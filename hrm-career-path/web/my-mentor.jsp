<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Mentor.MentorAssignment" %>
<%@ page import="model.Mentor.MentorEvaluation" %>
<%@ page import="java.util.List" %>
<% 
    MentorAssignment myMentor = (MentorAssignment) request.getAttribute("myMentor"); 
    List<MentorEvaluation> myEvaluations = (List<MentorEvaluation>) request.getAttribute("myEvaluations");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Mentor Hướng Dẫn Của Tôi</h1>
    </div>

    <div class="content-body">
        <div class="card" style="border: 1px solid #000; padding: 20px; max-width: 750px; margin-bottom: 25px;">
            <% if (myMentor != null) { %>
                <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-top: 0;">
                    <i class="fa-solid fa-user-tie"></i> Thông Tin Mentor Phụ Trách
                </h3>
                <p style="font-size: 16px;"><b>Họ tên Mentor:</b> <span style="color: #0056b3; font-weight: bold;"><%= myMentor.getMentorName() %></span></p>
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

        <%-- ĐÁNH GIÁ NĂNG LỰC TỪ MENTOR (NON-ANONYMOUS PROFESSIONAL ASSESSMENT REVIEW) --%>
        <% if (myMentor != null) { %>
        <div class="card" style="border: 1px solid #000; padding: 20px; max-width: 750px;">
            <h3 style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-top: 0; color: #0d47a1;">
                <i class="fa-solid fa-clipboard-check"></i> Đánh Giá Năng Lực &amp; Phản Hồi Từ Mentor (Non-anonymous Review)
            </h3>
            <% if (myEvaluations != null && !myEvaluations.isEmpty()) { 
                for (MentorEvaluation eval : myEvaluations) { %>
                <div style="border: 1px solid #90caf9; background: #fbfdff; padding: 15px; border-radius: 4px; margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                        <span style="font-weight: bold; font-size: 15px;">Điểm hiệu suất: <span style="color: #d32f2f; font-size: 18px;"><%= eval.getPerformanceScore() %></span> / 10</span>
                        <span class="badge" style="background: #e3f2fd; color: #0d47a1; border: 1px solid #90caf9; padding: 4px 8px; font-size: 12px;"><%= eval.getApprovalStatus() %></span>
                    </div>
                    <div style="font-size: 14px; line-height: 1.6; color: #333;">
                        <b>Nhận xét hướng dẫn chuyên môn:</b>
                        <p style="margin: 6px 0 0 0; white-space: pre-line; background: #fff; padding: 10px; border: 1px dashed #bbb; border-radius: 4px;">
                            <%= (eval.getPublicFeedback() != null && !eval.getPublicFeedback().trim().isEmpty()) ? eval.getPublicFeedback() : eval.getFeedback() %>
                        </p>
                    </div>
                </div>
            <%  } 
               } else { %>
                <p style="font-size: 13.5px; color: #666; font-style: italic;">Chưa có phiếu đánh giá định kỳ nào từ Mentor.</p>
            <% } %>
        </div>
        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
