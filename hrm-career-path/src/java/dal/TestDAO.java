package dal;

import java.sql.*;
import java.time.*;
import java.util.*;
import model.*;
import service.TestException;

/**
 * DAO được tạo theo transaction; không giữ connection trong field static dùng
 * chung.
 */
public final class TestDAO {

    private final Connection conn;

    /** Giữ kiểu VARBINARY khi file null, tránh SQL Server nhận tham số NVARCHAR NULL. */
    public record Binary(byte[] value) { }

    public TestDAO(Connection conn) {
        this.conn = conn;
    }

    /**
     * Bind tham số, quy đổi Instant thành DATETIME2 UTC nhất quán khi đọc/ghi.
     */
    private PreparedStatement prepare(String sql, Object... args) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(sql);
        try {
            for (int i = 0; i < args.length; i++) {
                Object value = args[i];
                if (value instanceof Binary) {
                    ps.setBytes(i + 1, ((Binary) value).value());
                    continue;
                }
                if (value instanceof Instant) {
                    value = LocalDateTime.ofInstant((Instant) value, ZoneOffset.UTC);
                }
                ps.setObject(i + 1, value);
            }
            return ps;
        } catch (SQLException e) {
            ps.close();
            throw e;
        }
    }

    /**
     * Thực thi câu ghi đã tham số hóa; service kiểm tra số dòng để phát hiện
     * xung đột.
     */
    public int execute(String sql, Object... args) throws SQLException {
        try (PreparedStatement ps = prepare(sql, args)) {
            return ps.executeUpdate();
        }
    }

    /**
     * INSERT ... OUTPUT INSERTED.id trả khóa mới trên chính connection
     * transaction.
     */
    public int insertId(String sql, Object... args) throws SQLException {
        try (PreparedStatement ps = prepare(sql, args); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                throw new SQLException("Insert did not return id");
            }
            return rs.getInt(1);
        }
    }

    /**
     * Tải lại tài khoản và phòng quản lý còn hoạt động, kể cả khi session chứa
     * quyền cũ.
     */
    public TestActor actor(int id) throws SQLException {
        String sql = "SELECT u.user_id,u.full_name,r.role_name,u.department_id,d.department_id AS managed_id "
                + "FROM Users u JOIN Roles r ON r.role_id=u.role_id "
                + "LEFT JOIN Departments d ON d.department_id=u.department_id AND d.manager_id=u.user_id "
                + "AND d.is_deleted=0 AND d.status=1 WHERE u.user_id=? AND u.is_deleted=0 AND u.status=1";
        try (PreparedStatement ps = prepare(sql, id); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                throw new TestException(403, "Tài khoản không còn hoạt động.");
            }
            return new TestActor(id, rs.getString("full_name"), rs.getString("role_name"),
                    (Integer) rs.getObject("department_id"), (Integer) rs.getObject("managed_id"));
        }
    }

    /**
     * Điều kiện quản lý sinh từ quyền vừa đọc DB; giá trị phòng luôn bind bằng
     * tham số.
     */
    private String management(TestActor actor, List<Object> args) {
        args.add(actor.departmentManager() ? actor.managedDepartmentId() : null);
        return "((t.type='culture' AND " + (actor.cultureManager() ? "1=1" : "1=0")
                + ") OR (t.type='department' AND (" + (actor.cultureManager() ? "1=1" : "1=0") + " OR t.department_id=?)))";
    }

    /** Lọc xóa mềm và giữ đề nháp trong phạm vi quản lý ngay tại SQL. */
    private String visible(TestActor actor, List<Object> args) {
        return "t.is_deleted=0 AND (t.status<>'draft' OR " + management(actor, args) + ")";
    }

    /**
     * Chuyển DATETIME2 UTC về Instant; không phụ thuộc múi giờ của máy chạy
     * Tomcat.
     */
    private Instant instant(ResultSet rs, String column) throws SQLException {
        LocalDateTime value = rs.getObject(column, LocalDateTime.class);
        return value == null ? null : value.toInstant(ZoneOffset.UTC);
    }

    /**
     * Ánh xạ đề; câu query đã lọc quyền trước khi hàm này chạy.
     */
    private TestTemplate template(ResultSet rs) throws SQLException {
        return new TestTemplate(rs.getInt("id"), rs.getString("title"), rs.getString("description"),
                rs.getString("type"), (Integer) rs.getObject("department_id"), rs.getInt("created_by"),
                rs.getString("status"), instant(rs, "start_time"), instant(rs, "end_time"),
                (Integer) rs.getObject("default_content_id"));
    }

    /**
     * Lấy đề theo ID trong phạm vi; cùng 404 cho ID không tồn tại hoặc không
     * được phép.
     */
    public TestTemplate template(TestActor actor, int id) throws SQLException {
        List<Object> args = new ArrayList<>();
        String filter = visible(actor, args);
        args.add(id);
        try (PreparedStatement ps = prepare("SELECT t.* FROM Test_Templates t WHERE " + filter + " AND t.id=?", args.toArray()); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                throw new TestException(404, "Không tìm thấy bài test trong phạm vi của bạn.");
            }
            return template(rs);
        }
    }

    /**
     * Phân trang sau khi lọc quyền; lịch dùng điều kiện giao nhau, upcoming
     * loại draft/closed.
     */
    public List<TestTemplate> templates(TestActor actor, boolean upcoming, Instant now,
            Instant from, Instant to, int offset, int size) throws SQLException {
        List<Object> args = new ArrayList<>();
        String sql = "SELECT t.* FROM Test_Templates t WHERE " + visible(actor, args);
        if (upcoming) {
            sql += " AND t.status='published' AND t.start_time>?";
            args.add(now);
        }
        if (from != null) {
            sql += " AND t.status<>'draft' AND t.start_time<? AND t.end_time>?";
            args.add(to);
            args.add(from);
        }
        sql += " ORDER BY t.start_time,t.id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        args.add(offset);
        args.add(size);
        List<TestTemplate> result = new ArrayList<>();
        try (PreparedStatement ps = prepare(sql, args.toArray()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(template(rs));
            }
        }
        return result;
    }

    /** Phạm vi assignment: assignee còn hoạt động, chủ bài hoặc người quản lý. */
    private String assignmentScope(TestActor actor, List<Object> args) {
        String result = visible(actor, args)
                + " AND a.is_deleted=0 AND u.is_deleted=0 AND u.status=1 "
                + "AND (a.assignee_id=? OR ";
        args.add(actor.id());
        return result + management(actor, args) + ")";
    }

    private static final String ASSIGNMENT_FROM = " FROM Test_Assignments a "
            + "JOIN Test_Templates t ON t.id=a.test_template_id JOIN Users u ON u.user_id=a.assignee_id ";

    /**
     * Lấy bài nộp đã lọc quyền; chỉ trang detail mới đọc nội dung, danh sách
     * không đọc file.
     */
    public List<TestAssignment> assignments(TestActor actor, Integer id, Integer templateId,
            boolean mine, int offset, int size) throws SQLException {
        List<Object> args = new ArrayList<>();
        String filter = assignmentScope(actor, args);
        if (id != null) {
            filter += " AND a.id=?";
            args.add(id);
        }
        if (templateId != null) {
            filter += " AND t.id=?";
            args.add(templateId);
        }
        if (mine) {
            filter += " AND a.assignee_id=?";
            args.add(actor.id());
        }
        args.add(offset);
        args.add(size);
        String sql = "SELECT a.id,a.test_template_id,a.assignee_id,a.status,a.submitted_at,a.file_name,"
                + (id != null ? "a.submission_content" : "CAST(NULL AS NVARCHAR(MAX)) AS submission_content")
                + ",t.title,u.full_name,e.evaluator_id,e.score,e.comment,e.evaluated_at,a.content_id,a.quiz_score,"
                + "b.kind AS content_kind,b.title AS content_title" + ASSIGNMENT_FROM
                + "LEFT JOIN Test_Content b ON b.id=a.content_id "
                + "LEFT JOIN Test_Evaluations e ON e.test_assignment_id=a.id WHERE " + filter
                + " ORDER BY a.id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<TestAssignment> result = new ArrayList<>();
        try (PreparedStatement ps = prepare(sql, args.toArray()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TestEvaluation evaluation = rs.getObject("evaluator_id") == null ? null : new TestEvaluation(
                        rs.getInt("evaluator_id"), rs.getBigDecimal("score"), rs.getString("comment"), instant(rs, "evaluated_at"));
                result.add(new TestAssignment(rs.getInt("id"), rs.getInt("test_template_id"), rs.getInt("assignee_id"),
                        rs.getString("full_name"), rs.getString("title"), rs.getString("status"), instant(rs, "submitted_at"),
                        rs.getString("submission_content"), rs.getString("file_name"), evaluation,
                        (Integer) rs.getObject("content_id"), rs.getString("content_kind"),
                        rs.getString("content_title"), rs.getBigDecimal("quiz_score")));
            }
        }
        return result;
    }

    /** Ánh xạ bộ đề/câu hỏi, không chứa đáp án đúng trong đối tượng metadata. */
    private TestContent content(ResultSet rs) throws SQLException {
        return new TestContent(rs.getInt("id"), rs.getString("title"), rs.getString("prompt"),
                rs.getString("kind"), rs.getString("type"), (Integer) rs.getObject("department_id"), rs.getString("status"));
    }

    /** Kho chỉ dành cho người quản lý đúng phạm vi; lấy theo ID cũng áp điều kiện SQL. */
    public TestContent managedContent(TestActor actor, int id) throws SQLException {
        List<Object> args = new ArrayList<>();
        String scope = management(actor, args);
        args.add(id);
        try (PreparedStatement ps = prepare("SELECT t.* FROM Test_Content t WHERE t.is_deleted=0 AND " + scope + " AND t.id=?", args.toArray()); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) throw new TestException(404, "Không tìm thấy bộ đề/câu hỏi trong phạm vi quản lý.");
            return content(rs);
        }
    }

    /** Danh sách kho có phân trang; selector chỉ trả nội dung ready cùng phạm vi của đợt giao. */
    public List<TestContent> contents(TestActor actor, TestTemplate target, int offset, int size) throws SQLException {
        List<Object> args = new ArrayList<>();
        String sql = "SELECT t.id,t.title,CAST('' AS NVARCHAR(MAX)) AS prompt,t.kind,t.type,t.department_id,t.status FROM Test_Content t WHERE t.is_deleted=0 AND " + management(actor, args);
        if (target != null) {
            sql += " AND t.status='ready' AND t.type=? AND (t.department_id IS NULL OR t.department_id=?)";
            args.add(target.type()); args.add(target.departmentId());
        }
        sql += " ORDER BY t.id DESC";
        if (target == null) { sql += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"; args.add(offset); args.add(size); }
        List<TestContent> result = new ArrayList<>();
        try (PreparedStatement ps = prepare(sql, args.toArray()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) result.add(content(rs));
        }
        return result;
    }

    /** Nội dung được giao chỉ tải qua assignment còn quyền; không mở kho cho người làm. */
    public TestContent assignedContent(TestActor actor, int id) throws SQLException {
        List<Object> args = new ArrayList<>();
        String scope = assignmentScope(actor, args);
        args.add(id);
        try (PreparedStatement ps = prepare("SELECT b.*" + ASSIGNMENT_FROM + "JOIN Test_Content b ON b.id=a.content_id WHERE " + scope + " AND a.id=?", args.toArray()); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? content(rs) : null;
        }
    }

    /** Chỉ gọi sau khi service kiểm tra quyền bộ đề/assignment trong cùng transaction. */
    public List<TestQuestion> questions(int contentId, boolean includeKey) throws SQLException {
        String sql = "SELECT id,prompt,option_a,option_b,option_c,option_d,"
                + (includeKey ? "correct_option" : "CAST(NULL AS INT) AS correct_option")
                + " FROM Test_Questions WHERE content_id=? ORDER BY id";
        List<TestQuestion> rows = new ArrayList<>();
        try (PreparedStatement ps = prepare(sql, contentId); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) rows.add(new TestQuestion(rs.getInt("id"), rs.getString("prompt"),
                    List.of(rs.getString("option_a"),rs.getString("option_b"),rs.getString("option_c"),rs.getString("option_d")),
                    (Integer) rs.getObject("correct_option")));
        }
        return rows;
    }

    /** Trả lựa chọn đã nộp chỉ sau khi xác minh quyền assignment ngay trong SQL. */
    public Map<Integer,Integer> answers(TestActor actor, int id) throws SQLException {
        List<Object> args = new ArrayList<>();
        String scope = assignmentScope(actor, args);
        args.add(id);
        Map<Integer,Integer> result = new LinkedHashMap<>();
        try (PreparedStatement ps = prepare("SELECT x.question_id,x.selected_option" + ASSIGNMENT_FROM
                + "JOIN Test_Answers x ON x.assignment_id=a.id WHERE " + scope + " AND a.id=?", args.toArray()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) result.put(rs.getInt(1),rs.getInt(2));
        }
        return result;
    }

    /**
     * Tải file chỉ sau khi SQL kiểm tra cùng phạm vi với trang bài nộp.
     */
    public byte[] file(TestActor actor, int assignmentId) throws SQLException {
        List<Object> args = new ArrayList<>();
        String filter = assignmentScope(actor, args);
        args.add(assignmentId);
        try (PreparedStatement ps = prepare("SELECT a.file_data" + ASSIGNMENT_FROM + "WHERE " + filter + " AND a.id=?", args.toArray()); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                throw new TestException(404, "Không tìm thấy file.");
            }
            byte[] bytes = rs.getBytes(1);
            if (bytes == null) {
                throw new TestException(404, "Bài nộp không có file.");
            }
            return bytes;
        }
    }

    /**
     * Danh sách ứng viên chưa được giao, chỉ trong phạm vi đề người quản lý
     * được thao tác.
     */
    public List<TestActor> candidates(TestActor actor, TestTemplate t) throws SQLException {
        List<Object> args = new ArrayList<>();
        String filter = visible(actor, args) + " AND " + management(actor, args);
        args.add(t.id());
        String sql = "SELECT u.user_id,u.full_name,u.department_id FROM Users u JOIN Roles r ON r.role_id=u.role_id CROSS JOIN Test_Templates t WHERE "
                + filter + " AND t.id=? AND u.is_deleted=0 AND u.status=1 "
                + "AND r.role_name<>'ADMIN' "
                + "AND NOT EXISTS (SELECT 1 FROM Test_Assignments a WHERE a.test_template_id=t.id AND a.assignee_id=u.user_id) "
                + "ORDER BY u.full_name,u.user_id";
        List<TestActor> result = new ArrayList<>();
        try (PreparedStatement ps = prepare(sql, args.toArray()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(new TestActor(rs.getInt(1), rs.getString(2), "", (Integer) rs.getObject(3), null));
            }
        }
        return result;
    }

    /**
     * Ghi dấu vết xem chi tiết/ghi dữ liệu trong cùng transaction, không lưu
     * nội dung nhạy cảm.
     */
    public void audit(TestActor actor, String action, int templateId, Integer assignmentId) throws SQLException {
        execute("INSERT INTO Test_Audit(actor_id,action,template_id,assignment_id) VALUES (?,?,?,?)",
                actor.id(), action, templateId, assignmentId);
    }

    /**
     * Thông báo chỉ của actor và assignment vẫn còn được phép xem sau khi
     * chuyển phòng.
     */
    public List<TestNotification> notifications(TestActor actor) throws SQLException {
        List<Object> args = new ArrayList<>();
        String filter = assignmentScope(actor, args);
        args.add(actor.id());
        List<TestNotification> result = new ArrayList<>();
        String sql = "SELECT TOP (100) n.*" + ASSIGNMENT_FROM
                + "JOIN Test_Notifications n ON n.assignment_id=a.id WHERE " + filter + " AND n.user_id=? ORDER BY n.id DESC";
        try (PreparedStatement ps = prepare(sql, args.toArray()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(new TestNotification(rs.getInt("id"), rs.getInt("assignment_id"),
                        rs.getString("message"), instant(rs, "created_at"), rs.getObject("read_at") != null));
            }
        }
        return result;
    }

    /**
     * Tạo outbox idempotent cho bài pending trong 24 giờ trước lịch; unique
     * chống job chạy lặp.
     */
    public void enqueueReminders(Instant now) throws SQLException {
        execute("INSERT INTO Test_Reminder_Outbox(assignment_id,scheduled_start) "
                + "SELECT a.id,t.start_time" + ASSIGNMENT_FROM
                + "WHERE a.status='pending' AND a.is_deleted=0 AND t.is_deleted=0 AND t.status='published' "
                + "AND u.status=1 AND u.is_deleted=0 "
                + "AND t.start_time>? AND t.start_time<=? AND NOT EXISTS "
                + "(SELECT 1 FROM Test_Reminder_Outbox o WITH (UPDLOCK,HOLDLOCK) WHERE o.assignment_id=a.id AND o.scheduled_start=t.start_time)",
                now, now.plus(Duration.ofHours(24)));
    }

    /**
     * Worker ghi thông báo nội bộ và đánh dấu delivered trong cùng transaction;
     * lỗi sẽ retry lần sau.
     */
    public void deliverReminders(Instant now) throws SQLException {
        execute("UPDATE Test_Templates SET status='closed',updated_at=? WHERE status='published' AND end_time<=?", now, now);
        execute("UPDATE Test_Assignments SET is_deleted=1 WHERE status='pending' AND is_deleted=0 AND test_template_id IN (SELECT id FROM Test_Templates WHERE status='closed' AND end_time<=?)", now);
        execute("INSERT INTO Test_Notifications(outbox_id,user_id,assignment_id,message) "
                + "SELECT o.id,a.assignee_id,a.id,N'Bài test sắp bắt đầu: '+t.title FROM Test_Reminder_Outbox o "
                + "JOIN Test_Assignments a ON a.id=o.assignment_id JOIN Test_Templates t ON t.id=a.test_template_id "
                + "JOIN Users u ON u.user_id=a.assignee_id WHERE o.delivered_at IS NULL "
                + "AND a.status='pending' AND a.is_deleted=0 AND t.is_deleted=0 AND t.status='published' "
                + "AND u.status=1 AND u.is_deleted=0 "
                + "AND t.start_time>? AND o.scheduled_start=t.start_time "
                + "AND NOT EXISTS (SELECT 1 FROM Test_Notifications n WITH (UPDLOCK,HOLDLOCK) WHERE n.outbox_id=o.id)", now);
        execute("UPDATE o SET delivered_at=? FROM Test_Reminder_Outbox o "
                + "WHERE o.delivered_at IS NULL AND EXISTS (SELECT 1 FROM Test_Notifications n WHERE n.outbox_id=o.id)", now);
    }
}
