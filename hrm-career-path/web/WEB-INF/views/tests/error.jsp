<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="static utils.TestView.h" %>
<% request.setAttribute("pageTitle", "Bài test | HRM"); %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content"><div class="content-body"><section class="card"><div class="card-body">
    <h1>Chưa thể thực hiện thao tác</h1>
    <p role="alert"><%= h(request.getAttribute("testError")) %></p>
    <p>Bạn có thể quay lại trang trước để kiểm tra nội dung vừa nhập.</p>
    <a class="btn btn-primary" href="<%= request.getContextPath() %>/tests">Về danh sách bài test</a>
</div></section></div></main>
<jsp:include page="/views/common/footer.jsp" />
