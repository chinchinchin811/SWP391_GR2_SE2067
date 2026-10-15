package controller;

import dal.FlashcardDAO;
import dal.PositionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Flashcard.Flashcard;
import model.Flashcard.FlashcardDeck;
import model.Position;
import model.User;

public class FlashcardServlet extends HttpServlet {

    private static final String CULTURE = "culture";
    private static final String PROFESSIONAL = "professional";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request, response);
        if (user == null) {
            return;
        }
        if (user.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/departments");
            return;
        }

        FlashcardDAO dao = new FlashcardDAO();
        boolean canManageCulture = user.getRoleId() == 2;
        boolean canManageProfessional = user.getRoleId() == 3 || dao.isActiveMentor(user.getUserId());
        request.setAttribute("canManageCulture", canManageCulture);
        request.setAttribute("canManageProfessional", canManageProfessional);
        request.setAttribute("positions", new PositionDAO().getAllPositions());

        String action = request.getParameter("action");
        try {
            if ("createDeck".equals(action)) {
                String type = request.getParameter("type");
                if (!canManageType(type, canManageCulture, canManageProfessional)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                FlashcardDeck deck = new FlashcardDeck();
                deck.setType(type);
                request.setAttribute("editDeck", deck);
                request.setAttribute("cards", List.of());
                request.getRequestDispatcher("flashcard-manage.jsp").forward(request, response);
                return;
            }

            if ("editDeck".equals(action) || "manageCards".equals(action)) {
                FlashcardDeck deck = dao.getDeckById(parseId(request.getParameter("deckId")));
                if (deck == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                if (!canManageDeck(deck, canManageCulture, canManageProfessional)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                request.setAttribute("editDeck", deck);
                request.setAttribute("cards", dao.getCardsByDeckId(deck.getDeckId()));
                request.getRequestDispatcher("flashcard-manage.jsp").forward(request, response);
                return;
            }

            List<FlashcardDeck> decks = dao.getAllDecks();
            int currentDeckId = parseId(request.getParameter("deckId"));
            FlashcardDeck currentDeck = findDeck(decks, currentDeckId);
            if (currentDeck == null && !decks.isEmpty()) {
                currentDeck = decks.get(0);
            }
            List<Flashcard> cards = currentDeck == null ? List.of() : dao.getCardsByDeckId(currentDeck.getDeckId());
            request.setAttribute("decks", decks);
            request.setAttribute("cards", cards);
            request.setAttribute("currentDeck", currentDeck);
            request.setAttribute("currentUser", user);
            request.getRequestDispatcher("flashcard-list.jsp").forward(request, response);
        } catch (IllegalStateException e) {
            throw new ServletException("Không thể tải hoặc cập nhật dữ liệu Flashcard.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getCurrentUser(request, response);
        if (user == null) {
            return;
        }
        if (user.getRoleId() == 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        FlashcardDAO dao = new FlashcardDAO();
        boolean canManageCulture = user.getRoleId() == 2;
        boolean canManageProfessional = user.getRoleId() == 3 || dao.isActiveMentor(user.getUserId());
        String action = request.getParameter("action");
        try {
            switch (action == null ? "" : action) {
                case "createDeck": {
                    String type = request.getParameter("deckType");
                    if (!canManageType(type, canManageCulture, canManageProfessional)) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    String title = clean(request.getParameter("title"));
                    if (title.isEmpty()) {
                        redirectToEditor(request, response, "createDeck", 0, type, "invalidTitle");
                        return;
                    }
                    Integer positionId = PROFESSIONAL.equals(type) ? parseNullableId(request.getParameter("positionId")) : null;
                    if (!isAvailablePosition(positionId)) {
                        redirectToEditor(request, response, "createDeck", 0, type, "invalidPosition");
                        return;
                    }
                    int deckId = dao.createDeck(title, clean(request.getParameter("description")), type, positionId);
                    if (deckId > 0) {
                        response.sendRedirect(manageUrl(request, "editDeck", deckId, "created"));
                    } else {
                        response.sendRedirect(request.getContextPath() + "/flashcards");
                    }
                    return;
                }
                case "updateDeck": {
                    int deckId = parseId(request.getParameter("deckId"));
                    FlashcardDeck deck = dao.getDeckById(deckId);
                    if (deck == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }
                    if (!canManageDeck(deck, canManageCulture, canManageProfessional)) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    String title = clean(request.getParameter("title"));
                    if (title.isEmpty()) {
                        response.sendRedirect(manageUrl(request, "editDeck", deckId, "invalidTitle"));
                        return;
                    }
                    Integer positionId = PROFESSIONAL.equals(deck.getType()) ? parseNullableId(request.getParameter("positionId")) : null;
                    if (!isAvailablePosition(positionId)) {
                        response.sendRedirect(manageUrl(request, "editDeck", deckId, "invalidPosition"));
                        return;
                    }
                    dao.updateDeck(deckId, title, clean(request.getParameter("description")), positionId);
                    response.sendRedirect(manageUrl(request, "editDeck", deckId, "updated"));
                    return;
                }
                case "deleteDeck": {
                    int deckId = parseId(request.getParameter("deckId"));
                    FlashcardDeck deck = dao.getDeckById(deckId);
                    if (deck == null) {
                        response.sendRedirect(request.getContextPath() + "/flashcards");
                        return;
                    }
                    if (!canManageDeck(deck, canManageCulture, canManageProfessional)) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    dao.deleteDeck(deckId);
                    response.sendRedirect(request.getContextPath() + "/flashcards?notice=deleted");
                    return;
                }
                case "createCard":
                case "updateCard":
                case "deleteCard": {
                    int deckId = parseId(request.getParameter("deckId"));
                    FlashcardDeck deck = dao.getDeckById(deckId);
                    if (deck == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }
                    if (!canManageDeck(deck, canManageCulture, canManageProfessional)) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    if ("createCard".equals(action)) {
                        String question = clean(request.getParameter("question"));
                        String answer = clean(request.getParameter("answer"));
                        if (question.isEmpty() || answer.isEmpty()) {
                            response.sendRedirect(manageUrl(request, "editDeck", deckId, "invalidCard"));
                            return;
                        }
                        dao.createCard(deckId, question, answer);
                    } else if ("updateCard".equals(action)) {
                        String question = clean(request.getParameter("question"));
                        String answer = clean(request.getParameter("answer"));
                        if (question.isEmpty() || answer.isEmpty()) {
                            response.sendRedirect(manageUrl(request, "editDeck", deckId, "invalidCard"));
                            return;
                        }
                        dao.updateCard(parseId(request.getParameter("cardId")), deckId, question, answer);
                    } else {
                        dao.deleteCard(parseId(request.getParameter("cardId")), deckId);
                    }
                    response.sendRedirect(manageUrl(request, "editDeck", deckId, "updated"));
                    return;
                }
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (IllegalStateException e) {
            throw new ServletException("Không thể cập nhật dữ liệu Flashcard.", e);
        }
    }

    private User getCurrentUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("currentUser");
    }

    private boolean canManageType(String type, boolean canManageCulture, boolean canManageProfessional) {
        return (CULTURE.equals(type) && canManageCulture)
                || (PROFESSIONAL.equals(type) && canManageProfessional);
    }

    private boolean canManageDeck(FlashcardDeck deck, boolean canManageCulture, boolean canManageProfessional) {
        return deck != null && canManageType(deck.getType(), canManageCulture, canManageProfessional);
    }

    private FlashcardDeck findDeck(List<FlashcardDeck> decks, int deckId) {
        for (FlashcardDeck deck : decks) {
            if (deck.getDeckId() == deckId) {
                return deck;
            }
        }
        return null;
    }

    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException | NullPointerException e) {
            return -1;
        }
    }

    private Integer parseNullableId(String value) {
        int id = parseId(value);
        return id > 0 ? id : null;
    }

    private boolean isAvailablePosition(Integer positionId) {
        if (positionId == null) {
            return true;
        }
        for (Position position : new PositionDAO().getAllPositions()) {
            if (position.getPositionId() == positionId) {
                return true;
            }
        }
        return false;
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private void redirectToEditor(HttpServletRequest request, HttpServletResponse response,
            String action, int deckId, String type, String notice) throws IOException {
        if (deckId > 0) {
            response.sendRedirect(manageUrl(request, action, deckId, notice));
        } else {
            response.sendRedirect(request.getContextPath() + "/flashcards?action=" + action
                    + "&type=" + type + "&notice=" + notice);
        }
    }

    private String manageUrl(HttpServletRequest request, String action, int deckId, String notice) {
        return request.getContextPath() + "/flashcards?action=" + action
                + "&deckId=" + deckId + "&notice=" + notice;
    }
}
