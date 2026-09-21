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
        <div style="padding: 10px; background: #d4edda; color: #155724; border: 1px solid #c3e6cb; margin-bottom: 15px; font-weight: bold;">
            [THONG BAO] <%= successMsg %>
        </div>
        <% } %>

        <div class="card" style="max-width: 650px; margin: 0 auto; border: 1px solid #000; padding: 20px;">
            <div style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 20px;">
                <h2 style="margin: 0; font-size: 18px;">Form Ghep Noi</h2>
            </div>

            <form action="<%= request.getContextPath() %>/mentors" method="POST">
                <input type="hidden" name="action" value="assign">

                <!-- 1. CHỌN NHÂN VIÊN MỚI -->
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

                <!-- 2. CHỌN MENTOR HƯỚNG DẪN -->
                <div style="margin-bottom: 15px;">
                    <label style="font-weight: bold; display: block; margin-bottom: 5px;">2. Chon Mentor huong dan (*):</label>
                    <select id="mentorSelect" name="mentorId" required style="width: 100%; padding: 8px;">
                        <option value="">-- Vui lòng chọn Nhân viên trước --</option>
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

<script>
    // 1. Chuyển danh sách Mentor từ Java sang JS và loại bỏ khoảng trắng thừa
    var allMentors = [
        <% if (mentors != null) {
            for (int i = 0; i < mentors.size(); i++) {
                User m = mentors.get(i);
                String mPosName = m.getPositionName() != null ? m.getPositionName().trim() : "";
        %>
        {
            id: <%= m.getUserId() %>,
            name: "<%= m.getFullName().replace("\"", "\\\"") %>",
            positionId: <%= m.getPositionId() %>,
            positionName: "<%= mPosName.replace("\"", "\\\"") %>"
        }<%= (i < mentors.size() - 1) ? "," : "" %>
        <%  } 
           } %>
    ];

    // 2. Hàm lọc Mentor linh hoạt
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

        // Chuẩn hóa tên vị trí của mentee về dạng chữ thường để so sánh
        var cleanMenteePosName = menteePosName ? menteePosName.trim().toLowerCase() : "";

        allMentors.forEach(function(mentor) {
            var isMatch = false;
            var cleanMentorPosName = mentor.positionName ? mentor.positionName.trim().toLowerCase() : "";

            // Kiểm tra khớp ID vị trí HOẶC khớp tên vị trí (không phân biệt hoa thường)
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
            mentorSelect.innerHTML = "";
            var emptyOpt = document.createElement("option");
            emptyOpt.value = "";
            emptyOpt.textContent = "-- Không có Mentor cùng chuyên môn (" + menteePosName + ") --";
            mentorSelect.appendChild(emptyOpt);
        }
    }
</script>

<jsp:include page="/views/common/footer.jsp" />