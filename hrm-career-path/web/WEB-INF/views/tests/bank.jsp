<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.*,service.TestService" %>
<%@ page import="static utils.TestView.*" %>
<%
    String bankBase=request.getContextPath()+"/tests";
    String bankCsrf=(String)session.getAttribute("testCsrf");
    TestService.ContentDetail detail=(TestService.ContentDetail)request.getAttribute("bankDetail");
    List<TestContent> items=(List<TestContent>)request.getAttribute("bankItems");
%>
<% if(items!=null) { %>
<section class="card"><div class="card-header"><h2>Bộ đề & Câu hỏi</h2></div><div class="card-body">
    <p>Mỗi câu hỏi được lưu theo loại bài test. Nội dung đã chốt được giữ nguyên cho các lần giao.</p>
    <% if(items.isEmpty()) { %><p>Chưa có bộ đề. Hãy chọn “Tạo bộ đề trắc nghiệm mới” khi tạo đợt giao bài.</p><% } %>
    <form method="post" action="<%= bankBase %>" onsubmit="return confirm('Xóa các bộ đề đã chọn khỏi ngân hàng?')">
    <input type="hidden" name="csrf" value="<%= h(bankCsrf) %>"><input type="hidden" name="action" value="deleteContents">
    <table class="data-table"><thead><tr><th><input type="checkbox" aria-label="Chọn tất cả" onclick="var checked=this.checked;document.querySelectorAll('input[name=contentId]').forEach(function(x){x.checked=checked})"></th><th>Tên ngân hàng / bộ đề</th><th>Ngân hàng</th><th>Hình thức</th></tr></thead><tbody>
        <% for(TestContent item:items) { %>
        <tr><td><input type="checkbox" name="contentId" value="<%= item.id() %>"></td><td><a href="<%= bankBase %>?action=bankDetail&amp;id=<%= item.id() %>"><%= h(item.title()) %></a></td>
            <td><%= "culture".equals(item.type()) ? "Ngân hàng văn hóa chung" : "Ngân hàng chuyên môn" %></td><td><%= "quiz".equals(item.kind()) ? "Bộ đề trắc nghiệm" : "Câu hỏi tự luận" %></td></tr>
        <% } %>
    </tbody></table><% if(!items.isEmpty()) { %><button class="btn btn-secondary">Xóa bộ đề đã chọn</button><% } %></form>
    <% int pageNo=(Integer)request.getAttribute("pageNumber"); %>
    <% if(pageNo>1 || items.size()==20) { %><nav class="test-nav">
        <% if(pageNo>1) { %><a href="<%= bankBase %>?action=bank&amp;page=<%= pageNo-1 %>">← Trang trước</a><% } %>
        <span>Trang <%= pageNo %></span>
        <% if(items.size()==20) { %><a href="<%= bankBase %>?action=bank&amp;page=<%= pageNo+1 %>">Trang tiếp →</a><% } %>
    </nav><% } %>
</div></section>
<% } %>
<% if(detail!=null) { TestContent item=detail.content(); %>
<section class="card"><div class="card-header"><h2><%= h(item.title()) %></h2>
    <span><%= "quiz".equals(item.kind()) ? "Trắc nghiệm" : "Tự luận" %> · <%= "ready".equals(item.status()) ? "Sẵn sàng" : "Bản nháp" %></span>
</div><div class="card-body">
    <div class="test-prose"><%= h(item.prompt()) %></div>
    <% int number=0; for(TestQuestion q:detail.questions()) { %>
    <section class="test-question"><h3>Câu <%= ++number %>: <%= h(q.prompt()) %></h3>
        <% for(int i=0;i<4;i++) { %><p><%= (char)('A'+i) %>. <%= h(q.options().get(i)) %><%= Objects.equals(q.correctOption(),i) ? " ✓ Đáp án đúng" : "" %></p><% } %>
        <% if("draft".equals(item.status())) { %>
        <details><summary>Sửa câu hỏi</summary><form method="post" action="<%= bankBase %>" class="test-form" onsubmit="return validateQuestionOptions(this)">
            <input type="hidden" name="csrf" value="<%= h(bankCsrf) %>"><input type="hidden" name="action" value="updateQuestion"><input type="hidden" name="id" value="<%= item.id() %>"><input type="hidden" name="questionId" value="<%= q.id() %>">
            <label>Nội dung <textarea name="prompt" rows="3" required><%= h(q.prompt()) %></textarea></label><% for(int i=0;i<4;i++) { %><label>Lựa chọn <%= (char)('A'+i) %> <input name="option<%= (char)('A'+i) %>" value="<%= h(q.options().get(i)) %>" required></label><% } %>
            <label>Đáp án đúng <select name="correct"><% for(int i=0;i<4;i++) { %><option value="<%= i %>" <%= Objects.equals(q.correctOption(),i)?"selected":"" %>><%= (char)('A'+i) %></option><% } %></select></label><button class="btn btn-primary">Lưu sửa</button>
        </form></details>
        <form method="post" action="<%= bankBase %>">
            <input type="hidden" name="csrf" value="<%= h(bankCsrf) %>"><input type="hidden" name="action" value="removeQuestion">
            <input type="hidden" name="id" value="<%= item.id() %>"><input type="hidden" name="questionId" value="<%= q.id() %>">
            <button class="btn btn-secondary">Xóa câu nháp</button>
        </form><% } %>
    </section><% } %>
    <% if("draft".equals(item.status()) && "quiz".equals(item.kind())) { %>
    <h3>Thêm câu trắc nghiệm (tối đa 100 câu)</h3>
    <form method="post" action="<%= bankBase %>" class="test-form" onsubmit="return validateQuestionOptions(this)">
        <input type="hidden" name="csrf" value="<%= h(bankCsrf) %>"><input type="hidden" name="action" value="addQuestion">
        <input type="hidden" name="id" value="<%= item.id() %>">
        <label>Nội dung câu hỏi <textarea name="prompt" rows="3" maxlength="4000" required></textarea></label>
        <% for(int i=0;i<4;i++) { %><label>Lựa chọn <%= (char)('A'+i) %> <input name="option<%= (char)('A'+i) %>" maxlength="1000" required></label><% } %>
        <p class="alert alert-danger" data-option-error hidden>Bốn lựa chọn A, B, C và D phải khác nhau.</p>
        <label>Đáp án đúng <select name="correct"><% for(int i=0;i<4;i++) { %><option value="<%= i %>"><%= (char)('A'+i) %></option><% } %></select></label>
        <button class="btn btn-primary">Thêm câu hỏi</button>
    </form><% } %>
    <% if("draft".equals(item.status())) { %>
    <form method="post" action="<%= bankBase %>" class="test-actions">
        <input type="hidden" name="csrf" value="<%= h(bankCsrf) %>"><input type="hidden" name="action" value="publishContent">
        <input type="hidden" name="id" value="<%= item.id() %>">
        <button class="btn btn-primary">Sẵn sàng để giao</button><span>Sau bước này, nội dung và đáp án sẽ được giữ nguyên.</span>
    </form><% } else { %><p>Đã sẵn sàng. Mở một đợt giao bài đã công bố, chọn nội dung này tại phần <strong>Giao bài</strong>.</p><% } %>
    <a href="<%= bankBase %>?action=bank">← Về kho bộ đề/câu hỏi</a>
</div></section>
<% } %>
<script>
function validateQuestionOptions(form){var fields=['optionA','optionB','optionC','optionD'];var values=fields.map(function(name){return form.elements[name].value.trim().toLocaleLowerCase('vi');});var duplicate=values.findIndex(function(value,index){return values.indexOf(value)!==index;});if(duplicate>=0){window.alert('Bốn lựa chọn A, B, C và D phải khác nhau.');form.elements[fields[duplicate]].focus();return false;}return true;}
</script>
