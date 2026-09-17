<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.Position" %>
<%@ page import="model.Role" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Danh sach Nhan vien | HRM");
    List<User> employees = (List<User>) request.getAttribute("employees");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<Role> roles = (List<Role>) request.getAttribute("roles");

    String search = (String) request.getAttribute("search");
    Integer selectedDeptId = (Integer) request.getAttribute("selectedDeptId");
    Integer selectedPosId = (Integer) request.getAttribute("selectedPosId");
    Integer selectedRoleId = (Integer) request.getAttribute("selectedRoleId");

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= (roleId == 3) ? "Nhan Su Truc Thuoc Phong Ban" : "Quan Ly Danh Sach Nhan Su" %></h1>
        <div>
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/employees?action=create" class="btn btn-primary">
                    + Khai Bao Nhan Vien Moi
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

        <form action="<%= request.getContextPath() %>/employees" method="GET" class="filter-box">
            <div class="form-group" style="flex: 2;">
                <label>Tim kiem:</label>
                <input type="text" name="search" class="form-control" placeholder="Ten, Email, SDT, Username..." 
                       value="<%= search != null ? search : "" %>">
            </div>

            <% if (roleId == 1 || roleId == 2) { %>
                <div class="form-group">
                    <label>Phong Ban:</label>
                    <select name="departmentId" class="form-control" onchange="this.form.submit()">
                        <option value="0">-- Tat ca Phong Ban --</option>
                        <%
                            if (departments != null) {
                                for (Department d : departments) {
                                    boolean isSel = (selectedDeptId != null && selectedDeptId.equals(d.getDepartmentId()));
                        %>
                            <option value="<%= d.getDepartmentId() %>" <%= isSel ? "selected" : "" %>><%= d.getDepartmentName() %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
            <% } %>

            <div class="form-group">
                <label>Vi Tri:</label>
                <select name="positionId" class="form-control" onchange="this.form.submit()">
                    <option value="0">-- Tat ca Vi Tri --</option>
                    <%
                        if (positions != null) {
                            for (Position p : positions) {
                                boolean isSel = (selectedPosId != null && selectedPosId.equals(p.getPositionId()));
                    %>
                        <option value="<%= p.getPositionId() %>" <%= isSel ? "selected" : "" %>><%= p.getPositionName() %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>

            <% if (roleId == 1 || roleId == 2) { %>
                <div class="form-group">
                    <label>Vai Tro:</label>
                    <select name="roleId" class="form-control" onchange="this.form.submit()">
                        <option value="0">-- Tat ca Vai Tro --</option>
                        <%
                            if (roles != null) {
                                for (Role r : roles) {
                                    boolean isSel = (selectedRoleId != null && selectedRoleId.equals(r.getRoleId()));
                        %>
                            <option value="<%= r.getRoleId() %>" <%= isSel ? "selected" : "" %>><%= r.getRoleName() %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
            <% } %>

            <div style="display: flex; gap: 5px;">
                <button type="submit" class="btn btn-primary">Loc</button>
                <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">Lam moi</a>
            </div>
        </form>

        <div class="card">
            <div class="card-header">
                <h2><%= (roleId == 3) ? "Danh Sach Nhan Vien Trong Phong" : "Danh Sach Nhan Vien Toan Cong Ty" %></h2>
                <span style="font-size: 12px; color: #555555;">Tong: <%= employees != null ? employees.size() : 0 %> nhan su</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 40px;">ID</th>
                            <th>Nhan Vien</th>
                            <th>Lien He</th>
                            <th>Phong Ban</th>
                            <th>Vi Tri & Cap Bac</th>
                            <th>Vai Tro</th>
                            <th>Trang Thai</th>
                            <th style="text-align: center; width: <%= (roleId == 1 || roleId == 2) ? "200px" : "80px" %>;">Thao Tac</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (employees != null && !employees.isEmpty()) {
                                for (User emp : employees) {
                        %>
                        <tr>
                            <td><%= emp.getUserId() %></td>
                            <td>
                                <b><%= emp.getFullName() %></b>
                                <div style="font-size: 11px; color: #555555;">@<%= emp.getUsername() %></div>
                            </td>
                            <td>
                                <div><%= emp.getEmail() %></div>
                                <div style="font-size: 11px; color: #555555;"><%= emp.getPhone() != null ? emp.getPhone() : "" %></div>
                            </td>
                            <td><%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "-" %></td>
                            <td>
                                <%= emp.getPositionName() != null ? emp.getPositionName() : "-" %>
                                <% if (emp.getLevelName() != null) { %>
                                    (<%= emp.getLevelName() %>)
                                <% } %>
                            </td>
                            <td><span class="badge"><%= emp.getRoleName() %></span></td>
                            <td>
                                <% if (emp.isStatus()) { %>
                                    <span class="badge">Dang lam viec</span>
                                <% } else { %>
                                    <span class="badge">Da nghi viec</span>
                                <% } %>
                            </td>
                            <td style="text-align: center;">
                                <% if (roleId == 1 || roleId == 2) { %>
                                    <a href="<%= request.getContextPath() %>/employees?action=assign&id=<%= emp.getUserId() %>" class="btn btn-sm btn-primary">
                                        Doi vi tri
                                    </a>
                                    <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= emp.getUserId() %>" class="btn btn-sm btn-secondary">
                                        Xem
                                    </a>
                                    <a href="<%= request.getContextPath() %>/employees?action=edit&id=<%= emp.getUserId() %>" class="btn btn-sm btn-secondary">
                                        Sua
                                    </a>
                                <% } else { %>
                                    <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= emp.getUserId() %>" class="btn btn-sm btn-secondary">
                                        Xem
                                    </a>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 15px;">Khong tim thay nhan vien nao.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
