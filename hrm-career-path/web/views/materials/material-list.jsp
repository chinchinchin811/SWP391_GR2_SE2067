<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.text.SimpleDateFormat,model.LearningMaterial,model.TrainingClass,model.User" %>
<%
    request.setAttribute("pageTitle", "Học liệu & Đào tạo | HRM");
    List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("materials");
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("classes");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    String successMessage = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Học Liệu &amp; Đào Tạo</h1>
        <div class="topbar-actions">
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Quản lý lớp đào tạo</a>
            <% if (canManage) { %>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=create">+ Thêm học liệu</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <h2>Kho Học Liệu</h2>
                <span class="badge-count">Tổng: <%= materials != null ? materials.size() : 0 %> học liệu</span>
            </div>
            <div class="card-body" style="padding:0">
                <table class="data-table">
                    <colgroup>
                        <col style="width:44%">
                        <col style="width:10%">
                        <col style="width:13%">
                        <col style="width:13%">
                        <col style="width:20%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th style="text-align:left;padding-left:14px">Học liệu</th>
                            <th style="text-align:center">Loại</th>
                            <th style="text-align:center">Phạm vi</th>
                            <th style="text-align:center">Thời lượng</th>
                            <th style="text-align:center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (materials != null && !materials.isEmpty()) {
                            for (LearningMaterial m : materials) { %>
                        <tr>
                            <td style="padding-left:14px">
                                <div style="font-size:13px;font-weight:600;line-height:1.4"><%= m.getTitle() %></div>
                                <% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
                                <div style="font-size:11.5px;color:#666;margin-top:3px;line-height:1.4"><%= m.getDescription() %></div>
                                <% } %>
                            </td>
                            <td style="text-align:center"><span class="badge"><%= m.getMaterialType() %></span></td>
                            <td style="text-align:center;font-size:12.5px"><%= m.getScopeType() %></td>
                            <td style="text-align:center;font-size:12.5px"><%= m.getDurationMinutes() %> phút</td>
                            <td style="text-align:center">
                                <div class="action-btn-group">
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>">Xem</a>
                                    <% if (canManage) { %>
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=edit&id=<%= m.getMaterialId() %>">Sửa</a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="5" style="text-align:center;padding:28px;color:#666;font-size:13px">Chưa có học liệu nào.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2>Lớp Đào Tạo Của Tôi</h2>
                <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Xem tất cả</a>
            </div>
            <div class="card-body" style="padding:0">
                <% if (classes != null && !classes.isEmpty()) { %>
                <table class="data-table">
                    <colgroup>
                        <col style="width:22%">
                        <col style="width:43%">
                        <col style="width:20%">
                        <col style="width:15%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th style="text-align:center">Mã lớp</th>
                            <th style="text-align:center">Tên lớp</th>
                            <th style="text-align:center">Trạng thái</th>
                            <th style="text-align:center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (TrainingClass c : classes) { %>
                        <tr>
                            <td style="text-align:center;font-size:12px"><%= c.getClassCode() %></td>
                            <td style="text-align:center;font-size:13px;font-weight:600"><%= c.getClassName() %></td>
                            <td style="text-align:center"><span class="badge"><%= c.getStatus() %></span></td>
                            <td style="text-align:center">
                                <a class="btn btn-sm btn-primary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= c.getClassId() %>">Vào lớp</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div style="padding:20px;text-align:center;color:#666;font-size:13px">Bạn chưa được ghi danh vào lớp nào.</div>
                <% } %>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
