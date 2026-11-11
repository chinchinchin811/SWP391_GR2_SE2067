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

<style>
    .segmented-date-wrapper {
        display: inline-flex;
        align-items: center;
        background: #ffffff;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        padding: 6px 12px;
        width: 100%;
        max-width: 280px;
        box-sizing: border-box;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .segmented-date-wrapper.focused {
        border-color: #3b82f6;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
    }
    .segmented-date-input {
        border: none;
        outline: none;
        background: transparent;
        font-size: 14px;
        font-family: inherit;
        color: #1e293b;
        text-align: center;
        padding: 0;
        margin: 0;
    }
    .segmented-date-input::placeholder {
        color: #94a3b8;
    }
    .segmented-date-input.part-day,
    .segmented-date-input.part-month {
        width: 28px;
    }
    .segmented-date-input.part-year {
        width: 48px;
    }
    .segmented-date-slash {
        color: #64748b;
        font-weight: 700;
        font-size: 14px;
        padding: 0 4px;
        user-select: none;
    }
</style>

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
                                   value="<%= emp != null && emp.getEmail() != null ? emp.getEmail() : "" %>" 
                                   <%= isSelfEdit ? "readonly style='background: #f1f2f6; cursor: not-allowed;'" : "required" %>>
                            <% if (isSelfEdit) { %>
                                <small style="color: #64748b; font-size: 11px;"><i class="fa-solid fa-lock"></i> Email định danh nội bộ, bạn không thể tự thay đổi.</small>
                            <% } %>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Số điện thoại:</label>
                            <input type="tel" id="phone" name="phone" class="form-control" 
                                   pattern="^(0|\+84)[0-9]{9}$"
                                   placeholder="Ví dụ: 0912345678"
                                   title="Số điện thoại gồm 10 chữ số bắt đầu bằng số 0 (hoặc +84)"
                                   value="<%= emp != null && emp.getPhone() != null ? emp.getPhone() : "" %>">
                            <small style="color: #64748b; font-size: 11px;">10 chữ số bắt đầu bằng số 0 (Ví dụ: 0912345678).</small>
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
                            <label for="dob_day">Ngày sinh (*) (dd/mm/yyyy):</label>
                            <div class="segmented-date-wrapper" id="dobWrapper">
                                <input type="text" id="dob_day" class="segmented-date-input part-day" maxlength="2" placeholder="dd" autocomplete="off" inputmode="numeric">
                                <span class="segmented-date-slash">/</span>
                                <input type="text" id="dob_month" class="segmented-date-input part-month" maxlength="2" placeholder="mm" autocomplete="off" inputmode="numeric">
                                <span class="segmented-date-slash">/</span>
                                <input type="text" id="dob_year" class="segmented-date-input part-year" maxlength="4" placeholder="yyyy" autocomplete="off" inputmode="numeric">
                                <input type="hidden" id="dob" name="dob" value="<%= (emp != null && emp.getDob() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(emp.getDob()) : (request.getParameter("dob") != null ? request.getParameter("dob") : "")) %>">
                            </div>
                            <small style="color: #64748b; font-size: 11px; display: block; margin-top: 4px;">Nhân viên phải từ đủ 18 tuổi trở lên (sinh trước ngày <%= maxDob.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %>).</small>
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
                            <label for="roleId">Vai trò (*):</label>
                            <select id="roleId" name="roleId" class="form-control" onchange="onRoleChange()" required>
                                <%
                                    if (roles != null) {
                                        for (Role r : roles) {
                                            // Khi tạo mới (!isEdit), chỉ hiển thị Manager (3) và Employee (4)
                                            if (!isEdit && r.getRoleId() != 3 && r.getRoleId() != 4) {
                                                continue;
                                            }
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
                    <div class="form-row" id="orgRow">
                        <div class="form-group" id="deptGroup">
                            <label for="departmentId" id="deptLabel">Phòng ban:</label>
                            <select id="departmentId" name="departmentId" class="form-control" onchange="onDepartmentChange()">
                                <option value="0" data-has-manager="false">-- Chưa xếp phòng ban --</option>
                                <%
                                    if (departments != null) {
                                        for (Department d : departments) {
                                            boolean hasMgr = (d.getManagerName() != null && !d.getManagerName().trim().isEmpty());
                                            String mgrInfo = hasMgr ? " (Đã có TP: " + d.getManagerName() + ")" : " (Chưa có TP)";
                                            boolean isInactive = !d.isStatus();
                                            boolean isCurrentDept = (emp != null && emp.getDepartmentId() != null && emp.getDepartmentId().equals(d.getDepartmentId()));
                                %>
                                <option value="<%= d.getDepartmentId() %>" 
                                        data-has-manager="<%= hasMgr %>" 
                                        data-manager-name="<%= hasMgr ? d.getManagerName() : "" %>"
                                        data-status="<%= d.isStatus() %>"
                                        <%= (isInactive && !isCurrentDept) ? "disabled style='color: #94a3b8; background-color: #f1f5f9;'" : "" %>
                                        <%= isCurrentDept ? "selected" : "" %>>
                                    <%= d.getDepartmentName() %><%= isInactive ? " (Tạm ngưng - Không thể tiếp nhận)" : mgrInfo %>
                                </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <small id="managerAlert" style="display: none; color: #e74c3c; font-weight: 500; margin-top: 4px;"></small>
                        </div>

                        <div class="form-group" id="positionGroup">
                            <label for="positionId">Vị trí chuyên môn:</label>
                            <select id="positionId" name="positionId" class="form-control" onchange="onPositionChange()">
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

                        <div class="form-group" id="levelGroup">
                            <label for="levelId">Cấp bậc khởi điểm:</label>
                            <select id="levelId" name="levelId" class="form-control">
                                <option value="0" data-pos="0">-- Chưa chọn cấp bậc --</option>
                                <%
                                    if (jobLevels != null) {
                                        for (JobLevel lvl : jobLevels) {
                                            int lPosId = (lvl.getPositionId() != null) ? lvl.getPositionId() : 0;
                                            boolean isSel = (emp != null && emp.getLevelId() != null && emp.getLevelId().equals(lvl.getLevelId()));
                                %>
                                <option value="<%= lvl.getLevelId() %>" data-pos="<%= lPosId %>" <%= isSel ? "selected" : "" %>><%= lvl.getLevelName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="hireDate_day">Ngày bắt đầu làm việc (dd/mm/yyyy):</label>
                        <div class="segmented-date-wrapper" id="hireDateWrapper">
                            <input type="text" id="hireDate_day" class="segmented-date-input part-day" maxlength="2" placeholder="dd" autocomplete="off" inputmode="numeric">
                            <span class="segmented-date-slash">/</span>
                            <input type="text" id="hireDate_month" class="segmented-date-input part-month" maxlength="2" placeholder="mm" autocomplete="off" inputmode="numeric">
                            <span class="segmented-date-slash">/</span>
                            <input type="text" id="hireDate_year" class="segmented-date-input part-year" maxlength="4" placeholder="yyyy" autocomplete="off" inputmode="numeric">
                            <input type="hidden" id="hireDate" name="hireDate" value="<%= (emp != null && emp.getHireDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(emp.getHireDate()) : (request.getParameter("hireDate") != null ? request.getParameter("hireDate") : "")) %>">
                        </div>
                        <small style="color: #64748b; font-size: 11px; display: block; margin-top: 4px;">Để trống sẽ tự động lấy ngày hiện tại (<%= java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %>) làm ngày bắt đầu làm việc.</small>
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

<script>
    function onRoleChange() {
        var roleSelect = document.getElementById("roleId");
        var posGroup = document.getElementById("positionGroup");
        var lvlGroup = document.getElementById("levelGroup");
        var posSelect = document.getElementById("positionId");
        var lvlSelect = document.getElementById("levelId");

        if (!roleSelect)
            return;

        var selectedRole = roleSelect.value;
        if (selectedRole === "3") { // MANAGER
            if (posGroup)
                posGroup.style.display = "none";
            if (lvlGroup)
                lvlGroup.style.display = "none";
            if (posSelect)
                posSelect.value = "0";
            if (lvlSelect)
                lvlSelect.value = "0";
        } else { // EMPLOYEE
            if (posGroup)
                posGroup.style.display = "";
            if (lvlGroup)
                lvlGroup.style.display = "";
            filterPositionsByDepartment(true);
            filterLevelsByPosition(true);
        }

        checkManagerWarning();
    }

    function checkManagerWarning() {
        var roleSelect = document.getElementById("roleId");
        var deptSelect = document.getElementById("departmentId");
        var deptLabel = document.getElementById("deptLabel");
        var alertEl = document.getElementById("managerAlert");

        if (!roleSelect || !deptSelect || !alertEl)
            return;

        var selectedRole = roleSelect.value;
        var selectedDeptOpt = deptSelect.options[deptSelect.selectedIndex];

        if (selectedDeptOpt && selectedDeptOpt.getAttribute("data-status") === "false") {
            alertEl.style.display = "block";
            alertEl.style.color = "#dc2626";
            alertEl.innerText = "⚠ Phòng ban này đang Tạm ngưng, không thể phân bổ hoặc tiếp nhận nhân sự!";
            return;
        }

        if (selectedRole === "3") { // MANAGER
            if (deptLabel)
                deptLabel.innerHTML = 'Phòng ban <span style="color:red;">(*)</span>:';
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
                deptLabel.innerHTML = 'Phòng ban:';
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

    function filterLevelsByPosition(preserveSelection) {
        var posSelect = document.getElementById("positionId");
        var levelSelect = document.getElementById("levelId");
        if (!posSelect || !levelSelect)
            return;

        var selectedPos = posSelect.value;
        var currentLevel = levelSelect.value;
        var hasMatchingOption = false;

        var matchingCount = 0;
        for (var i = 0; i < levelSelect.options.length; i++) {
            var opt = levelSelect.options[i];
            var optPos = opt.getAttribute("data-pos");
            if (opt.value !== "0" && optPos === selectedPos) {
                matchingCount++;
            }
        }

        for (var i = 0; i < levelSelect.options.length; i++) {
            var opt = levelSelect.options[i];
            var optPos = opt.getAttribute("data-pos");

            if (opt.value === "0") {
                opt.style.display = "";
                opt.hidden = false;
            } else if (selectedPos === "0" || selectedPos === "") {
                opt.style.display = "none";
                opt.hidden = true;
            } else if (matchingCount > 0 && optPos === selectedPos) {
                opt.style.display = "";
                opt.hidden = false;
                if (opt.value === currentLevel) {
                    hasMatchingOption = true;
                }
            } else if (matchingCount === 0 && optPos === "0") {
                opt.style.display = "";
                opt.hidden = false;
                if (opt.value === currentLevel) {
                    hasMatchingOption = true;
                }
            } else {
                opt.style.display = "none";
                opt.hidden = true;
            }
        }

        if (!hasMatchingOption && !preserveSelection) {
            levelSelect.value = "0";
        }
    }

    function onDepartmentChange() {
        checkManagerWarning();
        filterPositionsByDepartment(false);
        filterLevelsByPosition(false);
    }

    function onPositionChange() {
        filterLevelsByPosition(false);
    }

    function parseDMY(str) {
        if (!str) return null;
        var parts = str.trim().split(/[-/.]/);
        if (parts.length === 3) {
            var d, m, y;
            if (parts[0].length === 4) { // yyyy-mm-dd
                y = parseInt(parts[0], 10);
                m = parseInt(parts[1], 10);
                d = parseInt(parts[2], 10);
            } else { // dd/mm/yyyy
                d = parseInt(parts[0], 10);
                m = parseInt(parts[1], 10);
                y = parseInt(parts[2], 10);
            }
            if (!isNaN(d) && !isNaN(m) && !isNaN(y) && m >= 1 && m <= 12 && d >= 1 && d <= 31 && y >= 1900 && y <= 2100) {
                var dt = new Date(y, m - 1, d);
                if (dt.getFullYear() === y && dt.getMonth() === m - 1 && dt.getDate() === d) {
                    return { date: dt, day: d, month: m, year: y };
                }
            }
        }
        return null;
    }

    function initSegmentedDate(prefix) {
        var wrapper = document.getElementById(prefix + "Wrapper");
        var dayInput = document.getElementById(prefix + "_day");
        var monthInput = document.getElementById(prefix + "_month");
        var yearInput = document.getElementById(prefix + "_year");
        var hiddenInput = document.getElementById(prefix);

        if (!wrapper || !dayInput || !monthInput || !yearInput || !hiddenInput)
            return;

        function syncFromHidden() {
            var val = hiddenInput.value ? hiddenInput.value.trim() : "";
            if (val) {
                var parts = val.split(/[-/.]/);
                if (parts.length === 3) {
                    if (parts[0].length === 4) { // yyyy-mm-dd
                        yearInput.value = parts[0];
                        monthInput.value = parts[1].padStart(2, '0');
                        dayInput.value = parts[2].padStart(2, '0');
                    } else { // dd/mm/yyyy
                        dayInput.value = parts[0].padStart(2, '0');
                        monthInput.value = parts[1].padStart(2, '0');
                        yearInput.value = parts[2];
                    }
                }
            }
        }
        syncFromHidden();

        function updateHidden() {
            var d = dayInput.value.trim();
            var m = monthInput.value.trim();
            var y = yearInput.value.trim();
            if (d || m || y) {
                var paddedD = (d.length === 1) ? ("0" + d) : d;
                var paddedM = (m.length === 1) ? ("0" + m) : m;
                hiddenInput.value = paddedD + "/" + paddedM + "/" + y;
            } else {
                hiddenInput.value = "";
            }
        }

        [dayInput, monthInput, yearInput].forEach(function (el) {
            el.addEventListener("focus", function () {
                wrapper.classList.add("focused");
            });
            el.addEventListener("blur", function () {
                wrapper.classList.remove("focused");
                updateHidden();
            });
        });

        dayInput.addEventListener("input", function () {
            var clean = this.value.replace(/\D/g, "");
            if (clean.length > 2) clean = clean.substring(0, 2);
            this.value = clean;
            updateHidden();
            if (clean.length === 2) {
                monthInput.focus();
                monthInput.select();
            }
        });

        monthInput.addEventListener("input", function () {
            var clean = this.value.replace(/\D/g, "");
            if (clean.length > 2) clean = clean.substring(0, 2);
            this.value = clean;
            updateHidden();
            if (clean.length === 2) {
                yearInput.focus();
                yearInput.select();
            }
        });

        yearInput.addEventListener("input", function () {
            var clean = this.value.replace(/\D/g, "");
            if (clean.length > 4) clean = clean.substring(0, 4);
            this.value = clean;
            updateHidden();
        });

        monthInput.addEventListener("keydown", function (e) {
            if (e.key === "Backspace" && (this.value === "" || (this.selectionStart === 0 && this.selectionEnd === 0))) {
                dayInput.focus();
            }
        });

        yearInput.addEventListener("keydown", function (e) {
            if (e.key === "Backspace" && (this.value === "" || (this.selectionStart === 0 && this.selectionEnd === 0))) {
                monthInput.focus();
            }
        });

        [dayInput, monthInput, yearInput].forEach(function (el) {
            el.addEventListener("paste", function (e) {
                var pasted = (e.clipboardData || window.clipboardData).getData("text");
                if (pasted) {
                    var digits = pasted.replace(/\D/g, "");
                    if (digits.length === 8) {
                        e.preventDefault();
                        dayInput.value = digits.substring(0, 2);
                        monthInput.value = digits.substring(2, 4);
                        yearInput.value = digits.substring(4, 8);
                        updateHidden();
                        yearInput.focus();
                    }
                }
            });
        });
    }

    function validateEmployeeForm() {
        var dayInput = document.getElementById("dob_day");
        var monthInput = document.getElementById("dob_month");
        var yearInput = document.getElementById("dob_year");

        var d = dayInput ? dayInput.value.trim() : "";
        var m = monthInput ? monthInput.value.trim() : "";
        var y = yearInput ? yearInput.value.trim() : "";

        if (!d || !m || !y || y.length < 4) {
            alert("Vui lòng nhập đầy đủ Ngày sinh theo định dạng dd/mm/yyyy!");
            if (!d && dayInput) dayInput.focus();
            else if (!m && monthInput) monthInput.focus();
            else if (yearInput) yearInput.focus();
            return false;
        }

        var parsed = parseDMY(d + "/" + m + "/" + y);
        if (!parsed) {
            alert("Ngày sinh không hợp lệ! Vui lòng kiểm tra lại ngày, tháng, năm sinh.");
            if (dayInput) dayInput.focus();
            return false;
        }

        var today = new Date();
        if (parsed.date > today) {
            alert("Ngày sinh không được ở thời điểm tương lai!");
            if (yearInput) yearInput.focus();
            return false;
        }
        if (parsed.year > 2099 || parsed.year < 1920) {
            alert("Năm sinh không hợp lệ!");
            if (yearInput) yearInput.focus();
            return false;
        }
        var age = today.getFullYear() - parsed.year;
        var mDiff = today.getMonth() - (parsed.month - 1);
        if (mDiff < 0 || (mDiff === 0 && today.getDate() < parsed.day)) {
            age--;
        }
        if (age < 18) {
            alert("Nhân viên phải từ đủ 18 tuổi trở lên (Hiện tại tính theo ngày sinh mới " + age + " tuổi)!");
            if (dayInput) dayInput.focus();
            return false;
        }

        var hDay = document.getElementById("hireDate_day");
        var hMonth = document.getElementById("hireDate_month");
        var hYear = document.getElementById("hireDate_year");
        var hd = hDay ? hDay.value.trim() : "";
        var hm = hMonth ? hMonth.value.trim() : "";
        var hy = hYear ? hYear.value.trim() : "";

        if (hd || hm || hy) {
            if (!hd || !hm || !hy || hy.length < 4) {
                alert("Vui lòng nhập đầy đủ Ngày bắt đầu làm việc theo định dạng dd/mm/yyyy hoặc để trống cả 3 ô để tự động lấy ngày hiện tại!");
                if (!hd && hDay) hDay.focus();
                else if (!hm && hMonth) hMonth.focus();
                else if (hYear) hYear.focus();
                return false;
            }
            var parsedHire = parseDMY(hd + "/" + hm + "/" + hy);
            if (!parsedHire) {
                alert("Ngày bắt đầu làm việc không hợp lệ! Vui lòng kiểm tra lại ngày, tháng, năm.");
                if (hDay) hDay.focus();
                return false;
            }
        }

        var roleSelect = document.getElementById("roleId");
        var deptSelect = document.getElementById("departmentId");
        if (deptSelect && deptSelect.value && deptSelect.value !== "0") {
            var selectedOpt = deptSelect.options[deptSelect.selectedIndex];
            if (selectedOpt && selectedOpt.getAttribute("data-status") === "false") {
                alert("Phòng ban '" + selectedOpt.text.trim() + "' đang ở trạng thái Tạm ngưng! Không thể phân bổ hoặc tiếp nhận nhân sự mới cho đến khi được kích hoạt lại.");
                deptSelect.focus();
                return false;
            }
        }

        if (roleSelect && roleSelect.value === "3") { // MANAGER
            if (deptSelect && (deptSelect.value === "0" || deptSelect.value === "")) {
                alert("Trưởng phòng bắt buộc phải chọn một phòng ban cụ thể!");
                deptSelect.focus();
                return false;
            }
        }

        return true;
    }

    document.addEventListener("DOMContentLoaded", function () {
        var roleSelect = document.getElementById("roleId");
        if (roleSelect) {
            roleSelect.addEventListener("change", onRoleChange);
        }
        initSegmentedDate("dob");
        initSegmentedDate("hireDate");
        onRoleChange();
    });
</script>

<jsp:include page="/views/common/footer.jsp" />
