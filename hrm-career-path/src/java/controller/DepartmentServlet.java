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

        // Manager chỉ được xem danh sách phòng ban của mình, không được tạo/sửa/xóa
        if (currentUser.getRoleId() == 3 && ("create".equals(action) || "edit".equals(action))) {
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

        // Chỉ HR (role 2) và Admin (role 1) mới có quyền tạo/sửa/xóa phòng ban hoặc gán manager
        if (currentUser.getRoleId() > 2) {
            response.sendRedirect(request.getContextPath() + "/departments");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
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
            // HR / Admin: Xem tất cả
            departments = departmentDAO.getAllDepartments();
        }

        List<User> managerCandidates = userDAO.getManagersCandidates();
        request.setAttribute("departments", departments);
        request.setAttribute("managerCandidates", managerCandidates);
        request.getRequestDispatcher("/views/departments/department-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> managerCandidates = userDAO.getManagersCandidates();
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
                    List<User> managerCandidates = userDAO.getManagersCandidates();
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
            request.setAttribute("error", "Ten phong ban khong duoc de trong!");
            showCreateForm(request, response);
            return;
        }

        Department dept = new Department();
        dept.setDepartmentName(name.trim());
        dept.setDescription(description);
        dept.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

        if (managerIdStr != null && !managerIdStr.trim().isEmpty() && !managerIdStr.equals("0")) {
            try {
                dept.setManagerId(Integer.parseInt(managerIdStr));
            } catch (NumberFormatException ignored) {
            }
        }

        boolean success = departmentDAO.addDepartment(dept);
        if (success) {
            request.getSession().setAttribute("successMessage", "Them moi phong ban thanh cong!");
            response.sendRedirect(request.getContextPath() + "/departments");
        } else {
            request.setAttribute("error", "Khong the them phong ban (Co the ten da ton tai)!");
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
            request.setAttribute("error", "Du lieu cap nhat khong hop le!");
            showEditForm(request, response);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Department dept = new Department();
            dept.setDepartmentId(id);
            dept.setDepartmentName(name.trim());
            dept.setDescription(description);
            dept.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

            if (managerIdStr != null && !managerIdStr.trim().isEmpty() && !managerIdStr.equals("0")) {
                dept.setManagerId(Integer.parseInt(managerIdStr));
            }

            boolean success = departmentDAO.updateDepartment(dept);
            if (success) {
                request.getSession().setAttribute("successMessage", "Cap nhat phong ban thanh cong!");
                response.sendRedirect(request.getContextPath() + "/departments");
            } else {
                request.setAttribute("error", "Cap nhat that bai!");
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
                managerId = Integer.parseInt(managerIdStr);
            }

            boolean success = departmentDAO.assignManager(deptId, managerId);
            if (success) {
                request.getSession().setAttribute("successMessage", "Gan Truong phong thanh cong!");
            } else {
                request.getSession().setAttribute("errorMessage", "Khong the gan Truong phong!");
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
                request.getSession().setAttribute("successMessage", "Xoa phong ban thanh cong!");
            } else {
                request.getSession().setAttribute("errorMessage", "Khong the xoa phong ban nay vi dang co rang buoc du lieu!");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/departments");
    }
}
