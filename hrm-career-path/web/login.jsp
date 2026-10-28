<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập | Career Path Management System (CPMS)</title>
        <!-- Google Fonts: Plus Jakarta Sans -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
            rel="stylesheet">
        <!-- Font Awesome 6 Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    </head>

    <body class="login-body">

        <div class="login-wrapper">
            <h2>ĐĂNG NHẬP HỆ THỐNG</h2>
            <p class="subtitle">Career Path Management System (CPMS)</p>

            <% String successMessage=(String) session.getAttribute("successMessage"); if (successMessage !=null) {
                session.removeAttribute("successMessage"); %>
                <div class="alert alert-success"
                    style="background-color: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px 14px; border-radius: 6px; margin-bottom: 16px; font-size: 13.5px; text-align: left; line-height: 1.5;">
                    <i class="fa-solid fa-circle-check" style="margin-right: 6px; color: #059669;"></i>
                    <%= successMessage %>
                </div>
                <% } %>

                    <% if (request.getAttribute("error") !=null) { %>
                        <div class="alert alert-danger">
                            <%= request.getAttribute("error") %>
                        </div>
                        <% } %>

                            <form action="<%= request.getContextPath() %>/login" method="POST">
                                <div class="form-group">
                                    <label for="username">Tên đăng nhập hoặc Email</label>
                                    <input type="text" id="username" name="username" class="form-control"
                                        value="<%= request.getAttribute(" enteredUsername") !=null ?
                                        request.getAttribute("enteredUsername") : "" %>" required autofocus>
                                </div>

                                <div class="form-group">
                                    <div
                                        style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                                        <label for="password" style="margin-bottom: 0;">Mật khẩu</label>
                                        <a href="<%= request.getContextPath() %>/forgot-password"
                                            style="font-size: 13px; color: #4f46e5; text-decoration: none; font-weight: 600;">
                                            Quên mật khẩu?
                                        </a>
                                    </div>
                                    <input type="password" id="password" name="password" class="form-control" required>
                                </div>

                                <button type="submit" class="btn btn-primary" style="width: 100%; padding: 8px;">
                                    Đăng Nhập
                                </button>
                            </form>
        </div>

    </body>

    </html>