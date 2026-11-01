package controller;

import dal.CareerProgressionDAO;
import dal.DepartmentDAO;
import dal.PositionDAO;
import dal.UserDAO;
import model.Department;
import model.JobLevel;
import model.PositionLevelCriteria;
import model.PromotionEvidence;
import model.PromotionRequest;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

public class CareerPathServlet extends HttpServlet {

    private final CareerProgressionDAO careerProgressionDAO = new CareerProgressionDAO();
    private final UserDAO userDAO = new UserDAO();
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
        String servletPath = request.getServletPath();

        if ("/career-path".equals(servletPath)) {
            showMyCareerPath(request, response, currentUser);
        } else {
            // /promotions path
            String action = request.getParameter("action");
            if ("review".equals(action)) {
                showReviewDetail(request, response, currentUser);
            } else {
                showPromotionList(request, response, currentUser);
            }
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

        if ("submitPromotion".equals(action)) {
            submitPromotionRequest(request, response, currentUser);
        } else if ("submitSingleEvidence".equals(action)) {
            submitSingleEvidence(request, response, currentUser);
        } else if ("verifyEvidence".equals(action)) {
            verifyEvidence(request, response, currentUser);
        } else if ("submitManagerReview".equals(action)) {
            submitManagerReview(request, response, currentUser);
        } else if ("hrDecision".equals(action)) {
            submitHrDecision(request, response, currentUser);
        } else if ("reopenPromotion".equals(action)) {
            reopenPromotion(request, response, currentUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    // ==========================================
    // GET HANDLERS
    // ==========================================

    private void showMyCareerPath(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        User employee = userDAO.getUserById(currentUser.getUserId());
        List<JobLevel> allLevels = null;
        if (employee != null && employee.getPositionId() != null) {
            allLevels = positionDAO.getLevelsByPosition(employee.getPositionId());
        }
        if (allLevels == null || allLevels.isEmpty()) {
            allLevels = positionDAO.getAllJobLevels();
        }

        JobLevel currentLevel = null;
        JobLevel nextLevel = null;

        if (employee != null && employee.getLevelId() != null) {
            for (JobLevel lvl : allLevels) {
                if (lvl.getLevelId() == employee.getLevelId()) {
                    currentLevel = lvl;
                    break;
                }
            }
        }

        if (currentLevel != null) {
            int nextRank = currentLevel.getRankOrder() + 1;
            for (JobLevel lvl : allLevels) {
                if (lvl.getRankOrder() == nextRank) {
                    nextLevel = lvl;
                    break;
                }
            }
        }

        PositionLevelCriteria criteria = null;
        PromotionRequest existingRequest = null;
        if (employee != null && employee.getPositionId() != null && currentLevel != null && nextLevel != null) {
            criteria = careerProgressionDAO.getCriteriaByStep(employee.getPositionId(), currentLevel.getLevelId(), nextLevel.getLevelId());
            if (criteria != null) {
                // Tự động lấy hoặc tạo hồ sơ tích lũy lũy tiến
                existingRequest = careerProgressionDAO.getOrCreateActivePromotionRequest(
                        currentUser.getUserId(),
                        employee.getPositionId(),
                        currentLevel.getLevelId(),
                        nextLevel.getLevelId(),
                        criteria.getCriteriaId()
                );
            }
        }

        request.setAttribute("employee", employee);
        request.setAttribute("currentLevel", currentLevel);
        request.setAttribute("nextLevel", nextLevel);
        request.setAttribute("criteria", criteria);
        request.setAttribute("existingRequest", existingRequest);
        request.setAttribute("allLevels", allLevels);

        request.getRequestDispatcher("/views/career/my-career-path.jsp").forward(request, response);
    }

    private void showPromotionList(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        List<PromotionRequest> list;

        if (currentUser.getRoleId() == 3) {
            // Manager: Chỉ xem nhân viên trong phòng ban mình quản lý
            Department dept = departmentDAO.getDepartmentByManagerId(currentUser.getUserId());
            if (dept != null) {
                list = careerProgressionDAO.getPromotionRequestsByDepartment(dept.getDepartmentId());
            } else {
                list = new java.util.ArrayList<>();
            }
        } else if (currentUser.getRoleId() == 1 || currentUser.getRoleId() == 2) {
            // Admin hoặc HR: Xem toàn bộ các hồ sơ đề xuất
            list = careerProgressionDAO.getAllPromotionRequests();
        } else {
            response.sendRedirect(request.getContextPath() + "/career-path");
            return;
        }

        request.setAttribute("requests", list);
        request.getRequestDispatcher("/views/career/promotion-list.jsp").forward(request, response);
    }

    private void showReviewDetail(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String reqIdStr = request.getParameter("id");
        if (reqIdStr == null || reqIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/promotions");
            return;
        }

        try {
            int reqId = Integer.parseInt(reqIdStr);
            PromotionRequest reqItem = careerProgressionDAO.getPromotionRequestById(reqId);
            if (reqItem == null) {
                response.sendRedirect(request.getContextPath() + "/promotions");
                return;
            }

            request.setAttribute("requestItem", reqItem);
            request.getRequestDispatcher("/views/career/promotion-review.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/promotions");
        }
    }

    // ==========================================
    // POST HANDLERS
    // ==========================================

    private void submitPromotionRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String posIdStr = request.getParameter("positionId");
        String curLevelStr = request.getParameter("currentLevelId");
        String targetLevelStr = request.getParameter("targetLevelId");
        String critIdStr = request.getParameter("criteriaId");

        try {
            int posId = Integer.parseInt(posIdStr);
            int curLevel = Integer.parseInt(curLevelStr);
            int targetLevel = Integer.parseInt(targetLevelStr);
            int critId = Integer.parseInt(critIdStr);

            PromotionRequest pr = new PromotionRequest();
            pr.setUserId(currentUser.getUserId());
            pr.setPositionId(posId);
            pr.setCurrentLevelId(curLevel);
            pr.setTargetLevelId(targetLevel);
            pr.setCriteriaId(critId);

            int reqId = careerProgressionDAO.createPromotionRequest(pr);
            if (reqId > 0) {
                // Đọc danh sách các requirements đã nộp
                String[] reqIds = request.getParameterValues("requirementId");
                if (reqIds != null) {
                    for (String rId : reqIds) {
                        int requirementId = Integer.parseInt(rId);
                        String summary = request.getParameter("evidenceSummary_" + requirementId);
                        String url = request.getParameter("evidenceUrl_" + requirementId);

                        if (summary != null && !summary.trim().isEmpty()) {
                            PromotionEvidence ev = new PromotionEvidence();
                            ev.setRequestId(reqId);
                            ev.setRequirementId(requirementId);
                            ev.setEvidenceSummary(summary.trim());
                            ev.setEvidenceUrl(url != null ? url.trim() : null);
                            careerProgressionDAO.addPromotionEvidence(ev);
                        }
                    }
                }
                request.getSession().setAttribute("successMessage", "Hồ sơ đề xuất thăng cấp đã được gửi thành công tới Quản lý để thẩm định!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể nộp hồ sơ, vui lòng kiểm tra lại thông tin!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Đã xảy ra lỗi trong quá trình nộp hồ sơ!");
        }

        response.sendRedirect(request.getContextPath() + "/career-path");
    }

    private void submitSingleEvidence(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String reqIdStr = request.getParameter("requestId");
        String rIdStr = request.getParameter("requirementId");
        String summary = request.getParameter("evidenceSummary");
        String url = request.getParameter("evidenceUrl");

        try {
            int requestId = Integer.parseInt(reqIdStr);
            int requirementId = Integer.parseInt(rIdStr);

            if (summary == null || summary.trim().isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Vui lòng nhập tóm tắt minh chứng!");
                response.sendRedirect(request.getContextPath() + "/career-path");
                return;
            }

            boolean ok = careerProgressionDAO.submitOrUpdateEvidence(requestId, requirementId, summary.trim(), url != null ? url.trim() : null);
            if (ok) {
                boolean autoPromoted = careerProgressionDAO.checkAndAutoPromote(requestId, currentUser.getUserId());
                if (autoPromoted) {
                    request.getSession().setAttribute("successMessage", "Chúc mừng! Bạn đã hoàn thành tất cả điều kiện bắt buộc và được hệ thống tự động thăng cấp lên bậc mới!");
                } else {
                    request.getSession().setAttribute("successMessage", "Đã lưu minh chứng thành công! Đang chờ Quản lý thẩm định.");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể lưu minh chứng, vui lòng thử lại!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Đã xảy ra lỗi khi lưu minh chứng!");
        }

        response.sendRedirect(request.getContextPath() + "/career-path");
    }

    private void verifyEvidence(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String evIdStr = request.getParameter("evidenceId");
        String reqIdStr = request.getParameter("requestId");
        String isVerifiedStr = request.getParameter("isVerified");

        try {
            int evId = Integer.parseInt(evIdStr);
            int reqId = Integer.parseInt(reqIdStr);
            boolean verified = "true".equalsIgnoreCase(isVerifiedStr);
            careerProgressionDAO.verifyEvidence(evId, verified, null);

            // Kiểm tra tự động thăng cấp khi thẩm định đạt
            if (verified) {
                boolean autoPromoted = careerProgressionDAO.checkAndAutoPromote(reqId, currentUser.getUserId());
                if (autoPromoted) {
                    request.getSession().setAttribute("successMessage", "Đã duyệt minh chứng và HỆ THỐNG ĐÃ TỰ ĐỘNG THĂNG CẤP THÀNH CÔNG CHO NHÂN SỰ!");
                    response.sendRedirect(request.getContextPath() + "/promotions?action=review&id=" + reqIdStr);
                    return;
                }
                request.getSession().setAttribute("successMessage", "Đã ghi nhận ĐẠT cho minh chứng.");
            } else {
                request.getSession().setAttribute("successMessage", "Đã hủy duyệt (chuyển về Chưa duyệt) cho minh chứng.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/promotions?action=review&id=" + reqIdStr);
    }

    private void reopenPromotion(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String reqIdStr = request.getParameter("requestId");
        try {
            int reqId = Integer.parseInt(reqIdStr);
            boolean ok = careerProgressionDAO.reopenPromotionRequest(reqId);
            if (ok) {
                request.getSession().setAttribute("successMessage", "Đã mở lại hồ sơ để Quản lý tiếp tục thẩm định và chỉnh sửa minh chứng.");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể mở lại hồ sơ này.");
            }
            response.sendRedirect(request.getContextPath() + "/promotions?action=review&id=" + reqId);
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/promotions");
    }

    private void submitManagerReview(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String reqIdStr = request.getParameter("requestId");
        String ratingStr = request.getParameter("managerRating");
        String decision = request.getParameter("managerDecision");
        String notes = request.getParameter("managerNotes");

        try {
            int reqId = Integer.parseInt(reqIdStr);
            BigDecimal rating = new BigDecimal(ratingStr != null ? ratingStr.trim() : "8.0");

            boolean ok = careerProgressionDAO.managerReview(reqId, currentUser.getUserId(), rating, notes, decision);
            if (ok) {
                if ("RECOMMENDED".equalsIgnoreCase(decision)) {
                    boolean autoPromoted = careerProgressionDAO.checkAndAutoPromote(reqId, currentUser.getUserId());
                    if (autoPromoted) {
                        request.getSession().setAttribute("successMessage", "Đã đánh giá đạt và HỆ THỐNG ĐÃ TỰ ĐỘNG THĂNG CẤP THÀNH CÔNG CHO NHÂN SỰ!");
                    } else {
                        request.getSession().setAttribute("successMessage", "Đã lưu phiếu đánh giá kín của Quản lý!");
                    }
                } else {
                    request.getSession().setAttribute("successMessage", "Đã từ chối đề xuất nâng bậc.");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Thao tác đánh giá thất bại!");
            }
            response.sendRedirect(request.getContextPath() + "/promotions?action=review&id=" + reqId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/promotions");
        }
    }

    private void submitHrDecision(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String reqIdStr = request.getParameter("requestId");
        String decision = request.getParameter("hrDecision");
        String notes = request.getParameter("hrNotes");

        try {
            int reqId = Integer.parseInt(reqIdStr);
            PromotionRequest reqItem = careerProgressionDAO.getPromotionRequestById(reqId);
            if (reqItem != null) {
                boolean ok = careerProgressionDAO.hrApproveAndPromote(
                        reqId, currentUser.getUserId(), decision, notes,
                        reqItem.getUserId(), reqItem.getTargetLevelId(), reqItem.getCurrentLevelId(), reqItem.getPositionId()
                );
                if (ok) {
                    if ("APPROVED".equalsIgnoreCase(decision)) {
                        request.getSession().setAttribute("successMessage", "ĐÃ BAN HÀNH QUYẾT ĐỊNH BỔ NHIỆM & CẬP NHẬT CẤP BẬC MỚI THÀNH CÔNG CHO NHÂN SỰ!");
                    } else {
                        request.getSession().setAttribute("successMessage", "Đã từ chối bổ nhiệm.");
                    }
                } else {
                    request.getSession().setAttribute("errorMessage", "Thao tác xử lý của HR thất bại!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/promotions?action=review&id=" + reqId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/promotions");
        }
    }
}

