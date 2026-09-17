<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%
    List<User> newEmployees = (List<User>) request.getAttribute("newEmployees");
    List<User> mentors = (List<User>) request.getAttribute("mentors");
    String successMsg = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Ghep Noi Mentor & Mentee</h1>
    </div>

    <div class="content-body">
        <% if (successMsg != null) { %>
            <div style="padding: 10px; background: #fff; border: 1px solid #000; margin-bottom: 15px; font-weight: bold;">
                [THONG BAO] <%= successMsg %>
            </div>
        <% } %>

        <div class="card" style="max-width: 650px; margin: 0 auto; border: 1px solid #000; padding: 20px;">
            <div style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 20px;">
                <h2 style="margin: 0; font-size: 18px;">Form Ghep Noi</h2>
            </div>
            
            <form action="<%= request.getContextPath() %>/mentors" method="POST">
                <input type="hidden" name="action" value="assign">

                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-weight: bold; margin-bottom: 5px;">1. Chon Nhan vien moi (*):</label>
                    <select name="menteeId" style="width: 100%; padding: 8px; border: 1px solid #000;" required>
                        <option value="">-- Chon --</option>
                        <% if (newEmployees != null) {
                            for (User emp : newEmployees) { %>
                                <option value="<%= emp.getUserId() %>">
                                    <%= emp.getFullName() %> | Vi tri: <%= emp.getPositionName() != null ? emp.getPositionName() : "Chua xep" %> 
                                    (Rank: <%= emp.getLevelName() != null ? emp.getLevelName() : "Chua xep" %>)
                                </option>
                        <%  } } %>
                    </select>
                </div>

                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-weight: bold; margin-bottom: 5px;">2. Chon Mentor huong dan (*):</label>
                    <select name="mentorId" style="width: 100%; padding: 8px; border: 1px solid #000;" required>
                        <option value="">-- Chon Mentor --</option>
                        <% if (mentors != null) {
                            for (User m : mentors) { %>
                                <option value="<%= m.getUserId() %>">
                                    [Mentor] <%= m.getFullName() %> | <%= m.getPositionName() != null ? m.getPositionName() : "Chua ro" %> 
                                    (Rank: <%= m.getLevelName() != null ? m.getLevelName() : "Chua ro" %>)
                                </option>
                        <%  } } %>
                    </select>
                </div>

                <div style="text-align: right; margin-top: 20px;">
                    <button type="submit" style="padding: 10px 20px; background: #000; color: #fff; border: 1px solid #000; cursor: pointer; font-weight: bold;">
                        XAC NHAN
                    </button>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />