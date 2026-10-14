<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.PositionRequest" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    List<PositionRequest> requests = (List<PositionRequest>) request.getAttribute("requests");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    request.setAttribute("pageTitle", "Đề xuất & Phê duyệt Vị trí | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>
            <% if (roleId == 3) { %>
                <i class="fa-solid fa-paper-plane"></i> Đề Xuất Vị Trí Của Phòng Ban
            <% } else { %>
                <i class="fa-solid fa-clipboard-check"></i> Danh Sách Đề Xuất Vị Trí Chuyên Môn
            <% } %>
        </h1>
        <div>
            <% if (roleId == 3) { %>
                <a href="<%= request.getContextPath() %>/positions?action=requestCreate" class="btn btn-primary">
                    + Tạo Đề Xuất Vị Trí Mới
                </a>
            <% } %>
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">
                Xem Vị Trí Hiện Có
            </a>
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
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h2>Danh Sách Đề Xuất</h2>
                <span class="badge" style="background: #e3f2fd; color: #0d47a1; padding: 5px 10px;">
                    Tổng cộng: <%= requests != null ? requests.size() : 0 %> yêu cầu
                </span>
            </div>
            <div class="card-body" style="padding: 0;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: center;">Mã</th>
                            <th>Vị trí đề xuất</th>
                            <th>Phòng ban</th>
                            <th>Người đề xuất</th>
                            <th>Lý do đề xuất (Reason)</th>
                            <th style="text-align: center;">Trạng thái</th>
                            <th>Giải trình quyết định (Explain Decision)</th>
                            <% if (roleId == 1 || roleId == 2) { %>
                                <th style="text-align: center; width: 170px;">Thao tác duyệt</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (requests != null && !requests.isEmpty()) {
                            for (PositionRequest r : requests) {
                                String statusColor = "#f57c00"; // PENDING
                                String statusBg = "#fff3e0";
                                String statusText = "Chờ duyệt (PENDING)";
                                if ("APPROVED".equalsIgnoreCase(r.getStatus())) {
                                    statusColor = "#2e7d32";
                                    statusBg = "#e8f5e9";
                                    statusText = "Đã duyệt (APPROVED)";
                                } else if ("REJECTED".equalsIgnoreCase(r.getStatus())) {
                                    statusColor = "#c62828";
                                    statusBg = "#ffebee";
                                    statusText = "Từ chối (REJECTED)";
                                }
                        %>
                            <tr>
                                <td style="text-align: center; font-weight: bold;">#<%= r.getRequestId() %></td>
                                <td>
                                    <b style="font-size: 14px; color: #000;"><%= r.getPositionName() %></b>
                                    <% if (r.getDescription() != null && !r.getDescription().isEmpty()) { %>
                                        <div style="font-size: 12px; color: #666; margin-top: 2px;"><%= r.getDescription() %></div>
                                    <% } %>
                                </td>
                                <td><span class="badge" style="background: #f0f0f0;"><%= r.getDepartmentName() %></span></td>
                                <td>
                                    <b><%= r.getManagerName() %></b>
                                    <div style="font-size: 11px; color: #888;"><%= r.getCreatedAt() != null ? sdf.format(r.getCreatedAt()) : "" %></div>
                                </td>
                                <td style="font-size: 13px; max-width: 250px;">
                                    <%= r.getReason() %>
                                </td>
                                <td style="text-align: center;">
                                    <span style="display: inline-block; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; background: <%= statusBg %>; color: <%= statusColor %>; border: 1px solid <%= statusColor %>;">
                                        <%= statusText %>
                                    </span>
                                </td>
                                <td style="font-size: 12.5px; max-width: 250px;">
                                    <% if (r.getDecisionNote() != null && !r.getDecisionNote().trim().isEmpty()) { %>
                                        <div style="background: #fafafa; padding: 6px 10px; border-left: 3px solid <%= statusColor %>; border-radius: 2px;">
                                            <b><%= r.getReviewerName() != null ? r.getReviewerName() : "Quản trị viên" %>:</b><br>
                                            <span style="color: #444;"><%= r.getDecisionNote() %></span>
                                        </div>
                                    <% } else { %>
                                        <span style="color: #999; font-style: italic;">Chưa có giải trình</span>
                                    <% } %>
                                </td>
                                <% if (roleId == 1 || roleId == 2) { %>
                                    <td style="text-align: center;">
                                        <% if ("PENDING".equalsIgnoreCase(r.getStatus())) { %>
                                            <div style="display: flex; gap: 5px; justify-content: center;">
                                                <!-- Nút Duyệt -->
                                                <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Xác nhận PHÊ DUYỆT đề xuất này? Hệ thống sẽ tự động tạo Vị trí mới.')">
                                                    <input type="hidden" name="action" value="reviewRequest">
                                                    <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                                                    <input type="hidden" name="status" value="APPROVED">
                                                    <input type="hidden" name="decisionNote" value="Đã duyệt đề xuất tạo vị trí mới">
                                                    <button type="submit" class="btn btn-sm btn-primary" style="background: #2e7d32; border-color: #2e7d32; padding: 4px 8px;">
                                                        <i class="fa-solid fa-check"></i> Duyệt
                                                    </button>
                                                </form>

                                                <!-- Nút Từ chối kèm lý do (Explain decision) -->
                                                <button type="button" class="btn btn-sm btn-danger" style="padding: 4px 8px;" onclick="openRejectModal(<%= r.getRequestId() %>, '<%= r.getPositionName().replace("'", "\\'") %>')">
                                                    <i class="fa-solid fa-xmark"></i> Từ chối
                                                </button>
                                            </div>
                                        <% } else { %>
                                            <span style="font-size: 11px; color: #888;">Đã xử lý</span>
                                        <% } %>
                                    </td>
                                <% } %>
                            </tr>
                        <%  }
                           } else { %>
                            <tr>
                                <td colspan="<%= (roleId == 1 || roleId == 2) ? 8 : 7 %>" style="text-align: center; padding: 30px; color: #888;">
                                    Hiện chưa có đề xuất vị trí nào.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- Modal Từ Chối kèm Giải trình quyết định (Explain Decision Modal) -->
<div id="rejectModal" style="display: none; position: fixed; z-index: 9999; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center;">
    <div style="background: #fff; padding: 25px; border-radius: 6px; width: 450px; max-width: 90%; box-shadow: 0 4px 15px rgba(0,0,0,0.3);">
        <h3 style="margin-top: 0; color: #c62828;">
            <i class="fa-solid fa-triangle-exclamation"></i> Giải trình từ chối đề xuất (Explain Decision)
        </h3>
        <p id="rejectModalTitle" style="font-size: 13.5px; color: #555; margin-bottom: 15px;"></p>
        <form action="<%= request.getContextPath() %>/positions" method="POST">
            <input type="hidden" name="action" value="reviewRequest">
            <input type="hidden" name="requestId" id="modalRequestId">
            <input type="hidden" name="status" value="REJECTED">
            <div class="form-group" style="margin-bottom: 15px;">
                <label style="font-weight: bold; font-size: 13px;">Lý do từ chối gửi tới Trưởng phòng (*):</label>
                <textarea name="decisionNote" rows="4" class="form-control" style="width: 100%; font-size: 13px;" placeholder="Ví dụ: Chưa phù hợp với ngân sách quý này / Đã có vị trí tương đương đảm nhiệm..." required></textarea>
            </div>
            <div style="text-align: right; gap: 8px; display: flex; justify-content: flex-end;">
                <button type="button" class="btn btn-secondary" onclick="closeRejectModal()">Hủy bỏ</button>
                <button type="submit" class="btn btn-danger">Xác nhận từ chối</button>
            </div>
        </form>
    </div>
</div>

<script>
function openRejectModal(id, name) {
    document.getElementById('modalRequestId').value = id;
    document.getElementById('rejectModalTitle').innerText = 'Từ chối vị trí đề xuất: "' + name + '"';
    document.getElementById('rejectModal').style.display = 'flex';
}
function closeRejectModal() {
    document.getElementById('rejectModal').style.display = 'none';
}
</script>

<jsp:include page="/views/common/footer.jsp" />
