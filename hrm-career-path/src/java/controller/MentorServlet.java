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
import jakarta.servlet.http.HttpSession;
import model.MentorEvaluation;
import model.User;
import java.util.List;

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
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "evaluations";
        }

        MentorDAO mentorDAO = new MentorDAO();

        // Employee (Role 4) KHÔNG ĐƯỢC VÀO TRANG MENTOR
        if (currentUser.getRoleId() == 4) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        switch (action) {
            case "pair":
                // Chỉ Admin (1) và HR (2) được vào ghép cặp
                if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }

                // Lấy danh sách nhân viên mới chưa có mentor và danh sách Mentor
                List<User> newEmployees = mentorDAO.getUnassignedNewEmployees();
                List<User> mentors = mentorDAO.getAllMentorsWithSpecialty();

                request.setAttribute("newEmployees", newEmployees);
                request.setAttribute("mentors", mentors);

                request.getRequestDispatcher("/views/mentor-pairing.jsp").forward(request, response);
                break;

            case "evaluations":
                List<MentorEvaluation> evals = mentorDAO.getAllEvaluations();
                request.setAttribute("evaluations", evals);
                request.getRequestDispatcher("/views/mentor-evaluation.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/dashboard");
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
        String action = request.getParameter("action");

        MentorDAO mentorDAO = new MentorDAO();

        if ("assign".equals(action)) {
            int menteeId = Integer.parseInt(request.getParameter("menteeId"));
            int mentorId = Integer.parseInt(request.getParameter("mentorId"));

            boolean success = mentorDAO.assignMentor(menteeId, mentorId, currentUser.getUserId());
            if (success) {
                session.setAttribute("successMessage", "Đã gán Mentor thành công cho nhân viên!");
            }
            response.sendRedirect(request.getContextPath() + "/mentors?action=pair");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
