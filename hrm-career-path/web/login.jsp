<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | HRM System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body style="background-color: #ecf0f1;">

    <div class="login-wrapper">
        <h2>ĐĂNG NHẬP HỆ THỐNG</h2>
        <p class="subtitle">Quản Lý Nhân Sự & Lộ Trình Phát Triển</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="POST">
            <div class="form-group">
                <label for="username">Tên đăng nhập hoặc Email:</label>
                <input type="text" id="username" name="username" class="form-control" 
                       value="<%= request.getAttribute("enteredUsername") != null ? request.getAttribute("enteredUsername") : "" %>" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" name="password" class="form-control" required>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 8px;">
                Đăng Nhập
            </button>
        </form>
    </div>

</body>
</html>
