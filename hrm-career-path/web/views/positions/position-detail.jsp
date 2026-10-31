<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.Position" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.PositionLevelCriteria" %>
<%@ page import="model.CriteriaRequirement" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    Position pos = (Position) request.getAttribute("position");
    List<JobLevel> levels = (List<JobLevel>) request.getAttribute("levels");
    List<PositionLevelCriteria> criteriaList = (List<PositionLevelCriteria>) request.getAttribute("criteriaList");

    String posTitle = (pos != null) ? pos.getPositionName() : "Vị Trí Chuyên Môn";
    request.setAttribute("pageTitle", "Chi Tiết Vị Trí: " + posTitle + " | CPMS");

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<style>
.tab-btn {
    padding: 12px 20px;
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
    border: none;
    background: transparent;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s ease;
}
.tab-btn:hover {
    color: #1e293b;
}
.tab-btn.active {
    color: #4f46e5;
    border-bottom-color: #4f46e5;
    font-weight: 700;
}
.inline-error {
    color: #dc2626;
    font-size: 12px;
    margin-top: 4px;
    display: none;
    font-weight: 500;
}
</style>

<main class="main-content">
    <div class="topbar">
        <div>
            <div style="font-size: 12.5px; color: #64748b; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                <a href="<%= request.getContextPath() %>/positions" style="color: #64748b; text-decoration: none;">Vị Trí Chuyên Môn</a>
                <i class="fa-solid fa-chevron-right" style="font-size: 10px;"></i>
                <span style="color: #1e293b; font-weight: 600;"><%= pos != null ? pos.getPositionName() : "" %></span>
            </div>
            <h1 style="margin: 0; font-size: 22px; color: #0f172a;">
                <%= pos != null ? pos.getPositionName() : "Chi Tiết Vị Trí" %>
            </h1>
        </div>
        <div style="display: flex; gap: 8px;">
            <a href="<%= request.getContextPath() %>/positions?action=criteria&positionId=<%= pos != null ? pos.getPositionId() : 0 %>" class="btn btn-primary" title="Mở trang quản trị barem tiêu chí chuyên sâu">
                <i class="fa-solid fa-stairs"></i> Quản Lý Barem Tiêu Chí
            </a>
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">
                <i class="fa-solid fa-arrow-left"></i> Danh Sách Vị Trí
            </a>
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

        <% if (pos == null) { %>
            <div class="card" style="padding: 30px; text-align: center;">
                <p style="color: #dc2626; font-weight: 600;">Không tìm thấy thông tin vị trí chuyên môn này!</p>
                <a href="<%= request.getContextPath() %>/positions" class="btn btn-primary">Quay lại danh sách</a>
            </div>
        <% } else { %>

            <!-- THẺ THÔNG TIN TỔNG QUAN VỊ TRÍ -->
            <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 24px; padding: 22px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 14px;">
                    <div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <h2 style="font-size: 18px; margin: 0; color: #1e293b;"><%= pos.getPositionName() %></h2>
                            <% if (pos.isStatus()) { %>
                                <span class="badge" style="font-size: 12px; padding: 3px 10px; background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; border-radius: 20px;">
                                    <i class="fa-solid fa-circle-check"></i> Đang áp dụng
                                </span>
                            <% } else { %>
                                <span class="badge" style="font-size: 12px; padding: 3px 10px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 20px;">
                                    <i class="fa-solid fa-ban"></i> Tạm khóa
                                </span>
                            <% } %>
                        </div>
                        <p style="margin: 6px 0 0 0; color: #64748b; font-size: 13.5px;">
                            <%= (pos.getDescription() != null && !pos.getDescription().trim().isEmpty()) ? pos.getDescription() : "Chưa có mô tả chi tiết cho vị trí này." %>
                        </p>
                    </div>
                    <% if (roleId == 1) { %>
                    <div>
                        <a href="<%= request.getContextPath() %>/positions?action=edit&id=<%= pos.getPositionId() %>" class="btn btn-sm btn-secondary" style="font-size: 13px;">
                            <i class="fa-solid fa-pen-to-square"></i> Sửa thông tin vị trí
                        </a>
                    </div>
                    <% } %>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px;">
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Phòng Ban Quản Lý:</span>
                        <div style="margin-top: 4px; font-weight: 700; color: #1e293b; font-size: 14px;">
                            <i class="fa-solid fa-building" style="color: #4f46e5; margin-right: 6px;"></i>
                            <%= pos.getDepartmentName() != null ? pos.getDepartmentName() : "Dùng chung toàn công ty" %>
                        </div>
                    </div>
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Quy Mô Nhân Sự Hiện Tại:</span>
                        <div style="margin-top: 4px; font-weight: 700; color: #0284c7; font-size: 14px;">
                            <i class="fa-solid fa-users" style="margin-right: 6px;"></i>
                            <a href="<%= request.getContextPath() %>/employees?positionId=<%= pos.getPositionId() %>" style="color: #0284c7; text-decoration: none;">
                                <%= pos.getEmployeeCount() %> Nhân sự
                            </a>
                        </div>
                    </div>
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Số Cấp Bậc Riêng Cấu Hình:</span>
                        <div style="margin-top: 4px; font-weight: 700; color: #1e293b; font-size: 14px;">
                            <i class="fa-solid fa-layer-group" style="color: #059669; margin-right: 6px;"></i>
                            <%= levels != null ? levels.size() : 0 %> Cấp bậc
                        </div>
                    </div>
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Ngày Tạo Hồ Sơ:</span>
                        <div style="margin-top: 4px; font-weight: 600; color: #334155; font-size: 13.5px;">
                            <i class="fa-regular fa-calendar-days" style="color: #64748b; margin-right: 6px;"></i>
                            <%= (pos.getCreatedAt() != null) ? sdf.format(pos.getCreatedAt()) : "--/--/----" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB ĐIỀU HƯỚNG CẤP BẬC & LỘ TRÌNH -->
            <div style="display: flex; border-bottom: 2px solid #e2e8f0; margin-bottom: 20px;">
                <button type="button" class="tab-btn active" id="tabBtnLevels" onclick="switchTab('levels')">
                    <i class="fa-solid fa-layer-group"></i> Thang Cấp Bậc Riêng (Job Levels)
                    <span style="background: #e0e7ff; color: #4338ca; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-weight: 700;">
                        <%= levels != null ? levels.size() : 0 %>
                    </span>
                </button>
                <button type="button" class="tab-btn" id="tabBtnCriteria" onclick="switchTab('criteria')">
                    <i class="fa-solid fa-stairs"></i> Lộ Trình &amp; Barem Thăng Tiến
                    <span style="background: #ecfdf5; color: #047857; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-weight: 700;">
                        <%= criteriaList != null ? criteriaList.size() : 0 %>
                    </span>
                </button>
            </div>

            <!-- PHẦN 1: THANG CẤP BẬC CỦA VỊ TRÍ (TAB LEVELS) -->
            <div id="tabContentLevels">
                <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden;">
                    <div class="card-header" style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h3 style="margin: 0; font-size: 15px; color: #1e293b;">
                                <i class="fa-solid fa-layer-group" style="color: #4f46e5; margin-right: 6px;"></i> Danh Mục Cấp Bậc Của Vị Trí: <%= pos.getPositionName() %>
                            </h3>
                            <span style="color: #64748b; font-size: 12.5px;">Cấp bậc được sắp xếp theo thứ tự bậc tăng dần (Rank 1 là bậc khởi điểm, Rank càng cao bậc càng lớn).</span>
                        </div>
                        <% if (roleId == 1) { %>
                        <div style="display: flex; gap: 8px;">
                            <button type="button" class="btn btn-sm btn-primary" onclick="openAddLevelModal()">
                                <i class="fa-solid fa-plus"></i> Thêm Cấp Bậc Mới
                            </button>
                        </div>
                        <% } %>
                    </div>

                    <div class="card-body" style="padding: 0;">
                        <% if (levels == null || levels.isEmpty()) { %>
                            <div style="padding: 40px 20px; text-align: center;">
                                <i class="fa-solid fa-cubes-stacked" style="font-size: 42px; color: #cbd5e1; margin-bottom: 14px;"></i>
                                <h4 style="color: #334155; margin-bottom: 6px;">Vị trí này chưa có thang cấp bậc riêng!</h4>
                                <p style="color: #64748b; font-size: 13.5px; max-width: 500px; margin: 0 auto 18px auto;">
                                    Bạn có thể khởi tạo nhanh bộ 6 cấp bậc tiêu chuẩn của công ty (Intern &rarr; Fresher &rarr; Junior &rarr; Middle &rarr; Senior &rarr; Lead) hoặc tự thêm các cấp bậc tùy chỉnh.
                                </p>
                                <% if (roleId == 1) { %>
                                <div style="display: flex; gap: 10px; justify-content: center;">
                                    <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;">
                                        <input type="hidden" name="action" value="copyDefaultLevels">
                                        <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                        <button type="submit" class="btn btn-success">
                                            <i class="fa-solid fa-wand-magic-sparkles"></i> Khởi Tạo 6 Cấp Bậc Tiêu Chuẩn
                                        </button>
                                    </form>
                                    <button type="button" class="btn btn-primary" onclick="openAddLevelModal()">
                                        <i class="fa-solid fa-plus"></i> Thêm Cấp Bậc Tùy Chỉnh
                                    </button>
                                </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 13.5px;">
                                <thead>
                                    <tr style="background: #f1f5f9; border-bottom: 1px solid #e2e8f0;">
                                        <th style="padding: 12px 16px; width: 90px; text-align: center;">Thứ Tự</th>
                                        <th style="padding: 12px 16px; width: 200px;">Tên Cấp Bậc</th>
                                        <th style="padding: 12px 16px;">Mô Tả / Tiêu Chuẩn Vị Trí</th>
                                        <% if (roleId == 1) { %>
                                        <th style="padding: 12px 16px; width: 130px; text-align: center;">Thao Tác</th>
                                        <% } %>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (JobLevel lvl : levels) { %>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 14px 16px; text-align: center;">
                                            <span style="background: #e0e7ff; color: #3730a3; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 13px;">
                                                Bậc <%= lvl.getRankOrder() %>
                                            </span>
                                        </td>
                                        <td style="padding: 14px 16px;">
                                            <strong style="color: #1e293b; font-size: 14px;"><%= lvl.getLevelName() %></strong>
                                        </td>
                                        <td style="padding: 14px 16px; color: #475569;">
                                            <%= (lvl.getDescription() != null && !lvl.getDescription().trim().isEmpty()) ? lvl.getDescription() : "<em style='color: #94a3b8;'>Chưa có mô tả</em>" %>
                                        </td>
                                        <% if (roleId == 1) { %>
                                        <td style="padding: 14px 16px; text-align: center;">
                                            <div style="display: flex; gap: 8px; justify-content: center;">
                                                <button type="button" class="btn btn-sm btn-secondary" style="font-size: 12px; padding: 4px 8px;"
                                                        onclick="openEditLevelModal(<%= lvl.getLevelId() %>, '<%= lvl.getLevelName().replace("'", "\\'") %>', <%= lvl.getRankOrder() %>, '<%= (lvl.getDescription() != null ? lvl.getDescription().replace("'", "\\'") : "").replace("\n", " ") %>')">
                                                    <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                </button>
                                                <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa cấp bậc này khỏi vị trí?');">
                                                    <input type="hidden" name="action" value="deleteLevel">
                                                    <input type="hidden" name="levelId" value="<%= lvl.getLevelId() %>">
                                                    <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                                    <button type="submit" class="btn btn-sm btn-danger" style="font-size: 12px; padding: 4px 8px;" title="Xóa cấp bậc">
                                                        <i class="fa-solid fa-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                        <% } %>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- PHẦN 2: LỘ TRÌNH & BAREM THĂNG TIẾN (TAB CRITERIA) -->
            <div id="tabContentCriteria" style="display: none;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <div>
                        <h3 style="margin: 0; font-size: 16px; color: #1e293b;">
                            <i class="fa-solid fa-stairs" style="color: #4f46e5; margin-right: 6px;"></i> Lộ Trình &amp; Barem Thăng Tiến Của Vị Trí
                        </h3>
                        <p style="margin: 4px 0 0 0; color: #64748b; font-size: 13px;">
                            Cấu hình các nấc thăng tiến từ bậc thấp lên bậc cao hơn, quy định điểm bài thi sát hạch và yêu cầu minh chứng thực tế.
                        </p>
                    </div>
                    <% if (roleId == 1) { %>
                    <div style="display: flex; gap: 8px;">
                        <button type="button" class="btn btn-primary" onclick="openAddCriteriaModal()">
                            <i class="fa-solid fa-plus"></i> Thêm Nấc Thăng Tiến
                        </button>
                        <a href="<%= request.getContextPath() %>/positions?action=criteria&positionId=<%= pos.getPositionId() %>" class="btn btn-outline-primary">
                            <i class="fa-solid fa-arrow-up-right-from-square"></i> Trang Barem Chuyên Sâu
                        </a>
                    </div>
                    <% } %>
                </div>

                <% if (criteriaList == null || criteriaList.isEmpty()) { %>
                    <div class="card" style="padding: 40px; text-align: center; background: #ffffff; border-radius: 8px;">
                        <i class="fa-solid fa-stairs" style="font-size: 48px; color: #cbd5e1; margin-bottom: 16px;"></i>
                        <h4 style="color: #334155;">Chưa cấu hình Barem thăng tiến cho vị trí này</h4>
                        <p style="color: #64748b; font-size: 14px; max-width: 500px; margin: 0 auto 20px auto;">
                            Sau khi thiết lập cấp bậc, Admin có thể tạo các nấc thăng tiến (ví dụ: Fresher lên Junior) và quy định điểm sàn cùng minh chứng thực tế.
                        </p>
                        <% if (roleId == 1) { %>
                        <button type="button" class="btn btn-primary" onclick="openAddCriteriaModal()">
                            <i class="fa-solid fa-plus"></i> Thiết Lập Nấc Thăng Tiến Đầu Tiên
                        </button>
                        <% } %>
                    </div>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 18px;">
                        <% for (PositionLevelCriteria crit : criteriaList) { %>
                        <div class="card" style="border: 1px solid #e2e8f0; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.03); background: #ffffff; overflow: hidden;">
                            <div style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; padding: 14px 20px; display: flex; justify-content: space-between; align-items: center;">
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <span style="background: #e0e7ff; color: #4338ca; font-weight: 700; padding: 4px 10px; border-radius: 6px; font-size: 13.5px;">
                                        Bậc: <%= crit.getFromLevelName() %>
                                    </span>
                                    <i class="fa-solid fa-arrow-right" style="color: #94a3b8; font-size: 14px;"></i>
                                    <span style="background: #ecfdf5; color: #047857; font-weight: 700; padding: 4px 10px; border-radius: 6px; font-size: 13.5px;">
                                        Mục tiêu: <%= crit.getToLevelName() %>
                                    </span>
                                </div>
                                <% if (roleId == 1) { %>
                                <div style="display: flex; gap: 8px;">
                                    <button type="button" class="btn btn-sm btn-secondary" style="font-size: 12px;"
                                            onclick="openAddReqModal(<%= crit.getCriteriaId() %>, '<%= crit.getFromLevelName() %> lên <%= crit.getToLevelName() %>')">
                                        <i class="fa-solid fa-plus"></i> Thêm Minh Chứng
                                    </button>
                                    <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa nấc barem này?');">
                                        <input type="hidden" name="action" value="deleteCriteria">
                                        <input type="hidden" name="criteriaId" value="<%= crit.getCriteriaId() %>">
                                        <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                        <input type="hidden" name="returnTo" value="detail">
                                        <button type="submit" class="btn btn-sm btn-danger" style="font-size: 12px;">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </div>
                                <% } %>
                            </div>

                            <div style="padding: 18px;">
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 16px;">
                                    <div style="background: #f8fafc; padding: 12px 14px; border-radius: 8px; border-left: 4px solid #4f46e5;">
                                        <span style="font-size: 12px; color: #64748b; font-weight: 600; text-transform: uppercase;">Năng lực cốt lõi yêu cầu:</span>
                                        <p style="margin: 6px 0 0 0; font-size: 13.5px; color: #1e293b; line-height: 1.5;">
                                            <%= crit.getCompetencySummary() %>
                                        </p>
                                    </div>
                                    <div style="background: #f8fafc; padding: 12px 14px; border-radius: 8px; border-left: 4px solid #059669;">
                                        <span style="font-size: 12px; color: #64748b; font-weight: 600; text-transform: uppercase;">Chuẩn điểm đánh giá:</span>
                                        <p style="margin: 6px 0 0 0; font-size: 13.5px; color: #1e293b;">
                                            • Điểm bài test sát hạch: <strong style="color: #059669;">≥ <%= crit.getMinTestScore() %>đ</strong><br>
                                            • Đánh giá kín từ Manager: <strong style="color: #4338ca;">≥ <%= crit.getMinManagerRating() %>/10đ</strong>
                                        </p>
                                    </div>
                                </div>

                                <!-- Tiêu chí minh chứng thực tế -->
                                <div>
                                    <div style="font-size: 13px; font-weight: 700; color: #334155; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
                                        <i class="fa-solid fa-list-check" style="color: #4f46e5;"></i> 
                                        Tiêu chí minh chứng thực tế:
                                    </div>
                                    <% if (crit.getRequirements() == null || crit.getRequirements().isEmpty()) { %>
                                        <p style="font-size: 12.5px; color: #94a3b8; font-style: italic; margin-left: 8px;">
                                            Chưa cấu hình tiêu chí minh chứng bổ sung (chỉ cần đạt chuẩn bài test và điểm Manager).
                                        </p>
                                    <% } else { %>
                                        <table class="data-table" style="width: 100%; font-size: 12.5px;">
                                            <thead>
                                                <tr style="background: #f1f5f9;">
                                                    <th style="width: 40px; text-align: center;">STT</th>
                                                    <th>Nội dung yêu cầu</th>
                                                    <th style="width: 160px;">Phân loại</th>
                                                    <th style="width: 110px; text-align: center;">Bắt buộc?</th>
                                                    <% if (roleId == 1) { %>
                                                    <th style="width: 60px; text-align: center;">Xóa</th>
                                                    <% } %>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% int rIdx = 1; for (CriteriaRequirement req : crit.getRequirements()) { %>
                                                <tr>
                                                    <td style="text-align: center; color: #64748b;"><%= rIdx++ %></td>
                                                    <td>
                                                        <strong style="color: #1e293b;"><%= req.getRequirementTitle() %></strong>
                                                        <% if (req.getDescription() != null && !req.getDescription().trim().isEmpty()) { %>
                                                            <div style="color: #64748b; font-size: 11.5px; margin-top: 2px;">
                                                                <%= req.getDescription() %>
                                                            </div>
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <span style="background: #f1f5f9; color: #334155; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: 600;">
                                                            <%= req.getRequirementTypeBadge() %>
                                                        </span>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <% if (req.isMandatory()) { %>
                                                            <span style="color: #dc2626; font-weight: 700; font-size: 11.5px;"><i class="fa-solid fa-asterisk"></i> Bắt buộc</span>
                                                        <% } else { %>
                                                            <span style="color: #64748b; font-size: 11.5px;">Khuyến khích</span>
                                                        <% } %>
                                                    </td>
                                                    <% if (roleId == 1) { %>
                                                    <td style="text-align: center;">
                                                        <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Xóa tiêu chí này?');">
                                                            <input type="hidden" name="action" value="deleteRequirement">
                                                            <input type="hidden" name="requirementId" value="<%= req.getRequirementId() %>">
                                                            <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                                            <input type="hidden" name="returnTo" value="detail">
                                                            <button type="submit" style="background: none; border: none; color: #ef4444; cursor: pointer;" title="Xóa">
                                                                <i class="fa-solid fa-trash-can"></i>
                                                            </button>
                                                        </form>
                                                    </td>
                                                    <% } %>
                                                </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

        <% } %>
    </div>
</main>

<!-- MODAL 1: THÊM CẤP BẬC MỚI -->
<div id="addLevelModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 90%; max-width: 520px; border-radius: 12px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <h3 style="margin: 0; color: #1e293b; font-size: 17px;">
                <i class="fa-solid fa-plus-circle" style="color: #4f46e5;"></i> Thêm Cấp Bậc Cho Vị Trí
            </h3>
            <button type="button" onclick="closeAddLevelModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form id="addLevelForm" action="<%= request.getContextPath() %>/positions" method="POST" novalidate onsubmit="return validateAddLevelForm(event);">
            <input type="hidden" name="action" value="addLevel">
            <input type="hidden" name="positionId" value="<%= pos != null ? pos.getPositionId() : 0 %>">

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 600; font-size: 13px;">Tên Cấp Bậc (*):</label>
                <input type="text" id="addLevelName" name="levelName" class="form-control" placeholder="Ví dụ: Intern, Fresher, Senior, Lead..." oninput="clearFieldError(this, 'err_addLevelName')">
                <div id="err_addLevelName" class="inline-error"></div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 600; font-size: 13px;">Thứ Tự Bậc (Rank Order) (*):</label>
                <input type="number" id="addRankOrder" name="rankOrder" class="form-control" placeholder="1, 2, 3..." value="<%= (levels != null ? levels.size() + 1 : 1) %>" oninput="clearFieldError(this, 'err_addRankOrder')">
                <small style="color: #64748b; font-size: 12px;">Số nguyên > 0. Càng cao đại diện cho bậc càng cao.</small>
                <div id="err_addRankOrder" class="inline-error"></div>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="font-weight: 600; font-size: 13px;">Mô Tả / Tiêu Chuẩn Năng Lực Bậc:</label>
                <textarea name="description" rows="3" class="form-control" placeholder="Mô tả trách nhiệm hoặc kinh nghiệm yêu cầu của cấp bậc này..."></textarea>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 14px;">
                <button type="button" onclick="closeAddLevelModal()" class="btn btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary">Thêm Cấp Bậc</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL 2: SỬA CẤP BẬC -->
<div id="editLevelModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 90%; max-width: 520px; border-radius: 12px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <h3 style="margin: 0; color: #1e293b; font-size: 17px;">
                <i class="fa-solid fa-pen-to-square" style="color: #4f46e5;"></i> Chỉnh Sửa Cấp Bậc
            </h3>
            <button type="button" onclick="closeEditLevelModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form id="editLevelForm" action="<%= request.getContextPath() %>/positions" method="POST" novalidate onsubmit="return validateEditLevelForm(event);">
            <input type="hidden" name="action" value="editLevel">
            <input type="hidden" id="editLevelId" name="levelId" value="">
            <input type="hidden" name="positionId" value="<%= pos != null ? pos.getPositionId() : 0 %>">

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 600; font-size: 13px;">Tên Cấp Bậc (*):</label>
                <input type="text" id="editLevelName" name="levelName" class="form-control" oninput="clearFieldError(this, 'err_editLevelName')">
                <div id="err_editLevelName" class="inline-error"></div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 600; font-size: 13px;">Thứ Tự Bậc (Rank Order) (*):</label>
                <input type="number" id="editRankOrder" name="rankOrder" class="form-control" oninput="clearFieldError(this, 'err_editRankOrder')">
                <div id="err_editRankOrder" class="inline-error"></div>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="font-weight: 600; font-size: 13px;">Mô Tả / Tiêu Chuẩn Năng Lực Bậc:</label>
                <textarea id="editDescription" name="description" rows="3" class="form-control"></textarea>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 14px;">
                <button type="button" onclick="closeEditLevelModal()" class="btn btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL 3: THÊM NẤC THĂNG TIẾN MỚI -->
<div id="addCriteriaModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 90%; max-width: 650px; border-radius: 12px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto;">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <h3 style="margin: 0; color: #1e293b; font-size: 18px;">Thiết Lập Nấc Barem Thăng Tiến Mới</h3>
            <button type="button" onclick="closeAddCriteriaModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form id="addCriteriaForm" action="<%= request.getContextPath() %>/positions" method="POST" novalidate onsubmit="return validateCriteriaForm(event);">
            <input type="hidden" name="action" value="saveCriteria">
            <input type="hidden" name="positionId" value="<%= pos != null ? pos.getPositionId() : 0 %>">
            <input type="hidden" name="returnTo" value="detail">

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 14px;">
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Từ Cấp Bậc (*):</label>
                    <select id="fromLevelId" name="fromLevelId" class="form-control" onchange="clearFieldError(this, 'err_fromLevelId')">
                        <option value="">-- Chọn Cấp Bậc Hiện Tại --</option>
                        <% if (levels != null) { for (JobLevel lvl : levels) { %>
                            <option value="<%= lvl.getLevelId() %>" data-rank="<%= lvl.getRankOrder() %>">Bậc <%= lvl.getRankOrder() %>. <%= lvl.getLevelName() %></option>
                        <% }} %>
                    </select>
                    <div id="err_fromLevelId" class="inline-error"></div>
                </div>
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Lên Cấp Bậc Mục Tiêu (*):</label>
                    <select id="toLevelId" name="toLevelId" class="form-control" onchange="clearFieldError(this, 'err_toLevelId')">
                        <option value="">-- Chọn Cấp Bậc Đích --</option>
                        <% if (levels != null) { for (JobLevel lvl : levels) { %>
                            <option value="<%= lvl.getLevelId() %>" data-rank="<%= lvl.getRankOrder() %>">Bậc <%= lvl.getRankOrder() %>. <%= lvl.getLevelName() %></option>
                        <% }} %>
                    </select>
                    <div id="err_toLevelId" class="inline-error"></div>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 600; font-size: 13px;">Tóm Tắt Năng Lực Cốt Lõi Yêu Cầu (*):</label>
                <textarea id="competencySummary" name="competencySummary" rows="3" class="form-control" placeholder="Ví dụ: Nắm vững kiến trúc Microservices, làm chủ Docker, tối ưu hóa CSDL..." oninput="clearFieldError(this, 'err_competencySummary')"></textarea>
                <div id="err_competencySummary" class="inline-error"></div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 18px;">
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Điểm Bài Test Sát Hạch Sàn (0 - 100):</label>
                    <input type="number" step="0.1" id="minTestScore" name="minTestScore" class="form-control" value="80.0" oninput="clearFieldError(this, 'err_minTestScore')">
                    <div id="err_minTestScore" class="inline-error"></div>
                </div>
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Điểm Đánh Giá Sàn Từ Manager (1 - 10):</label>
                    <input type="number" step="0.1" id="minManagerRating" name="minManagerRating" class="form-control" value="7.5" oninput="clearFieldError(this, 'err_minManagerRating')">
                    <div id="err_minManagerRating" class="inline-error"></div>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 14px;">
                <button type="button" onclick="closeAddCriteriaModal()" class="btn btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary">Lưu Nấc Barem</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL 4: THÊM TIÊU CHÍ MINH CHỨNG MỞ -->
<div id="addReqModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 90%; max-width: 580px; border-radius: 12px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <div>
                <h3 style="margin: 0; color: #1e293b; font-size: 17px;">Thêm Tiêu Chí Minh Chứng Thực Tế</h3>
                <small id="modalCriteriaSub" style="color: #64748b; font-size: 12.5px;"></small>
            </div>
            <button type="button" onclick="closeAddReqModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form id="addReqForm" action="<%= request.getContextPath() %>/positions" method="POST" novalidate onsubmit="return validateReqForm(event);">
            <input type="hidden" name="action" value="addRequirement">
            <input type="hidden" name="positionId" value="<%= pos != null ? pos.getPositionId() : 0 %>">
            <input type="hidden" id="modalCriteriaId" name="criteriaId" value="">
            <input type="hidden" name="returnTo" value="detail">

            <div class="form-group" style="margin-bottom: 12px;">
                <label style="font-weight: 600; font-size: 13px;">Phân Loại Tiêu Chí (*):</label>
                <select name="requirementType" class="form-control">
                    <option value="PROJECT_EXPERIENCE">Kinh Nghiệm Dự Án Thực Tế (Project Experience)</option>
                    <option value="CUSTOMER_SATISFACTION">Đánh Giá Khách Hàng / CSAT (Customer Satisfaction)</option>
                    <option value="CERTIFICATE">Chứng Chỉ Chuyên Môn / Quốc Tế (External Certificate)</option>
                    <option value="OTHER">Tiêu Chí Khác (Tech Talk, Đóng góp mã nguồn...)</option>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 12px;">
                <label style="font-weight: 600; font-size: 13px;">Tên Tiêu Chí Yêu Cầu (*):</label>
                <input type="text" id="reqTitle" name="requirementTitle" class="form-control" placeholder="Ví dụ: Tham gia tối thiểu 2 dự án thực tế đạt tiến độ" oninput="clearFieldError(this, 'err_reqTitle')">
                <div id="err_reqTitle" class="inline-error"></div>
            </div>

            <div class="form-group" style="margin-bottom: 12px;">
                <label style="font-weight: 600; font-size: 13px;">Hướng Dẫn Cách Nộp Minh Chứng:</label>
                <textarea name="description" rows="2" class="form-control" placeholder="Ví dụ: Đính kèm link nghiệm thu dự án hoặc ảnh thư khen của khách hàng..."></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 8px; cursor: pointer;">
                    <input type="checkbox" name="isMandatory" value="true" checked style="width: 16px; height: 16px;">
                    Đây là tiêu chí Bắt Buộc (Mandatory)
                </label>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 14px;">
                <button type="button" onclick="closeAddReqModal()" class="btn btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary">Thêm Tiêu Chí</button>
            </div>
        </form>
    </div>
</div>

<script>
function switchTab(tab) {
    var tabLevels = document.getElementById('tabContentLevels');
    var tabCriteria = document.getElementById('tabContentCriteria');
    var btnLevels = document.getElementById('tabBtnLevels');
    var btnCriteria = document.getElementById('tabBtnCriteria');

    if (tab === 'levels') {
        tabLevels.style.display = 'block';
        tabCriteria.style.display = 'none';
        btnLevels.classList.add('active');
        btnCriteria.classList.remove('active');
    } else {
        tabLevels.style.display = 'none';
        tabCriteria.style.display = 'block';
        btnCriteria.classList.add('active');
        btnLevels.classList.remove('active');
    }
}

// Level Modals
function openAddLevelModal() {
    clearFieldError(document.getElementById('addLevelName'), 'err_addLevelName');
    clearFieldError(document.getElementById('addRankOrder'), 'err_addRankOrder');
    document.getElementById('addLevelModal').style.display = 'flex';
}
function closeAddLevelModal() {
    document.getElementById('addLevelModal').style.display = 'none';
}

function openEditLevelModal(id, name, rank, desc) {
    document.getElementById('editLevelId').value = id;
    document.getElementById('editLevelName').value = name;
    document.getElementById('editRankOrder').value = rank;
    document.getElementById('editDescription').value = desc || '';
    clearFieldError(document.getElementById('editLevelName'), 'err_editLevelName');
    clearFieldError(document.getElementById('editRankOrder'), 'err_editRankOrder');
    document.getElementById('editLevelModal').style.display = 'flex';
}
function closeEditLevelModal() {
    document.getElementById('editLevelModal').style.display = 'none';
}

// Criteria Modals
function openAddCriteriaModal() {
    clearCriteriaErrors();
    document.getElementById('addCriteriaModal').style.display = 'flex';
}
function closeAddCriteriaModal() {
    document.getElementById('addCriteriaModal').style.display = 'none';
}

function openAddReqModal(criteriaId, stepTitle) {
    clearReqErrors();
    document.getElementById('modalCriteriaId').value = criteriaId;
    document.getElementById('modalCriteriaSub').innerText = 'Cho nấc: ' + stepTitle;
    document.getElementById('addReqModal').style.display = 'flex';
}
function closeAddReqModal() {
    document.getElementById('addReqModal').style.display = 'none';
}

window.onclick = function(event) {
    if (event.target === document.getElementById('addLevelModal')) closeAddLevelModal();
    if (event.target === document.getElementById('editLevelModal')) closeEditLevelModal();
    if (event.target === document.getElementById('addCriteriaModal')) closeAddCriteriaModal();
    if (event.target === document.getElementById('addReqModal')) closeAddReqModal();
};

// Inline Error Helpers
function showError(inputEl, errId, msg) {
    if (inputEl) {
        inputEl.style.borderColor = '#ef4444';
        inputEl.style.backgroundColor = '#fff5f5';
    }
    var errDiv = document.getElementById(errId);
    if (errDiv) {
        errDiv.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> ' + msg;
        errDiv.style.display = 'block';
    }
}

function clearFieldError(inputEl, errId) {
    if (inputEl) {
        inputEl.style.borderColor = '#cbd5e1';
        inputEl.style.backgroundColor = '#ffffff';
    }
    var errDiv = document.getElementById(errId);
    if (errDiv) {
        errDiv.style.display = 'none';
        errDiv.innerHTML = '';
    }
}

function clearCriteriaErrors() {
    var inputs = ['fromLevelId', 'toLevelId', 'competencySummary', 'minTestScore', 'minManagerRating'];
    inputs.forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
            el.style.borderColor = '#cbd5e1';
            el.style.backgroundColor = '#ffffff';
        }
    });
    var inlineErrors = document.querySelectorAll('#addCriteriaModal .inline-error');
    inlineErrors.forEach(function(div) {
        div.style.display = 'none';
        div.innerHTML = '';
    });
}

function clearReqErrors() {
    var el = document.getElementById('reqTitle');
    if (el) {
        el.style.borderColor = '#cbd5e1';
        el.style.backgroundColor = '#ffffff';
    }
    var errDiv = document.getElementById('err_reqTitle');
    if (errDiv) {
        errDiv.style.display = 'none';
        errDiv.innerHTML = '';
    }
}

// Form validations
function validateAddLevelForm(e) {
    var isValid = true;
    var nameInp = document.getElementById('addLevelName');
    var rankInp = document.getElementById('addRankOrder');

    if (!nameInp.value || nameInp.value.trim() === '') {
        showError(nameInp, 'err_addLevelName', 'Vui lòng nhập tên cấp bậc.');
        isValid = false;
    }
    var rank = parseInt(rankInp.value, 10);
    if (isNaN(rank) || rank <= 0) {
        showError(rankInp, 'err_addRankOrder', 'Thứ tự bậc phải là số nguyên dương lớn hơn 0 (ví dụ: 1, 2, 3...).');
        isValid = false;
    }

    if (!isValid) {
        e.preventDefault();
        return false;
    }
    return true;
}

function validateEditLevelForm(e) {
    var isValid = true;
    var nameInp = document.getElementById('editLevelName');
    var rankInp = document.getElementById('editRankOrder');

    if (!nameInp.value || nameInp.value.trim() === '') {
        showError(nameInp, 'err_editLevelName', 'Vui lòng nhập tên cấp bậc.');
        isValid = false;
    }
    var rank = parseInt(rankInp.value, 10);
    if (isNaN(rank) || rank <= 0) {
        showError(rankInp, 'err_editRankOrder', 'Thứ tự bậc phải là số nguyên dương lớn hơn 0 (ví dụ: 1, 2, 3...).');
        isValid = false;
    }

    if (!isValid) {
        e.preventDefault();
        return false;
    }
    return true;
}

function validateCriteriaForm(e) {
    var isValid = true;
    var fromSelect = document.getElementById('fromLevelId');
    var toSelect = document.getElementById('toLevelId');
    var summaryInput = document.getElementById('competencySummary');
    var testScoreInput = document.getElementById('minTestScore');
    var ratingInput = document.getElementById('minManagerRating');

    clearCriteriaErrors();

    if (!fromSelect.value) {
        showError(fromSelect, 'err_fromLevelId', 'Vui lòng chọn cấp bậc hiện tại.');
        isValid = false;
    }

    if (!toSelect.value) {
        showError(toSelect, 'err_toLevelId', 'Vui lòng chọn cấp bậc mục tiêu.');
        isValid = false;
    } else if (fromSelect.value) {
        if (fromSelect.value === toSelect.value) {
            showError(toSelect, 'err_toLevelId', 'Cấp bậc mục tiêu không được trùng với cấp bậc hiện tại!');
            isValid = false;
        } else {
            var fromOpt = fromSelect.options[fromSelect.selectedIndex];
            var toOpt = toSelect.options[toSelect.selectedIndex];
            var fromRank = parseInt(fromOpt.getAttribute('data-rank') || '0', 10);
            var toRank = parseInt(toOpt.getAttribute('data-rank') || '0', 10);
            if (toRank <= fromRank) {
                showError(toSelect, 'err_toLevelId', 'Cấp bậc mục tiêu phải cao hơn cấp bậc hiện tại (Bậc ' + toRank + ' không thể nhỏ hơn hoặc bằng Bậc ' + fromRank + ')!');
                isValid = false;
            }
        }
    }

    if (!summaryInput.value || summaryInput.value.trim() === '') {
        showError(summaryInput, 'err_competencySummary', 'Vui lòng nhập tóm tắt năng lực cốt lõi yêu cầu.');
        isValid = false;
    }

    var score = parseFloat(testScoreInput.value);
    if (isNaN(score) || score < 0 || score > 100) {
        showError(testScoreInput, 'err_minTestScore', 'Điểm bài test sát hạch sàn phải từ 0 đến 100.');
        isValid = false;
    }

    var rating = parseFloat(ratingInput.value);
    if (isNaN(rating) || rating < 0 || rating > 10) {
        showError(ratingInput, 'err_minManagerRating', 'Điểm đánh giá kín sàn từ Manager phải từ 0 đến 10.');
        isValid = false;
    }

    if (!isValid) {
        e.preventDefault();
        return false;
    }
    return true;
}

function validateReqForm(e) {
    var isValid = true;
    var titleInput = document.getElementById('reqTitle');
    clearReqErrors();

    if (!titleInput.value || titleInput.value.trim() === '') {
        showError(titleInput, 'err_reqTitle', 'Vui lòng nhập tên tiêu chí yêu cầu.');
        isValid = false;
    }

    if (!isValid) {
        e.preventDefault();
        return false;
    }
    return true;
}
</script>

<jsp:include page="/views/common/footer.jsp" />
