<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.TrainingClass,model.SmartCandidate" %>
<%
    TrainingClass trainingClass = (TrainingClass) request.getAttribute("trainingClass");
    List<SmartCandidate> candidates = (List<SmartCandidate>) request.getAttribute("candidates");
    request.setAttribute("pageTitle", "Gán nhân sự | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Gán Nhân Sự Vào Lớp</h1>
        <div class="topbar-actions">
            <% if (trainingClass != null) { %>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= trainingClass.getClassId() %>">Quay lại chi tiết lớp</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (trainingClass != null) { %>
        <div class="card">
            <div class="card-header">
                <h2><%= trainingClass.getClassName() %></h2>
                <span class="badge-count">Nhân sự chưa ghi danh: <%= candidates != null ? candidates.size() : 0 %> người</span>
            </div>
            <div class="card-body">
                <% if (trainingClass.getMentorId() == null) { %>
                <div class="alert alert-danger">Lớp chưa có mentor đứng lớp nên chưa thể ghép mentee. <a href="<%= request.getContextPath() %>/materials?action=classDetail&amp;id=<%= trainingClass.getClassId() %>">Chọn mentor tại chi tiết lớp</a>.</div>
                <% } else { %>
                <p><b>Mentor đứng lớp:</b> <%= trainingClass.getMentorName() %>. Nhân viên được ghi danh sẽ tự động được ghép làm mentee của mentor này.</p>
                <form method="post" action="<%= request.getContextPath() %>/materials">
                    <input type="hidden" name="action" value="enrollSubmit">
                    <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px">
                        <button type="button" class="btn btn-secondary" onclick="toggleSelectAll(this)">
                            Chọn tất cả
                        </button>
                        <button class="btn btn-primary">Ghi danh nhân sự đã chọn</button>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width:5%;text-align:center">
                                    <input type="checkbox" id="selectAllCheckbox" onclick="toggleAllCheckboxes(this)">
                                </th>
                                <th style="width:25%;text-align:left">Nhân sự</th>
                                <th style="width:25%;text-align:left">Phòng ban</th>
                                <th style="width:25%;text-align:left">Vị trí</th>
                                <th style="width:20%;text-align:left">Cấp bậc</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (candidates != null && !candidates.isEmpty()) {
                                for (SmartCandidate c : candidates) { %>
                            <tr>
                                <td style="text-align:center">
                                    <input class="user-select-chk" type="checkbox" name="userIds" value="<%= c.getUserId() %>">
                                </td>
                                <td>
                                    <div style="font-size:13px;font-weight:600"><%= c.getFullName() %></div>
                                    <div style="font-size:11.5px;color:#666;margin-top:2px"><%= c.getEmail() %></div>
                                </td>
                                <td style="font-size:12.5px"><%= c.getDepartmentName() != null ? c.getDepartmentName() : "-" %></td>
                                <td style="font-size:12.5px"><%= c.getPositionName() != null ? c.getPositionName() : "-" %></td>
                                <td style="font-size:12.5px"><%= c.getLevelName() != null ? c.getLevelName() : "-" %></td>
                            </tr>
                            <% } } else { %>
                            <tr>
                                <td colspan="5" style="text-align:center;padding:20px;color:#666;font-size:13px">Không còn nhân sự khả dụng để thêm vào lớp.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </form>
                <script>
                    function toggleAllCheckboxes(master) {
                        document.querySelectorAll('.user-select-chk').forEach(function (item) {
                            item.checked = master.checked;
                        });
                    }
                    function toggleSelectAll(btn) {
                        const checkboxes = document.querySelectorAll('.user-select-chk');
                        const anyUnchecked = Array.from(checkboxes).some(cb => !cb.checked);
                        checkboxes.forEach(cb => cb.checked = anyUnchecked);
                        const master = document.getElementById('selectAllCheckbox');
                        if (master) master.checked = anyUnchecked;
                        btn.textContent = anyUnchecked ? 'Bỏ chọn tất cả' : 'Chọn tất cả';
                    }
                </script>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
