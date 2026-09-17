<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Vi tri & Cap bac | HRM");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
    Integer selectedDeptId = (Integer) request.getAttribute("selectedDeptId");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>To Chuc Vi Tri Cong Viec & Cap Bac</h1>
        <div>
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/positions?action=create" class="btn btn-primary">
                    + Tao Vi Tri Moi
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

        <form action="<%= request.getContextPath() %>/positions" method="GET" class="filter-box">
            <div class="form-group">
                <label>Loc theo Phong Ban:</label>
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
            <% if (selectedDeptId != null && selectedDeptId > 0) { %>
                <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">Bo loc</a>
            <% } %>
        </form>

        <div style="display: flex; gap: 15px;">
            <div class="card" style="flex: 2;">
                <div class="card-header">
                    <h2>Danh Muc Vi Tri Chuyen Mon</h2>
                    <span style="font-size: 12px; color: #555555;">Tong: <%= positions != null ? positions.size() : 0 %> vi tri</span>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Ten Vi Tri</th>
                                <th>Phong Ban</th>
                                <th>So Nhan Su</th>
                                <th>Trang Thai</th>
                                <% if (roleId == 1 || roleId == 2) { %>
                                    <th style="text-align: center; width: 110px;">Thao Tac</th>
                                <% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (positions != null && !positions.isEmpty()) {
                                    for (Position p : positions) {
                            %>
                            <tr>
                                <td><%= p.getPositionId() %></td>
                                <td>
                                    <b><%= p.getPositionName() %></b>
                                    <% if (p.getDescription() != null && !p.getDescription().isEmpty()) { %>
                                        <div style="font-size: 11px; color: #555555;"><%= p.getDescription() %></div>
                                    <% } %>
                                </td>
                                <td><%= p.getDepartmentName() != null ? p.getDepartmentName() : "Dung chung" %></td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/employees?positionId=<%= p.getPositionId() %>">
                                        <%= p.getEmployeeCount() %> nguoi
                                    </a>
                                </td>
                                <td>
                                    <% if (p.isStatus()) { %>
                                        <span class="badge">Ap dung</span>
                                    <% } else { %>
                                        <span class="badge">Tam khoa</span>
                                    <% } %>
                                </td>
                                <% if (roleId == 1 || roleId == 2) { %>
                                    <td style="text-align: center;">
                                        <a href="<%= request.getContextPath() %>/positions?action=edit&id=<%= p.getPositionId() %>" class="btn btn-sm btn-secondary">Sua</a>
                                        <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline-block;" onsubmit="return confirm('Ban co chac muon xoa vi tri nay?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= p.getPositionId() %>">
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
                                <td colspan="<%= (roleId == 1 || roleId == 2) ? "6" : "5" %>" style="text-align: center; padding: 15px;">Khong co vi tri nao.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Barem Cap Bac (Job Levels)</h2>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Bac</th>
                                <th>Ten Cap Bac</th>
                                <th>Mo Ta</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (jobLevels != null) {
                                    for (JobLevel lvl : jobLevels) {
                            %>
                            <tr>
                                <td><b><%= lvl.getRankOrder() %></b></td>
                                <td><b><%= lvl.getLevelName() %></b></td>
                                <td><%= lvl.getDescription() %></td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
