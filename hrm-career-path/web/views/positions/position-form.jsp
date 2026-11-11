<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.Position" %>
<%
    Position pos = (Position) request.getAttribute("position");
    boolean isEdit = (pos != null && pos.getPositionId() > 0);
    request.setAttribute("pageTitle", (isEdit ? "Chỉnh sửa Vị trí" : "Tạo Vị trí Mới") + " | CPMS");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cập Nhật Vị Trí" : "Tạo Vị Trí Mới" %></h1>
        <div>
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">
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
                <h2>Thông Tin Vị Trí Chuyên Môn</h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/positions" method="POST" onsubmit="return validatePositionForm()">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                    <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="departmentId">Phòng Ban (*):</label>
                        <select id="departmentId" name="departmentId" class="form-control" required>
                            <option value="">-- Chọn Phòng Ban --</option>
                            <%
                                if (departments != null) {
                                    for (Department d : departments) {
                                        boolean isSel = (pos != null && pos.getDepartmentId() != null && pos.getDepartmentId().equals(d.getDepartmentId()));
                                        boolean isInactive = !d.isStatus();
                            %>
                            <option value="<%= d.getDepartmentId() %>" 
                                    data-status="<%= d.isStatus() %>"
                                    <%= isSel ? "selected" : "" %>
                                    <%= (isInactive && !isSel) ? "disabled style='color: #94a3b8; background-color: #f1f5f9;'" : "" %>>
                                <%= d.getDepartmentName() %><%= isInactive ? " (Tạm ngưng)" : "" %>
                            </option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="positionName">Tên Vị Trí Trong Phòng Ban (*):</label>
                        <input type="text" id="positionName" name="positionName" class="form-control" 
                               value="<%= pos != null && pos.getPositionName() != null ? pos.getPositionName() : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô Tả Chuyên Môn:</label>
                        <textarea id="description" name="description" class="form-control" rows="3"><%= pos != null && pos.getDescription() != null ? pos.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng Thái:</label>
                        <select id="status" name="status" class="form-control">
                            <option value="1" <%= (pos == null || pos.isStatus()) ? "selected" : "" %>>Đang áp dụng</option>
                            <option value="0" <%= (pos != null && !pos.isStatus()) ? "selected" : "" %>>Tạm khóa</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Lưu Thay Đổi" : "Tạo Vị Trí" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<script>
function validatePositionForm() {
    var deptSelect = document.getElementById("departmentId");
    if (!deptSelect || !deptSelect.value || deptSelect.value.trim() === "" || deptSelect.value === "0") {
        alert("Vui lòng chọn Phòng ban cho vị trí chuyên môn!");
        if (deptSelect) deptSelect.focus();
        return false;
    }
    var selectedOpt = deptSelect.options[deptSelect.selectedIndex];
    if (selectedOpt && selectedOpt.getAttribute("data-status") === "false") {
        alert("Phòng ban '" + selectedOpt.text.replace("(Tạm ngưng)", "").trim() + "' đang ở trạng thái Tạm ngưng! Không thể tạo vị trí cho phòng ban này.");
        if (deptSelect) deptSelect.focus();
        return false;
    }
    var nameInput = document.getElementById("positionName");
    if (!nameInput || !nameInput.value || !nameInput.value.trim()) {
        alert("Vui lòng nhập Tên vị trí trong phòng ban!");
        if (nameInput) nameInput.focus();
        return false;
    }
    return true;
}
</script>

<jsp:include page="/views/common/footer.jsp" />
