<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.LearningMaterial,model.TrainingClass,model.User" %>
<%
    request.setAttribute("pageTitle", "Học liệu & Đào tạo | HRM");
    List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("materials");
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("classes");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    String successMessage = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Học Liệu & Đào Tạo</h1>
        <div>
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
                <span>Tổng: <%= materials != null ? materials.size() : 0 %> học liệu</span>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Học liệu</th>
                            <th>Loại</th>
                            <th>Phạm vi</th>
                            <th>Thời lượng</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (materials != null && !materials.isEmpty()) { 
                            for (LearningMaterial m : materials) { %>
                            <tr>
                                <td>
                                    <b><%= m.getTitle() %></b><br>
                                    <span style="font-size:11px;color:#555"><%= m.getDescription() != null ? m.getDescription() : "" %></span>
                                </td>
                                <td><span class="badge"><%= m.getMaterialType() %></span></td>
                                <td><%= m.getScopeType() %></td>
                                <td><%= m.getDurationMinutes() %> phút</td>
                                <td>
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>">Xem</a>
                                    <% if (canManage) { %>
                                        <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=edit&id=<%= m.getMaterialId() %>">Sửa</a>
                                    <% } %>
                                </td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr><td colspan="5" style="text-align:center">Chưa có học liệu.</td></tr>
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
            <div class="card-body">
                <% if (classes != null && !classes.isEmpty()) { %>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Mã lớp</th>
                                <th>Tên lớp</th>
                                <th>Trạng thái</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (TrainingClass c : classes) { %>
                                <tr>
                                    <td><%= c.getClassCode() %></td>
                                    <td><%= c.getClassName() %></td>
                                    <td><span class="badge"><%= c.getStatus() %></span></td>
                                    <td>
                                        <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= c.getClassId() %>">Vào lớp</a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    Bạn chưa được ghi danh vào lớp nào.
                <% } %>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
