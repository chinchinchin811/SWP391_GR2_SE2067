<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Vị Trí Công Việc & Cấp Bậc | CPMS");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    Integer selectedDeptId = (Integer) request.getAttribute("selectedDeptId");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <div>
            <h1 style="margin-bottom: 4px;">Tổ Chức Vị Trí Chuyên Môn &amp; Cấp Bậc</h1>
            <p style="color: #64748b; font-size: 13.5px; margin: 0;">
                Quản lý danh mục vị trí công việc theo phòng ban, cấu hình cấp bậc riêng và barem tiêu chuẩn thăng tiến.
            </p>
        </div>
        <div>
            <% if (roleId == 1) { %>
                <a href="<%= request.getContextPath() %>/positions?action=create" class="btn btn-primary">
                    <i class="fa-solid fa-plus"></i> Tạo Vị Trí Mới
                </a>
            <% } else if (roleId == 3) { %>
                <a href="<%= request.getContextPath() %>/positions?action=requestCreate" class="btn btn-primary">
                    <i class="fa-solid fa-paper-plane"></i> Đề Xuất Vị Trí Mới
                </a>
            <% } %>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;">
            <i class="fa-solid fa-circle-check"></i> <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;">
            <i class="fa-solid fa-triangle-exclamation"></i> <%= errorMessage %>
        </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/positions" method="GET" class="filter-box" style="margin-bottom: 20px;">
            <div class="form-group" style="flex: 2; min-width: 240px;">
                <label style="font-weight: 600; font-size: 13px;">Tìm kiếm vị trí:</label>
                <input type="text" name="search" class="form-control" placeholder="Tên vị trí, mô tả nhiệm vụ..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
            </div>

            <div class="form-group" style="min-width: 220px;">
                <label style="font-weight: 600; font-size: 13px;">Lọc theo Phòng Ban:</label>
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
            
            <div style="display: flex; gap: 8px; align-items: flex-end;">
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-filter"></i> Lọc</button>
                <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">Làm mới</a>
            </div>
        </form>

        <!-- BẢNG DANH MỤC VỊ TRÍ TOÀN MÀN HÌNH (FULL WIDTH) -->
        <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden;">
            <div class="card-header" style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                <h2 style="font-size: 16px; margin: 0; color: #1e293b;">
                    <i class="fa-solid fa-id-badge" style="color: #4f46e5; margin-right: 6px;"></i> Danh Mục Vị Trí Chuyên Môn
                </h2>
                <span style="font-size: 13px; color: #64748b; font-weight: 600;">Tổng số: <%= positions != null ? positions.size() : 0 %> vị trí</span>
            </div>
            <div class="card-body" style="padding: 0;">
                <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 13.5px;">
                    <thead>
                        <tr style="background: #f1f5f9; border-bottom: 1px solid #e2e8f0;">
                            <th style="padding: 12px 16px; width: 60px;">ID</th>
                            <th style="padding: 12px 16px;">Tên Vị Trí Chuyên Môn</th>
                            <th style="padding: 12px 16px;">Phòng Ban Phụ Trách</th>
                            <th style="padding: 12px 16px; text-align: center;">Số Nhân Sự</th>
                            <th style="padding: 12px 16px; text-align: center; width: 120px;">Trạng Thái</th>
                            <% if (roleId == 1) { %>
                                <th style="padding: 12px 16px; text-align: center; width: 240px;">Thao Tác</th>
                            <% } else { %>
                                <th style="padding: 12px 16px; text-align: center; width: 140px;">Chi Tiết</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (positions != null && !positions.isEmpty()) {
                                for (Position p : positions) {
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 14px 16px; font-weight: 700; color: #64748b;">#<%= p.getPositionId() %></td>
                            <td style="padding: 14px 16px;">
                                <a href="<%= request.getContextPath() %>/positions?action=detail&amp;id=<%= p.getPositionId() %>" style="color: #1e293b; font-weight: 700; font-size: 14.5px; text-decoration: none;">
                                    <%= p.getPositionName() %>
                                </a>
                                <% if (p.getDescription() != null && !p.getDescription().isEmpty()) { %>
                                <div style="font-size: 12px; color: #64748b; margin-top: 3px;"><%= p.getDescription() %></div>
                                <% } %>
                            </td>
                            <td style="padding: 14px 16px;">
                                <span style="background: #e0e7ff; color: #3730a3; padding: 3px 10px; border-radius: 6px; font-size: 12.5px; font-weight: 600;">
                                    <%= p.getDepartmentName() != null ? p.getDepartmentName() : "Dùng chung" %>
                                </span>
                            </td>
                            <td style="padding: 14px 16px; text-align: center;">
                                <a href="<%= request.getContextPath() %>/employees?positionId=<%= p.getPositionId() %>" style="color: #0284c7; font-weight: 600; text-decoration: none;">
                                    <i class="fa-solid fa-users" style="margin-right: 4px;"></i> <%= p.getEmployeeCount() %> nhân sự
                                </a>
                            </td>
                            <td style="padding: 14px 16px; text-align: center;">
                                <% if (p.isStatus()) { %>
                                <span class="badge badge-success" style="font-size: 11.5px; padding: 4px 10px; background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; border-radius: 20px;">Đang áp dụng</span>
                                <% } else { %>
                                <span class="badge badge-danger" style="font-size: 11.5px; padding: 4px 10px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 20px;">Tạm khóa</span>
                                <% } %>
                            </td>
                            <td style="padding: 14px 16px; text-align: center;">
                                <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                                    <a href="<%= request.getContextPath() %>/positions?action=detail&amp;id=<%= p.getPositionId() %>" 
                                       class="btn btn-sm" style="background: #0284c7; color: #ffffff; padding: 5px 10px; font-size: 12px; border-radius: 4px;" title="Xem chi tiết, danh sách cấp bậc &amp; lộ trình">
                                        <i class="fa-solid fa-circle-info"></i> Chi tiết
                                    </a>
                                    <% if (roleId == 1) { %>
                                        <a href="<%= request.getContextPath() %>/positions?action=criteria&amp;positionId=<%= p.getPositionId() %>" 
                                           class="btn btn-sm" style="background: #4f46e5; color: #ffffff; padding: 5px 10px; font-size: 12px; border-radius: 4px;" title="Cấu hình Barem Thăng Cấp">
                                            <i class="fa-solid fa-stairs"></i> Barem
                                        </a>
                                        <a href="<%= request.getContextPath() %>/positions?action=edit&amp;id=<%= p.getPositionId() %>" 
                                           class="btn btn-sm btn-secondary" style="padding: 5px 10px; font-size: 12px; border-radius: 4px;" aria-label="Sửa vị trí <%= p.getPositionName() %>">
                                            <i class="fa-solid fa-pen"></i> Sửa
                                        </a>
                                        <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline-block; margin: 0;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa vị trí này?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= p.getPositionId() %>">
                                            <button type="submit" class="btn btn-sm btn-danger" style="padding: 5px 10px; font-size: 12px; border-radius: 4px;" aria-label="Xóa vị trí <%= p.getPositionName() %>">
                                                <i class="fa-solid fa-trash"></i> Xóa
                                            </button>
                                        </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="<%= (roleId == 1) ? "6" : "5" %>" style="text-align: center; padding: 30px; color: #94a3b8;">
                                <i class="fa-solid fa-inbox" style="font-size: 32px; display: block; margin-bottom: 8px;"></i>
                                Không tìm thấy vị trí chuyên môn nào phù hợp bộ lọc.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
