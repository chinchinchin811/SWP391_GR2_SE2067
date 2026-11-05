<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Mentor.MentorAssignment" %>
<% 
    List<MentorAssignment> assignments = (List<MentorAssignment>) request.getAttribute("myAssignments"); 
    request.setAttribute("pageTitle", "Danh Sách Mentee Của Tôi | CPMS");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Danh Sách Mentee Của Tôi</h1>
    </div>
    <div class="content-body">
        <div class="card">
            <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
                <h2 style="font-size:16px; margin:0; font-weight:600;">Danh Sách Mentee Được Phân Công</h2>
                <span class="text-secondary" style="font-size:13px;">Tổng: <%= assignments != null ? assignments.size() : 0 %> học viên</span>
            </div>
            <div class="table-responsive">
                <table class="data-table" style="width:100%;">
                    <thead>
                        <tr>
                            <th>Mentee (Học viên)</th>
                            <th>Vị trí &amp; Chuyên môn</th>
                            <th style="text-align: center; width: 160px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (assignments != null && !assignments.isEmpty()) { 
                            for (MentorAssignment a : assignments) { %>
                        <tr>
                            <td>
                                <strong><%= a.getMenteeName() %></strong>
                                <span class="text-secondary" style="font-size:12px;">(<%= a.getMenteeLevel() != null ? a.getMenteeLevel() : "Chưa có cấp" %>)</span>
                            </td>
                            <td><%= a.getPositionName() != null ? a.getPositionName() : "Chưa cập nhật" %></td>
                            <td style="text-align: center;">
                                <% if ("ACTIVE".equalsIgnoreCase(a.getStatus())) { %>
                                <a href="<%= request.getContextPath() %>/mentors?action=evaluateForm&amp;assignmentId=<%= a.getAssignmentId() %>" class="btn btn-sm btn-primary">
                                    <i class="fa-solid fa-pen-to-square"></i> Viết Đánh Giá
                                </a>
                                <% } else { %>
                                <span class="badge badge-status-inactive">Phân công đã kết thúc</span>
                                <% } %>
                            </td>
                        </tr>
                        <%  } 
                           } else { %>
                        <tr>
                            <td colspan="3" style="text-align: center; padding: 32px 16px; color: var(--text-secondary);">
                                <i class="fa-solid fa-user-group" style="font-size: 24px; margin-bottom: 8px; display: block; opacity: 0.5;"></i>
                                Bạn chưa được phân công hướng dẫn Mentee nào.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
