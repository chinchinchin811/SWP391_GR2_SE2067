<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.TrainingClass,model.User" %>
<% 
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("classes"); 
    User currentUser = (User) session.getAttribute("currentUser"); 
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3; 
    request.setAttribute("pageTitle", "Quản lý lớp đào tạo | HRM"); 
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Quản Lý Lớp Đào Tạo</h1>
        <div>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Kho học liệu</a>
            <% if (canManage) { %>
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=classCreate">+ Mở lớp mới</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <div class="card">
            <div class="card-header">
                <h2>Danh Sách Lớp Đào Tạo</h2>
                <span>Tổng: <%= classes != null ? classes.size() : 0 %> lớp</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Mã lớp</th>
                            <th>Tên lớp</th>
                            <th>Mentor</th>
                            <th>Thời gian</th>
                            <th>Học viên</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (classes != null && !classes.isEmpty()) { 
                            for (TrainingClass c : classes) { %>
                            <tr>
                                <td><%= c.getClassCode() %></td>
                                <td><b><%= c.getClassName() %></b></td>
                                <td><%= c.getMentorName() != null ? c.getMentorName() : "Chưa phân công" %></td>
                                <td><%= c.getStartDate() %></td>
                                <td><%= c.getEnrollmentCount() %></td>
                                <td><span class="badge"><%= c.getStatus() %></span></td>
                                <td>
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= c.getClassId() %>">Chi tiết</a>
                                    <% if (canManage) { %>
                                        <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classAssign&id=<%= c.getClassId() %>">Gán nhân sự</a>
                                    <% } %>
                                </td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr><td colspan="7" style="text-align:center">Chưa có lớp đào tạo.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
