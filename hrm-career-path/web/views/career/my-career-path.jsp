<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.User" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.PositionLevelCriteria" %>
<%@ page import="model.CriteriaRequirement" %>
<%@ page import="model.PromotionRequest" %>
<%@ page import="model.PromotionEvidence" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    SimpleDateFormat sdfDateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
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

    // Tính toán tiến độ các điều kiện bắt buộc
    int totalMandatory = 0;
    int completedMandatory = 0;
    if (criteria != null) {
        if (criteria.getMinTestScore() != null && criteria.getMinTestScore().doubleValue() > 0) {
            totalMandatory++;
            if (existingRequest != null && existingRequest.getTestScore() != null 
                    && existingRequest.getTestScore().compareTo(criteria.getMinTestScore()) >= 0) {
                completedMandatory++;
            }
        }
        if (criteria.getMinManagerRating() != null && criteria.getMinManagerRating().doubleValue() > 0) {
            totalMandatory++;
            if (existingRequest != null && existingRequest.getManagerRating() != null 
                    && existingRequest.getManagerRating().compareTo(criteria.getMinManagerRating()) >= 0) {
                completedMandatory++;
            }
        }
        if (criteria.getRequirements() != null) {
            for (CriteriaRequirement req : criteria.getRequirements()) {
                if (req.isMandatory()) {
                    totalMandatory++;
                    if (existingRequest != null && existingRequest.getEvidenceList() != null) {
                        for (PromotionEvidence ev : existingRequest.getEvidenceList()) {
                            if (ev.getRequirementId() == req.getRequirementId() && ev.isVerified()) {
                                completedMandatory++;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    int progressPercent = (totalMandatory > 0) ? (completedMandatory * 100 / totalMandatory) : 0;
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <div>
            <h1 style="margin-bottom: 4px;">Lộ Trình Nghề Nghiệp &amp; Thăng Tiến</h1>
            <p style="color: #64748b; font-size: 13.5px; margin: 0;">
                Theo dõi tiêu chuẩn năng lực, tích lũy minh chứng thực tế cho từng điều kiện và tự động nâng bậc khi hoàn thành.
            </p>
        </div>
        <div>
            <% if (existingRequest != null) { %>
                <span class="badge" style="font-size: 13.5px; padding: 7px 14px; background: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; font-weight: 700;">
                    Hồ sơ tích lũy: <%= existingRequest.getStatus() != null ? existingRequest.getStatus() : "Đang tích lũy" %> (Mã: #<%= existingRequest.getRequestId() %>)
                </span>
            <% } %>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
            <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 14px;">
                <%= successMessage %>
            </div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 14px;">
                <%= errorMessage %>
            </div>
        <% } %>

        <!-- Khung Thông Tin Tổng Quan -->
        <div class="card" style="background: #1e1b4b; color: #ffffff; padding: 22px 24px; border-radius: 10px; margin-bottom: 24px;">
            <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 20px;">
                <div>
                    <span style="background: rgba(255,255,255,0.15); color: #c7d2fe; font-size: 11.5px; font-weight: 700; text-transform: uppercase; padding: 4px 10px; border-radius: 4px; letter-spacing: 0.5px;">
                        Vị Trí Chuyên Môn
                    </span>
                    <h2 style="margin: 8px 0 4px 0; font-size: 22px; font-weight: 800; color: #ffffff;">
                        <%= (user != null && user.getPositionName() != null) ? user.getPositionName() : "Chưa phân bổ vị trí" %>
                    </h2>
                    <p style="margin: 0; color: #cbd5e1; font-size: 13.5px;">
                        Phòng ban: <strong><%= (user != null && user.getDepartmentName() != null) ? user.getDepartmentName() : "Chung" %></strong>
                        | Nhân sự: <strong><%= (user != null ? user.getFullName() : "") %></strong>
                    </p>
                </div>

                <div style="display: flex; align-items: center; gap: 16px; background: rgba(255,255,255,0.08); padding: 12px 18px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.12);">
                    <div style="text-align: right;">
                        <span style="font-size: 11px; color: #cbd5e1; display: block;">CẤP BẬC HIỆN TẠI</span>
                        <div style="font-size: 17px; font-weight: 800; color: #38bdf8;">
                            <%= currentLevel != null ? currentLevel.getLevelName() : "Chưa có" %>
                        </div>
                    </div>
                    <span style="color: #94a3b8; font-size: 18px; font-weight: 300;">-&gt;</span>
                    <div>
                        <span style="font-size: 11px; color: #cbd5e1; display: block;">MỤC TIÊU TIẾP THEO</span>
                        <div style="font-size: 17px; font-weight: 800; color: #4ade80;">
                            <%= nextLevel != null ? nextLevel.getLevelName() : "Đỉnh Lộ Trình" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG 1: THANG CẤP BẬC VỊ TRÍ CHUYÊN MÔN (LỘ TRÌNH TỔNG THỂ) -->
        <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; margin-bottom: 24px; padding: 22px;">
            <div style="margin-bottom: 16px;">
                <h3 style="font-size: 16.5px; font-weight: 700; color: #0f172a; margin: 0 0 4px 0;">
                    Thang Cấp Bậc Vị Trí Chuyên Môn
                </h3>
                <p style="font-size: 13px; color: #64748b; margin: 0;">
                    Cấp bậc được sắp xếp theo thứ tự tăng dần. Theo dõi cấp bậc hiện tại và mục tiêu phát triển của bạn.
                </p>
            </div>

            <div class="table-responsive">
                <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 13.5px;">
                    <thead>
                        <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0;">
                            <th style="padding: 10px 14px; text-align: left; width: 90px; color: #475569;">Thứ tự</th>
                            <th style="padding: 10px 14px; text-align: left; width: 180px; color: #475569;">Tên cấp bậc</th>
                            <th style="padding: 10px 14px; text-align: left; color: #475569;">Mô tả / Tiêu chuẩn vị trí</th>
                            <th style="padding: 10px 14px; text-align: center; width: 220px; color: #475569;">Trạng thái của bạn</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (allLevels != null && !allLevels.isEmpty()) {
                                for (JobLevel lvl : allLevels) {
                                    int currentRank = (currentLevel != null) ? currentLevel.getRankOrder() : -1;
                                    int lvlRank = lvl.getRankOrder();
                                    boolean isCurrent = (currentLevel != null && lvl.getLevelId() == currentLevel.getLevelId());
                                    boolean isCompleted = (currentRank > 0 && lvlRank < currentRank);
                                    boolean isNext = (nextLevel != null && lvl.getLevelId() == nextLevel.getLevelId());
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9; <%= isCurrent ? "background: #f8fafc;" : "" %>">
                            <td style="padding: 12px 14px; font-weight: 600; color: #334155;">
                                Bậc <%= lvl.getRankOrder() %>
                            </td>
                            <td style="padding: 12px 14px;">
                                <strong style="color: #0f172a;"><%= lvl.getLevelName() %></strong>
                            </td>
                            <td style="padding: 12px 14px; color: #475569;">
                                <%= (lvl.getDescription() != null && !lvl.getDescription().trim().isEmpty()) ? lvl.getDescription() : "-" %>
                            </td>
                            <td style="padding: 12px 14px; text-align: center;">
                                <% if (isCompleted) { %>
                                    <span style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 12px;">
                                        Đã hoàn thành
                                    </span>
                                <% } else if (isCurrent) { %>
                                    <span style="background: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 12px;">
                                        Đang đảm nhiệm (Hiện tại)
                                    </span>
                                <% } else if (isNext) { %>
                                    <span style="background: #fef3c7; color: #92400e; border: 1px solid #fde68a; padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 12px;">
                                        Mục tiêu tiếp theo
                                    </span>
                                <% } else { %>
                                    <span style="background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; padding: 4px 10px; border-radius: 4px; font-weight: 600; font-size: 12px;">
                                        Chưa mở khóa
                                    </span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 20px; color: #94a3b8;">Chưa có dữ liệu cấp bậc.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <% if (nextLevel == null) { %>
            <!-- Trường hợp đã ở cấp bậc cao nhất -->
            <div class="card" style="padding: 36px; text-align: center; background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0;">
                <h3 style="color: #1e293b; margin-bottom: 8px; font-size: 18px;">
                    Chúc Mừng! Bạn Đã Đạt Cấp Bậc Cao Nhất
                </h3>
                <p style="color: #64748b; font-size: 14px; max-width: 500px; margin: 0 auto;">
                    Hiện tại bạn đang ở bậc <strong><%= currentLevel != null ? currentLevel.getLevelName() : "" %></strong>, là cấp bậc cao nhất trong khung tiêu chuẩn của vị trí này.
                </p>
            </div>
        <% } else if (criteria == null) { %>
            <!-- Trường hợp chưa cấu hình barem -->
            <div class="card" style="padding: 36px; text-align: center; background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0;">
                <h3 style="color: #1e293b; margin-bottom: 8px; font-size: 18px;">
                    Barem Thăng Tiến Đang Được Cập Nhật
                </h3>
                <p style="color: #64748b; font-size: 14px; max-width: 550px; margin: 0 auto;">
                    Admin hiện chưa cấu hình bộ tiêu chí cụ thể cho bước thăng tiến từ
                    <strong><%= currentLevel != null ? currentLevel.getLevelName() : "" %></strong> lên
                    <strong><%= nextLevel.getLevelName() %></strong>. Vui lòng liên hệ bộ phận Nhân sự (HR) để biết thêm thông tin.
                </p>
            </div>
        <% } else { %>

            <!-- BẢNG 2: DANH MỤC TIÊU CHUẨN & NỘP MINH CHỨNG THĂNG TIẾN (LŨY TIẾN) -->
            <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; margin-bottom: 24px; padding: 22px;">
                <div style="margin-bottom: 16px;">
                    <h3 style="font-size: 16.5px; font-weight: 700; color: #0f172a; margin: 0 0 4px 0;">
                        Tiêu Chuẩn Năng Lực &amp; Nộp Minh Chứng Lên Bậc: <%= nextLevel.getLevelName() %>
                    </h3>
                    <p style="font-size: 13px; color: #64748b; margin: 0;">
                        Nộp minh chứng từng phần cho từng tiêu chuẩn bên dưới. Khi tất cả điều kiện bắt buộc được thẩm định Đạt, hệ thống sẽ tự động nâng bậc cho bạn.
                    </p>
                </div>

                <!-- Khung Năng lực cốt lõi -->
                <% if (criteria.getCompetencySummary() != null && !criteria.getCompetencySummary().trim().isEmpty()) { %>
                    <div style="background: #f8fafc; padding: 14px 18px; border-radius: 6px; border-left: 4px solid #4338ca; margin-bottom: 18px;">
                        <span style="color: #334155; font-size: 12px; font-weight: 700; text-transform: uppercase;">
                            Yêu Cầu Năng Lực Cốt Lõi:
                        </span>
                        <p style="margin: 4px 0 0 0; font-size: 13.5px; color: #1e293b; line-height: 1.5;">
                            <%= criteria.getCompetencySummary() %>
                        </p>
                    </div>
                <% } %>

                <!-- Thanh Tiến Độ Tích Lũy -->
                <div style="background: #f1f5f9; padding: 14px 18px; border-radius: 8px; margin-bottom: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                        <span style="font-size: 13px; font-weight: 700; color: #334155;">
                            Tiến Độ Hoàn Thành Điều Kiện Bắt Buộc:
                        </span>
                        <span style="font-size: 13px; font-weight: 800; color: <%= (progressPercent == 100) ? "#059669" : "#4338ca" %>;">
                            <%= completedMandatory %> / <%= totalMandatory %> điều kiện (<%= progressPercent %>%)
                        </span>
                    </div>
                    <div style="width: 100%; height: 8px; background: #e2e8f0; border-radius: 4px; overflow: hidden;">
                        <div style="width: <%= progressPercent %>%; height: 100%; background: <%= (progressPercent == 100) ? "#059669" : "#4338ca" %>; transition: width 0.3s ease;"></div>
                    </div>
                    <p style="font-size: 12px; color: #64748b; margin: 6px 0 0 0;">
                        Lưu ý: Hệ thống sẽ tự động kích hoạt quyết định bổ nhiệm và thăng cấp ngay khi tất cả các tiêu chí bắt buộc đạt 100%.
                    </p>
                </div>

                <div class="table-responsive">
                    <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 13px;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0;">
                                <th style="padding: 10px 12px; text-align: center; width: 45px; color: #475569;">STT</th>
                                <th style="padding: 10px 12px; text-align: left; color: #475569;">Tiêu chuẩn điều kiện</th>
                                <th style="padding: 10px 12px; text-align: left; width: 140px; color: #475569;">Phân loại</th>
                                <th style="padding: 10px 12px; text-align: left; width: 220px; color: #475569;">Chuẩn yêu cầu</th>
                                <th style="padding: 10px 12px; text-align: left; color: #475569;">Minh chứng của bạn</th>
                                <th style="padding: 10px 12px; text-align: center; width: 120px; color: #475569;">Trạng thái</th>
                                <th style="padding: 10px 12px; text-align: center; width: 130px; color: #475569;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int itemIndex = 1;

                                // Dòng 1: Điểm thi sát hạch lý thuyết
                                if (criteria.getMinTestScore() != null && criteria.getMinTestScore().doubleValue() > 0) {
                                    boolean hasScore = (existingRequest != null && existingRequest.getTestScore() != null);
                                    boolean isTestPassed = (hasScore && existingRequest.getTestScore().compareTo(criteria.getMinTestScore()) >= 0);
                            %>
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 12px; text-align: center; color: #64748b; font-weight: 600;"><%= itemIndex++ %></td>
                                <td style="padding: 12px;">
                                    <strong style="color: #0f172a;">Bài thi khảo sát sát hạch chuyên môn</strong>
                                    <span style="color: #dc2626; font-size: 11px; font-weight: 700; margin-left: 4px;">(Bắt buộc)</span>
                                </td>
                                <td style="padding: 12px;">
                                    <span style="background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600;">Sát hạch</span>
                                </td>
                                <td style="padding: 12px; color: #334155;">
                                    Điểm bài thi chuyên môn sàn: <strong>&gt;= <%= criteria.getMinTestScore() %>đ</strong>
                                </td>
                                <td style="padding: 12px;">
                                    <% if (hasScore) { %>
                                        Điểm ghi nhận: <strong><%= existingRequest.getTestScore() %>đ</strong>
                                    <% } else { %>
                                        <span style="color: #94a3b8;">Chưa ghi nhận điểm thi</span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <% if (isTestPassed) { %>
                                        <span style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">Đạt</span>
                                    <% } else { %>
                                        <span style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11.5px;">Chưa đạt</span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <% if (isTestPassed) { %>
                                        <span style="color: #059669; font-weight: 700; font-size: 12px;">Đã ghi nhận</span>
                                    <% } else { %>
                                        <form action="<%= request.getContextPath() %>/career-path" method="POST" style="margin: 0; display: inline;">
                                            <input type="hidden" name="action" value="submitDemoTestScore">
                                            <input type="hidden" name="requestId" value="<%= (existingRequest != null) ? existingRequest.getRequestId() : "" %>">
                                            <button type="submit" class="btn btn-sm btn-primary" style="font-size: 11.5px; padding: 4px 10px; font-weight: 600;" title="Bấm để làm bài thi / ghi nhận điểm thi chuyên môn đạt chuẩn 85đ">
                                                Làm bài thi (Nhận 85đ)
                                            </button>
                                        </form>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>

                            <%
                                // Dòng 2: Điểm đánh giá năng lực của Trưởng phòng
                                if (criteria.getMinManagerRating() != null && criteria.getMinManagerRating().doubleValue() > 0) {
                                    boolean hasRating = (existingRequest != null && existingRequest.getManagerRating() != null);
                                    boolean isRatingPassed = (hasRating && existingRequest.getManagerRating().compareTo(criteria.getMinManagerRating()) >= 0);
                            %>
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 12px; text-align: center; color: #64748b; font-weight: 600;"><%= itemIndex++ %></td>
                                <td style="padding: 12px;">
                                    <strong style="color: #0f172a;">Đánh giá năng lực kín từ Trưởng phòng</strong>
                                    <span style="color: #dc2626; font-size: 11px; font-weight: 700; margin-left: 4px;">(Bắt buộc)</span>
                                </td>
                                <td style="padding: 12px;">
                                    <span style="background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600;">Đánh giá quản lý</span>
                                </td>
                                <td style="padding: 12px; color: #334155;">
                                    Điểm đánh giá sàn: <strong>&gt;= <%= criteria.getMinManagerRating() %>/10</strong>
                                </td>
                                <td style="padding: 12px;">
                                    <% if (hasRating) { %>
                                        Điểm Trưởng phòng chấm: <strong><%= existingRequest.getManagerRating() %>/10</strong>
                                    <% } else { %>
                                        <span style="color: #94a3b8;">Đang chờ Trưởng phòng đánh giá</span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <% if (isRatingPassed) { %>
                                        <span style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">Đạt</span>
                                    <% } else if (hasRating) { %>
                                        <span style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11.5px;">Chưa đạt</span>
                                    <% } else { %>
                                        <span style="background: #fef3c7; color: #92400e; border: 1px solid #fde68a; padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11.5px;">Chờ thẩm định</span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px; text-align: center; color: #64748b; font-size: 12px;">
                                    Quản lý thẩm định
                                </td>
                            </tr>
                            <% } %>

                            <%
                                // Các dòng tiêu chí minh chứng thực tế
                                if (criteria.getRequirements() != null && !criteria.getRequirements().isEmpty()) {
                                    for (CriteriaRequirement req : criteria.getRequirements()) {
                                        PromotionEvidence userEv = null;
                                        if (existingRequest != null && existingRequest.getEvidenceList() != null) {
                                            for (PromotionEvidence ev : existingRequest.getEvidenceList()) {
                                                if (ev.getRequirementId() == req.getRequirementId()) {
                                                    userEv = ev;
                                                    break;
                                                }
                                            }
                                        }

                                        boolean isSubmitted = (userEv != null && userEv.getEvidenceSummary() != null && !userEv.getEvidenceSummary().trim().isEmpty());
                                        boolean isVerified = (userEv != null && userEv.isVerified());
                            %>
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 12px; text-align: center; color: #64748b; font-weight: 600;"><%= itemIndex++ %></td>
                                <td style="padding: 12px;">
                                    <strong style="color: #0f172a;"><%= req.getRequirementTitle() %></strong>
                                    <% if (req.isMandatory()) { %>
                                        <span style="color: #dc2626; font-size: 11px; font-weight: 700; margin-left: 4px;">(Bắt buộc)</span>
                                    <% } else { %>
                                        <span style="color: #64748b; font-size: 11px; margin-left: 4px;">(Tự chọn)</span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px;">
                                    <span style="background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600;">
                                        <%= req.getRequirementTypeBadge() %>
                                    </span>
                                </td>
                                <td style="padding: 12px; color: #475569; font-size: 12.5px;">
                                    <%= (req.getDescription() != null && !req.getDescription().trim().isEmpty()) ? req.getDescription() : "-" %>
                                </td>
                                <td style="padding: 12px;">
                                    <% if (isSubmitted) { %>
                                        <div style="font-weight: 600; color: #1e293b; margin-bottom: 3px;"><%= userEv.getEvidenceSummary() %></div>
                                        <% if (userEv.getEvidenceUrl() != null && !userEv.getEvidenceUrl().trim().isEmpty()) { %>
                                            <a href="<%= userEv.getEvidenceUrl() %>" target="_blank" style="color: #4338ca; font-size: 11.5px; text-decoration: underline;">
                                                Xem tài liệu liên kết
                                            </a>
                                        <% } %>
                                        <% if (userEv.getVerificationComment() != null && !userEv.getVerificationComment().trim().isEmpty()) { %>
                                            <div style="color: #64748b; font-size: 11px; margin-top: 2px;">
                                                Nhận xét: <%= userEv.getVerificationComment() %>
                                            </div>
                                        <% } %>
                                    <% } else { %>
                                        <span style="color: #94a3b8;">Chưa cung cấp minh chứng</span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <% if (isVerified) { %>
                                        <span style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 11.5px;">
                                            Đạt
                                        </span>
                                    <% } else if (isSubmitted) { %>
                                        <span style="background: #fef3c7; color: #92400e; border: 1px solid #fde68a; padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11.5px;">
                                            Chờ duyệt
                                        </span>
                                    <% } else { %>
                                        <span style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11.5px;">
                                            Chưa nộp
                                        </span>
                                    <% } %>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <% if (isVerified) { %>
                                        <span style="color: #059669; font-weight: 700; font-size: 12px;">Đã ghi nhận</span>
                                    <% } else if (isSubmitted) { %>
                                        <button type="button" class="btn btn-sm btn-secondary" style="padding: 4px 10px; font-size: 12px;"
                                                onclick="openEvidenceModal(<%= req.getRequirementId() %>, '<%= req.getRequirementTitle().replace("'", "\\'") %>', '<%= userEv.getEvidenceSummary().replace("'", "\\'") %>', '<%= (userEv.getEvidenceUrl() != null ? userEv.getEvidenceUrl().replace("'", "\\'") : "") %>')">
                                            Cập nhật
                                        </button>
                                    <% } else { %>
                                        <button type="button" class="btn btn-sm btn-primary" style="padding: 4px 10px; font-size: 12px;"
                                                onclick="openEvidenceModal(<%= req.getRequirementId() %>, '<%= req.getRequirementTitle().replace("'", "\\'") %>', '', '')">
                                            Nộp minh chứng
                                        </button>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- MODAL POPUP NỘP / CẬP NHẬT MINH CHỨNG CHO TỪNG TIÊU CHÍ (KHÔNG DÙNG ICON) -->
            <% if (existingRequest != null) { %>
            <div id="evidenceModalOverlay" style="display: none; position: fixed; inset: 0; z-index: 99999; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); justify-content: center; align-items: center; padding: 20px;">
                <div style="background: #ffffff; width: 560px; max-width: 100%; border-radius: 10px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2); overflow: hidden; display: flex; flex-direction: column;">
                    <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0f172a;">Nộp Minh Chứng Tiêu Chuẩn</h3>
                            <div id="modalReqTitle" style="font-size: 12.5px; color: #64748b; margin-top: 2px;">Tiêu chí: -</div>
                        </div>
                        <button type="button" onclick="closeEvidenceModal()" style="border: none; background: transparent; font-size: 18px; color: #94a3b8; cursor: pointer; padding: 4px;">
                            X
                        </button>
                    </div>

                    <form action="<%= request.getContextPath() %>/career-path" method="POST" style="margin: 0;" novalidate onsubmit="return validateEvidenceForm(event);">
                        <input type="hidden" name="action" value="submitSingleEvidence">
                        <input type="hidden" name="requestId" value="<%= existingRequest.getRequestId() %>">
                        <input type="hidden" id="modalRequirementId" name="requirementId" value="">

                        <div style="padding: 20px;">
                            <div style="margin-bottom: 14px;">
                                <label style="display: block; font-weight: 600; font-size: 13.5px; color: #334155; margin-bottom: 6px;">
                                    Tóm tắt kết quả minh chứng:
                                </label>
                                <textarea id="modalSummary" name="evidenceSummary" rows="3" class="form-control"
                                          placeholder="Mô tả cụ thể kết quả đạt được, vai trò của bạn trong dự án hoặc mã số chứng chỉ..."
                                          style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13.5px;"
                                          oninput="document.getElementById('modalSummaryError').style.display = 'none';"></textarea>
                                <div id="modalSummaryError" style="color: #dc2626; font-size: 12px; margin-top: 5px; display: none; font-weight: 500;">
                                    Vui lòng nhập tóm tắt nội dung minh chứng.
                                </div>
                            </div>

                            <div style="margin-bottom: 14px;">
                                <label style="display: block; font-weight: 600; font-size: 13.5px; color: #334155; margin-bottom: 6px;">
                                    Đường dẫn liên kết tài liệu minh chứng (Google Drive / GitHub / Báo cáo online):
                                </label>
                                <input type="text" id="modalUrl" name="evidenceUrl" class="form-control"
                                       placeholder="https://drive.google.com/... hoặc https://github.com/..."
                                       style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13.5px;"
                                       oninput="document.getElementById('modalUrlError').style.display = 'none';">
                                <div id="modalUrlError" style="color: #dc2626; font-size: 12px; margin-top: 5px; display: none; font-weight: 500;">
                                    Đường dẫn không hợp lệ. Vui lòng nhập đúng định dạng URL (ví dụ: https://...).
                                </div>
                            </div>

                            <div style="padding: 10px 12px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 6px; font-size: 12px; color: #166534; line-height: 1.5;">
                                Thông tin sau khi lưu sẽ được gửi tới Trưởng phòng thẩm định. Hệ thống sẽ tự động nâng bậc ngay khi hoàn thành tất cả các điều kiện bắt buộc.
                            </div>
                        </div>

                        <div style="padding: 12px 20px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end; gap: 10px;">
                            <button type="button" class="btn btn-secondary" onclick="closeEvidenceModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary">Lưu Minh Chứng</button>
                        </div>
                    </form>
                </div>
            </div>

            <script>
            function isValidUrl(string) {
                if (!string) return true;
                var trimmed = string.trim();
                if (!trimmed) return true;
                try {
                    var parsed = new URL(trimmed);
                    return parsed.protocol === "http:" || parsed.protocol === "https:";
                } catch (_) {
                    return false;
                }
            }

            function validateEvidenceForm(e) {
                var summary = document.getElementById('modalSummary').value.trim();
                var url = document.getElementById('modalUrl').value.trim();
                var summaryErr = document.getElementById('modalSummaryError');
                var urlErr = document.getElementById('modalUrlError');
                var isValid = true;

                summaryErr.style.display = 'none';
                urlErr.style.display = 'none';

                if (!summary) {
                    summaryErr.style.display = 'block';
                    isValid = false;
                }

                if (url && !isValidUrl(url)) {
                    urlErr.style.display = 'block';
                    isValid = false;
                }

                if (!isValid) {
                    if (e) e.preventDefault();
                    return false;
                }
                return true;
            }

            function openEvidenceModal(reqId, reqTitle, currentSummary, currentUrl) {
                document.getElementById('modalRequirementId').value = reqId;
                document.getElementById('modalReqTitle').innerText = 'Tiêu chí: ' + reqTitle;
                document.getElementById('modalSummary').value = currentSummary ? currentSummary : '';
                document.getElementById('modalUrl').value = currentUrl ? currentUrl : '';
                document.getElementById('modalSummaryError').style.display = 'none';
                document.getElementById('modalUrlError').style.display = 'none';
                var modal = document.getElementById('evidenceModalOverlay');
                if (modal) modal.style.display = 'flex';
            }
            function closeEvidenceModal() {
                var modal = document.getElementById('evidenceModalOverlay');
                if (modal) modal.style.display = 'none';
                document.getElementById('modalSummaryError').style.display = 'none';
                document.getElementById('modalUrlError').style.display = 'none';
            }
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closeEvidenceModal();
            });
            </script>
            <% } %>

        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
