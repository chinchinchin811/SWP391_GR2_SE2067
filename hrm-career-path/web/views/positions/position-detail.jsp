<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
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
.clickable-level-row {
    transition: background-color 0.15s ease;
}
.clickable-level-row:hover {
    background-color: #f1f5f9 !important;
}
.inline-error {
    color: #dc2626;
    font-size: 12px;
    margin-top: 4px;
    display: none;
    font-weight: 500;
}
.modal-overlay {
    display: none;
    position: fixed;
    z-index: 9999;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: rgba(15, 23, 42, 0.6);
    backdrop-filter: blur(2px);
    align-items: center;
    justify-content: center;
}
.modal-box {
    background: #ffffff;
    width: 90%;
    max-width: 680px;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    max-height: 90vh;
    overflow-y: auto;
}
.modal-box-lg {
    max-width: 860px;
}
</style>

<main class="main-content">
    <div class="topbar">
        <div style="display: flex; flex-direction: column; align-items: flex-start; justify-content: center; gap: 3px;">
            <div style="font-size: 12px; color: #64748b; display: flex; align-items: center; gap: 6px;">
                <a href="<%= request.getContextPath() %>/positions" style="color: #64748b; text-decoration: none;">Vị Trí Chuyên Môn</a>
                <span style="color: #94a3b8; font-size: 11px;">&gt;</span>
                <span style="color: #475569; font-weight: 500;">Chi Tiết Vị Trí</span>
            </div>
            <h1 style="margin: 0; font-size: 20px; font-weight: 800; color: #0f172a; line-height: 1.2;">
                <%= pos != null ? pos.getPositionName() : "Chi Tiết Vị Trí" %>
            </h1>
        </div>
        <div style="display: flex; gap: 8px;">
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">
                Danh Sách Vị Trí
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;">
            <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;">
            <%= errorMessage %>
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
                                    Đang áp dụng
                                </span>
                            <% } else { %>
                                <span class="badge" style="font-size: 12px; padding: 3px 10px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 20px;">
                                    Tạm khóa
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
                            <%= pos.getDepartmentName() != null ? pos.getDepartmentName() : "Dùng chung toàn công ty" %>
                        </div>
                    </div>
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Quy Mô Nhân Sự Hiện Tại:</span>
                        <div style="margin-top: 4px; font-weight: 700; color: #0284c7; font-size: 14px;">
                            <a href="<%= request.getContextPath() %>/employees?positionId=<%= pos.getPositionId() %>" style="color: #0284c7; text-decoration: none;">
                                <%= pos.getEmployeeCount() %> Nhân sự
                            </a>
                        </div>
                    </div>
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Số Cấp Bậc Cấu Hình:</span>
                        <div style="margin-top: 4px; font-weight: 700; color: #1e293b; font-size: 14px;">
                            <%= levels != null ? levels.size() : 0 %> Cấp bậc
                        </div>
                    </div>
                    <div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                        <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Ngày Tạo Hồ Sơ:</span>
                        <div style="margin-top: 4px; font-weight: 600; color: #334155; font-size: 13.5px;">
                            <%= (pos.getCreatedAt() != null) ? sdf.format(pos.getCreatedAt()) : "--/--/----" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- BẢNG THANG CẤP BẬC CỦA VỊ TRÍ (GỌN GÀNG, KHÔNG CÓ CỘT BAREM THỪA) -->
            <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden;">
                <div class="card-header" style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                    <div>
                        <h3 style="margin: 0; font-size: 15px; color: #1e293b;">
                            Danh Mục Cấp Bậc: <%= pos.getPositionName() %>
                        </h3>
                        <span style="color: #64748b; font-size: 12.5px;">
                            Nhấp vào hàng của cấp bậc để xem hoặc thiết lập <strong>Lộ Trình &amp; Điều Kiện Thăng Tiến Lên Bậc Tiếp Theo</strong>.
                        </span>
                    </div>
                    <% if (roleId == 1) { %>
                    <div style="display: flex; gap: 8px;">
                        <button type="button" class="btn btn-sm btn-primary" onclick="openAddLevelModal()">
                            Thêm Cấp Bậc Mới
                        </button>
                    </div>
                    <% } %>
                </div>

                <div class="card-body" style="padding: 0;">
                    <% if (levels == null || levels.isEmpty()) { %>
                        <div style="padding: 40px 20px; text-align: center;">
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
                                        Khởi Tạo 6 Cấp Bậc Tiêu Chuẩn
                                    </button>
                                </form>
                                <button type="button" class="btn btn-primary" onclick="openAddLevelModal()">
                                    Thêm Cấp Bậc Tùy Chỉnh
                                </button>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 13.5px;">
                            <thead>
                                <tr style="background: #f1f5f9; border-bottom: 1px solid #e2e8f0;">
                                    <th style="padding: 12px 16px; width: 70px; text-align: center;">Thứ Tự</th>
                                    <th style="padding: 12px 16px; width: 200px;">Tên Cấp Bậc</th>
                                    <th style="padding: 12px 16px;">Mô Tả / Tiêu Chuẩn Năng Lực</th>
                                    <th style="padding: 12px 16px; width: 210px; text-align: center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                for (int i = 0; i < levels.size(); i++) { 
                                    JobLevel lvl = levels.get(i);
                                    JobLevel nextLvl = (i + 1 < levels.size()) ? levels.get(i + 1) : null;
                                    String nextLvlName = (nextLvl != null) ? nextLvl.getLevelName() : "";
                                %>
                                <tr class="clickable-level-row" style="border-bottom: 1px solid #f1f5f9; cursor: pointer;"
                                    onclick="openLevelCriteriaModal(<%= lvl.getLevelId() %>, '<%= lvl.getLevelName().replace("'", "\\'") %>', <%= lvl.getRankOrder() %>, '<%= nextLvlName.replace("'", "\\'") %>')">
                                    <td style="padding: 14px 16px; text-align: center; font-size: 14px; font-weight: 600; color: #475569;">
                                        <%= lvl.getRankOrder() %>
                                    </td>
                                    <td style="padding: 14px 16px;">
                                        <strong style="color: #1e293b; font-size: 14.5px;"><%= lvl.getLevelName() %></strong>
                                    </td>
                                    <td style="padding: 14px 16px; color: #475569;">
                                        <%= (lvl.getDescription() != null && !lvl.getDescription().trim().isEmpty()) ? lvl.getDescription() : "<em style='color: #94a3b8;'>Chưa có mô tả chi tiết</em>" %>
                                    </td>
                                    <td style="padding: 14px 16px; text-align: center;" onclick="event.stopPropagation();">
                                        <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                                            <button type="button" class="btn btn-sm btn-outline-primary" style="font-size: 12px; padding: 4px 10px;"
                                                    onclick="openLevelCriteriaModal(<%= lvl.getLevelId() %>, '<%= lvl.getLevelName().replace("'", "\\'") %>', <%= lvl.getRankOrder() %>, '<%= nextLvlName.replace("'", "\\'") %>')">
                                                <%= (roleId == 1 ? "Cấu hình lộ trình" : "Xem lộ trình") %>
                                            </button>
                                            <% if (roleId == 1) { %>
                                            <button type="button" class="btn btn-sm btn-secondary" style="font-size: 12px; padding: 4px 8px;" title="Sửa tên hoặc bậc"
                                                    onclick="openEditLevelModal(<%= lvl.getLevelId() %>, '<%= lvl.getLevelName().replace("'", "\\'") %>', <%= lvl.getRankOrder() %>, '<%= (lvl.getDescription() != null ? lvl.getDescription().replace("'", "\\'") : "").replace("\n", " ") %>')">
                                                Sửa
                                            </button>
                                            <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa cấp bậc này khỏi vị trí? Hệ thống sẽ tự động dồn lại thứ bậc của các cấp bậc sau.');">
                                                <input type="hidden" name="action" value="deleteLevel">
                                                <input type="hidden" name="levelId" value="<%= lvl.getLevelId() %>">
                                                <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                                <button type="submit" class="btn btn-sm btn-danger" style="font-size: 12px; padding: 4px 8px;" title="Xóa cấp bậc">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } %>
                </div>
            </div>

        <% } %>
    </div>
</main>

<!-- ========================================================================= -->
<!-- MODAL POPUP: CHI TIẾT ĐIỀU KIỆN THĂNG TIẾN LÊN BẬC TIẾP THEO (DẠNG BẢNG) -->
<!-- ========================================================================= -->
<div id="levelCriteriaModal" class="modal-overlay">
    <div class="modal-box modal-box-lg">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #e2e8f0; padding-bottom: 14px; margin-bottom: 18px;">
            <div>
                <div style="font-size: 12px; color: #64748b; font-weight: 600; text-transform: uppercase;">
                    Lộ Trình &amp; Điều Kiện Thăng Tiến Cấp Bậc
                </div>
                <h3 id="modalLevelTitle" style="margin: 4px 0 0 0; color: #1e293b; font-size: 18px; font-weight: 800;"></h3>
            </div>
            <button type="button" onclick="closeLevelCriteriaModal()" style="background: none; border: none; font-size: 22px; cursor: pointer; color: #94a3b8; line-height: 1;">&times;</button>
        </div>

        <div id="modalLevelContainer">
            <% if (levels != null && pos != null) {
                for (int i = 0; i < levels.size(); i++) {
                    JobLevel lvl = levels.get(i);
                    JobLevel nextLvl = (i + 1 < levels.size()) ? levels.get(i + 1) : null;
                    
                    // Tìm criteria cho bước thăng tiến TỪ cấp bậc này LÊN cấp bậc tiếp theo
                    PositionLevelCriteria stepCrit = null;
                    if (nextLvl != null && criteriaList != null) {
                        for (PositionLevelCriteria c : criteriaList) {
                            if (c.getFromLevelId() == lvl.getLevelId() && c.getToLevelId() == nextLvl.getLevelId()) {
                                stepCrit = c;
                                break;
                            }
                        }
                        if (stepCrit == null) {
                            for (PositionLevelCriteria c : criteriaList) {
                                if (c.getFromLevelId() == lvl.getLevelId()) {
                                    stepCrit = c;
                                    break;
                                }
                            }
                        }
                    }
            %>
            <div id="levelPane_<%= lvl.getLevelId() %>" class="level-detail-pane" style="display: none;">
                
                <% if (nextLvl == null) { %>
                    <!-- TRƯỜNG HỢP 1: ĐÂY LÀ BẬC CAO NHẤT (ĐỈNH LỘ TRÌNH, KHÔNG CÓ BẬC TIẾP THEO) -->
                    <div style="text-align: center; padding: 28px 16px;">
                        <h4 style="color: #1e293b; margin-bottom: 6px; font-size: 17px;">Cấp Bậc Cao Nhất (Đỉnh Lộ Trình Chuyên Môn)</h4>
                        <p style="color: #64748b; font-size: 13.5px; max-width: 520px; margin: 0 auto 16px auto; line-height: 1.6;">
                            <strong><%= lvl.getLevelName() %></strong> (Bậc <%= lvl.getRankOrder() %>) là cấp bậc cao nhất trong khung tiêu chuẩn chức danh của vị trí <strong><%= pos.getPositionName() %></strong>.
                            Nhân sự đạt cấp bậc này đã hoàn thành lộ trình thăng tiến chuyên môn và không có nấc thăng tiến bậc cao hơn.
                        </p>
                        <div style="background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 8px; padding: 14px 18px; text-align: left; max-width: 540px; margin: 0 auto;">
                            <div style="font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase; margin-bottom: 4px;">Tiêu chuẩn vai trò cấp bậc:</div>
                            <div style="font-size: 13.5px; color: #334155;">
                                <%= (lvl.getDescription() != null && !lvl.getDescription().trim().isEmpty()) ? lvl.getDescription() : "Chưa có mô tả chi tiết." %>
                            </div>
                        </div>
                    </div>

                <% } else if (stepCrit == null) { %>
                    <!-- TRƯỜNG HỢP 2: CÓ BẬC TIẾP THEO NHƯNG CHƯA CẤU HÌNH BAREM -->
                    <div style="text-align: center; padding: 28px 16px;">
                        <h4 style="color: #1e293b; margin-bottom: 6px; font-size: 17px;">Chưa Cấu Hình Barem Thăng Tiến Cho Nấc Này</h4>
                        <p style="color: #64748b; font-size: 13.5px; max-width: 520px; margin: 0 auto 18px auto; line-height: 1.6;">
                            Hiện chưa có barem quy định điều kiện để nhân sự từ <strong><%= lvl.getLevelName() %> (Bậc <%= lvl.getRankOrder() %>)</strong> thăng tiến lên <strong><%= nextLvl.getLevelName() %> (Bậc <%= nextLvl.getRankOrder() %>)</strong>.
                        </p>
                        <% if (roleId == 1) { %>
                        <button type="button" class="btn btn-primary" onclick="setupCriteriaForLevel(<%= lvl.getLevelId() %>, <%= nextLvl.getLevelId() %>)">
                            Thiết Lập Barem Lên <%= nextLvl.getLevelName() %>
                        </button>
                        <% } %>
                    </div>

                <% } else { %>
                    <!-- TRƯỜNG HỢP 3: ĐÃ CÓ BAREM - HIỂN THỊ DƯỚI DẠNG BẢNG CHI TIẾT (TABLE) -->
                    <div>
                        <!-- NÚT THÊM ĐIỀU KIỆN & XÓA BAREM NẤC NÀY (ĐÃ LƯỢC BỎ HEADER THÔNG TIN THỪA) -->
                        <% if (roleId == 1) { %>
                        <div style="display: flex; justify-content: flex-end; align-items: center; gap: 8px; margin-bottom: 12px;">
                            <button type="button" class="btn btn-sm btn-primary" style="font-size: 12.5px; padding: 6px 14px;"
                                    onclick="openAddReqModal(<%= stepCrit.getCriteriaId() %>, '<%= lvl.getLevelName() %> lên <%= nextLvl.getLevelName() %>')">
                                Thêm điều kiện
                            </button>
                            <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa barem của nấc thăng tiến này?');">
                                <input type="hidden" name="action" value="deleteCriteria">
                                <input type="hidden" name="criteriaId" value="<%= stepCrit.getCriteriaId() %>">
                                <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                <input type="hidden" name="returnTo" value="detail">
                                <button type="submit" class="btn btn-sm btn-danger" style="font-size: 12.5px; padding: 6px 10px;" title="Xóa barem nấc này">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </div>
                        <% } %>

                        <!-- BẢNG TOÀN BỘ CÁC TIÊU CHUẨN THĂNG TIẾN (TABLE) -->
                        <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
                            <table class="data-table" style="width: 100%; font-size: 13px; border-collapse: collapse;">
                                <thead>
                                    <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0;">
                                        <th style="width: 45px; text-align: center; padding: 10px 12px;">STT</th>
                                        <th style="width: 210px; padding: 10px 12px;">Hạng Mục Tiêu Chuẩn</th>
                                        <th style="padding: 10px 12px;">Nội Dung Yêu Cầu / Chuẩn Barem Chi Tiết</th>
                                        <th style="width: 130px; text-align: center; padding: 10px 12px;">Tính Chất</th>
                                        <% if (roleId != 1) { %>
                                        <th style="width: 120px; text-align: center; padding: 10px 12px;">Trạng Thái</th>
                                        <% } %>
                                        <% if (roleId == 1) { %>
                                        <th style="width: 50px; text-align: center; padding: 10px 12px;">Xóa</th>
                                        <% } %>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- 1. NĂNG LỰC CỐT LÕI YÊU CẦU -->
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="text-align: center; color: #64748b; padding: 12px; font-weight: 600;">1</td>
                                        <td style="padding: 12px;">
                                            <strong style="color: #1e293b;">Năng lực cốt lõi</strong>
                                        </td>
                                        <td style="padding: 12px; color: #334155; line-height: 1.5;">
                                            <%= stepCrit.getCompetencySummary() %>
                                        </td>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #e0e7ff; color: #4338ca; padding: 3px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 700;">
                                                Bắt buộc
                                            </span>
                                        </td>
                                        <% if (roleId != 1) { %>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                                Chưa đạt
                                            </span>
                                        </td>
                                        <% } %>
                                        <% if (roleId == 1) { %><td style="text-align: center; color: #94a3b8;">-</td><% } %>
                                    </tr>

                                    <!-- 2. ĐIỂM BÀI TEST SÁT HẠCH SÀN -->
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="text-align: center; color: #64748b; padding: 12px; font-weight: 600;">2</td>
                                        <td style="padding: 12px;">
                                            <strong style="color: #1e293b;">Điểm bài test sát hạch</strong>
                                        </td>
                                        <td style="padding: 12px; color: #334155;">
                                            Điểm bài thi chuyên môn tối thiểu: <strong style="color: #059669; font-size: 13.5px;">≥ <%= stepCrit.getMinTestScore() %> / 100 điểm</strong>
                                        </td>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #e0e7ff; color: #4338ca; padding: 3px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 700;">
                                                Bắt buộc
                                            </span>
                                        </td>
                                        <% if (roleId != 1) { %>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                                Chưa đạt
                                            </span>
                                        </td>
                                        <% } %>
                                        <% if (roleId == 1) { %><td style="text-align: center; color: #94a3b8;">-</td><% } %>
                                    </tr>

                                    <!-- 3. ĐIỂM ĐÁNH GIÁ SÀN TỪ MANAGER -->
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="text-align: center; color: #64748b; padding: 12px; font-weight: 600;">3</td>
                                        <td style="padding: 12px;">
                                            <strong style="color: #1e293b;">Đánh giá từ Manager</strong>
                                        </td>
                                        <td style="padding: 12px; color: #334155;">
                                            Điểm đánh giá kín hiệu suất từ Trưởng phòng: <strong style="color: #4338ca; font-size: 13.5px;">≥ <%= stepCrit.getMinManagerRating() %> / 10 điểm</strong>
                                        </td>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #e0e7ff; color: #4338ca; padding: 3px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 700;">
                                                Bắt buộc
                                            </span>
                                        </td>
                                        <% if (roleId != 1) { %>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                                Chưa đạt
                                            </span>
                                        </td>
                                        <% } %>
                                        <% if (roleId == 1) { %><td style="text-align: center; color: #94a3b8;">-</td><% } %>
                                    </tr>

                                    <!-- 4+. CÁC TIÊU CHÍ MINH CHỨNG THỰC TẾ (NẾU CÓ) -->
                                    <% 
                                    int stt = 4;
                                    if (stepCrit.getRequirements() != null) {
                                        for (CriteriaRequirement req : stepCrit.getRequirements()) {
                                    %>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="text-align: center; color: #64748b; padding: 12px; font-weight: 600;"><%= stt++ %></td>
                                        <td style="padding: 12px;">
                                            <strong style="color: #1e293b;"><%= req.getRequirementTitle() %></strong>
                                            <span style="display: block; color: #64748b; font-size: 11.5px; margin-top: 3px;">
                                                <%= req.getRequirementTypeBadge() %>
                                            </span>
                                        </td>
                                        <td style="padding: 12px; color: #334155;">
                                            <%= (req.getDescription() != null && !req.getDescription().trim().isEmpty()) ? req.getDescription() : "Nộp tài liệu hoặc đường dẫn minh chứng thực tế" %>
                                        </td>
                                        <td style="text-align: center; padding: 12px;">
                                            <% if (req.isMandatory()) { %>
                                                <span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 700;">
                                                    Bắt buộc
                                                </span>
                                            <% } else { %>
                                                <span style="background: #f1f5f9; color: #64748b; padding: 3px 8px; border-radius: 4px; font-size: 11.5px;">
                                                    Khuyến khích
                                                </span>
                                            <% } %>
                                        </td>
                                        <% if (roleId != 1) { %>
                                        <td style="text-align: center; padding: 12px;">
                                            <span style="background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                                Chưa đạt
                                            </span>
                                        </td>
                                        <% } %>
                                        <% if (roleId == 1) { %>
                                        <td style="text-align: center; padding: 12px;">
                                            <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Xóa điều kiện này?');">
                                                <input type="hidden" name="action" value="deleteRequirement">
                                                <input type="hidden" name="requirementId" value="<%= req.getRequirementId() %>">
                                                <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                                <input type="hidden" name="returnTo" value="detail">
                                                <button type="submit" style="background: none; border: none; color: #ef4444; cursor: pointer; padding: 4px;" title="Xóa">
                                                    <i class="fa-solid fa-trash-can"></i>
                                                </button>
                                            </form>
                                        </td>
                                        <% } %>
                                    </tr>
                                    <% }} %>
                                </tbody>
                            </table>
                        </div>

                    </div>
                <% } %>

            </div>
            <% }} %>
        </div>

        <div style="display: flex; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 14px; margin-top: 20px;">
            <button type="button" onclick="closeLevelCriteriaModal()" class="btn btn-secondary">Đóng</button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: THÊM CẤP BẬC MỚI -->
<!-- ========================================================================= -->
<div id="addLevelModal" class="modal-overlay">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <h3 style="margin: 0; color: #1e293b; font-size: 17px;">
                Thêm Cấp Bậc Cho Vị Trí
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
                <small style="color: #4338ca; font-size: 12px; background: #e0e7ff; padding: 2px 8px; border-radius: 4px; display: inline-block; margin-top: 4px;">Hệ thống tự động đẩy các bậc sau đó lên 1 nấc nếu chọn thứ tự đã có.</small>
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

<!-- ========================================================================= -->
<!-- MODAL: SỬA CẤP BẬC -->
<!-- ========================================================================= -->
<div id="editLevelModal" class="modal-overlay">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <h3 style="margin: 0; color: #1e293b; font-size: 17px;">
                Chỉnh Sửa Cấp Bậc
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

<!-- ========================================================================= -->
<!-- MODAL: THIẾT LẬP NẤC BAREM THĂNG TIẾN MỚI -->
<!-- ========================================================================= -->
<div id="addCriteriaModal" class="modal-overlay">
    <div class="modal-box">
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

<!-- ========================================================================= -->
<!-- MODAL: THÊM ĐIỀU KIỆN MINH CHỨNG MỞ -->
<!-- ========================================================================= -->
<div id="addReqModal" class="modal-overlay">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <div>
                <h3 style="margin: 0; color: #1e293b; font-size: 17px;">Thêm Điều Kiện Thăng Tiến</h3>
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
                <label style="font-weight: 600; font-size: 13px;">Tên Điều Kiện Yêu Cầu (*):</label>
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
                <button type="submit" class="btn btn-primary">Thêm Điều Kiện</button>
            </div>
        </form>
    </div>
</div>

<script>
// =========================================================================
// MODAL MANAGEMENT SCRIPTS
// =========================================================================

// Level Progression Details Modal
function openLevelCriteriaModal(levelId, levelName, rankOrder, nextLevelName) {
    var titleEl = document.getElementById('modalLevelTitle');
    if (nextLevelName && nextLevelName !== '') {
        titleEl.innerHTML = levelName + ' (Bậc ' + rankOrder + ') &rarr; ' + nextLevelName;
    } else {
        titleEl.innerHTML = levelName + ' (Bậc ' + rankOrder + ') - Đỉnh Lộ Trình';
    }
    
    // Hide all panes
    var panes = document.querySelectorAll('.level-detail-pane');
    panes.forEach(function(pane) {
        pane.style.display = 'none';
    });

    // Show the target pane
    var targetPane = document.getElementById('levelPane_' + levelId);
    if (targetPane) {
        targetPane.style.display = 'block';
    }

    document.getElementById('levelCriteriaModal').style.display = 'flex';
}

function closeLevelCriteriaModal() {
    document.getElementById('levelCriteriaModal').style.display = 'none';
}

function setupCriteriaForLevel(fromLevelId, toLevelId) {
    closeLevelCriteriaModal();
    openAddCriteriaModal();
    var fromSelect = document.getElementById('fromLevelId');
    var toSelect = document.getElementById('toLevelId');
    if (fromSelect && fromLevelId > 0) {
        fromSelect.value = fromLevelId;
    }
    if (toSelect && toLevelId > 0) {
        toSelect.value = toLevelId;
    }
}

// Add Level Modal
function openAddLevelModal() {
    clearFieldError(document.getElementById('addLevelName'), 'err_addLevelName');
    clearFieldError(document.getElementById('addRankOrder'), 'err_addRankOrder');
    document.getElementById('addLevelModal').style.display = 'flex';
}
function closeAddLevelModal() {
    document.getElementById('addLevelModal').style.display = 'none';
}

// Edit Level Modal
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

// Criteria Modal
function openAddCriteriaModal() {
    clearCriteriaErrors();
    document.getElementById('addCriteriaModal').style.display = 'flex';
}
function closeAddCriteriaModal() {
    document.getElementById('addCriteriaModal').style.display = 'none';
}

// Requirement Modal
function openAddReqModal(criteriaId, stepTitle) {
    clearReqErrors();
    document.getElementById('modalCriteriaId').value = criteriaId;
    document.getElementById('modalCriteriaSub').innerText = 'Cho nấc: ' + stepTitle;
    document.getElementById('addReqModal').style.display = 'flex';
}
function closeAddReqModal() {
    document.getElementById('addReqModal').style.display = 'none';
}

// Global backdrop click
window.onclick = function(event) {
    if (event.target === document.getElementById('levelCriteriaModal')) closeLevelCriteriaModal();
    if (event.target === document.getElementById('addLevelModal')) closeAddLevelModal();
    if (event.target === document.getElementById('editLevelModal')) closeEditLevelModal();
    if (event.target === document.getElementById('addCriteriaModal')) closeAddCriteriaModal();
    if (event.target === document.getElementById('addReqModal')) closeAddReqModal();
};

// =========================================================================
// INLINE VALIDATION & ERROR HELPERS
// =========================================================================
function showError(inputEl, errId, msg) {
    if (inputEl) {
        inputEl.style.borderColor = '#ef4444';
        inputEl.style.backgroundColor = '#fff5f5';
    }
    var errDiv = document.getElementById(errId);
    if (errDiv) {
        errDiv.innerHTML = msg;
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

// Form Validation: Add Level
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

// Form Validation: Edit Level
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

// Form Validation: Save Criteria
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

// Form Validation: Add Requirement
function validateReqForm(e) {
    var isValid = true;
    var titleInput = document.getElementById('reqTitle');
    clearReqErrors();

    if (!titleInput.value || titleInput.value.trim() === '') {
        showError(titleInput, 'err_reqTitle', 'Vui lòng nhập tên điều kiện yêu cầu.');
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
