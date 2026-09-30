<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.Role" %>
<%@ page import="model.User" %>
<%
    User emp = (User) request.getAttribute("employee");
    boolean isEdit = (emp != null && emp.getUserId() > 0);
    request.setAttribute("pageTitle", (isEdit ? "Cập Nhật Nhân Sự" : "Khai Báo Nhân Sự Mới") + " | HRM");

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
    List<Role> roles = (List<Role>) request.getAttribute("roles");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cập Nhật Hồ Sơ Nhân Viên" : "Khai Báo Nhân Viên Mới" %></h1>
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

        <div class="card" style="max-width: 750px; margin: 0 auto;">
            <div class="card-header">
                <h2><%= isEdit ? "Thông Tin Nhân Viên" : "Khai Báo Thông Tin & Xếp Phòng Ban / Vị Trí" %></h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/employees" method="POST">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="userId" value="<%= emp.getUserId() %>">
                    <% } %>

                    <div style="font-weight: bold; margin-bottom: 10px; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 5px;">
                        1. Thông tin tài khoản & Cá nhân
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Tên đăng nhập (Username) (*):</label>
                            <input type="text" id="username" name="username" class="form-control" 
                                   value="<%= emp != null && emp.getUsername() != null ? emp.getUsername() : "" %>" 
                                   <%= isEdit ? "readonly style='background: #f1f2f6;'" : "required" %>>
                        </div>

                        <% if (!isEdit) { %>
                        <div class="form-group">
                            <label for="password">Mật khẩu khởi tạo:</label>
                            <input type="password" id="password" name="password" class="form-control" 
                                   placeholder="Mặc định: 123">
                        </div>
                        <% } %>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">Họ và Tên (*):</label>
                            <input type="text" id="fullName" name="fullName" class="form-control" 
                                   value="<%= emp != null && emp.getFullName() != null ? emp.getFullName() : "" %>" required>
                        </div>

                        <div class="form-group">
                            <label for="email">Email (*):</label>
                            <input type="email" id="email" name="email" class="form-control" 
                                   value="<%= emp != null && emp.getEmail() != null ? emp.getEmail() : "" %>" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Số điện thoại:</label>
                            <input type="text" id="phone" name="phone" class="form-control" 
                                   value="<%= emp != null && emp.getPhone() != null ? emp.getPhone() : "" %>">
                        </div>

                        <div class="form-group">
                            <label for="gender">Giới tính:</label>
                            <select id="gender" name="gender" class="form-control">
                                <option value="Nam" <%= (emp != null && "Nam".equalsIgnoreCase(emp.getGender())) ? "selected" : "" %>>Nam</option>
                                <option value="Nữ" <%= (emp != null && ("Nữ".equalsIgnoreCase(emp.getGender()) || "Nu".equalsIgnoreCase(emp.getGender()))) ? "selected" : "" %>>Nữ</option>
                                <option value="Khác" <%= (emp != null && ("Khác".equalsIgnoreCase(emp.getGender()) || "Khac".equalsIgnoreCase(emp.getGender()))) ? "selected" : "" %>>Khác</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="dob">Ngày sinh:</label>
                            <input type="date" id="dob" name="dob" class="form-control" 
                                   value="<%= emp != null && emp.getDob() != null ? emp.getDob().toString() : "" %>">
                        </div>
                    </div>

                    <div style="font-weight: bold; margin: 15px 0 10px; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 5px;">
                        2. Phân quyền & Tổ chức
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="<%= !isEdit ? "flex: 1;" : "" %>">
                            <label for="roleId">Vai trò (*):</label>
                            <select id="roleId" name="roleId" class="form-control" required>
                                <%
                                    if (roles != null) {
                                        for (Role r : roles) {
                                            boolean isSel = (emp != null && emp.getRoleId() == r.getRoleId()) || (emp == null && r.getRoleId() == 4);
                                %>
                                    <option value="<%= r.getRoleId() %>" <%= isSel ? "selected" : "" %>><%= r.getRoleName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <% if (isEdit) { %>
                        <div class="form-group">
                            <label for="status">Trạng thái:</label>
                            <select id="status" name="status" class="form-control">
                                <option value="1" <%= (emp == null || emp.isStatus()) ? "selected" : "" %>>Đang làm việc</option>
                                <option value="0" <%= (emp != null && !emp.isStatus()) ? "selected" : "" %>>Đã nghỉ việc</option>
                            </select>
                        </div>
                        <% } %>
                    </div>

                    <% if (!isEdit) { %>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="departmentId">Phòng ban:</label>
                            <select id="departmentId" name="departmentId" class="form-control">
                                <option value="0">-- Chưa xếp phòng ban --</option>
                                <%
                                    if (departments != null) {
                                        for (Department d : departments) {
                                %>
                                    <option value="<%= d.getDepartmentId() %>"><%= d.getDepartmentName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="positionId">Vị trí chuyên môn:</label>
                            <select id="positionId" name="positionId" class="form-control">
                                <option value="0">-- Chưa xếp vị trí --</option>
                                <%
                                    if (positions != null) {
                                        for (Position p : positions) {
                                %>
                                    <option value="<%= p.getPositionId() %>"><%= p.getPositionName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="levelId">Cấp bậc khởi điểm:</label>
                            <select id="levelId" name="levelId" class="form-control">
                                <option value="0">-- Chưa chọn cấp bậc --</option>
                                <%
                                    if (jobLevels != null) {
                                        for (JobLevel lvl : jobLevels) {
                                %>
                                    <option value="<%= lvl.getLevelId() %>"><%= lvl.getLevelName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="hireDate">Ngày bắt đầu làm việc:</label>
                        <input type="date" id="hireDate" name="hireDate" class="form-control">
                    </div>
                    <% } %>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Lưu Thay Đổi" : "Thêm Nhân Viên" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
