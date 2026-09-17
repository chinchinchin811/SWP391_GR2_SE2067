<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("currentUser");
    String currentURI = request.getRequestURI();
    int roleId = (user != null) ? user.getRoleId() : 4;
%>
<aside class="sidebar">
    <div class="sidebar-brand">
        <h3>HRM Career Path</h3>
        <span>He thong Quan tri</span>
    </div>

    <ul class="sidebar-menu">
        <li class="<%= currentURI.contains("/dashboard") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/dashboard">Tong quan</a>
        </li>

        <!-- 1. MỤC FLASHCARD: HIỂN THỊ CHO TẤT CẢ MỌI VAI TRÒ (ADMIN, HR, MANAGER, EMPLOYEE, MENTOR) -->
        <li class="<%= currentURI.contains("/flashcards") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/flashcards">The ghi nho (Flashcards)</a>
        </li>

        <!-- 2. MỤC DÀNH CHO HR (ROLE 2) VA ADMIN (ROLE 1) -->
        <% if (roleId == 1 || roleId == 2) { %>
            <div class="sidebar-menu-category">Quan tri To chuc</div>
            <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/departments">Quan ly Phong Ban</a>
            </li>
            <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/positions">Vi tri & Cap bac</a>
            </li>

            <div class="sidebar-menu-category">Quan tri Nhan su</div>
            <li class="<%= currentURI.contains("/employees") && !currentURI.contains("action=create") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/employees">Danh sach Nhan vien</a>
            </li>
            
            <!-- CHỨC NĂNG GHÉP MENTOR DÀNH CHO HR -->
            <li class="<%= currentURI.contains("/mentors") && currentURI.contains("action=pair") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/mentors?action=pair">Ghep noi Mentor</a>
            </li>
            <li class="<%= currentURI.contains("/mentors") && currentURI.contains("action=evaluations") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/mentors?action=evaluations">Danh gia Mentor</a>
            </li>

        <% } else if (roleId == 3) { %>
            <!-- MANAGER (ROLE 3) -->
            <div class="sidebar-menu-category">Phong Ban Phu Trach</div>
            <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/departments">Thong tin Phong Ban</a>
            </li>
            <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/employees">Nhan vien truc thuoc</a>
            </li>
            <li class="<%= currentURI.contains("/mentors") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/mentors?action=evaluations">Xem Danh gia Mentor</a>
            </li>

        <% } else if (roleId == 5) { %>
            <!-- MENTOR (ROLE 5) -->
            <div class="sidebar-menu-category">Nhiem vu Mentor</div>
            <li class="<%= currentURI.contains("/mentors") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/mentors?action=evaluations">Danh gia Mentee</a>
            </li>

        <% } else { %>
            <!-- EMPLOYEE (ROLE 4) -->
            <div class="sidebar-menu-category">Ca Nhan</div>
            <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/employees?action=detail">Ho so ca nhan</a>
            </li>
        <% } %>
    </ul>

    <div class="sidebar-user">
        <div class="user-name"><%= user != null ? user.getFullName() : "Nguoi dung" %></div>
        <div class="user-role">Vai tro: [<%= user != null ? user.getRoleName() : "EMPLOYEE" %>]</div>
        <a href="<%= request.getContextPath() %>/logout" class="logout-link">[Dang xuat]</a>
    </div>
</aside>