<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Ho So Chi Tiet Mentee</h1>
        <div><a href="javascript:history.back()" class="btn btn-secondary">Quay lại</a></div>
    </div>

    <div class="content-body">
        <div style="display: flex; gap: 20px;">
            <!-- Phần Thông tin chung -->
            <div class="card" style="flex: 1; border: 1px solid #000; padding: 20px;">
                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px;">Thông tin cá nhân & Công việc</h3>
                <p><b>Họ tên:</b> Nguyễn Văn Mentee</p>
                <p><b>Vị trí (Title):</b> Fresher Java Developer</p>
                <p><b>Phòng ban:</b> Khối Công Nghệ Thông Tin</p>
                <p><b>Thời gian làm việc:</b> 2 tháng (Từ 01/08/2026)</p>
            </div>

            <!-- Phần Kỹ năng & Mục tiêu -->
            <div class="card" style="flex: 2; border: 1px solid #000; padding: 20px;">
                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px;">Mục tiêu phát triển</h3>
                <ul style="margin-bottom: 20px;">
                    <li>Cải thiện kỹ năng thiết kế cơ sở dữ liệu và tối ưu SQL.</li>
                    <li>Định hướng trở thành Backend Developer độc lập sau 6 tháng.</li>
                    <li>Lý do tham gia: Mong muốn được học hỏi kinh nghiệm thực chiến từ dự án thật.</li>
                </ul>

                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px;">Kỹ năng & Kinh nghiệm (CV Tóm tắt)</h3>
                <ul style="margin-bottom: 10px;">
                    <li><b>Kinh nghiệm:</b> Đã từng làm đồ án Spring Boot tại trường Đại học.</li>
                    <li><b>Điểm mạnh:</b> Nắm chắc lý thuyết OOP, tự học công nghệ mới nhanh.</li>
                    <li><b>Điểm yếu:</b> Thiếu kinh nghiệm làm việc nhóm bằng Git, chưa quen môi trường Agile/Scrum.</li>
                </ul>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />