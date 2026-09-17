<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.JobLevel" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User emp = (User) request.getAttribute("employee");
    request.setAttribute("pageTitle", "Dieu chuyen vi tri | HRM");

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    List<JobLevel> jobLevels = (List<JobLevel>) request.getAttribute("jobLevels");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Dieu Chuyen Vi Tri & Thang Cap</h1>
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

        <div class="card" style="max-width: 700px; margin: 0 auto;">
            <div class="card-header">
                <h2>Dieu Chuyen Phong Ban / Doi Chuyen Mon / Thang Chuc</h2>
            </div>
            <div class="card-body">
                <!-- Thong tin hien tai -->
                <div style="background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 12px; margin-bottom: 20px; font-size: 13px;">
                    <div><b>Nhan vien:</b> <%= emp.getFullName() %> (Username: <%= emp.getUsername() %>)</div>
                    <div style="margin-top: 5px;">
                        Phong ban hien tai: <b><%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chua co" %></b> | 
                        Vi tri hien tai: <b><%= emp.getPositionName() != null ? emp.getPositionName() : "Chua co" %></b> | 
                        Cap bac: <b><%= emp.getLevelName() != null ? emp.getLevelName() : "Chua co" %></b>
                    </div>
                </div>

                <form action="<%= request.getContextPath() %>/employees" method="POST">
                    <input type="hidden" name="action" value="assign">
                    <input type="hidden" name="userId" value="<%= emp.getUserId() %>">

                    <div class="form-group">
                        <label for="changeType">Loai thay doi (*):</label>
                        <select id="changeType" name="changeType" class="form-control" required>
                            <option value="ROLE_CHANGE">Chuyen doi chuyen mon/vi tri moi (Can ghep Mentor chuyen mon)</option>
                            <option value="PROMOTION">Thang cap bac / Len chuc (Promotion)</option>
                            <option value="DEPARTMENT_TRANSFER">Luan chuyen phong ban</option>
                        </select>
                        <small style="color: #7f8c8d; display: block; margin-top: 3px;">
                            He thong se tu dong ghi nhan lich su de xac dinh can ghep Mentor va lam bai thi danh gia nang luc.
                        </small>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="departmentId">Phong ban moi:</label>
                            <select id="departmentId" name="departmentId" class="form-control">
                                <option value="0">-- Giu nguyen hoac Chua phan --</option>
                                <%
                                    if (departments != null) {
                                        for (Department d : departments) {
                                            boolean isSel = (emp.getDepartmentId() != null && emp.getDepartmentId().equals(d.getDepartmentId()));
                                %>
                                    <option value="<%= d.getDepartmentId() %>" <%= isSel ? "selected" : "" %>><%= d.getDepartmentName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="positionId">Vi tri chuyen mon moi:</label>
                            <select id="positionId" name="positionId" class="form-control">
                                <option value="0">-- Giu nguyen hoac Chua phan --</option>
                                <%
                                    if (positions != null) {
                                        for (Position p : positions) {
                                            boolean isSel = (emp.getPositionId() != null && emp.getPositionId().equals(p.getPositionId()));
                                %>
                                    <option value="<%= p.getPositionId() %>" <%= isSel ? "selected" : "" %>><%= p.getPositionName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="levelId">Cap bac moi:</label>
                            <select id="levelId" name="levelId" class="form-control">
                                <option value="0">-- Giu nguyen hoac Chua phan --</option>
                                <%
                                    if (jobLevels != null) {
                                        for (JobLevel lvl : jobLevels) {
                                            boolean isSel = (emp.getLevelId() != null && emp.getLevelId().equals(lvl.getLevelId()));
                                %>
                                    <option value="<%= lvl.getLevelId() %>" <%= isSel ? "selected" : "" %>><%= lvl.getLevelName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="notes">Ly do / Ghi chu quyet dinh:</label>
                        <textarea id="notes" name="notes" class="form-control" rows="3" 
                                  placeholder="Ghi chu ly do thuyen chuyen hoac thang chuc..."></textarea>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/employees" class="btn btn-secondary">Huy</a>
                        <button type="submit" class="btn btn-primary">
                            Xac Nhan Dieu Chuyen & Luu Lich Su
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
