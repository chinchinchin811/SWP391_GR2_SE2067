package controller;

import dal.CareerProgressionDAO;
import dal.DepartmentDAO;
import dal.PositionDAO;
import dal.PositionRequestDAO;
import model.CriteriaRequirement;
import model.Department;
import model.JobLevel;
import model.Position;
import model.PositionLevelCriteria;
import model.PositionRequest;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

public class PositionServlet extends HttpServlet {

    private final PositionDAO positionDAO = new PositionDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final PositionRequestDAO positionRequestDAO = new PositionRequestDAO();
    private final CareerProgressionDAO careerProgressionDAO = new CareerProgressionDAO();

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
                String deptFilterStr = request.getParameter("departmentId");
                String searchKeyword = request.getParameter("search");

                Integer deptFilter = null;
                if (deptFilterStr != null && !deptFilterStr.trim().isEmpty() && !deptFilterStr.equals("0")) {
                    try {
                        deptFilter = Integer.parseInt(deptFilterStr);
                    } catch (NumberFormatException ignored) {}
                }

                List<PositionRequest> requests = positionRequestDAO.getAllRequests(reqStatus, deptFilter, searchKeyword);
                List<Department> departments = departmentDAO.getAllDepartments();

                request.setAttribute("requests", requests);
                request.setAttribute("departments", departments);
                request.setAttribute("selectedStatus", reqStatus);
                request.setAttribute("selectedDeptId", deptFilter);
                request.setAttribute("searchKeyword", searchKeyword);
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

            case "detail":
                showPositionDetail(request, response, currentUser);
                break;

            case "criteria":
                showCriteria(request, response, currentUser);
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

