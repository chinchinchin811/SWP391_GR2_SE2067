package controller;

import dal.UserDAO;
import model.User;
import utils.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ email đã đăng ký!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        String cleanEmail = email.trim();
        User user = userDAO.getUserByEmail(cleanEmail);

        if (user == null) {
            request.setAttribute("error", "Không tìm thấy tài khoản nào khớp với email '" + cleanEmail + "'!");
            request.setAttribute("enteredEmail", cleanEmail);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!user.isStatus()) {
            request.setAttribute("error", "Tài khoản của bạn hiện đang ở trạng thái Tạm Khóa. Vui lòng liên hệ Quản trị viên (Admin)!");
            request.setAttribute("enteredEmail", cleanEmail);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        // Sinh mật khẩu ngẫu nhiên mới: CPMS@ + 6 chữ số
        int randomDigits = 100000 + RANDOM.nextInt(900000);
        String newPassword = "CPMS@" + randomDigits;

        // Cập nhật mật khẩu mới vào CSDL
        boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);
        if (updated) {
            try {
                int port = request.getServerPort();
                if (port == 8080) {
                    port = 8084;
                }
                String loginUrl = request.getScheme() + "://" + request.getServerName() + ":" + port + request.getContextPath() + "/login";
                EmailUtil.sendForgotPasswordEmail(user.getEmail(), user.getFullName(), user.getUsername(), newPassword, loginUrl);
            } catch (Exception ex) {
                System.err.println("[ForgotPasswordServlet] Lỗi gửi email: " + ex.getMessage());
            }

            request.getSession().setAttribute("successMessage", 
                    "Mật khẩu mới đã được cấp và gửi thành công tới email: " + user.getEmail() + ". Vui lòng kiểm tra hộp thư để đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("error", "Không thể cập nhật mật khẩu lúc này. Vui lòng thử lại sau ít phút!");
            request.setAttribute("enteredEmail", cleanEmail);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Forgot Password Servlet";
    }
}
