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
            <% if (roleId == 1) { %>
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
                            <th>Trưởng Phòng</th>
                            <th>Mô Tả Chức Năng</th>
                            <th>Số Nhân Sự</th>
                            <th>Trạng Thái</th>
                            <% if (roleId == 1) { %>
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
                                <% boolean hasManager = (d.getManagerName() != null && !d.getManagerName().trim().isEmpty() && !"Chưa bổ nhiệm".equalsIgnoreCase(d.getManagerName().trim())); %>
                                <% if (hasManager) { %>
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
                                    <% if (roleId == 1 || roleId == 2) { %>
                                    <div style="display: flex; align-items: center; justify-content: center;">
                                        <button type="button" class="btn btn-sm btn-primary" style="padding: 4px 12px; font-size: 12px; font-weight: 500;"
                                                title="Bổ nhiệm Trưởng phòng cho phòng ban này"
                                                onclick="openAssignModal(<%= d.getDepartmentId() %>, '<%= d.getDepartmentName().replace("'", "\\'") %>', 0)">
                                            <i class="fa-solid fa-user-plus"></i> Bổ nhiệm
                                        </button>
                                    </div>
                                    <% } else { %>
                                    <div style="text-align: center; color: #94a3b8; font-size: 13px;">Chưa bổ nhiệm</div>
                                    <% } %>
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
                            <% if (roleId == 1) { %>
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
                            <td colspan="<%= roleId == 1 ? "7" : "6" %>" style="text-align: center; padding: 15px;">Chưa có phòng ban nào.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<%-- MODAL BỔ NHIỆM TRƯỞNG PHÒNG DÀNH CHO HR VÀ ADMIN --%>
<% if (roleId == 1 || roleId == 2) { %>
<div id="assignManagerModalOverlay" style="display: none; position: fixed; inset: 0; z-index: 99999; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); justify-content: center; align-items: center; padding: 20px;">
    <div style="background: #ffffff; width: 540px; max-width: 100%; border-radius: 12px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; animation: modalFadeIn 0.2s ease;">
        <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 34px; height: 34px; border-radius: 8px; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-size: 15px;">
                    <i class="fa-solid fa-user-tie"></i>
                </div>
                <div>
                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0f172a;">Bổ Nhiệm Trưởng Phòng</h3>
                    <div id="modalDeptSubtitle" style="font-size: 12px; color: #64748b; margin-top: 2px;">Phòng ban: -</div>
                </div>
            </div>
            <button type="button" onclick="closeAssignModal()" style="border: none; background: transparent; font-size: 18px; color: #94a3b8; cursor: pointer; padding: 4px;">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        
        <form action="<%= request.getContextPath() %>/departments" method="POST" style="margin: 0;">
            <input type="hidden" name="action" value="assign-manager">
            <input type="hidden" id="modalDeptId" name="departmentId" value="">
            
            <div style="padding: 20px;">
                <div style="margin-bottom: 14px;">
                    <label style="display: block; font-weight: 600; font-size: 13.5px; color: #334155; margin-bottom: 6px;">Chọn nhân sự bổ nhiệm:</label>
                    <select id="modalManagerSelect" name="managerId" class="form-control" style="width: 100%; padding: 9px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13.5px;">
                        <option value="0">-- Miễn nhiệm / Chưa bổ nhiệm --</option>
                        <%
                            if (managerCandidates != null) {
                                for (User u : managerCandidates) {
                                    if (u.getRoleId() == 1) continue;
                        %>
                        <option value="<%= u.getUserId() %>">
                            <%= u.getFullName() %> (<%= u.getRoleName() %><%= u.getPositionName() != null ? " - " + u.getPositionName() : "" %><%= u.getLevelName() != null ? ", " + u.getLevelName() : "" %>)
                        </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                <div style="padding: 10px 12px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 6px; font-size: 12px; color: #166534; line-height: 1.5;">
                    <i class="fa-solid fa-circle-info" style="margin-right: 4px;"></i>
                    Hệ thống chỉ hiển thị những nhân sự đang làm việc và <strong>chưa phụ trách phòng ban nào khác</strong>.
                </div>
            </div>
            
            <div style="padding: 12px 20px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeAssignModal()">Hủy</button>
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check"></i> Lưu Bổ Nhiệm</button>
            </div>
        </form>
    </div>
</div>

<script>
function openAssignModal(deptId, deptName, currentManagerId) {
    document.getElementById('modalDeptId').value = deptId;
    document.getElementById('modalDeptSubtitle').innerText = 'Phòng ban: ' + deptName;
    var select = document.getElementById('modalManagerSelect');
    if (select) {
        select.value = currentManagerId ? currentManagerId : "0";
    }
    var modal = document.getElementById('assignManagerModalOverlay');
    if (modal) {
        modal.style.display = 'flex';
    }
}
function closeAssignModal() {
    var modal = document.getElementById('assignManagerModalOverlay');
    if (modal) {
        modal.style.display = 'none';
    }
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeAssignModal();
});
</script>
<% } %>

<jsp:include page="/views/common/footer.jsp" />
