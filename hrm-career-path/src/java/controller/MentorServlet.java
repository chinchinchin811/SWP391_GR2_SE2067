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
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import model.Mentor.MentorAssignment;
import model.Mentor.MentorEvaluation;
import model.User;
import model.TrainingClass;
import model.ClassEnrollment;
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
            /* TODO output your page here. You may use following sample code. */
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
                Map<Integer, List<ClassEnrollment>> classMentees = new LinkedHashMap<>();
                MaterialDAO materialDAO = new MaterialDAO();
                for (TrainingClass trainingClass : materialDAO.getClasses(currentUser.getUserId(), false)) {
                    if (currentUser.getDepartmentId().equals(trainingClass.getDepartmentId())) {
                        materialDAO.syncClassMentorAssignments(trainingClass.getClassId(), currentUser.getUserId());
                        managerClasses.add(trainingClass);
                        classMentees.put(trainingClass.getClassId(), materialDAO.getEnrollments(trainingClass.getClassId()));
                    }
                }
                request.setAttribute("managerClasses", managerClasses);
                request.setAttribute("classMentees", classMentees);
                request.setAttribute("managerEvaluations", mentorDAO.getEvaluationsByDepartment(currentUser.getDepartmentId()));
                request.getRequestDispatcher("mentor-manager-workspace.jsp").forward(request, response);
                break;

            case "evaluations":
                if (currentUser.getRoleId() == 4 && !mentorDAO.isMentor(currentUser.getUserId())) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                if (currentUser.getRoleId() == 4) {
                    request.setAttribute("evaluations", mentorDAO.getEvaluationsByMentor(currentUser.getUserId()));
                } else if (currentUser.getRoleId() == 3) {
                    request.setAttribute("evaluations", currentUser.getDepartmentId() == null ? new ArrayList<>() : mentorDAO.getEvaluationsByDepartment(currentUser.getDepartmentId()));
                } else if (currentUser.getRoleId() == 2) {
                    request.setAttribute("evaluations", mentorDAO.getAllEvaluations());
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                request.getRequestDispatcher("mentor-evaluation.jsp").forward(request, response);
                break;

            case "myMentees":
                if (currentUser.getRoleId() != 4 || !mentorDAO.isMentor(currentUser.getUserId())) {
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
                } else if (currentUser.getRoleId() == 4) {
                    if (!mentorDAO.ownsAssignment(parseInt(request.getParameter("assignmentId")), currentUser.getUserId())) {
                        response.sendRedirect(request.getContextPath() + "/mentors?action=myMentees");
                        return;
                    }
                }
                request.setAttribute("assignmentId", request.getParameter("assignmentId"));
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
        } else if ("saveEvaluation".equals(action)) {
            if (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 4) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            String[] visible = request.getParameterValues("visibleCriteria");
            String[] internal = request.getParameterValues("internalCriteria");
            String comment = request.getParameter("comment");
            String publicFeedback = criteriaText(visible, false) + (comment == null || comment.trim().isEmpty() ? "" : "\n\nNhận xét: " + comment.trim());
            String privateFeedback = criteriaText(internal, true);
            int score = criteriaCount(visible) * 2;
            if (score == 0) {
                session.setAttribute("errorMessage", "Hãy chọn ít nhất một tiêu chí công khai để tính điểm.");
                response.sendRedirect(request.getContextPath() + (currentUser.getRoleId() == 3 ? "/mentors?action=managerWorkspace" : "/mentors?action=myMentees"));
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
