<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.*" %>
<%
    List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("materials");
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
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Quay lại danh sách</a>
        </div>
    </div>
    <div class="content-body">
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
        <% } %>

        <div class="card" style="max-width:920px;margin:0 auto">
            <div class="card-header">
                <h2>Thông Tin Lớp Đào Tạo</h2>
            </div>
            <div class="card-body">
                <form method="post" action="<%= request.getContextPath() %>/materials" id="classForm">
                    <input type="hidden" name="action" value="saveClass">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Mã lớp <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="classCode" placeholder="VD: DEV-FRESHER-2026">
                        </div>
                        <div class="form-group">
                            <label>Tên lớp <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="className">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Mô tả</label>
                        <textarea class="form-control" rows="3" name="description"></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Vị trí mục tiêu</label>
                            <select class="form-control" name="positionId">
                                <option value="">— Tất cả vị trí —</option>
                                <% if (positions != null) {
                                    for (Position p : positions) { %>
                                <option value="<%= p.getPositionId() %>"><%= p.getPositionName() %></option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Cấp bậc mục tiêu</label>
                            <select class="form-control" name="levelId">
                                <option value="">— Tất cả cấp bậc —</option>
                                <% if (levels != null) {
                                    for (JobLevel l : levels) { %>
                                <option value="<%= l.getLevelId() %>"><%= l.getLevelName() %></option>
                                <% } } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Mentor</label>
                            <select class="form-control" name="mentorId">
                                <option value="">— Chưa phân công —</option>
                                <% if (mentors != null) {
                                    for (User u : mentors) { %>
                                <option value="<%= u.getUserId() %>"><%= u.getFullName() %></option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Ngày bắt đầu <span style="color:#c00">*</span></label>
                            <input required class="form-control" type="date" name="startDate" id="startDate">
                        </div>
                        <div class="form-group">
                            <label>Ngày kết thúc <span style="color:#c00">*</span></label>
                            <input required class="form-control" type="date" name="endDate" id="endDate">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Học liệu trong lớp</label>
                        <div style="max-height:220px;overflow:auto;border:1px solid #000;padding:10px">
                            <% if (materials != null) {
                                for (LearningMaterial m : materials) { %>
                            <label style="display:flex;align-items:baseline;gap:8px;padding:5px 0;cursor:pointer;font-size:13px">
                                <input type="checkbox" name="materialIds" value="<%= m.getMaterialId() %>">
                                <span><strong><%= m.getTitle() %></strong>
                                    <span style="color:#666;font-size:11.5px">(<%= m.getMaterialType() %>, <%= m.getDurationMinutes() %> phút)</span>
                                </span>
                            </label>
                            <% } } %>
                        </div>
                    </div>

                    <input type="hidden" name="status" value="OPEN">
                    <div class="form-actions">
                        <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classList">Hủy</a>
                        <button class="btn btn-primary">Mở lớp</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>
<script>
(function(){
    var start = document.getElementById('startDate'),
        end   = document.getElementById('endDate');

    function formatDate(d) {
        var year = d.getFullYear();
        var month = ('0' + (d.getMonth() + 1)).slice(-2);
        var day = ('0' + d.getDate()).slice(-2);
        return year + '-' + month + '-' + day;
    }

    function addDays(dateStr, days) {
        if (!dateStr) return '';
        var parts = dateStr.split('-');
        if (parts.length !== 3) return '';
        var d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
        d.setDate(d.getDate() + days);
        return formatDate(d);
    }

    var todayStr = formatDate(new Date());
    start.min = todayStr;

    start.addEventListener('change', function(){
        if (start.value) {
            var minEnd = addDays(start.value, 1);
            end.min = minEnd;
            if (end.value && end.value < minEnd) {
                end.value = minEnd;
            }
        }
    });

    document.getElementById('classForm').addEventListener('submit', function(e){
        if (!start.value) {
            e.preventDefault();
            alert('Vui lòng chọn ngày bắt đầu.');
            start.focus();
            return false;
        }
        if (!end.value) {
            e.preventDefault();
            alert('Vui lòng chọn ngày kết thúc.');
            end.focus();
            return false;
        }
        var minEnd = addDays(start.value, 1);
        if (end.value < minEnd) {
            e.preventDefault();
            alert('Ngày kết thúc phải sau ngày bắt đầu ít nhất 1 ngày (tối thiểu là từ ngày ' + minEnd + ').');
            end.focus();
            return false;
        }
    });
})();
</script>
<jsp:include page="/views/common/footer.jsp" />
