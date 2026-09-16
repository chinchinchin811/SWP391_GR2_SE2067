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
        <h1><%= (roleId == 3) ? "Thong Tin Phong Ban Phu Trach" : "Co Cau To Chuc Phong Ban" %></h1>
        <div>
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/departments?action=create" class="btn btn-primary">
                    + Tao Phong Ban Moi
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
                <h2><%= (roleId == 3) ? "Phong Ban Cua Ban" : "Danh Sach Phong Ban & Truong Phong Quan Ly" %></h2>
                <span style="font-size: 12px; color: #555555;">Tong so: <%= departments != null ? departments.size() : 0 %> phong ban</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 50px;">ID</th>
                            <th>Ten Phong Ban</th>
                            <th>Truong Phong (Manager)</th>
                            <th>Mo Ta Chuc Nang</th>
                            <th>So Nhan Su</th>
                            <th>Trang Thai</th>
                            <% if (roleId == 1 || roleId == 2) { %>
                                <th style="text-align: center; width: 140px;">Thao Tac</th>
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
                                            <option value="0">-- Chua bo nhiem --</option>
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
                                    <%= d.getManagerName() != null ? d.getManagerName() : "Chua bo nhiem" %>
                                <% } %>
                            </td>
                            <td><%= d.getDescription() != null ? d.getDescription() : "-" %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/employees?departmentId=<%= d.getDepartmentId() %>">
                                    <%= d.getEmployeeCount() %> nhan vien
                                </a>
                            </td>
                            <td>
                                <% if (d.isStatus()) { %>
                                    <span class="badge">Hoat dong</span>
                                <% } else { %>
                                    <span class="badge">Tam ngung</span>
                                <% } %>
                            </td>
                            <% if (roleId == 1 || roleId == 2) { %>
                                <td style="text-align: center;">
                                    <a href="<%= request.getContextPath() %>/departments?action=edit&id=<%= d.getDepartmentId() %>" class="btn btn-sm btn-secondary">
                                        Sua
                                    </a>
                                    <form action="<%= request.getContextPath() %>/departments" method="POST" style="display: inline-block;" onsubmit="return confirm('Ban co chac chan muon xoa phong ban nay?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= d.getDepartmentId() %>">
                                        <button type="submit" class="btn btn-sm btn-danger">Xoa</button>
                                    </form>
                                </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="<%= (roleId == 1 || roleId == 2) ? "7" : "6" %>" style="text-align: center; padding: 15px;">Chua co phong ban nao.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
