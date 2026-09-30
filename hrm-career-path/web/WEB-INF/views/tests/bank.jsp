<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.*,service.TestService" %>
<%@ page import="static utils.TestView.*" %>
<%!
    private String questionType(String type) {
        if ("true_false".equals(type)) return "Đúng / Sai";
        if ("multiple".equals(type)) return "Chọn nhiều đáp án";
        return "Chọn một đáp án";
    }
%>
<%
    String bankBase=request.getContextPath()+"/tests";
    TestService.ContentDetail detail=(TestService.ContentDetail)request.getAttribute("bankDetail");
    List<TestContent> items=(List<TestContent>)request.getAttribute("bankItems");
%>
<% if(items!=null) { %>
<section class="card"><div class="card-header"><h2>Kho đề thi trong</h2></div><div class="card-body">
        <% if(items.isEmpty()) { %><p>Chưa có đề thi. Hãy chạy file <code>seed_data_sqlserver.sql</code>.</p><% } %>
        <% for(String scope : List.of("culture", "department")) { %>
        <h3><%= "culture".equals(scope) ? "Đề thi Văn hóa" : "Đề thi Chuyên môn" %></h3>
        <div class="test-table"><table class="data-table"><thead><tr><th>Tên đề</th><th>Hình thức</th><th>Trạng thái</th></tr></thead><tbody>
                            <% boolean found=false; for(TestContent item:items) { if(scope.equals(item.type())) { found=true; %>
                    <tr><td><a href="<%= bankBase %>?action=bankDetail&amp;id=<%= item.id() %>"><%= h(item.title()) %></a></td>
                        <td><%= "quiz".equals(item.kind()) ? "Trắc nghiệm từ database" : "Tự luận" %></td>
                        <td><%= "ready".equals(item.status()) ? "Sẵn sàng" : "Bản nháp" %></td></tr>
                    <% } } if(!found) { %><tr><td colspan="3">Chưa có đề thuộc nhóm này.</td></tr><% } %>
                </tbody></table></div>
                <% } %>
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
        <span><%= "culture".equals(item.type()) ? "Đề Văn hóa" : "Đề Chuyên môn" %> · Chỉ đọc</span>
    </div><div class="card-body">
        <div class="test-prose"><%= h(item.prompt()) %></div>
        <% int number=0; for(TestQuestion q:detail.questions()) { %>
        <section class="test-question">
            <h3>Câu <%= ++number %>: <%= h(q.prompt()) %></h3>
            <p><small><%= questionType(q.type()) %></small></p>
            <% int optionNumber=0; for(TestQuestionOption option:q.options()) { %>
            <p><%= (char)('A'+optionNumber++) %>. <%= h(option.text()) %><%= Boolean.TRUE.equals(option.correct()) ? " ✓ Đáp án đúng" : "" %></p>
            <% } %>
        </section>
        <% } %>
        <p>Đề và đáp án được nạp từ database; muốn thay đổi cần cập nhật migration/seed để mọi môi trường dùng cùng dữ liệu.</p>
        <a href="<%= bankBase %>?action=bank">← Về kho đề thi</a>
    </div></section>
    <% } %>
