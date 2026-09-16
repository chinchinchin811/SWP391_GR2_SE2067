<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.Position" %>
<%
    Position pos = (Position) request.getAttribute("position");
    boolean isEdit = (pos != null && pos.getPositionId() > 0);
    request.setAttribute("pageTitle", (isEdit ? "Chinh sua Vi tri" : "Tao Vi tri Moi") + " | HRM");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cap Nhat Vi Tri" : "Tao Vi Tri Moi" %></h1>
        <div>
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">
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
                <h2>Thong Tin Vi Tri Chuyen Mon</h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/positions" method="POST">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="positionName">Ten Vi Tri / Chuc Danh (*):</label>
                        <input type="text" id="positionName" name="positionName" class="form-control" 
                               value="<%= pos != null && pos.getPositionName() != null ? pos.getPositionName() : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label for="departmentId">Phong Ban:</label>
                        <select id="departmentId" name="departmentId" class="form-control">
                            <option value="0">-- Vi tri dung chung toan cong ty --</option>
                            <%
                                if (departments != null) {
                                    for (Department d : departments) {
                                        boolean isSel = (pos != null && pos.getDepartmentId() != null && pos.getDepartmentId().equals(d.getDepartmentId()));
                            %>
                                <option value="<%= d.getDepartmentId() %>" <%= isSel ? "selected" : "" %>><%= d.getDepartmentName() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="description">Mo Ta Chuyen Mon:</label>
                        <textarea id="description" name="description" class="form-control" rows="3"><%= pos != null && pos.getDescription() != null ? pos.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="status">Trang Thai:</label>
                        <select id="status" name="status" class="form-control">
                            <option value="1" <%= (pos == null || pos.isStatus()) ? "selected" : "" %>>Dang ap dung</option>
                            <option value="0" <%= (pos != null && !pos.isStatus()) ? "selected" : "" %>>Tam khoa</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">Huy</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Luu Thay Doi" : "Tao Vi Tri" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
