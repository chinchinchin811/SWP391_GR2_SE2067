/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dal.MentorDAO;
import dal.PositionDAO;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Mentor.MentorAssignment;
import model.Mentor.MentorEvaluation;
import model.User;

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

        String action = request.getParameter("action");
        if (action == null) {
            // Tự động chọn action mặc định theo Role
            if (currentUser.getRoleId() == 4) {
                action = "myMentor";
            } else if (currentUser.getRoleId() == 5) {
                action = "myMentees";
            } else {
                action = "evaluations";
            }
        }

        MentorDAO mentorDAO = new MentorDAO();

        switch (action) {
            case "pair":
                if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                request.setAttribute("newEmployees", mentorDAO.getUnassignedNewEmployees());
                request.setAttribute("mentors", mentorDAO.getAllMentorsWithSpecialty());
                request.setAttribute("assignments", mentorDAO.getActiveAssignments());
                request.getRequestDispatcher("mentor-pairing.jsp").forward(request, response);
                break;

            case "evaluations":
                if (currentUser.getRoleId() == 4) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                request.setAttribute("evaluations", mentorDAO.getAllEvaluations());
                request.getRequestDispatcher("mentor-evaluation.jsp").forward(request, response);
                break;

            case "myMentees":
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
                request.setAttribute("myMentor", myMentor);
                request.getRequestDispatcher("my-mentor.jsp").forward(request, response);
                break;

            case "evaluateForm":
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

        String action = request.getParameter("action");

        if ("assign".equals(action)) {
            // SỬA LỖI: Cần lấy String trước, kiểm tra null/empty để tránh lỗi 500
            String menteeIdStr = request.getParameter("menteeId");
            String mentorIdStr = request.getParameter("mentorId");

            if (menteeIdStr != null && mentorIdStr != null && !menteeIdStr.isEmpty() && !mentorIdStr.isEmpty()) {
                int menteeId = Integer.parseInt(menteeIdStr);
                int mentorId = Integer.parseInt(mentorIdStr);

                int positionId = 0;
                String posParam = request.getParameter("positionId");
                if (posParam != null && !posParam.trim().isEmpty()) {
                    positionId = Integer.parseInt(posParam);
                }

                boolean success = new MentorDAO().assignMentorWithPosition(menteeId, mentorId, positionId, currentUser.getUserId());
                if (success) {
                    session.setAttribute("successMessage", "Ghep Mentor thanh cong!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/mentors?action=pair");
        }else if ("saveEvaluation".equals(action)) {
            String assignmentIdStr = request.getParameter("assignmentId");
            String feedback = request.getParameter("feedback");
            
            if (assignmentIdStr != null && !assignmentIdStr.isEmpty()) {
                int assignmentId = Integer.parseInt(assignmentIdStr);
                
                // Gọi DAO để lưu vào Database (mặc định cho điểm 8, trạng thái PENDING)
                boolean success = new MentorDAO().saveEvaluation(assignmentId, currentUser.getUserId(), 8, feedback);
                
                if (success) {
                    session.setAttribute("successMessage", "Lưu đánh giá thành công!");
                }
            }
            // LƯU Ý QUAN TRỌNG: Phải có lệnh sendRedirect để tránh màn hình trắng
            response.sendRedirect(request.getContextPath() + "/mentors?action=evaluations");
        }

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
