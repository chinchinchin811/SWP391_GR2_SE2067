<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="model.EmployeeHistory" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    User emp = (User) request.getAttribute("employee");
    request.setAttribute("pageTitle", "Hồ sơ: " + emp.getFullName() + " | HRM");
    List<EmployeeHistory> historyList = (List<EmployeeHistory>) request.getAttribute("historyList");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Hồ Sơ Nhân Viên: <%= emp.getFullName() %></h1>
        <div style="display: flex; gap: 6px;">
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/employees?action=assign&id=<%= emp.getUserId() %>" class="btn btn-primary">
                    Điều chuyển / Thăng chức
                </a>
                <a href="<%= request.getContextPath() %>/employees?action=edit&id=<%= emp.getUserId() %>" class="btn btn-secondary">
                    Sửa thông tin
                </a>
                <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                    Danh sách
                </a>
            <% } else if (roleId == 3) { %>
                <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                    Quay lại danh sách
                </a>
            <% } %>
        </div>
    </div>

    <div class="content-body">
        <div style="display: flex; gap: 15px;">
            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Thông Tin Cá Nhân</h2>
                </div>
                <div class="card-body">
                    <p style="margin-bottom: 8px;"><b>Họ và tên:</b> <%= emp.getFullName() %></p>
                    <p style="margin-bottom: 8px;"><b>Username:</b> <%= emp.getUsername() %></p>
                    <p style="margin-bottom: 8px;"><b>Vai trò:</b> <span class="badge"><%= emp.getRoleName() %></span></p>
                    <p style="margin-bottom: 8px;"><b>Trạng thái:</b> 
                        <% if (emp.isStatus()) { %>
                            <span class="badge">Đang làm việc</span>
                        <% } else { %>
                            <span class="badge">Đã nghỉ việc</span>
                        <% } %>
                    </p>
                    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ccc;">
                    <p style="margin-bottom: 8px;"><b>Email:</b> <%= emp.getEmail() %></p>
                    <p style="margin-bottom: 8px;"><b>SĐT:</b> <%= emp.getPhone() != null ? emp.getPhone() : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Giới tính:</b> <%= emp.getGender() != null ? emp.getGender() : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Ngày sinh:</b> <%= emp.getDob() != null ? sdfDate.format(emp.getDob()) : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Ngày vào công ty:</b> <%= emp.getHireDate() != null ? sdfDate.format(emp.getHireDate()) : "-" %></p>
                    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ccc;">
                    <p style="margin-bottom: 8px;"><b>Phòng ban:</b> <%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chưa xếp" %></p>
                    <p style="margin-bottom: 8px;"><b>Vị trí chuyên môn:</b> <%= emp.getPositionName() != null ? emp.getPositionName() : "Chưa xếp" %></p>
                    <p style="margin-bottom: 8px;"><b>Cấp bậc:</b> <%= emp.getLevelName() != null ? emp.getLevelName() : "Chưa xếp" %></p>
                </div>
            </div>

            <div class="card" style="flex: 2;">
                <div class="card-header">
                    <h2>Lịch Sử Biến Động Chức Vụ & Chuyên Môn</h2>
                </div>
                <div class="card-body">
                    <%
                        if (historyList != null && !historyList.isEmpty()) {
                    %>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Thời Gian</th>
                                <th>Loại Biến Động</th>
                                <th>Chi Tiết Thay Đổi</th>
                                <th>Ghi Chú / Người Thực Hiện</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (EmployeeHistory h : historyList) {
                                    String typeLabel = "Luân chuyển phòng ban";
                                    if ("NEW_HIRE".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Tuyển dụng mới";
                                    } else if ("ROLE_CHANGE".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Chuyển đổi vị trí/chuyên môn";
                                    } else if ("PROMOTION".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Thăng cấp bậc";
                                    }
                            %>
                            <tr>
                                <td><%= h.getChangeDate() != null ? sdf.format(h.getChangeDate()) : "" %></td>
                                <td><b><%= typeLabel %></b></td>
                                <td>
                                    <% if (h.getNewPositionName() != null) { %>
                                        <div>Vị trí: <%= h.getOldPositionName() != null ? h.getOldPositionName() : "(Chưa có)" %> -> <b><%= h.getNewPositionName() %></b> <%= h.getNewLevelName() != null ? "(" + h.getNewLevelName() + ")" : "" %></div>
                                    <% } %>
                                    <% if (h.getNewDepartmentName() != null) { %>
                                        <div style="font-size: 11px; color: #555555;">Phòng ban: <%= h.getOldDepartmentName() != null ? h.getOldDepartmentName() : "(Chưa có)" %> -> <b><%= h.getNewDepartmentName() %></b></div>
                                    <% } %>
                                </td>
                                <td>
                                    <div><%= h.getNotes() != null ? h.getNotes() : "-" %></div>
                                    <% if (h.getCreatorName() != null) { %>
                                        <div style="font-size: 11px; color: #777777;">Người thực hiện: <%= h.getCreatorName() %></div>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                        <div style="text-align: center; padding: 20px; color: #555555;">
                            Chưa có dữ liệu biến động lịch sử cho nhân viên này.
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
