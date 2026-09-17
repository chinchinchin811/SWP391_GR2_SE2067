<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.MentorEvaluation" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;

    // BẢO MẬT GIAO DIỆN: EMPLOYEE (ROLE 4) CHẶN KHÔNG CHO TRUY CẬP
    if (roleId == 4) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    request.setAttribute("pageTitle", "Quan Ly Danh Gia Mentee | HRM");
    List<MentorEvaluation> evaluations = (List<MentorEvaluation>) request.getAttribute("evaluations");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Phe Duyet & Danh Gia Nhan Vien Moi</h1>
    </div>

    <div class="content-body">
        <div class="card" style="border: 1px solid #000; background: #fff; padding: 20px;">
            <div class="card-header" style="border-bottom: 1px solid #000; padding-bottom: 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;">
                <h2 style="margin: 0; font-size: 18px;">Danh Sach Danh Gia Tu Mentor</h2>
                <span style="font-size: 12px; font-style: italic; color: #555;">(Chi hien thi cho HR, Manager, Admin & Mentor)</span>
            </div>
            <div class="card-body">
                <table class="data-table" style="width: 100%; border-collapse: collapse; border: 1px solid #000;">
                    <thead>
                        <tr style="background: #f0f0f0; border-bottom: 1px solid #000; text-align: left;">
                            <th style="padding: 10px; border: 1px solid #000;">STT</th>
                            <th style="padding: 10px; border: 1px solid #000;">Mentee (Nhan vien)</th>
                            <th style="padding: 10px; border: 1px solid #000;">Mentor Huong dan</th>
                            <th style="padding: 10px; border: 1px solid #000;">Diem Danh gia</th>
                            <th style="padding: 10px; border: 1px solid #000;">Nhan xet Chuyen mon</th>
                            <th style="padding: 10px; border: 1px solid #000;">Trang thai Phe duyet</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (evaluations != null && !evaluations.isEmpty()) {
                            int stt = 1;
                            for (MentorEvaluation eval : evaluations) { %>
                            <tr style="border-bottom: 1px solid #ccc;">
                                <td style="padding: 10px; border: 1px solid #000; text-align: center;"><%= stt++ %></td>
                                <td style="padding: 10px; border: 1px solid #000;"><b><%= eval.getMenteeName() %></b></td>
                                <td style="padding: 10px; border: 1px solid #000;"><%= eval.getMentorName() %></td>
                                <td style="padding: 10px; border: 1px solid #000; text-align: center;">
                                    <b><%= eval.getPerformanceScore() %>/10</b>
                                </td>
                                <td style="padding: 10px; border: 1px solid #000;"><%= eval.getFeedback() %></td>
                                <td style="padding: 10px; border: 1px solid #000; text-align: center;">
                                    <span style="padding: 3px 8px; border: 1px solid #000; background: <%= "APPROVED".equalsIgnoreCase(eval.getApprovalStatus()) ? "#e8f5e9" : "#fff3e0" %>; font-size: 11px; font-weight: bold;">
                                        <%= eval.getApprovalStatus() %>
                                    </span>
                                </td>
                            </tr>
                        <%  } 
                        } else { %>
                            <tr>
                                <td colspan="6" style="padding: 20px; text-align: center; border: 1px solid #000;">
                                    Chua co ghi nhan danh gia nao tu Mentor.
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