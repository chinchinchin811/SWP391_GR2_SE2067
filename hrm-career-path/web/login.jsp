<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dang nhap | HRM System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body style="background-color: #ecf0f1;">

    <div class="login-wrapper">
        <h2>DANG NHAP HE THONG</h2>
        <p class="subtitle">Quan Ly Nhan Su & Lo Trinh Phat Trien</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="POST">
            <div class="form-group">
                <label for="username">Ten dang nhap hoac Email:</label>
                <input type="text" id="username" name="username" class="form-control" 
                       value="<%= request.getAttribute("enteredUsername") != null ? request.getAttribute("enteredUsername") : "" %>" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Mat khau:</label>
                <input type="password" id="password" name="password" class="form-control" required>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 8px;">
                Dang Nhap
            </button>
        </form>

        <div class="test-accounts">
            <b>Tai khoan dung thu:</b><br>
            - HR Manager: <code>hr_manager</code> / <code>123</code><br>
            - Admin: <code>admin</code> / <code>123</code><br>
            - Manager IT: <code>manager_it</code> / <code>123</code><br>
            - Nhan vien Fresher: <code>dev_fresher</code> / <code>123</code>
        </div>
    </div>

</body>
</html>
