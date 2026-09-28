<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Mentor.MentorAssignment" %>
<%
    List<User> newEmployees = (List<User>) request.getAttribute("newEmployees");
    List<User> mentors = (List<User>) request.getAttribute("mentors");
    List<MentorAssignment> assignments = (List<MentorAssignment>) request.getAttribute("assignments");
    String successMsg = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Quan Ly & Ghep Noi Mentor - Mentee</h1>
    </div>

    <div class="content-body">
        <% if (successMsg != null) { %>
        <div style="padding: 10px; background: #d4edda; color: #155724; border: 1px solid #c3e6cb; margin-bottom: 15px; font-weight: bold;">
            [THONG BAO] <%= successMsg %>
        </div>
        <% } %>

        <div style="display: flex; gap: 20px; align-items: flex-start;">
            
            <!-- CỘT TRÁI: DANH SÁCH GHÉP NỐI -->
            <div class="card" style="flex: 2; border: 1px solid #000; padding: 20px;">
                <div style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 15px;">
                    <h2 style="margin: 0; font-size: 18px;">Danh Sach Dang Ghep Noi</h2>
                </div>
                <table class="data-table" style="width: 100%; border-collapse: collapse; border: 1px solid #000;">
                    <thead>
                        <tr style="background: #f0f0f0; border-bottom: 1px solid #000; text-align: left;">
                            <th style="padding: 8px; border: 1px solid #000;">Mentee</th>
                            <th style="padding: 8px; border: 1px solid #000;">Mentor</th>
                            <th style="padding: 8px; border: 1px solid #000;">Chuyên môn</th>
                            <th style="padding: 8px; border: 1px solid #000;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (assignments != null && !assignments.isEmpty()) { 
                            for (MentorAssignment a : assignments) { %>
                            <tr>
                                <td style="padding: 8px; border: 1px solid #000;">
                                    <b><%= a.getMenteeName() %></b><br>
                                    <span style="font-size: 11px; color: #555;"><%= a.getMenteeLevel() != null ? a.getMenteeLevel() : "" %></span>
                                </td>
                                <td style="padding: 8px; border: 1px solid #000;"><%= a.getMentorName() %></td>
                                <td style="padding: 8px; border: 1px solid #000;"><%= a.getPositionName() != null ? a.getPositionName() : "" %></td>
                                <td style="padding: 8px; border: 1px solid #000; text-align: center;">
                                    <a href="<%= request.getContextPath() %>/mentors?action=menteeDetail&id=<%= a.getMenteeId() %>" class="btn btn-sm btn-secondary" style="font-size: 11px;">Hồ sơ</a>
                                    <a href="<%= request.getContextPath() %>/mentors?action=evaluateForm&assignmentId=<%= a.getAssignmentId() %>" class="btn btn-sm btn-primary" style="font-size: 11px;">Đánh giá</a>
                                </td>
                            </tr>
                        <%  } 
                        } else { %>
                            <tr><td colspan="4" style="padding: 15px; text-align: center; border: 1px solid #000;">Chưa có dữ liệu ghép nối.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- CỘT PHẢI: FORM GHÉP NỐI (Giữ nguyên form cũ của bạn) -->
            <div class="card" style="flex: 1; border: 1px solid #000; padding: 20px;">
                <div style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 20px;">
                    <h2 style="margin: 0; font-size: 18px;">Form Ghep Noi Moi</h2>
                </div>

                <form action="<%= request.getContextPath() %>/mentors" method="POST">
                    <input type="hidden" name="action" value="assign">
                    
                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: bold; display: block; margin-bottom: 5px;">1. Chon Nhan vien moi (*):</label>
                        <select id="menteeSelect" name="menteeId" onchange="filterMentorsByPosition()" required style="width: 100%; padding: 8px;">
                            <option value="">-- Chọn Nhân viên --</option>
                            <% if (newEmployees != null) {
                                for(User mentee : newEmployees) { 
                                    String posName = mentee.getPositionName() != null ? mentee.getPositionName().trim() : "";
                            %>
                            <option value="<%= mentee.getUserId() %>" 
                                    data-position-id="<%= mentee.getPositionId() %>"
                                    data-position-name="<%= posName %>">
                                <%= mentee.getFullName() %> - <%= mentee.getLevelName() %> (<%= !posName.isEmpty() ? posName : "Chưa xếp vị trí" %>)
                            </option>
                            <%  } 
                               } %>
                        </select>
                    </div>
                   
                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: bold; display: block; margin-bottom: 5px;">2. Chon Mentor huong dan (*):</label>
                        <select id="mentorSelect" name="mentorId" required style="width: 100%; padding: 8px;">
                            <option value="">-- Vui lòng chọn Nhân viên trước --</option>
                        </select>
                    </div>

                    <div style="text-align: right; margin-top: 20px;">
                        <button type="submit" style="padding: 10px 20px; background: #000; color: #fff; border: 1px solid #000; cursor: pointer; font-weight: bold;">
                            XAC NHAN GHEP NOI
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<!-- GIỮ NGUYÊN ĐOẠN SCRIPT FILTER MENTOR CỦA BẠN Ở ĐÂY -->
<script>
    var allMentors = [
        <% if (mentors != null) {
            for (int i = 0; i < mentors.size(); i++) {
                User m = mentors.get(i);
                String mPosName = m.getPositionName() != null ? m.getPositionName().trim() : "";
        %>
        { id: <%= m.getUserId() %>, name: "<%= m.getFullName().replace("\"", "\\\"") %>", positionId: <%= m.getPositionId() %>, positionName: "<%= mPosName.replace("\"", "\\\"") %>" }<%= (i < mentors.size() - 1) ? "," : "" %>
        <%  } } %>
    ];
   
    function filterMentorsByPosition() {
        var menteeSelect = document.getElementById("menteeSelect");
        var mentorSelect = document.getElementById("mentorSelect");
        var selectedOption = menteeSelect.options[menteeSelect.selectedIndex];
        var menteePosId = selectedOption.getAttribute("data-position-id");
        var menteePosName = selectedOption.getAttribute("data-position-name");

        mentorSelect.innerHTML = "";

        if (!menteeSelect.value) {
            var defaultOpt = document.createElement("option");
            defaultOpt.value = "";
            defaultOpt.textContent = "-- Vui lòng chọn Nhân viên trước --";
            mentorSelect.appendChild(defaultOpt);
            return;
        }

        var count = 0;
        var defaultOpt = document.createElement("option");
        defaultOpt.value = "";
        defaultOpt.textContent = "-- Chọn Mentor --";
        mentorSelect.appendChild(defaultOpt);
        
        var cleanMenteePosName = menteePosName ? menteePosName.trim().toLowerCase() : "";

        allMentors.forEach(function(mentor) {
            var isMatch = false;
            var cleanMentorPosName = mentor.positionName ? mentor.positionName.trim().toLowerCase() : "";
            if (menteePosId && menteePosId !== "0" && Number(mentor.positionId) === Number(menteePosId)) {
                isMatch = true;
            } else if (cleanMenteePosName !== "" && cleanMentorPosName === cleanMenteePosName) {
                isMatch = true;
            }

            if (isMatch) {
                var opt = document.createElement("option");
                opt.value = mentor.id;
                opt.textContent = mentor.name + " (" + mentor.positionName + ")";
                mentorSelect.appendChild(opt);
                count++;
            }
        });

        if (count === 0) {
            var emptyOpt = document.createElement("option");
            emptyOpt.value = "";
            emptyOpt.textContent = "-- Không có Mentor cùng chuyên môn (" + menteePosName + ") --";
            mentorSelect.appendChild(emptyOpt);
        }
    }
</script>

<jsp:include page="/views/common/footer.jsp" />