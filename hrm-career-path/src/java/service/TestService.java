package service;

import dal.DBContext;
import dal.TestDAO;
import java.math.BigDecimal;
import java.sql.*;
import java.time.*;
import java.util.*;
import model.*;
import policy.TestPolicy;

/**
 * Nghiệp vụ bài tự do; mọi entry point nhận userId từ session và đọc lại quyền
 * từ DB.
 */
public final class TestService {

    public static final int MAX_FILE_BYTES = 5 * 1024 * 1024;
    private final ConnectionFactory connections;
    private final Clock clock;
    private final TestPolicy policy = new TestPolicy();

    @FunctionalInterface
    public interface ConnectionFactory {

        Connection open() throws SQLException;
    }

    @FunctionalInterface
    private interface Work<T> {

        T run(TestDAO dao) throws SQLException;
    }

    /**
     * Cấu hình mặc định dùng SQL Server của dự án và đồng hồ UTC.
     */
    public TestService() {
        this(() -> DBContext.getInstance().getConnection(), Clock.systemUTC());
    }

    /**
     * Cho phép kiểm thử trên database riêng và thời gian cố định mà không sửa
     * dữ liệu thật.
     */
    public TestService(ConnectionFactory connections, Clock clock) {
        this.connections = connections;
        this.clock = clock;
    }

