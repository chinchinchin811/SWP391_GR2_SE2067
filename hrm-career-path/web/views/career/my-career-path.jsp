<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.PositionLevelCriteria" %>
<%@ page import="model.CriteriaRequirement" %>
<%@ page import="model.PromotionRequest" %>
<%@ page import="model.PromotionEvidence" %>
<%
    User user = (User) request.getAttribute("employee");
    JobLevel currentLevel = (JobLevel) request.getAttribute("currentLevel");
    JobLevel nextLevel = (JobLevel) request.getAttribute("nextLevel");
    PositionLevelCriteria criteria = (PositionLevelCriteria) request.getAttribute("criteria");
    PromotionRequest existingRequest = (PromotionRequest) request.getAttribute("existingRequest");
    List<JobLevel> allLevels = (List<JobLevel>) request.getAttribute("allLevels");
    
    request.setAttribute("pageTitle", "Lộ Trình Thăng Tiến Của Tôi | CPMS");
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
            <h1 style="margin-bottom: 4px;">Lộ Trình Nghề Nghiệp &amp; Thăng Tiến</h1>
            <p style="color: #64748b; font-size: 13.5px; margin: 0;">
                Theo dõi tiêu chuẩn năng lực, tích lũy minh chứng thực tế và nộp hồ sơ xét duyệt nâng bậc.
            </p>
        </div>
        <div>
            <% if (existingRequest != null) { %>
                <span class="badge <%= existingRequest.getStatusBadge() %>" style="font-size: 13.5px; padding: 8px 14px;">
                    <i class="fa-solid fa-clock-rotate-left"></i> Hồ sơ: <%= existingRequest.getStatusText() %>
                </span>
            <% } %>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
            <i class="fa-solid fa-circle-check" style="margin-right: 6px;"></i> <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
            <i class="fa-solid fa-triangle-exclamation" style="margin-right: 6px;"></i> <%= errorMessage %>
        </div>
        <% } %>

        <!-- Card Thông Tin Tổng Quan -->
        <div class="card" style="background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%); color: #ffffff; padding: 24px; border-radius: 12px; margin-bottom: 24px; box-shadow: 0 4px 12px rgba(49, 46, 129, 0.2);">
            <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 20px;">
                <div>
                    <span style="background: rgba(255,255,255,0.15); color: #c7d2fe; font-size: 12px; font-weight: 700; text-transform: uppercase; padding: 4px 10px; border-radius: 20px; letter-spacing: 0.5px;">
                        Vị Trí Chuyên Môn
                    </span>
                    <h2 style="margin: 8px 0 4px 0; font-size: 24px; font-weight: 800; color: #ffffff;">
                        <%= (user != null && user.getPositionName() != null) ? user.getPositionName() : "Chưa phân bổ vị trí" %>
                    </h2>
                    <p style="margin: 0; color: #cbd5e1; font-size: 14px;">
                        Phòng ban: <strong><%= (user != null && user.getDepartmentName() != null) ? user.getDepartmentName() : "Chung" %></strong>
                        | Nhân sự: <strong><%= (user != null ? user.getFullName() : "") %></strong>
                    </p>
                </div>

                <div style="display: flex; align-items: center; gap: 16px; background: rgba(255,255,255,0.1); padding: 14px 20px; border-radius: 10px; border: 1px solid rgba(255,255,255,0.15);">
                    <div style="text-align: right;">
                        <span style="font-size: 11.5px; color: #cbd5e1;">CẤP BẬC HIỆN TẠI</span>
                        <div style="font-size: 18px; font-weight: 800; color: #38bdf8;">
                            <%= currentLevel != null ? currentLevel.getLevelName() : "Chưa có" %>
                        </div>
                    </div>
                    <i class="fa-solid fa-arrow-right-long" style="font-size: 20px; color: #a5b4fc;"></i>
                    <div>
                        <span style="font-size: 11.5px; color: #cbd5e1;">MỤC TIÊU TIẾP THEO</span>
                        <div style="font-size: 18px; font-weight: 800; color: #4ade80;">
                            <%= nextLevel != null ? nextLevel.getLevelName() : "Đỉnh Lộ Trình" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <% if (nextLevel == null) { %>
            <div class="card" style="padding: 40px; text-align: center; background: #ffffff; border-radius: 10px;">
                <i class="fa-solid fa-trophy" style="font-size: 56px; color: #f59e0b; margin-bottom: 16px;"></i>
                <h3 style="color: #1e293b; margin-bottom: 8px;">Chúc Mừng! Bạn Đã Đạt Cấp Bậc Cao Nhất</h3>
                <p style="color: #64748b; font-size: 14px; max-width: 500px; margin: 0 auto;">
                    Hiện tại bạn đang ở bậc <strong><%= currentLevel != null ? currentLevel.getLevelName() : "" %></strong>, là cấp bậc cao nhất trong khung tiêu chuẩn của vị trí này.
                </p>
            </div>
        <% } else if (criteria == null) { %>
            <div class="card" style="padding: 40px; text-align: center; background: #ffffff; border-radius: 10px;">
                <i class="fa-solid fa-hourglass-half" style="font-size: 48px; color: #94a3b8; margin-bottom: 16px;"></i>
                <h3 style="color: #1e293b; margin-bottom: 8px;">Barem Thăng Tiến Đang Được Cập Nhật</h3>
                <p style="color: #64748b; font-size: 14px; max-width: 550px; margin: 0 auto;">
                    Admin hiện chưa cấu hình bộ tiêu chí cụ thể cho bước thăng tiến từ <strong><%= currentLevel.getLevelName() %></strong> lên <strong><%= nextLevel.getLevelName() %></strong>. Vui lòng liên hệ bộ phận Nhân sự (HR) để biết thêm thông tin.
                </p>
            </div>
        <% } else { %>

            <!-- Khung Chi Tiết Điều Kiện Lên Bậc -->
            <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; margin-bottom: 24px; padding: 24px;">
                <h3 style="font-size: 17px; color: #1e293b; margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-bullseye" style="color: #4f46e5;"></i>
                    Chuẩn Năng Lực Cần Đạt Để Lên Bậc: <span style="color: #059669;"><%= nextLevel.getLevelName() %></span>
                </h3>

                <div style="background: #f8fafc; padding: 16px 20px; border-radius: 8px; border-left: 4px solid #4f46e5; margin-bottom: 20px;">
                    <strong style="color: #334155; font-size: 13px; text-transform: uppercase;">Yêu cầu năng lực cốt lõi:</strong>
                    <p style="margin: 6px 0 0 0; font-size: 14px; color: #1e293b; line-height: 1.6;">
                        <%= criteria.getCompetencySummary() %>
                    </p>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px; margin-bottom: 24px;">
                    <div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; background: #fafafa;">
                        <span style="font-size: 12px; color: #64748b; font-weight: 600;">1. KHẢO SÁT SÁT HẠCH</span>
                        <div style="margin-top: 6px; font-size: 14px; color: #1e293b;">
                            Điểm bài test chuyên môn sàn: <strong style="color: #059669;">≥ <%= criteria.getMinTestScore() %>đ</strong>
                        </div>
                    </div>
                    <div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; background: #fafafa;">
                        <span style="font-size: 12px; color: #64748b; font-weight: 600;">2. ĐÁNH GIÁ NĂNG LỰC THỰC CHIẾN</span>
                        <div style="margin-top: 6px; font-size: 14px; color: #1e293b;">
                            Điểm đánh giá kín từ Trưởng phòng: <strong style="color: #4338ca;">≥ <%= criteria.getMinManagerRating() %>/10đ</strong>
                        </div>
                    </div>
                </div>

                <!-- Bảng Nộp Hồ Sơ Minh Chứng -->
                <h3 style="font-size: 16px; color: #1e293b; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-folder-open" style="color: #f59e0b;"></i>
                    Hồ Sơ Minh Chứng Năng Lực Thực Tế (Dự án / CSAT / Chứng chỉ)
                </h3>

                <% if (existingRequest != null) { %>
                    <!-- Hiển thị hồ sơ đã nộp và trạng thái thẩm định -->
                    <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 18px; margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                            <span style="font-size: 13.5px; color: #334155; font-weight: 700;">
                                <i class="fa-solid fa-file-lines" style="color: #4f46e5;"></i> Hồ Sơ Đang Xét Duyệt (Mã: #<%= existingRequest.getRequestId() %>)
                            </span>
                            <span style="font-size: 12.5px; color: #64748b;">
                                Ngày nộp: <%= existingRequest.getCreatedAt() %>
                            </span>
                        </div>

                        <table class="data-table" style="width: 100%; font-size: 13px; background: #ffffff;">
                            <thead>
                                <tr style="background: #f1f5f9;">
                                    <th>Tiêu chí yêu cầu</th>
                                    <th>Nội dung minh chứng bạn đã nộp</th>
                                    <th style="width: 180px;">Tài liệu / Liên kết</th>
                                    <th style="width: 130px; text-align: center;">Trạng thái thẩm định</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (existingRequest.getEvidenceList() != null) { 
                                    for (PromotionEvidence ev : existingRequest.getEvidenceList()) { 
                                %>
                                <tr>
                                    <td>
                                        <strong><%= ev.getRequirementTitle() %></strong>
                                        <div style="font-size: 11px; color: #64748b;"><%= ev.getRequirementType() %></div>
                                    </td>
                                    <td><%= ev.getEvidenceSummary() %></td>
                                    <td>
                                        <% if (ev.getEvidenceUrl() != null && !ev.getEvidenceUrl().isEmpty()) { %>
                                            <a href="<%= ev.getEvidenceUrl() %>" target="_blank" style="color: #4f46e5; text-decoration: underline;">
                                                <i class="fa-solid fa-arrow-up-right-from-square"></i> Xem liên kết
                                            </a>
                                        <% } else { %>
                                            <span style="color: #94a3b8;">Không có liên kết</span>
                                        <% } %>
                                    </td>
                                    <td style="text-align: center;">
                                        <% if (ev.isVerified()) { %>
                                            <span style="color: #059669; font-weight: 700;"><i class="fa-solid fa-check"></i> Đạt</span>
                                        <% } else { %>
                                            <span style="color: #d97706; font-size: 12px;"><i class="fa-solid fa-clock"></i> Chờ duyệt</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>

                <% } else { %>

                    <!-- Form nộp hồ sơ minh chứng mới -->
                    <form action="<%= request.getContextPath() %>/career-path" method="POST">
                        <input type="hidden" name="action" value="submitPromotion">
                        <input type="hidden" name="positionId" value="<%= criteria.getPositionId() %>">
                        <input type="hidden" name="currentLevelId" value="<%= criteria.getFromLevelId() %>">
                        <input type="hidden" name="targetLevelId" value="<%= criteria.getToLevelId() %>">
                        <input type="hidden" name="criteriaId" value="<%= criteria.getCriteriaId() %>">

                        <p style="font-size: 13.5px; color: #64748b; margin-bottom: 16px;">
                            Vui lòng cung cấp tóm tắt kết quả công việc và liên kết tài liệu minh chứng tương ứng với từng tiêu chí dưới đây để Trưởng phòng và Nhân sự thẩm định:
                        </p>

                        <div style="display: flex; flex-direction: column; gap: 16px; margin-bottom: 24px;">
                            <% 
                                if (criteria.getRequirements() != null && !criteria.getRequirements().isEmpty()) {
                                    for (CriteriaRequirement req : criteria.getRequirements()) {
                            %>
                                <div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; background: #fafafa;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                                        <div>
                                            <strong style="color: #1e293b; font-size: 14px;">
                                                <%= req.getRequirementTitle() %>
                                            </strong>
                                            <% if (req.isMandatory()) { %>
                                                <span style="color: #dc2626; font-size: 12px; font-weight: 700; margin-left: 6px;">* Bắt buộc</span>
                                            <% } %>
                                            <% if (req.getDescription() != null && !req.getDescription().isEmpty()) { %>
                                                <div style="color: #64748b; font-size: 12.5px; margin-top: 3px;">
                                                    Hướng dẫn: <%= req.getDescription() %>
                                                </div>
                                            <% } %>
                                        </div>
                                        <span style="background: #e2e8f0; color: #334155; font-size: 11px; padding: 2px 8px; border-radius: 4px; font-weight: 600;">
                                            <%= req.getRequirementTypeBadge() %>
                                        </span>
                                    </div>

                                    <input type="hidden" name="requirementId" value="<%= req.getRequirementId() %>">
                                    <div style="margin-top: 10px;">
                                        <textarea name="evidenceSummary_<%= req.getRequirementId() %>" rows="2" class="form-control" 
                                                  placeholder="Tóm tắt minh chứng của bạn (ví dụ: Tên dự án tham gia, vai trò, đóng góp cụ thể...)" 
                                                  <%= req.isMandatory() ? "required" : "" %>></textarea>
                                    </div>
                                    <div style="margin-top: 8px;">
                                        <input type="url" name="evidenceUrl_<%= req.getRequirementId() %>" class="form-control" 
                                               placeholder="Dán đường dẫn tài liệu minh chứng (Google Drive / GitHub / Báo cáo nghiệm thu online)">
                                    </div>
                                </div>
                            <% 
                                    }
                                } else { 
                            %>
                                <p style="color: #64748b; font-size: 13.5px; font-style: italic;">
                                    Không có tiêu chí minh chứng mở nào. Bạn có thể gửi đề xuất ngay để Quản lý làm phiếu đánh giá.
                                </p>
                            <% } %>
                        </div>

                        <div style="text-align: right; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                            <button type="submit" class="btn btn-primary" style="padding: 10px 24px; font-weight: 700; font-size: 14px;">
                                <i class="fa-solid fa-paper-plane" style="margin-right: 6px;"></i> Nộp Hồ Sơ Đề Xuất Thăng Cấp
                            </button>
                        </div>
                    </form>
                <% } %>
            </div>

        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

