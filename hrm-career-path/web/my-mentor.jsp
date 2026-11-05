<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Mentor.MentorAssignment" %>
<%@ page import="model.Mentor.MentorEvaluation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<% 
    request.setAttribute("pageTitle", "Mentor Hướng Dẫn Của Tôi | CPMS");
    MentorAssignment myMentor = (MentorAssignment) request.getAttribute("myMentor"); 
    List<MentorEvaluation> myEvaluations = (List<MentorEvaluation>) request.getAttribute("myEvaluations");
   
    List<MentorEvaluation> approvedEvaluations = new ArrayList<>();
    if (myEvaluations != null) {
        for (MentorEvaluation e : myEvaluations) {
            if ("APPROVED".equalsIgnoreCase(e.getApprovalStatus())) {
                approvedEvaluations.add(e);
            }
        }
    }
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Mentor Hướng Dẫn Của Tôi</h1>
    </div>

    <div class="content-body" style="max-width: 860px;">
        <%-- THÔNG TIN MENTOR --%>
        <div class="card" style="margin-bottom: 24px;">
            <div class="card-header" style="border-bottom: 1px solid var(--border-color); padding: 16px 20px;">
                <h3 style="margin: 0; font-size: 16px; font-weight: 600; display: flex; align-items: center; gap: 8px; color: #1e293b;">
                    <i class="fa-solid fa-user-tie" style="color: var(--primary);"></i> Thông Tin Mentor Phụ Trách
                </h3>
            </div>
            <div class="card-body" style="padding: 20px;">
                <% if (myMentor != null) { %>
                <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 18px;">
                    <div style="width: 52px; height: 52px; border-radius: 50%; background: rgba(79, 70, 229, 0.1); color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 24px;">
                        <i class="fa-solid fa-user-tie"></i>
                    </div>
                    <div>
                        <div style="font-size: 12px; text-transform: uppercase; color: var(--text-secondary); font-weight: 600; letter-spacing: 0.5px;">Mentor Hướng Dẫn</div>
                        <div style="font-size: 18px; font-weight: 700; color: #1e293b;"><%= myMentor.getMentorName() %></div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px; background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid var(--border-color);">
                    <div>
                        <span style="font-size: 12.5px; color: var(--text-secondary); display: block;">Chuyên môn &amp; Vị trí:</span>
                        <strong style="font-size: 14px; color: #1e293b;"><%= myMentor.getPositionName() != null ? myMentor.getPositionName() : "Chưa cập nhật" %></strong>
                    </div>
                    <div>
                        <span style="font-size: 12.5px; color: var(--text-secondary); display: block;">Phòng ban:</span>
                        <strong style="font-size: 14px; color: #1e293b;"><%= myMentor.getDepartmentName() != null ? myMentor.getDepartmentName() : "N/A" %></strong>
                    </div>
                    <div>
                        <span style="font-size: 12.5px; color: var(--text-secondary); display: block;">Trạng thái ghép nối:</span>
                        <span class="badge badge-status-active" style="margin-top: 2px;">
                            <i class="fa-solid fa-circle-check"></i> Đang đồng hành
                        </span>
                    </div>
                </div>
                <% } else { %>
                <div style="text-align: center; padding: 24px; color: var(--text-secondary);">
                    <i class="fa-solid fa-user-slash" style="font-size: 28px; margin-bottom: 8px; display: block; opacity: 0.5;"></i>
                    <p style="font-size: 14.5px; margin: 0 0 4px 0; color: #1e293b; font-weight: 600;">Hiện tại bạn chưa được ghép nối với Mentor nào.</p>
                    <p style="font-size: 13px; margin: 0;">Vui lòng liên hệ bộ phận HR hoặc Quản lý phòng ban để được hỗ trợ ghép nối Mentor.</p>
                </div>
                <% } %>
            </div>
        </div>

        <%-- ĐÁNH GIÁ NĂNG LỰC TỪ MENTOR (CHỈ HIỂN THỊ KHI ĐÃ ĐƯỢC DUYỆT, KHÔNG HIỂN THỊ ĐIỂM SỐ) --%>
        <% if (myMentor != null) { %>
        <div class="card">
            <div class="card-header" style="border-bottom: 1px solid var(--border-color); padding: 16px 20px; display: flex; justify-content: space-between; align-items: center;">
                <h3 style="margin: 0; font-size: 16px; font-weight: 600; display: flex; align-items: center; gap: 8px; color: #1e293b;">
                    <i class="fa-solid fa-clipboard-check" style="color: var(--primary);"></i> Đánh Giá Năng Lực &amp; Phản Hồi Từ Mentor
                </h3>
                <span class="text-secondary" style="font-size: 13px;">Đã duyệt: <%= approvedEvaluations.size() %></span>
            </div>
            <div class="card-body" style="padding: 20px;">
                <% if (!approvedEvaluations.isEmpty()) { 
                    for (MentorEvaluation eval : approvedEvaluations) { 
                        // Làm sạch nội dung phản hồi công khai: loại bỏ hoàn toàn các điểm số trong ngoặc (2.0đ), (1.6đ)...
                        String rawPub = (eval.getPublicFeedback() != null && !eval.getPublicFeedback().trim().isEmpty()) 
                                        ? eval.getPublicFeedback() : (eval.getFeedback() != null ? eval.getFeedback() : "");
                        String cleanPub = rawPub.replaceAll("\\s*\\([0-9]+(?:[.,][0-9]+)?\\s*(?:đ|điểm|pts)?\\)", "").trim();
                %>
                <div style="border: 1px solid #e0e7ff; background: #ffffff; padding: 18px 20px; border-radius: 8px; margin-bottom: 18px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; padding-bottom: 10px; border-bottom: 1px solid #f1f5f9;">
                        <span style="font-weight: 700; font-size: 14.5px; color: #1e293b; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-file-signature" style="color: var(--primary);"></i> Phiếu Đánh Giá Chuyên Môn
                        </span>
                        <span class="badge badge-status-active">
                            <i class="fa-solid fa-circle-check"></i> Đã phê duyệt
                        </span>
                    </div>
                    <div style="font-size: 14px; line-height: 1.6; color: #334155;">
                        <div style="font-weight: 600; margin-bottom: 8px; color: #1e293b; font-size: 13.5px;">
                            <i class="fa-solid fa-comment-dots" style="color: var(--primary); margin-right: 4px;"></i> Nhận xét &amp; Định hướng chuyên môn:
                        </div>
                        <div style="white-space: pre-line; background: #f8fafc; padding: 14px 16px; border: 1px solid #e2e8f0; border-radius: 8px; color: #1e293b; font-size: 13.5px; line-height: 1.65;">
                            <%= cleanPub %>
                        </div>
                    </div>
                </div>
                <%  } 
                   } else { %>
                <div style="text-align: center; padding: 36px 16px; color: var(--text-secondary);">                    
                    <p style="font-size: 14px; margin: 0 0 4px 0; color: #1e293b; font-weight: 600;">Chưa có đánh giá nào</p>                    
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
