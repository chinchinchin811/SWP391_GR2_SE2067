package controller;

import dal.DepartmentDAO;
import dal.PositionDAO;
import dal.RoleDAO;
import dal.UserDAO;
import model.Department;
import model.EmployeeHistory;
import model.JobLevel;
import model.Position;
import model.Role;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class EmployeeServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final PositionDAO positionDAO = new PositionDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        // Nhân viên thường (role 4): Chỉ được xem hồ sơ của chính mình
        if (currentUser.getRoleId() == 4) {
            if ("detail".equals(action)) {
                showDetail(request, response, currentUser.getUserId());
            } else {
                showDetail(request, response, currentUser.getUserId());
            }
            return;
        }

        // Manager (role 3): Không được vào trang tạo nhân sự mới
        if (currentUser.getRoleId() == 3 && ("create".equals(action) || "assign".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        switch (action) {
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response, currentUser);
                break;
            case "assign":
                showAssignForm(request, response);
                break;
            case "detail":
                String idStr = request.getParameter("id");
                int id = currentUser.getUserId();
                if (idStr != null) {
                    try {
                        id = Integer.parseInt(idStr);
                    } catch (NumberFormatException ignored) {
                    }
                }
                showDetail(request, response, id);
                break;
            default:
                listEmployees(request, response, currentUser);
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

        // Nhân viên thường không có quyền thao tác dữ liệu
        if (currentUser.getRoleId() == 4) {
            response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + currentUser.getUserId());
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // Manager không có quyền tạo hoặc phân bổ vị trí nhân sự
        if (currentUser.getRoleId() == 3 && ("create".equals(action) || "assign".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        switch (action) {
            case "create":
                createEmployee(request, response, currentUser);
                break;
            case "edit":
                updateEmployee(request, response);
                break;
            case "assign":
                assignEmployee(request, response, currentUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/employees");
                break;
        }
    }

    private void listEmployees(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String search = request.getParameter("search");
        String deptIdStr = request.getParameter("departmentId");
        String posIdStr = request.getParameter("positionId");
        String roleIdStr = request.getParameter("roleId");

        Integer deptId = parseInteger(deptIdStr);
        Integer posId = parseInteger(posIdStr);
        Integer roleId = parseInteger(roleIdStr);

        List<Department> departments;
        // Nếu là Manager (role 3), tự động ép chỉ lấy phòng ban mình quản lý
        if (currentUser.getRoleId() == 3) {
            Department myDept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
            if (myDept != null) {
                deptId = myDept.getDepartmentId();
                departments = new ArrayList<>();
                departments.add(myDept);
            } else {
                deptId = -1; // Không có phòng ban nào
                departments = new ArrayList<>();
            }
        } else {
            departments = departmentDAO.getAllDepartments();
        }

        List<User> employees = userDAO.getAllEmployees(search, deptId, posId, roleId);
        List<Position> positions = positionDAO.getAllPositions();
        List<Role> roles = roleDAO.getAllRoles();

        request.setAttribute("employees", employees);
        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);
        request.setAttribute("roles", roles);

        request.setAttribute("search", search);
        request.setAttribute("selectedDeptId", deptId);
        request.setAttribute("selectedPosId", posId);
        request.setAttribute("selectedRoleId", roleId);

        request.getRequestDispatcher("/views/employees/employee-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadFormData(request);
        request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                User user = userDAO.getUserById(id);
                if (user != null) {
                    loadFormData(request);
                    request.setAttribute("employee", user);
                    request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        response.sendRedirect(request.getContextPath() + "/employees");
    }

    private void showAssignForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                User user = userDAO.getUserById(id);
                if (user != null) {
                    loadFormData(request);
                    request.setAttribute("employee", user);
                    request.getRequestDispatcher("/views/employees/employee-assign.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        response.sendRedirect(request.getContextPath() + "/employees");
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response, int id)
            throws ServletException, IOException {
        User user = userDAO.getUserById(id);
        if (user != null) {
            List<EmployeeHistory> historyList = userDAO.getHistoryByUserId(id);
            request.setAttribute("employee", user);
            request.setAttribute("historyList", historyList);
            request.getRequestDispatcher("/views/employees/employee-detail.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/dashboard");
    }

    private void createEmployee(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String dobStr = request.getParameter("dob");
        String roleIdStr = request.getParameter("roleId");
        String deptIdStr = request.getParameter("departmentId");
        String posIdStr = request.getParameter("positionId");
        String levelIdStr = request.getParameter("levelId");
        String hireDateStr = request.getParameter("hireDate");

        if (username == null || username.trim().isEmpty() || fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui long dien day du Ten tai khoan, Ho ten va Email!");
            loadFormData(request);
            request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(password != null && !password.trim().isEmpty() ? password.trim() : "123");
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPhone(phone);
        user.setGender(gender);
        user.setStatus(true);

        if (dobStr != null && !dobStr.isEmpty()) {
            try {
                user.setDob(Date.valueOf(dobStr));
            } catch (IllegalArgumentException ignored) {
            }
        }

        if (hireDateStr != null && !hireDateStr.isEmpty()) {
            try {
                user.setHireDate(Date.valueOf(hireDateStr));
            } catch (IllegalArgumentException ignored) {
                user.setHireDate(new Date(System.currentTimeMillis()));
            }
        } else {
            user.setHireDate(new Date(System.currentTimeMillis()));
        }

        user.setRoleId(parseInteger(roleIdStr) != null ? parseInteger(roleIdStr) : 4);
        user.setDepartmentId(parseInteger(deptIdStr));
        user.setPositionId(parseInteger(posIdStr));
        user.setLevelId(parseInteger(levelIdStr));

        int creatorId = currentUser != null ? currentUser.getUserId() : 1;

        boolean success = userDAO.addEmployee(user, creatorId);
        if (success) {
            request.getSession().setAttribute("successMessage", "Khai bao nhan su moi thanh cong!");
            response.sendRedirect(request.getContextPath() + "/employees");
        } else {
            request.setAttribute("error", "Khai bao that bai! Co the Username hoac Email da ton tai.");
            request.setAttribute("employee", user);
            loadFormData(request);
            request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
        }
    }

    private void updateEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("userId");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String dobStr = request.getParameter("dob");
        String roleIdStr = request.getParameter("roleId");
        String statusStr = request.getParameter("status");

        if (idStr == null || fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Du lieu khong hop le!");
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            User user = new User();
            user.setUserId(id);
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            user.setPhone(phone);
            user.setGender(gender);
            if (dobStr != null && !dobStr.isEmpty()) {
                try {
                    user.setDob(Date.valueOf(dobStr));
                } catch (IllegalArgumentException ignored) {
                }
            }
            user.setRoleId(parseInteger(roleIdStr) != null ? parseInteger(roleIdStr) : 4);
            user.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

            boolean success = userDAO.updateEmployee(user);
            if (success) {
                request.getSession().setAttribute("successMessage", "Cap nhat thong tin thanh cong!");
                response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + id);
            } else {
                request.setAttribute("error", "Cap nhat that bai!");
                response.sendRedirect(request.getContextPath() + "/employees");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employees");
        }
    }

    private void assignEmployee(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String idStr = request.getParameter("userId");
        String deptIdStr = request.getParameter("departmentId");
        String posIdStr = request.getParameter("positionId");
        String levelIdStr = request.getParameter("levelId");
        String changeType = request.getParameter("changeType");
        String notes = request.getParameter("notes");

        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        try {
            int userId = Integer.parseInt(idStr);
            Integer newDeptId = parseInteger(deptIdStr);
            Integer newPosId = parseInteger(posIdStr);
            Integer newLevelId = parseInteger(levelIdStr);

            int creatorId = currentUser != null ? currentUser.getUserId() : 1;

            boolean success = userDAO.updateEmployeeAssignment(userId, newDeptId, newPosId, newLevelId, changeType, notes, creatorId);
            if (success) {
                request.getSession().setAttribute("successMessage", "Phan bo / Chuyen vi tri thanh cong! Lich su da duoc luu.");
                response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + userId);
            } else {
                request.setAttribute("error", "Phan bo that bai!");
                response.sendRedirect(request.getContextPath() + "/employees");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employees");
        }
    }

    private void loadFormData(HttpServletRequest request) {
        request.setAttribute("departments", departmentDAO.getAllDepartments());
        request.setAttribute("positions", positionDAO.getAllPositions());
        request.setAttribute("jobLevels", positionDAO.getAllJobLevels());
        request.setAttribute("roles", roleDAO.getAllRoles());
    }

    private Integer parseInteger(String str) {
        if (str == null || str.trim().isEmpty() || str.equals("0")) {
            return null;
        }
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
