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
        <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= trainingClass.getClassId() %>">Quay lại chi tiết lớp</a>
    </div>
    <div class="content-body">
        <div class="card">
            <div class="card-header">
                <h2><%= trainingClass.getClassName() %></h2>
                <span>Danh sách tất cả nhân sự chưa ghi danh: <%= candidates != null ? candidates.size() : 0 %> người</span>
            </div>
            <div class="card-body">
                <p style="margin-bottom:10px">Nhân sự có điểm từ 60 trở lên là nhóm được hệ thống gợi ý. Nút chọn nhanh chỉ chọn nhóm này.</p>
                <form method="post" action="<%= request.getContextPath() %>/materials">
                    <input type="hidden" name="action" value="enrollSubmit">
                    <input type="hidden" name="classId" value="<%= trainingClass.getClassId() %>">
                    <div class="form-actions" style="margin-top:0">
                        <button type="button" class="btn btn-secondary" onclick="document.querySelectorAll('.smart-recommended').forEach(function(item){item.checked=true;})">Chọn tất cả nhân sự được gợi ý</button>
                        <button class="btn btn-primary">Ghi danh đã chọn</button>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th></th>
                                <th>Nhân sự</th>
                                <th>Phòng ban / Vị trí / Cấp bậc</th>
                                <th>Điểm</th>
                                <th>Lý do</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (candidates != null && !candidates.isEmpty()) { 
                                for (SmartCandidate c : candidates) { 
                                    boolean recommended = c.getMatchScore() >= 60; %>
                                <tr>
                                    <td><input class="<%= recommended ? "smart-recommended" : "" %>" type="checkbox" name="userIds" value="<%= c.getUserId() %>"></td>
                                    <td>
                                        <b><%= c.getFullName() %></b><br>
                                        <span style="font-size:11px;color:#555"><%= c.getEmail() %></span>
                                    </td>
                                    <td><%= c.getDepartmentName() %> / <%= c.getPositionName() %> / <%= c.getLevelName() %></td>
                                    <td><span class="badge"><%= c.getMatchScore() %><%= recommended ? " - Gợi ý" : "" %></span></td>
                                    <td><%= c.getMatchReason() %></td>
                                </tr>
                            <% } 
                            } else { %>
                                <tr><td colspan="5" style="text-align:center">Không còn nhân sự phù hợp để gợi ý.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </form>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
