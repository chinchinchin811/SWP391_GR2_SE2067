<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,java.time.*,model.*,policy.TestPolicy,service.TestService" %>
<%@ page import="static utils.TestView.*" %>
<%
    String view = (String) request.getAttribute("testView");
    TestActor actor = (TestActor) request.getAttribute("testActor");
    TestPolicy policy = (TestPolicy) request.getAttribute("testPolicy");
    Instant now = (Instant) request.getAttribute("testNow");
    String base = request.getContextPath() + "/tests";
    String csrf = (String) session.getAttribute("testCsrf");
    int pageNo = (Integer) request.getAttribute("pageNumber");
    TestTemplate template = (TestTemplate) request.getAttribute("template");
    TestAssignment assignment = (TestAssignment) request.getAttribute("assignment");
    List<TestTemplate> templates = (List<TestTemplate>) request.getAttribute("templates");
    List<TestAssignment> assignments = (List<TestAssignment>) request.getAttribute("assignments");
    List<TestActor> candidates = (List<TestActor>) request.getAttribute("candidates");
    TestService.ContentDetail assignedContent = (TestService.ContentDetail) request.getAttribute("assignedContent");
    String flash = (String) session.getAttribute("testSuccess");
    session.removeAttribute("testSuccess");
    request.setAttribute("pageTitle", "Bài test & Đánh giá | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content test-module">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/tests.css">
    <div class="topbar"><h1>Bài test & Đánh giá</h1>
        <% if (actor.cultureManager() || actor.departmentManager()) { %>
        <a class="btn btn-primary" href="<%= base %>?action=new">+ Tạo đợt giao bài</a>
        <% } %>
    </div>
    <div class="content-body">
        <nav class="test-nav" aria-label="Bài test">
            <a href="<%= base %>">Tất cả đề</a>
            <a href="<%= base %>?scope=upcoming">Sắp diễn ra</a>
            <% if(!"ADMIN".equals(actor.role())) { %><a href="<%= base %>?action=mine">Bài của tôi</a><% } %>
            <a href="<%= base %>?action=calendar">Lịch</a>
        </nav>
        <% if (flash != null) { %><div class="alert alert-success" role="status"><%= h(flash) %></div><% } %>
        <% if ("bank".equals(view) || "bankDetail".equals(view)) { %>
        <jsp:include page="/WEB-INF/views/tests/bank.jsp" />
        <% } %>

        <% if ("new".equals(view)) { %>
        <section class="card"><div class="card-header"><h2>Tạo bài test</h2></div><div class="card-body">
            <p>Đặt lịch, chọn đề tự luận hoặc một bộ trắc nghiệm. Phạm vi người nhận là toàn công ty, ngoại trừ ADMIN.</p>
            <form method="post" action="<%= base %>" class="test-form">
                <input type="hidden" name="csrf" value="<%= h(csrf) %>">
                <input type="hidden" name="action" value="create">
                <label>Tiêu đề <input name="title" required maxlength="200"></label>
                <label>Loại bài
                    <select name="type" id="testType" onchange="syncTestCreateForm()">
                        <% if (actor.departmentManager() || actor.cultureManager()) { %><option value="department">Đánh giá chuyên môn</option><% } %>
                        <% if (actor.cultureManager()) { %><option value="culture">Văn hóa chung</option><% } %>
                    </select>
                </label>
                <label>Nội dung yêu cầu <textarea name="description" rows="9" required maxlength="20000"></textarea></label>
                <label>Hình thức đề thi <select name="contentId" id="contentMode" onchange="syncTestCreateForm()">
                    <option value="">Đề tự luận theo nội dung yêu cầu phía trên</option><option value="newQuiz">Tạo bộ đề trắc nghiệm mới</option>
                    <% List<TestContent> newChoices=(List<TestContent>)request.getAttribute("contentChoices");if(newChoices!=null)for(TestContent item:newChoices){if("quiz".equals(item.kind())&&"ready".equals(item.status())){%><option value="<%= item.id() %>" data-test-type="<%= h(item.type()) %>">Trắc nghiệm: <%= h(item.title()) %></option><% }} %>
                </select></label>
                <div id="newQuizFields" hidden><label>Tên bộ đề trắc nghiệm mới <input name="quizTitle" maxlength="200"></label><label>Hướng dẫn làm bài <textarea name="quizPrompt" rows="4" maxlength="20000"></textarea></label><p>Sau khi lưu, hãy thêm/sửa/xóa câu hỏi rồi bấm “Sẵn sàng để giao”.</p></div>
                <div class="test-columns">
                    <label>Thời gian bắt đầu (GMT+7) <input type="date" name="startDate" required min="2000-01-01" max="2099-12-31"><input type="time" name="startTime" required></label>
                    <label>Thời gian kết thúc (GMT+7) <input type="date" name="endDate" required min="2000-01-01" max="2099-12-31"><input type="time" name="endTime" required></label></div>
                <button class="btn btn-primary">Lưu bản nháp</button>
            </form>
        </div></section>
        <% } %>

        <% if ("calendar".equals(view)) { %>
        <section class="card"><div class="card-header"><h2>Lịch bài test</h2></div><div class="card-body">
            <form method="get" action="<%= base %>" class="test-filters">
                <input type="hidden" name="action" value="calendar">
                <label>Từ ngày <input type="date" name="from" value="<%= h(request.getAttribute("from")) %>" required></label>
                <label>Đến trước ngày <input type="date" name="to" value="<%= h(request.getAttribute("to")) %>" required></label>
                <button class="btn btn-primary">Xem lịch</button>
            </form>
            <p>Giờ Việt Nam (UTC+7). Hiển thị các bài có thời gian giao với khoảng đã chọn, tối đa 366 ngày.</p>
        </div></section>
        <% } %>

        <% if (templates != null) { %>
        <section class="card"><div class="card-header"><h2><%= "calendar".equals(view) ? "Lịch theo thời gian" : "Danh sách đề" %></h2></div><div class="card-body test-table">
            <% if (templates.isEmpty()) { %><p>Chưa có bài test phù hợp.</p><% } else { %>
            <table class="data-table"><thead><tr><th>Bài test</th><th>Phạm vi</th><th>Bắt đầu</th><th>Kết thúc</th><th>Trạng thái</th></tr></thead><tbody>
                <% for (TestTemplate t : templates) { %>
                <tr><td><a href="<%= base %>?action=detail&amp;id=<%= t.id() %>"><%= h(t.title()) %></a></td>
                    <td><%= "culture".equals(t.type()) ? "Văn hóa chung" : "Đánh giá chuyên môn" %></td>
                    <td><%= time(t.startTime()) %></td><td><%= time(t.endTime()) %></td><td><%= h(status(t.status())) %></td></tr>
                <% } %>
            </tbody></table><% } %>
            <%
                String query = "calendar".equals(view) ? "action=calendar&from=" + request.getAttribute("from") + "&to=" + request.getAttribute("to")
                        : "action=list&scope=" + request.getAttribute("scope");
            %>
            <% if(pageNo>1 || templates.size()==20) { %><nav class="test-nav" aria-label="Phân trang đề">
                <% if (pageNo > 1) { %><a href="<%= base %>?<%= h(query) %>&amp;page=<%= pageNo - 1 %>">← Trang trước</a><% } %>
                <span>Trang <%= pageNo %></span>
                <% if (templates.size() == 20) { %><a href="<%= base %>?<%= h(query) %>&amp;page=<%= pageNo + 1 %>">Trang tiếp →</a><% } %>
            </nav><% } %>
        </div></section>
        <% } %>

        <% if ("detail".equals(view)) { %>
        <section class="card"><div class="card-header"><h2><%= h(template.title()) %></h2><span><%= h(status(template.status())) %></span></div>
            <div class="card-body">
                <p><%= "culture".equals(template.type()) ? "Văn hóa chung" : "Đánh giá chuyên môn" %>
                    · <%= time(template.startTime()) %> — <%= time(template.endTime()) %> (giờ Việt Nam)</p>
                <div class="test-prose"><%= h(template.description()) %></div>
                <% if (policy.canManage(actor, template)) { %>
                <div class="test-actions">
                    <form method="post" action="<%= base %>">
                        <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="id" value="<%= template.id() %>">
                        <% if ("draft".equals(template.status())) { %>
                        <button class="btn btn-primary" name="action" value="publish">Công bố đề</button>
                        <% } else if ("published".equals(template.status())) { %>
                        <button class="btn btn-primary" name="action" value="close">Đóng đề, ngừng nhận bài</button>
                        <% } %>
                        <% if (!"published".equals(template.status())) { %>
                        <button class="btn btn-secondary" name="action" value="archive">Lưu trữ đề</button>
                        <% } %>
                    </form>
                </div>
                <% } else { %><p>Để làm bài đã được giao, hãy vào <a href="<%= base %>?action=mine">Bài của tôi</a>.</p><% } %>
            </div>
        </section>
        <% if (candidates != null) { %>
        <section class="card"><div class="card-header"><h2>Giao bài</h2></div><div class="card-body">
            <% if (candidates.isEmpty()) { %><p>Không còn người nhận phù hợp chưa được giao.</p><% } else { %>
            <form method="post" action="<%= base %>" class="test-form">
                <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="assign">
                <input type="hidden" name="id" value="<%= template.id() %>">
                <label>Nội dung giao
                    <select name="contentId">
                        <option value="">Tự luận theo nội dung yêu cầu của đợt này</option>
                        <% List<TestContent> choices=(List<TestContent>)request.getAttribute("contentChoices");
                           for (String kind : List.of("quiz","question")) { %>
                        <optgroup label="<%= "quiz".equals(kind) ? "Bộ đề trắc nghiệm" : "Câu hỏi tự luận" %>">
                            <% for (TestContent item:choices) { if (kind.equals(item.kind())) { %>
                            <option value="<%= item.id() %>" <%= Objects.equals(template.defaultContentId(),item.id())?"selected":"" %>><%= h(item.title()) %></option>
                            <% } } %>
                        </optgroup><% } %>
                    </select>
                </label>
                <p>Chỉ hiển thị nội dung đã chốt cùng phạm vi. <a href="<%= base %>?action=bank">Tạo bộ đề/câu hỏi</a></p>
                <fieldset class="test-candidates"><legend>Chọn người nhận toàn công ty, ngoại trừ ADMIN (tối đa 500 mỗi lần)</legend>
                    <% for (TestActor candidate : candidates) { %>
                    <label><input type="checkbox" name="assigneeId" value="<%= candidate.id() %>">
                        <%= h(candidate.name()) %> · #<%= candidate.id() %><%= candidate.departmentId() == null ? "" : " · Phòng #" + candidate.departmentId() %></label>
                    <% } %>
                </fieldset><button class="btn btn-primary">Giao cho người đã chọn</button>
            </form><% } %>
        </div></section><% } %>
        <% } %>

        <% if (assignments != null) { %>
        <section class="card"><div class="card-header"><h2><%= "mine".equals(view) ? "Bài được giao cho tôi" : "Người được giao & Kết quả" %></h2></div>
            <div class="card-body test-table">
                <% if (assignments.isEmpty()) { %><p>Chưa có bài được giao trong trang này.</p><% } else { %>
                <table class="data-table"><thead><tr><th>Bài test</th><th>Người làm</th><th>Trạng thái</th><th>Nộp lúc</th><th>Điểm / 10</th><th></th></tr></thead><tbody>
                    <% for (TestAssignment a : assignments) { %>
                    <tr><td><%= h(a.title()) %><% if(a.contentId()!=null) { %><br><small><%= "quiz".equals(a.contentKind()) ? "Trắc nghiệm: " : "Câu hỏi: " %><%= h(a.contentTitle()) %></small><% } %></td><td><%= h(a.assigneeName()) %></td><td><%= h(status(a.status())) %></td>
                        <td><%= time(a.submittedAt()) %></td><td><%= a.evaluation() == null ? "—" : h(a.evaluation().score()) %></td>
                        <td><a href="<%= base %>?action=assignment&amp;id=<%= a.id() %>">Mở bài</a></td></tr>
                    <% } %>
                </tbody></table><% } %>
                <% String query = "mine".equals(view) ? "action=mine" : "action=detail&id=" + template.id(); %>
                <% if(pageNo>1 || assignments.size()==20) { %><nav class="test-nav" aria-label="Phân trang bài được giao">
                    <% if (pageNo > 1) { %><a href="<%= base %>?<%= h(query) %>&amp;page=<%= pageNo - 1 %>">← Trang trước</a><% } %>
                    <span>Trang <%= pageNo %></span>
                    <% if (assignments.size() == 20) { %><a href="<%= base %>?<%= h(query) %>&amp;page=<%= pageNo + 1 %>">Trang tiếp →</a><% } %>
                </nav><% } %>
            </div>
        </section>
        <% } %>

        <% if ("assignment".equals(view)) { %>
        <section class="card"><div class="card-header"><h2><%= h(template.title()) %></h2><span><%= h(status(assignment.status())) %></span></div><div class="card-body">
            <p>Người làm: <strong><%= h(assignment.assigneeName()) %></strong></p>
            <p>Thời gian: <%= time(template.startTime()) %> — <%= time(template.endTime()) %> (giờ Việt Nam)</p>
            <div class="test-prose"><%= h(template.description()) %></div>
            <% if (assignment.contentId()!=null) { %>
                <h3><%= "quiz".equals(assignment.contentKind()) ? "Bộ đề trắc nghiệm: " : "Câu hỏi tự luận: " %><%= h(assignment.contentTitle()) %></h3>
                <% if (assignedContent!=null) { %>
                <div class="test-prose"><%= h(assignedContent.content().prompt()) %></div>
                <% } else { %><p>Nội dung sẽ mở khi đến giờ bắt đầu.</p><% } %>
            <% } %>
            <% if ("quiz".equals(assignment.contentKind()) && assignedContent!=null) {
                boolean canAnswer=policy.canSubmit(actor,assignment,template,now); %>
                <form method="post" action="<%= base %>" class="test-form">
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="submitQuiz">
                    <input type="hidden" name="id" value="<%= assignment.id() %>">
                    <% int number=0; for (TestQuestion q:assignedContent.questions()) { %>
                    <fieldset class="test-question"><legend>Câu <%= ++number %>: <%= h(q.prompt()) %></legend>
                        <% for(int option=0;option<q.options().size();option++) { %>
                        <label class="test-option"><input type="radio" name="answer_<%= q.id() %>" value="<%= option %>"
                            <%= Objects.equals(assignedContent.answers().get(q.id()),option) ? "checked" : "" %>
                            <%= canAnswer ? "required" : "disabled" %>>
                            <%= (char)('A'+option) %>. <%= h(q.options().get(option)) %></label>
                        <% } %>
                        <% if (q.correctOption()!=null) { %><p>Đáp án đúng (người quản lý): <%= (char)('A'+q.correctOption()) %></p><% } %>
                    </fieldset><% } %>
                    <% if(canAnswer) { %><p>Mỗi câu chọn một đáp án. Sau khi nộp không thể sửa.</p><button class="btn btn-primary">Nộp bài trắc nghiệm</button><% } %>
                </form>
                <% if (assignment.quizScore()!=null) { %><p><strong>Điểm trắc nghiệm tự tính: <%= h(assignment.quizScore()) %> / 10.</strong> Người quản lý sẽ xác nhận đánh giá.</p><% } %>
            <% } %>
            <% if (policy.canSubmit(actor, assignment, template, now)) { %>
                <% if ("pending".equals(assignment.status())) { %>
                <form method="post" action="<%= base %>" class="test-actions">
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="start">
                    <input type="hidden" name="id" value="<%= assignment.id() %>"><button class="btn btn-secondary">Bắt đầu làm</button>
                </form><% } %>
                <% if (!"quiz".equals(assignment.contentKind())) { %>
                <form method="post" action="<%= base %>" enctype="multipart/form-data" class="test-form">
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="submit">
                    <input type="hidden" name="id" value="<%= assignment.id() %>">
                    <label>Nội dung bài làm <textarea name="content" rows="10" maxlength="50000"></textarea></label>
                    <label>File bài làm (tối đa 5 MiB) <input type="file" name="file"></label>
                    <p>Nhập nội dung hoặc đính kèm file. Sau khi nộp, bài không thể sửa.</p>
                    <button class="btn btn-primary">Nộp bài</button>
                </form>
                <% } %>
            <% } else if (assignment.assigneeId() == actor.id() && ("pending".equals(assignment.status()) || "in_progress".equals(assignment.status()))) { %>
                <p class="alert">Hiện không thể nộp: bài chưa đến giờ bắt đầu, đã hết hạn hoặc đề đã đóng.</p>
            <% } %>
            <% if (assignment.submittedAt() != null) { %>
                <h3>Bài đã nộp · <%= time(assignment.submittedAt()) %></h3>
                <div class="test-prose"><%= h(assignment.content()) %></div>
                <% if (assignment.fileName() != null) { %>
                <p><a href="<%= base %>?action=download&amp;id=<%= assignment.id() %>">Tải file: <%= h(assignment.fileName()) %></a></p><% } %>
            <% } %>
            <% if (assignment.evaluation() != null) { %>
                <h3>Kết quả: <%= h(assignment.evaluation().score()) %> / 10</h3>
                <p>Người chấm #<%= assignment.evaluation().evaluatorId() %> · <%= time(assignment.evaluation().evaluatedAt()) %></p>
                <div class="test-prose"><%= h(assignment.evaluation().comment()) %></div>
            <% } %>
            <% if (policy.canEvaluate(actor, assignment, template)) { %>
                <h3>Đánh giá bài làm</h3>
                <form method="post" action="<%= base %>" class="test-form">
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="evaluate">
                    <input type="hidden" name="id" value="<%= assignment.id() %>">
                    <label>Điểm (0–10) <input type="number" min="0" max="10" step="0.01" name="score" value="<%= h(assignment.quizScore()) %>" required></label>
                    <label>Nhận xét <textarea name="comment" maxlength="4000" rows="5" required></textarea></label>
                    <button class="btn btn-primary">Lưu đánh giá</button>
                </form>
            <% } %>
            <% if (policy.canManage(actor, template) && "pending".equals(assignment.status())) { %>
                <form method="post" action="<%= base %>" class="test-actions">
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="revoke">
                    <input type="hidden" name="id" value="<%= assignment.id() %>"><button class="btn btn-secondary">Thu hồi bài chưa bắt đầu</button>
                </form>
            <% } %>
        </div></section>
        <% } %>

    </div>
</main>
<script>
function syncTestCreateForm(){
    var type=document.getElementById('testType'),mode=document.getElementById('contentMode'),fields=document.getElementById('newQuizFields');
    if(!type||!mode||!fields)return;
    Array.prototype.forEach.call(mode.options,function(option){if(option.dataset.testType)option.disabled=option.dataset.testType!==type.value;});
    if(mode.selectedOptions.length&&mode.selectedOptions[0].disabled)mode.value='';
    var creating=mode.value==='newQuiz';fields.hidden=!creating;
    Array.prototype.forEach.call(fields.querySelectorAll('input,textarea'),function(input){input.required=creating;});
}
document.addEventListener('DOMContentLoaded',syncTestCreateForm);
</script>
<jsp:include page="/views/common/footer.jsp" />
