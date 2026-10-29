package controller;

import dal.DepartmentDAO;
import dal.PositionDAO;
import dal.PositionRequestDAO;
import dal.TransferRequestDAO;
import dal.UserDAO;
import model.Department;
import model.EmployeeHistory;
import model.PositionRequest;
import model.TransferRequest;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class DashboardServlet extends HttpServlet {

    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final PositionDAO positionDAO = new PositionDAO();
    private final PositionRequestDAO positionRequestDAO = new PositionRequestDAO();
    private final TransferRequestDAO transferRequestDAO = new TransferRequestDAO();
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
        int roleId = currentUser.getRoleId();

        if (roleId == 1) {
            // Dashboard cho Quản trị viên (Admin)
            int totalDepartments = departmentDAO.countDepartments();
            int totalPositions = positionDAO.countPositions();
            int totalEmployees = userDAO.countEmployees();

            List<PositionRequest> pendingPositionRequests = positionRequestDAO.getAllRequests("PENDING");
            int countPendingRequests = (pendingPositionRequests != null) ? pendingPositionRequests.size() : 0;
            List<Department> departments = departmentDAO.getAllDepartments();

            request.setAttribute("totalDepartments", totalDepartments);
            request.setAttribute("totalPositions", totalPositions);
            request.setAttribute("totalEmployees", totalEmployees);
            request.setAttribute("countPendingRequests", countPendingRequests);
            request.setAttribute("pendingPositionRequests", pendingPositionRequests);
            request.setAttribute("departments", departments);

        } else if (roleId == 2) {
            // Dashboard cho Bộ phận Nhân sự (HR)
            int totalDepartments = departmentDAO.countDepartments();
            int totalPositions = positionDAO.countPositions();
            int totalEmployees = userDAO.countEmployees();
            int totalNewHires = userDAO.countNewHires();
            int totalRoleChanges = userDAO.countRoleChanges();

            List<TransferRequest> pendingTransfers = transferRequestDAO.getAllRequestsForHR("PENDING_HR");
            int countPendingTransfers = (pendingTransfers != null) ? pendingTransfers.size() : 0;

            List<Department> departments = departmentDAO.getAllDepartments();
            List<User> recentEmployees = userDAO.getAllEmployees("", null, null, null);
            if (recentEmployees.size() > 5) {
                recentEmployees = recentEmployees.subList(0, 5);
            }

            request.setAttribute("totalDepartments", totalDepartments);
            request.setAttribute("totalPositions", totalPositions);
            request.setAttribute("totalEmployees", totalEmployees);
            request.setAttribute("totalNewHires", totalNewHires);
            request.setAttribute("totalRoleChanges", totalRoleChanges);
            request.setAttribute("countPendingTransfers", countPendingTransfers);
            request.setAttribute("pendingTransfers", pendingTransfers);
            request.setAttribute("departments", departments);
            request.setAttribute("recentEmployees", recentEmployees);

        } else if (roleId == 3) {
            Department myDept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
            if (myDept != null) {
                List<User> deptEmployees = userDAO.getAllEmployees("", myDept.getDepartmentId(), null, null);
                request.setAttribute("myDepartment", myDept);
                request.setAttribute("deptEmployees", deptEmployees);
            }

        } else {
            User myProfile = userDAO.getUserById(currentUser.getUserId());
            List<EmployeeHistory> myHistory = userDAO.getHistoryByUserId(currentUser.getUserId());
            request.setAttribute("myProfile", myProfile != null ? myProfile : currentUser);
            request.setAttribute("myHistory", myHistory);
        }

        request.getRequestDispatcher("/views/dashboard.jsp").forward(request, response);
    }
}
