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
    String minimumTestDate = now.atZone(ZoneId.of("Asia/Ho_Chi_Minh")).toLocalDate().toString();
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
            <a href="<%= base %>" class="<%= ("list".equals(view) && (request.getAttribute("scope") == null || "all".equals(request.getAttribute("scope")))) ? "active" : "" %>">Tất cả đề</a>
            <% if(!"ADMIN".equals(actor.role())) { %>
            <a href="<%= base %>?scope=upcoming" class="<%= "upcoming".equals(request.getAttribute("scope")) ? "active" : "" %>">Sắp diễn ra</a>
            <a href="<%= base %>?action=mine" class="<%= "mine".equals(view) ? "active" : "" %>">Bài của tôi</a>
            <a href="<%= base %>?action=calendar" class="<%= "calendar".equals(view) ? "active" : "" %>">Lịch</a>
            <% } %>
            <% if (actor.cultureManager() || actor.departmentManager()) { %><a href="<%= base %>?action=bank" class="<%= ("bank".equals(view) || "bankDetail".equals(view)) ? "active" : "" %>">Kho đề</a><% } %>
        </nav>
        <% if (flash != null) { %><div class="alert alert-success" role="status"><%= h(flash) %></div><% } %>
        <% if ("bank".equals(view) || "bankDetail".equals(view)) { %>
        <jsp:include page="/WEB-INF/views/tests/bank.jsp" />
        <% } %>

        <% if ("new".equals(view)) { %>
        <section class="card"><div class="card-header"><h2>Tạo bài test</h2></div><div class="card-body">
            <form method="post" action="<%= base %>" class="test-form" id="testCreateForm">
                <input type="hidden" name="csrf" value="<%= h(csrf) %>">
                <input type="hidden" name="action" value="create">
                <label>Tiêu đề <input name="title" required maxlength="200"></label>
                <label>Hướng bài thi
                    <select name="type" id="testType" onchange="syncTestCreateForm()">
                        <% if (actor.cultureManager()) { %><option value="culture">Bài thi Văn hóa</option><% } %>
                        <% if (actor.professionalManager()) { %><option value="department">Bài thi Chuyên môn</option><% } %>
                    </select>
                </label>
                <label>Nội dung yêu cầu <textarea name="description" rows="9" required maxlength="20000"></textarea></label>
                <label>Đề thi <select name="contentId" id="contentMode" onchange="syncTestCreateForm()" required>
                    <option value="" disabled selected>-- Chọn đề thi --</option>
                    <% List<TestContent> newChoices=(List<TestContent>)request.getAttribute("contentChoices");if(newChoices!=null)for(TestContent item:newChoices){if("quiz".equals(item.kind())&&"ready".equals(item.status())){%><option value="<%= item.id() %>" data-test-type="<%= h(item.type()) %>"><%= "culture".equals(item.type()) ? "Văn hóa: " : "Chuyên môn: " %><%= h(item.title()) %></option><% }} %>
                </select></label>
                <div class="test-columns">
                    <label>Thời gian bắt đầu (GMT+7) <input type="date" name="startDate" id="testStartDate" required min="<%= minimumTestDate %>" max="2099-12-31"><input type="time" name="startTime" id="testStartTime" required></label>
                    <label>Thời gian kết thúc (GMT+7) <input type="date" name="endDate" id="testEndDate" required min="<%= minimumTestDate %>" max="2099-12-31"><input type="time" name="endTime" id="testEndTime" required></label></div>
                <button class="btn btn-primary">Tạo đề</button>
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
                    <td><%= time(t.startTime()) %></td><td><%= time(t.endTime()) %></td><td><%= h(templateStatus(t, now)) %></td></tr>
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
        <% if (policy.canManage(actor, template) && "published".equals(template.status())) { %>
        <section class="card"><div class="card-header"><h2>Thao tác đợt giao bài</h2><span><%= h(templateStatus(template, now)) %></span></div>
            <div class="card-body">
                <div class="test-actions">
                    <form method="post" action="<%= base %>">
                        <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="id" value="<%= template.id() %>">
                        <button class="btn btn-primary" name="action" value="close">Đóng đề, ngừng nhận bài</button>
                    </form>
                </div>
            </div>
        </section>
        <% } %>
        <% if (candidates != null) { %>
        <section class="card"><div class="card-header"><h2>Giao bài</h2></div><div class="card-body">
            <% if (candidates.isEmpty()) { %><p>Không còn người nhận phù hợp chưa được giao.</p><% } else { %>
            <form method="post" action="<%= base %>" class="test-form">
                <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="assign">
                <input type="hidden" name="id" value="<%= template.id() %>">
                <label>Nội dung giao
                    <select name="contentId" required>
                        <% List<TestContent> choices=(List<TestContent>)request.getAttribute("contentChoices");
                           for (String kind : List.of("quiz","question")) { %>
                        <optgroup label="<%= "quiz".equals(kind) ? "Đề trắc nghiệm" : "Đề tự luận" %>">
                            <% for (TestContent item:choices) { if (kind.equals(item.kind())) { %>
                            <option value="<%= item.id() %>" <%= Objects.equals(template.defaultContentId(),item.id())?"selected":"" %>><%= h(item.title()) %></option>
                            <% } } %>
                        </optgroup><% } %>
                    </select>
                </label>
                <label>Thời lượng làm bài sau khi bấm bắt đầu
                    <input type="number" name="durationMinutes" min="<%= TestService.MIN_DURATION_MINUTES %>"
                           max="<%= TestService.MAX_DURATION_MINUTES %>" step="1"
                           value="<%= TestService.DEFAULT_DURATION_MINUTES %>" required>
                </label>
                <p>Đồng hồ sẽ chạy khi nhân viên bấm “Bắt đầu làm”. Hạn cá nhân không vượt quá giờ kết thúc chung của đợt.</p>
                <p>Chỉ hiển thị đề đã chốt đúng hướng Văn hóa/Chuyên môn. <a href="<%= base %>?action=bank">Xem kho đề</a></p>
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
                <table class="data-table"><thead><tr><th>Bài test</th><th>Phạm vi</th><th>Bộ đề</th><th>Người làm</th><th>Mở đợt</th><th>Đóng đợt</th><th>Thời lượng</th><th>Trạng thái</th><th>Nộp lúc</th><th>Điểm / 10</th><th></th></tr></thead><tbody>
                    <% for (TestAssignment a : assignments) { %>
                    <tr><td><%= h(a.title()) %></td>
                        <td><%= "culture".equals(a.testType()) ? "Văn hóa chung" : "Đánh giá chuyên môn" %></td>
                        <td><%= a.contentId()==null ? "—" : h(a.contentTitle()) %><% if(a.contentId()!=null) { %><br><small><%= "quiz".equals(a.contentKind()) ? "Trắc nghiệm" : "Câu hỏi" %></small><% } %></td>
                        <td><%= h(a.assigneeName()) %></td><td><%= time(a.startTime()) %></td><td><%= time(a.endTime()) %></td>
                        <td><%= a.durationMinutes() %> phút</td><td><%= a.timeExpired(now) ? "Hết giờ" : h(status(a.status())) %></td>
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
        <% boolean ownAssignment = assignment.assigneeId() == actor.id();
           boolean canStartTest = policy.canStart(actor, assignment, template, now);
           boolean canSubmitTest = policy.canSubmit(actor, assignment, template, now);
           boolean startedAssignment = "in_progress".equals(assignment.status());
           Instant submissionDeadline = assignment.submissionDeadline(); %>
        <section class="card"><div class="card-header"><h2><%= h(template.title()) %></h2><span><%= assignment.timeExpired(now) ? "Hết giờ" : h(status(assignment.status())) %></span></div><div class="card-body">
            <p>Người làm: <strong><%= h(assignment.assigneeName()) %></strong></p>
            <p>Thời gian mở đợt: <%= time(template.startTime()) %> — <%= time(template.endTime()) %> (giờ Việt Nam)</p>
            <p>Thời lượng làm bài: <strong><%= assignment.durationMinutes() %> phút</strong></p>
            <% if (assignment.startedAt()!=null) { %>
            <p>Bắt đầu làm: <%= time(assignment.startedAt()) %> · Hạn nộp cá nhân: <strong><%= time(submissionDeadline) %></strong></p>
            <% } %>
            <% if (ownAssignment && startedAssignment && submissionDeadline!=null && now.isBefore(submissionDeadline)) { %>
            <div class="test-countdown" id="testCountdown" data-deadline="<%= submissionDeadline.toEpochMilli() %>" role="timer" aria-live="polite">
                <span>Thời gian còn lại</span><strong id="testCountdownValue">--:--</strong>
            </div>
            <% } %>
            <div class="test-prose"><%= h(template.description()) %></div>
            <% if (assignment.contentId()!=null) { %>
                <h3><%= "quiz".equals(assignment.contentKind()) ? "Bộ đề trắc nghiệm: " : "Câu hỏi tự luận: " %><%= h(assignment.contentTitle()) %></h3>
                <% if (assignedContent!=null) { %>
                <div class="test-prose"><%= h(assignedContent.content().prompt()) %></div>
                <% } else { %><p>Nội dung sẽ mở khi đến giờ bắt đầu.</p><% } %>
            <% } %>
            <% if ("quiz".equals(assignment.contentKind()) && assignedContent!=null
                    && (!ownAssignment || !"pending".equals(assignment.status()))) {
                boolean canAnswer=canSubmitTest && ownAssignment && startedAssignment; %>
                <form method="post" action="<%= base %>" class="test-form" <%= canAnswer ? "data-timed-submission" : "" %>>
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="submitQuiz">
                    <input type="hidden" name="id" value="<%= assignment.id() %>">
                    <% int number=0; for (TestQuestion q:assignedContent.questions()) { %>
                    <fieldset class="test-question"><legend>Câu <%= ++number %>: <%= h(q.prompt()) %></legend>
                        <% int optionNumber=0; Set<Integer> selectedAnswers=assignedContent.answers().getOrDefault(q.id(),Collections.emptySet());
                           for(TestQuestionOption option:q.options()) { %>
                        <label class="test-option"><input type="<%= q.multipleChoice() ? "checkbox" : "radio" %>" name="answer_<%= q.id() %>" value="<%= option.id() %>"
                            <%= selectedAnswers.contains(option.id()) ? "checked" : "" %>
                            <%= canAnswer ? (!q.multipleChoice() ? "required" : "") : "disabled" %>>
                            <%= (char)('A'+optionNumber++) %>. <%= h(option.text()) %></label>
                        <% } %>
                            <% if (assignment.assigneeId() != actor.id() && !q.correctOptionIds().isEmpty()) { %><p>Đáp án đúng (người quản lý):
                            <% int correctNumber=0; for(TestQuestionOption option:q.options()) { if(Boolean.TRUE.equals(option.correct())) { if(correctNumber++>0){ %>, <% } %><%= h(option.text()) %><% } } %>
                        </p><% } %>
                    </fieldset><% } %>
                    <% if(canAnswer) { %><p>Câu “chọn nhiều” có thể có nhiều đáp án đúng; các câu còn lại chỉ chọn một đáp án. Sau khi nộp không thể sửa.</p><button class="btn btn-primary">Nộp bài trắc nghiệm</button><% } %>
                </form>
                <% if (assignment.quizScore()!=null) { %><p><strong>Điểm trắc nghiệm tự tính: <%= h(assignment.quizScore()) %> / 10.</strong> Người quản lý sẽ xác nhận đánh giá.</p><% } %>
            <% } %>
            <% if (canStartTest && ownAssignment) { %>
                <form method="post" action="<%= base %>" class="test-actions">
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="start">
                    <input type="hidden" name="id" value="<%= assignment.id() %>"><button class="btn btn-secondary">Bắt đầu làm</button>
                </form>
                <p>Hãy bấm “Bắt đầu làm” để mở nội dung trả lời.</p>
            <% } %>
                <% if (canSubmitTest && ownAssignment && startedAssignment && !"quiz".equals(assignment.contentKind())) { %>
                <form method="post" action="<%= base %>" enctype="multipart/form-data" class="test-form" data-timed-submission>
                    <input type="hidden" name="csrf" value="<%= h(csrf) %>"><input type="hidden" name="action" value="submit">
                    <input type="hidden" name="id" value="<%= assignment.id() %>">
                    <label>Nội dung bài làm <textarea name="content" rows="10" maxlength="50000"></textarea></label>
                    <label>File bài làm (tối đa 5 MiB) <input type="file" name="file"></label>
                    <p>Nhập nội dung hoặc đính kèm file. Sau khi nộp, bài không thể sửa.</p>
                    <button class="btn btn-primary">Nộp bài</button>
                </form>
                <% } %>
            <% if (ownAssignment && ("pending".equals(assignment.status()) || "in_progress".equals(assignment.status()))
                    && !canStartTest && !canSubmitTest) { %>
                <p class="alert"><%= assignment.timeExpired(now)
                        ? "Đã hết thời gian làm bài. Hệ thống không nhận thêm câu trả lời."
                        : "Hiện không thể làm bài: bài chưa đến giờ bắt đầu, đã hết hạn hoặc đề đã đóng." %></p>
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
            <% if (policy.canManage(actor, template) && !ownAssignment && policy.canRevoke(actor, assignment)) { %>
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
    var type=document.getElementById('testType'),mode=document.getElementById('contentMode');
    if(!type||!mode)return;
    Array.prototype.forEach.call(mode.options,function(option){if(option.dataset.testType)option.disabled=option.dataset.testType!==type.value;});
    if(mode.selectedOptions.length&&mode.selectedOptions[0].disabled)mode.value='';
}
function initTestCountdown(){
    var box=document.getElementById('testCountdown'),value=document.getElementById('testCountdownValue');
    if(!box||!value)return;
    var deadline=Number(box.dataset.deadline),timer;
    function update(){
        var remaining=Math.max(0,deadline-Date.now()),seconds=Math.ceil(remaining/1000);
        var hours=Math.floor(seconds/3600),minutes=Math.floor((seconds%3600)/60),secs=seconds%60;
        value.textContent=(hours>0?String(hours).padStart(2,'0')+':':'')+String(minutes).padStart(2,'0')+':'+String(secs).padStart(2,'0');
        if(remaining<=0){
            value.textContent='Đã hết giờ';
            box.classList.add('expired');
            document.querySelectorAll('form[data-timed-submission] input, form[data-timed-submission] textarea, form[data-timed-submission] button')
                    .forEach(function(control){control.disabled=true;});
            if(timer)clearInterval(timer);
        }
    }
    update();
    timer=setInterval(update,1000);
}
function validateTestSchedule(){
    var startDate=document.getElementById('testStartDate'),startTime=document.getElementById('testStartTime');
    var endDate=document.getElementById('testEndDate'),endTime=document.getElementById('testEndTime');
    if(!startDate||!startTime||!endDate||!endTime)return true;
    updateTestEndConstraints(false);
    startTime.setCustomValidity('');
    endTime.setCustomValidity('');
    var startValid=true,endValid=true;
    if(startDate.value&&startTime.value){
        var start=new Date(startDate.value+'T'+startTime.value+':00+07:00');
        startValid=start.getTime()>=Date.now();
        startTime.setCustomValidity(startValid?'':'Thời gian bắt đầu không được sớm hơn thời gian hiện tại.');
        if(endDate.value&&endTime.value){
            var end=new Date(endDate.value+'T'+endTime.value+':00+07:00');
            endValid=end.getTime()>start.getTime();
            endTime.setCustomValidity(endValid?'':'Thời gian kết thúc phải sau thời gian bắt đầu.');
        }
    }
    return startValid&&endValid;
}
function nextTestMinute(value){
    if(!value)return null;
    var parts=value.split(':'),minutes=parseInt(parts[0],10)*60+parseInt(parts[1],10)+1;
    if(minutes>=1440)return null;
    return String(Math.floor(minutes/60)).padStart(2,'0')+':'+String(minutes%60).padStart(2,'0');
}
function nextTestDate(value){
    var parts=value.split('-'),date=new Date(Number(parts[0]),Number(parts[1])-1,Number(parts[2])+1);
    return date.getFullYear()+'-'+String(date.getMonth()+1).padStart(2,'0')+'-'+String(date.getDate()).padStart(2,'0');
}
function updateTestEndConstraints(clearInvalid){
    var startDate=document.getElementById('testStartDate'),startTime=document.getElementById('testStartTime');
    var endDate=document.getElementById('testEndDate'),endTime=document.getElementById('testEndTime');
    if(!startDate||!startTime||!endDate||!endTime)return;
    var minimumDate=startDate.value||'<%= minimumTestDate %>',minimumTime=nextTestMinute(startTime.value);
    if(startDate.value&&startTime.value&&!minimumTime)minimumDate=nextTestDate(startDate.value);
    endDate.min=minimumDate;
    if(clearInvalid&&endDate.value&&endDate.value<minimumDate){
        endDate.value='';
        endTime.value='';
    }
    if(startDate.value&&endDate.value===startDate.value&&minimumTime){
        endTime.min=minimumTime;
        if(clearInvalid&&endTime.value&&endTime.value<minimumTime)endTime.value='';
    }else{
        endTime.removeAttribute('min');
    }
}
document.addEventListener('DOMContentLoaded',function(){
    syncTestCreateForm();
    initTestCountdown();
    var form=document.getElementById('testCreateForm');
    if(form){
        form.addEventListener('submit',validateTestSchedule);
        ['testStartDate','testStartTime','testEndDate','testEndTime'].forEach(function(id){
            var field=document.getElementById(id);
            field.addEventListener('input',function(){updateTestEndConstraints(true);validateTestSchedule();});
            field.addEventListener('change',function(){updateTestEndConstraints(true);validateTestSchedule();});
        });
        updateTestEndConstraints(true);
        validateTestSchedule();
    }
});
</script>
<jsp:include page="/views/common/footer.jsp" />
