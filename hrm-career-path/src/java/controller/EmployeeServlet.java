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

        if (currentUser.getRoleId() == 1 && !"list".equals(action) && !"detail".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
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

        if (currentUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/flashcards");
            return;
        }

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
        List<Position> positions = (deptId != null && deptId > 0) 
            ? positionDAO.getPositionsByDepartment(deptId) 
            : positionDAO.getAllPositions();
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
                    request.setAttribute("employee", user);
                    loadFormData(request);
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
                    request.setAttribute("employee", user);
                    loadFormData(request);
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
            request.setAttribute("error", "Vui lòng điền đầy đủ Tên tài khoản, Họ tên và Email!");
            loadFormData(request);
            request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
            return;
        }

        int roleId = parseInteger(roleIdStr) != null ? parseInteger(roleIdStr) : 4;
        Integer deptId = parseInteger(deptIdStr);

        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(password != null && !password.trim().isEmpty() ? password.trim() : "123");
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPhone(phone);
        user.setGender(gender);
        user.setStatus(true);
        user.setRoleId(roleId);
        user.setDepartmentId(deptId);
        user.setPositionId(parseInteger(posIdStr));
        user.setLevelId(parseInteger(levelIdStr));

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

        // 1. RÀNG BUỘC ADMIN: Chỉ duy nhất 1 Admin trên toàn hệ thống
        if (roleId == 1) {
            if (userDAO.countAdmin() >= 1) {
                request.setAttribute("error", "Hệ thống chỉ cho phép duy nhất 1 Quản trị viên (Admin) và tài khoản này đã tồn tại!");
                request.setAttribute("employee", user);
                loadFormData(request);
                request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                return;
            }
        }

        // 2. RÀNG BUỘC MANAGER: Bắt buộc chọn phòng ban và mỗi phòng chỉ có tối đa 1 Manager
        if (roleId == 3) {
            if (deptId == null || deptId <= 0) {
                request.setAttribute("error", "Vui lòng chọn Phòng ban khi khai báo nhân sự với vai trò Trưởng phòng (Manager)!");
                request.setAttribute("employee", user);
                loadFormData(request);
                request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                return;
            }

            Department currentDept = departmentDAO.getDepartmentById(deptId);
            User existingMgr = userDAO.getManagerByDepartment(deptId);
            if (existingMgr != null || (currentDept != null && currentDept.getManagerId() != null && currentDept.getManagerId() > 0)) {
                String mgrName = (existingMgr != null) ? existingMgr.getFullName() : (currentDept != null ? currentDept.getManagerName() : "Đã có Trưởng phòng");
                String deptName = (currentDept != null) ? currentDept.getDepartmentName() : "này";
                request.setAttribute("error", "Phòng ban '" + deptName + "' đã có Trưởng phòng (" + mgrName + "). Mỗi phòng ban chỉ được phép có tối đa 1 Trưởng phòng!");
                request.setAttribute("employee", user);
                loadFormData(request);
                request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                return;
            }
        }

        // 3. RÀNG BUỘC VỊ TRÍ CHUYÊN MÔN: Phải thuộc đúng Phòng ban đã chọn
        Integer posId = parseInteger(posIdStr);
        if (posId != null && posId > 0) {
            if (deptId == null || deptId <= 0) {
                request.setAttribute("error", "Vui lòng chọn Phòng ban trước khi chọn Vị trí chuyên môn!");
                request.setAttribute("employee", user);
                loadFormData(request);
                request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                return;
            }

            Position pos = positionDAO.getPositionById(posId);
            if (pos != null && pos.getDepartmentId() != null && !pos.getDepartmentId().equals(deptId)) {
                Department d = departmentDAO.getDepartmentById(deptId);
                String deptName = (d != null) ? d.getDepartmentName() : "đã chọn";
                request.setAttribute("error", "Vị trí chuyên môn '" + pos.getPositionName() + "' không thuộc phòng ban " + deptName + "! Vui lòng chọn đúng vị trí của phòng ban.");
                request.setAttribute("employee", user);
                loadFormData(request);
                request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                return;
            }
        }

        int creatorId = currentUser != null ? currentUser.getUserId() : 1;

        boolean success = userDAO.addEmployee(user, creatorId);
        if (success) {
            request.getSession().setAttribute("successMessage", "Khai báo nhân sự mới thành công!");
            response.sendRedirect(request.getContextPath() + "/employees");
        } else {
            request.setAttribute("error", "Khai báo thất bại! Có thể Tên tài khoản/Email đã tồn tại hoặc vi phạm ràng buộc dữ liệu.");
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
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            User existingUser = userDAO.getUserById(id);
            if (existingUser == null) {
                response.sendRedirect(request.getContextPath() + "/employees");
                return;
            }

            int newRoleId = parseInteger(roleIdStr) != null ? parseInteger(roleIdStr) : 4;
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
            user.setRoleId(newRoleId);
            user.setStatus("1".equals(statusStr) || "true".equalsIgnoreCase(statusStr));

            // 1. RÀNG BUỘC ADMIN
            if (newRoleId == 1 && existingUser.getRoleId() != 1) {
                if (userDAO.countAdmin() >= 1) {
                    request.setAttribute("error", "Hệ thống chỉ cho phép duy nhất 1 Quản trị viên (Admin)!");
                    request.setAttribute("employee", user);
                    loadFormData(request);
                    request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                    return;
                }
            }

            // 2. RÀNG BUỘC MANAGER
            if (newRoleId == 3) {
                if (existingUser.getDepartmentId() == null || existingUser.getDepartmentId() <= 0) {
                    request.setAttribute("error", "Nhân sự này chưa thuộc phòng ban nào! Vui lòng vào chức năng 'Phân bổ vị trí' để xếp phòng ban trước khi bổ nhiệm Trưởng phòng.");
                    request.setAttribute("employee", user);
                    loadFormData(request);
                    request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                    return;
                }

                int deptId = existingUser.getDepartmentId();
                boolean hasOtherMgr = userDAO.hasManagerInDepartment(deptId, existingUser.getUserId());
                Department dept = departmentDAO.getDepartmentById(deptId);
                if (hasOtherMgr || (dept != null && dept.getManagerId() != null && dept.getManagerId() != existingUser.getUserId())) {
                    User otherMgr = userDAO.getManagerByDepartment(deptId);
                    String mgrName = (otherMgr != null) ? otherMgr.getFullName() : (dept != null ? dept.getManagerName() : "Đã có Trưởng phòng");
                    String deptName = (dept != null) ? dept.getDepartmentName() : "này";
                    request.setAttribute("error", "Phòng ban '" + deptName + "' đã có Trưởng phòng (" + mgrName + "). Mỗi phòng ban chỉ được phép có tối đa 1 Trưởng phòng!");
                    request.setAttribute("employee", user);
                    loadFormData(request);
                    request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
                    return;
                }
            }

            boolean success = userDAO.updateEmployee(user);
            if (success) {
                // Đồng bộ Departments.manager_id
                if (newRoleId == 3 && existingUser.getDepartmentId() != null) {
                    departmentDAO.assignManager(existingUser.getDepartmentId(), id);
                } else if (existingUser.getRoleId() == 3 && newRoleId != 3) {
                    // Nếu bị hạ chức từ Manager xuống chức khác -> Hủy Trưởng phòng ở Department
                    Department myDept = departmentDAO.getDepartmentByManagerId(id);
                    if (myDept != null) {
                        departmentDAO.assignManager(myDept.getDepartmentId(), null);
                    }
                }

                request.getSession().setAttribute("successMessage", "Cập nhật thông tin thành công!");
                response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + id);
            } else {
                request.setAttribute("error", "Cập nhật thất bại!");
                request.setAttribute("employee", user);
                loadFormData(request);
                request.getRequestDispatcher("/views/employees/employee-form.jsp").forward(request, response);
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
            User targetUser = userDAO.getUserById(userId);
            if (targetUser == null) {
                response.sendRedirect(request.getContextPath() + "/employees");
                return;
            }

            Integer newDeptId = parseInteger(deptIdStr);
            Integer newPosId = parseInteger(posIdStr);
            Integer newLevelId = parseInteger(levelIdStr);

            // Kiểm tra nếu nhân sự này đang là MANAGER mà điều chuyển sang phòng ban khác
            if (targetUser.getRoleId() == 3 && newDeptId != null && !newDeptId.equals(targetUser.getDepartmentId())) {
                User newDeptMgr = userDAO.getManagerByDepartment(newDeptId);
                if (newDeptMgr != null && newDeptMgr.getUserId() != userId) {
                    request.getSession().setAttribute("errorMessage", "Phòng ban mới đã có Trưởng phòng (" + newDeptMgr.getFullName() + "). Không thể điều chuyển Trưởng phòng sang phòng ban đã có quản lý!");
                    response.sendRedirect(request.getContextPath() + "/employees?action=assign&id=" + userId);
                    return;
                }
            }

            // Kiểm tra Vị trí chuyên môn mới có thuộc phòng ban được chọn không
            if (newPosId != null && newPosId > 0) {
                Integer effectiveDeptId = (newDeptId != null && newDeptId > 0) ? newDeptId : targetUser.getDepartmentId();
                if (effectiveDeptId == null || effectiveDeptId <= 0) {
                    request.getSession().setAttribute("errorMessage", "Nhân sự chưa có phòng ban! Vui lòng chọn phòng ban mới khi gán vị trí chuyên môn.");
                    response.sendRedirect(request.getContextPath() + "/employees?action=assign&id=" + userId);
                    return;
                }
                Position pos = positionDAO.getPositionById(newPosId);
                if (pos != null && pos.getDepartmentId() != null && !pos.getDepartmentId().equals(effectiveDeptId)) {
                    Department d = departmentDAO.getDepartmentById(effectiveDeptId);
                    String deptName = (d != null) ? d.getDepartmentName() : "đã chọn";
                    request.getSession().setAttribute("errorMessage", "Vị trí '" + pos.getPositionName() + "' không thuộc phòng ban " + deptName + "!");
                    response.sendRedirect(request.getContextPath() + "/employees?action=assign&id=" + userId);
                    return;
                }
            }

            int creatorId = currentUser != null ? currentUser.getUserId() : 1;

            boolean success = userDAO.updateEmployeeAssignment(userId, newDeptId, newPosId, newLevelId, changeType, notes, creatorId);
            if (success) {
                // Nếu là Manager và chuyển phòng: cập nhật lại quan hệ quản lý
                if (targetUser.getRoleId() == 3 && newDeptId != null && !newDeptId.equals(targetUser.getDepartmentId())) {
                    if (targetUser.getDepartmentId() != null) {
                        departmentDAO.assignManager(targetUser.getDepartmentId(), null);
                    }
                    departmentDAO.assignManager(newDeptId, userId);
                }

                request.getSession().setAttribute("successMessage", "Phân bổ / Chuyển vị trí thành công! Lịch sử biến động đã được lưu.");
                response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + userId);
            } else {
                request.getSession().setAttribute("errorMessage", "Phân bổ thất bại!");
                response.sendRedirect(request.getContextPath() + "/employees");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employees");
        }
    }

    private void loadFormData(HttpServletRequest request) {
        User emp = (User) request.getAttribute("employee");
        boolean isEditingAdmin = (emp != null && emp.getRoleId() == 1);
        request.setAttribute("departments", departmentDAO.getAllDepartments());
        request.setAttribute("positions", positionDAO.getAllPositions());
        request.setAttribute("jobLevels", positionDAO.getAllJobLevels());
        request.setAttribute("roles", roleDAO.getRolesForEmployeeForm(isEditingAdmin));
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
