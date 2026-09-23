
import dal.DBContext;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.time.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.*;
import model.*;
import service.*;
import utils.TestView;

/**
 * Chạy trực tiếp bằng Java; tạo database riêng, không thêm fixture vào
 * HRM_Project_DB.
 */
public class TestModuleIntegrationTest {

    private static final Instant NOW = Instant.parse("2030-05-10T03:00:00Z");
    private static String database;
    private static int assertions;

    @FunctionalInterface
    interface Action {

        void run() throws Exception;
    }

    /**
     * Kết nối chỉ trỏ vào database ngẫu nhiên được tạo bởi chính lần kiểm thử
     * này.
     */
    private static Connection connection() throws SQLException {
        Connection conn = DBContext.getInstance().getConnection();
        try {
            conn.setCatalog(database);
            return conn;
        } catch (SQLException e) {
            conn.close();
            throw e;
        }
    }

    /**
     * Service dùng đồng hồ cố định để kiểm tra chính xác ranh giới giờ nộp.
     */
    private static TestService service(Instant now) {
        return new TestService(TestModuleIntegrationTest::connection, Clock.fixed(now, ZoneOffset.UTC));
    }

    private static void sql(String sql) throws SQLException {
        try (Connection conn = connection(); Statement st = conn.createStatement()) {
            st.execute(sql);
        }
    }

