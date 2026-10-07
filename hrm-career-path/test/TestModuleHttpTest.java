
import dal.DBContext;
import java.net.*;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.*;
import org.apache.catalina.startup.Tomcat;

/**
 * Smoke test trên Tomcat thật ở cổng ngẫu nhiên + database riêng; không cần
 * thêm thư viện vào WAR.
 */
public class TestModuleHttpTest {

    private static URI origin;
    private static int assertions;
    private static int quizContentId;
    private static int essayContentId;
    private static int cultureContentId;
    private static int trueFalseQuestionId;
    private static int trueOptionId;
    private static int multipleQuestionId;
    private static int multipleOptionA;
    private static int multipleOptionB;
    private static int multipleOptionC;

    private static void check(boolean ok, String message) {
        if (!ok) {
            throw new AssertionError(message);
        }
        assertions++;
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static HttpResponse<String> get(HttpClient client, String path) throws Exception {
        return client.send(HttpRequest.newBuilder(origin.resolve(path)).GET().build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
    }

    private static HttpResponse<String> post(HttpClient client, String path, String... pairs) throws Exception {
        List<String> parts = new ArrayList<>();
        for (int i = 0; i < pairs.length; i += 2) {
            parts.add(encode(pairs[i]) + "=" + encode(pairs[i + 1]));
        }
        return client.send(HttpRequest.newBuilder(origin.resolve(path)).header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(String.join("&", parts))).build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
    }

    private static String csrf(String html) {
        Matcher match = Pattern.compile("name=\"csrf\" value=\"([^\"]+)\"").matcher(html);
        if (!match.find()) {
            throw new AssertionError("Missing CSRF token");
        }
        return match.group(1);
    }

    private static HttpClient login(String username) throws Exception {
        HttpClient client = HttpClient.newBuilder().cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL)).build();
        HttpResponse<String> response = post(client, "/hrm/login", "username", username, "password", "test-password");
        check(response.statusCode() == 302, "login " + username);
        return client;
    }

    private static String newId(HttpResponse<String> response) {
        check(response.statusCode() == 303, "expected successful POST, got " + response.statusCode() + ": " + response.body());
        return response.headers().firstValue("Location").orElseThrow().split("id=")[1];
    }

