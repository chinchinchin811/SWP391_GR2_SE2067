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
    request.setAttribute("pageTitle", (isEdit ? "Cap Nhat Nhan Su" : "Khai Bao Nhan Su Moi") + " | HRM");

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
    List<Role> roles = (List<Role>) request.getAttribute("roles");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cap Nhat Ho So Nhan Vien" : "Khai Bao Nhan Vien Moi" %></h1>
        <div>
            <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                Quay lai danh sach
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="card" style="max-width: 750px; margin: 0 auto;">
            <div class="card-header">
                <h2><%= isEdit ? "Thong Tin Nhan Vien" : "Khai Bao Thong Tin & Xep Phong Ban/Vi Tri" %></h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/employees" method="POST">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="userId" value="<%= emp.getUserId() %>">
                    <% } %>

                    <div style="font-weight: bold; margin-bottom: 10px; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 5px;">
                        1. Thong tin tai khoan & Ca nhan
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Ten dang nhap (Username) (*):</label>
                            <input type="text" id="username" name="username" class="form-control" 
                                   value="<%= emp != null && emp.getUsername() != null ? emp.getUsername() : "" %>" 
                                   <%= isEdit ? "readonly style='background: #f1f2f6;'" : "required" %>>
                        </div>

                        <% if (!isEdit) { %>
                        <div class="form-group">
                            <label for="password">Mat khau khoi tao:</label>
                            <input type="password" id="password" name="password" class="form-control" 
                                   placeholder="Mac dinh: 123">
                        </div>
                        <% } %>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">Ho va Ten (*):</label>
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
                            <label for="phone">So dien thoai:</label>
                            <input type="text" id="phone" name="phone" class="form-control" 
                                   value="<%= emp != null && emp.getPhone() != null ? emp.getPhone() : "" %>">
                        </div>

                        <div class="form-group">
                            <label for="gender">Gioi tinh:</label>
                            <select id="gender" name="gender" class="form-control">
                                <option value="Nam" <%= (emp != null && "Nam".equalsIgnoreCase(emp.getGender())) ? "selected" : "" %>>Nam</option>
                                <option value="Nữ" <%= (emp != null && "Nữ".equalsIgnoreCase(emp.getGender())) ? "selected" : "" %>>Nu</option>
                                <option value="Khác" <%= (emp != null && "Khác".equalsIgnoreCase(emp.getGender())) ? "selected" : "" %>>Khac</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="dob">Ngay sinh:</label>
                            <input type="date" id="dob" name="dob" class="form-control" 
                                   value="<%= emp != null && emp.getDob() != null ? emp.getDob().toString() : "" %>">
                        </div>
                    </div>

                    <div style="font-weight: bold; margin: 15px 0 10px; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 5px;">
                        2. Phan quyen & To chuc
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="roleId">Vai tro (*):</label>
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

                        <div class="form-group">
                            <label for="status">Trang thai:</label>
                            <select id="status" name="status" class="form-control">
                                <option value="1" <%= (emp == null || emp.isStatus()) ? "selected" : "" %>>Dang lam viec</option>
                                <option value="0" <%= (emp != null && !emp.isStatus()) ? "selected" : "" %>>Da nghi viec</option>
                            </select>
                        </div>
                    </div>

                    <% if (!isEdit) { %>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="departmentId">Phong ban:</label>
                            <select id="departmentId" name="departmentId" class="form-control">
                                <option value="0">-- Chua xep phong ban --</option>
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
                            <label for="positionId">Vi tri chuyen mon:</label>
                            <select id="positionId" name="positionId" class="form-control">
                                <option value="0">-- Chua xep vi tri --</option>
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
                            <label for="levelId">Cap bac khoi diem:</label>
                            <select id="levelId" name="levelId" class="form-control">
                                <option value="0">-- Chua chon cap bac --</option>
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
                        <label for="hireDate">Ngay bat dau lam viec:</label>
                        <input type="date" id="hireDate" name="hireDate" class="form-control">
                    </div>
                    <% } %>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">Huy</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Luu Thay Doi" : "Them Nhan Vien" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
