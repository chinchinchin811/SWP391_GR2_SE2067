package controller;

import dal.DepartmentDAO;
import dal.PositionDAO;
import model.Department;
import model.JobLevel;
import model.Position;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class PositionServlet extends HttpServlet {

    private final PositionDAO positionDAO = new PositionDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/flashcards");
            return;
        }

        // Nhân viên không vào trang quản lý vị trí
        if (currentUser.getRoleId() == 4) {
            response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + currentUser.getUserId());
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // Manager chỉ xem, không được tạo/sửa vị trí công ty
        if (currentUser.getRoleId() == 3 && ("create".equals(action) || "edit".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        switch (action) {
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                listPositions(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        // Chỉ HR mới được thêm/sửa/xóa vị trí
        if (currentUser.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "create":
                createPosition(request, response);
                break;
            case "edit":
                updatePosition(request, response);
                break;
            case "delete":
                deletePosition(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/positions");
                break;
        }
    }

    private void listPositions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String deptFilterStr = request.getParameter("departmentId");
        Integer deptFilter = null;
        if (deptFilterStr != null && !deptFilterStr.isEmpty() && !deptFilterStr.equals("0")) {
            try {
                deptFilter = Integer.parseInt(deptFilterStr);
            } catch (NumberFormatException ignored) {
            }
        }

        List<Position> positions = positionDAO.getPositionsByDepartment(deptFilter);
        List<Department> departments = departmentDAO.getAllDepartments();
        List<JobLevel> jobLevels = positionDAO.getAllJobLevels();

        request.setAttribute("positions", positions);
        request.setAttribute("departments", departments);
        request.setAttribute("jobLevels", jobLevels);
        request.setAttribute("selectedDeptId", deptFilter);
        request.getRequestDispatcher("/views/positions/position-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Department> departments = departmentDAO.getAllDepartments();
        request.setAttribute("departments", departments);
        request.getRequestDispatcher("/views/positions/position-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Position pos = positionDAO.getPositionById(id);
                if (pos != null) {
                    List<Department> departments = departmentDAO.getAllDepartments();
                    request.setAttribute("position", pos);
                    request.setAttribute("departments", departments);
                    request.getRequestDispatcher("/views/positions/position-form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/positions");
    }

    private void createPosition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("positionName");
        String deptIdStr = request.getParameter("departmentId");
        String description = request.getParameter("description");
        String statusStr = request.getParameter("status");

        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Tên vị trí không được để trống!");
            showCreateForm(request, response);
            return;
        }

        Position pos = new Position();
        pos.setPositionName(name.trim());
        pos.setDescription(description);
        pos.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

        if (deptIdStr != null && !deptIdStr.trim().isEmpty() && !deptIdStr.equals("0")) {
            try {
                pos.setDepartmentId(Integer.parseInt(deptIdStr));
            } catch (NumberFormatException ignored) {
            }
        }

        boolean success = positionDAO.addPosition(pos);
        if (success) {
            request.getSession().setAttribute("successMessage", "Thêm mới vị trí chuyên môn thành công!");
            response.sendRedirect(request.getContextPath() + "/positions");
        } else {
            request.setAttribute("error", "Không thể thêm vị trí mới!");
            request.setAttribute("position", pos);
            showCreateForm(request, response);
        }
    }

    private void updatePosition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("positionId");
        String name = request.getParameter("positionName");
        String deptIdStr = request.getParameter("departmentId");
        String description = request.getParameter("description");
        String statusStr = request.getParameter("status");

        if (idStr == null || name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            showEditForm(request, response);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Position pos = new Position();
            pos.setPositionId(id);
            pos.setPositionName(name.trim());
            pos.setDescription(description);
            pos.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

            if (deptIdStr != null && !deptIdStr.trim().isEmpty() && !deptIdStr.equals("0")) {
                pos.setDepartmentId(Integer.parseInt(deptIdStr));
            }

            boolean success = positionDAO.updatePosition(pos);
            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật vị trí thành công!");
                response.sendRedirect(request.getContextPath() + "/positions");
            } else {
                request.setAttribute("error", "Cập nhật thất bại!");
                request.setAttribute("position", pos);
                showEditForm(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void deletePosition(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("id");
        try {
            int id = Integer.parseInt(idStr);
            boolean success = positionDAO.deletePosition(id);
            if (success) {
                request.getSession().setAttribute("successMessage", "Xóa vị trí thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể xóa vị trí này vì đang có nhân sự đảm nhiệm!");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/positions");
    }
}
