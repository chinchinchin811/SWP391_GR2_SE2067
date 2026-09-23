package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.time.*;
import java.time.format.DateTimeParseException;
import java.util.*;
import model.*;
import policy.TestPolicy;
import service.*;

/** Controller mỏng: session/CSRF/input -> service -> JSP; không truy vấn DAO trực tiếp. */
@WebServlet(name = "TestServlet", urlPatterns = "/tests")
@MultipartConfig(maxFileSize = 5242880, maxRequestSize = 6291456, fileSizeThreshold = 1048576)
public class TestServlet extends HttpServlet {
    private final TestService service = new TestService();
    private final TestPolicy policy = new TestPolicy();
    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    /** Lấy duy nhất định danh từ session; role và phòng được service đọc lại từ DB. */
    private Integer authenticated(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("currentUser") instanceof User)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        res.setHeader("Cache-Control", "no-store");
        res.setHeader("X-Content-Type-Options", "nosniff");
        synchronized (session) {
            if (session.getAttribute("testCsrf") == null) session.setAttribute("testCsrf", UUID.randomUUID().toString());
        }
        return ((User) session.getAttribute("currentUser")).getUserId();
    }

    /** Giá trị action được whitelist bằng switch, không dùng làm đường dẫn JSP tùy ý. */
    private String action(HttpServletRequest req) { return Optional.ofNullable(req.getParameter("action")).orElse("list"); }

    /** Parse ID/trang dương; dữ liệu URL sai trả 400 thay vì lỗi 500. */
    private int integer(String value) {
        try {
            int id = Integer.parseInt(value);
            if (id <= 0) throw new NumberFormatException();
            return id;
        } catch (NumberFormatException e) { throw new TestException(400, "ID hoặc số trang không hợp lệ."); }
    }

    /** Ghép ngày và giờ Việt Nam thành Instant UTC để lưu trong DB. */
    private Instant inputTime(String date, String time) {
        try {
            return LocalDateTime.of(LocalDate.parse(date == null ? "" : date),
                    LocalTime.parse(time == null ? "" : time)).atZone(ZONE).toInstant();
        } catch (DateTimeParseException e) {
            throw new TestException(400, "Ngày hoặc giờ hẹn không hợp lệ.");
        }
    }

    /** Các trang đọc đều gọi service có scope, JSP nằm trong WEB-INF để không truy cập trực tiếp. */
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Integer userId = authenticated(req, res);
        if (userId == null) return;
        try {
            TestActor actor = service.currentActor(userId);
            req.setAttribute("testActor", actor);
            req.setAttribute("testPolicy", policy);
            req.setAttribute("testNow", Instant.now());
            int page = req.getParameter("page") == null ? 1 : integer(req.getParameter("page"));
            req.setAttribute("pageNumber", page);
            String action = action(req);
            req.setAttribute("testView", action);
            switch (action) {
                case "list":
                    String scope = Optional.ofNullable(req.getParameter("scope")).orElse("all");
                    req.setAttribute("scope", scope);
                    req.setAttribute("templates", service.listTemplates(userId, scope, page, 20));
                    break;
                case "new":
                    if (!actor.cultureManager() && !actor.departmentManager()) throw new TestException(403, "Bạn không có quyền tạo bài test.");
                    req.setAttribute("contentChoices", service.listContent(userId, 1, 100));
                    break;
                case "bank":
                    req.setAttribute("bankItems", service.listContent(userId,page,20));
                    break;
                case "bankDetail":
                    req.setAttribute("bankDetail", service.getContent(userId,integer(req.getParameter("id"))));
                    break;
                case "detail": {
                    int id = integer(req.getParameter("id"));
                    TestTemplate t = service.getTemplate(userId, id);
                    req.setAttribute("template", t);
                    if (policy.canManage(actor, t)) req.setAttribute("assignments", service.getTemplateAssignments(userId, id, page, 20));
                    if (policy.canAssign(actor, t, Instant.now())) {
                        req.setAttribute("candidates", service.getCandidates(userId, id));
                        req.setAttribute("contentChoices", service.getContentChoices(userId,id));
                    }
                    break;
                }
                case "mine":
                    req.setAttribute("assignments", service.getMyAssignments(userId, page, 20));
                    break;
                case "assignment": {
                    TestAssignment a = service.getAssignment(userId, integer(req.getParameter("id")));
                    req.setAttribute("assignment", a);
                    req.setAttribute("template", service.getTemplate(userId, a.templateId()));
                    req.setAttribute("assignedContent", service.getAssignmentContent(userId,a.id()));
                    break;
                }
                case "calendar": {
                    LocalDate from;
                    LocalDate to;
                    try {
                        from = req.getParameter("from") == null ? LocalDate.now(ZONE).withDayOfMonth(1) : LocalDate.parse(req.getParameter("from"));
                        to = req.getParameter("to") == null ? from.plusMonths(1) : LocalDate.parse(req.getParameter("to"));
                    } catch (DateTimeParseException e) { throw new TestException(400, "Ngày lọc lịch không hợp lệ."); }
                    req.setAttribute("from", from);
                    req.setAttribute("to", to);
                    req.setAttribute("templates", service.getCalendar(userId, from.atStartOfDay(ZONE).toInstant(), to.atStartOfDay(ZONE).toInstant(), page, 20));
                    break;
                }
                case "download": {
                    TestService.Download file = service.download(userId, integer(req.getParameter("id")));
                    res.setContentType("application/octet-stream");
                    res.setHeader("Content-Disposition", "attachment; filename=\"submission\"; filename*=UTF-8''"
                            + URLEncoder.encode(file.name(), StandardCharsets.UTF_8).replace("+", "%20"));
                    res.setContentLength(file.bytes().length);
                    res.getOutputStream().write(file.bytes());
                    return;
                }
                default: throw new TestException(404, "Trang không tồn tại.");
            }
            req.getRequestDispatcher("/WEB-INF/views/tests/index.jsp").forward(req, res);
        } catch (TestException e) { error(req, res, e.status(), e.getMessage()); }
        catch (SQLException e) {
            log("Test module read failed", e);
            error(req, res, 503, "Chưa thể tải dữ liệu bài test. Vui lòng thử lại sau hoặc kiểm tra migration database.");
        }
    }

    /** Kiểm tra CSRF trước mọi thao tác ghi; userId/createdBy không lấy từ form. */
    @Override protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer userId = authenticated(req, res);
        if (userId == null) return;
        try {
            String supplied = req.getParameter("csrf");
            String expected = (String) req.getSession().getAttribute("testCsrf");
            if (supplied == null || !MessageDigest.isEqual(expected.getBytes(StandardCharsets.UTF_8), supplied.getBytes(StandardCharsets.UTF_8)))
                throw new TestException(403, "Phiên biểu mẫu không hợp lệ. Hãy tải lại trang rồi thử lại.");
            String action = action(req);
            String next;
            if ("createContent".equals(action)) {
                int id=service.createContent(userId,req.getParameter("kind"),req.getParameter("title"),req.getParameter("prompt"));
                next="bankDetail&id="+id;
            } else if ("deleteContents".equals(action)) {
                String[] selected = req.getParameterValues("contentId");
                List<Integer> ids = new ArrayList<>();
                if (selected != null) {
                    for (String value : selected) ids.add(integer(value));
                }
                service.deleteContents(userId, ids);
                next = "bank";
            } else if ("create".equals(action)) {
                String selected = req.getParameter("contentId");
                Instant start = inputTime(req.getParameter("startDate"), req.getParameter("startTime"));
                Instant end = inputTime(req.getParameter("endDate"), req.getParameter("endTime"));
                if ("newQuiz".equals(selected)) {
                    TestService.CreatedTemplate created = service.createTemplateWithNewQuiz(userId,
                            req.getParameter("title"), req.getParameter("description"), req.getParameter("type"),
                            start, end, req.getParameter("quizTitle"), req.getParameter("quizPrompt"));
                    next = "bankDetail&id=" + created.contentId();
                } else {
                    Integer contentId = selected == null || selected.isBlank() ? null : integer(selected);
                    int id = service.createTemplate(userId, req.getParameter("title"), req.getParameter("description"),
                            req.getParameter("type"), start, end, contentId);
                    next = "detail&id=" + id;
                }
            } else {
                int id = integer(req.getParameter("id"));
                next = "detail&id=" + id;
                switch (action) {
                    case "addQuestion": {
                        int correct;
                        try { correct=Integer.parseInt(req.getParameter("correct")); }
                        catch (NumberFormatException e) { throw new TestException(400,"Đáp án đúng không hợp lệ."); }
                        service.addQuestion(userId,id,req.getParameter("prompt"),
                                Arrays.asList(req.getParameter("optionA"),req.getParameter("optionB"),req.getParameter("optionC"),req.getParameter("optionD")),correct);
                        next="bankDetail&id="+id; break;
                    }
                    case "removeQuestion": service.removeQuestion(userId,id,integer(req.getParameter("questionId"))); next="bankDetail&id="+id; break;
                    case "updateQuestion": {
                        int correct;
                        try { correct = Integer.parseInt(req.getParameter("correct")); }
                        catch (NumberFormatException e) { throw new TestException(400, "Đáp án đúng không hợp lệ."); }
                        service.updateQuestion(userId, id, integer(req.getParameter("questionId")),
                                req.getParameter("prompt"), Arrays.asList(req.getParameter("optionA"),
                                req.getParameter("optionB"), req.getParameter("optionC"), req.getParameter("optionD")), correct);
                        next = "bankDetail&id=" + id;
                        break;
                    }
                    case "publishContent": service.publishContent(userId,id); next="bankDetail&id="+id; break;
                    case "publish": service.publishTemplate(userId, id); break;
                    case "close": service.closeTemplate(userId, id); break;
                    case "archive": service.archiveTemplate(userId, id); next = "list"; break;
                    case "assign": {
                        String[] selected = req.getParameterValues("assigneeId");
                        List<Integer> ids = new ArrayList<>();
                        if (selected != null) for (String value : selected) ids.add(integer(value));
                        String selectedContent=req.getParameter("contentId");
                        Integer contentId=selectedContent==null || selectedContent.isBlank() ? null : integer(selectedContent);
                        service.assignTest(userId, id, ids, contentId);
                        break;
                    }
                    case "start": service.startAssignment(userId, id); next = "assignment&id=" + id; break;
                    case "submitQuiz": {
                        Map<Integer,Integer> answers=new LinkedHashMap<>();
                        for (String param:Collections.list(req.getParameterNames())) {
                            if (!param.startsWith("answer_")) continue;
                            String[] values=req.getParameterValues(param);
                            if (values.length!=1) throw new TestException(400,"Mỗi câu chỉ chọn một đáp án.");
                            int questionId=integer(param.substring(7));
                            int choice;
                            try { choice=Integer.parseInt(values[0]); }
                            catch(NumberFormatException e) { throw new TestException(400,"Lựa chọn không hợp lệ."); }
                            if (answers.put(questionId,choice)!=null) throw new TestException(400,"Câu hỏi bị lặp.");
                        }
                        service.submitQuiz(userId,id,answers); next="assignment&id="+id; break;
                    }
                    case "submit": {
                        Part part = req.getPart("file");
                        byte[] bytes = null;
                        String name = null;
                        if (part != null && part.getSize() > 0) {
                            name = part.getSubmittedFileName();
                            try (var stream = part.getInputStream()) { bytes = stream.readNBytes(TestService.MAX_FILE_BYTES + 1); }
                        }
                        service.submitAssignment(userId, id, req.getParameter("content"), name, bytes);
                        next = "assignment&id=" + id;
                        break;
                    }
                    case "evaluate": {
                        BigDecimal score;
                        try { score = new BigDecimal(Optional.ofNullable(req.getParameter("score")).orElse("")); }
                        catch (NumberFormatException e) { throw new TestException(400, "Điểm không hợp lệ."); }
                        service.evaluateAssignment(userId, id, score, req.getParameter("comment"));
                        next = "assignment&id=" + id;
                        break;
                    }
                    case "revoke": service.archiveAssignment(userId, id); next = "list"; break;
                    default: throw new TestException(400, "Thao tác không hợp lệ.");
                }
            }
            req.getSession().setAttribute("testSuccess", "Đã lưu thay đổi thành công.");
            res.setStatus(HttpServletResponse.SC_SEE_OTHER);
            res.setHeader("Location", req.getContextPath() + "/tests?action=" + next);
        } catch (TestException e) { error(req, res, e.status(), e.getMessage()); }
        catch (IllegalStateException e) { error(req, res, 413, "File vượt giới hạn 5 MiB hoặc biểu mẫu quá lớn."); }
        catch (SQLException e) {
            log("Test module write failed", e);
            error(req, res, 503, "Không thể lưu thay đổi. Dữ liệu chưa được ghi; hãy thử lại sau.");
        }
    }

    /** Trả trang lỗi đã escape nội dung, giữ mã HTTP để client nhận biết lỗi phân quyền/validation. */
    private void error(HttpServletRequest req, HttpServletResponse res, int status, String message) throws ServletException, IOException {
        res.setStatus(status);
        req.setAttribute("testError", message);
        req.getRequestDispatcher("/WEB-INF/views/tests/error.jsp").forward(req, res);
    }
}
