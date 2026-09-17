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
import java.util.List;
import dal.FlashcardDAO;
import model.Flashcard;
import model.FlashcardDeck;

/**
 *
 * @author HP
 */
public class FlashcardServlet extends HttpServlet {

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
            out.println("<title>Servlet FlashcardServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet FlashcardServlet at " + request.getContextPath() + "</h1>");
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
        FlashcardDAO dao = new FlashcardDAO();
        List<FlashcardDeck> decks = dao.getAllDecks();

        int currentDeckId = -1;
        String deckIdParam = request.getParameter("deckId");

        if (deckIdParam != null && !deckIdParam.isEmpty()) {
            currentDeckId = Integer.parseInt(deckIdParam);
        } else if (decks != null && !decks.isEmpty()) {
            currentDeckId = decks.get(0).getDeckId(); // Default lấy bộ thẻ đầu tiên
        }

        FlashcardDeck currentDeck = null;
        List<Flashcard> cards = null;

        if (currentDeckId != -1) {
            cards = dao.getCardsByDeckId(currentDeckId);
            for (FlashcardDeck d : decks) {
                if (d.getDeckId() == currentDeckId) {
                    currentDeck = d;
                    break;
                }
            }
        }

        request.setAttribute("decks", decks);
        request.setAttribute("cards", cards);
        request.setAttribute("currentDeck", currentDeck);

        // Điều hướng tới file giao diện flashcard
        request.getRequestDispatcher("/views/flashcard-list.jsp").forward(request, response);

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
        processRequest(request, response);
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
