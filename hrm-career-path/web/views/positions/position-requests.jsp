<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.PositionRequest" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    private String escapeAttr(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    List<PositionRequest> requests = (List<PositionRequest>) request.getAttribute("requests");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    Integer selectedDeptId = (Integer) request.getAttribute("selectedDeptId");
    String searchKeyword = (String) request.getAttribute("searchKeyword");

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    request.setAttribute("pageTitle", "Duyệt Đề Xuất Vị Trí | HRM");

    int pendingCount = 0;
    if (requests != null) {
        for (PositionRequest r : requests) {
            if ("PENDING".equalsIgnoreCase(r.getStatus())) {
                pendingCount++;
            }
        }
    }
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>
            <% if (roleId == 3) { %>
                <i class="fa-solid " style="color: var(--primary);"></i> Đề Xuất Vị Trí Của Phòng Ban
            <% } else { %>
                <i class="fa-solid" style="color: var(--primary);"></i> Duyệt Đề Xuất Vị Trí Chuyên Môn
            <% } %>
        </h1>
        <div style="display: flex; gap: 8px;">
            <% if (roleId == 3) { %>
                <a href="<%= request.getContextPath() %>/positions?action=requestCreate" class="btn btn-primary">
                    <i class="fa-solid fa-plus"></i> Tạo Đề Xuất Vị Trí Mới
                </a>
            <% } %>
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary" title="Xem danh mục vị trí và cấp bậc hiện có">
                <i class="fa-solid fa-id-badge"></i> Xem Vị Trí Hiện Có
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i> <%= successMessage %>
            </div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i> <%= errorMessage %>
            </div>
        <% } %>

        <%-- Hộp lọc & Tìm kiếm (Filter Box chuẩn phong cách HR) --%>
        <form action="<%= request.getContextPath() %>/positions" method="GET" class="filter-box">
            <input type="hidden" name="action" value="<%= roleId == 3 ? "myRequests" : "requests" %>">

            <div class="form-group" style="flex: 2; min-width: 200px;">
                <label>Tìm kiếm đề xuất:</label>
                <input type="text" name="search" class="form-control" placeholder="Tên vị trí, người đề xuất, lý do..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
            </div>

            <% if (roleId == 1 || roleId == 2) { %>
            <div class="form-group">
                <label>Phòng Ban:</label>
                <select name="departmentId" class="form-control" onchange="this.form.submit()">
                    <option value="0">-- Tất cả Phòng Ban --</option>
                    <% if (departments != null) {
                        for (Department d : departments) {
                            boolean isSel = (selectedDeptId != null && selectedDeptId.equals(d.getDepartmentId()));
                    %>
                    <option value="<%= d.getDepartmentId() %>" <%= isSel ? "selected" : "" %>><%= d.getDepartmentName() %></option>
                    <% } } %>
                </select>
            </div>
            <% } %>

            <div class="form-group">
                <label>Trạng Thái:</label>
                <select name="status" class="form-control" onchange="this.form.submit()">
                    <option value="ALL">-- Tất cả Trạng Thái --</option>
                    <option value="PENDING" <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Chờ duyệt (PENDING)</option>
                    <option value="APPROVED" <%= "APPROVED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Đã duyệt (APPROVED)</option>
                    <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Từ chối (REJECTED)</option>
                </select>
            </div>

            <div style="display: flex; gap: 6px;">
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-filter"></i> Lọc</button>
                <a href="<%= request.getContextPath() %>/positions?action=<%= roleId == 3 ? "myRequests" : "requests" %>" class="btn btn-secondary">Làm mới</a>
            </div>
        </form>

        <%-- Bảng Danh Sách Đề Xuất (Card & Data Table) --%>
        <div class="card">
            <div class="card-header">
                <h2>
                    <%= (roleId == 3) ? "Các Yêu Cầu Vị Trí Đã Đề Xuất" : "Danh Sách Đề Xuất Vị Trí Chuyên Môn" %>
                </h2>
                <div style="display: flex; gap: 8px; align-items: center;">
                    <% if (pendingCount > 0) { %>
                        <span class="badge" style="background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa;">
                            <i class="fa-solid fa-clock"></i> <%= pendingCount %> yêu cầu chờ duyệt
                        </span>
                    <% } %>
                    <span style="font-size: 12px; color: #64748b;">
                        Tổng số: <b><%= requests != null ? requests.size() : 0 %></b> yêu cầu
                    </span>
                </div>
            </div>
            <div class="card-body" style="padding: 0;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 55px; text-align: center;">Mã</th>
                            <th>Vị Trí Đề Xuất</th>
                            <th>Phòng Ban</th>
                            <th>Người Đề Xuất</th>
                            <th>Lý Do Đề Xuất</th>
                            <th style="text-align: center;">Trạng Thái</th>
                            <th style="text-align: center; width: 150px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (requests != null && !requests.isEmpty()) {
                            for (PositionRequest r : requests) {
                                String status = r.getStatus() != null ? r.getStatus().toUpperCase() : "PENDING";
                        %>
                            <tr class="request-table-row" 
                                style="cursor: pointer;"
                                data-id="<%= r.getRequestId() %>"
                                data-posname="<%= escapeAttr(r.getPositionName()) %>"
                                data-deptname="<%= escapeAttr(r.getDepartmentName()) %>"
                                data-manager="<%= escapeAttr(r.getManagerName()) %>"
                                data-created="<%= r.getCreatedAt() != null ? sdf.format(r.getCreatedAt()) : "" %>"
                                data-reason="<%= escapeAttr(r.getReason()) %>"
                                data-desc="<%= escapeAttr(r.getDescription()) %>"
                                data-status="<%= status %>"
                                data-reviewer="<%= escapeAttr(r.getReviewerName()) %>"
                                data-reviewedat="<%= r.getReviewedAt() != null ? sdf.format(r.getReviewedAt()) : "" %>"
                                data-decisionnote="<%= escapeAttr(r.getDecisionNote()) %>"
                                onclick="handleRowClick(event, this)">
                                
                                <td style="text-align: center; font-weight: 700; color: #475569;">
                                    #<%= r.getRequestId() %>
                                </td>
                                <td>
                                    <div class="user-fullname" style="font-size: 13.5px; color: #0f172a;">
                                        <%= r.getPositionName() %>
                                    </div>
                                    <% if (r.getDescription() != null && !r.getDescription().trim().isEmpty()) { 
                                        String descSnippet = r.getDescription().trim();
                                        if (descSnippet.length() > 55) {
                                            descSnippet = descSnippet.substring(0, 52) + "...";
                                        }
                                    %>
                                        <div class="user-sub" style="margin-top: 2px;"><%= descSnippet %></div>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge" style="background: #eef2ff; color: #4338ca; border-color: #c7d2fe;">
                                        <i class="fa-regular fa-building"></i> <%= r.getDepartmentName() %>
                                    </span>
                                </td>
                                <td>
                                    <div class="user-cell">
                                        <div class="avatar-sm">
                                            <%= r.getManagerName() != null && !r.getManagerName().trim().isEmpty() ? r.getManagerName().trim().substring(0, 1).toUpperCase() : "M" %>
                                        </div>
                                        <div>
                                            <div class="user-fullname"><%= r.getManagerName() %></div>
                                            <div class="user-sub"><i class="fa-regular fa-clock"></i> <%= r.getCreatedAt() != null ? sdf.format(r.getCreatedAt()) : "" %></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div style="font-size: 12.5px; color: #334155; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%= escapeAttr(r.getReason()) %>">
                                        <%= r.getReason() != null ? r.getReason() : "-" %>
                                    </div>
                                </td>
                                <td style="text-align: center;">
                                    <% if ("APPROVED".equalsIgnoreCase(status)) { %>
                                        <span class="badge badge-status-active">
                                            <i class="fa-solid fa-circle-check"></i> Đã duyệt
                                        </span>
                                    <% } else if ("REJECTED".equalsIgnoreCase(status)) { %>
                                        <span class="badge badge-status-inactive">
                                            <i class="fa-solid fa-circle-xmark"></i> Từ chối
                                        </span>
                                    <% } else { %>
                                        <span class="badge" style="background: #fff7ed; color: #c2410c; border-color: #fed7aa; font-weight: 600;">
                                            <i class="fa-solid fa-clock"></i> Chờ duyệt
                                        </span>
                                    <% } %>
                                </td>
                                <td style="text-align: center;">
                                    <button type="button" class="btn btn-sm <%= "PENDING".equalsIgnoreCase(status) ? "btn-action-assign" : "btn-action-view" %>" onclick="event.stopPropagation(); openModalFromRow(this.closest('tr'))">
                                        <% if ("PENDING".equalsIgnoreCase(status) && (roleId == 1 || roleId == 2)) { %>
                                            <i class="fa-solid fa-clipboard-check"></i> Xét duyệt
                                        <% } else { %>
                                            <i class="fa-regular fa-eye"></i> Xem chi tiết
                                        <% } %>
                                    </button>
                                </td>
                            </tr>
                        <%  }
                        } else { %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 36px 15px; color: #64748b;">
                                    <i class="fa-regular fa-folder-open" style="font-size: 28px; color: #94a3b8; display: block; margin-bottom: 8px;"></i>
                                    Không tìm thấy đề xuất vị trí nào phù hợp.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<%-- ==========================================================================
     POP-UP MODAL CHI TIẾT & XÉT DUYỆT ĐỀ XUẤT VỊ TRÍ (Modern Dialog)
     ========================================================================== --%>
<div id="requestModalOverlay" style="display: none; position: fixed; inset: 0; z-index: 99999; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); justify-content: center; align-items: center; padding: 20px;">
    <div style="background: #ffffff; width: 620px; max-width: 100%; max-height: 90vh; border-radius: 12px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; animation: modalFadeIn 0.2s ease;">
        
        <%-- Modal Header --%>
        <div style="padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 36px; height: 36px; border-radius: 8px; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-size: 16px;">
                    <i class="fa-solid fa-file-signature"></i>
                </div>
                <div>
                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0f172a;">Chi Tiết Đề Xuất Vị Trí</h3>
                    <div style="display: flex; gap: 6px; align-items: center; margin-top: 3px;">
                        <span id="modalRequestBadge" style="font-size: 11px; font-weight: 700; color: #64748b;">#0</span>
                        <span id="modalStatusBadge" class="badge">Trạng thái</span>
                    </div>
                </div>
            </div>
            <button type="button" onclick="closeRequestModal()" style="border: none; background: transparent; font-size: 18px; color: #94a3b8; cursor: pointer; padding: 4px; border-radius: 6px; transition: color 0.15s;" onmouseover="this.style.color='#0f172a'" onmouseout="this.style.color='#94a3b8'">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <%-- Modal Scrollable Body --%>
        <div style="padding: 20px 24px; overflow-y: auto; flex: 1;">
            
            <%-- Thông tin cơ bản --%>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; background: #f8fafc; padding: 14px 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                <div>
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 3px;">Vị Trí Đề Xuất</label>
                    <div id="modalPosName" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
                </div>
                <div>
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 3px;">Phòng Ban Trực Thuộc</label>
                    <div id="modalDeptName" style="font-size: 13.5px; font-weight: 600; color: #4338ca;">-</div>
                </div>
                <div>
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 3px;">Trưởng Phòng Đề Xuất</label>
                    <div id="modalManager" style="font-size: 13.5px; font-weight: 600; color: #334155;">-</div>
                </div>
                <div>
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 3px;">Thời Gian Gửi</label>
                    <div id="modalCreated" style="font-size: 12.5px; color: #64748b;">-</div>
                </div>
            </div>

            <%-- Lý do đề xuất --%>
            <div style="margin-bottom: 16px;">
                <label style="font-size: 12px; font-weight: 700; color: #334155; display: flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                    <i class="fa-solid fa-lightbulb" style="color: #f59e0b;"></i> Lý Do Cần Mở Vị Trí Này:
                </label>
                <div id="modalReason" style="font-size: 13px; line-height: 1.6; color: #1e293b; background: #fffbeb; border: 1px solid #fef3c7; padding: 12px 14px; border-radius: 8px; white-space: pre-wrap;">-</div>
            </div>

            <%-- Mô tả công việc --%>
            <div style="margin-bottom: 18px;">
                <label style="font-size: 12px; font-weight: 700; color: #334155; display: flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                    <i class="fa-solid fa-briefcase" style="color: #6366f1;"></i> Bản Mô Tả Công Việc Dự Kiến:
                </label>
                <div id="modalDesc" style="font-size: 13px; line-height: 1.6; color: #334155; background: #f8fafc; border: 1px solid #e2e8f0; padding: 12px 14px; border-radius: 8px; white-space: pre-wrap;">-</div>
            </div>

            <%-- Kết quả đã xét duyệt (Hiển thị khi đề xuất đã được APPROVED hoặc REJECTED) --%>
            <div id="modalReviewResultBox" style="display: none; margin-bottom: 16px; padding: 14px 16px; border-radius: 8px; border: 1px solid #e2e8f0; background: #f8fafc;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                    <label style="font-size: 12px; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 6px;">
                        <i class="fa-solid fa-stamp" style="color: #0284c7;"></i> Kết Quả Xét Duyệt Của Quản Trị Viên:
                    </label>
                    <span id="modalReviewTime" style="font-size: 11.5px; color: #64748b;">-</span>
                </div>
                <div style="font-size: 12.5px; color: #475569; margin-bottom: 4px;">
                    Người xét duyệt: <b id="modalReviewer">-</b>
                </div>
                <div id="modalDecisionNote" style="font-size: 13px; line-height: 1.5; color: #0f172a; padding: 10px 12px; border-radius: 6px; background: #ffffff; border: 1px solid #cbd5e1; margin-top: 6px;">-</div>
            </div>

            <%-- Form Xét Duyệt (Chỉ dành cho Admin / HR khi đề xuất đang PENDING) --%>
            <% if (roleId == 1 || roleId == 2) { %>
            <div id="modalReviewFormBox" style="display: none; border-top: 2px dashed #cbd5e1; padding-top: 16px; margin-top: 16px;">
                <h4 style="margin: 0 0 10px 0; font-size: 13.5px; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 6px;">
                    <i class="fa-solid fa-gavel" style="color: var(--primary);"></i> Lựa Chọn Quyết Định Của Quản Trị Viên:
                </h4>
                
                <form id="reviewActionForm" action="<%= request.getContextPath() %>/positions" method="POST">
                    <input type="hidden" name="action" value="reviewRequest">
                    <input type="hidden" name="requestId" id="formRequestId" value="">
                    <input type="hidden" name="status" id="formStatus" value="">

                    <div class="form-group" style="margin-bottom: 14px;">
                        <label style="font-size: 12px; font-weight: 600; color: #334155; margin-bottom: 4px; display: block;">
                            Ý kiến / Lý do giải trình gửi tới Trưởng phòng:
                        </label>
                        <textarea name="decisionNote" id="formDecisionNote" rows="3" class="form-control" style="width: 100%; font-size: 12.5px; resize: vertical;" placeholder="Nhập ghi chú phê duyệt hoặc lý do từ chối (bắt buộc khi từ chối)..."></textarea>
                    </div>

                    <div style="display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="button" class="btn btn-secondary" onclick="closeRequestModal()">Đóng</button>
                        
                        <button type="button" class="btn btn-danger" onclick="submitDecision('REJECTED')">
                            <i class="fa-solid fa-xmark"></i> Từ Chối Đề Xuất
                        </button>

                        <button type="button" class="btn btn-primary" style="background: #16a34a; border-color: #15803d;" onclick="submitDecision('APPROVED')">
                            <i class="fa-solid fa-check"></i> Phê Duyệt &amp; Tạo Vị Trí
                        </button>
                    </div>
                </form>
            </div>
            <% } %>

        </div>

        <%-- Modal Footer (nếu đã duyệt hoặc là role khác) --%>
        <div id="modalDefaultFooter" style="padding: 12px 24px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end;">
            <button type="button" class="btn btn-secondary" onclick="closeRequestModal()">Đóng cửa sổ</button>
        </div>

    </div>
</div>

<style>
@keyframes modalFadeIn {
    from { opacity: 0; transform: scale(0.96); }
    to { opacity: 1; transform: scale(1); }
}
.request-table-row:hover {
    background-color: #f1f5f9 !important;
}
</style>

<script>
function handleRowClick(event, row) {
    // Nếu người dùng không click vào button thì vẫn mở modal
    if (!event.target.closest('button') && !event.target.closest('a')) {
        openModalFromRow(row);
    }
}

function openModalFromRow(row) {
    if (!row) return;

    var id = row.getAttribute('data-id');
    var posName = row.getAttribute('data-posname');
    var deptName = row.getAttribute('data-deptname');
    var manager = row.getAttribute('data-manager');
    var created = row.getAttribute('data-created');
    var reason = row.getAttribute('data-reason');
    var desc = row.getAttribute('data-desc');
    var status = row.getAttribute('data-status');
    var reviewer = row.getAttribute('data-reviewer');
    var reviewedAt = row.getAttribute('data-reviewedat');
    var decisionNote = row.getAttribute('data-decisionnote');

    document.getElementById('modalRequestBadge').innerText = '#' + id;
    document.getElementById('modalPosName').innerText = posName || '-';
    document.getElementById('modalDeptName').innerText = deptName || '-';
    document.getElementById('modalManager').innerText = manager || '-';
    document.getElementById('modalCreated').innerText = created || '-';
    document.getElementById('modalReason').innerText = reason || 'Không có lý do được cung cấp.';
    document.getElementById('modalDesc').innerText = desc || 'Chưa có bản mô tả chi tiết.';

    // Set Status Badge
    var statusBadge = document.getElementById('modalStatusBadge');
    if (status === 'APPROVED') {
        statusBadge.className = 'badge badge-status-active';
        statusBadge.innerHTML = '<i class="fa-solid fa-circle-check"></i> Đã phê duyệt';
    } else if (status === 'REJECTED') {
        statusBadge.className = 'badge badge-status-inactive';
        statusBadge.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> Đã từ chối';
    } else {
        statusBadge.className = 'badge';
        statusBadge.style.background = '#fff7ed';
        statusBadge.style.color = '#c2410c';
        statusBadge.style.borderColor = '#fed7aa';
        statusBadge.innerHTML = '<i class="fa-solid fa-clock"></i> Chờ xem xét (PENDING)';
    }

    var resultBox = document.getElementById('modalReviewResultBox');
    var formBox = document.getElementById('modalReviewFormBox');
    var defaultFooter = document.getElementById('modalDefaultFooter');

    if (status === 'PENDING') {
        if (resultBox) resultBox.style.display = 'none';
        if (formBox) {
            formBox.style.display = 'block';
            document.getElementById('formRequestId').value = id;
            document.getElementById('formDecisionNote').value = '';
            if (defaultFooter) defaultFooter.style.display = 'none';
        } else {
            if (defaultFooter) defaultFooter.style.display = 'flex';
        }
    } else {
        if (formBox) formBox.style.display = 'none';
        if (resultBox) {
            resultBox.style.display = 'block';
            document.getElementById('modalReviewer').innerText = reviewer || 'Quản trị viên';
            document.getElementById('modalReviewTime').innerText = reviewedAt || '';
            document.getElementById('modalDecisionNote').innerText = decisionNote || 'Không có ghi chú giải trình.';
        }
        if (defaultFooter) defaultFooter.style.display = 'flex';
    }

    document.getElementById('requestModalOverlay').style.display = 'flex';
}

function closeRequestModal() {
    document.getElementById('requestModalOverlay').style.display = 'none';
}

// Bấm phím Escape để đóng modal
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeRequestModal();
    }
});

// Bấm ra ngoài hộp thoại để đóng modal
document.getElementById('requestModalOverlay').addEventListener('click', function(event) {
    if (event.target === this) {
        closeRequestModal();
    }
});

function submitDecision(status) {
    var noteInput = document.getElementById('formDecisionNote');
    var note = noteInput ? noteInput.value.trim() : '';

    if (status === 'REJECTED') {
        if (!note) {
            alert('Vui lòng nhập lý do giải trình khi từ chối đề xuất vị trí để Trưởng phòng nắm rõ thông tin!');
            noteInput.focus();
            return;
        }
        if (!confirm('Bạn có chắc chắn muốn TỪ CHỐI đề xuất vị trí này không?')) {
            return;
        }
    } else if (status === 'APPROVED') {
        if (!confirm('Xác nhận PHÊ DUYỆT đề xuất này?\nHệ thống sẽ tự động tạo Vị trí mới vào Phòng ban tương ứng.')) {
            return;
        }
        if (!note) {
            noteInput.value = 'Đã duyệt đề xuất tạo vị trí mới.';
        }
    }

    document.getElementById('formStatus').value = status;
    document.getElementById('reviewActionForm').submit();
}
</script>

<jsp:include page="/views/common/footer.jsp" />
