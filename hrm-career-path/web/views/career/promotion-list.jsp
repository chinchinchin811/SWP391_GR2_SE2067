<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.PromotionRequest" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    List<PromotionRequest> requests = (List<PromotionRequest>) request.getAttribute("requests");
    boolean isManager = (roleId == 3);
    
    request.setAttribute("pageTitle", (isManager ? "Thẩm Định Thăng Tiến Phòng Ban" : "Quản Trị Bổ Nhiệm & Thăng Cấp") + " | CPMS");
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
            <h1 style="margin-bottom: 4px;">
                <%= isManager ? "Thẩm Định Đề Xuất Thăng Tiến" : "Xét Duyệt & Quyết Định Bổ Nhiệm" %>
            </h1>
            <p style="color: #64748b; font-size: 13.5px; margin: 0;">
                <%= isManager ? "Rà soát minh chứng năng lực thực tế và làm phiếu đánh giá kín cho nhân viên trực thuộc." 
                              : "Xem xét đề xuất từ Quản lý và ký quyết định bổ nhiệm nâng bậc chính thức." %>
            </p>
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

        <div class="card" style="background: #ffffff; border-radius: 10px; border: 1px solid #e2e8f0; overflow: hidden;">
            <div class="card-header" style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center;">
                <h2 style="font-size: 16px; margin: 0; color: #1e293b;">
                    Danh Sách Hồ Sơ Đề Xuất Nâng Bậc (<%= requests != null ? requests.size() : 0 %> hồ sơ)
                </h2>
            </div>
            <div class="card-body" style="padding: 0;">
                <table class="data-table" style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                            <th style="padding: 12px 16px; width: 60px;">Mã</th>
                            <th style="padding: 12px 16px;">Nhân sự đề xuất</th>
                            <th style="padding: 12px 16px;">Vị trí chuyên môn</th>
                            <th style="padding: 12px 16px;">Lộ trình xét duyệt</th>
                            <th style="padding: 12px 16px; text-align: center;">Đánh giá Manager</th>
                            <th style="padding: 12px 16px; text-align: center;">Trạng thái</th>
                            <th style="padding: 12px 16px; text-align: center; width: 130px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (requests != null && !requests.isEmpty()) { 
                            for (PromotionRequest r : requests) {
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 12px 16px; font-weight: 700; color: #64748b;">#<%= r.getRequestId() %></td>
                            <td style="padding: 12px 16px;">
                                <strong style="color: #1e293b; font-size: 14px;"><%= r.getUserFullName() %></strong>
                                <div style="font-size: 12px; color: #64748b;"><%= r.getUserEmail() %></div>
                            </td>
                            <td style="padding: 12px 16px; color: #334155;"><%= r.getPositionName() %></td>
                            <td style="padding: 12px 16px;">
                                <span style="background: #e2e8f0; color: #334155; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                    <%= r.getCurrentLevelName() %>
                                </span>
                                <i class="fa-solid fa-arrow-right" style="font-size: 11px; margin: 0 4px; color: #94a3b8;"></i>
                                <span style="background: #ecfdf5; color: #047857; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 700;">
                                    <%= r.getTargetLevelName() %>
                                </span>
                            </td>
                            <td style="padding: 12px 16px; text-align: center;">
                                <% if (r.getManagerRating() != null) { %>
                                    <strong style="color: #4f46e5; font-size: 14px;"><%= r.getManagerRating() %></strong>/10đ
                                <% } else { %>
                                    <span style="color: #94a3b8; font-size: 12px;">Chưa đánh giá</span>
                                <% } %>
                            </td>
                            <td style="padding: 12px 16px; text-align: center;">
                                <span class="badge <%= r.getStatusBadge() %>" style="font-size: 12px; padding: 4px 10px;">
                                    <%= r.getStatusText() %>
                                </span>
                            </td>
                            <td style="padding: 12px 16px; text-align: center;">
                                <a href="<%= request.getContextPath() %>/promotions?action=review&id=<%= r.getRequestId() %>" 
                                   class="btn btn-sm btn-primary" style="padding: 5px 12px; font-size: 12.5px;">
                                    <%= isManager ? "Thẩm Định" : "Xem Xét" %>
                                </a>
                            </td>
                        </tr>
                        <% }} else { %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px; color: #64748b;">
                                <i class="fa-solid fa-inbox" style="font-size: 36px; color: #cbd5e1; margin-bottom: 10px; display: block;"></i>
                                Hiện tại không có hồ sơ đề xuất nâng bậc nào cần xử lý.
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

