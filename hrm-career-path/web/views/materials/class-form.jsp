<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="java.util.List,model.*" %>
        <% List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("materials");
                List<Department> departments = (List<Department>) request.getAttribute("departments");
                        List<Position> positions = (List<Position>) request.getAttribute("positions");
                                List<JobLevel> levels = (List<JobLevel>) request.getAttribute("levels");
                                        List<User> mentors = (List<User>) request.getAttribute("mentors");
                                                String errorMessage = (String) session.getAttribute("errorMessage");
                                                session.removeAttribute("errorMessage");
                                                request.setAttribute("pageTitle", "Mở lớp đào tạo | HRM");
                                                %>
                                                <jsp:include page="/views/common/header.jsp" />
                                                <jsp:include page="/views/common/sidebar.jsp" />
                                                <main class="main-content">
                                                    <div class="topbar">
                                                        <h1>Mở Lớp Đào Tạo</h1>
                                                        <div class="topbar-actions">
                                                            <a class="btn btn-secondary"
                                                                href="<%= request.getContextPath() %>/materials?action=classList">Quay
                                                                lại danh sách</a>
                                                        </div>
                                                    </div>
                                                    <div class="content-body">
                                                        <% if (errorMessage !=null) { %>
                                                            <div class="alert alert-danger">
                                                                <%= errorMessage %>
                                                            </div>
                                                            <% } %>

                                                                <div class="card" style="max-width:920px;margin:0 auto">
                                                                    <div class="card-header">
                                                                        <h2>Thông Tin Lớp Đào Tạo</h2>
                                                                    </div>
                                                                    <div class="card-body">
                                                                        <form method="post"
                                                                            action="<%= request.getContextPath() %>/materials"
                                                                            id="classForm"
                                                                            onsubmit="return validateClassForm()">
                                                                            <input type="hidden" name="action"
                                                                                value="saveClass">

                                                                            <div class="form-row">
                                                                                <div class="form-group">
                                                                                    <label for="classCode">Mã lớp <span
                                                                                            style="color:#dc2626;">*</span></label>
                                                                                    <input required class="form-control"
                                                                                        id="classCode" name="classCode"
                                                                                        data-field-name="Mã lớp"
                                                                                        placeholder="VD: DEV-FRESHER-2026">
                                                                                </div>
                                                                                <div class="form-group">
                                                                                    <label for="className">Tên lớp <span
                                                                                            style="color:#dc2626;">*</span></label>
                                                                                    <input required class="form-control"
                                                                                        id="className" name="className"
                                                                                        data-field-name="Tên lớp">
                                                                                </div>
                                                                            </div>

                                                                            <div class="form-group">
                                                                                <label for="description">Mô tả</label>
                                                                                <textarea class="form-control"
                                                                                    id="description" rows="3"
                                                                                    name="description"></textarea>
                                                                            </div>

                                                                            <div class="form-row">
                                                                                <div class="form-group">
                                                                                    <label for="positionId">Vị trí mục
                                                                                        tiêu</label>
                                                                                    <select class="form-control"
                                                                                        id="positionId"
                                                                                        name="positionId"
                                                                                        onchange="filterClassLevels()"
                                                                                        data-field-name="Vị trí mục tiêu">
                                                                                        <option value="">— Tất cả vị trí
                                                                                            —</option>
                                                                                        <% if (positions !=null) { for
                                                                                            (Position p : positions) {
                                                                                            %>
                                                                                            <option
                                                                                                value="<%= p.getPositionId() %>">
                                                                                                <%= p.getPositionName()
                                                                                                    %>
                                                                                            </option>
                                                                                            <% } } %>
                                                                                    </select>
                                                                                </div>
                                                                                <div class="form-group">
                                                                                    <label for="levelId">Cấp bậc mục
                                                                                        tiêu</label>
                                                                                    <select class="form-control"
                                                                                        id="levelId" name="levelId"
                                                                                        data-field-name="Cấp bậc mục tiêu">
                                                                                        <option value="">— Tất cả cấp
                                                                                            bậc —</option>
                                                                                        <% if (levels !=null) { for
                                                                                            (JobLevel l : levels) { 
                                                                                            int lPosId = (l.getPositionId() != null) ? l.getPositionId() : 0;
                                                                                        %>
                                                                                            <option
                                                                                                value="<%= l.getLevelId() %>"
                                                                                                data-pos="<%= lPosId %>">
                                                                                                <%= l.getLevelName() %>
                                                                                            </option>
                                                                                            <% } } %>
                                                                                    </select>
                                                                                </div>
                                                                            </div>

                                                                            <div class="form-row">
                                                                                <div class="form-group">
                                                                                    <label for="mentorId">Mentor đứng
                                                                                        lớp <span
                                                                                            style="color:#dc2626;">*</span></label>
                                                                                    <small
                                                                                        style="display:block;color:#666;margin-bottom:6px">Nhân
                                                                                        viên được ghi danh vào lớp sẽ tự
                                                                                        động trở thành mentee của mentor
                                                                                        này.</small>
                                                                                    <select required
                                                                                        class="form-control"
                                                                                        id="mentorId" name="mentorId"
                                                                                        data-field-name="Mentor đứng lớp">
                                                                                        <option value="">— Chọn mentor
                                                                                            đứng lớp —</option>
                                                                                        <% if (mentors !=null) { for
                                                                                            (User u : mentors) { %>
                                                                                            <option
                                                                                                value="<%= u.getUserId() %>">
                                                                                                <%= u.getFullName() %>
                                                                                            </option>
                                                                                            <% } } %>
                                                                                    </select>
                                                                                </div>
                                                                                <div class="form-group">
                                                                                    <label for="startDate">Ngày bắt đầu
                                                                                        <span
                                                                                            style="color:#dc2626;">*</span></label>
                                                                                    <div style="position:relative;">
                                                                                        <input required
                                                                                            class="form-control date-picker-dmy"
                                                                                            type="text" name="startDate"
                                                                                            id="startDate"
                                                                                            placeholder="dd/mm/yyyy"
                                                                                            maxlength="10"
                                                                                            autocomplete="off"
                                                                                            data-field-name="Ngày bắt đầu">
                                                                                        <span class="dmy-calendar-btn"
                                                                                            data-target="startDate"
                                                                                            style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#6b7280;font-size:14px;"
                                                                                            title="Chọn ngày bắt đầu">
                                                                                            <i
                                                                                                class="fa-solid fa-calendar-days"></i>
                                                                                        </span>
                                                                                    </div>
                                                                                </div>
                                                                                <div class="form-group">
                                                                                    <label for="endDate">Ngày kết thúc
                                                                                        <span
                                                                                            style="color:#dc2626;">*</span></label>
                                                                                    <div style="position:relative;">
                                                                                        <input required
                                                                                            class="form-control date-picker-dmy"
                                                                                            type="text" name="endDate"
                                                                                            id="endDate"
                                                                                            placeholder="dd/mm/yyyy"
                                                                                            maxlength="10"
                                                                                            autocomplete="off"
                                                                                            data-field-name="Ngày kết thúc">
                                                                                        <span class="dmy-calendar-btn"
                                                                                            data-target="endDate"
                                                                                            style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#6b7280;font-size:14px;"
                                                                                            title="Chọn ngày kết thúc">
                                                                                            <i
                                                                                                class="fa-solid fa-calendar-days"></i>
                                                                                        </span>
                                                                                    </div>
                                                                                </div>
                                                                            </div>

                                                                            <div class="form-group">
                                                                                <label>Học liệu trong lớp</label>
                                                                                <div
                                                                                    style="max-height:220px;overflow:auto;border:1px solid #000;padding:10px">
                                                                                    <% if (materials !=null) { for
                                                                                        (LearningMaterial m : materials)
                                                                                        { %>
                                                                                        <label
                                                                                            style="display:flex;align-items:baseline;gap:8px;padding:5px 0;cursor:pointer;font-size:13px">
                                                                                            <input type="checkbox"
                                                                                                name="materialIds"
                                                                                                value="<%= m.getMaterialId() %>">
                                                                                            <span><strong>
                                                                                                    <%= m.getTitle() %>
                                                                                                </strong>
                                                                                                <span
                                                                                                    style="color:#666;font-size:11.5px">(
                                                                                                    <%= m.getMaterialType()
                                                                                                        %>, <%=
                                                                                                            m.getDurationMinutes()
                                                                                                            %>
                                                                                                            phút)</span>
                                                                                            </span>
                                                                                        </label>
                                                                                        <% } } %>
                                                                                </div>
                                                                            </div>

                                                                            <input type="hidden" name="status"
                                                                                value="OPEN">
                                                                            <div class="form-actions">
                                                                                <a class="btn btn-secondary"
                                                                                    href="<%= request.getContextPath() %>/materials?action=classList">Hủy</a>
                                                                                <button type="submit"
                                                                                    class="btn btn-primary">Mở
                                                                                    lớp</button>
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
                                                        box-shadow: 0 10px 20px -3px rgba(0, 0, 0, 0.12), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
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

                                                    .dmy-calendar-day:hover:not(.disabled) {
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

                                                    .dmy-calendar-day.disabled {
                                                        color: #cbd5e1 !important;
                                                        cursor: not-allowed !important;
                                                        background: transparent !important;
                                                        pointer-events: none !important;
                                                        opacity: 0.4;
                                                        text-decoration: line-through;
                                                    }
                                                </style>

                                                <script>
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

                                                    // Helper: Lấy minDate cho từng ô nhập
                                                    function getMinAllowedDate(fieldId) {
                                                        var today = new Date();
                                                        today.setHours(0, 0, 0, 0);

                                                        if (fieldId === "startDate") {
                                                            return today;
                                                        } else if (fieldId === "endDate") {
                                                            var startInput = document.getElementById("startDate");
                                                            if (startInput && startInput.value) {
                                                                var startDt = parseDateDMY(startInput.value);
                                                                if (startDt) {
                                                                    var minEnd = new Date(startDt);
                                                                    minEnd.setDate(minEnd.getDate() + 1);
                                                                    minEnd.setHours(0, 0, 0, 0);
                                                                    return minEnd;
                                                                }
                                                            }
                                                            var minEndToday = new Date(today);
                                                            minEndToday.setDate(minEndToday.getDate() + 1);
                                                            return minEndToday;
                                                        }
                                                        return null;
                                                    }

                                                    // Tự động kiểm tra và đẩy ngày kết thúc khi ngày bắt đầu thay đổi
                                                    function syncDateLimits() {
                                                        var startInput = document.getElementById("startDate");
                                                        var endInput = document.getElementById("endDate");
                                                        if (!startInput || !endInput) return;

                                                        var startVal = startInput.value ? startInput.value.trim() : "";
                                                        var startDt = parseDateDMY(startVal);
                                                        if (startDt) {
                                                            var minEnd = new Date(startDt);
                                                            minEnd.setDate(minEnd.getDate() + 1);
                                                            minEnd.setHours(0, 0, 0, 0);

                                                            var endVal = endInput.value ? endInput.value.trim() : "";
                                                            var endDt = parseDateDMY(endVal);
                                                            if (endDt && endDt < minEnd) {
                                                                endInput.value = formatDMY(minEnd);
                                                                clearFieldError(endInput);
                                                            }
                                                        }
                                                    }

                                                    function validateClassForm() {
                                                        var startInput = document.getElementById("startDate");
                                                        var endInput = document.getElementById("endDate");

                                                        if (startInput) clearFieldError(startInput);
                                                        if (endInput) clearFieldError(endInput);

                                                        var today = new Date();
                                                        today.setHours(0, 0, 0, 0);

                                                        var startDt = null;
                                                        if (startInput) {
                                                            var startVal = startInput.value ? startInput.value.trim() : "";
                                                            if (!startVal) {
                                                                setFieldError(startInput, "Ngày bắt đầu không được để trống");
                                                                startInput.focus();
                                                                return false;
                                                            }
                                                            startDt = parseDateDMY(startVal);
                                                            if (!startDt) {
                                                                setFieldError(startInput, "Ngày bắt đầu không đúng định dạng dd/mm/yyyy");
                                                                startInput.focus();
                                                                return false;
                                                            }
                                                            if (startDt < today) {
                                                                setFieldError(startInput, "Ngày bắt đầu không được nằm trong quá khứ");
                                                                startInput.focus();
                                                                return false;
                                                            }
                                                        }

                                                        if (endInput) {
                                                            var endVal = endInput.value ? endInput.value.trim() : "";
                                                            if (!endVal) {
                                                                setFieldError(endInput, "Ngày kết thúc không được để trống");
                                                                endInput.focus();
                                                                return false;
                                                            }
                                                            var endDt = parseDateDMY(endVal);
                                                            if (!endDt) {
                                                                setFieldError(endInput, "Ngày kết thúc không đúng định dạng dd/mm/yyyy");
                                                                endInput.focus();
                                                                return false;
                                                            }

                                                            if (startDt) {
                                                                var minEnd = new Date(startDt);
                                                                minEnd.setDate(minEnd.getDate() + 1);
                                                                minEnd.setHours(0, 0, 0, 0);

                                                                if (endDt < minEnd) {
                                                                    setFieldError(endInput, "Ngày kết thúc phải sau ngày bắt đầu ít nhất 1 ngày (tối thiểu là từ ngày " + formatDMY(minEnd) + ")");
                                                                    endInput.focus();
                                                                    return false;
                                                                }
                                                            }
                                                        }

                                                        return true;
                                                    }

                                                    // --- Custom dd/mm/yyyy DatePicker & Calendar Popup for Class Form ---
                                                    (function () {
                                                        var currentActiveInput = null;
                                                        var calendarPopup = document.createElement("div");
                                                        calendarPopup.className = "dmy-calendar-popup";
                                                        document.body.appendChild(calendarPopup);

                                                        function pad(n) { return n < 10 ? "0" + n : n; }

                                                        function renderCalendar(targetInput, viewYear, viewMonth) {
                                                            currentActiveInput = targetInput;
                                                            var currentVal = parseDateDMY(targetInput.value);
                                                            var minAllowed = getMinAllowedDate(targetInput.id);

                                                            if ((!viewYear && viewYear !== 0) || (!viewMonth && viewMonth !== 0)) {
                                                                if (currentVal) {
                                                                    viewYear = currentVal.getFullYear();
                                                                    viewMonth = currentVal.getMonth();
                                                                } else if (minAllowed) {
                                                                    viewYear = minAllowed.getFullYear();
                                                                    viewMonth = minAllowed.getMonth();
                                                                } else {
                                                                    var now = new Date();
                                                                    viewYear = now.getFullYear();
                                                                    viewMonth = now.getMonth();
                                                                }
                                                            }

                                                            // Nếu viewYear/viewMonth nhỏ hơn minAllowed thì tự nhảy tới minAllowed
                                                            if (minAllowed) {
                                                                var viewStartOfMonth = new Date(viewYear, viewMonth + 1, 0);
                                                                viewStartOfMonth.setHours(23, 59, 59, 999);
                                                                if (viewStartOfMonth < minAllowed) {
                                                                    viewYear = minAllowed.getFullYear();
                                                                    viewMonth = minAllowed.getMonth();
                                                                }
                                                            }

                                                            var monthNames = ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
                                                                "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"];

                                                            var html = '<div class="dmy-calendar-header">';
                                                            html += '<select class="dmy-select-month">';
                                                            for (var m = 0; m < 12; m++) {
                                                                var isMonthDisabled = false;
                                                                if (minAllowed && viewYear === minAllowed.getFullYear() && m < minAllowed.getMonth()) {
                                                                    isMonthDisabled = true;
                                                                }
                                                                html += '<option value="' + m + '"' + (m === viewMonth ? ' selected' : '') + (isMonthDisabled ? ' disabled style="color:#cbd5e1"' : '') + '>' + monthNames[m] + '</option>';
                                                            }
                                                            html += '</select>';

                                                            html += '<select class="dmy-select-year">';
                                                            var currentY = new Date().getFullYear();
                                                            var startY = minAllowed ? minAllowed.getFullYear() : currentY;
                                                            var endY = startY + 5;
                                                            for (var y = startY; y <= endY; y++) {
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
                                                                var cellDate = new Date(viewYear, viewMonth, day);
                                                                cellDate.setHours(0, 0, 0, 0);
                                                                var isSel = currentVal && currentVal.getFullYear() === viewYear && currentVal.getMonth() === viewMonth && currentVal.getDate() === day;
                                                                var isDisabled = (minAllowed && cellDate < minAllowed);

                                                                var cls = 'dmy-calendar-day';
                                                                if (isSel) cls += ' selected';
                                                                if (isDisabled) cls += ' disabled';

                                                                html += '<div class="' + cls + '" data-day="' + day + '"' + (isDisabled ? ' title="Không thể chọn ngày trong quá khứ hoặc trước hạn tối thiểu"' : '') + '>' + day + '</div>';
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

                                                            var dayElements = calendarPopup.querySelectorAll(".dmy-calendar-day:not(.empty):not(.disabled)");
                                                            dayElements.forEach(function (dayEl) {
                                                                dayEl.addEventListener("click", function (ev) {
                                                                    ev.stopPropagation();
                                                                    var pickedDay = parseInt(this.getAttribute("data-day"), 10);
                                                                    var pickedMonth = parseInt(monthSel.value, 10) + 1;
                                                                    var pickedYear = parseInt(yearSel.value, 10);
                                                                    targetInput.value = pad(pickedDay) + "/" + pad(pickedMonth) + "/" + pickedYear;
                                                                    clearFieldError(targetInput);
                                                                    targetInput.dispatchEvent(new Event("input", { bubbles: true }));
                                                                    targetInput.dispatchEvent(new Event("change", { bubbles: true }));
                                                                    calendarPopup.style.display = "none";
                                                                    syncDateLimits();
                                                                });
                                                            });

                                                            var rect = targetInput.getBoundingClientRect();
                                                            calendarPopup.style.position = "absolute";
                                                            calendarPopup.style.top = (rect.bottom + window.scrollY + 4) + "px";
                                                            calendarPopup.style.left = (rect.left + window.scrollX) + "px";
                                                            calendarPopup.style.display = "block";
                                                        }

                                                        // Live typing handling: allow free keyboard input
                                                        document.querySelectorAll(".date-picker-dmy").forEach(function (input) {
                                                            input.addEventListener("input", function (e) {
                                                                clearFieldError(input);
                                                                calendarPopup.style.display = "none";
                                                            });

                                                            input.addEventListener("blur", function (e) {
                                                                var v = this.value ? this.value.trim() : "";
                                                                if (v) {
                                                                    var parsed = parseDateDMY(v);
                                                                    if (parsed) {
                                                                        this.value = formatDMY(parsed);
                                                                        clearFieldError(input);
                                                                        syncDateLimits();
                                                                    }
                                                                }
                                                            });

                                                            input.addEventListener("change", function (e) {
                                                                syncDateLimits();
                                                            });
                                                        });

                                                        // Click calendar icon toggles calendar popup
                                                        document.querySelectorAll(".dmy-calendar-btn").forEach(function (btn) {
                                                            btn.addEventListener("click", function (e) {
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

                                                        document.addEventListener("click", function (e) {
                                                            if (!calendarPopup.contains(e.target)) {
                                                                calendarPopup.style.display = "none";
                                                            }
                                                        });
                                                    })();

                                                    var allClassLevels = [];
                                                    function initClassLevels() {
                                                        var lvlSelect = document.getElementById("levelId");
                                                        if (lvlSelect && allClassLevels.length === 0) {
                                                            for (var i = 0; i < lvlSelect.options.length; i++) {
                                                                var o = lvlSelect.options[i];
                                                                if (o.value !== "") {
                                                                    allClassLevels.push({
                                                                        value: o.value,
                                                                        text: o.text,
                                                                        pos: o.getAttribute("data-pos") || "0"
                                                                    });
                                                                }
                                                            }
                                                        }
                                                    }
                                                    function filterClassLevels() {
                                                        initClassLevels();
                                                        var posSelect = document.getElementById("positionId");
                                                        var lvlSelect = document.getElementById("levelId");
                                                        if (!posSelect || !lvlSelect) return;
                                                        var selectedPos = posSelect.value;
                                                        var currentLvl = lvlSelect.value;
                                                        lvlSelect.innerHTML = "";
                                                        var defOpt = document.createElement("option");
                                                        defOpt.value = "";
                                                        defOpt.text = "— Tất cả cấp bậc —";
                                                        lvlSelect.appendChild(defOpt);

                                                        var matched = [];
                                                        if (!selectedPos || selectedPos === "") {
                                                            matched = allClassLevels.filter(function(item) {
                                                                return item.pos === "0";
                                                            });
                                                            if (matched.length === 0) {
                                                                matched = allClassLevels.slice(0, 6);
                                                            }
                                                        } else {
                                                            matched = allClassLevels.filter(function(item) {
                                                                return item.pos === selectedPos;
                                                            });
                                                            if (matched.length === 0) {
                                                                matched = allClassLevels.filter(function(item) {
                                                                    return item.pos === "0";
                                                                });
                                                            }
                                                        }

                                                        matched.forEach(function(item) {
                                                            var opt = document.createElement("option");
                                                            opt.value = item.value;
                                                            opt.text = item.text;
                                                            if (item.value === currentLvl) {
                                                                opt.selected = true;
                                                            }
                                                            lvlSelect.appendChild(opt);
                                                        });
                                                    }
                                                    document.addEventListener("DOMContentLoaded", function() {
                                                        initClassLevels();
                                                        filterClassLevels();
                                                    });
                                                </script>
                                                <jsp:include page="/views/common/footer.jsp" />