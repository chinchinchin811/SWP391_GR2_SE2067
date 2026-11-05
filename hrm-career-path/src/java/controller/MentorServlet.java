package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dal.MentorDAO;
import dal.PositionDAO;
import dal.MaterialDAO;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.ArrayList;
import model.Mentor.MentorAssignment;
import model.Mentor.MentorEvaluation;
import model.Mentor.ClassMenteeEvaluation;
import model.Mentor.EvaluationCriteria;
import model.User;
import model.TrainingClass;
import java.util.Map;
import java.util.LinkedHashMap;

/**
 *
 * @author HP
 */
public class MentorServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet MentorServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet MentorServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/departments");
            return;
        }

        MentorDAO mentorDAO = new MentorDAO();

        String action = request.getParameter("action");
        if (action == null) {
            // Tự động chọn action mặc định theo quyền và trạng thái phân công
            if (currentUser.getRoleId() == 3) {
                action = "managerWorkspace";
            } else if (mentorDAO.isMentor(currentUser.getUserId())) {
                action = "myMentees";
            } else if (currentUser.getRoleId() == 2) {
                action = "evaluations";
            } else if (currentUser.getRoleId() == 4) {
                if (mentorDAO.hasMentor(currentUser.getUserId())) {
                    action = "myMentor";
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
            } else {
                action = "evaluations";
            }
        }

        switch (action) {
            case "pair":
                response.sendRedirect(request.getContextPath() + "/materials?action=classList");
                return;

            case "managerWorkspace":
                if (currentUser.getRoleId() != 3 || currentUser.getDepartmentId() == null) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                List<TrainingClass> managerClasses = new ArrayList<>();
                Map<Integer, List<ClassMenteeEvaluation>> classMentees = new LinkedHashMap<>();
                MaterialDAO materialDAO = new MaterialDAO();
                for (TrainingClass trainingClass : materialDAO.getClasses(currentUser.getUserId(), false)) {
                    if (currentUser.getDepartmentId().equals(trainingClass.getDepartmentId())) {
                        materialDAO.syncClassMentorAssignments(trainingClass.getClassId(), currentUser.getUserId());
                        managerClasses.add(trainingClass);
                        classMentees.put(trainingClass.getClassId(), mentorDAO.getClassMenteeEvaluations(trainingClass.getClassId()));
                    }
                }
                request.setAttribute("managerClasses", managerClasses);
                request.setAttribute("classMentees", classMentees);
                request.getRequestDispatcher("mentor-manager-workspace.jsp").forward(request, response);
                break;

            case "evaluations":
                if ((currentUser.getRoleId() == 3 || currentUser.getRoleId() == 4) && !mentorDAO.isMentor(currentUser.getUserId())) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                if (currentUser.getRoleId() == 4) {
                    request.setAttribute("evaluations", mentorDAO.getEvaluationsByMentor(currentUser.getUserId()));
                } else if (currentUser.getRoleId() == 3) {
                    request.setAttribute("evaluations", currentUser.getDepartmentId() == null ? new ArrayList<>() : mentorDAO.getEvaluationsByDepartment(currentUser.getDepartmentId()));
                } else if (currentUser.getRoleId() == 2) {
                    MaterialDAO hrMaterialDAO = new MaterialDAO();
                    List<TrainingClass> hrClasses = hrMaterialDAO.getClasses(null, false);
                    Map<Integer, List<ClassMenteeEvaluation>> hrClassEvaluations = new LinkedHashMap<>();
                    for (TrainingClass trainingClass : hrClasses) {
                        hrClassEvaluations.put(trainingClass.getClassId(), mentorDAO.getClassMenteeEvaluations(trainingClass.getClassId()));
                    }
                    request.setAttribute("hrClasses", hrClasses);
                    request.setAttribute("hrClassEvaluations", hrClassEvaluations);
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                request.getRequestDispatcher("mentor-evaluation.jsp").forward(request, response);
                break;

            case "myMentees":
                if (!mentorDAO.isMentor(currentUser.getUserId())) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                // Lấy danh sách Mentee của Mentor này
                request.setAttribute("myAssignments", mentorDAO.getAssignmentsByMentor(currentUser.getUserId()));
                request.getRequestDispatcher("my-mentees.jsp").forward(request, response);
                break;

            case "menteeDetail":
                // Xử lý nút "Hồ sơ"
                String menteeIdStr = request.getParameter("id");
                if (menteeIdStr != null && !menteeIdStr.isEmpty()) {
                    int menteeId = Integer.parseInt(menteeIdStr);
                    User mentee = mentorDAO.getMenteeDetail(menteeId);
                    request.setAttribute("mentee", mentee);
                }
                request.getRequestDispatcher("mentee-detail.jsp").forward(request, response);
                break;

            case "myMentor":
                // Dành riêng cho Employee (Mentee) xem Mentor phụ trách mình
                MentorAssignment myMentor = mentorDAO.getMentorByMentee(currentUser.getUserId());
                if (myMentor == null) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                request.setAttribute("myMentor", myMentor);
                request.setAttribute("myEvaluations", mentorDAO.getEvaluationsByMentee(currentUser.getUserId()));
                request.getRequestDispatcher("my-mentor.jsp").forward(request, response);
                break;

            case "evaluateForm":
                if (currentUser.getRoleId() == 3) {
                    int classId = parseInt(request.getParameter("classId"));
                    int menteeId = parseInt(request.getParameter("menteeId"));
                    if (!new MentorDAO().isMenteeInManagedClass(currentUser.getUserId(), classId, menteeId)) {
                        response.sendRedirect(request.getContextPath() + "/mentors?action=managerWorkspace");
                        return;
                    }
                    request.setAttribute("classId", classId);
                    request.setAttribute("menteeId", menteeId);
                    request.setAttribute("managerEvaluation", true);
                    request.setAttribute("mentee", mentorDAO.getMenteeDetail(menteeId));
                } else if (currentUser.getRoleId() == 4) {
                    if (!mentorDAO.ownsAssignment(parseInt(request.getParameter("assignmentId")), currentUser.getUserId())) {
                        response.sendRedirect(request.getContextPath() + "/mentors?action=myMentees");
                        return;
                    }
                }
                int aid = parseInt(request.getParameter("assignmentId"));
                if (aid > 0) {
                    request.setAttribute("assignment", mentorDAO.getAssignmentById(aid));
                }
                request.setAttribute("assignmentId", request.getParameter("assignmentId"));
                request.getRequestDispatcher("mentor-evaluate-form.jsp").forward(request, response);
                break;

            case "editEvaluation":
                int editEvalId = parseInt(request.getParameter("id"));
                if (editEvalId <= 0) {
                    response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                    return;
                }
                MentorEvaluation evalToEdit = mentorDAO.getEvaluationById(editEvalId);
                if (evalToEdit == null) {
                    session.setAttribute("errorMessage", "Không tìm thấy thông tin đánh giá.");
                    response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                    return;
                }
                // "Khi nào nhận xét đánh giá được duyệt thì mentor không thể chỉnh sửa được nữa."
                if ("APPROVED".equalsIgnoreCase(evalToEdit.getApprovalStatus())) {
                    session.setAttribute("errorMessage", "Đánh giá này đã được duyệt nên không thể chỉnh sửa.");
                    response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                    return;
                }
                if (currentUser.getRoleId() == 4) {
                    if (evalToEdit.getEvaluatorId() != currentUser.getUserId() && !mentorDAO.ownsAssignment(evalToEdit.getAssignmentId(), currentUser.getUserId())) {
                        session.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa đánh giá này.");
                        response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                        return;
                    }
                }
                MentorAssignment editAssign = mentorDAO.getAssignmentById(evalToEdit.getAssignmentId());
                request.setAttribute("evaluation", evalToEdit);
                request.setAttribute("assignment", editAssign);
                request.setAttribute("assignmentId", evalToEdit.getAssignmentId());
                request.getRequestDispatcher("mentor-evaluate-form.jsp").forward(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/departments");
            return;
        }

        String action = request.getParameter("action");

        if ("assign".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/materials?action=classList");
        } else if ("approveEvaluation".equals(action)) {
            if (currentUser.getRoleId() != 3 || currentUser.getDepartmentId() == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            int evaluationId = parseInt(request.getParameter("evaluationId"));
            boolean approved = evaluationId > 0 && new MentorDAO().approveDepartmentEvaluation(evaluationId, currentUser.getUserId());
            session.setAttribute(approved ? "successMessage" : "errorMessage",
                    approved ? "Đã duyệt đánh giá thành công." : "Đánh giá không tồn tại, đã được duyệt hoặc không thuộc phòng ban của bạn.");
            response.sendRedirect(request.getContextPath() + "/mentors?action=managerWorkspace");
        } else if ("saveEvaluation".equals(action)) {
            if (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 4) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            // Evaluate with comprehensive criteria
            String comment = request.getParameter("comment");

            double totalScore = 0.0;
            int answeredPublicCount = 0;
            StringBuilder pubFb = new StringBuilder();
            pubFb.append("【KẾT QUẢ ĐÁNH GIÁ NĂNG LỰC HỌC VIÊN】\n");

            for (EvaluationCriteria.Question q : EvaluationCriteria.PUBLIC_QUESTIONS) {
                String optCode = request.getParameter(q.getCode());
                EvaluationCriteria.Option opt = q.findOption(optCode);
                if (opt != null) {
                    totalScore += opt.getScore();
                    answeredPublicCount++;
                    pubFb.append("• ").append(q.getTitle()).append(":\n")
                         .append("  ➜ ").append(opt.getLabel()).append(" - ").append(opt.getDescription()).append("\n");
                }
            }

            // Fallback nếu dùng form cũ (checkboxes)
            if (answeredPublicCount == 0) {
                String[] visible = request.getParameterValues("visibleCriteria");
                if (visible != null && visible.length > 0) {
                    totalScore = criteriaCount(visible) * 2;
                    pubFb.append(criteriaText(visible, false)).append("\n");
                    answeredPublicCount = visible.length;
                }
            }

            if (comment != null && !comment.trim().isEmpty()) {
                pubFb.append("\n【NHẬN XÉT CỦA MENTOR】\n").append(comment.trim());
            }

            StringBuilder privFb = new StringBuilder();
            privFb.append("【ĐÁNH GIÁ NỘI BỘ (MENTOR / MANAGER / HR)】\n");
            int answeredInternalCount = 0;
            for (EvaluationCriteria.Question q : EvaluationCriteria.INTERNAL_QUESTIONS) {
                String optCode = request.getParameter(q.getCode());
                EvaluationCriteria.Option opt = q.findOption(optCode);
                if (opt != null) {
                    answeredInternalCount++;
                    privFb.append("• ").append(q.getTitle()).append(":\n")
                          .append("  ➜ ").append(opt.getLabel()).append(" - ").append(opt.getDescription()).append("\n");
                }
            }

            // Fallback nếu dùng form cũ (checkboxes)
            if (answeredInternalCount == 0) {
                String[] internal = request.getParameterValues("internalCriteria");
                if (internal != null && internal.length > 0) {
                    privFb.append(criteriaText(internal, true));
                    answeredInternalCount = internal.length;
                }
            }

            if (answeredPublicCount == 0) {
                session.setAttribute("errorMessage", "Vui lòng chọn các câu hỏi đánh giá công khai để tính điểm.");
                response.sendRedirect(request.getContextPath() + (currentUser.getRoleId() == 3 ? "/mentors?action=managerWorkspace" : "/mentors?action=myMentees"));
                return;
            }

            int score = Math.max(1, Math.min(10, (int) Math.round(totalScore)));
            String publicFeedback = pubFb.toString().trim();
            String privateFeedback = privFb.toString().trim();

            // KIỂM TRA CHỈNH SỬA ĐÁNH GIÁ (EDIT EVALUATION)
            int evaluationId = parseInt(request.getParameter("evaluationId"));
            if (evaluationId > 0) {
                MentorEvaluation existingEval = new MentorDAO().getEvaluationById(evaluationId);
                if (existingEval == null || "APPROVED".equalsIgnoreCase(existingEval.getApprovalStatus())) {
                    session.setAttribute("errorMessage", "Đánh giá đã được phê duyệt hoặc không tồn tại, không thể chỉnh sửa!");
                    response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                    return;
                }
                if (currentUser.getRoleId() == 4 && existingEval.getEvaluatorId() != currentUser.getUserId() && !new MentorDAO().ownsAssignment(existingEval.getAssignmentId(), currentUser.getUserId())) {
                    session.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa đánh giá này.");
                    response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                    return;
                }
                boolean updateOk = new MentorDAO().updateEvaluation(evaluationId, currentUser.getUserId(), score, publicFeedback, privateFeedback);
                if (updateOk) {
                    session.setAttribute("successMessage", "Cập nhật đánh giá Mentee thành công!");
                } else {
                    session.setAttribute("errorMessage", "Cập nhật đánh giá thất bại.");
                }
                response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
                return;
            }

            if (currentUser.getRoleId() == 3) {
                int classId = parseInt(request.getParameter("classId"));
                int menteeId = parseInt(request.getParameter("menteeId"));
                boolean success = new MentorDAO().saveClassEvaluation(classId, menteeId, currentUser.getUserId(), score, publicFeedback, privateFeedback);
                session.setAttribute(success ? "successMessage" : "errorMessage", success ? "Lưu đánh giá Mentee thành công!" : "Không thể lưu đánh giá cho mentee này.");
                response.sendRedirect(request.getContextPath() + "/mentors?action=managerWorkspace");
                return;
            }
            String assignmentIdStr = request.getParameter("assignmentId");
            String scoreStr = String.valueOf(score);
            
            if (assignmentIdStr != null && !assignmentIdStr.isEmpty()) {
                int assignmentId = Integer.parseInt(assignmentIdStr);
                if (!new MentorDAO().ownsAssignment(assignmentId, currentUser.getUserId())) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                int currentScore = 8;
                if (scoreStr != null && !scoreStr.trim().isEmpty()) {
                    try {
                        currentScore = Integer.parseInt(scoreStr.trim());
                    } catch (NumberFormatException ignored) {}
                }
                
                // Lưu đánh giá với đầy đủ Public Feedback (Non-anonymous) và Private Feedback (Anonymous)
                boolean success = new MentorDAO().saveEvaluation(assignmentId, currentUser.getUserId(), currentScore, publicFeedback, privateFeedback);
                
                if (success) {
                    session.setAttribute("successMessage", "Lưu đánh giá Mentee thành công!");
                }
            }
            // LƯU Ý QUAN TRỌNG: Phải có lệnh sendRedirect để tránh màn hình trắng
            response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
        }

    }

    private int parseInt(String value) {
        try { return Integer.parseInt(value); } catch (Exception e) { return 0; }
    }

    private String criteriaText(String[] selected, boolean internal) {
        String[] labels = internal
                ? new String[]{"Chủ động và trách nhiệm", "Tuân thủ quy trình", "Giao tiếp và phối hợp", "Tiếp thu phản hồi", "Tiềm năng phát triển"}
                : new String[]{"Hoàn thành nhiệm vụ đúng hạn", "Chất lượng công việc đạt yêu cầu", "Nắm vững kiến thức chuyên môn", "Chủ động học hỏi", "Phối hợp tốt với đồng đội"};
        StringBuilder text = new StringBuilder();
        boolean[] included = new boolean[labels.length];
        if (selected != null) for (String value : selected) {
            int i = parseInt(value);
            if (i >= 0 && i < labels.length) included[i] = true;
        }
        for (int i = 0; i < included.length; i++) if (included[i]) text.append("• ").append(labels[i]).append("\n");
        return text.toString().trim();
    }

    private int criteriaCount(String[] selected) {
        if (selected == null) return 0;
        boolean[] included = new boolean[5];
        for (String value : selected) {
            int i = parseInt(value);
            if (i >= 0 && i < included.length) included[i] = true;
        }
        int count = 0;
        for (boolean value : included) if (value) count++;
        return count;
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Mentor Management Servlet";
    }// </editor-fold>

}
