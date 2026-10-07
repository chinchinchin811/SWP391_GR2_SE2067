
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

    private static int insertId(String sql, Object... values) throws SQLException {
        try (Connection conn = connection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < values.length; i++) ps.setObject(i + 1, values[i]);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new SQLException("Insert did not return an id");
                return rs.getInt(1);
            }
        }
    }

    private static int content(String title, String type, Integer department, int creator, String status) throws SQLException {
        return insertId("INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by,status) "
                + "OUTPUT INSERTED.id VALUES (?,?,?,?,?,?,?)", title, "Hướng dẫn", "quiz", type, department, creator, status);
    }

    private static int question(int contentId, String prompt, String type) throws SQLException {
        return insertId("INSERT INTO Test_Questions(content_id,prompt,question_type) OUTPUT INSERTED.id VALUES (?,?,?)",
                contentId, prompt, type);
    }

    private static int option(int questionId, String text, boolean correct, int order) throws SQLException {
        return insertId("INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                + "OUTPUT INSERTED.id VALUES (?,?,?,?)", questionId, text, correct, order);
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
                + "CREATE TABLE Departments(department_id INT PRIMARY KEY,department_name NVARCHAR(100),manager_id INT,status BIT,is_deleted BIT); "
                + "CREATE TABLE Users(user_id INT PRIMARY KEY,username VARCHAR(50),full_name NVARCHAR(100),role_id INT REFERENCES Roles(role_id),"
                + "department_id INT REFERENCES Departments(department_id),status BIT,is_deleted BIT); "
                + "INSERT INTO Roles VALUES (1,'ADMIN'),(2,'HR'),(3,'MANAGER'),(4,'EMPLOYEE'); "
                + "INSERT INTO Departments VALUES (1,N'Phòng Kỹ Thuật (IT)',3,1,0),(2,N'Phòng Nhân Sự (HR)',5,1,0); "
                + "INSERT INTO Users VALUES (1,'admin',N'Admin',1,NULL,1,0),(2,'hr_manager',N'HR',2,NULL,1,0),"
                + "(3,'manager_it',N'Leader A',3,1,1,0),(4,'member_a',N'Member A',4,1,1,0),(5,'manager_b',N'Leader B',3,2,1,0),"
                + "(6,'member_b',N'Member B',4,2,1,0),(7,'member_a2',N'Member A2',4,1,1,0),(8,'no_department',N'No department',4,NULL,1,0); "
                + "CREATE TABLE Test_Content(id INT IDENTITY PRIMARY KEY,title NVARCHAR(200) NOT NULL,prompt NVARCHAR(MAX) NOT NULL,"
                + "kind VARCHAR(20) NOT NULL,type VARCHAR(20) NOT NULL,department_id INT NULL REFERENCES Departments(department_id),"
                + "created_by INT NOT NULL REFERENCES Users(user_id),status VARCHAR(20) NOT NULL DEFAULT 'draft',is_deleted BIT NOT NULL DEFAULT 0,"
                + "created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()); "
                + "CREATE TABLE Test_Questions(id INT IDENTITY PRIMARY KEY,content_id INT NOT NULL REFERENCES Test_Content(id),"
                + "prompt NVARCHAR(4000) NOT NULL,option_a NVARCHAR(1000) NOT NULL,option_b NVARCHAR(1000) NOT NULL,"
                + "option_c NVARCHAR(1000) NOT NULL,option_d NVARCHAR(1000) NOT NULL,correct_option INT NOT NULL); "
                + "INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by,status,is_deleted) "
                + "VALUES(N'Legacy',N'Legacy','quiz','department',1,3,'ready',1); "
                + "INSERT INTO Test_Questions(content_id,prompt,option_a,option_b,option_c,option_d,correct_option) "
                + "VALUES(1,N'Câu hỏi cũ',N'A',N'B',N'C',N'D',2);");
    }

    /**
     * Luồng nghiệp vụ, IDOR, state machine, file và transaction trên SQL Server.
     */
    private static void runTests() throws Exception {
        TestService s = service(NOW);
        rejects(403, () -> s.createTemplate(4, "x", "y", "department", NOW, NOW.plusSeconds(3600)));
        rejects(403, () -> s.createTemplate(3, "x", "y", "culture", NOW, NOW.plusSeconds(3600)));
        rejects(403, () -> s.createTemplate(1, "Đánh giá chuyên môn toàn công ty", "Nội dung", "department", NOW, NOW.plusSeconds(3600)));
        rejects(400, () -> s.createTemplate(3, "x", "y", "department", NOW, NOW));
        rejects(400, () -> s.createTemplate(3, "x", "y", "department", NOW.plusSeconds(10), NOW.plusSeconds(5)));
        rejects(400, () -> s.createTemplate(3, "x", "y", "department", NOW.minusSeconds(1), NOW.plusSeconds(10)));
        rejects(400, () -> s.createTemplate(3, " ", "y", "department", NOW, NOW.plusSeconds(10)));
        int dept = s.createTemplate(3, "Đề chuyên môn <script>", "Mô tả tự do", "department", NOW, NOW.plusSeconds(3600));
        rejects(403, () -> s.createTemplate(2, "x", "y", "culture", NOW, NOW.plusSeconds(3600)));
        int culture = s.createTemplate(1, "Văn hóa", "Bài viết văn hóa", "culture", NOW, NOW.plusSeconds(3600));
        int future = s.createTemplate(3, "Bài sắp tới", "Nội dung", "department", NOW.plusSeconds(3600), NOW.plusSeconds(7200));
        rejects(404, () -> s.getTemplate(4, dept));
        rejects(404, () -> s.getTemplate(6, culture));
        check(s.listTemplates(4, "all", 1, 20).isEmpty(), "draft must be hidden");
        check(s.getCalendar(3, NOW.minusSeconds(600), NOW.plusSeconds(8000), 1, 20).isEmpty(), "calendar excludes drafts even for creator");
        s.publishTemplate(3, dept);
        s.publishTemplate(1, culture);
        s.publishTemplate(3, future);
        check(s.getTemplate(6, culture).id() == culture, "culture visible company wide");
        check(s.getTemplate(6, dept).id() == dept, "professional evaluation visible company wide");
        rejects(404, () -> s.getTemplate(1, dept));
        check(s.getTemplate(1, culture).id() == culture, "ADMIN can view culture evaluation");
        check(s.listTemplates(1, "all", 1, 20).size() == 1, "ADMIN only sees culture evaluations");
        check(s.listTemplates(8, "all", 1, 20).size() == 3, "users without department see company evaluations");
        check(s.listTemplates(4, "upcoming", 1, 20).size() == 1, "upcoming scope");
        check(s.getCalendar(4, NOW.minusSeconds(30), NOW.plusSeconds(30), 1, 20).size() == 2, "calendar overlap not just start range");
        rejects(400, () -> s.getCalendar(4, NOW, NOW.plus(Duration.ofDays(367)), 1, 20));
        rejects(400, () -> s.listTemplates(4, "all", 0, 20));
        rejects(403, () -> s.assignTest(4, dept, List.of(7)));
        check(s.getCandidates(3, dept).stream().map(TestActor::id).collect(java.util.stream.Collectors.toSet()).equals(Set.of(4, 7)),
                "MANAGER only sees employees in managed department");
        rejects(403, () -> s.assignTest(3, dept, List.of(6)));
        rejects(403, () -> s.assignTest(3, dept, List.of(5)));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 0, "cross-department and superior assignments rejected");
        rejects(403, () -> s.assignTest(3, dept, List.of(1)));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 0, "ADMIN is excluded from recipients");
        s.assignTest(3, dept, List.of(4, 4, 7));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 2, "deduplicate request IDs");
        rejects(403, () -> s.assignTest(3, dept, List.of(3, 4)));
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE test_template_id=" + dept) == 2, "invalid superior assignment rolls back earlier insert");
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
        rejects(403, () -> s.revokeAssignment(2, pending));
        s.revokeAssignment(3, pending);
        check(s.getMyAssignments(4, 1, 20).size() == 1, "manager can revoke assignment they created");
        int expiring = s.createTemplate(1, "Đợt sắp hết hạn", "Thu hồi bài chưa làm",
                "culture", NOW, NOW.plusSeconds(10));
        s.publishTemplate(1, expiring);
        s.assignTest(1, expiring, List.of(8));
        int expiringAssignment = assignment(expiring, 8);
        s.closeExpiredTests(NOW.plusSeconds(20));
        check(count("SELECT COUNT(*) FROM Test_Templates WHERE id=" + expiring + " AND status='closed'") == 1,
                "expired template automatically closes");
        check(count("SELECT COUNT(*) FROM Test_Assignments WHERE id=" + expiringAssignment + " AND status='pending' AND is_deleted=0") == 1,
                "expired pending assignment remains available as not done");
        check(s.getMyAssignments(8, 1, 20).size() == 1, "expired assignment remains visible to candidate");
        sql("UPDATE Users SET department_id=2 WHERE user_id=4");
        check(s.getMyAssignments(4, 1, 20).size() == 1, "transfer keeps existing submitted assignment");
        check(Arrays.equals(s.download(4, a).bytes(), file), "transfer keeps access to own submission");
        check(s.getAssignment(3, a).id() == a, "manager keeps review access after employee transfer");
        sql("UPDATE Users SET department_id=2 WHERE user_id=3");
        check(s.getTemplate(3, dept).id() == dept, "published professional evaluation stays visible after manager transfer");
        rejects(403, () -> s.createTemplate(3, "x", "y", "department", NOW, NOW.plusSeconds(100)));
        sql("UPDATE Users SET department_id=1 WHERE user_id=3");
        s.revokeAssignment(3, assignment(future, 7));
        check(s.getMyAssignments(7, 1, 20).size() == 1, "revoked assignment hidden");
        check(s.getTemplate(7, dept).id() == dept, "closed template remains available without archive feature");
        check(count("SELECT COUNT(*) FROM Test_Evaluations") == 2, "closing template preserves grades");

        s.assignTest(1, culture, List.of(6));
        int ca = assignment(culture, 6);
        rejects(404, () -> s.getAssignment(4, ca));
        rejects(403, () -> s.assignTest(5, culture, List.of(6)));
        s.submitAssignment(6, ca, "culture response", null, null);
        s.evaluateAssignment(1, ca, new BigDecimal("10"), "ADMIN may grade culture");
        check(s.getAssignment(6, ca).evaluation() != null, "culture full flow");
        s.assignTest(1, culture, List.of(2));
        int hrOwn = assignment(culture, 2);
        s.submitAssignment(2, hrOwn, "HR self response", null, null);
        rejects(403, () -> s.evaluateAssignment(2, hrOwn, new BigDecimal("9"), "self grade forbidden"));
        s.evaluateAssignment(1, hrOwn, new BigDecimal("9"), "ADMIN grades HR");
        check(s.getAssignment(2, hrOwn).evaluation().evaluatorId() == 1, "only higher role evaluates HR");
        sql("UPDATE Users SET status=0 WHERE user_id=6");
        rejects(403, () -> s.getMyAssignments(6, 1, 20));
        rejects(403, () -> s.getMyAssignments(1, 1, 20));
        check(TestView.h("<script>\"'&").equals("&lt;script&gt;&quot;&#39;&amp;"), "HTML escape");
    }

    /**
     * Kiểm tra kho đề chỉ đọc từ database, số lựa chọn linh hoạt, câu đúng/sai,
     * câu nhiều đáp án và việc không làm lộ đáp án cho người thi.
     */
    private static void runQuestionTests() throws Exception {
        sql("UPDATE Users SET department_id=1 WHERE user_id=4; UPDATE Users SET status=1 WHERE user_id=6;");
        TestService s = service(NOW);

        int quiz = content("Đề chuyên môn", "department", 1, 3, "ready");
        int draft = content("Đề nháp", "department", 1, 3, "draft");
        int culture = content("Đề văn hóa", "culture", null, 2, "ready");

        int trueFalse = question(quiz, "PreparedStatement giúp chống SQL Injection.", "true_false");
        int tfTrue = option(trueFalse, "Đúng", true, 1);
        option(trueFalse, "Sai", false, 2);

        int multiple = question(quiz, "Chọn đúng ba thực hành tốt.", "multiple");
        int multiA = option(multiple, "PreparedStatement", true, 1);
        int multiB = option(multiple, "Try-with-resources", true, 2);
        int multiC = option(multiple, "Tách service", true, 3);
        option(multiple, "Hard-code password", false, 4);
        int multiWrong = option(multiple, "Nuốt exception", false, 5);

        int sixChoices = question(quiz, "HTTP nào là Created?", "single");
        option(sixChoices, "200", false, 1);
        int created = option(sixChoices, "201", true, 2);
        option(sixChoices, "204", false, 3);
        option(sixChoices, "400", false, 4);
        option(sixChoices, "404", false, 5);
        option(sixChoices, "500", false, 6);

        check(s.getContent(3, quiz).questions().get(2).options().size() == 6, "question supports more than four options");
        check(s.getContent(3, quiz).questions().get(1).correctOptionIds().size() == 3, "question supports three correct options");
        rejects(403, () -> s.listContent(4, 1, 20));
        rejects(404, () -> s.getContent(5, quiz));

        int t = s.createTemplate(3, "Đợt quiz", "Hướng dẫn", "department", NOW, NOW.plusSeconds(3600), quiz);
        s.publishTemplate(3, t);
        check(s.getContentChoices(3, t).size() == 1, "only ready professional content shown");
        rejects(409, () -> s.assignTest(3, t, List.of(7), draft));
        rejects(404, () -> s.assignTest(3, t, List.of(7), culture));
        s.assignTest(3, t, List.of(7), quiz);
        int a = assignment(t, 7);
        TestService.ContentDetail student = s.getAssignmentContent(7, a);
        check(student.questions().stream().flatMap(q -> q.options().stream()).allMatch(o -> o.correct() == null),
                "student DTO has no answer keys");
        check(s.getAssignmentContent(3, a).questions().stream().allMatch(q -> !q.correctOptionIds().isEmpty()),
                "manager can inspect answer keys");
        rejects(403, () -> s.assignTest(3, t, List.of(3), quiz));
        int managerOwnAssignment = insertId("INSERT INTO Test_Assignments(test_template_id,assignee_id,assigned_by,content_id) "
                + "OUTPUT INSERTED.id VALUES (" + t + ",3,3," + quiz + ")");
        check(s.getAssignmentContent(3, managerOwnAssignment).questions().stream()
                .flatMap(q -> q.options().stream()).allMatch(o -> o.correct() == null),
                "manager taking own test cannot inspect answer keys");

        Map<Integer, Set<Integer>> answers = new LinkedHashMap<>();
        answers.put(trueFalse, Set.of(tfTrue));
        answers.put(multiple, Set.of(multiA, multiB, multiWrong)); // Sai một lựa chọn.
        answers.put(sixChoices, Set.of(created));
        Map<Integer, Set<Integer>> missing = new LinkedHashMap<>(answers);
        missing.remove(sixChoices);
        rejects(400, () -> s.submitQuiz(7, a, missing));
        check(count("SELECT COUNT(*) FROM Test_Answer_Options WHERE assignment_id=" + a) == 0,
                "invalid submission rolls back all selected options");

        s.submitQuiz(7, a, answers);
        check(s.getAssignment(7, a).quizScore().compareTo(new BigDecimal("6.67")) == 0,
                "server scores exact answer sets");
        check(s.getAssignmentContent(7, a).answers().equals(answers), "multiple selections roundtrip");
        rejects(409, () -> s.submitQuiz(7, a, answers));
        s.evaluateAssignment(3, a, new BigDecimal("6.67"), "Xác nhận kết quả");
        check(s.getAssignment(7, a).evaluation() != null, "manager confirms quiz grade");
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
                Path schemaPath = Files.exists(Path.of("database/schema/create_tables_sqlserver.sql"))
                        ? Path.of("database/schema/create_tables_sqlserver.sql")
                        : Path.of("hrm-career-path/database/schema/create_tables_sqlserver.sql");
                String schema = Files.readString(schemaPath, StandardCharsets.UTF_8);
                int moduleStart = schema.indexOf("-- BEGIN TEST MODULE");
                if (moduleStart < 0) {
                    throw new IllegalStateException("Missing test module schema section");
                }
                String migration = schema.substring(moduleStart);
                sql(migration);
                sql(migration);
                check(count("SELECT COUNT(*) FROM Test_Question_Options WHERE question_id=1") == 4,
                        "legacy four-column questions migrate exactly once");
                runTests();
                runQuestionTests();
                Path seedPath = Files.exists(Path.of("database/seed_data/seed_data_sqlserver.sql"))
                        ? Path.of("database/seed_data/seed_data_sqlserver.sql")
                        : Path.of("hrm-career-path/database/seed_data/seed_data_sqlserver.sql");
                String seed = Files.readString(seedPath, StandardCharsets.UTF_8);
                int seedStart = seed.indexOf("-- 8. SEED DATA: KHO ĐỀ THI");
                int seedEnd = seed.indexOf("\nGO", seedStart);
                if (seedStart < 0 || seedEnd < 0) throw new IllegalStateException("Missing test question seed section");
                String testSeed = seed.substring(seedStart, seedEnd);
                sql(testSeed);
                sql(testSeed);
                check(count("SELECT COUNT(*) FROM Test_Content WHERE title IN (N'Đề thi Văn hóa doanh nghiệp',N'Đề thi Chuyên môn Java Backend')") == 2,
                        "question seed is idempotent");
                check(count("SELECT COUNT(*) FROM Test_Questions q JOIN Test_Content c ON c.id=q.content_id "
                        + "WHERE c.title IN (N'Đề thi Văn hóa doanh nghiệp',N'Đề thi Chuyên môn Java Backend')") == 20,
                        "question seed creates both exam directions");
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
