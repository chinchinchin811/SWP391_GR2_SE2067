<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="model.EmployeeHistory" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    User emp = (User) request.getAttribute("employee");
    request.setAttribute("pageTitle", "Ho so: " + emp.getFullName() + " | HRM");
    List<EmployeeHistory> historyList = (List<EmployeeHistory>) request.getAttribute("historyList");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Ho So Nhan Vien: <%= emp.getFullName() %></h1>
        <div style="display: flex; gap: 6px;">
            <% if (roleId == 1 || roleId == 2) { %>
                <a href="<%= request.getContextPath() %>/employees?action=assign&id=<%= emp.getUserId() %>" class="btn btn-primary">
                    Dieu chuyen / Thang chuc
                </a>
                <a href="<%= request.getContextPath() %>/employees?action=edit&id=<%= emp.getUserId() %>" class="btn btn-secondary">
                    Sua thong tin
                </a>
                <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                    Danh sach
                </a>
            <% } else if (roleId == 3) { %>
                <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                    Quay lai danh sach
                </a>
            <% } %>
        </div>
    </div>

    <div class="content-body">
        <div style="display: flex; gap: 15px;">
            <div class="card" style="flex: 1;">
                <div class="card-header">
                    <h2>Thong Tin Ca Nhan</h2>
                </div>
                <div class="card-body">
                    <p style="margin-bottom: 8px;"><b>Ho va ten:</b> <%= emp.getFullName() %></p>
                    <p style="margin-bottom: 8px;"><b>Username:</b> <%= emp.getUsername() %></p>
                    <p style="margin-bottom: 8px;"><b>Vai tro:</b> <span class="badge"><%= emp.getRoleName() %></span></p>
                    <p style="margin-bottom: 8px;"><b>Trang thai:</b> 
                        <% if (emp.isStatus()) { %>
                            <span class="badge">Dang lam viec</span>
                        <% } else { %>
                            <span class="badge">Da nghi viec</span>
                        <% } %>
                    </p>
                    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ccc;">
                    <p style="margin-bottom: 8px;"><b>Email:</b> <%= emp.getEmail() %></p>
                    <p style="margin-bottom: 8px;"><b>SDT:</b> <%= emp.getPhone() != null ? emp.getPhone() : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Gioi tinh:</b> <%= emp.getGender() != null ? emp.getGender() : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Ngay sinh:</b> <%= emp.getDob() != null ? sdfDate.format(emp.getDob()) : "-" %></p>
                    <p style="margin-bottom: 8px;"><b>Ngay vao cong ty:</b> <%= emp.getHireDate() != null ? sdfDate.format(emp.getHireDate()) : "-" %></p>
                    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ccc;">
                    <p style="margin-bottom: 8px;"><b>Phong ban:</b> <%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chua xep" %></p>
                    <p style="margin-bottom: 8px;"><b>Vi tri chuyen mon:</b> <%= emp.getPositionName() != null ? emp.getPositionName() : "Chua xep" %></p>
                    <p style="margin-bottom: 8px;"><b>Cap bac:</b> <%= emp.getLevelName() != null ? emp.getLevelName() : "Chua xep" %></p>
                </div>
            </div>

            <div class="card" style="flex: 2;">
                <div class="card-header">
                    <h2>Lich Su Bien Dong Chuc Vu & Chuyen Mon</h2>
                </div>
                <div class="card-body">
                    <%
                        if (historyList != null && !historyList.isEmpty()) {
                    %>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Thoi Gian</th>
                                <th>Loai Bien Dong</th>
                                <th>Chi Tiet Thay Doi</th>
                                <th>Ghi Chu / Nguoi Thuc Hien</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (EmployeeHistory h : historyList) {
                                    String typeLabel = "Luan chuyen phong ban";
                                    if ("NEW_HIRE".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Tuyen dung moi";
                                    } else if ("ROLE_CHANGE".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Chuyen doi vi tri/chuyen mon";
                                    } else if ("PROMOTION".equalsIgnoreCase(h.getChangeType())) {
                                        typeLabel = "Thang cap bac";
                                    }
                            %>
                            <tr>
                                <td><%= h.getChangeDate() != null ? sdf.format(h.getChangeDate()) : "" %></td>
                                <td><b><%= typeLabel %></b></td>
                                <td>
                                    <% if (h.getNewPositionName() != null) { %>
                                        <div>Vi tri: <%= h.getOldPositionName() != null ? h.getOldPositionName() : "(Chua co)" %> -> <b><%= h.getNewPositionName() %></b> <%= h.getNewLevelName() != null ? "(" + h.getNewLevelName() + ")" : "" %></div>
                                    <% } %>
                                    <% if (h.getNewDepartmentName() != null) { %>
                                        <div style="font-size: 11px; color: #555555;">Phong ban: <%= h.getOldDepartmentName() != null ? h.getOldDepartmentName() : "(Chua co)" %> -> <b><%= h.getNewDepartmentName() %></b></div>
                                    <% } %>
                                </td>
                                <td>
                                    <div><%= h.getNotes() != null ? h.getNotes() : "-" %></div>
                                    <% if (h.getCreatorName() != null) { %>
                                        <div style="font-size: 11px; color: #777777;">Nguoi thuc hien: <%= h.getCreatorName() %></div>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                        <div style="text-align: center; padding: 20px; color: #555555;">
                            Chua co du lieu bien dong lich su cho nhan vien nay.
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
