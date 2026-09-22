<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User emp = (User) request.getAttribute("employee");
    request.setAttribute("pageTitle", "Dieu chuyen vi tri | HRM");

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Điều Chuyển Vị Trí & Thăng Cấp</h1>
        <div>
            <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                Quay lại danh sach
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="card" style="max-width: 700px; margin: 0 auto;">
            <div class="card-header">
                <h2>Điều Chuyển Phòng Ban / ĐỔi Chuyên Môn / Thăng Chức</h2>
            </div>
            <div class="card-body">
                <!-- Thong tin hien tai -->
                <div style="background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 12px; margin-bottom: 20px; font-size: 13px;">
                    <div><b>Nhan vien:</b> <%= emp.getFullName() %> (Username: <%= emp.getUsername() %>)</div>
                    <div style="margin-top: 5px;">
                        Phòng ban hiện tại: <b><%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chua co" %></b> | 
                        Vị trí hiện tại: <b><%= emp.getPositionName() != null ? emp.getPositionName() : "Chua co" %></b> | 
                        Cấp bậc: <b><%= emp.getLevelName() != null ? emp.getLevelName() : "Chua co" %></b>
                    </div>
                </div>

                <form action="<%= request.getContextPath() %>/employees" method="POST">
                    <input type="hidden" name="action" value="assign">
                    <input type="hidden" name="userId" value="<%= emp.getUserId() %>">

                    <div class="form-group">
                        <label for="changeType">Loại thay đổi (*):</label>
                        <select id="changeType" name="changeType" class="form-control" required>
                            <option value="ROLE_CHANGE">Chuyển đổi chuyên môn/vị trí mới (Cần ghép Mentor chuyên môn)</option>
                            <option value="PROMOTION">Thăng cấp bậc / Lên chức (Promotion)</option>
                            <option value="DEPARTMENT_TRANSFER">Luân chuyển phòng ban</option>
                        </select>
                        <small style="color: #7f8c8d; display: block; margin-top: 3px;">
                            Hệ thống sẽ tự động ghi nhận lịch sử để xác định cần ghép Mentor và làm bài thi đánh giá năng lực.
                        </small>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="departmentId">Phòng ban mới:</label>
                            <select id="departmentId" name="departmentId" class="form-control">
                                <option value="0">-- Giữ nguyên hoặc Chưa phân --</option>
                                <%
                                    if (departments != null) {
                                        for (Department d : departments) {
                                            boolean isSel = (emp.getDepartmentId() != null && emp.getDepartmentId().equals(d.getDepartmentId()));
                                %>
                                    <option value="<%= d.getDepartmentId() %>" <%= isSel ? "selected" : "" %>><%= d.getDepartmentName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="positionId">Vị trí chuyên môn mới:</label>
                            <select id="positionId" name="positionId" class="form-control">
                                <option value="0">-- Giữ nguyên hoặc Chưa phân --</option>
                                <%
                                    if (positions != null) {
                                        for (Position p : positions) {
                                            boolean isSel = (emp.getPositionId() != null && emp.getPositionId().equals(p.getPositionId()));
                                %>
                                    <option value="<%= p.getPositionId() %>" <%= isSel ? "selected" : "" %>><%= p.getPositionName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="levelId">Cấp bậc mới:</label>
                            <select id="levelId" name="levelId" class="form-control">
                                <option value="0">-- Giữ nguyên hoặc Chưa phân --</option>
                                <%
                                    if (jobLevels != null) {
                                        for (JobLevel lvl : jobLevels) {
                                            boolean isSel = (emp.getLevelId() != null && emp.getLevelId().equals(lvl.getLevelId()));
                                %>
                                    <option value="<%= lvl.getLevelId() %>" <%= isSel ? "selected" : "" %>><%= lvl.getLevelName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="notes">Lý do / Ghi chú quyết định:</label>
                        <textarea id="notes" name="notes" class="form-control" rows="3" 
                                  placeholder="Ghi chú lý do thuyên chuyển hoặc thăng chức..."></textarea>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-primary">
                            Xác Nhận Điều Chuyển & Lưu Lịch Sử
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
