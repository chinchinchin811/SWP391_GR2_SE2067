<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Flashcard.Flashcard" %>
<%@ page import="model.Flashcard.FlashcardDeck" %>
<%
    List<FlashcardDeck> decks = (List<FlashcardDeck>) request.getAttribute("decks");
    List<Flashcard> cards = (List<Flashcard>) request.getAttribute("cards");
    FlashcardDeck currentDeck = (FlashcardDeck) request.getAttribute("currentDeck");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<style>
    /* CSS toi gian cho Flashcard The lật */
    .flashcard-container {
        display: flex; gap: 20px;
    }
    .deck-sidebar {
        width: 250px; border-right: 2px solid #000; padding-right: 15px;
    }
    .deck-item {
        display: block; padding: 10px; margin-bottom: 10px;
        border: 1px solid #000; text-decoration: none; color: #000;
        font-weight: bold;
    }
    .deck-item:hover, .deck-item.active {
        background: #000; color: #fff;
    }
    .card-area {
        flex: 1; padding: 20px; text-align: center;
    }
    .flashcard {
        width: 400px; height: 250px; margin: 0 auto;
        perspective: 1000px; cursor: pointer;
    }
    .flashcard-inner {
        width: 100%; height: 100%; text-align: center;
        transition: transform 0.6s; transform-style: preserve-3d;
    }
    .flashcard.flipped .flashcard-inner {
        transform: rotateY(180deg);
    }
    .flashcard-front, .flashcard-back {
        width: 100%; height: 100%; position: absolute;
        backface-visibility: hidden; display: flex;
        align-items: center; justify-content: center;
        border: 3px solid #000; padding: 20px; box-sizing: border-box;
        font-size: 20px; font-weight: bold; background: #fff;
    }
    .flashcard-front { color: #000; }
    .flashcard-back {
        background: #000; color: #fff; transform: rotateY(180deg);
    }
</style>

<main class="main-content">
    <div class="topbar"><h1>Học Tập: Flashcards</h1></div>

    <div class="content-body flashcard-container">
        <!-- Sidebar danh sách bộ thẻ -->
        <div class="deck-sidebar">
            <h3 style="border-bottom: 1px solid #000; padding-bottom: 5px;">Bộ Thẻ</h3>
            <% if (decks != null) {
                for (FlashcardDeck d : decks) { 
                    boolean isAct = (currentDeck != null && currentDeck.getDeckId() == d.getDeckId());
            %>
                <a href="?deckId=<%= d.getDeckId() %>" class="deck-item <%= isAct ? "active" : "" %>">
                    <%= d.getTitle() %>
                </a>
            <% } } %>
        </div>

        <!-- Vùng hiển thị the (Flip effect) -->
        <div class="card-area">
            <% if (currentDeck != null) { %>
                <h2><%= currentDeck.getTitle() %></h2>
                <p><%= currentDeck.getDescription() %></p>
                
                <% if (cards != null && !cards.isEmpty()) { 
                    int index = 0;
                %>
                    <div class="flashcard" onclick="this.classList.toggle('flipped')">
                        <div class="flashcard-inner">
                            <div class="flashcard-front">
                                Q: <%= cards.get(index).getQuestion() %>
                            </div>
                            <div class="flashcard-back">
                                A: <%= cards.get(index).getAnswer() %>
                            </div>
                        </div>
                    </div>
                    <p style="margin-top:20px; font-size:14px;">(Click vào thẻ để xem đáp án)</p>
                <% } else { %>
                    <p>[!] Bộ thẻ này chưa có câu hỏi nào.</p>
                <% } %>
            <% } else { %>
                <p>Vui lòng chọn 1 bộ thẻ bên trái.</p>
            <% } %>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />