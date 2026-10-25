package controller;

import dal.DepartmentDAO;
import dal.UserDAO;
import model.Department;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class DepartmentServlet extends HttpServlet {

    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        // Nhân viên thường không có quyền quản lý phòng ban
        if (currentUser.getRoleId() == 4) {
            response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + currentUser.getUserId());
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // HR và Manager chỉ được xem danh sách phòng ban, không được tạo/sửa/xóa
        if ((currentUser.getRoleId() == 2 || currentUser.getRoleId() == 3) && ("create".equals(action) || "edit".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/departments");
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
                listDepartments(request, response, currentUser);
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

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // Admin (role 1) có toàn quyền tạo/sửa/xóa/gán manager
        // HR (role 2) có quyền gán/thay đổi/miễn nhiệm Trưởng phòng (assign-manager)
        if (currentUser.getRoleId() == 2) {
            if (!"assign-manager".equals(action)) {
                response.sendRedirect(request.getContextPath() + "/departments");
                return;
            }
        } else if (currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/departments");
            return;
        }

        switch (action) {
            case "create":
                createDepartment(request, response);
                break;
            case "edit":
                updateDepartment(request, response);
                break;
            case "assign-manager":
                assignManager(request, response);
                break;
            case "delete":
                deleteDepartment(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/departments");
                break;
        }
    }

    private void listDepartments(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        List<Department> departments;
        if (currentUser.getRoleId() == 3) {
            // Manager: Chỉ xem phòng ban mình phụ trách
            departments = new ArrayList<>();
            Department myDept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
            if (myDept != null) {
                departments.add(myDept);
            }
        } else {
            // Admin & HR: Xem tất cả
            departments = departmentDAO.getAllDepartments();
        }

        List<User> managerCandidates = userDAO.getAvailableManagerCandidates(null);
        request.setAttribute("departments", departments);
        request.setAttribute("managerCandidates", managerCandidates);
        request.getRequestDispatcher("/views/departments/department-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> managerCandidates = userDAO.getAvailableManagerCandidates(null);
        request.setAttribute("managerCandidates", managerCandidates);
        request.getRequestDispatcher("/views/departments/department-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Department dept = departmentDAO.getDepartmentById(id);
                if (dept != null) {
                    List<User> managerCandidates = userDAO.getAvailableManagerCandidates(dept.getDepartmentId());
                    request.setAttribute("department", dept);
                    request.setAttribute("managerCandidates", managerCandidates);
                    request.getRequestDispatcher("/views/departments/department-form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/departments");
    }

    private void createDepartment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("departmentName");
        String managerIdStr = request.getParameter("managerId");
        String description = request.getParameter("description");
        String statusStr = request.getParameter("status");

        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Tên phòng ban không được để trống!");
            showCreateForm(request, response);
            return;
        }

        // Kiểm tra trùng tên phòng ban TRƯỚC KHI insert để tránh nhảy IDENTITY trong SQL Server
        if (departmentDAO.isDepartmentNameExists(name, null)) {
            request.setAttribute("error", "Tên phòng ban '" + name.trim() + "' đã tồn tại trên hệ thống!");
            Department dept = new Department();
            dept.setDepartmentName(name.trim());
            dept.setDescription(description);
            dept.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));
            request.setAttribute("department", dept);
            showCreateForm(request, response);
            return;
        }

        Department dept = new Department();
        dept.setDepartmentName(name.trim());
        dept.setDescription(description);
        dept.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

        if (managerIdStr != null && !managerIdStr.trim().isEmpty() && !managerIdStr.equals("0")) {
            try {
                int mid = Integer.parseInt(managerIdStr);
                User cand = userDAO.getUserById(mid);
                if (cand != null && cand.getRoleId() == 1) {
                    request.setAttribute("error", "Quản trị viên (Admin) không thể được bổ nhiệm làm Trưởng phòng!");
                    request.setAttribute("department", dept);
                    showCreateForm(request, response);
                    return;
                }
                dept.setManagerId(mid);
            } catch (NumberFormatException ignored) {
            }
        }

        boolean success = departmentDAO.addDepartment(dept);
        if (success) {
            request.getSession().setAttribute("successMessage", "Thêm mới phòng ban thành công!");
            response.sendRedirect(request.getContextPath() + "/departments");
        } else {
            request.setAttribute("error", "Không thể thêm phòng ban! Vui lòng kiểm tra lại thông tin.");
            request.setAttribute("department", dept);
            showCreateForm(request, response);
        }
    }

    private void updateDepartment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("departmentId");
        String name = request.getParameter("departmentName");
        String managerIdStr = request.getParameter("managerId");
        String description = request.getParameter("description");
        String statusStr = request.getParameter("status");

        if (idStr == null || name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Dữ liệu cập nhật không hợp lệ!");
            showEditForm(request, response);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            // Kiểm tra trùng tên phòng ban TRƯỚC KHI update
            if (departmentDAO.isDepartmentNameExists(name, id)) {
                request.setAttribute("error", "Tên phòng ban '" + name.trim() + "' đã tồn tại trên hệ thống!");
                Department dept = new Department();
                dept.setDepartmentId(id);
                dept.setDepartmentName(name.trim());
                dept.setDescription(description);
                dept.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));
                request.setAttribute("department", dept);
                showEditForm(request, response);
                return;
            }

            Department dept = new Department();
            dept.setDepartmentId(id);
            dept.setDepartmentName(name.trim());
            dept.setDescription(description);
            dept.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

            if (managerIdStr != null && !managerIdStr.trim().isEmpty() && !managerIdStr.equals("0")) {
                int mid = Integer.parseInt(managerIdStr);
                User cand = userDAO.getUserById(mid);
                if (cand != null && cand.getRoleId() == 1) {
                    request.setAttribute("error", "Quản trị viên (Admin) không thể được bổ nhiệm làm Trưởng phòng!");
                    request.setAttribute("department", dept);
                    showEditForm(request, response);
                    return;
                }
                dept.setManagerId(mid);
            }

            boolean success = departmentDAO.updateDepartment(dept);
            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật phòng ban thành công!");
                response.sendRedirect(request.getContextPath() + "/departments");
            } else {
                request.setAttribute("error", "Cập nhật thất bại!");
                request.setAttribute("department", dept);
                showEditForm(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/departments");
        }
    }

    private void assignManager(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String deptIdStr = request.getParameter("departmentId");
        String managerIdStr = request.getParameter("managerId");

        try {
            int deptId = Integer.parseInt(deptIdStr);
            Integer managerId = null;
            if (managerIdStr != null && !managerIdStr.isEmpty() && !managerIdStr.equals("0")) {
                int mid = Integer.parseInt(managerIdStr);
                User cand = userDAO.getUserById(mid);
                if (cand != null && cand.getRoleId() == 1) {
                    request.getSession().setAttribute("errorMessage", "Quản trị viên (Admin) không thể được bổ nhiệm làm Trưởng phòng!");
                    response.sendRedirect(request.getContextPath() + "/departments");
                    return;
                }

                // Kiểm tra người này đã là manager của phòng ban khác chưa
                Department existingManaging = departmentDAO.getDepartmentByManagerId(mid);
                if (existingManaging != null && existingManaging.getDepartmentId() != deptId) {
                    request.getSession().setAttribute("errorMessage", "Nhân sự " + (cand != null ? cand.getFullName() : "") + " hiện đang là Trưởng phòng của " + existingManaging.getDepartmentName() + "!");
                    response.sendRedirect(request.getContextPath() + "/departments");
                    return;
                }
                managerId = mid;
            }

            boolean success = departmentDAO.assignManager(deptId, managerId);
            if (success) {
                if (managerId != null) {
                    User cand = userDAO.getUserById(managerId);
                    int targetRole = (cand != null && cand.getRoleId() == 2) ? 2 : 3;
                    userDAO.updateUserDepartmentAndRole(managerId, deptId, targetRole);
                    request.getSession().setAttribute("successMessage", "Bổ nhiệm Trưởng phòng thành công!");
                } else {
                    request.getSession().setAttribute("successMessage", "Đã miễn nhiệm Trưởng phòng thành công!");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể cập nhật Trưởng phòng!");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/departments");
    }

    private void deleteDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("id");
        try {
            int id = Integer.parseInt(idStr);
            boolean success = departmentDAO.deleteDepartment(id);
            if (success) {
                request.getSession().setAttribute("successMessage", "Xóa phòng ban thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể xóa phòng ban này vì đang có ràng buộc dữ liệu!");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/departments");
    }
}
