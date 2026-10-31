<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.PromotionRequest" %>
<%@ page import="model.PromotionEvidence" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    SimpleDateFormat sdfDateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    PromotionRequest reqItem = (PromotionRequest) request.getAttribute("requestItem");
    boolean isManager = (roleId == 3);
    boolean isHR = (roleId == 1 || roleId == 2);
    
    request.setAttribute("pageTitle", "Hồ Sơ Nâng Bậc #" + (reqItem != null ? reqItem.getRequestId() : "") + " | CPMS");
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
            <h1 style="margin-bottom: 4px;">Thẩm Định Hồ Sơ Thăng Tiến #<%= reqItem != null ? reqItem.getRequestId() : "" %></h1>
            <p style="color: #64748b; font-size: 13.5px; margin: 0;">
                Nhân sự: <strong><%= reqItem != null ? reqItem.getUserFullName() : "" %></strong> 
                | Vị trí: <strong><%= reqItem != null ? reqItem.getPositionName() : "" %></strong>
            </p>
        </div>
        <div>
            <a href="<%= request.getContextPath() %>/promotions" class="btn btn-secondary">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
            <i class="fa-solid fa-circle-check"></i> <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
            <i class="fa-solid fa-triangle-exclamation"></i> <%= errorMessage %>
        </div>
        <% } %>

        <% if (reqItem != null) { %>

            <!-- Khung Thông Tin Nấc Thăng Cấp -->
            <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; padding: 20px; margin-bottom: 20px;">
                <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px;">
                    <div>
                        <span style="font-size: 12px; color: #64748b; font-weight: 600;">LỘ TRÌNH ĐỀ XUẤT</span>
                        <div style="font-size: 18px; font-weight: 800; color: #1e293b; margin-top: 4px;">
                            <span style="color: #475569;"><%= reqItem.getCurrentLevelName() %></span>
                            <i class="fa-solid fa-arrow-right" style="margin: 0 8px; font-size: 14px; color: #94a3b8;"></i>
                            <span style="color: #059669;"><%= reqItem.getTargetLevelName() %></span>
                        </div>
                    </div>
                    <div>
                        <span style="font-size: 12px; color: #64748b; font-weight: 600;">TRẠNG THÁI HIỆN TẠI</span>
                        <div style="margin-top: 4px;">
                            <span class="badge <%= reqItem.getStatusBadge() %>" style="font-size: 13px; padding: 6px 12px;">
                                <%= reqItem.getStatusText() %>
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bảng Chi Tiết Minh Chứng Thực Tế -->
            <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; padding: 24px; margin-bottom: 24px;">
                <h3 style="font-size: 16px; color: #1e293b; margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-folder-open" style="color: #4f46e5;"></i>
                    Danh Mục Bằng Chứng Thực Tế Nhân Viên Nộp (Dự án / CSAT / Chứng chỉ)
                </h3>

                <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 13.5px;">
                    <thead>
                        <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                            <th style="padding: 12px; width: 220px;">Tiêu chí yêu cầu</th>
                            <th style="padding: 12px;">Nội dung minh chứng nhân viên trình bày</th>
                            <th style="padding: 12px; width: 180px;">Tài liệu / Liên kết</th>
                            <th style="padding: 12px; text-align: center; width: 140px;">Xác nhận Đạt</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (reqItem.getEvidenceList() != null && !reqItem.getEvidenceList().isEmpty()) { 
                            for (PromotionEvidence ev : reqItem.getEvidenceList()) {
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 14px 12px;">
                                <strong style="color: #1e293b;"><%= ev.getRequirementTitle() %></strong>
                                <div style="font-size: 11.5px; color: #64748b; margin-top: 2px;"><%= ev.getRequirementType() %></div>
                            </td>
                            <td style="padding: 14px 12px; line-height: 1.5; color: #334155;">
                                <%= ev.getEvidenceSummary() %>
                            </td>
                            <td style="padding: 14px 12px;">
                                <% if (ev.getEvidenceUrl() != null && !ev.getEvidenceUrl().isEmpty()) { %>
                                    <a href="<%= ev.getEvidenceUrl() %>" target="_blank" class="btn btn-sm btn-secondary" style="font-size: 12px; text-decoration: none;">
                                        <i class="fa-solid fa-arrow-up-right-from-square"></i> Mở liên kết
                                    </a>
                                <% } else { %>
                                    <span style="color: #94a3b8; font-size: 12px;">Không đính kèm link</span>
                                <% } %>
                            </td>
                            <td style="padding: 14px 12px; text-align: center;">
                                <% if (isManager && "SUBMITTED".equals(reqItem.getStatus())) { %>
                                    <!-- Manager có thể bấm tích duyệt trực tiếp -->
                                    <form action="<%= request.getContextPath() %>/promotions" method="POST" style="display: inline;">
                                        <input type="hidden" name="action" value="verifyEvidence">
                                        <input type="hidden" name="requestId" value="<%= reqItem.getRequestId() %>">
                                        <input type="hidden" name="evidenceId" value="<%= ev.getEvidenceId() %>">
                                        <input type="hidden" name="isVerified" value="<%= ev.isVerified() ? "false" : "true" %>">
                                        <button type="submit" class="btn btn-sm <%= ev.isVerified() ? "btn-success" : "btn-secondary" %>" style="font-size: 12px;">
                                            <i class="fa-solid <%= ev.isVerified() ? "fa-check" : "fa-circle-xmark" %>"></i>
                                            <%= ev.isVerified() ? "Đã duyệt" : "Chưa duyệt" %>
                                        </button>
                                    </form>
                                <% } else { %>
                                    <% if (ev.isVerified()) { %>
                                        <span style="color: #059669; font-weight: 700;"><i class="fa-solid fa-check"></i> Đạt</span>
                                    <% } else { %>
                                        <span style="color: #d97706; font-size: 12px;"><i class="fa-solid fa-clock"></i> Chưa duyệt</span>
                                    <% } %>
                                <% } %>
                            </td>
                        </tr>
                        <% }} else { %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 24px; color: #94a3b8;">Không có bằng chứng minh họa bổ sung.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- PHẦN 1: ĐÁNH GIÁ KÍN CỦA TRƯỞNG PHÒNG (MANAGER) -->
            <% if (isManager && "SUBMITTED".equals(reqItem.getStatus())) { %>
                <div class="card" style="background: #ffffff; border-radius: 10px; border: 2px solid #4f46e5; padding: 24px; margin-bottom: 24px;">
                    <h3 style="font-size: 16px; color: #4338ca; margin-bottom: 14px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-user-check"></i>
                        Phiếu Đánh Giá Hiệu Suất Kín Của Trưởng Phòng (Confidential Appraisal)
                    </h3>
                    <p style="font-size: 13px; color: #64748b; margin-bottom: 18px;">
                        Phiếu đánh giá này được bảo mật nội bộ, chỉ chuyển tới phòng Nhân sự (HR) để xét duyệt và nhân viên không xem được.
                    </p>

                    <form action="<%= request.getContextPath() %>/promotions" method="POST">
                        <input type="hidden" name="action" value="submitManagerReview">
                        <input type="hidden" name="requestId" value="<%= reqItem.getRequestId() %>">

                        <div style="display: grid; grid-template-columns: 200px 1fr; gap: 20px; margin-bottom: 16px;">
                            <div class="form-group">
                                <label style="font-weight: 700; font-size: 13px;">Điểm Năng Lực Thực Tế (1 - 10) (*):</label>
                                <input type="number" step="0.1" min="1" max="10" name="managerRating" class="form-control" value="8.0" required>
                            </div>
                            <div class="form-group">
                                <label style="font-weight: 700; font-size: 13px;">Ý Kiến Đề Xuất Xét Duyệt (*):</label>
                                <select name="managerDecision" class="form-control" required>
                                    <option value="RECOMMENDED">ĐỀ XUẤT CHO THĂNG CẤP (Đạt chuẩn năng lực)</option>
                                    <option value="REJECTED">TỪ CHỐI (Chưa đủ điều kiện, cần rèn luyện thêm)</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="font-weight: 700; font-size: 13px;">Nhận Xét Kín Gửi HR Về Năng Lực &amp; Đóng Góp Dự Án:</label>
                            <textarea name="managerNotes" rows="3" class="form-control" placeholder="Đánh giá về thái độ làm việc, kỹ năng phối hợp và mức độ hoàn thành nhiệm vụ thực tế..." required></textarea>
                        </div>

                        <div style="text-align: right;">
                            <button type="submit" class="btn btn-primary" style="padding: 10px 24px; font-weight: 700;">
                                <i class="fa-solid fa-paper-plane" style="margin-right: 6px;"></i> Hoàn Tất Đánh Giá &amp; Gửi Lên HR
                            </button>
                        </div>
                    </form>
                </div>
            <% } else if (reqItem.getManagerRating() != null) { %>
                <!-- Đã có đánh giá từ Manager -->
                <div class="card" style="background: #f8fafc; border-radius: 10px; border: 1px solid #cbd5e1; padding: 20px; margin-bottom: 24px;">
                    <h3 style="font-size: 15px; color: #1e293b; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-user-check" style="color: #4f46e5;"></i>
                        Kết Quả Đánh Giá Kín Của Trưởng Phòng
                    </h3>
                    <div style="font-size: 13.5px; color: #334155; line-height: 1.6;">
                        • Trưởng phòng đánh giá: <strong><%= reqItem.getManagerName() != null ? reqItem.getManagerName() : "Quản lý" %></strong><br>
                        • Điểm năng lực thực chiến: <strong style="color: #4f46e5; font-size: 16px;"><%= reqItem.getManagerRating() %>/10đ</strong><br>
                        • Đề xuất của Quản lý: <strong><%= "RECOMMENDED".equals(reqItem.getManagerStatus()) ? "ĐỒNG Ý ĐỀ XUẤT THĂNG CẤP" : "TỪ CHỐI" %></strong><br>
                        • Nhận xét kín: <em>"<%= reqItem.getManagerConfidentialNotes() != null ? reqItem.getManagerConfidentialNotes() : "" %>"</em>
                    </div>
                </div>
            <% } %>

            <!-- PHẦN 2: QUYẾT ĐỊNH BỔ NHIỆM CHÍNH THỨC CỦA HR -->
            <% if (isHR && ("MANAGER_REVIEWED".equals(reqItem.getStatus()) || "SUBMITTED".equals(reqItem.getStatus()))) { %>
                <div class="card" style="background: #ffffff; border-radius: 10px; border: 2px solid #059669; padding: 24px;">
                    <h3 style="font-size: 16px; color: #047857; margin-bottom: 14px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-stamp"></i>
                        Quyết Định Bổ Nhiệm &amp; Thăng Cấp (Phòng Nhân Sự HR)
                    </h3>
                    <p style="font-size: 13px; color: #64748b; margin-bottom: 18px;">
                        Khi HR bấm <b>"Phê Duyệt &amp; Ban Hành Bổ Nhiệm"</b>, hệ thống sẽ tự động cập nhật cấp bậc của nhân viên lên <strong><%= reqItem.getTargetLevelName() %></strong> và ghi vào Lịch sử nhân sự.
                    </p>

                    <form action="<%= request.getContextPath() %>/promotions" method="POST">
                        <input type="hidden" name="action" value="hrDecision">
                        <input type="hidden" name="requestId" value="<%= reqItem.getRequestId() %>">

                        <div class="form-group" style="margin-bottom: 16px;">
                            <label style="font-weight: 700; font-size: 13px;">Quyết Định Của HR (*):</label>
                            <select name="hrDecision" class="form-control" required>
                                <option value="APPROVED">PHÊ DUYỆT THĂNG CHỨC &amp; BAN HÀNH QUYẾT ĐỊNH</option>
                                <option value="REJECTED">TỪ CHỐI BỔ NHIỆM</option>
                            </select>
                        </div>

                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="font-weight: 700; font-size: 13px;">Ghi Chú Quyết Định Bổ Nhiệm / Lý Do:</label>
                            <textarea name="hrNotes" rows="2" class="form-control" placeholder="Số quyết định, lý do hoặc thông điệp chúc mừng..."></textarea>
                        </div>

                        <div style="text-align: right;">
                            <button type="submit" class="btn btn-primary" style="background: #059669; border-color: #059669; padding: 10px 24px; font-weight: 700;">
                                <i class="fa-solid fa-stamp" style="margin-right: 6px;"></i> Xác Nhận Ban Hành Quyết Định
                            </button>
                        </div>
                    </form>
                </div>
            <% } else if ("APPROVED".equals(reqItem.getStatus())) { %>
                <div class="card" style="background: #ecfdf5; border-radius: 10px; border: 1px solid #a7f3d0; padding: 20px;">
                    <h3 style="font-size: 15px; color: #065f46; margin-bottom: 8px;">
                        <i class="fa-solid fa-circle-check"></i> Đã Ban Hành Quyết Định Bổ Nhiệm Chính Thức
                    </h3>
                    <p style="margin: 0; font-size: 13.5px; color: #047857;">
                        Quyết định được ký bởi: <strong><%= reqItem.getHrName() != null ? reqItem.getHrName() : "HR" %></strong> 
                        vào ngày <%= reqItem.getHrActionDate() != null ? sdfDateTime.format(reqItem.getHrActionDate()) : "" %><br>
                        Ghi chú: "<%= reqItem.getHrNotes() != null ? reqItem.getHrNotes() : "" %>"
                    </p>
                </div>
            <% } %>

        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

