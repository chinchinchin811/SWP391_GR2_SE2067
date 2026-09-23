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
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= trainingClass.getClassId() %>">Quay lại chi tiết lớp</a>
        </div>
    </div>
    <div class="content-body">
        <div class="card">
            <div class="card-header">
                <h2><%= trainingClass.getClassName() %></h2>
                <span class="badge-count">Nhân sự chưa ghi danh: <%= candidates != null ? candidates.size() : 0 %> người</span>
            </div>
            <div class="card-body">
                <p style="font-size:12.5px;color:#555;margin-bottom:14px;line-height:1.6">
                    Nhân sự có điểm từ 60 trở lên là nhóm được hệ thống gợi ý.
                    Nút <strong>Chọn gợi ý</strong> sẽ tự động tích chọn nhóm này.
                </p>
                <form method="post" action="<%= request.getContextPath() %>/materials">
                    <input type="hidden" name="action" value="enrollSubmit">
                    <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px">
                        <button type="button" class="btn btn-secondary"
                                onclick="document.querySelectorAll('.smart-recommended').forEach(function(item){item.checked=true;})">
                            ✓ Chọn gợi ý
                        </button>
                        <button class="btn btn-primary">Ghi danh đã chọn</button>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width:4%;text-align:center"></th>
                                <th style="width:22%;text-align:center">Nhân sự</th>
                                <th style="width:32%;text-align:center">Phòng ban / Vị trí / Cấp bậc</th>
                                <th style="width:12%;text-align:center">Điểm</th>
                                <th style="text-align:center">Lý do</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (candidates != null && !candidates.isEmpty()) {
                                for (SmartCandidate c : candidates) {
                                    boolean recommended = c.getMatchScore() >= 60; %>
                            <tr style="<%= recommended ? "background:#fafafa" : "" %>">
                                <td style="text-align:center">
                                    <input class="<%= recommended ? "smart-recommended" : "" %>"
                                           type="checkbox" name="userIds" value="<%= c.getUserId() %>">
                                </td>
                                <td style="text-align:center">
                                    <div style="font-size:13px;font-weight:600"><%= c.getFullName() %></div>
                                    <div style="font-size:11.5px;color:#666;margin-top:2px"><%= c.getEmail() %></div>
                                </td>
                                <td style="text-align:center;font-size:12.5px"><%= c.getDepartmentName() %> / <%= c.getPositionName() %> / <%= c.getLevelName() %></td>
                                <td style="text-align:center">
                                    <span class="badge"><%= c.getMatchScore() %><%= recommended ? " ★" : "" %></span>
                                </td>
                                <td style="text-align:center;font-size:12.5px;color:#444"><%= c.getMatchReason() %></td>
                            </tr>
                            <% } } else { %>
                            <tr>
                                <td colspan="5" style="text-align:center;padding:20px;color:#666;font-size:13px">Không còn nhân sự phù hợp để gợi ý.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </form>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
