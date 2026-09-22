<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.LearningMaterial,model.TrainingClass,model.User" %>
<%
    request.setAttribute("pageTitle", "Hoc lieu & Dao tao | HRM");
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
    <div class="topbar"><h1>Hoc Lieu & Dao Tao</h1><div><a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Quan ly lop dao tao</a><% if (canManage) { %><a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=create">+ Them hoc lieu</a><% } %></div></div>
    <div class="content-body">
        <% if (successMessage != null) { %><div class="alert alert-success"><%= successMessage %></div><% } %>
        <div class="card"><div class="card-header"><h2>Kho Hoc Lieu</h2><span>Tong: <%= materials != null ? materials.size() : 0 %> hoc lieu</span></div><div class="card-body"><table class="data-table"><thead><tr><th>Hoc lieu</th><th>Loai</th><th>Pham vi</th><th>Thoi luong</th><th>Thao tac</th></tr></thead><tbody><% if (materials != null && !materials.isEmpty()) { for (LearningMaterial m : materials) { %><tr><td><b><%= m.getTitle() %></b><br><span style="font-size:11px;color:#555"><%= m.getDescription() != null ? m.getDescription() : "" %></span></td><td><span class="badge"><%= m.getMaterialType() %></span></td><td><%= m.getScopeType() %></td><td><%= m.getDurationMinutes() %> phut</td><td><a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>">Xem</a><% if (canManage) { %> <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=edit&id=<%= m.getMaterialId() %>">Sua</a><% } %></td></tr><% } } else { %><tr><td colspan="5" style="text-align:center">Chua co hoc lieu.</td></tr><% } %></tbody></table></div></div>
        <div class="card"><div class="card-header"><h2>Lop Dao Tao Cua Toi</h2><a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Xem tat ca</a></div><div class="card-body"><% if (classes != null && !classes.isEmpty()) { %><table class="data-table"><thead><tr><th>Ma lop</th><th>Ten lop</th><th>Trang thai</th><th></th></tr></thead><tbody><% for (TrainingClass c : classes) { %><tr><td><%= c.getClassCode() %></td><td><%= c.getClassName() %></td><td><span class="badge"><%= c.getStatus() %></span></td><td><a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= c.getClassId() %>">Vao lop</a></td></tr><% } %></tbody></table><% } else { %>Ban chua duoc ghi danh vao lop nao.<% } %></div></div>
    </div>
</main><jsp:include page="/views/common/footer.jsp" />
