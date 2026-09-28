<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("currentUser");
    String currentURI = request.getRequestURI();
    String action = request.getParameter("action");
    int roleId = (user != null) ? user.getRoleId() : 4;

    boolean organizationActive = currentURI.contains("/departments") || currentURI.contains("/positions");
    boolean employeeActive = currentURI.contains("/employees");
    boolean mentorAdminActive = currentURI.contains("/mentors")
            && ("pair".equals(action) || "evaluations".equals(action));
    boolean mentorWorkspaceActive = currentURI.contains("/mentors") && "evaluations".equals(action);
    boolean trainingActive = currentURI.contains("/materials");
    boolean testActive = currentURI.contains("/tests");
    
    User loggedInUser = (User) session.getAttribute("currentUser");
%>
<aside class="sidebar">
    <div class="sidebar-brand">
        <h3>HRM Career Path</h3>
        <span>Hệ thống Quản trị</span>
    </div>

    <nav class="sidebar-menu" aria-label="Điều hướng chính">
        <ul class="sidebar-menu-list">
            <li class="<%= currentURI.contains("/dashboard") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/dashboard">Tổng quan</a>
            </li>

            <li class="<%= currentURI.contains("/flashcards") || currentURI.contains("/flashcard-list.jsp") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/flashcards">Flashcards</a>                
            </li>

            <% 
    // Giả sử Role ID của Mentor trong database của bạn là 5
    if (loggedInUser != null && loggedInUser.getRoleId() == 6) { 
            %>
            <li class="nav-item">
                <a class="nav-link" href="<%= request.getContextPath() %>/mentors?action=myMentees">
                    Danh sách Mentee
                </a>
            </li>
            <% 
                } 
            %>
            
            <% if (roleId == 1 || roleId == 2) { %>
            <li class="sidebar-section <%= organizationActive ? "has-active" : "" %>" data-sidebar-section="organization">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-organization">
                    <span>Quản trị Tổ chức</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-organization">
                    <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/departments">Quản lý Phòng Ban</a>
                    </li>
                    <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/positions">Vị trí &amp; Cấp bậc</a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-section <%= employeeActive ? "has-active" : "" %>" data-sidebar-section="employees">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-employees">
                    <span>Quản trị Nhân sự</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-employees">
                    <li class="<%= currentURI.contains("/employees") && action == null ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees">Danh sách Nhân viên</a>
                    </li>
                    <li class="<%= currentURI.contains("/employees") && "create".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees?action=create">Khai báo Nhân viên mới</a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-section <%= mentorAdminActive ? "has-active" : "" %>" data-sidebar-section="mentor-admin">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-mentor-admin">
                    <span>Quản trị Mentor</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-mentor-admin">
                    <li class="<%= currentURI.contains("/mentors") && "pair".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/mentors?action=pair">Ghép Nối Mentor</a>
                    </li>
                    <li class="<%= currentURI.contains("/mentors") && "evaluations".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/mentors?action=evaluations">Kết Quả Đánh Giá của Mentor</a>
                    </li>
                </ul>
            </li>
            <% } else if (roleId == 3) { %>
            <li class="sidebar-section <%= (organizationActive || employeeActive) ? "has-active" : "" %>" data-sidebar-section="managed-department">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-managed-department">
                    <span>Phòng Ban Phụ Trách</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-managed-department">
                    <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/departments">Thông tin Phòng Ban</a>
                    </li>
                    <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees">Nhân viên trực thuộc</a>
                    </li>
                    <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/positions">Vị trí Chuyên môn</a>
                    </li>
                </ul>
            </li>
            <% } else { %>
            <li class="sidebar-section <%= employeeActive ? "has-active" : "" %>" data-sidebar-section="personal">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-personal">
                    <span>Cá Nhân</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-personal">
                    <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees?action=detail&amp;id=<%= user != null ? user.getUserId() : 0 %>">Hồ sơ cá nhân</a>
                    </li>
                </ul>
            </li>
            <% } %>

            <% if (roleId == 5) { %>
            <li class="sidebar-section <%= mentorWorkspaceActive ? "has-active" : "" %>" data-sidebar-section="mentor-workspace">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-mentor-workspace">
                    <span>Mentor Workspace</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-mentor-workspace">
                    <li class="<%= mentorWorkspaceActive ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/mentors?action=evaluations">Đánh giá Mentee</a>
                    </li>
                </ul>
            </li>
            <% } %>

            <li class="sidebar-section <%= trainingActive ? "has-active" : "" %>" data-sidebar-section="training">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-training">
                    <span>Đào tạo &amp; Phát triển</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-training">
                    <li class="<%= currentURI.contains("/materials") && (action == null || "list".equals(action) || "view".equals(action) || "create".equals(action) || "edit".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/materials">Học liệu &amp; Đào tạo</a>
                    </li>
                    <li class="<%= currentURI.contains("/materials") && ("classList".equals(action) || "classDetail".equals(action) || "classAssign".equals(action) || "classCreate".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/materials?action=classList">Lớp Đào Tạo</a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-section <%= testActive ? "has-active" : "" %>" data-sidebar-section="tests">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-tests">
                    <span>Bài test &amp; Đánh giá</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true">⌄</span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-tests">
                    <li class="<%= currentURI.contains("/tests") && (action == null || "list".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/tests">Danh sách bài test</a>
                    </li>
                    <li class="<%= currentURI.contains("/tests") && "calendar".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/tests?action=calendar">Lịch bài test</a>
                    </li>
                    <% if (roleId == 1 || roleId == 2 || roleId == 3) { %>
                    <li class="<%= currentURI.contains("/tests") && ("bank".equals(action) || "bankDetail".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/tests?action=bank">Bộ đề &amp; Câu hỏi</a>
                    </li>
                    <% } %>
                </ul>
            </li>
        </ul>
    </nav>

    <div class="sidebar-user">
        <div class="user-name"><%= user != null ? user.getFullName() : "Người dùng" %></div>
        <div class="user-role">Vai trò: [<%= user != null ? user.getRoleName() : "EMPLOYEE" %>]</div>
        <a href="<%= request.getContextPath() %>/logout" class="logout-link">Đăng xuất</a>
    </div>
</aside>

<script>
    (function () {
        document.querySelectorAll('.sidebar-section').forEach(function (section) {
            var button = section.querySelector('.sidebar-menu-category');
            var sectionName = section.getAttribute('data-sidebar-section');
            var storageKey = 'hrm.sidebar.' + sectionName + '.collapsed';
            var collapsed = false;

            try {
                collapsed = localStorage.getItem(storageKey) === 'true';
            } catch (ignored) {
                collapsed = false;
            }

            if (section.classList.contains('has-active')) {
                collapsed = false;
            }

            function render() {
                section.classList.toggle('is-collapsed', collapsed);
                button.setAttribute('aria-expanded', String(!collapsed));
            }

            render();
            button.addEventListener('click', function () {
                collapsed = !collapsed;
                render();
                try {
                    localStorage.setItem(storageKey, String(collapsed));
                } catch (ignored) {
                    // Sidebar van hoat dong neu trinh duyet chan localStorage.
                }
            });
        });
    }());

</script>
