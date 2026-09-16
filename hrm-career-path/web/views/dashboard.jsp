<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.EmployeeHistory" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Tong quan he thong | HRM");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <% if (roleId == 1 || roleId == 2) { %>
        <!-- =========================================================
             1. GIAO DIEN DASHBOARD DANG NHAP BANG HR / ADMIN
             ========================================================= -->
        <div class="topbar">
            <h1>Bao Cao Tong Quan He Thong (HR / Admin)</h1>
            <div>
                <a href="<%= request.getContextPath() %>/employees?action=create" class="btn btn-primary">
                    + Khai bao Nhan vien
                </a>
            </div>
        </div>

        <div class="content-body">
            <!-- Stats toan cong ty -->
            <div class="stats-grid">
                <div class="stat-box">
                    <h3><%= request.getAttribute("totalDepartments") %></h3>
                    <p>Phong ban hoat dong</p>
                </div>
                <div class="stat-box">
                    <h3><%= request.getAttribute("totalPositions") %></h3>
                    <p>Vi tri chuyen mon</p>
                </div>
                <div class="stat-box">
                    <h3><%= request.getAttribute("totalEmployees") %></h3>
                    <p>Tong so nhan su</p>
                </div>
                <div class="stat-box">
                    <h3><%= request.getAttribute("totalNewHires") %></h3>
                    <p>Nhan su moi vao cong ty</p>
                </div>
                <div class="stat-box">
                    <h3><%= request.getAttribute("totalRoleChanges") %></h3>
                    <p>Moi doi chuyen mon/ngach</p>
                </div>
            </div>

            <div style="display: flex; gap: 15px;">
                <!-- Co cau phong ban -->
                <div class="card" style="flex: 1;">
                    <div class="card-header">
                        <h2>Co Cau Phong Ban</h2>
                        <a href="<%= request.getContextPath() %>/departments" class="btn btn-sm btn-secondary">Quan ly</a>
                    </div>
                    <div class="card-body">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Phong Ban</th>
                                    <th>Truong Phong</th>
                                    <th>So Nhan Su</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<Department> departments = (List<Department>) request.getAttribute("departments");
                                    if (departments != null && !departments.isEmpty()) {
                                        for (Department d : departments) {
                                %>
                                <tr>
                                    <td><b><%= d.getDepartmentName() %></b></td>
                                    <td><%= d.getManagerName() != null ? d.getManagerName() : "Chua bo nhiem" %></td>
                                    <td><span class="badge"><%= d.getEmployeeCount() %> nguoi</span></td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="3" style="text-align: center;">Chua co phong ban nao</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Nhan su moi cap nhat -->
                <div class="card" style="flex: 1;">
                    <div class="card-header">
                        <h2>Nhan Su Cap Nhat Gan Day</h2>
                        <a href="<%= request.getContextPath() %>/employees" class="btn btn-sm btn-secondary">Tat ca</a>
                    </div>
                    <div class="card-body">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Ho Ten</th>
                                    <th>Phong Ban</th>
                                    <th>Vi Tri</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<User> recentEmployees = (List<User>) request.getAttribute("recentEmployees");
                                    if (recentEmployees != null && !recentEmployees.isEmpty()) {
                                        for (User emp : recentEmployees) {
                                %>
                                <tr>
                                    <td>
                                        <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= emp.getUserId() %>" style="color: #000; font-weight: bold;">
                                            <%= emp.getFullName() %>
                                        </a>
                                    </td>
                                    <td><%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "-" %></td>
                                    <td><%= emp.getPositionName() != null ? emp.getPositionName() : "-" %></td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="3" style="text-align: center;">Chua co nhan su nao</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    <% } else if (roleId == 3) { %>
        <!-- =========================================================
             2. GIAO DIEN DASHBOARD DANG NHAP BANG MANAGER (TRUONG PHONG)
             ========================================================= -->
        <%
            Department myDept = (Department) request.getAttribute("myDepartment");
            List<User> deptEmployees = (List<User>) request.getAttribute("deptEmployees");
        %>
        <div class="topbar">
            <h1>Phong Ban Phu Trach: <%= myDept != null ? myDept.getDepartmentName() : "Chua duoc phan bo" %></h1>
        </div>

        <div class="content-body">
            <% if (myDept != null) { %>
                <div class="stats-grid">
                    <div class="stat-box">
                        <h3><%= deptEmployees != null ? deptEmployees.size() : 0 %></h3>
                        <p>Nhan su thuoc phong ban cua ban</p>
                    </div>
                    <div class="stat-box">
                        <h3><%= myDept.getDepartmentName() %></h3>
                        <p>Truong phong: <%= currentUser.getFullName() %></p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2>Danh Sach Nhan Su Truc Thuoc Phong Ban</h2>
                    </div>
                    <div class="card-body">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Ho va Ten</th>
                                    <th>Email / SDT</th>
                                    <th>Vi Tri Chuyen Mon</th>
                                    <th>Cap Bac</th>
                                    <th>Thao Tac</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (deptEmployees != null && !deptEmployees.isEmpty()) {
                                        for (User emp : deptEmployees) {
                                %>
                                <tr>
                                    <td><%= emp.getUserId() %></td>
                                    <td><b><%= emp.getFullName() %></b> (@<%= emp.getUsername() %>)</td>
                                    <td><%= emp.getEmail() %> / <%= emp.getPhone() != null ? emp.getPhone() : "-" %></td>
                                    <td><%= emp.getPositionName() != null ? emp.getPositionName() : "Chua phan" %></td>
                                    <td><%= emp.getLevelName() != null ? emp.getLevelName() : "Chua phan" %></td>
                                    <td>
                                        <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= emp.getUserId() %>" class="btn btn-sm btn-secondary">
                                            Xem ho so
                                        </a>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 15px;">Chua co nhan su nao trong phong ban cua ban.</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            <% } else { %>
                <div class="alert alert-danger">
                    Tai khoan nay chua duoc HR gan lam Truong phong cua bat ky phong ban nao.
                </div>
            <% } %>
        </div>

    <% } else { %>
        <!-- =========================================================
             3. GIAO DIEN DASHBOARD DANG NHAP BANG EMPLOYEE (NHAN VIEN)
             ========================================================= -->
        <%
            User myProfile = (User) request.getAttribute("myProfile");
            List<EmployeeHistory> myHistory = (List<EmployeeHistory>) request.getAttribute("myHistory");
        %>
        <div class="topbar">
            <h1>Ho So & Lo Trinh Ca Nhan: <%= myProfile != null ? myProfile.getFullName() : currentUser.getFullName() %></h1>
        </div>

        <div class="content-body">
            <div style="display: flex; gap: 15px;">
                <!-- Thong tin hien tai -->
                <div class="card" style="flex: 1;">
                    <div class="card-header">
                        <h2>Thong Tin Cong Viec Hien Tai</h2>
                    </div>
                    <div class="card-body">
                        <p style="margin-bottom: 8px;"><b>Ho va ten:</b> <%= myProfile.getFullName() %></p>
                        <p style="margin-bottom: 8px;"><b>Username:</b> <%= myProfile.getUsername() %></p>
                        <p style="margin-bottom: 8px;"><b>Email:</b> <%= myProfile.getEmail() %></p>
                        <p style="margin-bottom: 8px;"><b>So dien thoai:</b> <%= myProfile.getPhone() != null ? myProfile.getPhone() : "-" %></p>
                        <p style="margin-bottom: 8px;"><b>Ngay vao cong ty:</b> <%= myProfile.getHireDate() != null ? sdfDate.format(myProfile.getHireDate()) : "-" %></p>
                        <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ccc;">
                        <p style="margin-bottom: 8px;"><b>Phong ban:</b> <%= myProfile.getDepartmentName() != null ? myProfile.getDepartmentName() : "Chua xep phong" %></p>
                        <p style="margin-bottom: 8px;"><b>Vi tri chuyen mon:</b> <%= myProfile.getPositionName() != null ? myProfile.getPositionName() : "Chua xep vi tri" %></p>
                        <p style="margin-bottom: 8px;"><b>Cap bac:</b> <%= myProfile.getLevelName() != null ? myProfile.getLevelName() : "Chua xep cap bac" %></p>
                    </div>
                </div>

                <!-- Lich su nghe nghiep cua ban -->
                <div class="card" style="flex: 2;">
                    <div class="card-header">
                        <h2>Lich Su Bien Dong & Phat Trien Nghe Nghiep Cua Ban</h2>
                    </div>
                    <div class="card-body">
                        <% if (myHistory != null && !myHistory.isEmpty()) { %>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Thoi Gian</th>
                                        <th>Loai Thay Doi</th>
                                        <th>Noi Dung Thay Doi</th>
                                        <th>Ghi Chu</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (EmployeeHistory h : myHistory) {
                                            String typeLabel = "Luan chuyen phong ban";
                                            if ("NEW_HIRE".equalsIgnoreCase(h.getChangeType())) {
                                                typeLabel = "Tuyen dung moi";
                                            } else if ("ROLE_CHANGE".equalsIgnoreCase(h.getChangeType())) {
                                                typeLabel = "Chuyen doi chuyen mon/vi tri";
                                            } else if ("PROMOTION".equalsIgnoreCase(h.getChangeType())) {
                                                typeLabel = "Thang cap bac";
                                            }
                                    %>
                                    <tr>
                                        <td><%= h.getChangeDate() != null ? sdf.format(h.getChangeDate()) : "" %></td>
                                        <td><b><%= typeLabel %></b></td>
                                        <td>
                                            <% if (h.getNewPositionName() != null) { %>
                                                Vi tri: <%= h.getOldPositionName() != null ? h.getOldPositionName() : "(Chua co)" %> -> <b><%= h.getNewPositionName() %></b> <%= h.getNewLevelName() != null ? "(" + h.getNewLevelName() + ")" : "" %><br>
                                            <% } %>
                                            <% if (h.getNewDepartmentName() != null) { %>
                                                Phong ban: <%= h.getOldDepartmentName() != null ? h.getOldDepartmentName() : "(Chua co)" %> -> <b><%= h.getNewDepartmentName() %></b>
                                            <% } %>
                                        </td>
                                        <td><%= h.getNotes() != null ? h.getNotes() : "-" %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <div style="text-align: center; padding: 20px; color: #7f8c8d;">
                                Chua co ghi nhan bien dong lich su chuc vu nao cho ban.
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    <% } %>
</main>

<jsp:include page="/views/common/footer.jsp" />
