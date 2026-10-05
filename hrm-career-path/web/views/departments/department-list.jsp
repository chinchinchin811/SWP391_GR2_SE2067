<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Quản lý Phòng Ban | HRM");
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
            <% if (roleId == 2) { %>
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
                <span style="font-size: 12px; color: #555555;">Tổng số: <%= departments != null ? departments.size() : 0 %> phòng ban</span>
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
                            <% if (roleId == 2) { %>
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
                                <% if (d.getManagerName() != null && !d.getManagerName().trim().isEmpty() && !"Chưa bổ nhiệm".equalsIgnoreCase(d.getManagerName().trim())) { %>
                                    <div class="user-cell">
                                        <div class="avatar-sm">
                                            <%= d.getManagerName().substring(0, 1).toUpperCase() %>
                                        </div>
                                        <div>
                                            <div class="user-fullname"><%= d.getManagerName() %></div>
                                            <div class="user-sub"><span class="badge badge-manager" style="font-size: 10px; padding: 1px 6px;">Trưởng phòng</span></div>
                                        </div>
                                    </div>
                                <% } else { %>
                                    <span class="badge" style="background: #f1f5f9; color: #64748b; border-color: #e2e8f0;">
                                        <i class="fa-regular fa-clock" style="font-size: 10px;"></i> Chưa bổ nhiệm
                                    </span>
                                <% } %>
                            </td>
                            <td><%= d.getDescription() != null ? d.getDescription() : "-" %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/employees?departmentId=<%= d.getDepartmentId() %>" style="color: var(--primary); font-weight: 600; text-decoration: none;">
                                    <i class="fa-solid fa-users" style="font-size: 11px; margin-right: 4px;"></i> <%= d.getEmployeeCount() %> nhân sự
                                </a>
                            </td>
                            <td>
                                <% if (d.isStatus()) { %>
                                    <span class="badge badge-status-active"><i class="fa-solid fa-circle status-dot"></i> Hoạt động</span>
                                <% } else { %>
                                    <span class="badge badge-status-inactive"><i class="fa-solid fa-circle status-dot"></i> Tạm ngưng</span>
                                <% } %>
                            </td>
                            <% if (roleId == 2) { %>
                                <td>
                                    <div class="table-actions">
                                        <a href="<%= request.getContextPath() %>/departments?action=edit&amp;id=<%= d.getDepartmentId() %>" class="btn btn-sm btn-action-edit" aria-label="Sửa phòng ban <%= d.getDepartmentName() %>">
                                            <i class="fa-regular fa-pen-to-square"></i> <span>Sửa</span>
                                        </a>
                                        <form action="<%= request.getContextPath() %>/departments" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn xóa phòng ban này?');" style="margin: 0; display: inline-flex;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= d.getDepartmentId() %>">
                                            <button type="submit" class="btn btn-sm btn-danger" aria-label="Xóa phòng ban <%= d.getDepartmentName() %>">
                                                <i class="fa-regular fa-trash-can"></i> <span>Xóa</span>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="<%= roleId == 2 ? "7" : "6" %>" style="text-align: center; padding: 15px;">Chưa có phòng ban nào.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
