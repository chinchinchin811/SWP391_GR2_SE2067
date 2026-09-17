<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%
    request.setAttribute("pageTitle", "Ghep Noi Mentor | HRM");
    List<User> newEmployees = (List<User>) request.getAttribute("newEmployees");
    List<User> mentors = (List<User>) request.getAttribute("mentors");
    String successMsg = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Ghep Noi Mentor - Nhan Vien Moi (Theo Chuyen Mon)</h1>
    </div>

    <div class="content-body">
        <% if (successMsg != null) { %>
            <div class="alert alert-success" style="padding: 10px; background: #e8f5e9; border: 1px solid #4caf50; color: #2e7d32; margin-bottom: 15px;">
                <%= successMsg %>
            </div>
        <% } %>

        <div class="card" style="max-width: 650px; margin: 0 auto; border: 1px solid #000; background: #fff; padding: 20px;">
            <div class="card-header" style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 20px;">
                <h2 style="margin: 0; font-size: 18px;">Thiet Lap Cap Mentor - Mentee</h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/mentors" method="POST">
                    <input type="hidden" name="action" value="assign">

                    <div class="form-group" style="margin-bottom: 15px;">
                        <label for="menteeId" style="display: block; font-weight: bold; margin-bottom: 5px;">1. Chon Nhan vien moi (Mentee) (*):</label>
                        <select id="menteeId" name="menteeId" class="form-control" style="width: 100%; padding: 8px; border: 1px solid #000;" required>
                            <option value="">-- Chon Nhan Vien Moi --</option>
                            <% if (newEmployees != null && !newEmployees.isEmpty()) {
                                for (User emp : newEmployees) { %>
                                    <option value="<%= emp.getUserId() %>">
                                        <%= emp.getFullName() %> | Vi tri: <%= emp.getPositionName() != null ? emp.getPositionName() : "Chua xep" %> (<%= emp.getDepartmentName() != null ? emp.getDepartmentName() : "N/A" %>)
                                    </option>
                            <%  } 
                            } else { %>
                                <option value="" disabled>Khong co nhan vien moi nao can ghep mentor</option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label for="mentorId" style="display: block; font-weight: bold; margin-bottom: 5px;">2. Chon Mentor cung Chuyen mon (*):</label>
                        <select id="mentorId" name="mentorId" class="form-control" style="width: 100%; padding: 8px; border: 1px solid #000;" required>
                            <option value="">-- Chon Mentor --</option>
                            <% if (mentors != null && !mentors.isEmpty()) {
                                for (User m : mentors) { %>
                                    <option value="<%= m.getUserId() %>">
                                        [Mentor] <%= m.getFullName() %> | Chuyen mon: <%= m.getPositionName() != null ? m.getPositionName() : "N/A" %> (<%= m.getDepartmentName() != null ? m.getDepartmentName() : "N/A" %>)
                                    </option>
                            <%  } 
                            } %>
                        </select>
                    </div>

                    <div class="form-actions" style="text-align: right;">
                        <button type="submit" class="btn btn-primary" style="padding: 8px 16px; background: #000; color: #fff; border: 1px solid #000; cursor: pointer;">Xac Nhan Ghep Mentor</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />