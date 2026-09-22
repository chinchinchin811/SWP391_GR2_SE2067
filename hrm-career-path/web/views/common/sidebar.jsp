<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("currentUser");
    String currentURI = request.getRequestURI();
    // THÊM MỚI: Lấy thêm queryString để active đúng menu ghép cặp / đánh giá Mentor
    String queryString = request.getQueryString();
    String fullURI = currentURI + (queryString != null ? "?" + queryString : "");
    
    int roleId = (user != null) ? user.getRoleId() : 4;
%>
<aside class="sidebar">
    <div class="sidebar-brand">
        <h3>HRM Career Path</h3>
        <span>Hệ thống Quản trị</span>
    </div>

    <ul class="sidebar-menu">
        <li class="<%= currentURI.contains("/dashboard") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/dashboard">
                Tổng quan
            </a>
        </li>

        <!-- ================= THÊM MỚI: MENU FLASHCARDS ================= -->
        <li class="<%= currentURI.contains("/flashcards")|| currentURI.contains("/flashcard-list.jsp") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/flashcards">
                Flashcards (Học tập)
            </a>
        </li>
        <!-- ============================================================= -->

        <% if (roleId == 1 || roleId == 2) { %>
        <div class="sidebar-menu-category">Quản trị Tổ chức</div>

        <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/departments">
                Quản lý Phòng Ban
            </a>
        </li>

        <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/positions">
                Vị trí & Cấp bậc
            </a>
        </li>

        <div class="sidebar-menu-category">Quản trị Nhân sự</div>

        <li class="<%= currentURI.contains("/employees") && request.getParameter("action") == null? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees">
                Danh sách Nhân viên
            </a>
        </li>

        <li class="<%= currentURI.contains("/employees") && "create".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees?action=create">
                Khai báo Nhân viên mới
            </a>
        </li>

        <!-- ================= THÊM MỚI: QUẢN LÝ MENTOR CHO ADMIN/HR ================= -->
        <div class="sidebar-menu-category">Quản trị Mentor</div>

        <li class="<%= "pair".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/mentors?action=pair">
                Ghép Nối Mentor
            </a>
        </li>

        <li class="<%= "evaluations".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/mentors?action=evaluations">
                Kết Quả Đánh Giá của Mentor
            </a>
        </li>
        <!-- ========================================================================= -->

        <% } else if (roleId == 3) { %>
        <div class="sidebar-menu-category">Phòng Ban Phụ Trách</div>

        <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/departments">
                Thông tin Phòng Ban
            </a>
        </li>

        <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees">
                Nhân viên trực thuộc
            </a>
        </li>

        <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/positions">
                Vị trí Chuyên môn
            </a>
        </li>

        <% } else { %>
        <div class="sidebar-menu-category">Cá Nhân</div>

        <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= user != null ? user.getUserId() : 0 %>">
                Hồ sơ cá nhân
            </a>
        </li>
        <% } %>

        <!-- ================= THÊM MỚI: WORKSPACE RIÊNG CHO MENTOR ================= -->
        <% if (roleId == 5) { %>
        <div class="sidebar-menu-category">Mentor Workspace</div>
        <li class="<%= fullURI.contains("mentors?action=evaluations") ? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/mentors?action=evaluations">
                Đánh giá Mentee
            </a>
        </li>
        <% } %>
        <!-- ======================================================================== -->

        <div class="sidebar-menu-category">Bài test & Đánh giá</div>


        <li class="<%= currentURI.contains("/tests") && request.getParameter("action") == null? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/tests">
                Danh sách bài test
            </a>
        </li>

        <li class="<%= currentURI.contains("/tests") && "mine".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/tests?action=mine">
                Bài được giao cho tôi
            </a>
        </li>

        <li class="<%= currentURI.contains("/tests") && "calendar".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/tests?action=calendar">
                Lịch bài test
            </a>
        </li>

        <li class="<%= currentURI.contains("/tests") && "notifications".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/tests?action=notifications">
                Thông báo nhắc lịch
            </a>
        </li>

        <% if (roleId == 1 || roleId == 2 || roleId == 3) { %>
        <li class="<%= currentURI.contains("/tests") && "bank".equals(request.getParameter("action"))? "active" : "" %>">
            <a href="<%= request.getContextPath() %>/tests?action=bank">
                Bộ đề & Câu hỏi
            </a>
        </li>
        <% } %>

    </ul>


    <div class="sidebar-user">
        <div class="user-name"><%= user != null ? user.getFullName() : "Nguoi dung" %></div>
        <div class="user-role">Vai trò: [<%= user != null ? user.getRoleName() : "EMPLOYEE" %>]</div>
        <a href="<%= request.getContextPath() %>/logout" class="logout-link">[Đăng xuất]</a>
    </div>



</aside>