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

    .flashcard-container {
        display: flex;
        gap: 20px;
    }
    .deck-sidebar {
        width: 250px;
        border-right: 2px solid #000;
        padding-right: 15px;
    }
    .deck-item {
        display: block;
        padding: 10px;
        margin-bottom: 10px;
        border: 1px solid #000;
        text-decoration: none;
        color: #000;
        font-weight: bold;
    }
    .deck-item:hover, .deck-item.active {
        background: #000;
        color: #fff;
    }
    .card-area {
        flex: 1;
        padding: 20px;
        text-align: center;
    }
    .flashcard {
        width: 400px;
        height: 250px;
        margin: 0 auto;
        perspective: 1000px;
        cursor: pointer;
    }
    .flashcard-inner {
        width: 100%;
        height: 100%;
        text-align: center;
        transition: transform 0.6s;
        transform-style: preserve-3d;
    }
    .flashcard.flipped .flashcard-inner {
        transform: rotateY(180deg);
    }
    .flashcard-front, .flashcard-back {
        width: 100%;
        height: 100%;
        position: absolute;
        backface-visibility: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 3px solid #000;
        padding: 20px;
        box-sizing: border-box;
        font-size: 20px;
        font-weight: bold;
        background: #fff;
    }
    .flashcard-front {
        color: #000;
    }
    .flashcard-back {
        background: #000;
        color: #fff;
        transform: rotateY(180deg);


        /* Thêm style cho cụm nút điều hướng Trước/Sau */
        .card-controls {
            margin-top: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
        }
        .btn-nav {
            padding: 10px 20px;
            border: 2px solid #000;
            background: #fff;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-nav:hover {
            background: #000;
            color: #fff;
        }
        .btn-nav:disabled {
            border-color: #ccc;
            color: #ccc;
            cursor: not-allowed;
            background: #fff;
        }
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

        
        <div class="card-area">
            <% if (currentDeck != null) { %>
            <h2><%= currentDeck.getTitle() %></h2>
            <p><%= currentDeck.getDescription() %></p>

            <% if (cards != null && !cards.isEmpty()) { %>
            
            <div id="flashcards-wrapper">
                <% for (int i = 0; i < cards.size(); i++) { 
                    Flashcard c = cards.get(i);
                %>
                
                <div class="flashcard card-item" data-id="<%= c.getCardId() %>" 
                     style="<%= i == 0 ? "display:block;" : "display:none;" %>" 
                     onclick="this.classList.toggle('flipped')">
                    <div class="flashcard-inner">
                        <div class="flashcard-front">
                            Q: <%= c.getQuestion() %>
                        </div>
                        <div class="flashcard-back">
                            A: <%= c.getAnswer() %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>

            <p style="margin-top:15px; font-size:14px; color: #555;">(Click vào thẻ để xem đáp án)</p>

            
            <div class="card-controls">
                <button id="btnPrev" class="btn-nav" onclick="prevCard()" disabled>Trước</button>
                <span id="card-counter" style="font-weight: bold;">1 / <%= cards.size() %></span>
                <button id="btnNext" class="btn-nav" onclick="nextCard()" <%= cards.size() == 1 ? "disabled" : "" %>>Sau</button>
            </div>

            
            <script>
                let currentIndex = 0;
                const totalCards = <%= cards.size() %>;
                const cardElements = document.querySelectorAll('.card-item');
                const counterEl = document.getElementById('card-counter');
                const btnPrev = document.getElementById('btnPrev');
                const btnNext = document.getElementById('btnNext');

                function updateUI() {
                    cardElements.forEach((el) => {
                        el.style.display = 'none'; 
                        el.classList.remove('flipped'); 
                    });

                    cardElements[currentIndex].style.display = 'block'; 
                    counterEl.innerText = (currentIndex + 1) + " / " + totalCards;

                    btnPrev.disabled = (currentIndex === 0);
                    btnNext.disabled = (currentIndex === totalCards - 1);
                }

                function nextCard() {
                    if (currentIndex < totalCards - 1) {
                        currentIndex++;
                        updateUI();
                    }
                }

                function prevCard() {
                    if (currentIndex > 0) {
                        currentIndex--;
                        updateUI();
                    }
                }
            </script>
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