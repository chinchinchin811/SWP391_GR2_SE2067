<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Position" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.PositionLevelCriteria" %>
<%@ page import="model.CriteriaRequirement" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    Position pos = (Position) request.getAttribute("position");
    List<PositionLevelCriteria> criteriaList = (List<PositionLevelCriteria>) request.getAttribute("criteriaList");
    List<JobLevel> allLevels = (List<JobLevel>) request.getAttribute("allLevels");
    
    request.setAttribute("pageTitle", "Barem Tiêu Chí Lộ Trình: " + (pos != null ? pos.getPositionName() : "") + " | CPMS");
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
            <h1 style="margin-bottom: 4px;">Barem Tiêu Chí Lộ Trình Thăng Tiến</h1>
            <p style="color: #64748b; font-size: 13.5px; margin: 0;">
                Vị trí: <strong><%= pos != null ? pos.getPositionName() : "" %></strong> 
                (<%= (pos != null && pos.getDepartmentName() != null) ? pos.getDepartmentName() : "Toàn công ty" %>)
            </p>
        </div>
        <div style="display: flex; gap: 8px;">
            <% if (roleId == 1) { %>
                <button type="button" class="btn btn-primary" onclick="openAddCriteriaModal()">
                    <i class="fa-solid fa-plus"></i> Thêm Nấc Thăng Tiến Mới
                </button>
            <% } %>
            <a href="<%= request.getContextPath() %>/positions" class="btn btn-secondary">
                <i class="fa-solid fa-arrow-left"></i> Quay lại Vị Trí
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px; border-radius: 6px; margin-bottom: 16px;">
            <i class="fa-solid fa-circle-check"></i> <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px; border-radius: 6px; margin-bottom: 16px;">
            <i class="fa-solid fa-triangle-exclamation"></i> <%= errorMessage %>
        </div>
        <% } %>

        <% if (criteriaList == null || criteriaList.isEmpty()) { %>
            <div class="card" style="padding: 40px; text-align: center; background: #ffffff; border-radius: 8px;">
                <i class="fa-solid fa-stairs" style="font-size: 48px; color: #cbd5e1; margin-bottom: 16px;"></i>
                <h3 style="color: #334155;">Chưa cấu hình Barem thăng tiến cho vị trí này</h3>
                <p style="color: #64748b; font-size: 14px; max-width: 500px; margin: 0 auto 20px auto;">
                    Admin có thể bấm nút <b>"Thêm Nấc Thăng Tiến Mới"</b> để thiết lập chuẩn năng lực, bài test sát hạch và các yêu cầu minh chứng thực tế (dự án, CSAT, chứng chỉ).
                </p>
                <% if (roleId == 1) { %>
                <button type="button" class="btn btn-primary" onclick="openAddCriteriaModal()">
                    <i class="fa-solid fa-plus"></i> Thiết Lập Nấc Thăng Tiến Đầu Tiên
                </button>
                <% } %>
            </div>
        <% } else { %>

            <div style="display: flex; flex-direction: column; gap: 20px;">
                <% for (PositionLevelCriteria crit : criteriaList) { %>
                    <div class="card" style="border: 1px solid #e2e8f0; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.03); background: #ffffff; overflow: hidden;">
                        
                        <!-- Header Nấc Thăng Tiến -->
                        <div style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <span style="background: #e0e7ff; color: #4338ca; font-weight: 700; padding: 4px 10px; border-radius: 6px; font-size: 14px;">
                                    Bậc: <%= crit.getFromLevelName() %>
                                </span>
                                <i class="fa-solid fa-arrow-right" style="color: #94a3b8; font-size: 14px;"></i>
                                <span style="background: #ecfdf5; color: #047857; font-weight: 700; padding: 4px 10px; border-radius: 6px; font-size: 14px;">
                                    Mục tiêu: <%= crit.getToLevelName() %>
                                </span>
                                <% if (!crit.isStatus()) { %>
                                    <span style="background: #fee2e2; color: #b91c1c; font-size: 12px; padding: 2px 8px; border-radius: 4px;">Tạm ngưng</span>
                                <% } %>
                            </div>

                            <% if (roleId == 1) { %>
                            <div style="display: flex; gap: 8px;">
                                <button type="button" class="btn btn-sm btn-secondary" style="font-size: 12.5px;" 
                                        onclick="openAddReqModal(<%= crit.getCriteriaId() %>, '<%= crit.getFromLevelName() %> lên <%= crit.getToLevelName() %>')">
                                    <i class="fa-solid fa-plus"></i> Thêm Tiêu Chí Minh Chứng
                                </button>
                                <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa nấc barem này?');">
                                    <input type="hidden" name="action" value="deleteCriteria">
                                    <input type="hidden" name="criteriaId" value="<%= crit.getCriteriaId() %>">
                                    <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                    <button type="submit" class="btn btn-sm btn-danger" style="font-size: 12.5px;">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                            <% } %>
                        </div>

                        <!-- Thân Chi Tiết Barem -->
                        <div style="padding: 20px;">
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 20px;">
                                <div style="background: #f8fafc; padding: 14px; border-radius: 8px; border-left: 4px solid #4f46e5;">
                                    <span style="font-size: 12px; color: #64748b; font-weight: 600; text-transform: uppercase;">Năng lực cốt lõi yêu cầu:</span>
                                    <p style="margin: 6px 0 0 0; font-size: 13.5px; color: #1e293b; line-height: 1.5;">
                                        <%= crit.getCompetencySummary() %>
                                    </p>
                                </div>
                                <div style="background: #f8fafc; padding: 14px; border-radius: 8px; border-left: 4px solid #059669;">
                                    <span style="font-size: 12px; color: #64748b; font-weight: 600; text-transform: uppercase;">Chuẩn điểm đánh giá:</span>
                                    <p style="margin: 6px 0 0 0; font-size: 13.5px; color: #1e293b;">
                                        • Điểm bài test sát hạch: <strong style="color: #059669;">≥ <%= crit.getMinTestScore() %>đ</strong><br>
                                        • Đánh giá kín từ Manager: <strong style="color: #4338ca;">≥ <%= crit.getMinManagerRating() %>/10đ</strong>
                                    </p>
                                </div>
                            </div>

                            <!-- Danh sách tiêu chí mở nộp minh chứng -->
                            <div>
                                <h4 style="font-size: 13.5px; font-weight: 700; color: #334155; margin-bottom: 10px; display: flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-list-check" style="color: #4f46e5;"></i> 
                                    Danh mục Tiêu chí Minh chứng Thực tế (Dự án / CSAT / Chứng chỉ):
                                </h4>

                                <% if (crit.getRequirements() == null || crit.getRequirements().isEmpty()) { %>
                                    <p style="font-size: 13px; color: #94a3b8; font-style: italic; margin-left: 10px;">
                                        Chưa có tiêu chí minh chứng bổ sung nào. (Chỉ yêu cầu bài test và đánh giá của Manager).
                                    </p>
                                <% } else { %>
                                    <table class="data-table" style="width: 100%; font-size: 13px;">
                                        <thead>
                                            <tr style="background: #f1f5f9;">
                                                <th style="width: 50px; text-align: center;">STT</th>
                                                <th>Nội dung tiêu chí yêu cầu</th>
                                                <th style="width: 170px;">Phân loại</th>
                                                <th style="width: 120px; text-align: center;">Bắt buộc?</th>
                                                <% if (roleId == 1) { %>
                                                <th style="width: 80px; text-align: center;">Xóa</th>
                                                <% } %>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% 
                                                int rIdx = 1;
                                                for (CriteriaRequirement req : crit.getRequirements()) { 
                                            %>
                                            <tr>
                                                <td style="text-align: center; color: #64748b;"><%= rIdx++ %></td>
                                                <td>
                                                    <strong style="color: #1e293b;"><%= req.getRequirementTitle() %></strong>
                                                    <% if (req.getDescription() != null && !req.getDescription().isEmpty()) { %>
                                                        <div style="color: #64748b; font-size: 12px; margin-top: 2px;">
                                                            Hướng dẫn: <%= req.getDescription() %>
                                                        </div>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <span style="background: #f1f5f9; color: #334155; padding: 3px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 600;">
                                                        <%= req.getRequirementTypeBadge() %>
                                                    </span>
                                                </td>
                                                <td style="text-align: center;">
                                                    <% if (req.isMandatory()) { %>
                                                        <span style="color: #dc2626; font-weight: 700; font-size: 12px;"><i class="fa-solid fa-asterisk"></i> Bắt buộc</span>
                                                    <% } else { %>
                                                        <span style="color: #64748b; font-size: 12px;">Khuyến khích</span>
                                                    <% } %>
                                                </td>
                                                <% if (roleId == 1) { %>
                                                <td style="text-align: center;">
                                                    <form action="<%= request.getContextPath() %>/positions" method="POST" style="display: inline;" onsubmit="return confirm('Xóa tiêu chí này?');">
                                                        <input type="hidden" name="action" value="deleteRequirement">
                                                        <input type="hidden" name="requirementId" value="<%= req.getRequirementId() %>">
                                                        <input type="hidden" name="positionId" value="<%= pos.getPositionId() %>">
                                                        <button type="submit" style="background: none; border: none; color: #ef4444; cursor: pointer;" title="Xóa tiêu chí">
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
</main>

<!-- MODAL THÊM NẤC THĂNG TIẾN MỚI -->
<div id="addCriteriaModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 90%; max-width: 650px; border-radius: 12px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto;">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <h3 style="margin: 0; color: #1e293b; font-size: 18px;">Thiết Lập Nấc Barem Thăng Tiến Mới</h3>
            <button type="button" onclick="closeAddCriteriaModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/positions" method="POST">
            <input type="hidden" name="action" value="saveCriteria">
            <input type="hidden" name="positionId" value="<%= pos != null ? pos.getPositionId() : 0 %>">

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 14px;">
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Từ Cấp Bậc (*):</label>
                    <select name="fromLevelId" class="form-control" required>
                        <option value="">-- Chọn Cấp Bậc Hiện Tại --</option>
                        <% if (allLevels != null) { for (JobLevel lvl : allLevels) { %>
                            <option value="<%= lvl.getLevelId() %>"><%= lvl.getRankOrder() %>. <%= lvl.getLevelName() %></option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Lên Cấp Bậc Mục Tiêu (*):</label>
                    <select name="toLevelId" class="form-control" required>
                        <option value="">-- Chọn Cấp Bậc Đích --</option>
                        <% if (allLevels != null) { for (JobLevel lvl : allLevels) { %>
                            <option value="<%= lvl.getLevelId() %>"><%= lvl.getRankOrder() %>. <%= lvl.getLevelName() %></option>
                        <% }} %>
                    </select>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 600; font-size: 13px;">Tóm Tắt Năng Lực Cốt Lõi Yêu Cầu (*):</label>
                <textarea name="competencySummary" rows="3" class="form-control" placeholder="Ví dụ: Nắm vững kiến trúc Microservices, làm chủ Docker, tối ưu hóa CSDL..." required></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 18px;">
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Điểm Bài Test Sát Hạch Sàn (0 - 100):</label>
                    <input type="number" step="0.1" name="minTestScore" class="form-control" value="80.0" required>
                </div>
                <div class="form-group">
                    <label style="font-weight: 600; font-size: 13px;">Điểm Đánh Giá Sàn Từ Manager (1 - 10):</label>
                    <input type="number" step="0.1" name="minManagerRating" class="form-control" value="7.5" required>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 14px;">
                <button type="button" onclick="closeAddCriteriaModal()" class="btn btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary">Lưu Nấc Barem</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL THÊM TIÊU CHÍ MINH CHỨNG MỞ -->
<div id="addReqModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 90%; max-width: 580px; border-radius: 12px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 18px;">
            <div>
                <h3 style="margin: 0; color: #1e293b; font-size: 17px;">Thêm Tiêu Chí Minh Chứng Thực Tế</h3>
                <small id="modalCriteriaSub" style="color: #64748b; font-size: 12.5px;"></small>
            </div>
            <button type="button" onclick="closeAddReqModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/positions" method="POST">
            <input type="hidden" name="action" value="addRequirement">
            <input type="hidden" name="positionId" value="<%= pos != null ? pos.getPositionId() : 0 %>">
            <input type="hidden" id="modalCriteriaId" name="criteriaId" value="">

            <div class="form-group" style="margin-bottom: 12px;">
                <label style="font-weight: 600; font-size: 13px;">Phân Loại Tiêu Chí (*):</label>
                <select name="requirementType" class="form-control" required>
                    <option value="PROJECT_EXPERIENCE">Kinh Nghiệm Dự Án Thực Tế (Project Experience)</option>
                    <option value="CUSTOMER_SATISFACTION">Đánh Giá Khách Hàng / CSAT (Customer Satisfaction)</option>
                    <option value="CERTIFICATE">Chứng Chỉ Chuyên Môn / Quốc Tế (External Certificate)</option>
                    <option value="OTHER">Tiêu Chí Khác (Tech Talk, Đóng góp mã nguồn...)</option>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 12px;">
                <label style="font-weight: 600; font-size: 13px;">Tên Tiêu Chí Yêu Cầu (*):</label>
                <input type="text" name="requirementTitle" class="form-control" placeholder="Ví dụ: Tham gia tối thiểu 2 dự án thực tế đạt tiến độ" required>
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
function openAddCriteriaModal() {
    document.getElementById('addCriteriaModal').style.display = 'flex';
}
function closeAddCriteriaModal() {
    document.getElementById('addCriteriaModal').style.display = 'none';
}
function openAddReqModal(criteriaId, stepTitle) {
    document.getElementById('modalCriteriaId').value = criteriaId;
    document.getElementById('modalCriteriaSub').innerText = 'Cho nấc: ' + stepTitle;
    document.getElementById('addReqModal').style.display = 'flex';
}
function closeAddReqModal() {
    document.getElementById('addReqModal').style.display = 'none';
}
window.onclick = function(event) {
    var m1 = document.getElementById('addCriteriaModal');
    var m2 = document.getElementById('addReqModal');
    if (event.target === m1) closeAddCriteriaModal();
    if (event.target === m2) closeAddReqModal();
}
</script>

<jsp:include page="/views/common/footer.jsp" />

