<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.text.SimpleDateFormat,model.TrainingClass,model.User" %>
<%
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("classes");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    request.setAttribute("pageTitle", "Quản lý lớp đào tạo | HRM");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Quản Lý Lớp Đào Tạo</h1>
        <div class="topbar-actions">
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Kho học liệu</a>
            <% if (canManage) { %>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=classCreate">+ Mở lớp mới</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <div class="card">
            <div class="card-header">
                <h2>Danh Sách Lớp Đào Tạo</h2>
                <span class="badge-count">Tổng: <%= classes != null ? classes.size() : 0 %> lớp</span>
            </div>
            <div class="card-body" style="padding:0">
                <table class="data-table">
                    <colgroup>
                        <col style="width:16%">
                        <col style="width:26%">
                        <col style="width:17%">
                        <col style="width:12%">
                        <col style="width:8%">
                        <col style="width:10%">
                        <col style="width:11%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th style="text-align:center">Mã lớp</th>
                            <th style="text-align:center">Tên lớp</th>
                            <th style="text-align:center">Mentor</th>
                            <th style="text-align:center">Ngày bắt đầu</th>
                            <th style="text-align:center">Học viên</th>
                            <th style="text-align:center">Trạng thái</th>
                            <th style="text-align:center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (classes != null && !classes.isEmpty()) {
                            for (TrainingClass c : classes) { %>
                        <tr>
                            <td style="text-align:center;font-size:12px"><%= c.getClassCode() %></td>
                            <td style="text-align:center;font-weight:600;font-size:13px;line-height:1.4"><%= c.getClassName() %></td>
                            <td style="text-align:center;font-size:12.5px">
                                <%= c.getMentorName() != null ? c.getMentorName() : "<em style='color:#888'>Chưa phân công</em>" %>
                            </td>
                            <td style="text-align:center;font-size:12.5px;white-space:nowrap">
                                <%= c.getStartDate() != null ? sdf.format(c.getStartDate()) : "—" %>
                            </td>
                            <td style="text-align:center;font-weight:700;font-size:14px"><%= c.getEnrollmentCount() %></td>
                            <td style="text-align:center"><span class="badge"><%= c.getStatus() %></span></td>
                            <td style="text-align:center">
                                <div class="action-btn-group">
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= c.getClassId() %>">Chi tiết</a>
                                    <% if (canManage) { %>
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=classAssign&id=<%= c.getClassId() %>">Gán nhân sự</a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="7" style="text-align:center;padding:28px;color:#666;font-size:13px">
                                Chưa có lớp đào tạo nào.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
