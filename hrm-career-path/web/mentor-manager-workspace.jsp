<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.TrainingClass" %>
<%@ page import="model.ClassEnrollment" %>
<%@ page import="model.User" %>
<%@ page import="model.Mentor.MentorEvaluation" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || currentUser.getRoleId() != 3) { response.sendRedirect(request.getContextPath() + "/dashboard"); return; }
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("managerClasses");
    Map<Integer, List<ClassEnrollment>> menteesByClass = (Map<Integer, List<ClassEnrollment>>) request.getAttribute("classMentees");
    List<MentorEvaluation> evaluations = (List<MentorEvaluation>) request.getAttribute("managerEvaluations");
    request.setAttribute("pageTitle", "Mentor Workspace | CPMS");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar"><h1>Mentor Workspace</h1></div>
    <div class="content-body">
        <p>Danh sách mentee đã được ghi danh vào các lớp thuộc phòng ban bạn phụ trách. Bạn có thể đánh giá từng mentee.</p>
        <% if (classes != null && !classes.isEmpty()) { for (TrainingClass trainingClass : classes) {
            List<ClassEnrollment> mentees = menteesByClass.get(trainingClass.getClassId()); %>
        <section class="card" style="padding:20px;margin-bottom:20px;">
            <h2 style="margin-top:0"><%= trainingClass.getClassName() %> <small>(<%= trainingClass.getClassCode() %>)</small></h2>
            <p>Mentor lớp: <%= trainingClass.getMentorName() == null ? "Chưa phân công" : trainingClass.getMentorName() %></p>
            <div class="table-responsive"><table class="data-table" style="width:100%">
                <thead><tr><th>Mentee</th><th>Trạng thái lớp</th><th>Tiến độ</th><th>Đánh giá</th></tr></thead>
                <tbody>
                <% if (mentees != null && !mentees.isEmpty()) { for (ClassEnrollment mentee : mentees) { %>
                    <tr><td><%= mentee.getUserName() %></td><td><%= mentee.getStatus() %></td><td><%= mentee.getProgressPercent() %>%</td>
                        <td><a class="btn btn-sm btn-primary" href="<%= request.getContextPath() %>/mentors?action=evaluateForm&amp;classId=<%= trainingClass.getClassId() %>&amp;menteeId=<%= mentee.getUserId() %>">Đánh giá mentee</a></td></tr>
                <% } } else { %><tr><td colspan="4" style="text-align:center">Lớp chưa có nhân viên được ghi danh.</td></tr><% } %>
                </tbody>
            </table></div>
        </section>
        <% } } else { %><div class="card" style="padding:24px">Chưa có lớp đào tạo nào thuộc phòng ban của bạn.</div><% } %>
        <section class="card" style="padding:20px;margin-top:24px">
            <h2 style="margin-top:0">Đánh giá mentee trong phòng ban</h2>
            <% if (evaluations != null && !evaluations.isEmpty()) { for (MentorEvaluation evaluation : evaluations) { %>
                <article style="border-top:1px solid #ddd;padding:14px 0">
                    <b><%= evaluation.getMenteeName() %></b> · <%= evaluation.getPerformanceScore() %>/10 · <%= evaluation.getApprovalStatus() %>
                    <% if (evaluation.getPublicFeedback() != null && !evaluation.getPublicFeedback().trim().isEmpty()) { %>
                        <p style="white-space:pre-line"><%= evaluation.getPublicFeedback() %></p>
                    <% } %>
                    <% if (evaluation.getPrivateFeedback() != null && !evaluation.getPrivateFeedback().trim().isEmpty()) { %>
                        <p style="white-space:pre-line;background:#fff7f7;padding:10px"><b>Ghi chú nội bộ:</b> <%= evaluation.getPrivateFeedback() %></p>
                    <% } %>
                </article>
            <% } } else { %><p>Chưa có đánh giá nào được lưu cho phòng ban này.</p><% } %>
        </section>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
