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

    /**
     * Tạo đợt giao bài nháp, có thể gắn sẵn một nội dung trong ngân hàng.
     */
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

    private void validateTemplate(String type, Instant start, Instant end) {
        Instant now = clock.instant();
        if (start == null || end == null) {
            throw new TestException(400, "Hãy nhập đầy đủ thời gian bắt đầu và kết thúc.");
        }
        if (start.isBefore(now)) {
            throw new TestException(400, "Thời gian bắt đầu không được sớm hơn thời gian hiện tại.");
        }
        if (!start.isBefore(end)) {
            throw new TestException(400, "Thời gian kết thúc phải sau thời gian bắt đầu.");
        }
        if (!now.isBefore(end)
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
                throw new TestException(403, "Chỉ ADMIN tạo bài văn hóa.");
            }
            return null;
        }
        if (!actor.professionalManager()) {
            throw new TestException(403, "Bạn chưa được gán quyền tạo đánh giá chuyên môn.");
        }
        return actor.managedDepartmentId();
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
            if ("published".equals(to) && t.defaultContentId() != null
                    && !"ready".equals(dao.managedContent(actor, t.defaultContentId()).status())) {
                throw new TestException(409, "Hãy hoàn tất và chốt bộ trắc nghiệm trước khi công bố đợt giao bài.");
            }
            if ("published".equals(to) && !clock.instant().isBefore(t.endTime())) {
                throw new TestException(409, "Đề đã hết hạn, không thể công bố.");
            }
            changed(dao.execute("UPDATE Test_Templates SET status=?,updated_at=? WHERE id=? AND status=? AND is_deleted=0",
                    to, clock.instant(), id, from));
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

    /**
     * Chọn nội dung ready cùng loại/phạm vi quản lý cho toàn bộ người nhận.
     */
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
            Integer selectedContentId = contentId == null ? t.defaultContentId() : contentId;
            if (!policy.canAssign(actor, t, clock.instant())) {
                throw new TestException(403, "Không có quyền giao bài hoặc đề đã hết hạn.");
            }
            if (selectedContentId != null) {
                TestContent selected = dao.managedContent(actor, selectedContentId);
                if (!"ready".equals(selected.status())) {
                    throw new TestException(409, "Bộ đề/câu hỏi chưa sẵn sàng để giao.");
                }
                if (!selected.type().equals(t.type()) || (selected.departmentId() != null && !Objects.equals(selected.departmentId(), t.departmentId()))) {
                    throw new TestException(403, "Bộ đề/câu hỏi phải cùng phạm vi với đợt giao bài.");
                }
            }
            for (int id : ids) {
                TestActor recipient = dao.actor(id);
                if ("ADMIN".equals(recipient.role())) {
                    throw new TestException(403, "Không thể giao bài đánh giá cho tài khoản ADMIN.");
                }
                if (actor.departmentManager()
                        && (!"EMPLOYEE".equals(recipient.role())
                        || !Objects.equals(actor.managedDepartmentId(), recipient.departmentId()))) {
                    throw new TestException(403, "MANAGER chỉ được giao bài cho nhân viên trong phòng ban mình quản lý.");
                }
                int assignment = dao.insertId("INSERT INTO Test_Assignments(test_template_id,assignee_id,assigned_by,content_id) "
                        + "OUTPUT INSERTED.id VALUES (?,?,?,?)", templateId, id, actor.id(), selectedContentId);
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
     * Xem bài nộp trong phạm vi; không tiết lộ nội dung bài khác cùng phòng.
     */
    public TestAssignment getAssignment(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
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
            if (!policy.canEvaluateAssignee(actor, a)) {
                throw new TestException(403, "Chỉ người có chức vụ cao hơn người làm bài mới được đánh giá.");
            }
            if (!policy.canEvaluate(actor, a, t)) {
                throw new TestException(409, "Chỉ chấm bài đã nộp và chưa được đánh giá.");
            }
            dao.execute("INSERT INTO Test_Evaluations(test_assignment_id,evaluator_id,score,comment,evaluated_at) VALUES (?,?,?,?,?)",
                    id, actor.id(), score, note, clock.instant());
            changed(dao.execute("UPDATE Test_Assignments SET status='evaluated' WHERE id=? AND status='submitted' AND is_deleted=0", id));
            return null;
        });
    }

    /**
     * Thu hồi mềm bài chưa bắt đầu, giữ khóa chống giao trùng và lịch sử cho
     * đối soát.
     */
    public void revokeAssignment(int userId, int id) throws SQLException {
        transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            manage(actor, dao.template(actor, a.templateId()));
            if (!policy.canRevoke(actor, a)) {
                throw new TestException(403, "Chỉ người giao bài hoặc cấp trên mới được thu hồi bài thi.");
            }
            changed(dao.execute("UPDATE Test_Assignments SET is_deleted=1 WHERE id=? AND status='pending' AND is_deleted=0", id));
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
            return new Download(a.fileName(), bytes);
        });
    }

    /**
     * Đóng các đợt đã hết hạn. Assignment chưa làm vẫn được giữ lại để bảng
     * kết quả hiển thị trạng thái "Chưa làm".
     */
    public void closeExpiredTests(Instant now) throws SQLException {
        transaction(dao -> {
            dao.closeExpiredTests(now);
            return null;
        });
    }

    /**
     * Kho nội dung chỉ mở cho ADMIN hoặc MANAGER đang quản lý một phòng.
     */
    private void bankManager(TestActor actor) {
        if (!actor.cultureManager() && !actor.departmentManager()) {
            throw new TestException(403, "Bạn không có quyền quản lý bộ đề/câu hỏi.");
        }
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

    public record ContentDetail(TestContent content, List<TestQuestion> questions, Map<Integer, Set<Integer>> answers) {

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
     * Người làm nhận nội dung khi đến giờ. Khi xem bài của chính mình, cờ đáp
     * án đúng luôn bị ẩn kể cả tài khoản đồng thời có quyền quản lý.
     */
    public ContentDetail getAssignmentContent(int userId, int id) throws SQLException {
        return transaction(dao -> {
            TestActor actor = dao.actor(userId);
            TestAssignment a = assignment(dao, actor, id);
            TestTemplate t = dao.template(actor, a.templateId());
            boolean manager = policy.canManage(actor, t);
            boolean ownAssignment = a.assigneeId() == actor.id();
            if (ownAssignment && clock.instant().isBefore(t.startTime())) {
                return null;
            }
            TestContent content = dao.assignedContent(actor, id);
            if (content == null) {
                return null;
            }
            boolean includeAnswerKey = manager && !ownAssignment;
            return new ContentDetail(content, dao.questions(content.id(), includeAnswerKey), dao.answers(actor, id));
        });
    }

    /**
     * Nộp quiz nguyên tử: kiểm tra đủ câu/đúng bộ, lưu lựa chọn và tính điểm
     * trên server.
     */
    public void submitQuiz(int userId, int id, Map<Integer, Set<Integer>> answers) throws SQLException {
        if (answers == null || answers.isEmpty() || answers.size() > 100) {
            throw new TestException(400, "Hãy trả lời đầy đủ các câu hỏi.");
        }
        Map<Integer, Set<Integer>> submitted = new LinkedHashMap<>();
        answers.forEach((questionId, selected) -> submitted.put(questionId,
                selected == null ? Set.of() : new LinkedHashSet<>(selected)));
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
                Set<Integer> choices = submitted.get(q.id());
                Set<Integer> available = q.options().stream()
                        .map(TestQuestionOption::id).collect(java.util.stream.Collectors.toSet());
                if (choices == null || choices.isEmpty() || choices.size() > q.options().size()
                        || !available.containsAll(choices)) {
                    throw new TestException(400, "Lựa chọn không hợp lệ hoặc câu hỏi không thuộc bộ đề.");
                }
                if (!q.multipleChoice() && choices.size() != 1) {
                    throw new TestException(400, "Câu hỏi này chỉ được chọn một đáp án.");
                }
                if (choices.equals(q.correctOptionIds())) {
                    correct++;
                }
                for (Integer optionId : choices) {
                    dao.execute("INSERT INTO Test_Answer_Options(assignment_id,question_id,option_id) VALUES (?,?,?)",
                            id, q.id(), optionId);
                }
            }
            BigDecimal score = BigDecimal.valueOf(correct * 10L).divide(BigDecimal.valueOf(questions.size()), 2, java.math.RoundingMode.HALF_UP);
            changed(dao.execute("UPDATE Test_Assignments SET status='submitted',submitted_at=?,quiz_score=? WHERE id=? AND status IN ('pending','in_progress') AND is_deleted=0", now, score, id));
            return null;
        });
    }
}
