<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean managerEvaluation = Boolean.TRUE.equals(request.getAttribute("managerEvaluation"));
    if (currentUser == null || (managerEvaluation && currentUser.getRoleId() != 3) || (!managerEvaluation && currentUser.getRoleId() != 4)) {
        response.sendRedirect(request.getContextPath() + "/dashboard"); return;
    }
    int classId = request.getAttribute("classId") == null ? 0 : (Integer) request.getAttribute("classId");
    int menteeId = request.getAttribute("menteeId") == null ? 0 : (Integer) request.getAttribute("menteeId");
    String[] publicItems = {"Hoàn thành nhiệm vụ đúng hạn", "Chất lượng công việc đạt yêu cầu", "Nắm vững kiến thức chuyên môn", "Chủ động học hỏi", "Phối hợp tốt với đồng đội"};
    String[] privateItems = {"Chủ động và trách nhiệm", "Tuân thủ quy trình", "Giao tiếp và phối hợp", "Tiếp thu phản hồi", "Tiềm năng phát triển"};
    request.setAttribute("pageTitle", "Đánh Giá Mentee | CPMS");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar"><h1>Đánh Giá Mentee</h1><a href="<%= request.getContextPath() %>/mentors?action=<%= managerEvaluation ? "managerWorkspace" : "myMentees" %>" class="btn btn-secondary">Quay lại</a></div>
    <div class="content-body">
        <form action="<%= request.getContextPath() %>/mentors" method="POST" class="card" style="padding:24px;max-width:850px;margin:0 auto">
            <input type="hidden" name="action" value="saveEvaluation">
            <% if (managerEvaluation) { %>
                <input type="hidden" name="classId" value="<%= classId %>"><input type="hidden" name="menteeId" value="<%= menteeId %>">
            <% } else { %><input type="hidden" name="assignmentId" value="<%= request.getAttribute("assignmentId") %>"><% } %>
            <p>Chọn các tiêu chí phù hợp. Mỗi tiêu chí công khai được chọn tính 2 điểm, tối đa 10 điểm.</p>
            <fieldset style="border:1px solid #90caf9;padding:16px;margin-bottom:18px"><legend><b>Kết quả mentee có thể xem</b></legend>
                <% for (int i = 0; i < publicItems.length; i++) { %><label style="display:block;margin:10px 0"><input type="checkbox" name="visibleCriteria" value="<%= i %>"> <%= publicItems[i] %></label><% } %>
            </fieldset>
            <fieldset style="border:1px solid #ef9a9a;padding:16px;margin-bottom:18px;background:#fffcfc"><legend><b>Đánh giá nội bộ, chỉ mentor/manager/HR xem</b></legend>
                <% for (int i = 0; i < privateItems.length; i++) { %><label style="display:block;margin:10px 0"><input type="checkbox" name="internalCriteria" value="<%= i %>"> <%= privateItems[i] %></label><% } %>
            </fieldset>
            <label for="comment"><b>Nhận xét</b></label>
            <textarea id="comment" name="comment" class="form-control" rows="5" maxlength="4000" style="width:100%;margin-top:8px" placeholder="Viết nhận xét dành cho mentee..."></textarea>
            <div style="margin-top:20px;text-align:right"><button type="submit" class="btn btn-primary">Lưu đánh giá</button></div>
        </form>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
