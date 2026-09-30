<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Mentor.MentorAssignment" %>
<% MentorAssignment myMentor = (MentorAssignment) request.getAttribute("myMentor"); %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Mentor Hướng Dẫn Của Tôi</h1>
    </div>

    <div class="content-body">
        <div class="card" style="border: 1px solid #000; padding: 20px; max-width: 600px;">
            <% if (myMentor != null) { %>
                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-top: 0;">Thông Tin Mentor Phụ Trách</h3>
                <p style="font-size: 16px;"><b>Họ tên Mentor:</b> <span style="color: #0056b3;"><%= myMentor.getMentorName() %></span></p>
                <p><b>Chuyên môn:</b> <%= myMentor.getPositionName() != null ? myMentor.getPositionName() : "Chưa cập nhật" %></p>
                <p><b>Phòng ban:</b> <%= myMentor.getDepartmentName() != null ? myMentor.getDepartmentName() : "N/A" %></p>
                <p><b>Trạng thái:</b> <span style="background: #e8f5e9; padding: 3px 8px; border: 1px solid #000; font-size: 12px; font-weight: bold;">Đang đồng hành</span></p>
            <% } else { %>
                <div style="text-align: center; padding: 20px;">
                    <p style="font-size: 15px; color: #666;">Hiện tại bạn chưa được ghép nối với Mentor nào.</p>
                    <p style="font-size: 13px; color: #888;">Vui lòng liên hệ bộ phận HR để được hỗ trợ ghép nối Mentor.</p>
                </div>
            <% } %>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />