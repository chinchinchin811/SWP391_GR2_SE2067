<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<% User mentee = (User) request.getAttribute("mentee"); %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Hồ Sơ Chi Tiết Mentee</h1>
        <div><a href="javascript:history.back()" class="btn btn-secondary" style="border: 1px solid #000; padding: 5px 15px; text-decoration: none;">Quay lại</a></div>
    </div>

    <div class="content-body">
        <% if (mentee != null) { %>
        <div style="display: flex; gap: 20px;">
            <!-- Phần Thông tin chung -->
            <div class="card" style="flex: 1; border: 1px solid #000; padding: 20px;">
                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px;">Thông tin cá nhân & Công việc</h3>
                <p><b>Họ tên:</b> <%= mentee.getFullName() %></p>
                <p><b>Email:</b> <%= mentee.getEmail() != null ? mentee.getEmail() : "N/A" %></p>
                <p><b>Số điện thoại:</b> <%= mentee.getPhone() != null ? mentee.getPhone() : "N/A" %></p>
                <p><b>Vị trí chuyên môn:</b> <%= mentee.getPositionName() != null ? mentee.getPositionName() : "Chưa cập nhật" %></p>
                <p><b>Cấp bậc (Level):</b> <%= mentee.getLevelName() != null ? mentee.getLevelName() : "N/A" %></p>
                <p><b>Phòng ban:</b> <%= mentee.getDepartmentName() != null ? mentee.getDepartmentName() : "Chưa sắp xếp" %></p>
            </div>

            <!-- Phần Kỹ năng & Mục tiêu -->
            <div class="card" style="flex: 2; border: 1px solid #000; padding: 20px;">
                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px;">Mục tiêu phát triển</h3>
                <ul style="margin-bottom: 20px;">
                    <li>Nắm vững quy trình làm việc thực tế tại phòng ban.</li>
                    <li>Hoàn thành các bài test & đánh giá định kỳ từ Mentor.</li>
                    <li>Nâng cao kỹ năng chuyên môn theo lộ trình Onboarding.</li>
                </ul>

                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px;">Ghi chú & Theo dõi</h3>
                <p>Nhân viên mới cần Mentor đồng hành hướng dẫn kỹ thuật và tích hợp văn hóa doanh nghiệp.</p>
            </div>
        </div>
        <% } else { %>
            <div class="card" style="border: 1px solid #000; padding: 20px; text-align: center;">
                <p>Không tìm thấy thông tin chi tiết của Mentee này.</p>
            </div>
        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />