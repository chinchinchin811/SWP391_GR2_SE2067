<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User emp = (User) request.getAttribute("employee");
    request.setAttribute("pageTitle", "Điều chuyển vị trí | HRM");

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
                Quay lại danh sách
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="card" style="max-width: 700px; margin: 0 auto;">
            <div class="card-header">
                <h2>Điều Chuyển Phòng Ban / Đổi Chuyên Môn / Thăng Chức</h2>
            </div>
            <div class="card-body">
                <!-- Thông tin hiện tại -->
                <div style="background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 12px; margin-bottom: 20px; font-size: 13px;">
                    <div><b>Nhân viên:</b> <%= emp.getFullName() %> (Username: <%= emp.getUsername() %>)</div>
                    <div style="margin-top: 5px;">
                        Phòng ban hiện tại: <b><%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chưa có" %></b> | 
                        Vị trí hiện tại: <b><%= emp.getPositionName() != null ? emp.getPositionName() : "Chưa có" %></b> | 
                        Cấp bậc: <b><%= emp.getLevelName() != null ? emp.getLevelName() : "Chưa có" %></b>
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
                            <select id="departmentId" name="departmentId" class="form-control" onchange="filterAssignPositions(false)">
                                <option value="0" <%= (emp.getDepartmentId() == null || emp.getDepartmentId() == 0) ? "selected" : "" %>>-- Giữ nguyên hoặc Chưa phân --</option>
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
                                <option value="0" data-dept="0">-- Giữ nguyên hoặc Chưa phân --</option>
                                <%
                                    if (positions != null) {
                                        for (Position p : positions) {
                                            int pDeptId = (p.getDepartmentId() != null) ? p.getDepartmentId() : 0;
                                            boolean isSel = (emp.getPositionId() != null && emp.getPositionId().equals(p.getPositionId()));
                                %>
                                    <option value="<%= p.getPositionId() %>" 
                                            data-dept="<%= pDeptId %>" 
                                            <%= isSel ? "selected" : "" %>>
                                        <%= p.getPositionName() %>
                                    </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <small style="color: #7f8c8d; font-size: 12px; display: block; margin-top: 3px;">
                                Vị trí tự động lọc theo Phòng ban mới được chọn.
                            </small>
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

<script>
    function filterAssignPositions(preserveSelection) {
        var deptSelect = document.getElementById("departmentId");
        var posSelect = document.getElementById("positionId");
        if (!deptSelect || !posSelect) return;

        var selectedDept = deptSelect.value;
        var currentPos = posSelect.value;
        var hasMatching = false;

        for (var i = 0; i < posSelect.options.length; i++) {
            var opt = posSelect.options[i];
            var optDept = opt.getAttribute("data-dept");

            if (opt.value === "0") {
                opt.style.display = "";
                opt.hidden = false;
            } else if (selectedDept === "0" || selectedDept === "") {
                opt.style.display = "";
                opt.hidden = false;
            } else if (optDept === selectedDept || optDept === "0") {
                opt.style.display = "";
                opt.hidden = false;
                if (opt.value === currentPos) {
                    hasMatching = true;
                }
            } else {
                opt.style.display = "none";
                opt.hidden = true;
            }
        }

        if (!hasMatching && !preserveSelection && selectedDept !== "0") {
            posSelect.value = "0";
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        filterAssignPositions(true);
    });
</script>

<jsp:include page="/views/common/footer.jsp" />
