<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.text.SimpleDateFormat,model.*" %>
<%
    TrainingClass trainingClass = (TrainingClass) request.getAttribute("trainingClass");
    List<ClassEnrollment> enrollments = (List<ClassEnrollment>) request.getAttribute("enrollments");
    List<LearningMaterial> availableMaterials = (List<LearningMaterial>) request.getAttribute("availableMaterials");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
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
            <% if (canManage && trainingClass != null) { %>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=classAssign&id=<%= trainingClass.getClassId() %>">+ Thêm học viên</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
        <% } %>

        <% if (trainingClass != null) { %>
        <!-- Thông tin lớp -->
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

        <!-- Học liệu theo lộ trình -->
        <div class="card">
            <div class="card-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px">
                <div style="display:flex;align-items:center;gap:12px">
                    <h2>Học Liệu Theo Lộ Trình</h2>
                    <span class="badge-count">Tổng: <%= (trainingClass.getMaterials() != null ? trainingClass.getMaterials().size() : 0) %> học liệu</span>
                </div>
                <% if (canManage && availableMaterials != null && !availableMaterials.isEmpty()) { %>
                <form method="post" action="<%= request.getContextPath() %>/materials" style="display:flex;gap:8px;align-items:center;margin:0">
                    <input type="hidden" name="action" value="addClassMaterial">
                    <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                    <select name="materialId" class="form-control" style="font-size:12px;padding:5px 8px;max-width:300px" required>
                        <option value="">— Chọn học liệu thêm vào lớp —</option>
                        <% for (LearningMaterial am : availableMaterials) {
                            boolean alreadyInClass = false;
                            if (trainingClass.getMaterials() != null) {
                                for (LearningMaterial em : trainingClass.getMaterials()) {
                                    if (em.getMaterialId() == am.getMaterialId()) {
                                        alreadyInClass = true;
                                        break;
                                    }
                                }
                            }
                            if (!alreadyInClass) { %>
                        <option value="<%= am.getMaterialId() %>"><%= am.getTitle() %> (<%= am.getMaterialType() %>)</option>
                        <%  }
                        } %>
                    </select>
                    <button type="submit" class="btn btn-sm btn-primary">+ Thêm học liệu</button>
                </form>
                <% } %>
            </div>
            <div class="card-body" style="padding:0">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width:6%;text-align:center">STT</th>
                            <th style="text-align:left">Học liệu</th>
                            <th style="width:14%;text-align:center">Định dạng</th>
                            <th style="width:14%;text-align:center">Thời lượng</th>
                            <th style="width:20%;text-align:center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (trainingClass.getMaterials() != null && !trainingClass.getMaterials().isEmpty()) {
                            int mIdx = 1;
                            for (LearningMaterial m : trainingClass.getMaterials()) { %>
                        <tr>
                            <td style="text-align:center;font-weight:600;color:#555"><%= mIdx++ %></td>
                            <td style="text-align:left">
                                <a href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>&classId=<%= trainingClass.getClassId() %>"
                                   style="font-weight:600;color:#000;text-decoration:none">
                                   <%= m.getTitle() %>
                                </a>
                                <% if (m.getDescription() != null && !m.getDescription().trim().isEmpty()) { %>
                                <div style="font-size:12px;color:#666;margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:480px">
                                    <%= m.getDescription() %>
                                </div>
                                <% } %>
                            </td>
                            <td style="text-align:center">
                                <span class="badge" style="font-size:11px"><%= m.getMaterialType() %></span>
                            </td>
                            <td style="text-align:center;font-size:12.5px;color:#444">
                                <%= m.getDurationMinutes() > 0 ? (m.getDurationMinutes() + " phút") : "—" %>
                            </td>
                            <td style="text-align:center">
                                <a class="btn btn-sm btn-primary" href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>&classId=<%= trainingClass.getClassId() %>" style="margin-right:4px">
                                    Vào học
                                </a>
                                <% if (canManage) { %>
                                <form method="post" action="<%= request.getContextPath() %>/materials" style="display:inline" onsubmit="return confirm('Bạn có chắc muốn gỡ học liệu này khỏi lớp đào tạo?')">
                                    <input type="hidden" name="action" value="removeClassMaterial">
                                    <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                                    <input type="hidden" name="materialId" value="<%= m.getMaterialId() %>">
                                    <button type="submit" class="btn btn-sm btn-danger">Gỡ bỏ</button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="5" style="text-align:center;padding:24px;color:#666;font-size:13px">
                                Lớp chưa có học liệu.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Danh sách học viên -->
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
        <% } %>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