    private static int count(String sql) throws SQLException {
        try (Connection conn = connection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private static void check(boolean condition, String label) {
        if (!condition) {
            throw new AssertionError(label);
        }
        assertions++;
    }

    private static void rejects(int status, Action action) throws Exception {
        try {
            action.run();
            throw new AssertionError("Expected HTTP " + status);
        } catch (TestException e) {
            check(e.status() == status, "Expected " + status + ", received " + e.status() + ": " + e.getMessage());
        }
    }

    private static int assignment(int template, int user) throws SQLException {
        return count("SELECT id FROM Test_Assignments WHERE test_template_id=" + template + " AND assignee_id=" + user);
    }

    /**
     * Bảng nền tối thiểu, tên cột/role tương thích với schema HRM thật.
     */
    private static void fixture() throws SQLException {
        sql("CREATE TABLE Roles(role_id INT PRIMARY KEY,role_name VARCHAR(50)); "
                + "CREATE TABLE Departments(department_id INT PRIMARY KEY,manager_id INT,status BIT,is_deleted BIT); "
                + "CREATE TABLE Users(user_id INT PRIMARY KEY,full_name NVARCHAR(100),role_id INT REFERENCES Roles(role_id),"
                + "department_id INT REFERENCES Departments(department_id),status BIT,is_deleted BIT); "
                + "INSERT INTO Roles VALUES (1,'ADMIN'),(2,'HR'),(3,'MANAGER'),(4,'EMPLOYEE'); "
                + "INSERT INTO Departments VALUES (1,3,1,0),(2,5,1,0); "
                + "INSERT INTO Users VALUES (1,N'Admin',1,NULL,1,0),(2,N'HR',2,NULL,1,0),"
                + "(3,N'Leader A',3,1,1,0),(4,N'Member A',4,1,1,0),(5,N'Leader B',3,2,1,0),"
                + "(6,N'Member B',4,2,1,0),(7,N'Member A2',4,1,1,0),(8,N'No department',4,NULL,1,0);");
    }

    /**
     * Luồng nghiệp vụ, IDOR, state machine, file, transaction và notification
     * retry trên SQL Server.
     */
    private static void runTests() throws Exception {
        TestService s = service(NOW);
        rejects(403, () -> s.createTemplate(4, "x", "y", "department", NOW, NOW.plusSeconds(3600)));
        rejects(403, () -> s.createTemplate(3, "x", "y", "culture", NOW, NOW.plusSeconds(3600)));
        int adminProfessional = s.createTemplate(1, "Đánh giá chuyên môn toàn công ty", "Nội dung", "department", NOW, NOW.plusSeconds(3600));
        check(s.getTemplate(1, adminProfessional).id() == adminProfessional, "ADMIN can manage professional evaluations");
        rejects(400, () -> s.createTemplate(3, "x", "y", "department", NOW, NOW));
        rejects(400, () -> s.createTemplate(3, " ", "y", "department", NOW, NOW.plusSeconds(10)));
        int dept = s.createTemplate(3, "Đề chuyên môn <script>", "Mô tả tự do", "department", NOW.minusSeconds(60), NOW.plusSeconds(3600));
        int culture = s.createTemplate(2, "Văn hóa", "Bài viết văn hóa", "culture", NOW, NOW.plusSeconds(3600));
        int future = s.createTemplate(3, "Bài sắp tới", "Nội dung", "department", NOW.plusSeconds(3600), NOW.plusSeconds(7200));
        rejects(404, () -> s.getTemplate(4, dept));
        rejects(404, () -> s.getTemplate(6, culture));
        check(s.listTemplates(4, "all", 1, 20).isEmpty(), "draft must be hidden");
        check(s.getCalendar(3, NOW.minusSeconds(600), NOW.plusSeconds(8000), 1, 20).isEmpty(), "calendar excludes drafts even for creator");
        s.publishTemplate(3, dept);
        s.publishTemplate(2, culture);
        s.publishTemplate(3, future);
        check(s.getTemplate(6, culture).id() == culture, "culture visible company wide");
        check(s.getTemplate(6, dept).id() == dept, "professional evaluation visible company wide");
        check(s.getTemplate(1, dept).id() == dept, "ADMIN can manage professional evaluation");
        check(s.listTemplates(8, "all", 1, 20).size() == 3, "users without department see company evaluations");
        check(s.listTemplates(4, "upcoming", 1, 20).size() == 1, "upcoming scope");
        check(s.getCalendar(4, NOW.minusSeconds(30), NOW.plusSeconds(30), 1, 20).size() == 2, "calendar overlap not just start range");
        rejects(400, () -> s.getCalendar(4, NOW, NOW.plus(Duration.ofDays(367)), 1, 20));
        rejects(400, () -> s.listTemplates(4, "all", 0, 20));
        rejects(403, () -> s.assignTest(4, dept, List.of(7)));
        s.assignTest(3, dept, List.of(6));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 1, "professional test can target another department");
        rejects(403, () -> s.assignTest(3, dept, List.of(1)));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 1, "ADMIN is excluded from recipients");
        s.assignTest(3, dept, List.of(4, 4, 7));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 3, "deduplicate request IDs");
        rejects(409, () -> s.assignTest(3, dept, List.of(3, 4)));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 3, "duplicate assignment rolls back earlier insert");
        int a = assignment(dept, 4), other = assignment(dept, 7);
        rejects(404, () -> s.getAssignment(7, a));
        rejects(404, () -> s.download(6, a));
        rejects(404, () -> s.submitAssignment(7, a, "stolen", null, null));
        rejects(409, () -> s.evaluateAssignment(3, a, new BigDecimal("5"), "not submitted"));
        rejects(400, () -> s.submitAssignment(4, a, "", null, null));
        rejects(400, () -> s.submitAssignment(4, a, "", "huge", new byte[TestService.MAX_FILE_BYTES + 1]));
        s.startAssignment(4, a);
        s.startAssignment(4, a);
        check(s.getAssignment(4, a).status().equals("in_progress"), "idempotent start");
        rejects(409, () -> service(NOW.plusSeconds(3600)).submitAssignment(4, a, "late", null, null));
        byte[] file = "file bytes <script>".getBytes(StandardCharsets.UTF_8);
        s.submitAssignment(4, a, "Nội dung <script>", "bài làm.txt", file);
        check(Arrays.equals(s.download(4, a).bytes(), file), "owner can download bytes");
        check(Arrays.equals(s.download(3, a).bytes(), file), "manager can download bytes");
        rejects(409, () -> s.submitAssignment(4, a, "again", null, null));
        rejects(400, () -> s.evaluateAssignment(3, a, new BigDecimal("10.01"), "invalid score"));
        rejects(403, () -> s.evaluateAssignment(4, a, new BigDecimal("9"), "self grading"));
        s.submitAssignment(7, other, "text only", null, null);
        s.closeTemplate(3, dept);
        s.evaluateAssignment(3, a, new BigDecimal("8.75"), "Đạt yêu cầu");
        check(s.getAssignment(4, a).evaluation().score().compareTo(new BigDecimal("8.75")) == 0, "grade after closure");
        rejects(409, () -> s.evaluateAssignment(3, a, new BigDecimal("9"), "duplicate"));
        rejects(403, () -> s.assignTest(3, dept, List.of(3)));

        sql("CREATE TRIGGER test_fail_grade ON Test_Assignments AFTER UPDATE AS BEGIN IF EXISTS(SELECT 1 FROM inserted WHERE status='evaluated') THROW 51000,'injected failure',1; END");
        try {
            s.evaluateAssignment(3, other, new BigDecimal("7"), "rollback");
            throw new AssertionError("expected SQL failure");
        } catch (SQLException expected) {
            assertions++;
        }
        sql("DROP TRIGGER test_fail_grade");
        check(count("SELECT COUNT(*) FROM Test_Evaluations WHERE test_assignment_id=" + other) == 0, "evaluation insert rolled back with assignment failure");
        check(s.getAssignment(7, other).status().equals("submitted"), "state preserved on failure");

        ExecutorService pool = Executors.newFixedThreadPool(2);
        CountDownLatch gate = new CountDownLatch(1);
        Callable<Integer> grade = () -> {
            gate.await();
            try {
                s.evaluateAssignment(3, other, new BigDecimal("7"), "concurrent");
                return 200;
            } catch (TestException e) {
                return e.status();
            }
        };
        try {
            Future<Integer> first = pool.submit(grade), second = pool.submit(grade);
            gate.countDown();
            List<Integer> statuses = new ArrayList<>(List.of(first.get(30, TimeUnit.SECONDS), second.get(30, TimeUnit.SECONDS)));
            Collections.sort(statuses);
            check(statuses.equals(List.of(200, 409)), "concurrent grading exactly one winner: " + statuses);
            check(count("SELECT COUNT(*) FROM Test_Evaluations WHERE test_assignment_id=" + other) == 1, "one evaluation persisted");
        } finally {
            pool.shutdownNow();
        }

        s.assignTest(3, future, List.of(4, 7));
        int pending = assignment(future, 4);
        rejects(409, () -> s.startAssignment(4, pending));
        rejects(409, () -> s.submitAssignment(4, pending, "early", null, null));
        sql("CREATE TRIGGER test_fail_notify ON Test_Notifications AFTER INSERT AS BEGIN THROW 51001,'injected delivery failure',1; END");
        try {
            s.sendUpcomingReminders(NOW);
            throw new AssertionError("expected notification failure");
        } catch (SQLException expected) {
            assertions++;
        }
        check(count("SELECT COUNT(*) FROM Test_Reminder_Outbox") == 2, "outbox committed before delivery failure");
        check(count("SELECT COUNT(*) FROM Test_Notifications") == 0, "failed delivery rolled back");
        sql("DROP TRIGGER test_fail_notify");
        s.sendUpcomingReminders(NOW);
        s.sendUpcomingReminders(NOW);
        check(count("SELECT COUNT(*) FROM Test_Notifications") == 2, "retry produces no duplicates");
        check(s.getNotifications(4).size() == 1, "private notifications");
        int notice = s.getNotifications(4).get(0).id();
        rejects(409, () -> s.readNotification(7, notice));
        s.readNotification(4, notice);
        check(s.getNotifications(4).get(0).read(), "mark read");
        int expiring = s.createTemplate(2, "Đợt sắp hết hạn", "Thu hồi bài chưa làm",
                "culture", NOW.minusSeconds(60), NOW.plusSeconds(10));
        s.publishTemplate(2, expiring);
        s.assignTest(2, expiring, List.of(8));
        int expiringAssignment = assignment(expiring, 8);
        s.sendUpcomingReminders(NOW.plusSeconds(20));
        check(count("SELECT COUNT(*) FROM Test_Templates WHERE id=" + expiring + " AND status='closed'") == 1,
                "expired template automatically closes");
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE id=" + expiringAssignment + " AND is_deleted=1") == 1,
                "expired pending assignment automatically revoked");
        check(s.getMyAssignments(8, 1, 20).isEmpty(), "revoked expired assignment hidden from candidate");
        sql("UPDATE Users SET department_id=2 WHERE user_id=4");
        check(s.getMyAssignments(4, 1, 20).size() == 2, "transfer keeps company-wide assignments");
        check(s.getNotifications(4).size() == 1, "transfer keeps company-wide reminder visibility");
        check(Arrays.equals(s.download(4, a).bytes(), file), "transfer keeps access to own submission");
        check(s.getAssignment(3, a).id() == a, "manager keeps review access after employee transfer");
        sql("UPDATE Users SET department_id=2 WHERE user_id=3");
        check(s.getTemplate(3, dept).id() == dept, "published professional evaluation stays visible after manager transfer");
        rejects(403, () -> s.createTemplate(3, "x", "y", "department", NOW, NOW.plusSeconds(100)));
        sql("UPDATE Users SET department_id=1 WHERE user_id=3");
        s.archiveAssignment(3, assignment(future, 7));
        check(s.getMyAssignments(7, 1, 20).size() == 1, "revoked assignment hidden");
        s.archiveTemplate(3, dept);
        rejects(404, () -> s.getTemplate(7, dept));
        check(count("SELECT COUNT(*) FROM Test_Evaluations") == 2, "archive preserves grades");

        s.assignTest(2, culture, List.of(6));
        int ca = assignment(culture, 6);
        rejects(404, () -> s.getAssignment(4, ca));
        rejects(403, () -> s.assignTest(5, culture, List.of(6)));
        s.submitAssignment(6, ca, "culture response", null, null);
        s.evaluateAssignment(1, ca, new BigDecimal("10"), "ADMIN may grade culture");
        check(s.getAssignment(6, ca).evaluation() != null, "culture full flow");
        sql("UPDATE Users SET status=0 WHERE user_id=6");
        rejects(403, () -> s.getMyAssignments(6, 1, 20));
        rejects(403, () -> s.getMyAssignments(1, 1, 20));
        check(TestView.h("<script>\"'&").equals("&lt;script&gt;&quot;&#39;&amp;"), "HTML escape");
        check(count("SELECT COUNT(*) FROM Test_Audit WHERE action='submit'") == 3, "submission audit committed");
    }

    /**
     * Kiểm tra kho, khóa nội dung, chọn đúng phạm vi và không lộ/nhận đáp án
     * đúng từ client.
     */
    private static void runQuestionTests() throws Exception {
        sql("UPDATE Users SET department_id=1 WHERE user_id=4; UPDATE Users SET status=1 WHERE user_id=6;");
        TestService s = service(NOW);
        rejects(403, () -> s.createContent(7, "quiz", "x", "y"));
        rejects(400, () -> s.createContent(3, "invalid", "x", "y"));
        int disposable = s.createContent(3, "quiz", "Bộ đề xóa", "Không còn sử dụng");
        s.deleteContents(3, List.of(disposable));
        rejects(404, () -> s.getContent(3, disposable));
        rejects(400, () -> s.deleteContents(3, List.of()));
        int quiz = s.createContent(3, "quiz", "Bộ kiến thức", "Chọn một đáp án"), essay = s.createContent(3, "question", "Câu tự luận", "Mô tả cách xử lý tình huống");
        int culture = s.createContent(2, "question", "Văn hóa", "Giá trị cốt lõi"), draft = s.createContent(3, "question", "Nháp", "Chưa sẵn sàng");
        rejects(400, () -> s.publishContent(3, quiz));
        rejects(400, () -> s.addQuestion(3, quiz, "Q", List.of("A", "A", "C", "D"), 0));
        rejects(400, () -> s.addQuestion(3, quiz, "Q", List.of("A", "a", "C", "D"), 0));
        rejects(400, () -> s.addQuestion(3, quiz, "Q", List.of("A", "B", "C", "D"), 4));
        for (int i = 0; i < 3; i++) {
            s.addQuestion(3, quiz, "Câu " + i, List.of("A", "B", "C", "D"), i);
        }
        s.addQuestion(3, quiz, "Câu xóa", List.of("A", "B", "C", "D"), 0);
        int edited = s.getContent(3, quiz).questions().get(0).id();
        s.updateQuestion(3, quiz, edited, "Câu đã sửa", List.of("A1", "B1", "C1", "D1"), 0);
        check(s.getContent(3, quiz).questions().get(0).prompt().equals("Câu đã sửa"), "edit draft question");
        int removed = s.getContent(3, quiz).questions().get(3).id();
        s.removeQuestion(3, quiz, removed);
        check(s.getContent(3, quiz).questions().size() == 3, "remove only draft question");
        s.publishContent(3, quiz);
        s.publishContent(3, essay);
        s.publishContent(2, culture);
        rejects(409, () -> s.addQuestion(3, quiz, "Q", List.of("A", "B", "C", "D"), 0));
        rejects(409, () -> s.updateQuestion(3, quiz, edited, "Q", List.of("A", "B", "C", "D"), 0));
        rejects(409, () -> s.removeQuestion(3, quiz, s.getContent(3, quiz).questions().get(0).id()));
        rejects(403, () -> s.listContent(4, 1, 20));
        rejects(404, () -> s.getContent(4, quiz));
        rejects(404, () -> s.getContent(5, quiz));
        int t = s.createTemplate(3, "Đợt quiz", "Hướng dẫn", "department", NOW, NOW.plusSeconds(3600));
        s.publishTemplate(3, t);
        check(s.getContentChoices(3, t).size() == 2, "only ready matching content shown");
        rejects(409, () -> s.assignTest(3, t, List.of(7), draft));
        rejects(404, () -> s.assignTest(3, t, List.of(7), culture));
        s.assignTest(3, t, List.of(7), quiz);
        s.assignTest(3, t, List.of(4), essay);
        int a = assignment(t, 7), e = assignment(t, 4);
        check(s.getAssignment(7, a).contentId() == quiz, "assignment keeps chosen quiz");
        TestService.ContentDetail student = s.getAssignmentContent(7, a);
        check(student.questions().stream().allMatch(q -> q.correctOption() == null), "student DTO has no answer keys");
        check(s.getAssignmentContent(3, a).questions().stream().allMatch(q -> q.correctOption() != null), "manager can inspect keys");
        rejects(404, () -> s.getAssignmentContent(4, a));
        rejects(400, () -> s.submitAssignment(7, a, "bypass", null, null));
        Map<Integer, Integer> answers = new LinkedHashMap<>();
        for (TestQuestion q : student.questions()) {
            answers.put(q.id(), 0);
        }
        Map<Integer, Integer> missing = new LinkedHashMap<>(answers);
        missing.remove(student.questions().get(2).id());
        rejects(400, () -> s.submitQuiz(7, a, missing));
        Map<Integer, Integer> foreign = new LinkedHashMap<>(missing);
        foreign.put(removed, 0);
        rejects(400, () -> s.submitQuiz(7, a, foreign));
        check(count("SELECT COUNT(*) FROM Test_Answers WHERE assignment_id=" + a) == 0, "invalid question rolls back partial answers");
        answers.put(student.questions().get(1).id(), 1); // 2/3 đúng.
        s.submitQuiz(7, a, answers);
        check(s.getAssignment(7, a).quizScore().compareTo(new BigDecimal("6.67")) == 0, "server calculates rounded score");
        check(s.getAssignment(7, a).status().equals("submitted"), "quiz waits for manager confirmation");
        check(s.getAssignmentContent(7, a).answers().equals(answers), "saved choices roundtrip");
        rejects(409, () -> s.submitQuiz(7, a, answers));
        s.submitAssignment(4, e, "Bài tự luận", null, null);
        check(s.getAssignmentContent(4, e).content().prompt().contains("tình huống"), "essay keeps selected question");
        rejects(409, () -> s.submitQuiz(4, e, answers));
        s.evaluateAssignment(3, a, new BigDecimal("6.67"), "Xác nhận kết quả");
        check(s.getAssignment(7, a).evaluation() != null, "manager confirms quiz grade");
        int later = s.createTemplate(3, "Lịch tới", "x", "department", NOW.plusSeconds(100), NOW.plusSeconds(200));
        s.publishTemplate(3, later);
        s.assignTest(3, later, List.of(7), quiz);
        int pending = assignment(later, 7);
        check(s.getAssignmentContent(7, pending) == null, "questions hidden until start");
        rejects(409, () -> s.submitQuiz(7, pending, answers));
        check(s.getAssignmentContent(3, pending) != null, "manager can review before start");
    }

    /**
     * Tạo/drop duy nhất database tên ngẫu nhiên thuộc lần chạy này; không chạy
     * script reset HRM.
     */
    public static void main(String[] args) throws Exception {
        database = "HRM_TestModule_it_" + UUID.randomUUID().toString().replace("-", "");
        boolean created = false;
        try (Connection admin = DBContext.getInstance().getConnection(); Statement st = admin.createStatement()) {
            admin.setCatalog("master");
            try {
                st.execute("CREATE DATABASE [" + database + "]");
                created = true;
                fixture();
                String schema = Files.readString(Path.of("database/schema/create_tables_sqlserver.sql"), StandardCharsets.UTF_8);
                int moduleStart = schema.indexOf("-- BEGIN TEST MODULE");
                if (moduleStart < 0) throw new IllegalStateException("Missing test module schema section");
                String migration = schema.substring(moduleStart);
                sql(migration);
                sql(migration);
                runTests();
                runQuestionTests();
                System.out.println("PASS: " + assertions + " assertions on isolated SQL Server database.");
            } finally {
                if (created && database.matches("HRM_TestModule_it_[a-f0-9]{32}")) {
                    st.execute("ALTER DATABASE [" + database + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE");
                    st.execute("DROP DATABASE [" + database + "]");
                }
            }
        }
    }
}
