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
        <div class="brand-icon"><i class="fa-solid fa-layer-group"></i></div>
        <div class="brand-text">
            <h3>HRM Career Path</h3>
            <span>Hệ thống Quản trị</span>
        </div>
    </div>

    <nav class="sidebar-menu" aria-label="Điều hướng chính">
        <ul class="sidebar-menu-list">
            <li class="<%= currentURI.contains("/dashboard") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/dashboard"><i class="fa-solid fa-chart-pie nav-icon"></i> <span>Tổng quan</span></a>
            </li>

            <li class="<%= currentURI.contains("/flashcards") || currentURI.contains("/flashcard-list.jsp") ? "active" : "" %>">
                <a href="<%= request.getContextPath() %>/flashcards"><i class="fa-solid fa-clone nav-icon"></i> <span>Flashcards</span></a>                
            </li>

            <% if (loggedInUser != null && loggedInUser.getRoleId() == 4) { %>
            <li class="nav-item">
                <a class="nav-link" href="<%= request.getContextPath() %>/mentors?action=myMentor">
                    Mentor Hướng Dẫn Của Tôi
                </a>
            </li>

            <% } %>
            <% 
    // Giả sử Role ID của Mentor trong database của bạn là 5
    if (loggedInUser != null && loggedInUser.getRoleId() == 6) { 
            %>
            <li class="nav-item">
                <a class="nav-link" href="<%= request.getContextPath() %>/mentors?action=myMentees">
                    <i class="fa-solid fa-user-graduate nav-icon"></i> <span>Danh sách Mentee</span>
                </a>
            </li>
            <% 
                } 
            %>

            <% if (roleId == 1 || roleId == 2) { %>
            <li class="sidebar-section <%= organizationActive ? "has-active" : "" %>" data-sidebar-section="organization">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-organization">
                    <span><i class="fa-solid fa-sitemap nav-cat-icon"></i> Quản trị Tổ chức</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-organization">
                    <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/departments"><i class="fa-regular fa-building nav-icon"></i> <span>Quản lý Phòng Ban</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/positions"><i class="fa-solid fa-id-badge nav-icon"></i> <span>Vị trí &amp; Cấp bậc</span></a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-section <%= employeeActive ? "has-active" : "" %>" data-sidebar-section="employees">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-employees">
                    <span><i class="fa-solid fa-users-gear nav-cat-icon"></i> Quản trị Nhân sự</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-employees">
                    <li class="<%= currentURI.contains("/employees") && action == null ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees"><i class="fa-solid fa-address-book nav-icon"></i> <span>Danh sách Nhân viên</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/employees") && "create".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees?action=create"><i class="fa-solid fa-user-plus nav-icon"></i> <span>Khai báo Nhân viên mới</span></a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-section <%= mentorAdminActive ? "has-active" : "" %>" data-sidebar-section="mentor-admin">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-mentor-admin">
                    <span><i class="fa-solid fa-handshake nav-cat-icon"></i> Quản trị Mentor</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-mentor-admin">
                    <li class="<%= currentURI.contains("/mentors") && "pair".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/mentors?action=pair"><i class="fa-solid fa-link nav-icon"></i> <span>Ghép Nối Mentor</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/mentors") && "evaluations".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/mentors?action=evaluations"><i class="fa-solid fa-clipboard-check nav-icon"></i> <span>Kết Quả Đánh Giá của Mentor</span></a>
                    </li>
                </ul>
            </li>
            <% } else if (roleId == 3) { %>
            <li class="sidebar-section <%= (organizationActive || employeeActive) ? "has-active" : "" %>" data-sidebar-section="managed-department">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-managed-department">
                    <span><i class="fa-solid fa-building-user nav-cat-icon"></i> Phòng Ban Phụ Trách</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-managed-department">
                    <li class="<%= currentURI.contains("/departments") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/departments"><i class="fa-regular fa-building nav-icon"></i> <span>Thông tin Phòng Ban</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees"><i class="fa-solid fa-users nav-icon"></i> <span>Nhân viên trực thuộc</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/positions") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/positions"><i class="fa-solid fa-id-badge nav-icon"></i> <span>Vị trí Chuyên môn</span></a>
                    </li>
                </ul>
            </li>
            <% } else { %>
            <li class="sidebar-section <%= employeeActive ? "has-active" : "" %>" data-sidebar-section="personal">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-personal">
                    <span><i class="fa-solid fa-circle-user nav-cat-icon"></i> Cá Nhân</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-personal">
                    <li class="<%= currentURI.contains("/employees") ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/employees?action=detail&amp;id=<%= user != null ? user.getUserId() : 0 %>"><i class="fa-regular fa-id-card nav-icon"></i> <span>Hồ sơ cá nhân</span></a>
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
                        <a href="<%= request.getContextPath() %>/mentors?action=evaluations"><i class="fa-solid fa-clipboard-check nav-icon"></i> <span>Đánh giá Mentee</span></a>
                    </li>
                </ul>
            </li>
            <% 
    // Kiểm tra nếu là Mentor (Giả sử Role ID của Mentor trong DB của bạn là 5, nếu khác hãy sửa lại số này)
    if (loggedInUser != null && loggedInUser.getRoleId() == 5) { 
            %>
            <li class="nav-item">
                <a class="nav-link" href="<%= request.getContextPath() %>/mentors?action=myMentees">
                    Danh sách Mentee của tôi
                </a>
            </li>
            <% 
                } 
            %>
            <% } %>

            <li class="sidebar-section <%= trainingActive ? "has-active" : "" %>" data-sidebar-section="training">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-training">
                    <span><i class="fa-solid fa-graduation-cap nav-cat-icon"></i> Đào tạo &amp; Phát triển</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-training">
                    <li class="<%= currentURI.contains("/materials") && (action == null || "list".equals(action) || "view".equals(action) || "create".equals(action) || "edit".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/materials"><i class="fa-solid fa-book-bookmark nav-icon"></i> <span>Học liệu &amp; Đào tạo</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/materials") && ("classList".equals(action) || "classDetail".equals(action) || "classAssign".equals(action) || "classCreate".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/materials?action=classList"><i class="fa-solid fa-chalkboard-user nav-icon"></i> <span>Lớp Đào Tạo</span></a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-section <%= testActive ? "has-active" : "" %>" data-sidebar-section="tests">
                <button class="sidebar-menu-category" type="button" aria-expanded="true" aria-controls="sidebar-tests">
                    <span><i class="fa-solid fa-file-lines nav-cat-icon"></i> Bài test &amp; Đánh giá</span>
                    <span class="sidebar-menu-category-icon" aria-hidden="true"><i class="fa-solid fa-chevron-down"></i></span>
                </button>
                <ul class="sidebar-submenu" id="sidebar-tests">
                    <li class="<%= currentURI.contains("/tests") && (action == null || "list".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/tests"><i class="fa-solid fa-list-check nav-icon"></i> <span>Danh sách bài test</span></a>
                    </li>
                    <li class="<%= currentURI.contains("/tests") && "calendar".equals(action) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/tests?action=calendar"><i class="fa-regular fa-calendar-days nav-icon"></i> <span>Lịch bài test</span></a>
                    </li>
                    <% if (roleId == 1 || roleId == 2 || roleId == 3) { %>
                    <li class="<%= currentURI.contains("/tests") && ("bank".equals(action) || "bankDetail".equals(action)) ? "active" : "" %>">
                        <a href="<%= request.getContextPath() %>/tests?action=bank"><i class="fa-solid fa-box-archive nav-icon"></i> <span>Bộ đề &amp; Câu hỏi</span></a>
                    </li>
                    <% } %>
                </ul>
            </li>
        </ul>
    </nav>

    <div class="sidebar-user">
        <div class="user-avatar-circle">
            <i class="fa-solid fa-user-tie"></i>
        </div>
        <div class="user-info">
            <div class="user-name"><%= user != null ? user.getFullName() : "Người dùng" %></div>
            <div class="user-role"><%= user != null ? user.getRoleName() : "EMPLOYEE" %></div>
        </div>
        <a href="<%= request.getContextPath() %>/logout" class="logout-link" title="Đăng xuất"><i class="fa-solid fa-arrow-right-from-bracket"></i></a>
    </div>
