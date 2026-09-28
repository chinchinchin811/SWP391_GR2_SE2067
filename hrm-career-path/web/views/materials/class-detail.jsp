<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.text.SimpleDateFormat,model.*" %>
<%
    TrainingClass trainingClass = (TrainingClass) request.getAttribute("trainingClass");
    List<ClassEnrollment> enrollments = (List<ClassEnrollment>) request.getAttribute("enrollments");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    String successMessage = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
    request.setAttribute("pageTitle", "Chi tiết lớp đào tạo | HRM");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Chi Tiết Lớp Đào Tạo</h1>
        <div class="topbar-actions">
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Quay lại danh sách</a>
            <% if (canManage) { %>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=classAssign&id=<%= trainingClass.getClassId() %>">+ Thêm học viên</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <!-- Thong tin lop -->
        <div class="card">
            <div class="card-header">
                <h2><%= trainingClass.getClassName() %></h2>
                <span class="badge"><%= trainingClass.getStatus() %></span>
            </div>
            <div class="card-body">
                <table style="width:100%;border-collapse:collapse;font-size:13px;line-height:1.8">
                    <colgroup><col style="width:130px"><col><col style="width:130px"><col></colgroup>
                    <tr>
                        <td style="color:#555;font-weight:600;vertical-align:top">Mã lớp:</td>
                        <td style="vertical-align:top"><%= trainingClass.getClassCode() %></td>
                        <td style="color:#555;font-weight:600;vertical-align:top">Mentor:</td>
                        <td style="vertical-align:top">
                            <%= trainingClass.getMentorName() != null ? trainingClass.getMentorName() : "<em style='color:#999'>Chưa phân công</em>" %>
                        </td>
                    </tr>
                    <tr>
                        <td style="color:#555;font-weight:600;vertical-align:top">Thời gian:</td>
                        <td style="vertical-align:top">
                            <%= trainingClass.getStartDate() != null ? sdf.format(trainingClass.getStartDate()) : "—" %>
                            &mdash;
                            <%= trainingClass.getEndDate() != null ? sdf.format(trainingClass.getEndDate()) : "<em style='color:#999'>Chưa xác định</em>" %>
                        </td>
                        <td style="color:#555;font-weight:600;vertical-align:top">Mô tả:</td>
                        <td style="vertical-align:top">
                            <%= trainingClass.getDescription() != null ? trainingClass.getDescription() : "—" %>
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <!-- Hoc lieu theo lo trinh -->
        <div class="card">
            <div class="card-header">
                <h2>Học Liệu Theo Lộ Trình</h2>
            </div>
            <div class="card-body">
                <% if (trainingClass.getMaterials() != null && !trainingClass.getMaterials().isEmpty()) { %>
                <ol style="margin:0;padding-left:22px">
                    <% for (LearningMaterial m : trainingClass.getMaterials()) { %>
                    <li style="margin-bottom:8px;font-size:13px;line-height:1.5">
                        <a href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>"
                           style="font-weight:600;color:#000;text-decoration:none">
                           <%= m.getTitle() %>
                        </a>
                        <span style="font-size:11.5px;color:#666;margin-left:6px">(<%= m.getMaterialType() %>)</span>
                    </li>
                    <% } %>
                </ol>
                <% } else { %>
                <p style="color:#666;font-size:13px;text-align:center;padding:12px 0">Lớp chưa có học liệu.</p>
                <% } %>
            </div>
        </div>

        <!-- Danh sach hoc vien -->
        <div class="card">
            <div class="card-header">
                <h2>Danh Sách Học Viên</h2>
                <span class="badge-count">Tổng: <%= enrollments != null ? enrollments.size() : 0 %> học viên</span>
            </div>
            <div class="card-body" style="padding:0">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width:30%;text-align:center">Học viên</th>
                            <th style="text-align:center">Thông tin ghi danh</th>
                            <% if (canManage) { %>
                            <th style="width:16%;text-align:center">Thao tác</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (enrollments != null && !enrollments.isEmpty()) {
                            for (ClassEnrollment e : enrollments) { %>
                        <tr>
                            <td style="text-align:center;font-size:13px;font-weight:600"><%= e.getUserName() %></td>
                            <td style="text-align:center;font-size:12.5px;color:#444">
                                <%= e.getAssignedReason() != null ? e.getAssignedReason() : "Ghi danh thủ công" %>
                            </td>
                            <% if (canManage) { %>
                            <td style="text-align:center">
                                <form method="post" action="<%= request.getContextPath() %>/materials"
                                      style="display:inline"
                                      onsubmit="return confirm('Xóa học viên khỏi lớp?')">
                                    <input type="hidden" name="action" value="deleteEnrollment">
                                    <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                                    <input type="hidden" name="enrollmentId" value="<%= e.getEnrollmentId() %>">
                                    <button class="btn btn-sm btn-danger">Xóa khỏi lớp</button>
                                </form>
                            </td>
                            <% } %>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="<%= canManage ? "3" : "2" %>"
                                style="text-align:center;padding:24px;color:#666;font-size:13px">
                                Chưa có học viên trong lớp.
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
