package controller;

import dal.DepartmentDAO;
import dal.PositionDAO;
import dal.PositionRequestDAO;
import model.Department;
import model.JobLevel;
import model.Position;
import model.PositionRequest;
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
    private final PositionRequestDAO positionRequestDAO = new PositionRequestDAO();

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
            action = (currentUser.getRoleId() == 1) ? "requests" : "list";
        }

        // Nhân viên thường không vào trang quản lý vị trí
        if (currentUser.getRoleId() == 4) {
            response.sendRedirect(request.getContextPath() + "/employees?action=detail&id=" + currentUser.getUserId());
            return;
        }

        // HR (role 2) và Manager (role 3) không được trực tiếp tạo/sửa vị trí (chỉ Admin mới có quyền)
        if ((currentUser.getRoleId() == 2 || currentUser.getRoleId() == 3) && ("create".equals(action) || "edit".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        switch (action) {
            case "requests":
                if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
                    response.sendRedirect(request.getContextPath() + "/positions");
                    return;
                }
                String reqStatus = request.getParameter("status");
                request.setAttribute("requests", positionRequestDAO.getAllRequests(reqStatus));
                request.getRequestDispatcher("/views/positions/position-requests.jsp").forward(request, response);
                break;

            case "myRequests":
                if (currentUser.getRoleId() != 3) {
                    response.sendRedirect(request.getContextPath() + "/positions");
                    return;
                }
                request.setAttribute("requests", positionRequestDAO.getRequestsByManager(currentUser.getUserId()));
                request.getRequestDispatcher("/views/positions/position-requests.jsp").forward(request, response);
                break;

            case "requestCreate":
                if (currentUser.getRoleId() != 3) {
                    response.sendRedirect(request.getContextPath() + "/positions");
                    return;
                }
                Department myDept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
                request.setAttribute("managerDepartment", myDept);
                request.getRequestDispatcher("/views/positions/position-request-form.jsp").forward(request, response);
                break;

            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                listPositions(request, response, currentUser);
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

        // Manager gửi đề xuất vị trí mới
        if ("createRequest".equals(action)) {
            if (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 2) {
                response.sendRedirect(request.getContextPath() + "/positions");
                return;
            }
            createPositionRequest(request, response, currentUser);
            return;
        }

        // Admin hoặc HR duyệt đề xuất vị trí
        if ("reviewRequest".equals(action)) {
            if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
                response.sendRedirect(request.getContextPath() + "/positions");
                return;
            }
            reviewPositionRequest(request, response, currentUser);
            return;
        }

        // Chỉ Admin (role 1) mới được thêm/sửa/xóa vị trí trực tiếp
        if (currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
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

    private void createPositionRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posName = request.getParameter("positionName");
        String deptIdStr = request.getParameter("departmentId");
        String desc = request.getParameter("description");
        String reason = request.getParameter("reason");

        if (posName != null && !posName.trim().isEmpty() && reason != null && !reason.trim().isEmpty()) {
            int deptId = 0;
            if (deptIdStr != null && !deptIdStr.isEmpty()) {
                try {
                    deptId = Integer.parseInt(deptIdStr);
                } catch (NumberFormatException ignored) {}
            }
            PositionRequest req = new PositionRequest();
            req.setManagerId(currentUser.getUserId());
            req.setDepartmentId(deptId);
            req.setPositionName(posName.trim());
            req.setDescription(desc != null ? desc.trim() : null);
            req.setReason(reason.trim());

            boolean ok = positionRequestDAO.createRequest(req);
            if (ok) {
                request.getSession().setAttribute("successMessage", "Đề xuất vị trí mới đã được gửi tới Quản trị viên (Admin) xem xét!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể gửi đề xuất, vui lòng kiểm tra lại thông tin.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/positions?action=myRequests");
    }

    private void reviewPositionRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String reqIdStr = request.getParameter("requestId");
        String status = request.getParameter("status");
        String note = request.getParameter("decisionNote");

        if (reqIdStr != null && status != null) {
            try {
                int reqId = Integer.parseInt(reqIdStr);
                boolean ok = positionRequestDAO.reviewRequest(reqId, currentUser.getUserId(), status, note);
                if (ok) {
                    if ("APPROVED".equalsIgnoreCase(status)) {
                        request.getSession().setAttribute("successMessage", "Đã PHÊ DUYỆT đề xuất và Hệ thống tự động tạo Vị trí mới thành công!");
                    } else {
                        request.getSession().setAttribute("successMessage", "Đã TỪ CHỐI đề xuất và gửi giải trình lý do tới Trưởng phòng.");
                    }
                } else {
                    request.getSession().setAttribute("errorMessage", "Thao tác phê duyệt thất bại hoặc yêu cầu đã được xử lý.");
                }
            } catch (NumberFormatException ignored) {}
        }
        response.sendRedirect(request.getContextPath() + "/positions?action=requests");
    }

    private void listPositions(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String deptFilterStr = request.getParameter("departmentId");
        Integer deptFilter = null;
        if (deptFilterStr != null && !deptFilterStr.isEmpty() && !deptFilterStr.equals("0")) {
            try {
                deptFilter = Integer.parseInt(deptFilterStr);
            } catch (NumberFormatException ignored) {
            }
        }

        List<Department> departments;
        // Nếu là Manager (role 3), chỉ xem vị trí trong phòng ban mình phụ trách
        if (currentUser != null && currentUser.getRoleId() == 3) {
            Department myDept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
            if (myDept != null) {
                deptFilter = myDept.getDepartmentId();
                departments = new java.util.ArrayList<>();
                departments.add(myDept);
            } else {
                deptFilter = -1;
                departments = new java.util.ArrayList<>();
            }
        } else {
            departments = departmentDAO.getAllDepartments();
        }

        List<Position> positions = positionDAO.getPositionsByDepartment(deptFilter);
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
