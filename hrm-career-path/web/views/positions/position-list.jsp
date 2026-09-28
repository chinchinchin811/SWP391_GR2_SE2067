<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Vị trí & Cấp bậc | HRM");
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
        <h1>Tổ Chức Vị Trí Công Việc & Cấp Bậc</h1>
        <div>
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/positions?action=create" class="btn btn-primary">
                    + Tạo Vị Trí Mới
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
                <label>Lọc theo Phòng Ban:</label>
                <select name="departmentId" class="form-control" onchange="this.form.submit()">
                    <option value="0">-- Tất cả Phòng Ban --</option>
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
                <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">Bỏ lọc</a>
            <% } %>
        </form>

        <div style="display: flex; gap: 15px;">
            <div class="card" style="flex: 2;">
                <div class="card-header">
                    <h2>Danh Mục Vị Trí Chuyên Môn</h2>
                    <span style="font-size: 12px; color: #555555;">Tổng: <%= positions != null ? positions.size() : 0 %> vị trí</span>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Tên Vị Trí</th>
                                <th>Phòng Ban</th>
                                <th>Số Nhân Sự</th>
                                <th>Trạng Thái</th>
                                <% if (roleId == 1 || roleId == 2) { %>
                                    <th style="text-align: center; width: 110px;">Thao Tác</th>
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
                                <td><%= p.getDepartmentName() != null ? p.getDepartmentName() : "Dùng chung" %></td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/employees?positionId=<%= p.getPositionId() %>">
                                        <%= p.getEmployeeCount() %> người
                                    </a>
                                </td>
                                <td>
                                    <% if (p.isStatus()) { %>
                                        <span class="badge">Áp dụng</span>
                                    <% } else { %>
                                        <span class="badge">Tạm khóa</span>
                                    <% } %>
                                </td>
                                    <td>
                                        <div class="table-actions">
                                            <a href="<%= request.getContextPath() %>/positions?action=edit&amp;id=<%= p.getPositionId() %>" class="btn btn-sm btn-edit" aria-label="Sửa vị trí <%= p.getPositionName() %>">Sửa</a>
                                            <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline-block;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa vị trí này?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="<%= p.getPositionId() %>">
                                                <button type="submit" class="btn btn-sm btn-danger" aria-label="Xóa vị trí <%= p.getPositionName() %>">Xóa</button>
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
                                <td colspan="<%= (roleId == 1 || roleId == 2) ? "6" : "5" %>" style="text-align: center; padding: 15px;">Không có vị trí nào.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Barem Cấp Bậc (Job Levels)</h2>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Bậc</th>
                                <th>Tên Cấp Bậc</th>
                                <th>Mô Tả</th>
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
