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
                            <label>Phòng ban mục tiêu</label>
                            <select class="form-control" name="departmentId">
                                <option value="">— Tất cả —</option>
                                <% if (departments != null) for (Department d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>"><%= d.getDepartmentName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Vị trí mục tiêu</label>
                            <select class="form-control" name="positionId">
                                <option value="">— Tất cả —</option>
                                <% if (positions != null) for (Position p : positions) { %>
                                <option value="<%= p.getPositionId() %>"><%= p.getPositionName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Cấp bậc mục tiêu</label>
                            <select class="form-control" name="levelId">
                                <option value="">— Tất cả —</option>
                                <% if (levels != null) for (JobLevel l : levels) { %>
                                <option value="<%= l.getLevelId() %>"><%= l.getLevelName() %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Mentor</label>
                            <select class="form-control" name="mentorId">
                                <option value="">— Chưa phân công —</option>
                                <% if (mentors != null) for (User u : mentors) { %>
                                <option value="<%= u.getUserId() %>"><%= u.getFullName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Ngày bắt đầu <span style="color:#c00">*</span></label>
                            <input required class="form-control" type="date" name="startDate" id="startDate">
                        </div>
                        <div class="form-group">
                            <label>Ngày kết thúc</label>
                            <input class="form-control" type="date" name="endDate" id="endDate">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Học liệu trong lớp</label>
                        <div style="max-height:220px;overflow:auto;border:1px solid #000;padding:10px">
                            <% if (materials != null) for (LearningMaterial m : materials) { %>
                            <label style="display:flex;align-items:baseline;gap:8px;padding:5px 0;cursor:pointer;font-size:13px">
                                <input type="checkbox" name="materialIds" value="<%= m.getMaterialId() %>">
                                <span><strong><%= m.getTitle() %></strong>
                                    <span style="color:#666;font-size:11.5px">(<%= m.getMaterialType() %>, <%= m.getDurationMinutes() %> phút)</span>
                                </span>
                            </label>
                            <% } %>
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
    var today = new Date().toISOString().slice(0, 10),
        start = document.getElementById('startDate'),
        end   = document.getElementById('endDate');
    start.min = today;
    end.min   = today;
    start.addEventListener('change', function(){
        end.min = start.value || today;
        if (end.value && end.value < start.value) end.value = '';
    });
    document.getElementById('classForm').addEventListener('submit', function(e){
        if (end.value && end.value < start.value){
            e.preventDefault();
            alert('Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.');
        }
    });
})();
</script>
<jsp:include page="/views/common/footer.jsp" />
