<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Quan ly Phong Ban | HRM");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<User> managerCandidates = (List<User>) request.getAttribute("managerCandidates");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= (roleId == 3) ? "Thông Tin Phòng Ban Phụ Trách" : "Cơ Cấu Tổ Chức Phòng Ban" %></h1>
        <div>
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/departments?action=create" class="btn btn-primary">
                    + Tạo Phòng Ban Mới
                </a>
            <% } %>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger"><%= errorMessage %></div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <h2><%= (roleId == 3) ? "Phòng Ban Của Bạn" : "Danh Sách Phòng Ban & Trưởng Phòng Quản Lý" %></h2>
                <span style="font-size: 12px; color: #555555;">Tong so: <%= departments != null ? departments.size() : 0 %> phòng ban</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 50px;">ID</th>
                            <th>Tên Phòng Ban</th>
                            <th>Trưởng Phòng (Manager)</th>
                            <th>Mô Tả Chức Năng</th>
                            <th>Số Nhân Sự</th>
                            <th>Trạng Thái</th>
                            <% if (roleId == 1 || roleId == 2) { %>
                                <th style="text-align: center; width: 140px;">Thao Tác</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (departments != null && !departments.isEmpty()) {
                                for (Department d : departments) {
                        %>
                        <tr>
                            <td><%= d.getDepartmentId() %></td>
                            <td><b><%= d.getDepartmentName() %></b></td>
                            <td>
                                <% if (roleId == 1 || roleId == 2) { %>
                                    <form action="<%= request.getContextPath() %>/departments" method="POST" style="display: flex; gap: 5px; align-items: center;">
                                        <input type="hidden" name="action" value="assign-manager">
                                        <input type="hidden" name="departmentId" value="<%= d.getDepartmentId() %>">
                                        <select name="managerId" class="form-control" style="padding: 2px 4px; font-size: 11px;" onchange="this.form.submit()">
                                            <option value="0">-- Chưa bổ nhiệm --</option>
                                            <%
                                                if (managerCandidates != null) {
                                                    for (User u : managerCandidates) {
                                                        boolean isSelected = (d.getManagerId() != null && d.getManagerId().equals(u.getUserId()));
                                            %>
                                                <option value="<%= u.getUserId() %>" <%= isSelected ? "selected" : "" %>>
                                                    <%= u.getFullName() %> (<%= u.getRoleName() %>)
                                                </option>
                                            <%
                                                    }
                                                }
                                            %>
                                        </select>
                                    </form>
                                <% } else { %>
                                    <%= d.getManagerName() != null ? d.getManagerName() : "Chưa bổ nhiệm" %>
                                <% } %>
                            </td>
                            <td><%= d.getDescription() != null ? d.getDescription() : "-" %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/employees?departmentId=<%= d.getDepartmentId() %>">
                                    <%= d.getEmployeeCount() %> nhân viên
                                </a>
                            </td>
                            <td>
                                <% if (d.isStatus()) { %>
                                    <span class="badge">Hoạt động</span>
                                <% } else { %>
                                    <span class="badge">Tạm ngưng</span>
                                <% } %>
                            </td>
                            <% if (roleId == 1 || roleId == 2) { %>
                                <td style="text-align: center;">
                                    <a href="<%= request.getContextPath() %>/departments?action=edit&id=<%= d.getDepartmentId() %>" class="btn btn-sm btn-secondary">
                                        Sửa
                                    </a>
                                    <form action="<%= request.getContextPath() %>/departments" method="POST" style="display: inline-block;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa phòng ban này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= d.getDepartmentId() %>">
                                        <button type="submit" class="btn btn-sm btn-danger">Xóa</button>
                                    </form>
                                </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="<%= (roleId == 1 || roleId == 2) ? "7" : "6" %>" style="text-align: center; padding: 15px;">Chưa có phòng ban nào.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
