<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Đánh Giá Mentee Hàng Tháng</h1>
        <div><a href="javascript:history.back()" class="btn btn-secondary">Quay lại</a></div>
    </div>

    <div class="content-body">
        <form action="<%= request.getContextPath() %>/mentors" method="POST" class="card" style="border: 1px solid #000; padding: 20px; max-width: 900px; margin: 0 auto;">

            <input type="hidden" name="action" value="saveEvaluation">
            <input type="hidden" name="assignmentId" value="<%= request.getAttribute("assignmentId") %>">
            
            <!-- ĐIỂM ĐÁNH GIÁ ĐỊNH LƯỢNG -->
            <div style="margin-bottom: 25px; background: #fff3e0; padding: 15px; border: 1px solid #ffb74d; border-radius: 4px;">
                <label style="font-weight: bold; font-size: 15px; display: block; margin-bottom: 8px;">
                    Điểm Đánh Giá Hiệu Suất / Năng Lực (Thang điểm 1 - 10) (*):
                </label>
                <div style="display: flex; align-items: center; gap: 15px;">
                    <input type="number" name="performanceScore" min="1" max="10" value="8" required class="form-control" style="width: 100px; font-size: 16px; font-weight: bold; text-align: center;">
                    <span style="font-size: 13px; color: #666;">(1-4: Chưa đạt yêu cầu | 5-6: Trung bình | 7-8: Khá, hoàn thành tốt task | 9-10: Xuất sắc)</span>
                </div>
            </div>

            <!-- PHẦN 1: PUBLIC (Mentee xem được - Non-anonymous Feedback) -->
            <div style="margin-bottom: 30px; border: 1px solid #90caf9; border-radius: 4px; padding: 15px; background: #fbfdff;">
                <h2 style="background: #e3f2fd; padding: 10px; border: 1px solid #64b5f6; font-size: 15px; margin: -15px -15px 15px -15px; color: #0d47a1;">
                    <i class="fa-solid fa-eye"></i> PHẦN 1: KẾT QUẢ CÔNG KHAI (Non-anonymous - Mentee có thể xem)
                </h2>
                <p style="font-size: 12.5px; color: #555; margin-bottom: 12px;">
                    Nội dung nhận xét về chuyên môn, thái độ học tập, kết quả task và hướng dẫn phát triển trực tiếp cho Mentee.
                </p>
                <div class="form-group">
                    <textarea name="publicFeedback" class="form-control" rows="5" style="width: 100%; font-size: 13.5px;" placeholder="Nhập nhận xét công khai gửi tới Mentee (ví dụ: Nắm vững kiến thức Java cơ bản, hoàn thành tốt bài test Onboarding...)" required></textarea>
                </div>
            </div>

            <!-- PHẦN 2: PRIVATE (Chỉ Mentor, HR, Manager xem - Anonymous / Nội bộ) -->
            <div style="margin-bottom: 20px; border: 1px solid #ef9a9a; border-radius: 4px; padding: 15px; background: #fffcfc;">
                <h2 style="background: #ffebee; padding: 10px; border: 1px solid #e57373; font-size: 15px; margin: -15px -15px 15px -15px; color: #b71c1c;">
                    <i class="fa-solid fa-user-shield"></i> PHẦN 2: ĐÁNH GIÁ NỘI BỘ (Anonymous / Private - Mentee KHÔNG nhìn thấy)
                </h2>
                <p style="font-size: 12.5px; color: #555; margin-bottom: 12px;">
                    Đánh giá khách quan dành riêng cho Quản lý (Manager) và Nhân sự (HR): tiềm năng phát triển, văn hóa làm việc và đề xuất ký hợp đồng chính thức.
                </p>
                <div class="form-group">
                    <textarea name="privateFeedback" class="form-control" rows="4" style="width: 100%; border: 1px solid #c62828; font-size: 13.5px;" placeholder="Nhập ghi chú nội bộ cho HR/Manager (ví dụ: Đề xuất qua thử việc sớm / Cần theo dõi thêm về kỷ luật giờ giấc...)"></textarea>
                </div>
            </div>

            <div style="text-align: center; border-top: 1px solid #eee; padding-top: 20px;">
                <button type="submit" class="btn btn-primary" style="padding: 10px 30px; font-size: 14px; font-weight: bold; cursor: pointer;">LƯU ĐÁNH GIÁ MENTEE</button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />