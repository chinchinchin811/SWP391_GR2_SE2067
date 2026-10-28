<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quên Mật Khẩu | Career Path Management System (CPMS)</title>
        <!-- Google Fonts: Plus Jakarta Sans -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    </head>

    <body class="login-body">

        <div class="login-wrapper">
            <h2>QUÊN MẬT KHẨU</h2>
            <p class="subtitle">Nhập email tài khoản của bạn để nhận mật khẩu khôi phục mới</p>

            <% if (request.getAttribute("error") !=null) { %>
                <div class="alert alert-danger" style="text-align: left;">
                    <%= request.getAttribute("error") %>
                </div>
                <% } %>

                    <form action="<%= request.getContextPath() %>/forgot-password" method="POST">
                        <div class="form-group" style="text-align: left;">
                            <label for="email">Địa chỉ Email đã đăng ký</label>
                            <input type="email" id="email" name="email" class="form-control"
                                value="<%= request.getAttribute(" enteredEmail") !=null ?
                                request.getAttribute("enteredEmail") : "" %>"
                            required autofocus>
                            <small style="color: #64748b; font-size: 12px; margin-top: 4px; display: block;">
                                Hệ thống sẽ tạo mật khẩu ngẫu nhiên mới và gửi trực tiếp tới email này.
                            </small>
                        </div>

                        <button type="submit" class="btn btn-primary"
                            style="width: 100%; padding: 10px; margin-top: 10px; font-weight: 600;">
                            Gửi Mật Khẩu Khôi Phục
                        </button>
                    </form>

                    <div style="margin-top: 24px; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                        <a href="<%= request.getContextPath() %>/login"
                            style="color: #4f46e5; font-size: 13.5px; text-decoration: none; font-weight: 600;">
                            Quay lại trang Đăng Nhập
                        </a>
                    </div>
        </div>

    </body>

    </html>