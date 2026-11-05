<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.Role" %>
<%@ page import="model.User" %>
<%
    User emp = (User) request.getAttribute("employee");
    boolean isEdit = (emp != null && emp.getUserId() > 0);
    User currentUser = (User) session.getAttribute("currentUser");
    int currentUserRole = (currentUser != null) ? currentUser.getRoleId() : 4;
    boolean isSelfEdit = (isEdit && currentUserRole == 4 && emp != null && emp.getUserId() == currentUser.getUserId());

    request.setAttribute("pageTitle", (isSelfEdit ? "Cập Nhật Thông Tin Cá Nhân" : (isEdit ? "Cập Nhật Nhân Sự" : "Khai Báo Nhân Sự Mới")) + " | CPMS");

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
    List<Role> roles = (List<Role>) request.getAttribute("roles");

    LocalDate maxDob = LocalDate.now().minusYears(18);
    LocalDate minDob = LocalDate.now().minusYears(100);
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><%= isSelfEdit ? "Cập Nhật Thông Tin Cá Nhân" : (isEdit ? "Cập Nhật Hồ Sơ Nhân Viên" : "Khai Báo Nhân Viên Mới") %></h1>
        <div>
            <% if (isSelfEdit) { %>
                <a href="<%= request.getContextPath() %>/employees?action=detail&id=<%= emp.getUserId() %>" class="btn btn-secondary">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại hồ sơ
                </a>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">
                    Quay lại danh sách
                </a>
            <% } %>
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
                <form action="<%= request.getContextPath() %>/employees" method="POST" onsubmit="return validateEmployeeForm()">
                    <input type="hidden" name="action" value="<%= isEdit ? "edit" : "create" %>">
                    <% if (isEdit) { %>
                    <input type="hidden" name="userId" value="<%= emp.getUserId() %>">
                    <% } %>

                    <div style="font-weight: bold; margin-bottom: 10px; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 5px;">
                        1. Thông tin tài khoản & Cá nhân
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Tên đăng nhập <span style="color:#dc2626;">*</span></label>
                            <input type="text" id="username" name="username" class="form-control" 
                                   data-field-name="Tên đăng nhập"
                                   value="<%= emp != null && emp.getUsername() != null ? emp.getUsername() : (request.getParameter("username") != null ? request.getParameter("username") : "") %>" 
                                   <%= isEdit ? "readonly style='background: #f1f2f6;'" : "required" %>>
                        </div>

                        <% if (!isEdit) { %>
                        <div class="form-group">
                            <label for="password">Mật khẩu khởi tạo</label>
                            <input type="password" id="password" name="password" class="form-control" 
                                   data-field-name="Mật khẩu khởi tạo"
                                   placeholder="Mặc định: 123">
                        </div>
                        <% } %>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">Họ và tên <span style="color:#dc2626;">*</span></label>
                            <input type="text" id="fullName" name="fullName" class="form-control" 
                                   data-field-name="Họ và tên"
                                   value="<%= emp != null && emp.getFullName() != null ? emp.getFullName() : (request.getParameter("fullName") != null ? request.getParameter("fullName") : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label for="email">Email <span style="color:#dc2626;">*</span></label>
                            <input type="email" id="email" name="email" class="form-control" 
                                   data-field-name="Email"
                                   value="<%= emp != null && emp.getEmail() != null ? emp.getEmail() : (request.getParameter("email") != null ? request.getParameter("email") : "") %>" 
                                   <%= isSelfEdit ? "readonly style='background: #f1f2f6; cursor: not-allowed;'" : "required" %>>
                            <% if (isSelfEdit) { %>
                                <small style="color: #64748b; font-size: 11px;"><i class="fa-solid fa-lock"></i> Email định danh nội bộ, bạn không thể tự thay đổi.</small>
                            <% } %>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Số điện thoại</label>
                            <input type="tel" id="phone" name="phone" class="form-control" 
                                   data-field-name="Số điện thoại"
                                   pattern="^(0|\+84)[0-9]{9}$"
                                   placeholder="Ví dụ: 0912345678"
                                   title="Số điện thoại gồm 10 chữ số bắt đầu bằng số 0 (hoặc +84)"
                                   value="<%= emp != null && emp.getPhone() != null ? emp.getPhone() : (request.getParameter("phone") != null ? request.getParameter("phone") : "") %>">
                        </div>

                        <div class="form-group">
                            <label for="gender">Giới tính</label>
                            <select id="gender" name="gender" class="form-control" data-field-name="Giới tính">
                                <option value="Nam" <%= (emp != null && "Nam".equalsIgnoreCase(emp.getGender())) ? "selected" : "" %>>Nam</option>
                                <option value="Nữ" <%= (emp != null && ("Nữ".equalsIgnoreCase(emp.getGender()) || "Nu".equalsIgnoreCase(emp.getGender()))) ? "selected" : "" %>>Nữ</option>
                                <option value="Khác" <%= (emp != null && ("Khác".equalsIgnoreCase(emp.getGender()) || "Khac".equalsIgnoreCase(emp.getGender()))) ? "selected" : "" %>>Khác</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="dob">Ngày sinh <span style="color:#dc2626;">*</span></label>
                            <div style="position:relative;">
                                <input type="text" id="dob" name="dob" class="form-control date-picker-dmy" 
                                       placeholder="dd/mm/yyyy" maxlength="10" autocomplete="off"
                                       data-field-name="Ngày sinh"
                                       value="<%= (request.getParameter("dob") != null ? request.getParameter("dob") : (emp != null && emp.getDob() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(emp.getDob()) : "")) %>" required>
                                <span class="dmy-calendar-btn" data-target="dob" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#6b7280;font-size:14px;" title="Chọn ngày sinh">
                                    <i class="fa-solid fa-calendar-days"></i>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div style="font-weight: bold; margin: 15px 0 10px; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 5px;">
                        <%= isSelfEdit ? "2. Thông tin phân bổ vị trí (Chỉ xem)" : "2. Phân quyền & Tổ chức" %>
                    </div>

                    <% if (isSelfEdit) { %>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Vai trò:</label>
                            <input type="hidden" name="roleId" value="<%= emp.getRoleId() %>">
                            <div style="padding: 9px 12px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 4px; font-weight: 600; color: #1e293b;">
                                <i class="fa-solid fa-id-card-clip" style="color: var(--primary);"></i> <%= emp.getRoleName() != null ? emp.getRoleName() : "EMPLOYEE" %>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Trạng thái:</label>
                            <input type="hidden" name="status" value="<%= emp.isStatus() ? "1" : "0" %>">
                            <div style="padding: 9px 12px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 4px; font-weight: 600; color: #16a34a;">
                                <i class="fa-solid fa-circle-check"></i> <%= emp.isStatus() ? "Đang làm việc" : "Đã nghỉ việc" %>
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Phòng ban hiện tại:</label>
                            <div style="padding: 9px 12px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 4px; color: #334155;">
                                <i class="fa-regular fa-building"></i> <%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chưa phân bổ" %>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Vị trí chuyên môn:</label>
                            <div style="padding: 9px 12px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 4px; color: #334155;">
                                <i class="fa-solid fa-briefcase"></i> <%= emp.getPositionName() != null ? emp.getPositionName() : "Chưa phân bổ" %>
                            </div>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="form-row">
                        <div class="form-group" style="<%= !isEdit ? "flex: 1;" : "" %>">
                            <label for="roleId">Vai trò <span style="color:#dc2626;">*</span></label>
                            <select id="roleId" name="roleId" class="form-control" data-field-name="Vai trò" required>
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
                    <% } %>

                    <% if (!isEdit) { %>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="departmentId" id="deptLabel">Phòng ban</label>
                            <select id="departmentId" name="departmentId" class="form-control" data-field-name="Phòng ban" onchange="onDepartmentChange()">
                                <option value="0" data-has-manager="false">-- Chưa xếp phòng ban --</option>
                                <%
                                    if (departments != null) {
                                        for (Department d : departments) {
                                            boolean hasMgr = (d.getManagerName() != null && !d.getManagerName().trim().isEmpty());
                                            String mgrInfo = hasMgr ? " (Đã có TP: " + d.getManagerName() + ")" : " (Chưa có TP)";
                                %>
                                <option value="<%= d.getDepartmentId() %>" 
                                        data-has-manager="<%= hasMgr %>" 
                                        data-manager-name="<%= hasMgr ? d.getManagerName() : "" %>"
                                        <%= (emp != null && emp.getDepartmentId() != null && emp.getDepartmentId().equals(d.getDepartmentId())) ? "selected" : "" %>>
                                    <%= d.getDepartmentName() %><%= mgrInfo %>
                                </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <small id="managerAlert" style="display: none; color: #e74c3c; font-weight: 500; margin-top: 4px;"></small>
                        </div>

                        <div class="form-group">
                            <label for="positionId">Vị trí chuyên môn</label>
                            <select id="positionId" name="positionId" class="form-control" data-field-name="Vị trí chuyên môn">
                                <option value="0" data-dept="0">-- Chọn vị trí chuyên môn --</option>
                                <%
                                    if (positions != null) {
                                        for (Position p : positions) {
                                            int pDeptId = (p.getDepartmentId() != null) ? p.getDepartmentId() : 0;
                                            boolean isSel = (emp != null && emp.getPositionId() != null && emp.getPositionId().equals(p.getPositionId()));
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
                        </div>

                        <div class="form-group">
                            <label for="levelId">Cấp bậc khởi điểm</label>
                            <select id="levelId" name="levelId" class="form-control" data-field-name="Cấp bậc khởi điểm">
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
                        <label for="hireDate">Ngày bắt đầu làm việc <span style="color:#dc2626;">*</span></label>
                        <div style="position:relative;">
                            <input type="text" id="hireDate" name="hireDate" class="form-control date-picker-dmy" 
                                   placeholder="dd/mm/yyyy" maxlength="10" autocomplete="off"
                                   data-field-name="Ngày bắt đầu làm việc"
                                   value="<%= (request.getParameter("hireDate") != null ? request.getParameter("hireDate") : (emp != null && emp.getHireDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(emp.getHireDate()) : "")) %>" required>
                            <span class="dmy-calendar-btn" data-target="hireDate" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#6b7280;font-size:14px;" title="Chọn ngày bắt đầu làm việc">
                                <i class="fa-solid fa-calendar-days"></i>
                            </span>
                        </div>
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

<style>
.dmy-calendar-popup {
    position: absolute;
    top: calc(100% + 4px);
    left: 0;
    z-index: 1000;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    box-shadow: 0 10px 20px -3px rgba(0,0,0,0.12), 0 4px 6px -2px rgba(0,0,0,0.05);
    border-radius: 8px;
    padding: 12px;
    width: 280px;
    font-family: inherit;
    display: none;
}
.dmy-calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 6px;
    margin-bottom: 10px;
}
.dmy-calendar-header select {
    padding: 4px 6px;
    font-size: 12.5px;
    border: 1px solid #cbd5e1;
    border-radius: 4px;
    background: #f8fafc;
    color: #1e293b;
    cursor: pointer;
}
.dmy-calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 3px;
    text-align: center;
}
.dmy-calendar-day-header {
    font-size: 11px;
    font-weight: 700;
    color: #64748b;
    padding: 4px 0;
}
.dmy-calendar-day {
    padding: 6px 0;
    font-size: 12.5px;
    border-radius: 4px;
    cursor: pointer;
    color: #334155;
    transition: all 0.15s;
}
.dmy-calendar-day:hover {
    background: #e0e7ff;
    color: #4338ca;
    font-weight: 600;
}
.dmy-calendar-day.empty {
    cursor: default;
    background: transparent;
}
.dmy-calendar-day.selected {
    background: #4f46e5;
    color: #ffffff;
    font-weight: 600;
}
</style>

<script>
    function checkManagerWarning() {
        var roleSelect = document.getElementById("roleId");
        var deptSelect = document.getElementById("departmentId");
        var deptLabel = document.getElementById("deptLabel");
        var alertEl = document.getElementById("managerAlert");

        if (!roleSelect || !deptSelect || !alertEl)
            return;

        var selectedRole = roleSelect.value;
        var selectedDeptOpt = deptSelect.options[deptSelect.selectedIndex];

        if (selectedRole === "3") {
            if (deptLabel)
                deptLabel.innerHTML = 'Phòng ban <span style="color:#dc2626;">*</span>';
            if (deptSelect.value === "0") {
                alertEl.style.display = "block";
                alertEl.style.color = "#e67e22";
                alertEl.innerText = "⚠ Trưởng phòng bắt buộc phải chọn một phòng ban cụ thể!";
            } else if (selectedDeptOpt && selectedDeptOpt.getAttribute("data-has-manager") === "true") {
                alertEl.style.display = "block";
                alertEl.style.color = "#e74c3c";
                var mgrName = selectedDeptOpt.getAttribute("data-manager-name");
                alertEl.innerText = "⚠ Phòng ban này đã có Trưởng phòng (" + mgrName + "). Mỗi phòng chỉ có tối đa 1 Trưởng phòng!";
            } else {
                alertEl.style.display = "none";
            }
        } else {
            if (deptLabel)
                deptLabel.innerHTML = 'Phòng ban';
            alertEl.style.display = "none";
        }
    }

    function filterPositionsByDepartment(preserveSelection) {
        var deptSelect = document.getElementById("departmentId");
        var posSelect = document.getElementById("positionId");
        if (!deptSelect || !posSelect)
            return;

        var selectedDept = deptSelect.value;
        var currentPos = posSelect.value;
        var hasMatchingOption = false;

        for (var i = 0; i < posSelect.options.length; i++) {
            var opt = posSelect.options[i];
            var optDept = opt.getAttribute("data-dept");

            if (opt.value === "0") {
                opt.style.display = "";
                opt.hidden = false;
            } else if (selectedDept === "0" || selectedDept === "") {
                opt.style.display = "none";
                opt.hidden = true;
            } else if (optDept === selectedDept || optDept === "0") {
                opt.style.display = "";
                opt.hidden = false;
                if (opt.value === currentPos) {
                    hasMatchingOption = true;
                }
            } else {
                opt.style.display = "none";
                opt.hidden = true;
            }
        }

        if (!hasMatchingOption && !preserveSelection) {
            posSelect.value = "0";
        }
    }

    function onDepartmentChange() {
        checkManagerWarning();
        filterPositionsByDepartment(false);
    }

    function setFieldError(field, msg) {
        if (!field) return;
        if (window.showFieldError) {
            window.showFieldError(field, msg);
        } else {
            field.style.borderColor = "#dc2626";
        }
    }

    function clearFieldError(field) {
        if (!field) return;
        if (window.clearFieldError) {
            window.clearFieldError(field);
        } else {
            field.style.borderColor = "";
        }
    }

    function parseDateDMY(str) {
        if (!str) return null;
        str = str.trim();
        var parts;
        var d, m, y;
        if (str.indexOf('/') !== -1) {
            parts = str.split('/');
        } else if (str.indexOf('-') !== -1) {
            parts = str.split('-');
        } else if (str.indexOf('.') !== -1) {
            parts = str.split('.');
        } else {
            return null;
        }
        if (parts.length !== 3) return null;

        if (parts[0].length === 4) {
            y = parseInt(parts[0], 10);
            m = parseInt(parts[1], 10) - 1;
            d = parseInt(parts[2], 10);
        } else {
            d = parseInt(parts[0], 10);
            m = parseInt(parts[1], 10) - 1;
            y = parseInt(parts[2], 10);
            if (y < 100) {
                y = (y > 30) ? 1900 + y : 2000 + y;
            }
        }
        if (isNaN(d) || isNaN(m) || isNaN(y) || y < 1900 || y > 2100 || m < 0 || m > 11 || d < 1 || d > 31) {
            return null;
        }
        var dt = new Date(y, m, d);
        if (dt.getFullYear() !== y || dt.getMonth() !== m || dt.getDate() !== d) {
            return null;
        }
        return dt;
    }

    function padZero(n) { return n < 10 ? "0" + n : n; }

    function formatDMY(date) {
        if (!date) return "";
        return padZero(date.getDate()) + "/" + padZero(date.getMonth() + 1) + "/" + date.getFullYear();
    }

    function validateEmployeeForm() {
        var dobInput = document.getElementById("dob");
        var hireInput = document.getElementById("hireDate");

        if (dobInput) clearFieldError(dobInput);
        if (hireInput) clearFieldError(hireInput);

        // 1. Kiểm tra Ngày sinh
        if (dobInput) {
            var dobVal = dobInput.value ? dobInput.value.trim() : "";
            if (!dobVal) {
                setFieldError(dobInput, "Ngày sinh không được để trống");
                dobInput.focus();
                return false;
            }
            var dob = parseDateDMY(dobVal);
            if (!dob) {
                setFieldError(dobInput, "Ngày sinh không đúng định dạng dd/mm/yyyy");
                dobInput.focus();
                return false;
            }
            var today = new Date();
            today.setHours(0,0,0,0);
            if (dob > today) {
                setFieldError(dobInput, "Ngày sinh không được ở thời điểm tương lai");
                dobInput.focus();
                return false;
            }
            var ageNow = today.getFullYear() - dob.getFullYear();
            var mDiff = today.getMonth() - dob.getMonth();
            if (mDiff < 0 || (mDiff === 0 && today.getDate() < dob.getDate())) {
                ageNow--;
            }
            if (ageNow < 18) {
                setFieldError(dobInput, "Nhân viên phải từ đủ 18 tuổi trở lên (hiện tại " + ageNow + " tuổi)");
                dobInput.focus();
                return false;
            }
        }

        // 2. Kiểm tra Ngày bắt đầu làm việc (khi tạo mới)
        if (hireInput) {
            var hireVal = hireInput.value ? hireInput.value.trim() : "";
            if (!hireVal) {
                setFieldError(hireInput, "Ngày bắt đầu làm việc không được để trống");
                hireInput.focus();
                return false;
            }
            var hire = parseDateDMY(hireVal);
            if (!hire) {
                setFieldError(hireInput, "Ngày bắt đầu làm việc không đúng định dạng dd/mm/yyyy");
                hireInput.focus();
                return false;
            }

            if (dobInput) {
                var dobVal = dobInput.value ? dobInput.value.trim() : "";
                var dob = parseDateDMY(dobVal);
                if (dob) {
                    // Ràng buộc 1: Không được trùng năm sinh
                    if (dob.getFullYear() === hire.getFullYear()) {
                        setFieldError(hireInput, "Năm bắt đầu làm việc không được trùng với năm sinh");
                        hireInput.focus();
                        return false;
                    }
                    // Ràng buộc 2: Tính từ ngày sinh đến lúc bắt đầu làm việc phải đủ 18 tuổi
                    var minHireDate = new Date(dob.getFullYear() + 18, dob.getMonth(), dob.getDate());
                    if (hire < minHireDate) {
                        setFieldError(hireInput, "Tính từ ngày sinh đến khi bắt đầu làm việc phải từ đủ 18 tuổi trở lên");
                        hireInput.focus();
                        return false;
                    }
                }
            }
        }

        return true;
    }

    // --- Custom dd/mm/yyyy DatePicker & Calendar Popup ---
    (function() {
        var currentActiveInput = null;
        var calendarPopup = document.createElement("div");
        calendarPopup.className = "dmy-calendar-popup";
        document.body.appendChild(calendarPopup);

        function pad(n) { return n < 10 ? "0" + n : n; }

        function renderCalendar(targetInput, viewYear, viewMonth) {
            currentActiveInput = targetInput;
            var currentVal = parseDateDMY(targetInput.value);
            if ((!viewYear && viewYear !== 0) || (!viewMonth && viewMonth !== 0)) {
                if (currentVal) {
                    viewYear = currentVal.getFullYear();
                    viewMonth = currentVal.getMonth();
                } else if (targetInput.id === "dob") {
                    viewYear = 2000;
                    viewMonth = 0;
                } else {
                    var now = new Date();
                    viewYear = now.getFullYear();
                    viewMonth = now.getMonth();
                }
            }

            var monthNames = ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
                              "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"];

            var html = '<div class="dmy-calendar-header">';
            html += '<select class="dmy-select-month">';
            for (var m = 0; m < 12; m++) {
                html += '<option value="' + m + '"' + (m === viewMonth ? ' selected' : '') + '>' + monthNames[m] + '</option>';
            }
            html += '</select>';

            html += '<select class="dmy-select-year">';
            var startY = targetInput.id === "dob" ? 1950 : 2000;
            var endY = targetInput.id === "dob" ? (new Date().getFullYear()) : (new Date().getFullYear() + 10);
            for (var y = endY; y >= startY; y--) {
                html += '<option value="' + y + '"' + (y === viewYear ? ' selected' : '') + '>' + y + '</option>';
            }
            html += '</select>';
            html += '</div>';

            html += '<div class="dmy-calendar-grid">';
            var dayHeaders = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
            for (var h = 0; h < 7; h++) {
                html += '<div class="dmy-calendar-day-header">' + dayHeaders[h] + '</div>';
            }

            var firstDay = new Date(viewYear, viewMonth, 1).getDay();
            var leadingEmpty = (firstDay === 0) ? 6 : (firstDay - 1);
            for (var e = 0; e < leadingEmpty; e++) {
                html += '<div class="dmy-calendar-day empty"></div>';
            }

            var totalDays = new Date(viewYear, viewMonth + 1, 0).getDate();
            for (var day = 1; day <= totalDays; day++) {
                var isSel = currentVal && currentVal.getFullYear() === viewYear && currentVal.getMonth() === viewMonth && currentVal.getDate() === day;
                html += '<div class="dmy-calendar-day' + (isSel ? ' selected' : '') + '" data-day="' + day + '">' + day + '</div>';
            }
            html += '</div>';

            calendarPopup.innerHTML = html;

            var monthSel = calendarPopup.querySelector(".dmy-select-month");
            var yearSel = calendarPopup.querySelector(".dmy-select-year");
            function onHeaderChange() {
                renderCalendar(targetInput, parseInt(yearSel.value, 10), parseInt(monthSel.value, 10));
            }
            monthSel.addEventListener("change", onHeaderChange);
            yearSel.addEventListener("change", onHeaderChange);

            var dayElements = calendarPopup.querySelectorAll(".dmy-calendar-day:not(.empty)");
            dayElements.forEach(function(dayEl) {
                dayEl.addEventListener("click", function(ev) {
                    ev.stopPropagation();
                    var pickedDay = parseInt(this.getAttribute("data-day"), 10);
                    var pickedMonth = parseInt(monthSel.value, 10) + 1;
                    var pickedYear = parseInt(yearSel.value, 10);
                    targetInput.value = pad(pickedDay) + "/" + pad(pickedMonth) + "/" + pickedYear;
                    clearFieldError(targetInput);
                    targetInput.dispatchEvent(new Event("input", { bubbles: true }));
                    targetInput.dispatchEvent(new Event("change", { bubbles: true }));
                    calendarPopup.style.display = "none";
                });
            });

            var rect = targetInput.getBoundingClientRect();
            calendarPopup.style.position = "absolute";
            calendarPopup.style.top = (rect.bottom + window.scrollY + 4) + "px";
            calendarPopup.style.left = (rect.left + window.scrollX) + "px";
            calendarPopup.style.display = "block";
        }

        // Live typing: completely unrestricted keyboard typing
        document.querySelectorAll(".date-picker-dmy").forEach(function(input) {
            input.addEventListener("input", function(e) {
                clearFieldError(input);
                calendarPopup.style.display = "none";
            });

            input.addEventListener("blur", function(e) {
                var v = this.value ? this.value.trim() : "";
                if (v) {
                    var parsed = parseDateDMY(v);
                    if (parsed) {
                        this.value = formatDMY(parsed);
                        clearFieldError(input);
                    }
                }
            });
        });

        // Click calendar icon toggles calendar popup
        document.querySelectorAll(".dmy-calendar-btn").forEach(function(btn) {
            btn.addEventListener("click", function(e) {
                e.stopPropagation();
                var targetId = this.getAttribute("data-target");
                var targetInput = document.getElementById(targetId);
                if (targetInput) {
                    if (calendarPopup.style.display === "block" && currentActiveInput === targetInput) {
                        calendarPopup.style.display = "none";
                    } else {
                        renderCalendar(targetInput);
                    }
                }
            });
        });

        document.addEventListener("click", function(e) {
            if (!calendarPopup.contains(e.target)) {
                calendarPopup.style.display = "none";
            }
        });
    })();

    document.addEventListener("DOMContentLoaded", function () {
        var roleSelect = document.getElementById("roleId");
        if (roleSelect) {
            roleSelect.addEventListener("change", checkManagerWarning);
        }
        checkManagerWarning();
        filterPositionsByDepartment(true);
    });
</script>

<jsp:include page="/views/common/footer.jsp" />