</aside>

<script>
    (function () {
        var sections = document.querySelectorAll('.sidebar-section');
        sections.forEach(function (section) {
            var button = section.querySelector('.sidebar-menu-category');
            var submenu = section.querySelector('.sidebar-submenu');
            if (!button || !submenu) return;

            var sectionName = section.getAttribute('data-sidebar-section');
            var storageKey = 'hrm.sidebar.' + sectionName + '.open';
            var isCurrentActive = section.classList.contains('has-active');
            
            // Mặc định: Chỉ mục đang active là MỞ, các mục khác ĐÓNG thành dropdown
            var isOpen = isCurrentActive;
            try {
                var saved = localStorage.getItem(storageKey);
                if (saved !== null) {
                    isOpen = (saved === 'true');
                }
            } catch (e) {}

            // Trang hiện tại luôn được mở
            if (isCurrentActive) {
                isOpen = true;
            }

            function setDropdownState(open, animated) {
                if (!animated) {
                    submenu.style.transition = 'none';
                } else {
                    submenu.style.transition = 'max-height 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease';
                }

                if (open) {
                    section.classList.remove('is-collapsed');
                    section.classList.add('is-open');
                    button.setAttribute('aria-expanded', 'true');
                    submenu.style.maxHeight = (submenu.scrollHeight + 50) + 'px';
                    submenu.style.opacity = '1';
                    submenu.style.pointerEvents = 'auto';
                } else {
                    section.classList.add('is-collapsed');
                    section.classList.remove('is-open');
                    button.setAttribute('aria-expanded', 'false');
                    submenu.style.maxHeight = '0px';
                    submenu.style.opacity = '0';
                    submenu.style.pointerEvents = 'none';
                }
            }

            // Thiết lập trạng thái ban đầu
            setDropdownState(isOpen, false);

            // Bật lại animation sau 60ms
            setTimeout(function () {
                submenu.style.transition = 'max-height 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease';
            }, 60);

            button.addEventListener('click', function (e) {
                e.preventDefault();
                isOpen = !isOpen;
                setDropdownState(isOpen, true);
                try {
                    localStorage.setItem(storageKey, String(isOpen));
                } catch (ignored) {}
            });
        });
    }());
</script>
