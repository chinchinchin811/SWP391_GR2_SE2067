<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.*" %>
<%
    TrainingClass trainingClass = (TrainingClass) request.getAttribute("trainingClass");
    List<ClassEnrollment> enrollments = (List<ClassEnrollment>) request.getAttribute("enrollments");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    String successMessage = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
    request.setAttribute("pageTitle", "Chi tiết lớp đào tạo | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Chi Tiết Lớp Đào Tạo</h1>
        <div>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Quay lại danh sách</a>
            <% if (canManage) { %>
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=classAssign&id=<%= trainingClass.getClassId() %>">+ Thêm học viên</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (successMessage != null) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>
        <div class="card">
            <div class="card-header">
                <h2><%= trainingClass.getClassName() %></h2>
                <span class="badge"><%= trainingClass.getStatus() %></span>
            </div>
            <div class="card-body">
                <p><b>Mã lớp:</b> <%= trainingClass.getClassCode() %></p>
                <p><b>Mentor:</b> <%= trainingClass.getMentorName() != null ? trainingClass.getMentorName() : "Chưa phân công" %></p>
                <p><b>Mô tả:</b> <%= trainingClass.getDescription() != null ? trainingClass.getDescription() : "-" %></p>
                <p><b>Thời gian:</b> <%= trainingClass.getStartDate() %> - <%= trainingClass.getEndDate() != null ? trainingClass.getEndDate() : "Chưa xác định" %></p>
            </div>
        </div>
        <div class="card">
            <div class="card-header">
                <h2>Học Liệu Theo Lộ Trình</h2>
            </div>
            <div class="card-body">
                <% if (trainingClass.getMaterials() != null && !trainingClass.getMaterials().isEmpty()) { %>
                    <ol>
                        <% for (LearningMaterial m : trainingClass.getMaterials()) { %>
                            <li style="margin-bottom:6px">
                                <a href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>">
                                    <b><%= m.getTitle() %></b>
                                </a> (<%= m.getMaterialType() %>)
                            </li>
                        <% } %>
                    </ol>
                <% } else { %>
                    Lớp chưa có học liệu.
                <% } %>
            </div>
        </div>
        <div class="card">
            <div class="card-header">
                <h2>Danh Sách Học Viên</h2>
                <span>Tổng: <%= enrollments != null ? enrollments.size() : 0 %> học viên</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Học viên</th>
                            <th>Thông tin ghi danh</th>
                            <% if (canManage) { %><th>Thao tác</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (enrollments != null && !enrollments.isEmpty()) { 
                            for (ClassEnrollment e : enrollments) { %>
                            <tr>
                                <td><b><%= e.getUserName() %></b></td>
                                <td><%= e.getAssignedReason() != null ? e.getAssignedReason() : "Ghi danh thủ công" %></td>
                                <% if (canManage) { %>
                                    <td>
                                        <form method="post" action="<%= request.getContextPath() %>/materials" style="display:inline" onsubmit="return confirm('Xóa học viên khỏi lớp?')">
                                            <input type="hidden" name="action" value="deleteEnrollment">
                                            <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                                            <input type="hidden" name="enrollmentId" value="<%= e.getEnrollmentId() %>">
                                            <button class="btn btn-sm btn-danger">Xóa khỏi lớp</button>
                                        </form>
                                    </td>
                                <% } %>
                            </tr>
                        <% } 
                        } else { %>
                            <tr><td colspan="<%= canManage ? "3" : "2" %>" style="text-align:center">Chưa có học viên trong lớp.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
