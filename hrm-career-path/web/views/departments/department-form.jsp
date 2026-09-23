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
                Quay lại danh sách
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header">
                <h2>Thông Tin Phòng Ban</h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/departments" method="POST">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="departmentId" value="<%= dept.getDepartmentId() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="departmentName">Tên Phòng Ban (*):</label>
                        <input type="text" id="departmentName" name="departmentName" class="form-control" 
                               value="<%= dept != null && dept.getDepartmentName() != null ? dept.getDepartmentName() : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label for="managerId">Trưởng Phòng (Manager):</label>
                        <select id="managerId" name="managerId" class="form-control">
                            <option value="0">-- Chưa bổ nhiệm --</option>
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
                        <label for="description">Mô Tả Chức Năng:</label>
                        <textarea id="description" name="description" class="form-control" rows="3"><%= dept != null && dept.getDescription() != null ? dept.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng Thái:</label>
                        <select id="status" name="status" class="form-control">
                            <option value="1" <%= (dept == null || dept.isStatus()) ? "selected" : "" %>>Đang hoạt động</option>
                            <option value="0" <%= (dept != null && !dept.isStatus()) ? "selected" : "" %>>Tạm ngưng</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/departments" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Lưu Thay Đổi" : "Tạo Phòng Ban" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
