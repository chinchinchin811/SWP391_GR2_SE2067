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
            <a href="<%= request.getContextPath() %>/dashboard">
                Tong quan
            </a>
        </li>

        <% if (roleId == 1 || roleId == 2) { %>
        <div class="sidebar-menu-category">Quan tri To chuc</div>

        <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/departments">
                Quan ly Phong Ban
            </a>
        </li>

        <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/positions">
                Vi tri & Cap bac
            </a>
        </li>

        <div class="sidebar-menu-category">Quan tri Nhan su</div>

        <li class="<%= currentURI.contains("/employees") && !currentURI.contains("action=create") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees">
                Danh sach Nhan vien
            </a>
        </li>

        <li>
            <a href="<%= request.getContextPath() %>/employees?action=create">
                Khai bao Nhan vien moi
            </a>
        </li>

        <% } else if (roleId == 3) { %>
        <div class="sidebar-menu-category">Phong Ban Phu Trach</div>

        <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/departments">
                Thong tin Phong Ban
            </a>
        </li>

        <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees">
                Nhan vien truc thuoc
            </a>
        </li>

        <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/positions">
                Vi tri Chuyen mon
            </a>
        </li>

        <% } else { %>
        <div class="sidebar-menu-category">Ca Nhan</div>

        <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= user != null ? user.getUserId() : 0 %>">
                Ho so ca nhan
            </a>
        </li>
        <% } %>
        <div class="sidebar-menu-category">Bài test & Đánh giá</div>
        <li><a href="<%= request.getContextPath() %>/tests">Danh sách bài test</a></li>
        <li><a href="<%= request.getContextPath() %>/tests?action=calendar">Lịch bài test</a></li>
            <% if (roleId == 1 || roleId == 2 || roleId == 3) { %>
        <li><a href="<%= request.getContextPath() %>/tests?action=bank">Bộ đề & Câu hỏi</a></li>
            <% } %>
    </ul>

    <div class="sidebar-user">
        <div class="user-name"><%= user != null ? user.getFullName() : "Nguoi dung" %></div>
        <div class="user-role">Vai tro: [<%= user != null ? user.getRoleName() : "EMPLOYEE" %>]</div>
        <a href="<%= request.getContextPath() %>/logout" class="logout-link">[Dang xuat]</a>
    </div>
</aside>
