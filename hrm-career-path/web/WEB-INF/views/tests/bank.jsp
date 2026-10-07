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
    TestActor bankActor=(TestActor)request.getAttribute("testActor");
    List<String> bankScopes="ADMIN".equals(bankActor.role()) ? List.of("culture")
            : ("HR".equals(bankActor.role()) ? List.of("culture", "department") : List.of("department"));
%>
<% if(items!=null) { %>
<section class="card">
    <div class="card-header">
        <h2>Kho đề thi</h2>
        <span class="text-secondary" style="font-size: 0.875rem;">Tổng số: <%= items.size() %> đề</span>
    </div>
    <div class="card-body">
        <% if(items.isEmpty()) { %><p class="empty-state">Chưa có đề thi nào trong ngân hàng. Hãy chạy file <code>seed_data_sqlserver.sql</code> để khởi tạo dữ liệu.</p><% } %>
        <%
            for (String scope : bankScopes) {
                boolean isCulture = "culture".equals(scope);
                String sectionTitle = isCulture ? "Đề thi Văn hóa" : "Đề thi Chuyên môn";
                String sectionIcon = isCulture ? "fa-solid fa-landmark" : "fa-solid fa-code";
                int scopeCount = 0;
                for (TestContent item : items) {
                    if (scope.equals(item.type())) scopeCount++;
                }
        %>
        <div class="test-bank-section">
            <div class="test-section-header">
                <h3 class="test-section-title">
                    <i class="<%= sectionIcon %>"></i>
                    <span><%= sectionTitle %></span>
                </h3>
                <span class="test-section-count"><%= scopeCount %> đề</span>
            </div>
            <div class="test-table-wrapper">
                <table class="data-table test-bank-table">
                    <colgroup>
                        <col style="width: 80%;">
                        <col style="width: 20%;">
                    </colgroup>
                    <thead>
                        <tr>
                            <th class="col-name">Tên đề</th>
                            <th class="col-status">Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean found = false;
                            for (TestContent item : items) {
                                if (scope.equals(item.type())) {
                                    found = true;
                        %>
                        <tr>
                            <td class="col-name">
                                <a href="<%= bankBase %>?action=bankDetail&amp;id=<%= item.id() %>" class="test-title-link">
                                    <%= h(item.title()) %>
                                </a>
                            </td>
                            <td class="col-status">
                                <% if ("ready".equals(item.status())) { %>
                                    <span class="badge badge-status-active"><i class="fa-solid fa-circle status-dot"></i> Sẵn sàng</span>
                                <% } else { %>
                                    <span class="badge badge-status-inactive"><i class="fa-solid fa-circle status-dot"></i> Bản nháp</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            }
                            if (!found) {
                        %>
                        <tr>
                            <td colspan="2" class="empty-row">Chưa có đề thuộc nhóm này.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>
        <% int pageNo = (Integer) request.getAttribute("pageNumber"); %>
        <% if (pageNo > 1 || items.size() == 20) { %>
        <nav class="test-nav" style="margin-top: 24px; margin-bottom: 0;" aria-label="Phân trang kho đề">
            <% if (pageNo > 1) { %><a href="<%= bankBase %>?action=bank&amp;page=<%= pageNo - 1 %>">← Trang trước</a><% } %>
            <span>Trang <%= pageNo %></span>
            <% if (items.size() == 20) { %><a href="<%= bankBase %>?action=bank&amp;page=<%= pageNo + 1 %>">Trang tiếp →</a><% } %>
        </nav>
        <% } %>
    </div>
</section>
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
        <a href="<%= bankBase %>?action=bank">← Về kho đề thi</a>
    </div></section>
    <% } %>
