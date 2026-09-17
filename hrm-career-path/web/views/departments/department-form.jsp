<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.User" %>
<%
    Department dept = (Department) request.getAttribute("department");
    boolean isEdit = (dept != null && dept.getDepartmentId() > 0);
    request.setAttribute("pageTitle", (isEdit ? "Chinh sua Phong Ban" : "Tao Phong Ban Moi") + " | HRM");
    List<User> managerCandidates = (List<User>) request.getAttribute("managerCandidates");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cap Nhat Phong Ban" : "Tao Phong Ban Moi" %></h1>
        <div>
            <a href="<%= request.getContextPath() %>/departments" class="btn btn-secondary">
                Quay lai danh sach
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header">
                <h2>Thong Tin Phong Ban</h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/departments" method="POST">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="departmentId" value="<%= dept.getDepartmentId() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="departmentName">Ten Phong Ban (*):</label>
                        <input type="text" id="departmentName" name="departmentName" class="form-control" 
                               value="<%= dept != null && dept.getDepartmentName() != null ? dept.getDepartmentName() : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label for="managerId">Truong Phong (Manager):</label>
                        <select id="managerId" name="managerId" class="form-control">
                            <option value="0">-- Chua bo nhiem --</option>
                            <%
                                if (managerCandidates != null) {
                                    for (User u : managerCandidates) {
                                        boolean isSelected = (dept != null && dept.getManagerId() != null && dept.getManagerId().equals(u.getUserId()));
                            %>
                                <option value="<%= u.getUserId() %>" <%= isSelected ? "selected" : "" %>>
                                    <%= u.getFullName() %> (<%= u.getRoleName() %>)
                                </option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="description">Mo Ta Chuc Nang:</label>
                        <textarea id="description" name="description" class="form-control" rows="3"><%= dept != null && dept.getDescription() != null ? dept.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="status">Trang Thai:</label>
                        <select id="status" name="status" class="form-control">
                            <option value="1" <%= (dept == null || dept.isStatus()) ? "selected" : "" %>>Dang hoat dong</option>
                            <option value="0" <%= (dept != null && !dept.isStatus()) ? "selected" : "" %>>Tam ngung</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/departments" class="btn btn-secondary">Huy</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Luu Thay Doi" : "Tao Phong Ban" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
