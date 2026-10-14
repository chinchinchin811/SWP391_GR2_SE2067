package controller;

import dal.DepartmentDAO;
import dal.PositionDAO;
import dal.TransferRequestDAO;
import dal.UserDAO;
import model.Department;
import model.JobLevel;
import model.Position;
import model.TransferRequest;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "TransferServlet", urlPatterns = {"/transfer"})
public class TransferServlet extends HttpServlet {

    private final TransferRequestDAO transferDAO = new TransferRequestDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final PositionDAO positionDAO = new PositionDAO();
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
        String action = request.getParameter("action");
        if (action == null) {
            if (currentUser.getRoleId() == 2) action = "hrRequests";
            else if (currentUser.getRoleId() == 3) action = "managerRequests";
            else action = "myRequests";
        }

        switch (action) {
            case "requestCreate":
                // Chỉ nhân viên (role 4) mới nộp đơn
                if (currentUser.getRoleId() != 4) {
                    response.sendRedirect(request.getContextPath() + "/transfer");
                    return;
                }
                User emp = userDAO.getUserById(currentUser.getUserId());
                List<Department> departments = departmentDAO.getAllDepartments();
                List<Position> positions = positionDAO.getPositionsByDepartment(null);
                request.setAttribute("employee", emp);
                request.setAttribute("departments", departments);
                request.setAttribute("positions", positions);
                request.getRequestDispatcher("/views/employees/transfer-form.jsp").forward(request, response);
                break;

            case "myRequests":
                List<TransferRequest> myRequests = transferDAO.getRequestsByEmployee(currentUser.getUserId());
                request.setAttribute("requests", myRequests);
                request.setAttribute("viewRole", "EMPLOYEE");
                request.getRequestDispatcher("/views/employees/transfer-list.jsp").forward(request, response);
                break;

            case "managerRequests":
                if (currentUser.getRoleId() != 3) {
                    response.sendRedirect(request.getContextPath() + "/transfer");
                    return;
                }
                Department myDept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
                int deptId = myDept != null ? myDept.getDepartmentId() : -1;
                List<TransferRequest> mgrRequests = transferDAO.getRequestsForManager(deptId);
                request.setAttribute("requests", mgrRequests);
                request.setAttribute("viewRole", "MANAGER");
                request.getRequestDispatcher("/views/employees/transfer-list.jsp").forward(request, response);
                break;

            case "hrRequests":
                if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 1) {
                    response.sendRedirect(request.getContextPath() + "/transfer");
                    return;
                }
                String filter = request.getParameter("filter");
                List<TransferRequest> hrRequests = transferDAO.getAllRequestsForHR(filter);
                List<JobLevel> levels = positionDAO.getAllJobLevels();
                request.setAttribute("requests", hrRequests);
                request.setAttribute("jobLevels", levels);
                request.setAttribute("viewRole", "HR");
                request.getRequestDispatcher("/views/employees/transfer-list.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/dashboard");
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

        if ("create".equals(action)) {
            // Employee gửi đề xuất
            if (currentUser.getRoleId() != 4) {
                response.sendRedirect(request.getContextPath() + "/transfer");
                return;
            }
            User emp = userDAO.getUserById(currentUser.getUserId());
            if (emp == null || emp.getDepartmentId() == null) {
                session.setAttribute("errorMessage", "Bạn chưa được xếp vào phòng ban nào để đề xuất chuyển!");
                response.sendRedirect(request.getContextPath() + "/transfer?action=myRequests");
                return;
            }

            String targetDeptStr = request.getParameter("targetDepartmentId");
            String targetPosStr = request.getParameter("targetPositionId");
            String reason = request.getParameter("reason");

            if (targetDeptStr == null || reason == null || reason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng chọn phòng ban mong muốn và nêu rõ lý do!");
                response.sendRedirect(request.getContextPath() + "/transfer?action=requestCreate");
                return;
            }

            try {
                int targetDeptId = Integer.parseInt(targetDeptStr);
                Integer targetPosId = (targetPosStr != null && !targetPosStr.isEmpty() && !targetPosStr.equals("0"))
                        ? Integer.parseInt(targetPosStr) : null;

                TransferRequest req = new TransferRequest();
                req.setEmployeeId(currentUser.getUserId());
                req.setCurrentDepartmentId(emp.getDepartmentId());
                req.setCurrentPositionId(emp.getPositionId());
                req.setTargetDepartmentId(targetDeptId);
                req.setTargetPositionId(targetPosId);
                req.setReason(reason.trim());

                boolean ok = transferDAO.createRequest(req);
                if (ok) {
                    session.setAttribute("successMessage", "Gửi nguyện vọng điều chuyển thành công! Vui lòng chờ Trưởng phòng phê duyệt.");
                    response.sendRedirect(request.getContextPath() + "/transfer?action=myRequests");
                    return;
                }
            } catch (NumberFormatException ignored) {}

            session.setAttribute("errorMessage", "Không thể gửi yêu cầu điều chuyển.");
            response.sendRedirect(request.getContextPath() + "/transfer?action=requestCreate");
            return;
        }

        if ("managerReview".equals(action)) {
            // Manager duyệt
            if (currentUser.getRoleId() != 3) {
                response.sendRedirect(request.getContextPath() + "/transfer");
                return;
            }
            String reqIdStr = request.getParameter("requestId");
            String status = request.getParameter("status"); // APPROVED hoặc REJECTED
            String note = request.getParameter("managerNote");

            if (reqIdStr != null && status != null) {
                try {
                    int reqId = Integer.parseInt(reqIdStr);
                    boolean ok = transferDAO.managerReview(reqId, currentUser.getUserId(), status, note);
                    if (ok) {
                        if ("APPROVED".equalsIgnoreCase(status)) {
                            session.setAttribute("successMessage", "Đã PHÊ DUYỆT nguyện vọng. Yêu cầu đã được chuyển tiếp sang phòng HR để thực thi.");
                        } else {
                            session.setAttribute("successMessage", "Đã TỪ CHỐI nguyện vọng điều chuyển của nhân sự.");
                        }
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/transfer?action=managerRequests");
            return;
        }

        if ("hrExecute".equals(action)) {
            // HR thực thi điều chuyển
            if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 1) {
                response.sendRedirect(request.getContextPath() + "/transfer");
                return;
            }
            String reqIdStr = request.getParameter("requestId");
            String status = request.getParameter("status"); // COMPLETED hoặc REJECTED
            String note = request.getParameter("hrNote");
            String levelIdStr = request.getParameter("levelId");

            if (reqIdStr != null && status != null) {
                try {
                    int reqId = Integer.parseInt(reqIdStr);
                    Integer levelId = (levelIdStr != null && !levelIdStr.isEmpty() && !levelIdStr.equals("0"))
                            ? Integer.parseInt(levelIdStr) : null;

                    boolean ok = transferDAO.hrExecuteTransfer(reqId, currentUser.getUserId(), status, note, levelId);
                    if (ok) {
                        if ("COMPLETED".equalsIgnoreCase(status)) {
                            session.setAttribute("successMessage", "Đã THỰC THI ĐIỀU CHUYỂN! Hệ thống đã tự động cập nhật phòng ban/vị trí mới và ghi nhận lịch sử biến động.");
                        } else {
                            session.setAttribute("successMessage", "Đã TỪ CHỐI yêu cầu điều chuyển.");
                        }
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/transfer?action=hrRequests");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/transfer");
    }
}
