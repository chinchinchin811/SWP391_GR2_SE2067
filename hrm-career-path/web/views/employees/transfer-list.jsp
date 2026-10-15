<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.TransferRequest" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String viewRole = (String) request.getAttribute("viewRole");
    if (viewRole == null) viewRole = "EMPLOYEE";
    List<TransferRequest> requests = (List<TransferRequest>) request.getAttribute("requests");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
    
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    request.setAttribute("pageTitle", "Quản Lý Đề Xuất Điều Chuyển | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>
            <% if ("EMPLOYEE".equals(viewRole)) { %>
                <i class="fa-solid"></i> Nguyện Vọng Điều Chuyển Của Tôi
            <% } else if ("MANAGER".equals(viewRole)) { %>
                <i class="fa-solid"></i> Duyệt Đề Xuất Điều Chuyển Phòng Ban
            <% } else { %>
                <i class="fa-solid"></i> Thực Hiện Điều Chuyển Nhân Sự
            <% } %>
        </h1>
        <div>
            <% if ("EMPLOYEE".equals(viewRole)) { %>
                <a href="<%= request.getContextPath() %>/transfer?action=requestCreate" class="btn btn-primary">
                    <i class="fa-solid fa-paper-plane"></i> + Gửi Đề Xuất Điều Chuyển
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
                <h2>Danh Sách Yêu Cầu Điều Chuyển</h2>
                <span style="font-size: 12px; color: #64748b;">Tổng cộng: <%= requests != null ? requests.size() : 0 %> yêu cầu</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 50px;">Mã</th>
                            <% if (!"EMPLOYEE".equals(viewRole)) { %>
                                <th>Nhân Sự</th>
                            <% } %>
                            <th>Hiện Tại</th>
                            <th>Nguyện Vọng Chuyển Đến</th>
                            <th>Lý Do Đề Xuất</th>
                            <th>Trưởng Phòng Duyệt</th>
                            <th>HR Xử Lý</th>
                            <% if ("MANAGER".equals(viewRole) || "HR".equals(viewRole)) { %>
                                <th style="text-align: center; width: 150px;">Thao Tác</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (requests != null && !requests.isEmpty()) {
                                for (TransferRequest req : requests) {
                        %>
                        <tr>
                            <td>#<%= req.getRequestId() %></td>
                            <% if (!"EMPLOYEE".equals(viewRole)) { %>
                                <td>
                                    <b><%= req.getEmployeeName() %></b><br>
                                    <small style="color: #64748b;"><%= req.getEmployeeEmail() %></small>
                                </td>
                            <% } %>
                            <td>
                                <b><%= req.getCurrentDepartmentName() %></b><br>
                                <span class="badge" style="font-size: 11px;"><%= req.getCurrentPositionName() != null ? req.getCurrentPositionName() : "Chưa có vị trí" %></span>
                            </td>
                            <td>
                                <b style="color: var(--primary);"><i class="fa-solid fa-arrow-right"></i> <%= req.getTargetDepartmentName() %></b><br>
                                <span class="badge badge-primary" style="font-size: 11px;"><%= req.getTargetPositionName() != null ? req.getTargetPositionName() : "Tùy HR sắp xếp" %></span>
                            </td>
                            <td>
                                <div style="max-width: 260px; font-size: 12px; color: #334155;">
                                    <%= req.getReason() %>
                                </div>
                                <small style="color: #94a3b8;"><%= req.getCreatedAt() != null ? sdf.format(req.getCreatedAt()) : "" %></small>
                            </td>

                            <!-- Trưởng phòng duyệt -->
                            <td>
                                <% if ("PENDING".equals(req.getManagerStatus())) { %>
                                    <span class="badge" style="background: #fef3c7; color: #b45309; border: 1px solid #fde68a;">
                                        <i class="fa-regular fa-clock"></i> Chờ TP duyệt
                                    </span>
                                <% } else if ("APPROVED".equals(req.getManagerStatus())) { %>
                                    <span class="badge badge-status-active">
                                        <i class="fa-solid fa-check"></i> TP Đồng ý
                                    </span>
                                    <% if (req.getManagerNote() != null && !req.getManagerNote().isEmpty()) { %>
                                        <div style="font-size: 11px; color: #475569; margin-top: 3px;"><i>"<%= req.getManagerNote() %>"</i></div>
                                    <% } %>
                                <% } else { %>
                                    <span class="badge badge-status-inactive">
                                        <i class="fa-solid fa-xmark"></i> TP Từ chối
                                    </span>
                                    <% if (req.getManagerNote() != null && !req.getManagerNote().isEmpty()) { %>
                                        <div style="font-size: 11px; color: #dc2626; margin-top: 3px;"><i>"<%= req.getManagerNote() %>"</i></div>
                                    <% } %>
                                <% } %>
                            </td>

                            <!-- HR xử lý -->
                            <td>
                                <% if ("COMPLETED".equals(req.getHrStatus())) { %>
                                    <span class="badge" style="background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0;">
                                        <i class="fa-solid fa-check-double"></i> Đã điều chuyển
                                    </span>
                                <% } else if ("PENDING".equals(req.getHrStatus())) { %>
                                    <span class="badge" style="background: #e0e7ff; color: #4338ca; border: 1px solid #c7d2fe;">
                                        <i class="fa-solid fa-hourglass-half"></i> Chờ HR thực thi
                                    </span>
                                <% } else if ("REJECTED".equals(req.getHrStatus())) { %>
                                    <span class="badge badge-status-inactive">
                                        <i class="fa-solid fa-xmark"></i> HR Từ chối
                                    </span>
                                <% } else { %>
                                    <span style="color: #94a3b8; font-size: 12px;">Đang đợi TP</span>
                                <% } %>
                                <% if (req.getHrNote() != null && !req.getHrNote().isEmpty()) { %>
                                    <div style="font-size: 11px; color: #475569; margin-top: 3px;"><i>"<%= req.getHrNote() %>"</i></div>
                                <% } %>
                            </td>

                            <!-- Thao tác cho Manager hoặc HR -->
                            <% if ("MANAGER".equals(viewRole)) { %>
                                <td style="text-align: center;">
                                    <% if ("PENDING".equals(req.getManagerStatus())) { %>
                                        <div style="display: flex; gap: 4px; justify-content: center;">
                                            <button type="button" class="btn btn-sm btn-action-edit" onclick="openManagerModal(<%= req.getRequestId() %>, 'APPROVED', '<%= req.getEmployeeName() %>')">
                                                <i class="fa-solid fa-check"></i> Duyệt
                                            </button>
                                            <button type="button" class="btn btn-sm btn-danger" onclick="openManagerModal(<%= req.getRequestId() %>, 'REJECTED', '<%= req.getEmployeeName() %>')">
                                                <i class="fa-solid fa-xmark"></i> Từ chối
                                            </button>
                                        </div>
                                    <% } else { %>
                                        <span style="color: #94a3b8; font-size: 11px;">Đã xử lý</span>
                                    <% } %>
                                </td>
                            <% } else if ("HR".equals(viewRole)) { %>
                                <td style="text-align: center;">
                                    <% if ("APPROVED".equals(req.getManagerStatus()) && "PENDING".equals(req.getHrStatus())) { %>
                                        <div style="display: flex; gap: 4px; justify-content: center;">
                                            <button type="button" class="btn btn-sm btn-primary" onclick="openHrModal(<%= req.getRequestId() %>, '<%= req.getEmployeeName() %>', '<%= req.getTargetDepartmentName() %>', '<%= req.getTargetPositionName() != null ? req.getTargetPositionName() : "" %>')">
                                                <i class="fa-solid fa-arrows-rotate"></i> Điều chuyển
                                            </button>
                                            <button type="button" class="btn btn-sm btn-danger" onclick="openHrRejectModal(<%= req.getRequestId() %>, '<%= req.getEmployeeName() %>')">
                                                Từ chối
                                            </button>
                                        </div>
                                    <% } else if ("COMPLETED".equals(req.getHrStatus())) { %>
                                        <span style="color: #16a34a; font-weight: 600; font-size: 12px;"><i class="fa-solid fa-check-circle"></i> Hoàn tất</span>
                                    <% } else { %>
                                        <span style="color: #94a3b8; font-size: 11px;">Chưa sẵn sàng</span>
                                    <% } %>
                                </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 20px; color: #64748b;">
                                Không có yêu cầu điều chuyển nào.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- MODAL DUYỆT CỦA TRƯỞNG PHÒNG -->
<div id="managerModal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;">
    <div style="background: #fff; width: 480px; border-radius: 8px; padding: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.2);">
        <h3 id="managerModalTitle" style="margin-top: 0; margin-bottom: 15px; color: #1e293b;">Duyệt Nguyện Vọng Điều Chuyển</h3>
        <form action="<%= request.getContextPath() %>/transfer" method="POST">
            <input type="hidden" name="action" value="managerReview">
            <input type="hidden" id="mgrModalReqId" name="requestId" value="">
            <input type="hidden" id="mgrModalStatus" name="status" value="">
            
            <div class="form-group" style="margin-bottom: 15px;">
                <label id="mgrNoteLabel" for="managerNote" style="font-weight: 600;">Ý kiến đánh giá năng lực của Trưởng phòng:</label>
                <textarea id="managerNote" name="managerNote" class="form-control" rows="4" placeholder="Nhập nhận xét hoặc lý do duyệt/từ chối..."></textarea>
            </div>
            
            <div style="display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn btn-secondary" onclick="closeManagerModal()">Hủy</button>
                <button type="submit" id="mgrModalSubmitBtn" class="btn btn-primary">Xác Nhận</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL THỰC HIỆN ĐIỀU CHUYỂN CỦA HR -->
<div id="hrModal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;">
    <div style="background: #fff; width: 500px; border-radius: 8px; padding: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.2);">
        <h3 style="margin-top: 0; margin-bottom: 15px; color: #1e293b;">Xác Nhận Thực Hiện Điều Chuyển</h3>
        <form action="<%= request.getContextPath() %>/transfer" method="POST">
            <input type="hidden" name="action" value="hrExecute">
            <input type="hidden" id="hrModalReqId" name="requestId" value="">
            <input type="hidden" name="status" value="COMPLETED">
            
            <p id="hrModalDesc" style="font-size: 13px; color: #475569; margin-bottom: 15px;"></p>

            <div class="form-group" style="margin-bottom: 15px;">
                <label for="levelId" style="font-weight: 600;">Xác định Cấp bậc (Job Level) tại vị trí mới (*):</label>
                <select id="levelId" name="levelId" class="form-control" required>
                    <option value="">-- Chọn Cấp Bậc --</option>
                    <%
                        if (jobLevels != null) {
                            for (JobLevel jl : jobLevels) {
                    %>
                        <option value="<%= jl.getLevelId() %>"><%= jl.getLevelName() %> (Bậc <%= jl.getRankOrder() %>)</option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 15px;">
                <label for="hrNote" style="font-weight: 600;">Ghi chú quyết định của HR:</label>
                <textarea id="hrNote" name="hrNote" class="form-control" rows="3" placeholder="Nhập quyết định điều chuyển, ngày bắt đầu nhận nhiệm vụ..."></textarea>
            </div>
            
            <div style="display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn btn-secondary" onclick="closeHrModal()">Hủy</button>
                <button type="submit" class="btn btn-primary" style="font-weight: 600;">
                    <i class="fa-solid fa-check"></i> CẬP NHẬT ĐIỀU CHUYỂN
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openManagerModal(reqId, status, empName) {
    document.getElementById("mgrModalReqId").value = reqId;
    document.getElementById("mgrModalStatus").value = status;
    var title = document.getElementById("managerModalTitle");
    var btn = document.getElementById("mgrModalSubmitBtn");
    if (status === 'APPROVED') {
        title.textContent = "Phê duyệt nguyện vọng: " + empName;
        btn.textContent = "Đồng ý chuyển tiếp sang HR";
        btn.className = "btn btn-primary";
    } else {
        title.textContent = "Từ chối nguyện vọng: " + empName;
        btn.textContent = "Xác nhận từ chối";
        btn.className = "btn btn-danger";
    }
    document.getElementById("managerModal").style.display = "flex";
}
function closeManagerModal() {
    document.getElementById("managerModal").style.display = "none";
}

function openHrModal(reqId, empName, deptName, posName) {
    document.getElementById("hrModalReqId").value = reqId;
    document.getElementById("hrModalDesc").innerHTML = "Thực hiện chuyển nhân sự <b>" + empName + "</b> sang phòng ban <b>" + deptName + "</b> (Vị trí: " + (posName ? posName : "Theo sắp xếp") + ").";
    document.getElementById("hrModal").style.display = "flex";
}
function closeHrModal() {
    document.getElementById("hrModal").style.display = "none";
}

function openHrRejectModal(reqId, empName) {
    var note = prompt("Nhập lý do HR từ chối điều chuyển nhân sự " + empName + ":");
    if (note != null && note.trim() !== "") {
        var form = document.createElement("form");
        form.method = "POST";
        form.action = "<%= request.getContextPath() %>/transfer";
        form.innerHTML = '<input type="hidden" name="action" value="hrExecute">' +
                         '<input type="hidden" name="requestId" value="' + reqId + '">' +
                         '<input type="hidden" name="status" value="REJECTED">' +
                         '<input type="hidden" name="hrNote" value="' + note.replace(/"/g, '&quot;') + '">';
        document.body.appendChild(form);
        form.submit();
    }
}
</script>

<jsp:include page="/views/common/footer.jsp" />