    /**
     * Serializable giữ quyền/trạng thái đã đọc ổn định đến commit; lỗi nào cũng
     * rollback.
     */
    private <T> T transaction(Work<T> work) throws SQLException {
        try (Connection conn = connections.open()) {
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            conn.setAutoCommit(false);
            try {
                T value = work.run(new TestDAO(conn));
                conn.commit();
                return value;
            } catch (SQLException | RuntimeException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollback) {
                    e.addSuppressed(rollback);
                }
                if (e instanceof SQLException) {
                    int code = ((SQLException) e).getErrorCode();
                    if (code == 2601 || code == 2627 || code == 1205) {
                        throw new TestException(409, "Dữ liệu đã thay đổi hoặc bị trùng. Hãy tải lại và thử lại.");
                    }
                }
                throw e;
            }
        }
    }

    /**
     * Chuẩn hóa và giới hạn văn bản phía server, không chỉ dựa vào maxlength
     * trên form.
     */
    private String text(String value, int max, boolean required) {
        String result = value == null ? "" : value.trim();
        if ((required && result.isEmpty()) || result.length() > max) {
            throw new TestException(400, "Nội dung bắt buộc bị trống hoặc vượt quá " + max + " ký tự.");
        }
        return result;
    }

    /**
     * Kiểm tra quyền chung để mọi thao tác quản lý đều không thể bỏ qua policy.
     */
    private void manage(TestActor actor, TestTemplate t) {
        if (!policy.canManage(actor, t)) {
            throw new TestException(403, "Bạn không có quyền quản lý bài test này.");
        }
    }

    /**
     * UPDATE không đổi đúng một dòng là xung đột trạng thái, không trả thành
     * công giả.
     */
    private void changed(int rows) {
        if (rows != 1) {
            throw new TestException(409, "Trạng thái đã thay đổi. Hãy tải lại trang.");
        }
    }

    /**
     * Trang lấy actor hiện tại để hiển thị hành động; server vẫn kiểm tra lại
     * khi POST.
     */
    public TestActor currentActor(int userId) throws SQLException {
        return transaction(dao -> dao.actor(userId));
    }

    /** Tạo đợt giao bài nháp, có thể gắn sẵn một nội dung trong ngân hàng. */
    public int createTemplate(int userId, String title, String description, String type,
            Instant start, Instant end) throws SQLException {
        return createTemplate(userId, title, description, type, start, end, null);
    }

    public int createTemplate(int userId, String title, String description, String type,
            Instant start, Instant end, Integer contentId) throws SQLException {
        final String checkedTitle = text(title, 200, true);
        final String checkedDescription = text(description, 20000, true);
        validateTemplate(type, start, end);
        return transaction(dao -> insertTemplate(dao, dao.actor(userId), checkedTitle,
                checkedDescription, type, start, end, contentId));
    }

    /**
     * Tạo đợt giao và bộ trắc nghiệm nháp trong cùng transaction. Nếu một bước
     * lỗi thì cả hai bản ghi đều được rollback, tránh để lại bộ đề mồ côi.
     */
    public CreatedTemplate createTemplateWithNewQuiz(int userId, String title, String description,
            String type, Instant start, Instant end, String quizTitle, String quizPrompt) throws SQLException {
        final String checkedTitle = text(title, 200, true);
        final String checkedDescription = text(description, 20000, true);
        final String checkedQuizTitle = text(quizTitle, 200, true);
        final String checkedQuizPrompt = text(quizPrompt, 20000, true);
        validateTemplate(type, start, end);
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            Integer department = templateDepartment(actor, type);
            int contentId = dao.insertId("INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by) "
                    + "OUTPUT INSERTED.id VALUES (?,?,?,?,?,?)", checkedQuizTitle,
                    checkedQuizPrompt, "quiz", type, department, actor.id());
            int templateId = insertTemplate(dao, actor, checkedTitle, checkedDescription,
                    type, start, end, contentId);
            return new CreatedTemplate(templateId, contentId);
        });
    }

    public record CreatedTemplate(int templateId, int contentId) { }

    private void validateTemplate(String type, Instant start, Instant end) {
        if (start == null || end == null || !start.isBefore(end) || !clock.instant().isBefore(end)
                || start.isBefore(Instant.parse("2000-01-01T00:00:00Z")) || end.isAfter(Instant.parse("2100-01-01T00:00:00Z"))) {
            throw new TestException(400, "Lịch phải hợp lệ, bắt đầu trước kết thúc và chưa hết hạn (năm 2000–2099).");
        }
        if (!"culture".equals(type) && !"department".equals(type)) {
            throw new TestException(400, "Loại bài test không hợp lệ.");
        }
    }

    private Integer templateDepartment(TestActor actor, String type) {
        if ("culture".equals(type)) {
            if (!actor.cultureManager()) {
                throw new TestException(403, "Chỉ ADMIN/HR tạo bài văn hóa.");
            }
            return null;
        }
        if (!actor.departmentManager() && !actor.cultureManager()) {
            throw new TestException(403, "Bạn chưa được gán quyền tạo đánh giá chuyên môn.");
        }
        return actor.cultureManager() ? null : actor.managedDepartmentId();
    }

    private int insertTemplate(TestDAO dao, TestActor actor, String title, String description,
            String type, Instant start, Instant end, Integer contentId) throws SQLException {
        Integer department = templateDepartment(actor, type);
        if (contentId != null) {
            TestContent selected = dao.managedContent(actor, contentId);
            if (!type.equals(selected.type()) || (selected.departmentId() != null
                    && !Objects.equals(department, selected.departmentId()))) {
                throw new TestException(400, "Bộ đề phải cùng loại với đợt giao bài.");
            }
        }
        int id = dao.insertId("INSERT INTO Test_Templates(title,description,type,department_id,created_by,start_time,end_time,default_content_id) "
                + "OUTPUT INSERTED.id VALUES (?,?,?,?,?,?,?,?)", title, description, type,
                department, actor.id(), start, end, contentId);
        dao.audit(actor, "create", id, null);
        return id;
    }

    /**
     * Công bố draft hoặc đóng published; đóng đề vẫn giữ nguyên bài nộp và
     * quyền chấm.
     */
    private void transition(int userId, int id, String from, String to) throws SQLException {
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestTemplate t = dao.template(actor, id);
            manage(actor, t);
            if ("published".equals(to) && t.defaultContentId()!=null
                    && !"ready".equals(dao.managedContent(actor,t.defaultContentId()).status()))
                throw new TestException(409,"Hãy hoàn tất và chốt bộ trắc nghiệm trước khi công bố đợt giao bài.");
            if ("published".equals(to) && !clock.instant().isBefore(t.endTime())) {
                throw new TestException(409, "Đề đã hết hạn, không thể công bố.");
            }
            changed(dao.execute("UPDATE Test_Templates SET status=?,updated_at=? WHERE id=? AND status=? AND is_deleted=0",
                    to, clock.instant(), id, from));
            dao.audit(actor, to, id, null);
            return null;
        });
    }

    /**
     * Chuyển draft sang published sau khi xác minh người quản lý.
     */
    public void publishTemplate(int userId, int id) throws SQLException {
        transition(userId, id, "draft", "published");
    }

    /**
     * Chuyển published sang closed, không nhận giao/nộp mới.
     */
    public void closeTemplate(int userId, int id) throws SQLException {
        transition(userId, id, "published", "closed");
    }

    /**
     * Xóa mềm draft/closed; đề đang mở phải đóng trước, audit và kết quả vẫn
     * được lưu.
     */
    public void archiveTemplate(int userId, int id) throws SQLException {
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestTemplate t = dao.template(actor, id);
            manage(actor, t);
            if ("published".equals(t.status())) {
                throw new TestException(409, "Hãy đóng đề trước khi lưu trữ.");
            }
            changed(dao.execute("UPDATE Test_Templates SET is_deleted=1,updated_at=? WHERE id=? AND is_deleted=0", clock.instant(), id));
            dao.audit(actor, "archive", id, null);
            return null;
        });
    }

    /**
     * Giới hạn trang và kích thước để tránh offset tràn số hoặc truy vấn không
     * giới hạn.
     */
    private int offset(int page, int size) {
        if (page < 1 || page > 100000 || size < 1 || size > 100) {
            throw new TestException(400, "Phân trang không hợp lệ.");
        }
        return (page - 1) * size;
    }

    /**
     * Danh sách có scope all/upcoming, lọc quyền trước khi phân trang trong
     * DAO.
     */
    public List<TestTemplate> listTemplates(int userId, String scope, int page, int size) throws SQLException {
        if (!"all".equals(scope) && !"upcoming".equals(scope)) {
            throw new TestException(400, "Bộ lọc không hợp lệ.");
        }
        int start = offset(page, size);
        return transaction(dao -> dao.templates(dao.actor(userId), "upcoming".equals(scope), clock.instant(), null, null, start, size));
    }

    /**
     * Chi tiết đề cùng audit đọc; ID ngoài phạm vi trả 404.
     */
    public TestTemplate getTemplate(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestTemplate t = dao.template(actor, id);
            dao.audit(actor, "view_template", id, null);
            return t;
        });
    }

    /**
     * Lịch không chứa đề draft, phân trang và giới hạn tối đa 366 ngày mỗi truy
     * vấn.
     */
    public List<TestTemplate> getCalendar(int userId, Instant from, Instant to, int page, int size) throws SQLException {
        if (from == null || to == null || !from.isBefore(to) || Duration.between(from, to).compareTo(Duration.ofDays(366)) > 0) {
            throw new TestException(400, "Khoảng lịch phải từ 1 đến 366 ngày.");
        }
        int start = offset(page, size);
        return transaction(dao -> dao.templates(dao.actor(userId), false, clock.instant(), from, to, start, size));
    }

    /**
     * Danh sách người nhận chỉ mở cho người có quyền giao đề còn hạn.
     */
    public List<TestActor> getCandidates(int userId, int templateId) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestTemplate t = dao.template(actor, templateId);
            if (!policy.canAssign(actor, t, clock.instant())) {
                throw new TestException(403, "Đề chưa cho phép giao bài.");
            }
            return dao.candidates(actor, t);
        });
    }

    /**
     * Giao hàng loạt nguyên tử: kiểm tra toàn bộ người nhận và rollback nếu có
     * ID sai/trùng DB.
     */
    public void assignTest(int userId, int templateId, List<Integer> assigneeIds) throws SQLException {
        assignTest(userId, templateId, assigneeIds, null);
    }

    /** Chọn nội dung ready cùng loại/phạm vi quản lý cho toàn bộ người nhận. */
    public void assignTest(int userId, int templateId, List<Integer> assigneeIds, Integer contentId) throws SQLException {
        if (assigneeIds == null || assigneeIds.isEmpty() || assigneeIds.size() > 500) {
            throw new TestException(400, "Chọn từ 1 đến 500 người nhận mỗi lần giao.");
        }
        Set<Integer> ids = new TreeSet<>();
        for (Integer id : assigneeIds) {
            if (id == null || id <= 0) {
                throw new TestException(400, "Người nhận không hợp lệ.");
            }
            ids.add(id);
        }
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestTemplate t = dao.template(actor, templateId);
            Integer selectedContentId=contentId==null?t.defaultContentId():contentId;
            if (!policy.canAssign(actor, t, clock.instant())) {
                throw new TestException(403, "Không có quyền giao bài hoặc đề đã hết hạn.");
            }
            if (selectedContentId != null) {
                TestContent selected = dao.managedContent(actor, selectedContentId);
                if (!"ready".equals(selected.status())) {
                    throw new TestException(409, "Bộ đề/câu hỏi chưa sẵn sàng để giao.");
                }
                if (!selected.type().equals(t.type()) || (selected.departmentId()!=null && !Objects.equals(selected.departmentId(), t.departmentId()))) {
                    throw new TestException(403, "Bộ đề/câu hỏi phải cùng phạm vi với đợt giao bài.");
                }
            }
            for (int id : ids) {
                TestActor recipient = dao.actor(id);
                if ("ADMIN".equals(recipient.role())) throw new TestException(403,"Không thể giao bài đánh giá cho tài khoản ADMIN.");
                int assignment = dao.insertId("INSERT INTO Test_Assignments(test_template_id,assignee_id,assigned_by,content_id) "
                        + "OUTPUT INSERTED.id VALUES (?,?,?,?)", templateId, id, actor.id(), selectedContentId);
                dao.audit(actor, "assign", templateId, assignment);
            }
            return null;
        });
    }

    /**
     * Lấy đúng một assignment qua query đã giới hạn owner/manager và phòng hiện
     * tại.
     */
    private TestAssignment assignment(TestDAO dao, TestActor actor, int id) throws SQLException {
        List<TestAssignment> rows = dao.assignments(actor, id, null, false, 0, 1);
        if (rows.isEmpty()) {
            throw new TestException(404, "Không tìm thấy bài được giao trong phạm vi của bạn.");
        }
        return rows.get(0);
    }

    /**
     * Trang bài của tôi không nhận assigneeId từ client; chỉ lấy userId phiên
     * đăng nhập.
     */
    public List<TestAssignment> getMyAssignments(int userId, int page, int size) throws SQLException {
        int start = offset(page, size);
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            if ("ADMIN".equals(actor.role())) {
                throw new TestException(403, "ADMIN không thuộc đối tượng thực hiện bài đánh giá.");
            }
            return dao.assignments(actor, null, null, true, start, size);
        });
    }

    /**
     * Hàng đợi chấm theo đề chỉ người quản lý được đọc; từng assignment vẫn lọc
     * lại ở SQL.
     */
    public List<TestAssignment> getTemplateAssignments(int userId, int id, int page, int size) throws SQLException {
        int start = offset(page, size);
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            manage(actor, dao.template(actor, id));
            return dao.assignments(actor, null, id, false, start, size);
        });
    }

    /**
     * Ghi audit khi xem bài nộp; không tiết lộ nội dung bài khác cùng phòng.
     */
    public TestAssignment getAssignment(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            dao.audit(actor, "view_assignment", a.templateId(), id);
            return a;
        });
    }

    /**
     * Bắt đầu đúng cửa sổ làm bài; gọi lại khi in_progress là idempotent.
     */
    public void startAssignment(int userId, int id) throws SQLException {
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            TestTemplate t = dao.template(actor, a.templateId());
            if (!policy.canSubmit(actor, a, t, clock.instant())) {
                throw new TestException(409, "Bạn không thể bắt đầu bài này lúc này.");
            }
            if ("pending".equals(a.status())) {
                changed(dao.execute("UPDATE Test_Assignments SET status='in_progress' WHERE id=? AND status='pending' AND is_deleted=0", id));
                dao.audit(actor, "start", t.id(), id);
            }
            return null;
        });
    }

    /**
     * Nộp văn bản hoặc file tối đa 5 MiB; file lưu riêng trong DB, không nhận
     * file_url từ client.
     */
    public void submitAssignment(int userId, int id, String content, String filename, byte[] file) throws SQLException {
        String body = text(content, 50000, false);
        if (file != null && (file.length == 0 || file.length > MAX_FILE_BYTES)) {
            throw new TestException(400, "File phải từ 1 byte đến 5 MiB.");
        }
        String safeName = file == null ? null : text(filename, 200, true).replaceAll("[\\\\/\\r\\n\\x00]", "_");
        if (body.isEmpty() && file == null) {
            throw new TestException(400, "Hãy nhập nội dung hoặc đính kèm file.");
        }
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            TestTemplate t = dao.template(actor, a.templateId());
            Instant now = clock.instant();
            if (!policy.canSubmit(actor, a, t, now)) {
                throw new TestException(409, "Bài đã nộp, chưa mở, hết hạn hoặc không thuộc về bạn.");
            }
            if ("quiz".equals(a.contentKind())) {
                throw new TestException(400, "Bài trắc nghiệm phải nộp bằng các lựa chọn trả lời.");
            }
            changed(dao.execute("UPDATE Test_Assignments SET submission_content=?,file_name=?,file_data=?,submitted_at=?,status='submitted' "
                    + "WHERE id=? AND assignee_id=? AND status IN ('pending','in_progress') AND is_deleted=0",
                    body, safeName, new TestDAO.Binary(file), now, id, actor.id()));
            dao.audit(actor, "submit", t.id(), id);
            return null;
        });
    }

    /**
     * Chấm 0–10 với tối đa 2 chữ số thập phân; INSERT và đổi trạng thái cùng
     * transaction.
     */
    public void evaluateAssignment(int userId, int id, BigDecimal score, String comment) throws SQLException {
        if (score == null || score.compareTo(BigDecimal.ZERO) < 0 || score.compareTo(BigDecimal.TEN) > 0 || score.scale() > 2) {
            throw new TestException(400, "Điểm phải từ 0 đến 10 và tối đa 2 chữ số thập phân.");
        }
        String note = text(comment, 4000, true);
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            TestTemplate t = dao.template(actor, a.templateId());
            manage(actor, t);
            if (!policy.canEvaluate(actor, a, t)) {
                throw new TestException(409, "Chỉ chấm bài đã nộp và chưa được đánh giá.");
            }
            dao.execute("INSERT INTO Test_Evaluations(test_assignment_id,evaluator_id,score,comment,evaluated_at) VALUES (?,?,?,?,?)",
                    id, actor.id(), score, note, clock.instant());
            changed(dao.execute("UPDATE Test_Assignments SET status='evaluated' WHERE id=? AND status='submitted' AND is_deleted=0", id));
            dao.audit(actor, "evaluate", t.id(), id);
            return null;
        });
    }

    /**
     * Thu hồi mềm bài chưa bắt đầu, giữ khóa chống giao trùng và lịch sử cho
     * đối soát.
     */
    public void archiveAssignment(int userId, int id) throws SQLException {
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            manage(actor, dao.template(actor, a.templateId()));
            changed(dao.execute("UPDATE Test_Assignments SET is_deleted=1 WHERE id=? AND status='pending' AND is_deleted=0", id));
            dao.audit(actor, "revoke_assignment", a.templateId(), id);
            return null;
        });
    }

    public record Download(String name, byte[] bytes) {

    }

    /**
     * File luôn trả dạng attachment qua controller, không thực thi HTML/SVG
     * người nộp gửi lên.
     */
    public Download download(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            byte[] bytes = dao.file(actor, id);
            dao.audit(actor, "download", a.templateId(), id);
            return new Download(a.fileName(), bytes);
        });
    }

    /**
     * Danh sách thông báo giới hạn 100 mới nhất và kiểm tra lại quyền trên
     * assignment.
     */
    public List<TestNotification> getNotifications(int userId) throws SQLException {
        return transaction(dao -> dao.notifications(dao.actor(userId)));
    }

    /**
     * Chỉ chủ thông báo được đánh dấu đã đọc, kể cả khi sửa ID trong form.
     */
    public void readNotification(int userId, int id) throws SQLException {
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            changed(dao.execute("UPDATE Test_Notifications SET read_at=COALESCE(read_at,?) WHERE id=? AND user_id=?", clock.instant(), id, actor.id()));
            return null;
        });
    }

    /**
     * Outbox commit trước; delivery transaction sau tự retry lần chạy tới nếu
     * có lỗi.
     */
    public void sendUpcomingReminders(Instant now) throws SQLException {
        transaction(dao -> {
            dao.enqueueReminders(now);
            return null;
        });
        transaction(dao -> {
            dao.deliverReminders(now);
            return null;
        });
    }

    /** Kho nội dung chỉ mở cho ADMIN/HR hoặc MANAGER đang quản lý một phòng. */
    private void bankManager(TestActor actor) {
        if (!actor.cultureManager() && !actor.departmentManager()) {
            throw new TestException(403, "Bạn không có quyền quản lý bộ đề/câu hỏi.");
        }
    }

    /**
     * Tạo nội dung nháp; scope tự lấy từ quyền hiện tại, không nhận phòng từ
     * form.
     */
    public int createContent(int userId, String kind, String title, String prompt) throws SQLException {
        return createContent(userId, kind, title, prompt, null);
    }

    public int createContent(int userId, String kind, String title, String prompt, String requestedType) throws SQLException {
        if (!"quiz".equals(kind) && !"question".equals(kind)) {
            throw new TestException(400, "Hình thức không hợp lệ.");
        }
        String name = text(title, 200, true), body = text(prompt, 20000, true);
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            bankManager(actor);
            String scopeType = requestedType == null
                    ? (actor.cultureManager() ? "culture" : "department") : requestedType;
            if (!"culture".equals(scopeType) && !"department".equals(scopeType)) {
                throw new TestException(400, "Loại ngân hàng không hợp lệ.");
            }
            if ("culture".equals(scopeType) && !actor.cultureManager()) {
                throw new TestException(403, "Không có quyền tạo ngân hàng văn hóa.");
            }
            Integer department = "department".equals(scopeType) && !actor.cultureManager()
                    ? actor.managedDepartmentId() : null;
            return dao.insertId("INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by) OUTPUT INSERTED.id VALUES (?,?,?,?,?,?)",
                    name, body, kind, scopeType, department, actor.id());
        });
    }

    /**
     * Xem kho có phân trang, không cho nhân viên dò ID lấy đáp án.
     */
    public List<TestContent> listContent(int userId, int page, int size) throws SQLException {
        int start = offset(page, size);
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            bankManager(actor);
            return dao.contents(actor, null, start, size);
        });
    }

    /** Xóa mềm các bộ đề được chọn; bài đã giao vẫn giữ nguyên nội dung lịch sử. */
    public void deleteContents(int userId, List<Integer> contentIds) throws SQLException {
        if (contentIds == null || contentIds.isEmpty() || contentIds.size() > 100) {
            throw new TestException(400, "Hãy chọn từ 1 đến 100 bộ đề để xóa.");
        }
        Set<Integer> ids = new LinkedHashSet<>(contentIds);
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            bankManager(actor);
            for (Integer id : ids) {
                if (id == null || id <= 0) throw new TestException(400, "Bộ đề không hợp lệ.");
                dao.managedContent(actor, id);
                changed(dao.execute("UPDATE Test_Content SET is_deleted=1 WHERE id=? AND is_deleted=0", id));
            }
            return null;
        });
    }

    public record ContentDetail(TestContent content, List<TestQuestion> questions, Map<Integer, Integer> answers) {

    }

    /**
     * Người quản lý xem đề nháp/ready và đáp án đúng để kiểm tra trước khi
     * giao.
     */
    public ContentDetail getContent(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestContent content = dao.managedContent(actor, id);
            return new ContentDetail(content, dao.questions(id, true), Map.of());
        });
    }

    /**
     * Thêm câu trắc nghiệm 4 lựa chọn, 1 đáp án; chỉ sửa draft, tối đa 100
     * câu/bộ.
     */
    public void addQuestion(int userId, int id, String prompt, List<String> options, int correct) throws SQLException {
        String body = text(prompt, 4000, true);
        List<String> choices = questionOptions(options, correct);
        transaction(dao -> {
            TestContent content = dao.managedContent(dao.actor(userId), id);
            if (!"draft".equals(content.status()) || !"quiz".equals(content.kind())) {
                throw new TestException(409, "Chỉ thêm câu vào bộ trắc nghiệm nháp.");
            }
            if (dao.questions(id, false).size() >= 100) {
                throw new TestException(400, "Mỗi bộ đề tối đa 100 câu.");
            }
            dao.execute("INSERT INTO Test_Questions(content_id,prompt,option_a,option_b,option_c,option_d,correct_option) VALUES (?,?,?,?,?,?,?)",
                    id, body, choices.get(0), choices.get(1), choices.get(2), choices.get(3), correct);
            return null;
        });
    }

    /**
     * Xóa câu nháp nhập sai; bộ ready bất biến để bài đã giao không đổi nội
     * dung/đáp án.
     */
    public void removeQuestion(int userId, int id, int questionId) throws SQLException {
        transaction(dao -> {
            TestContent content = dao.managedContent(dao.actor(userId), id);
            if (!"draft".equals(content.status())) {
                throw new TestException(409, "Bộ đề sẵn sàng không được thay đổi.");
            }
            changed(dao.execute("DELETE FROM Test_Questions WHERE id=? AND content_id=?", questionId, id));
            return null;
        });
    }

    /** Sửa câu nhập sai khi bộ đề vẫn còn là bản nháp. */
    public void updateQuestion(int userId, int id, int questionId, String prompt,
            List<String> options, int correct) throws SQLException {
        String body = text(prompt, 4000, true);
        List<String> choices = questionOptions(options, correct);
        transaction(dao -> {
            TestContent content = dao.managedContent(dao.actor(userId), id);
            if (!"draft".equals(content.status()) || !"quiz".equals(content.kind())) {
                throw new TestException(409, "Chỉ sửa câu trong bộ trắc nghiệm nháp.");
            }
            changed(dao.execute("UPDATE Test_Questions SET prompt=?,option_a=?,option_b=?,option_c=?,option_d=?,correct_option=? WHERE id=? AND content_id=?",
                    body, choices.get(0), choices.get(1), choices.get(2), choices.get(3), correct, questionId, id));
            return null;
        });
    }

    private List<String> questionOptions(List<String> options, int correct) {
        if (options == null || options.size() != 4 || correct < 0 || correct > 3) {
            throw new TestException(400, "Cần 4 lựa chọn và 1 đáp án đúng.");
        }
        List<String> choices = new ArrayList<>();
        Set<String> normalized = new HashSet<>();
        for (String value : options) {
            String choice = text(value, 1000, true);
            choices.add(choice);
            normalized.add(choice.toLowerCase(Locale.ROOT));
        }
        if (normalized.size() != 4) {
            throw new TestException(400, "Bốn lựa chọn A, B, C và D phải khác nhau.");
        }
        return choices;
    }

    /**
     * Chốt nội dung trước khi giao; quiz rỗng không được chuyển ready.
     */
    public void publishContent(int userId, int id) throws SQLException {
        transaction(dao -> {
            TestContent content = dao.managedContent(dao.actor(userId), id);
            if ("quiz".equals(content.kind()) && dao.questions(id, false).isEmpty()) {
                throw new TestException(400, "Hãy thêm ít nhất một câu trắc nghiệm.");
            }
            changed(dao.execute("UPDATE Test_Content SET status='ready' WHERE id=? AND status='draft'", id));
            return null;
        });
    }

    /**
     * Selector khi giao chỉ chứa bộ trắc nghiệm/câu hỏi đã chốt, đúng phạm vi
     * đợt giao.
     */
    public List<TestContent> getContentChoices(int userId, int templateId) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestTemplate t = dao.template(actor, templateId);
            if (!policy.canAssign(actor, t, clock.instant())) {
                throw new TestException(403, "Đề chưa cho phép giao bài.");
            }
            return dao.contents(actor, t, 0, 0);
        });
    }

    /**
     * Người làm nhận nội dung khi đến giờ, tuyệt đối không nhận correctOption
     * trong DTO/HTML.
     */
    public ContentDetail getAssignmentContent(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            TestTemplate t = dao.template(actor, a.templateId());
            boolean manager = policy.canManage(actor, t);
            if (!manager && clock.instant().isBefore(t.startTime())) {
                return null;
            }
            TestContent content = dao.assignedContent(actor, id);
            if (content == null) {
                return null;
            }
            return new ContentDetail(content, dao.questions(content.id(), manager), dao.answers(actor, id));
        });
    }

    /**
     * Nộp quiz nguyên tử: kiểm tra đủ câu/đúng bộ, lưu lựa chọn và tính điểm
     * trên server.
     */
    public void submitQuiz(int userId, int id, Map<Integer, Integer> answers) throws SQLException {
        if (answers == null || answers.isEmpty() || answers.size() > 100) {
            throw new TestException(400, "Hãy trả lời đầy đủ các câu hỏi.");
        }
        Map<Integer, Integer> submitted = new LinkedHashMap<>(answers);
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            TestTemplate t = dao.template(actor, a.templateId());
            Instant now = clock.instant();
            if (!policy.canSubmit(actor, a, t, now)) {
                throw new TestException(409, "Bài đã nộp, chưa mở, hết hạn hoặc không thuộc về bạn.");
            }
            if (!"quiz".equals(a.contentKind()) || a.contentId() == null) {
                throw new TestException(400, "Đây không phải bài trắc nghiệm.");
            }
            List<TestQuestion> questions = dao.questions(a.contentId(), true);
            if (questions.isEmpty() || submitted.size() != questions.size()) {
                throw new TestException(400, "Hãy trả lời đúng và đủ câu của bộ đề được giao.");
            }
            int correct = 0;
            for (TestQuestion q : questions) {
                Integer choice = submitted.get(q.id());
                if (choice == null || choice < 0 || choice > 3) {
                    throw new TestException(400, "Lựa chọn không hợp lệ hoặc câu hỏi không thuộc bộ đề.");
                }
                if (choice.equals(q.correctOption())) {
                    correct++;
                }
                dao.execute("INSERT INTO Test_Answers(assignment_id,question_id,selected_option) VALUES (?,?,?)", id, q.id(), choice);
            }
            BigDecimal score = BigDecimal.valueOf(correct * 10L).divide(BigDecimal.valueOf(questions.size()), 2, java.math.RoundingMode.HALF_UP);
            changed(dao.execute("UPDATE Test_Assignments SET status='submitted',submitted_at=?,quiz_score=? WHERE id=? AND status IN ('pending','in_progress') AND is_deleted=0", now, score, id));
            dao.audit(actor, "submit_quiz", t.id(), id);
            return null;
        });
    }
}