        // Chỉ Admin (role 1) mới được thêm/sửa/xóa vị trí và cấu hình barem
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
            case "addLevel":
                addPositionLevel(request, response, currentUser);
                break;
            case "editLevel":
                editPositionLevel(request, response, currentUser);
                break;
            case "deleteLevel":
                deletePositionLevel(request, response, currentUser);
                break;
            case "copyDefaultLevels":
                copyDefaultLevels(request, response, currentUser);
                break;
            case "saveCriteria":
                saveCriteria(request, response, currentUser);
                break;
            case "deleteCriteria":
                deleteCriteria(request, response, currentUser);
                break;
            case "addRequirement":
                addRequirement(request, response, currentUser);
                break;
            case "deleteRequirement":
                deleteRequirement(request, response, currentUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/positions");
                break;
        }
    }

    // ==========================================
    // ACTION HANDLERS
    // ==========================================

    private void showCriteria(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String posIdStr = request.getParameter("positionId");
        if (posIdStr == null || posIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }
        try {
            int posId = Integer.parseInt(posIdStr);
            Position pos = positionDAO.getPositionById(posId);
            if (pos == null) {
                response.sendRedirect(request.getContextPath() + "/positions");
                return;
            }
            List<PositionLevelCriteria> criteriaList = careerProgressionDAO.getCriteriaByPosition(posId);
            List<JobLevel> allLevels = positionDAO.getLevelsByPosition(posId);
            if (allLevels == null || allLevels.isEmpty()) {
                allLevels = positionDAO.getAllJobLevels();
            }

            request.setAttribute("position", pos);
            request.setAttribute("criteriaList", criteriaList);
            request.setAttribute("allLevels", allLevels);
            request.getRequestDispatcher("/views/positions/position-criteria.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void saveCriteria(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posIdStr = request.getParameter("positionId");
        String fromLevelStr = request.getParameter("fromLevelId");
        String toLevelStr = request.getParameter("toLevelId");
        String summary = request.getParameter("competencySummary");
        String testScoreStr = request.getParameter("minTestScore");
        String ratingStr = request.getParameter("minManagerRating");
        String returnTo = request.getParameter("returnTo");

        try {
            int posId = Integer.parseInt(posIdStr);
            String redirectUrl = "detail".equals(returnTo)
                    ? request.getContextPath() + "/positions?action=detail&id=" + posId
                    : request.getContextPath() + "/positions?action=criteria&positionId=" + posId;

            int fromLvl = Integer.parseInt(fromLevelStr);
            int toLvl = Integer.parseInt(toLevelStr);

            // Validate logic thăng tiến: toLevel phải lớn hơn fromLevel
            JobLevel fromLevel = positionDAO.getJobLevelById(fromLvl);
            JobLevel toLevel = positionDAO.getJobLevelById(toLvl);
            if (fromLevel == null || toLevel == null) {
                request.getSession().setAttribute("errorMessage", "Cấp bậc đã chọn không tồn tại trong hệ thống!");
                response.sendRedirect(redirectUrl);
                return;
            }
            if (fromLvl == toLvl) {
                request.getSession().setAttribute("errorMessage", "Cấp bậc mục tiêu không được trùng với cấp bậc hiện tại!");
                response.sendRedirect(redirectUrl);
                return;
            }
            if (toLevel.getRankOrder() <= fromLevel.getRankOrder()) {
                request.getSession().setAttribute("errorMessage", "Cấp bậc mục tiêu phải cao hơn cấp bậc hiện tại (Bậc " + toLevel.getRankOrder() + " <= Bậc " + fromLevel.getRankOrder() + ")!");
                response.sendRedirect(redirectUrl);
                return;
            }

            PositionLevelCriteria c = new PositionLevelCriteria();
            c.setPositionId(posId);
            c.setFromLevelId(fromLvl);
            c.setToLevelId(toLvl);
            c.setCompetencySummary(summary != null ? summary.trim() : "");
            c.setStatus(true);

            if (testScoreStr != null && !testScoreStr.trim().isEmpty()) {
                c.setMinTestScore(new BigDecimal(testScoreStr.trim()));
            } else {
                c.setMinTestScore(new BigDecimal("80.0"));
            }
            if (ratingStr != null && !ratingStr.trim().isEmpty()) {
                c.setMinManagerRating(new BigDecimal(ratingStr.trim()));
            } else {
                c.setMinManagerRating(new BigDecimal("7.5"));
            }

            int id = careerProgressionDAO.addCriteria(c);
            if (id > 0) {
                request.getSession().setAttribute("successMessage", "Đã thiết lập nấc barem thăng tiến mới thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể lưu barem. Có thể nấc thăng tiến giữa 2 cấp bậc này đã tồn tại!");
            }
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void deleteCriteria(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String critIdStr = request.getParameter("criteriaId");
        String posIdStr = request.getParameter("positionId");
        String returnTo = request.getParameter("returnTo");
        try {
            int critId = Integer.parseInt(critIdStr);
            careerProgressionDAO.deleteCriteria(critId);
            request.getSession().setAttribute("successMessage", "Đã xóa nấc barem thăng tiến!");
            String redirectUrl = "detail".equals(returnTo)
                    ? request.getContextPath() + "/positions?action=detail&id=" + posIdStr
                    : request.getContextPath() + "/positions?action=criteria&positionId=" + posIdStr;
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void addRequirement(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String critIdStr = request.getParameter("criteriaId");
        String posIdStr = request.getParameter("positionId");
        String title = request.getParameter("requirementTitle");
        String type = request.getParameter("requirementType");
        String desc = request.getParameter("description");
        String isMandatoryStr = request.getParameter("isMandatory");
        String returnTo = request.getParameter("returnTo");

        try {
            int critId = Integer.parseInt(critIdStr);
            CriteriaRequirement req = new CriteriaRequirement();
            req.setCriteriaId(critId);
            req.setRequirementTitle(title != null ? title.trim() : "");
            req.setRequirementType(type != null ? type.trim() : "OTHER");
            req.setDescription(desc != null ? desc.trim() : "");
            req.setMandatory("true".equalsIgnoreCase(isMandatoryStr) || "1".equals(isMandatoryStr));
            req.setOrderIndex(1);

            int id = careerProgressionDAO.addRequirement(req);
            if (id > 0) {
                request.getSession().setAttribute("successMessage", "Đã thêm tiêu chí minh chứng thực tế mới!");
            } else {
                request.getSession().setAttribute("errorMessage", "Thêm tiêu chí thất bại!");
            }
            String redirectUrl = "detail".equals(returnTo)
                    ? request.getContextPath() + "/positions?action=detail&id=" + posIdStr
                    : request.getContextPath() + "/positions?action=criteria&positionId=" + posIdStr;
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void deleteRequirement(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String reqIdStr = request.getParameter("requirementId");
        String posIdStr = request.getParameter("positionId");
        String returnTo = request.getParameter("returnTo");
        try {
            int reqId = Integer.parseInt(reqIdStr);
            careerProgressionDAO.deleteRequirement(reqId);
            request.getSession().setAttribute("successMessage", "Đã xóa tiêu chí minh chứng!");
            String redirectUrl = "detail".equals(returnTo)
                    ? request.getContextPath() + "/positions?action=detail&id=" + posIdStr
                    : request.getContextPath() + "/positions?action=criteria&positionId=" + posIdStr;
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
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
        String search = request.getParameter("search");
        Integer deptFilter = null;
        if (deptFilterStr != null && !deptFilterStr.isEmpty() && !deptFilterStr.equals("0")) {
            try {
                deptFilter = Integer.parseInt(deptFilterStr);
            } catch (NumberFormatException ignored) {
            }
        }

        List<Department> departments;
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

        List<Position> positions = positionDAO.getPositionsByDepartment(deptFilter, search);
        List<JobLevel> jobLevels = positionDAO.getAllJobLevels();

        request.setAttribute("positions", positions);
        request.setAttribute("departments", departments);
        request.setAttribute("jobLevels", jobLevels);
        request.setAttribute("selectedDeptId", deptFilter);
        request.setAttribute("searchKeyword", search);
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

    private void showPositionDetail(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }
        try {
            int posId = Integer.parseInt(idStr);
            Position pos = positionDAO.getPositionById(posId);
            if (pos == null) {
                response.sendRedirect(request.getContextPath() + "/positions");
                return;
            }
            List<JobLevel> levels = positionDAO.getLevelsByPosition(posId);
            List<PositionLevelCriteria> criteriaList = careerProgressionDAO.getCriteriaByPosition(posId);

            request.setAttribute("position", pos);
            request.setAttribute("levels", levels);
            request.setAttribute("criteriaList", criteriaList);
            request.getRequestDispatcher("/views/positions/position-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void addPositionLevel(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posIdStr = request.getParameter("positionId");
        String name = request.getParameter("levelName");
        String rankStr = request.getParameter("rankOrder");
        String desc = request.getParameter("description");

        try {
            int posId = Integer.parseInt(posIdStr);
            int rank = Integer.parseInt(rankStr);
            if (name == null || name.trim().isEmpty() || rank <= 0) {
                request.getSession().setAttribute("errorMessage", "Vui lòng nhập tên cấp bậc và thứ tự bậc hợp lệ (> 0)!");
                response.sendRedirect(request.getContextPath() + "/positions?action=detail&id=" + posId);
                return;
            }

            JobLevel lvl = new JobLevel();
            lvl.setPositionId(posId);
            lvl.setLevelName(name.trim());
            lvl.setRankOrder(rank);
            lvl.setDescription(desc != null ? desc.trim() : "");

            int newId = positionDAO.addJobLevel(lvl);
            if (newId > 0) {
                request.getSession().setAttribute("successMessage", "Đã thêm cấp bậc '" + lvl.getLevelName() + "' cho vị trí!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể thêm cấp bậc. Vui lòng kiểm tra lại thông tin!");
            }
            response.sendRedirect(request.getContextPath() + "/positions?action=detail&id=" + posId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void editPositionLevel(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posIdStr = request.getParameter("positionId");
        String levelIdStr = request.getParameter("levelId");
        String name = request.getParameter("levelName");
        String rankStr = request.getParameter("rankOrder");
        String desc = request.getParameter("description");

        try {
            int posId = Integer.parseInt(posIdStr);
            int levelId = Integer.parseInt(levelIdStr);
            int rank = Integer.parseInt(rankStr);

            JobLevel lvl = new JobLevel();
            lvl.setLevelId(levelId);
            lvl.setPositionId(posId);
            lvl.setLevelName(name != null ? name.trim() : "");
            lvl.setRankOrder(rank);
            lvl.setDescription(desc != null ? desc.trim() : "");

            boolean ok = positionDAO.updateJobLevel(lvl);
            if (ok) {
                request.getSession().setAttribute("successMessage", "Đã cập nhật thông tin cấp bậc!");
            } else {
                request.getSession().setAttribute("errorMessage", "Cập nhật cấp bậc thất bại!");
            }
            response.sendRedirect(request.getContextPath() + "/positions?action=detail&id=" + posId);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void deletePositionLevel(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posIdStr = request.getParameter("positionId");
        String levelIdStr = request.getParameter("levelId");
        try {
            int posId = Integer.parseInt(posIdStr);
            int levelId = Integer.parseInt(levelIdStr);

            if (positionDAO.isLevelUsed(levelId)) {
                request.getSession().setAttribute("errorMessage", "Không thể xóa cấp bậc này vì đang được nhân viên giữ hoặc đang có trong barem thăng tiến!");
            } else {
                boolean ok = positionDAO.deleteJobLevel(levelId);
                if (ok) {
                    request.getSession().setAttribute("successMessage", "Đã xóa cấp bậc khỏi vị trí!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Xóa cấp bậc thất bại!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/positions?action=detail&id=" + posId);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }

    private void copyDefaultLevels(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posIdStr = request.getParameter("positionId");
        try {
            int posId = Integer.parseInt(posIdStr);
            String[][] defaults = {
                {"Intern", "1", "Thực tập sinh"},
                {"Fresher", "2", "Nhân viên mới vào nghề"},
                {"Junior", "3", "Nhân viên có 1 - 2 năm kinh nghiệm"},
                {"Middle", "4", "Nhân viên có 2 - 4 năm kinh nghiệm"},
                {"Senior", "5", "Chuyên viên có 4+ năm kinh nghiệm"},
                {"Lead", "6", "Trưởng nhóm chuyên môn"}
            };
            for (String[] def : defaults) {
                JobLevel lvl = new JobLevel();
                lvl.setPositionId(posId);
                lvl.setLevelName(def[0]);
                lvl.setRankOrder(Integer.parseInt(def[1]));
                lvl.setDescription(def[2]);
                positionDAO.addJobLevel(lvl);
            }
            request.getSession().setAttribute("successMessage", "Đã khởi tạo bộ 6 cấp bậc tiêu chuẩn cho vị trí!");
            response.sendRedirect(request.getContextPath() + "/positions?action=detail&id=" + posId);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/positions");
        }
    }
}
