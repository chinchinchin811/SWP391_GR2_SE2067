<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.EmployeeHistory" %>
<%@ page import="model.PositionRequest" %>
<%@ page import="model.TransferRequest" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    request.setAttribute("pageTitle", "Tổng quan hệ thống | HRM");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <% if (roleId == 1) { %>
    <!-- =========================================================
         1. GIAO DIEN DASHBOARD DANG NHAP BANG ADMIN (QUAN TRI VIEN)
         ========================================================= -->
    <div class="topbar">
        <div>
            <h1>Báo Cáo Quản Trị Hệ Thống (Admin Dashboard)</h1>
            <span style="color: #64748b; font-size: 13px;">Quản lý cơ cấu phòng ban, danh mục vị trí và xét duyệt đề xuất chuyên môn</span>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
            <a href="<%= request.getContextPath() %>/departments?action=create" class="btn btn-secondary">
                <i class="fa-solid fa-plus"></i> Thêm Phòng Ban
            </a>
            <a href="<%= request.getContextPath() %>/positions?action=create" class="btn btn-secondary">
                <i class="fa-solid fa-plus"></i> Thêm Vị Trí
            </a>
            <a href="<%= request.getContextPath() %>/positions?action=requests" class="btn btn-primary">
                <i class="fa-solid fa-clipboard-check"></i> Duyệt Đề Xuất Vị Trí
                <% 
                    Object pendingReqCountObj = request.getAttribute("countPendingRequests");
                    int pendingReqCount = (pendingReqCountObj != null) ? (Integer) pendingReqCountObj : 0;
                    if (pendingReqCount > 0) { 
                %>
                    <span class="badge" style="background-color: #ef4444; color: #fff; margin-left: 5px;"><%= pendingReqCount %></span>
                <% } %>
            </a>
        </div>
    </div>

    <div class="content-body">
        <!-- Stats Admin -->
        <div class="stats-grid">
            <div class="stat-box">
                <h3><%= request.getAttribute("totalDepartments") != null ? request.getAttribute("totalDepartments") : 0 %></h3>
                <p>Phòng ban hoạt động</p>
            </div>
            <div class="stat-box">
                <h3><%= request.getAttribute("totalPositions") != null ? request.getAttribute("totalPositions") : 0 %></h3>
                <p>Vị trí chuyên môn</p>
            </div>
            <div class="stat-box">
                <h3><%= request.getAttribute("totalEmployees") != null ? request.getAttribute("totalEmployees") : 0 %></h3>
                <p>Tổng số nhân sự</p>
            </div>
            <div class="stat-box">
                <h3 style="color: #ef4444;"><%= pendingReqCount %></h3>
                <p>Yêu cầu vị trí chờ duyệt</p>
            </div>
        </div>

        <div style="display: flex; gap: 15px;">
            <!-- De xuat vi tri cho duyet -->
            <div class="card" style="flex: 1.2;">
                <div class="card-header">
                    <h2>Đề Xuất Vị Trí Mới Chờ Duyệt</h2>
                    <a href="<%= request.getContextPath() %>/positions?action=requests" class="btn btn-sm btn-secondary">Tất cả</a>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Vị Trí Đề Xuất</th>
                                <th>Phòng Ban</th>
                                <th>Người Đề Xuất</th>
                                <th>Ngày Gửi</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<PositionRequest> pendingPosRequests = (List<PositionRequest>) request.getAttribute("pendingPositionRequests");
                                if (pendingPosRequests != null && !pendingPosRequests.isEmpty()) {
                                    for (PositionRequest pr : pendingPosRequests) {
                            %>
                            <tr>
                                <td><b><%= pr.getPositionName() %></b></td>
                                <td><%= pr.getDepartmentName() != null ? pr.getDepartmentName() : "-" %></td>
                                <td><%= pr.getManagerName() != null ? pr.getManagerName() : "Trưởng phòng" %></td>
                                <td><%= pr.getCreatedAt() != null ? sdfDate.format(pr.getCreatedAt()) : "-" %></td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/positions?action=requests" class="btn btn-sm btn-primary">
                                        Xem & Duyệt
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 15px; color: #64748b;">
                                    Hiện không có đề xuất vị trí nào chờ phê duyệt.
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Co cau phong ban -->
            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Cơ Cấu Phòng Ban & Trưởng Phòng</h2>
                    <a href="<%= request.getContextPath() %>/departments" class="btn btn-sm btn-secondary">Quản lý</a>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Phòng Ban</th>
                                <th>Trưởng Phòng</th>
                                <th>Số Nhân Sự</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<Department> adminDepts = (List<Department>) request.getAttribute("departments");
                                if (adminDepts != null && !adminDepts.isEmpty()) {
                                    for (Department d : adminDepts) {
                            %>
                            <tr>
                                <td><b><%= d.getDepartmentName() %></b></td>
                                <td><%= d.getManagerName() != null ? d.getManagerName() : "Chưa bổ nhiệm" %></td>
                                <td><span class="badge"><%= d.getEmployeeCount() %> người</span></td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="3" style="text-align: center; padding: 15px; color: #64748b;">Chưa có phòng ban nào</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <% } else if (roleId == 2) { %>
    <!-- =========================================================
         2. GIAO DIEN DASHBOARD DANG NHAP BANG HR (QUAN LY NHAN SU)
         ========================================================= -->
    <div class="topbar">
        <div>
            <h1>Báo Cáo Tổng Quan Nhân Sự (HR Dashboard)</h1>
            <span style="color: #64748b; font-size: 13px;">Khai báo nhân viên mới, điều chuyển nội bộ và quản lý đội ngũ nhân sự</span>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
            <a href="<%= request.getContextPath() %>/employees?action=create" class="btn btn-primary">
                <i class="fa-solid fa-user-plus"></i> + Khai Báo Nhân Viên Mới
            </a>
            <a href="<%= request.getContextPath() %>/transfer?action=hrRequests" class="btn btn-secondary">
                <i class="fa-solid fa-people-arrows"></i> Điều Chuyển Nhân Sự
                <% 
                    Object pendingTransferCountObj = request.getAttribute("countPendingTransfers");
                    int pendingTransferCount = (pendingTransferCountObj != null) ? (Integer) pendingTransferCountObj : 0;
                    if (pendingTransferCount > 0) { 
                %>
                    <span class="badge" style="background-color: #ef4444; color: #fff; margin-left: 5px;"><%= pendingTransferCount %></span>
                <% } %>
            </a>
            <a href="<%= request.getContextPath() %>/mentors?action=pair" class="btn btn-secondary">
                <i class="fa-solid fa-handshake"></i> Ghép Nối Mentor
            </a>
        </div>
    </div>

    <div class="content-body">
        <!-- Stats HR -->
        <div class="stats-grid">
            <div class="stat-box">
                <h3><%= request.getAttribute("totalEmployees") != null ? request.getAttribute("totalEmployees") : 0 %></h3>
                <p>Tổng số nhân sự</p>
            </div>
            <div class="stat-box">
                <h3 style="color: #059669;"><%= request.getAttribute("totalNewHires") != null ? request.getAttribute("totalNewHires") : 0 %></h3>
                <p>Nhân sự mới vào công ty</p>
            </div>
            <div class="stat-box">
                <h3 style="color: #2563eb;"><%= request.getAttribute("totalRoleChanges") != null ? request.getAttribute("totalRoleChanges") : 0 %></h3>
                <p>Mới đổi chuyên môn/ngạch</p>
            </div>
            <div class="stat-box">
                <h3 style="color: #d97706;"><%= pendingTransferCountObj != null ? pendingTransferCountObj : 0 %></h3>
                <p>Yêu cầu điều chuyển chờ xử lý</p>
            </div>
            <div class="stat-box">
                <h3><%= request.getAttribute("totalDepartments") != null ? request.getAttribute("totalDepartments") : 0 %></h3>
                <p>Phòng ban hoạt động</p>
            </div>
        </div>

        <div style="display: flex; gap: 15px;">
            <!-- De xuat dieu chuyen cho HR xu ly -->
            <div class="card" style="flex: 1.2;">
                <div class="card-header">
                    <h2>Đề Xuất Điều Chuyển Chờ HR Xử Lý</h2>
                    <a href="<%= request.getContextPath() %>/transfer?action=hrRequests" class="btn btn-sm btn-secondary">Tất cả</a>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Nhân Viên</th>
                                <th>Phòng Ban Chuyển</th>
                                <th>Vị Trí Mới</th>
                                <th>Trưởng Phòng Duyệt</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<TransferRequest> pendingTransfers = (List<TransferRequest>) request.getAttribute("pendingTransfers");
                                if (pendingTransfers != null && !pendingTransfers.isEmpty()) {
                                    for (TransferRequest tr : pendingTransfers) {
                            %>
                            <tr>
                                <td><b><%= tr.getEmployeeName() %></b></td>
                                <td>
                                    <small style="color: #64748b;"><%= tr.getCurrentDepartmentName() != null ? tr.getCurrentDepartmentName() : "Chưa có" %></small>
                                    <i class="fa-solid fa-arrow-right" style="font-size: 10px; margin: 0 4px; color: #94a3b8;"></i>
                                    <b><%= tr.getTargetDepartmentName() != null ? tr.getTargetDepartmentName() : "-" %></b>
                                </td>
                                <td><%= tr.getTargetPositionName() != null ? tr.getTargetPositionName() : "Chưa xếp" %></td>
                                <td>
                                    <span class="badge" style="background-color: #dcfce7; color: #166534;">
                                        <%= tr.getManagerReviewerName() != null ? tr.getManagerReviewerName() : "Đã duyệt" %>
                                    </span>
                                </td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/transfer?action=hrRequests" class="btn btn-sm btn-primary">
                                        Xử lý
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 15px; color: #64748b;">
                                    Không có đề xuất điều chuyển nào cần xử lý.
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Nhan su moi cap nhat -->
            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Nhân Sự Toàn Công Ty Gần Đây</h2>
                    <a href="<%= request.getContextPath() %>/employees" class="btn btn-sm btn-secondary">Tất cả</a>
                </div>
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Họ Tên</th>
                                <th>Phòng Ban</th>
                                <th>Vị Trí</th>
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
                                <td colspan="3" style="text-align: center; padding: 15px; color: #64748b;">Chưa có nhân sự nào</td>
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
        <h1>Phòng Ban Phụ Trách: <%= myDept != null ? myDept.getDepartmentName() : "Chưa được phân bổ" %></h1>
    </div>

    <div class="content-body">
        <% if (myDept != null) { %>
        <div class="stats-grid">
            <div class="stat-box">
                <h3><%= deptEmployees != null ? deptEmployees.size() : 0 %></h3>
                <p>Nhân sự thuộc phòng ban của bạn</p>
            </div>
            <div class="stat-box">
                <h3><%= myDept.getDepartmentName() %></h3>
                <p>Trưởng phòng: <%= currentUser.getFullName() %></p>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2>Danh Sách Nhân Sự Trực Thuộc Phòng Ban</h2>
            </div>
            <div class="card-body">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Họ và Tên</th>
                            <th>Email / SĐT</th>
                            <th>Vị Trí Chuyên Môn</th>
                            <th>Cấp Bậc</th>
                            <th>Thao Tác</th>
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
                            <td><%= emp.getPositionName() != null ? emp.getPositionName() : "Chưa phân" %></td>
                            <td><%= emp.getLevelName() != null ? emp.getLevelName() : "Chưa phân" %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= emp.getUserId() %>" class="btn btn-sm btn-secondary">
                                    Xem hồ sơ
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 15px;">Chưa có nhân sự nào trong phòng ban của bạn.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } else { %>
        <div class="alert alert-danger">
            Tài khoản này chưa được HR gắn làm Trưởng phòng của bất kỳ phòng ban nào.
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
        <h1>Hồ Sơ & Lộ Trình Cá Nhân: <%= myProfile != null ? myProfile.getFullName() : currentUser.getFullName() %></h1>
    </div>

    <div class="content-body">
        <div style="display: flex; gap: 15px;">
            <!-- Thông tin hiện tại -->
            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Thông Tin Công Việc Hiện Tại</h2>
                </div>
                <div class="card-body">
                    <p style="margin-bottom: 8px;"><b>Họ và tên:</b> <%= myProfile.getFullName() %></p>
                    <p style="margin-bottom: 8px;"><b>Username:</b> <%= myProfile.getUsername() %></p>
                    <p style="margin-bottom: 8px;"><b>Email:</b> <%= myProfile.getEmail() %></p>
                    <p style="margin-bottom: 8px;"><b>Số điện thoại:</b> <%= myProfile.getPhone() != null ? myProfile.getPhone() : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Ngày vào công ty:</b> <%= myProfile.getHireDate() != null ? sdfDate.format(myProfile.getHireDate()) : "-" %></p>
                    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ccc;">
                    <p style="margin-bottom: 8px;"><b>Phòng ban:</b> <%= myProfile.getDepartmentName() != null ? myProfile.getDepartmentName() : "Chưa xếp phòng" %></p>
                    <p style="margin-bottom: 8px;"><b>Vị trí chuyên môn:</b> <%= myProfile.getPositionName() != null ? myProfile.getPositionName() : "Chưa xếp vị trí" %></p>
                    <p style="margin-bottom: 8px;"><b>Cấp bậc:</b> <%= myProfile.getLevelName() != null ? myProfile.getLevelName() : "Chưa xếp cấp bậc" %></p>
                </div>
            </div>

            <!-- Lịch sử nghề nghiệp của bạn -->
            <div class="card" style="flex: 2;">
                <div class="card-header">
                    <h2>Lịch Sử Biến Động & Phát Triển Nghề Nghiệp Của Bạn</h2>
                </div>
                <div class="card-body">
                    <% if (myHistory != null && !myHistory.isEmpty()) { %>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Thời Gian</th>
                                <th>Loại Thay Đổi</th>
                                <th>Nội Dung Thay Đổi</th>
                                <th>Ghi Chú</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (EmployeeHistory h : myHistory) {
                                    String typeLabel = "Luân chuyển phòng ban";
                                    if ("NEW_HIRE".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Tuyển dụng mới";
                                    } else if ("ROLE_CHANGE".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Chuyển đổi chuyên môn/vị trí";
                                    } else if ("PROMOTION".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Thăng cấp bậc";
                                    }
                            %>
                            <tr>
                                <td><%= h.getChangeDate() != null ? sdf.format(h.getChangeDate()) : "" %></td>
                                <td><b><%= typeLabel %></b></td>
                                <td>
                                    <% if (h.getNewPositionName() != null) { %>
                                    Vị trí: <%= h.getOldPositionName() != null ? h.getOldPositionName() : "(Chưa có)" %> -> <b><%= h.getNewPositionName() %></b> <%= h.getNewLevelName() != null ? "(" + h.getNewLevelName() + ")" : "" %><br>
                                    <% } %>
                                    <% if (h.getNewDepartmentName() != null) { %>
                                    Phòng ban: <%= h.getOldDepartmentName() != null ? h.getOldDepartmentName() : "(Chưa có)" %> -> <b><%= h.getNewDepartmentName() %></b>
                                    <% } %>
                                </td>
                                <td><%= h.getNotes() != null ? h.getNotes() : "-" %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div style="text-align: center; padding: 20px; color: #7f8c8d;">
                        Chưa có ghi nhận biến động lịch sử chức vụ nào cho bạn.
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</main>

<jsp:include page="/views/common/footer.jsp" />