    private static void execute(Connection conn, String sql) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.execute(sql);
        }
    }

    private static int insertId(Connection conn, String sql, Object... values) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < values.length; i++) ps.setObject(i + 1, values[i]);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    private static String assignmentId(Connection conn, String template) throws SQLException {
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT id FROM Test_Assignments WHERE test_template_id=" + Integer.parseInt(template))) {
            rs.next();
            return rs.getString(1);
        }
    }

    /**
     * Test form/browser contract: redirects, CSRF, multipart, escape HTML,
     * download và lỗi IDOR.
     */
    private static void run(Connection conn) throws Exception {
        HttpClient anonymous = HttpClient.newHttpClient();
        check(get(anonymous, "/hrm/tests").statusCode() == 302, "unauthenticated redirect");
        HttpClient manager = login("leader"), member = login("member"), outsider = login("outsider"),
                adminClient = login("admin"), hrClient = login("hr");
        HttpResponse<String> adminForm = get(adminClient, "/hrm/tests?action=new");
        check(adminForm.statusCode() == 200 && adminForm.body().contains("value=\"culture\"")
                && !adminForm.body().contains("value=\"department\""), "ADMIN create form only shows culture type");
        String adminToken = csrf(adminForm.body());
        check(post(adminClient, "/hrm/tests", "csrf", adminToken, "action", "create", "title", "Không hợp lệ",
                "description", "Chuyên môn", "type", "department", "contentId", String.valueOf(essayContentId),
                "startDate", LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(1).toString(), "startTime", "08:00",
                "endDate", LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(1).toString(), "endTime", "09:00").statusCode() == 403,
                "ADMIN department template rejected by server");
        String adminBank = get(adminClient, "/hrm/tests?action=bank").body();
        check(adminBank.contains("Đề Văn hóa HTTP") && !adminBank.contains("Bộ đề HTTP")
                && !adminBank.contains("Đề thi Chuyên môn"), "ADMIN bank only shows culture content");
        int hrTemplate = insertId(conn, "INSERT INTO Test_Templates(title,description,type,department_id,created_by,status,start_time,end_time,default_content_id) "
                + "OUTPUT INSERTED.id VALUES (N'Bài cho HR',N'Kiểm tra quyền chấm','culture',NULL,4,'published',DATEADD(MINUTE,-1,SYSUTCDATETIME()),DATEADD(HOUR,1,SYSUTCDATETIME()),?)",
                cultureContentId);
        int hrAssignment = insertId(conn, "INSERT INTO Test_Assignments(test_template_id,assignee_id,assigned_by,content_id,status,submitted_at,submission_content) "
                + "OUTPUT INSERTED.id VALUES (?,5,4,?,'submitted',SYSUTCDATETIME(),N'Bài làm HR')", hrTemplate, cultureContentId);
        HttpResponse<String> hrOwnPage = get(hrClient, "/hrm/tests?action=assignment&id=" + hrAssignment);
        check(hrOwnPage.statusCode() == 200 && !hrOwnPage.body().contains("Đánh giá bài làm"),
                "HR self assignment does not render evaluation form");
        check(get(hrClient, "/hrm/tests?action=new").statusCode() == 403, "HR cannot open create form");
        check(get(hrClient, "/hrm/tests?action=bank").statusCode() == 403, "HR cannot browse bank");
        check(post(hrClient, "/hrm/tests", "csrf", "bad-token", "action", "evaluate", "id", String.valueOf(hrAssignment),
                "score", "9", "comment", "Tự chấm").statusCode() == 403, "HR self evaluation rejected by server");
        HttpResponse<String> form = get(manager, "/hrm/tests?action=new");
        check(form.statusCode() == 200, "render create form");
        String token = csrf(form.body());
        check(post(manager, "/hrm/tests", "action", "create").statusCode() == 403, "missing CSRF rejected");
        check(post(manager, "/hrm/tests", "csrf", "bad-token", "action", "create").statusCode() == 403, "invalid CSRF rejected");
        ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        DateTimeFormatter dateFmt = DateTimeFormatter.ISO_LOCAL_DATE;
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
        String title = "Đề tiếng Việt <script>alert(1)</script>";
        String template = newId(post(manager, "/hrm/tests", "csrf", token, "action", "create", "title", title, "description", "Yêu cầu <img src=x onerror=alert(1)>",
                "type", "department", "contentId", String.valueOf(essayContentId), "startDate", now.plusMinutes(1).format(dateFmt), "startTime", now.plusMinutes(1).format(timeFmt),
                "endDate", now.plusHours(2).format(dateFmt), "endTime", now.plusHours(2).format(timeFmt)));
        execute(conn, "UPDATE Test_Templates SET start_time=SYSUTCDATETIME() WHERE id=" + template);
        check(get(member, "/hrm/tests?action=detail&id=" + template).statusCode() == 404, "draft inaccessible to member");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "publish", "id", template).statusCode() == 303, "publish form");
        HttpResponse<String> listPage = get(manager, "/hrm/tests");
        check(listPage.statusCode() == 200 && listPage.body().contains("&lt;script&gt;"), "title HTML escaped in list");
        check(!listPage.body().contains("<script>alert(1)</script>"), "no raw script in title");
        HttpResponse<String> detail = get(manager, "/hrm/tests?action=detail&id=" + template);
        check(detail.statusCode() == 200 && !detail.body().contains("&lt;script&gt;")
                && !detail.body().contains("Yêu cầu &lt;img"), "template summary block removed from detail page");
        check(detail.body().contains("Member") && !detail.body().contains("Outsider") && !detail.body().contains("Administrator"),
                "MANAGER candidate list only contains employees in managed department");
        check(!detail.body().contains("value=\"archive\"") && !detail.body().contains("Lưu trữ đề"),
                "template archive action removed");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "archive", "id", template).statusCode() == 400,
                "removed archive endpoint rejected");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "assign", "id", template, "assigneeId", "2").statusCode() == 303, "assign form");
        String assignment = assignmentId(conn, template);
        HttpResponse<String> pendingDetail = get(manager, "/hrm/tests?action=detail&id=" + template);
        check(pendingDetail.statusCode() == 200 && pendingDetail.body().contains("Member")
                && pendingDetail.body().contains("Chưa làm")
                && pendingDetail.body().contains("Đánh giá chuyên môn")
                && pendingDetail.body().contains("Câu tình huống")
                && pendingDetail.body().contains("Bắt đầu") && pendingDetail.body().contains("Kết thúc"),
                "manager detail reports pending assignee with scope, content and schedule");
        HttpResponse<String> mine = get(member, "/hrm/tests?action=assignment&id=" + assignment);
        check(mine.statusCode() == 200 && mine.body().contains("Chưa làm")
                && mine.body().contains("Bắt đầu làm") && !mine.body().contains("multipart/form-data"),
                "pending assignment only renders start action");
        String memberToken = csrf(mine.body());
        check(post(member, "/hrm/tests", "csrf", memberToken, "action", "start", "id", assignment).statusCode() == 303,
                "start assignment");
        mine = get(member, "/hrm/tests?action=assignment&id=" + assignment);
        check(mine.body().contains("multipart/form-data") && !mine.body().contains("Bắt đầu làm")
                && !mine.body().contains("Thu hồi bài chưa bắt đầu"), "started assignment only renders submission form");
        check(get(outsider, "/hrm/tests?action=assignment&id=" + assignment).statusCode() == 404, "assignment IDOR blocked");
        check(get(member, "/hrm/WEB-INF/views/tests/index.jsp").statusCode() == 404, "JSP direct access blocked");
        String boundary = "hrm-boundary-" + UUID.randomUUID();
        StringBuilder multipart = new StringBuilder();
        String[] fields = {"csrf", memberToken, "action", "submit", "id", assignment, "content", "Nội dung <script>bad()</script>"};
        for (int i = 0; i < fields.length; i += 2) {
            multipart.append("--").append(boundary).append("\r\nContent-Disposition: form-data; name=\"")
                    .append(fields[i]).append("\"\r\n\r\n").append(fields[i + 1]).append("\r\n");
        }
        multipart.append("--").append(boundary).append("\r\nContent-Disposition: form-data; name=\"file\"; filename=\"answer.txt\"\r\n")
                .append("Content-Type: text/plain\r\n\r\nfile-content\r\n--").append(boundary).append("--\r\n");
        HttpResponse<String> submitted = member.send(HttpRequest.newBuilder(origin.resolve("/hrm/tests"))
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .POST(HttpRequest.BodyPublishers.ofString(multipart.toString(), StandardCharsets.UTF_8)).build(), HttpResponse.BodyHandlers.ofString());
        check(submitted.statusCode() == 303, "multipart submit: " + submitted.statusCode() + " " + submitted.body());
        HttpResponse<String> result = get(manager, "/hrm/tests?action=assignment&id=" + assignment);
        check(result.statusCode() == 200 && result.body().contains("&lt;script&gt;bad()&lt;/script&gt;"), "submission escaped on grading page");
        HttpResponse<String> download = get(member, "/hrm/tests?action=download&id=" + assignment);
        check(download.statusCode() == 200 && download.body().equals("file-content"), "download payload roundtrip");
        check(download.headers().firstValue("Content-Disposition").orElse("").startsWith("attachment;"), "force attachment");
        check(download.headers().firstValue("X-Content-Type-Options").orElse("").equals("nosniff"), "download nosniff");
        check(get(outsider, "/hrm/tests?action=download&id=" + assignment).statusCode() == 404, "download IDOR blocked");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "evaluate", "id", assignment, "score", "9.25", "comment", "Tốt <b>ok</b>").statusCode() == 303, "grade form");
        HttpResponse<String> graded = get(member, "/hrm/tests?action=assignment&id=" + assignment);
        check(graded.body().contains("9.25") && graded.body().contains("&lt;b&gt;ok&lt;/b&gt;"), "grade visible to owner, escaped");
        check(get(member, "/hrm/tests?action=calendar").statusCode() == 200, "calendar renders");
        check(get(member, "/hrm/tests?action=notifications").statusCode() == 404, "notifications page removed");
        check(get(member, "/hrm/tests?action=mine").statusCode() == 200, "mine renders");
        check(get(member, "/hrm/tests?id=x&action=detail").statusCode() == 400, "malformed ID returns 400");
        check(get(member, "/hrm/tests?action=calendar&from=invalid&to=invalid").statusCode() == 400, "invalid date returns 400");
        check(get(manager, "/hrm/tests?action=bank").statusCode() == 200, "bank management page renders");
        check(get(member, "/hrm/tests?action=bank").statusCode() == 403, "member cannot browse bank");
        check(get(manager, "/hrm/tests?action=bankDetail&id=" + quizContentId).statusCode() == 200, "read-only bank detail renders");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "addQuestion", "id", String.valueOf(quizContentId)).statusCode() == 400,
                "manual question endpoint removed");
        check(get(member, "/hrm/tests?action=bankDetail&id=" + quizContentId).statusCode() == 404, "member cannot read answer key page");
        String qt = newId(post(manager, "/hrm/tests", "csrf", token, "action", "create", "title", "Đợt giao trắc nghiệm", "description", "Giao bộ đề", "type", "department",
                "contentId", String.valueOf(quizContentId), "startDate", now.plusMinutes(1).format(dateFmt), "startTime", now.plusMinutes(1).format(timeFmt),
                "endDate", now.plusHours(2).format(dateFmt), "endTime", now.plusHours(2).format(timeFmt)));
        execute(conn, "UPDATE Test_Templates SET start_time=SYSUTCDATETIME() WHERE id=" + qt);
        check(post(manager, "/hrm/tests", "csrf", token, "action", "publish", "id", qt).statusCode() == 303, "publish quiz event");
        String selection = get(manager, "/hrm/tests?action=detail&id=" + qt).body();
        check(selection.contains("name=\"contentId\"") && selection.contains("Bộ đề HTTP"), "assignment selector lists database content");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "assign", "id", qt, "assigneeId", "2", "contentId", String.valueOf(quizContentId)).statusCode() == 303, "assign selected quiz");
        String qa = assignmentId(conn, qt);
        HttpResponse<String> quizPage = get(member, "/hrm/tests?action=assignment&id=" + qa);
        check(quizPage.body().contains("Bắt đầu làm") && !quizPage.body().contains("type=\"radio\""),
                "pending quiz hides questions");
        String quizToken = csrf(quizPage.body());
        check(post(member, "/hrm/tests", "csrf", quizToken, "action", "start", "id", qa).statusCode() == 303,
                "start quiz assignment");
        quizPage = get(member, "/hrm/tests?action=assignment&id=" + qa);
        check(quizPage.statusCode() == 200 && quizPage.body().contains("type=\"radio\"")
                && quizPage.body().contains("type=\"checkbox\""), "single and multiple answer controls render");
        check(!quizPage.body().contains("Đáp án đúng") && !quizPage.body().contains("correctOption"), "no correct key in student HTML");
        quizToken = csrf(quizPage.body());
        check(post(member, "/hrm/tests", "csrf", quizToken, "action", "submitQuiz", "id", qa,
                "answer_" + trueFalseQuestionId, String.valueOf(trueOptionId),
                "answer_" + trueFalseQuestionId, String.valueOf(trueOptionId)).statusCode() == 400, "duplicate option rejected");
        check(post(member, "/hrm/tests", "csrf", quizToken, "action", "submitQuiz", "id", qa,
                "answer_" + trueFalseQuestionId, String.valueOf(trueOptionId),
                "answer_" + multipleQuestionId, String.valueOf(multipleOptionA),
                "answer_" + multipleQuestionId, String.valueOf(multipleOptionB),
                "answer_" + multipleQuestionId, String.valueOf(multipleOptionC), "score", "0").statusCode() == 303,
                "submit single and multiple selections");
        String scored = get(member, "/hrm/tests?action=assignment&id=" + qa).body();
        check(scored.contains("10.00") && scored.contains("checked"), "server score ignores client and retains selected choice");
        check(!scored.contains("Đáp án đúng"), "answer key stays private after submission");
        String et = newId(post(manager, "/hrm/tests", "csrf", token, "action", "create", "title", "Đợt câu hỏi", "description", "Giao câu hỏi", "type", "department",
                "contentId", String.valueOf(essayContentId), "startDate", now.plusMinutes(1).format(dateFmt), "startTime", now.plusMinutes(1).format(timeFmt),
                "endDate", now.plusHours(2).format(dateFmt), "endTime", now.plusHours(2).format(timeFmt)));
        execute(conn, "UPDATE Test_Templates SET start_time=SYSUTCDATETIME() WHERE id=" + et);
        check(post(manager, "/hrm/tests", "csrf", token, "action", "publish", "id", et).statusCode() == 303, "publish essay event");
        check(post(manager, "/hrm/tests", "csrf", token, "action", "assign", "id", et, "assigneeId", "2", "contentId", String.valueOf(essayContentId)).statusCode() == 303, "assign selected essay question");
        String essayAssignment = assignmentId(conn, et);
        String essayPage = get(member, "/hrm/tests?action=assignment&id=" + essayAssignment).body();
        String essayToken = csrf(essayPage);
        check(post(member, "/hrm/tests", "csrf", essayToken, "action", "start", "id", essayAssignment).statusCode() == 303,
                "start essay assignment");
        essayPage = get(member, "/hrm/tests?action=assignment&id=" + essayAssignment).body();
        check(essayPage.contains("Xử lý phản hồi khách hàng như thế nào?") && essayPage.contains("multipart/form-data") && !essayPage.contains("type=\"radio\""), "essay selection displays correct prompt and submission form");
        System.out.println("PASS: " + assertions + " HTTP assertions on isolated Tomcat and SQL Server.");
    }

    /**
     * Dùng schema nền đầy đủ nhưng bỏ hẳn phần reset database và dữ liệu mẫu
     * thật.
     */
    public static void main(String[] args) throws Exception {
        String database = "HRM_TestModule_http_" + UUID.randomUUID().toString().replace("-", "");
        String originalUrl = System.getProperty("hrm.db.url");
        Tomcat tomcat = new Tomcat();
        boolean created = false;
        try (Connection admin = DBContext.getInstance().getConnection()) {
            admin.setCatalog("master");
            try {
                execute(admin, "CREATE DATABASE [" + database + "]");
                created = true;
                admin.setCatalog(database);
                String schema = Files.readString(Path.of("database/schema/create_tables_sqlserver.sql"), StandardCharsets.UTF_8);
                int moduleStart = schema.indexOf("-- BEGIN TEST MODULE");
                if (moduleStart < 0) throw new IllegalStateException("Missing test module schema section");
                String moduleSchema = schema.substring(moduleStart);
                schema = schema.substring(schema.indexOf("CREATE TABLE dbo.Roles"), moduleStart);
                for (String batch : schema.split("(?m)^GO\\s*$")) {
                    if (!batch.isBlank()) {
                        execute(admin, batch);
                    }
                }
                execute(admin, "INSERT INTO Roles(role_name) VALUES ('ADMIN'),('HR'),('MANAGER'),('EMPLOYEE'); "
                        + "INSERT INTO Departments(department_name) VALUES (N'A'),(N'B'); "
                        + "INSERT INTO Users(username,password,full_name,email,role_id,department_id) VALUES "
                        + "('leader','test-password',N'Leader', 'leader@example.invalid',3,1),"
                        + "('member','test-password',N'Member','member@example.invalid',4,1),"
                        + "('outsider','test-password',N'Outsider','outside@example.invalid',4,2),"
                        + "('admin','test-password',N'Administrator','admin@example.invalid',1,NULL),"
                        + "('hr','test-password',N'Human Resources','hr@example.invalid',2,NULL); "
                        + "UPDATE Departments SET manager_id=1 WHERE department_id=1;");
                execute(admin, moduleSchema);
                quizContentId = insertId(admin, "INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by,status) "
                        + "OUTPUT INSERTED.id VALUES (N'Bộ đề HTTP',N'Chọn đáp án đúng','quiz','department',1,1,'ready')");
                essayContentId = insertId(admin, "INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by,status) "
                        + "OUTPUT INSERTED.id VALUES (N'Câu tình huống',N'Xử lý phản hồi khách hàng như thế nào?','question','department',1,1,'ready')");
                cultureContentId = insertId(admin, "INSERT INTO Test_Content(title,prompt,kind,type,department_id,created_by,status) "
                        + "OUTPUT INSERTED.id VALUES (N'Đề Văn hóa HTTP',N'Văn hóa doanh nghiệp','question','culture',NULL,4,'ready')");
                trueFalseQuestionId = insertId(admin, "INSERT INTO Test_Questions(content_id,prompt,question_type) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Java là ngôn ngữ hướng đối tượng.','true_false')", quizContentId);
                trueOptionId = insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Đúng',1,1)", trueFalseQuestionId);
                insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Sai',0,2)", trueFalseQuestionId);
                multipleQuestionId = insertId(admin, "INSERT INTO Test_Questions(content_id,prompt,question_type) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Chọn đúng ba thực hành tốt.','multiple')", quizContentId);
                multipleOptionA = insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'PreparedStatement',1,1)", multipleQuestionId);
                multipleOptionB = insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Try-with-resources',1,2)", multipleQuestionId);
                multipleOptionC = insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Tách tầng service',1,3)", multipleQuestionId);
                insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Hard-code mật khẩu',0,4)", multipleQuestionId);
                insertId(admin, "INSERT INTO Test_Question_Options(question_id,option_text,is_correct,display_order) "
                        + "OUTPUT INSERTED.id VALUES (?,N'Nuốt exception',0,5)", multipleQuestionId);
                System.setProperty("hrm.db.url", "jdbc:sqlserver://localhost:1433;databaseName=" + database + ";encrypt=true;trustServerCertificate=true;");
                tomcat.setBaseDir(Files.createTempDirectory("hrm-test-tomcat-").toString());
                tomcat.setPort(0);
                tomcat.getConnector().setProperty("address", "127.0.0.1");
                var context = tomcat.addWebapp("/hrm", Path.of("build/web").toAbsolutePath().toString());
                context.setParentClassLoader(TestModuleHttpTest.class.getClassLoader());
                tomcat.start();
                origin = URI.create("http://127.0.0.1:" + tomcat.getConnector().getLocalPort());
                run(admin);
            } finally {
                try {
                    tomcat.stop();
                    tomcat.destroy();
                } finally {
                    if (originalUrl == null) {
                        System.clearProperty("hrm.db.url");
                    } else {
                        System.setProperty("hrm.db.url", originalUrl);
                    }
                    admin.setCatalog("master");
                    if (created && database.matches("HRM_TestModule_http_[a-f0-9]{32}")) {
                        execute(admin, "ALTER DATABASE [" + database + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE");
                        execute(admin, "DROP DATABASE [" + database + "]");
                    }
                }
            }
        }
    }
}
