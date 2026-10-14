<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Mentor.MentorEvaluation" %>
<%@ page import="dal.MentorDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    MentorDAO evalMentorDAO = new MentorDAO();
    boolean isMentorUser = (currentUser != null) && evalMentorDAO.isMentor(currentUser.getUserId());
    if (roleId == 4 && !isMentorUser) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    request.setAttribute("pageTitle", "Quản Lý Đánh Giá Mentee | HRM");
    List<MentorEvaluation> evaluations = (List<MentorEvaluation>) request.getAttribute("evaluations");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Phê Duyệt & Đánh Giá Nhân Viên Mới</h1>
    </div>

    <div class="content-body">
        <div class="card" style="border: 1px solid #000; background: #fff; padding: 20px;">
            <div class="card-header" style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;">
                <h2 style="margin: 0; font-size: 18px;">Danh Sách Đánh Giá Từ Mentor</h2>
                <span style="font-size: 12px; font-style: italic; color: #555;">(Chỉ hiển thị cho HR, Quản lý, Admin & Mentor)</span>
            </div>
            <div class="card-body">
                <table class="data-table" style="width: 100%; border-collapse: collapse; border: 1px solid #000;">
                    <thead>
                        <tr style="background: #f0f0f0; border-bottom: 1px solid #000; text-align: left;">
                            <th style="padding: 10px; border: 1px solid #000;">STT</th>
                            <th style="padding: 10px; border: 1px solid #000;">Mentee (Nhân viên)</th>
                            <th style="padding: 10px; border: 1px solid #000;">Mentor Hướng dẫn</th>
                            <th style="padding: 10px; border: 1px solid #000;">Điểm Đánh giá</th>
                            <th style="padding: 10px; border: 1px solid #000;">Nhận xét Chuyên môn</th>
                            <th style="padding: 10px; border: 1px solid #000;">Trạng thái Phê duyệt</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (evaluations != null && !evaluations.isEmpty()) {
                            int stt = 1;
                            for (MentorEvaluation eval : evaluations) {
                                boolean isApproved = "APPROVED".equalsIgnoreCase(eval.getApprovalStatus());
                        %>
                            <tr style="border-bottom: 1px solid #ccc;">
                                <td style="padding: 10px; border: 1px solid #000; text-align: center;">
                                    <%= stt++ %>
                                </td>
                                <td style="padding: 10px; border: 1px solid #000;">
                                    <b><%= eval.getMenteeName() %></b>
                                </td>
                                <td style="padding: 10px; border: 1px solid #000;">
                                    <%= eval.getMentorName() %>
                                </td>
                                <td style="padding: 10px; border: 1px solid #000; text-align: center;">
                                    <b><%= eval.getPerformanceScore() %>/10</b>
                                </td>
                                <td style="padding: 10px; border: 1px solid #000; font-size: 13px; line-height: 1.5;">
                                    <div>
                                        <b style="color: #0d47a1;"><i class="fa-solid fa-eye"></i> Công khai (Mentee xem):</b><br>
                                        <span style="color: #333;"><%= (eval.getPublicFeedback() != null && !eval.getPublicFeedback().isEmpty()) ? eval.getPublicFeedback() : eval.getFeedback() %></span>
                                    </div>
                                    <% if (eval.getPrivateFeedback() != null && !eval.getPrivateFeedback().trim().isEmpty()) { %>
                                    <div style="margin-top: 8px; padding-top: 6px; border-top: 1px dashed #e57373;">
                                        <b style="color: #c62828;"><i class="fa-solid fa-user-shield"></i> Nội bộ HR/Manager (Ẩn với Mentee):</b><br>
                                        <span style="color: #555; font-style: italic;"><%= eval.getPrivateFeedback() %></span>
                                    </div>
                                    <% } %>
                                </td>
                                <td style="padding: 10px; border: 1px solid #000; text-align: center;">
                                    <span style="padding: 3px 8px; border: 1px solid #000; background: <%= isApproved ? "#e8f5e9" : "#fff3e0" %>; font-size: 11px; font-weight: bold;">
                                        <%= eval.getApprovalStatus() %>
                                    </span>
                                </td>
                            </tr>
                        <%  }
                        } else { %>
                            <tr>
                                <td colspan="6" style="padding: 20px; text-align: center; border: 1px solid #000;">
                                    Chưa có ghi nhận đánh giá nào từ Mentor.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />