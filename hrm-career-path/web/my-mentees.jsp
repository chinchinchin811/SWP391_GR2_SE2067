<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Mentor.MentorAssignment" %>
<% List<MentorAssignment> assignments = (List<MentorAssignment>) request.getAttribute("myAssignments"); %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar"><h1>Danh Sách Mentee Của Tôi</h1></div>
    <div class="content-body">
        <div class="card" style="border: 1px solid #000; padding: 20px;">
            <table class="data-table" style="width: 100%; border-collapse: collapse; border: 1px solid #000;">
                <tr style="background: #f0f0f0; text-align: left;">
                    <th style="padding: 8px; border: 1px solid #000;">Mentee (Học viên)</th>
                    <th style="padding: 8px; border: 1px solid #000;">Vị trí & Chuyên môn</th>
                    <th style="padding: 8px; border: 1px solid #000; text-align: center;">Thao tác</th>
                </tr>
                <% if (assignments != null && !assignments.isEmpty()) { 
                    for (MentorAssignment a : assignments) { %>
                    <tr>
                        <td style="padding: 8px; border: 1px solid #000;"><b><%= a.getMenteeName() %></b> (<%= a.getMenteeLevel() != null ? a.getMenteeLevel() : "Chưa có cấp" %>)</td>
                        <td style="padding: 8px; border: 1px solid #000;"><%= a.getPositionName() != null ? a.getPositionName() : "" %></td>
                        <td style="padding: 8px; border: 1px solid #000; text-align: center;">
                            <a href="<%= request.getContextPath() %>/mentors?action=evaluateForm&assignmentId=<%= a.getAssignmentId() %>" class="btn btn-sm btn-primary" style="background: #000; color: #fff; padding: 5px 10px; text-decoration: none;">Viết Đánh Giá</a>
                        </td>
                    </tr>
                <% }} else { %>
                    <tr><td colspan="3" style="text-align: center; padding: 15px; border: 1px solid #000;">Bạn chưa được phân công hướng dẫn Mentee nào.</td></tr>
                <% } %>
            </table>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />