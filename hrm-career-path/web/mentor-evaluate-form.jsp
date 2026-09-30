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
            
            <!-- PHẦN 1: PUBLIC (Mentee xem được) -->
            <div style="margin-bottom: 30px;">
                <h2 style="background: #e3f2fd; padding: 10px; border: 1px solid #000; font-size: 16px; margin-bottom: 15px;">
                    PHẦN 1: KẾT QUẢ CÔNG KHAI (Mentee có thể xem)
                </h2>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold;">1. Năng lực chuyên môn & Chất lượng công việc:</label>
                    <p style="font-size: 12px; color: #555;">Khả năng nắm bắt, tốc độ hoàn thành, độ chính xác của task.</p>
                    <textarea class="form-control" rows="3" style="width: 100%;"></textarea>
                </div>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold;">2. Sự chủ động & Khả năng học hỏi:</label>
                    <textarea class="form-control" rows="3" style="width: 100%;"></textarea>
                </div>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold;">3. Kỹ năng giao tiếp & Làm việc nhóm:</label>
                    <textarea class="form-control" rows="3" style="width: 100%;"></textarea>
                </div>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold;">4. Bảng KPI / OKR - Kết quả Task (Đạt/Chưa đạt):</label>
                    <textarea class="form-control" rows="2" style="width: 100%;"></textarea>
                </div>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold;">5. Feedback trực diện (1-on-1):</label>
                    <textarea class="form-control" rows="2" style="width: 100%;"></textarea>
                </div>
            </div>

            <!-- PHẦN 2: PRIVATE (Chỉ Mentor, HR, Manager xem) -->
            <div style="margin-bottom: 20px;">
                <h2 style="background: #ffebee; padding: 10px; border: 1px solid #000; font-size: 16px; margin-bottom: 15px;">
                    PHẦN 2: ĐÁNH GIÁ NỘI BỘ (Mentee KHÔNG nhìn thấy)
                </h2>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold; color: #c62828;">1. Thái độ ẩn & Văn hóa ngầm:</label>
                    <p style="font-size: 12px; color: #555;">Ứng xử khi áp lực, tinh thần hợp tác thực tế đằng sau vỏ bọc.</p>
                    <textarea class="form-control" rows="3" style="width: 100%; border: 1px solid #c62828;"></textarea>
                </div>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold; color: #c62828;">2. Tiềm năng phát triển (Potential) & Rủi ro:</label>
                    <textarea class="form-control" rows="3" style="width: 100%; border: 1px solid #c62828;"></textarea>
                </div>

                <div class="form-group" style="margin-bottom: 15px;">
                    <label style="font-weight: bold; color: #c62828;">3. Ghi chú nội bộ (HR/Manager):</label>
                    <p style="font-size: 12px; color: #555;">Mức lương kỳ vọng, độ phức tạp quản lý, sự cố ghi nhận.</p>
                    <textarea class="form-control" rows="3" style="width: 100%; border: 1px solid #c62828;"></textarea>
                </div>
            </div>

            <div style="text-align: center; border-top: 1px solid #000; padding-top: 20px;">
                <button type="submit" style="padding: 10px 30px; background: #000; color: #fff; font-weight: bold; cursor: pointer;">LƯU ĐÁNH GIÁ</button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />