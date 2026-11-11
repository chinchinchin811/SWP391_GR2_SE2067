<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.*,policy.TestPolicy,service.TestService" %>
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
    TestPolicy bankPolicy=(TestPolicy)request.getAttribute("testPolicy");
%>
<% if(items!=null) { %>
<section class="card">
    <div class="card-header">
        <h2>Kho đề thi</h2>
        <span class="text-secondary" style="font-size: 0.875rem;">Tổng số: <%= items.size() %> đề</span>
    </div>
    <div class="card-body">
        <% if(items.isEmpty()) { %><p class="empty-state">Chưa có đề thi nào trong phạm vi của bạn.</p><% } %>
        <div class="test-bank-section">
            <div class="test-section-header">
                <h3 class="test-section-title">
                    <i class="fa-solid fa-code"></i>
                    <span>Đề thi Chuyên môn</span>
                </h3>
                <span class="test-section-count"><%= items.size() %> đề</span>
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
                        <% for (TestContent item : items) { %>
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
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
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
        <div class="test-card-header-actions">
            <span>Đề <%= typeLabel(item.type()) %> · <%= "ready".equals(item.status()) ? "Sẵn sàng" : "Bản nháp" %></span>
            <% if(bankPolicy.canEditContent(bankActor,item)) { %>
            <a class="btn btn-secondary" href="<%= bankBase %>?action=editSet&amp;id=<%= item.id() %>">Chỉnh sửa bộ đề</a>
            <% } %>
        </div>
    </div><div class="card-body">
        <div class="test-prose"><%= h(item.prompt()) %></div>
        <% int number=0; for(TestQuestion q:detail.questions()) { %>
        <section class="test-question">
            <h3>Câu <%= ++number %>: <%= h(q.prompt()) %></h3>
            <p><small><%= questionType(q.type()) %></small></p>
            <% int optionNumber=0; for(TestQuestionOption option:q.options()) {
               boolean isCorrect = Boolean.TRUE.equals(option.correct());
            %>
            <p class="test-option-line">
                <% if(isCorrect) { %><span class="correct-answer-highlight"><% } %>
                    <%= (char)('A'+optionNumber++) %>. <%= h(option.text()) %>
                    <% if(isCorrect) { %> <i class="fa-solid fa-check"></i> Đáp án đúng</span><% } %>
            </p>
            <% } %>
        </section>
        <% } %>
        <a href="<%= bankBase %>?action=bank">← Về kho đề thi</a>
    </div></section>
    <% } %>
