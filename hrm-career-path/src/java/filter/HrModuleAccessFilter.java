package filter;

import dal.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

/** Chặn HR khỏi toàn bộ bề mặt Học liệu/Đào tạo và Bài test, kể cả URL JSP trực tiếp. */
public final class HrModuleAccessFilter implements Filter {
    private final UserDAO users = new UserDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") instanceof User sessionUser) {
            User current = users.getUserById(sessionUser.getUserId());
            if (current == null) {
                session.invalidate();
                res.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            if (current.getRoleId() == 2) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "HR chỉ quản lý tổ chức và nhân sự, không truy cập Học liệu & Đào tạo hoặc Bài test & Đánh giá.");
                return;
            }
        }
        chain.doFilter(request, response);
    }
}
