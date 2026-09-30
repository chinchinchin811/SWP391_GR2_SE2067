<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Flashcard.Flashcard" %>
<%@ page import="model.Flashcard.FlashcardDeck" %>
<%
    List<FlashcardDeck> decks = (List<FlashcardDeck>) request.getAttribute("decks");
    List<Flashcard> cards = (List<Flashcard>) request.getAttribute("cards");
    FlashcardDeck currentDeck = (FlashcardDeck) request.getAttribute("currentDeck");
    int cardCount = (cards != null) ? cards.size() : 0;
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<style>
    /* Flashcard Layout */
    .flashcard-container {
        display: flex;
        gap: 24px;
        align-items: flex-start;
    }

    /* Deck Sidebar */
    .deck-sidebar {
        width: 270px;
        flex-shrink: 0;
        background: #ffffff;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-lg);
        padding: 20px 16px;
        box-shadow: var(--shadow-sm);
    }

    .deck-sidebar-header {
        font-size: 14px;
        font-weight: 700;
        color: var(--text-primary);
        padding-bottom: 12px;
        margin-bottom: 14px;
        border-bottom: 1px solid var(--border-light);
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .deck-sidebar-header i {
        color: var(--primary);
    }

    .deck-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 14px;
        margin-bottom: 8px;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        text-decoration: none;
        color: var(--text-primary);
        font-weight: 600;
        font-size: 13px;
        background: #ffffff;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
    }

    .deck-item:hover {
        border-color: #818cf8;
        color: var(--primary);
        transform: translateX(4px);
        background: #f8fafc;
    }

    .deck-item.active {
        background: linear-gradient(135deg, var(--primary) 0%, #6366f1 100%);
        color: #ffffff;
        border-color: var(--primary-dark);
        box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
        transform: translateX(4px);
    }

    .deck-item-icon {
        font-size: 14px;
        opacity: 0.85;
    }

    /* Main Flashcard Stage Area */
    .card-area {
        flex: 1;
        min-width: 0;
        padding: 28px 24px;
        text-align: center;
        background: #ffffff;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
    }

    .deck-heading h2 {
        font-size: 20px;
        font-weight: 800;
        color: var(--text-primary);
        letter-spacing: -0.4px;
        margin-bottom: 6px;
    }

    .deck-heading p {
        font-size: 13px;
        color: var(--text-secondary);
        margin-bottom: 20px;
    }

    /* Progress Bar */
    .progress-wrapper {
        max-width: 520px;
        margin: 0 auto 20px;
        display: flex;
        align-items: center;
        gap: 14px;
    }

    .progress-track {
        flex: 1;
        height: 7px;
        background: #f1f5f9;
        border-radius: var(--radius-full);
        overflow: hidden;
    }

    .progress-fill {
        height: 100%;
        background: linear-gradient(90deg, #4f46e5, #06b6d4);
        border-radius: var(--radius-full);
        transition: width 0.35s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .progress-count {
        font-size: 12.5px;
        font-weight: 700;
        color: var(--primary);
        white-space: nowrap;
    }

    /* 3D Flashcard Stage */
    .flashcard-stage {
        position: relative;
        width: 520px;
        height: 310px;
        margin: 0 auto;
        perspective: 1200px;
    }

    /* Card Item (Default State: Hidden) */
    .card-item {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        display: none;
        opacity: 0;
        cursor: pointer;
        user-select: none;
    }

    /* Active Visible Card */
    .card-item.active {
        display: block !important;
        opacity: 1 !important;
        transform: translateX(0) scale(1) !important;
        z-index: 2;
    }

    /* KEYFRAME ANIMATIONS FOR SMOOTH SLIDE */
    @keyframes slideExitToLeft {
        0% {
            opacity: 1;
            transform: translateX(0) scale(1) rotate(0deg);
        }
        100% {
            opacity: 0;
            transform: translateX(-150px) scale(0.92) rotate(-4deg);
        }
    }

    @keyframes slideEnterFromRight {
        0% {
            opacity: 0;
            transform: translateX(150px) scale(0.92) rotate(4deg);
        }
        100% {
            opacity: 1;
            transform: translateX(0) scale(1) rotate(0deg);
        }
    }

    @keyframes slideExitToRight {
        0% {
            opacity: 1;
            transform: translateX(0) scale(1) rotate(0deg);
        }
        100% {
            opacity: 0;
            transform: translateX(150px) scale(0.92) rotate(4deg);
        }
    }

    @keyframes slideEnterFromLeft {
        0% {
            opacity: 0;
            transform: translateX(-150px) scale(0.92) rotate(-4deg);
        }
        100% {
            opacity: 1;
            transform: translateX(0) scale(1) rotate(0deg);
        }
    }

    .slide-exit-left {
        display: block !important;
        animation: slideExitToLeft 0.35s cubic-bezier(0.4, 0, 0.2, 1) forwards !important;
        z-index: 1 !important;
        pointer-events: none;
    }

    .slide-enter-right {
        display: block !important;
        animation: slideEnterFromRight 0.35s cubic-bezier(0.34, 1.25, 0.64, 1) forwards !important;
        z-index: 2 !important;
    }

    .slide-exit-right {
        display: block !important;
        animation: slideExitToRight 0.35s cubic-bezier(0.4, 0, 0.2, 1) forwards !important;
        z-index: 1 !important;
        pointer-events: none;
    }

    .slide-enter-left {
        display: block !important;
        animation: slideEnterFromLeft 0.35s cubic-bezier(0.34, 1.25, 0.64, 1) forwards !important;
        z-index: 2 !important;
    }

    /* 3D Flip Card Inner */
    .flashcard-inner {
        position: relative;
        width: 100%;
        height: 100%;
        text-align: center;
        transition: transform 0.65s cubic-bezier(0.34, 1.35, 0.64, 1);
        transform-style: preserve-3d;
        border-radius: 18px;
    }

    .card-item.flipped .flashcard-inner {
        transform: rotateY(180deg);
    }

    /* Front & Back Faces */
    .flashcard-face {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        backface-visibility: hidden;
        -webkit-backface-visibility: hidden;
        border-radius: 18px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: space-between;
        padding: 24px 30px;
        box-sizing: border-box;
        box-shadow: 0 12px 30px -6px rgba(0, 0, 0, 0.09), 0 4px 12px -2px rgba(0, 0, 0, 0.05);
        transition: border-color 0.2s ease, box-shadow 0.2s ease;
    }

    .card-item:hover .flashcard-face {
        box-shadow: 0 18px 36px -6px rgba(79, 70, 229, 0.16), 0 6px 16px -2px rgba(0, 0, 0, 0.06);
    }

    /* FRONT FACE (White/Clean) */
    .flashcard-front {
        background: #ffffff;
        border: 2px solid #e2e8f0;
        color: var(--text-primary);
    }

    /* BACK FACE (Deep Royal Indigo Gradient) */
    .flashcard-back {
        background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 55%, #312e81 100%);
        border: 2px solid #4338ca;
        color: #ffffff;
        transform: rotateY(180deg);
    }

    /* Badge Label (Câu hỏi / Đáp án) */
    .face-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 5px 14px;
        border-radius: var(--radius-full);
        font-size: 11.5px;
        font-weight: 700;
        letter-spacing: 0.5px;
        text-transform: uppercase;
    }

    .face-badge-q {
        background: #eef2ff;
        color: #4f46e5;
        border: 1px solid #c7d2fe;
    }

    .face-badge-a {
        background: rgba(255, 255, 255, 0.15);
        color: #38bdf8;
        border: 1px solid rgba(255, 255, 255, 0.25);
        backdrop-filter: blur(4px);
    }

    /* Center Content Text */
    .face-content {
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 10px 0;
        width: 100%;
    }

    .flashcard-front .face-text {
        font-size: 21px;
        font-weight: 700;
        color: #0f172a;
        line-height: 1.45;
        letter-spacing: -0.3px;
    }

    .flashcard-back .face-text {
        font-size: 19px;
        font-weight: 600;
        color: #f8fafc;
        line-height: 1.55;
    }

    /* Hint at Bottom */
    .face-hint {
        font-size: 12px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 6px;
        opacity: 0.75;
        transition: opacity 0.15s ease;
    }

    .card-item:hover .face-hint {
        opacity: 1;
    }

    .flashcard-front .face-hint {
        color: #64748b;
    }

    .flashcard-back .face-hint {
        color: #94a3b8;
    }

    /* Controls Bar */
    .card-controls {
        margin-top: 24px;
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 14px;
    }

    .btn-nav-action {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 9px 20px;
        border-radius: var(--radius-md);
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        border: 1px solid transparent;
        line-height: 1.2;
    }

    .btn-nav-prev, .btn-nav-next {
        background: #ffffff;
        color: var(--text-primary);
        border: 1px solid var(--border-color);
        box-shadow: var(--shadow-sm);
    }

    .btn-nav-prev:hover:not(:disabled), .btn-nav-next:hover:not(:disabled) {
        border-color: #818cf8;
        color: var(--primary);
        background: #f8fafc;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
    }

    .btn-nav-prev:disabled, .btn-nav-next:disabled {
        opacity: 0.45;
        cursor: not-allowed;
        background: #f8fafc;
        border-color: var(--border-light);
    }

    .btn-nav-flip {
        background: linear-gradient(135deg, var(--primary) 0%, #6366f1 100%);
        color: #ffffff;
        border: 1px solid var(--primary-dark);
        box-shadow: 0 4px 12px rgba(79, 70, 229, 0.28);
    }

    .btn-nav-flip:hover {
        background: linear-gradient(135deg, #4338ca 0%, var(--primary) 100%);
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(79, 70, 229, 0.38);
    }

    .keyboard-hint {
        margin-top: 16px;
        font-size: 12px;
        color: #94a3b8;
    }

    .keyboard-hint kbd {
        display: inline-block;
        padding: 2px 7px;
        font-size: 11px;
        font-family: inherit;
        background: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
        border-radius: 4px;
        font-weight: 700;
        box-shadow: 0 1px 1px rgba(0,0,0,0.06);
    }

    @media (max-width: 860px) {
        .flashcard-container {
            flex-direction: column;
        }
        .deck-sidebar {
            width: 100%;
        }
        .flashcard-stage {
            width: 100%;
            max-width: 440px;
            height: 280px;
        }
    }
</style>

<main class="main-content">
    <div class="topbar">
        <h1><i class="fa-solid fa-clone" style="color: var(--primary);"></i> <span>Học Tập: Flashcards</span></h1>
    </div>

    <div class="content-body flashcard-container">
        <!-- Sidebar danh sách bộ thẻ -->
        <aside class="deck-sidebar">
            <div class="deck-sidebar-header">
                <i class="fa-solid fa-layer-group"></i>
                <span>Bộ Thẻ Kiến Thức</span>
            </div>
            <% if (decks != null) {
                for (FlashcardDeck d : decks) { 
                    boolean isAct = (currentDeck != null && currentDeck.getDeckId() == d.getDeckId());
            %>
            <a href="?deckId=<%= d.getDeckId() %>" class="deck-item <%= isAct ? "active" : "" %>">
                <span><%= d.getTitle() %></span>
                <i class="fa-solid fa-chevron-right deck-item-icon"></i>
            </a>
            <% } } %>
        </aside>

        <!-- Khung lật Flashcard trung tâm -->
        <section class="card-area">
            <% if (currentDeck != null) { %>
            <div class="deck-heading">
                <h2><%= currentDeck.getTitle() %></h2>
                <p><%= currentDeck.getDescription() != null ? currentDeck.getDescription() : "Bộ câu hỏi trắc nghiệm & ôn tập kiến thức" %></p>
            </div>

            <% if (cards != null && !cards.isEmpty()) { %>
            
            <!-- Thanh Tiến Trình (Progress bar) -->
            <div class="progress-wrapper">
                <div class="progress-track">
                    <div class="progress-fill" id="progressFill" style="width: <%= (1.0 / cardCount) * 100 %>%;"></div>
                </div>
                <div class="progress-count" id="progressCount">1 / <%= cardCount %></div>
            </div>

            <!-- Khung chiếu thẻ 3D (Flashcard Stage) -->
            <div class="flashcard-stage" id="flashcardStage">
                <% for (int i = 0; i < cards.size(); i++) { 
                    Flashcard c = cards.get(i);
                %>
                <div class="flashcard card-item <%= i == 0 ? "active" : "" %>" 
                     data-index="<%= i %>"
                     onclick="flipCurrentCard()">
                    <div class="flashcard-inner">
                        <!-- MẶT TRƯỚC (CÂU HỎI) -->
                        <div class="flashcard-face flashcard-front">
                            <div class="face-badge face-badge-q">
                                <i class="fa-regular fa-circle-question"></i> Câu Hỏi
                            </div>
                            <div class="face-content">
                                <div class="face-text"><%= c.getQuestion() %></div>
                            </div>
                            <div class="face-hint">
                                <i class="fa-solid fa-repeat"></i> Click thẻ hoặc bấm Space để lật đáp án
                            </div>
                        </div>

                        <!-- MẶT SAU (ĐÁP ÁN) -->
                        <div class="flashcard-face flashcard-back">
                            <div class="face-badge face-badge-a">
                                <i class="fa-solid fa-circle-check"></i> Đáp Án
                            </div>
                            <div class="face-content">
                                <div class="face-text"><%= c.getAnswer() %></div>
                            </div>
                            <div class="face-hint">
                                <i class="fa-solid fa-repeat"></i> Click thẻ để lật lại câu hỏi
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Bộ điều khiển điều hướng Trước / Lật / Sau -->
            <div class="card-controls">
                <button id="btnPrev" class="btn-nav-action btn-nav-prev" onclick="prevCard()" disabled>
                    <i class="fa-solid fa-arrow-left"></i> <span>Trước</span>
                </button>
                <button class="btn-nav-action btn-nav-flip" onclick="flipCurrentCard()">
                    <i class="fa-solid fa-arrows-rotate"></i> <span>Lật thẻ</span>
                </button>
                <button id="btnNext" class="btn-nav-action btn-nav-next" onclick="nextCard()" <%= cardCount <= 1 ? "disabled" : "" %>>
                    <span>Sau</span> <i class="fa-solid fa-arrow-right"></i>
                </button>
            </div>

            <div class="keyboard-hint">
                Phím tắt: <kbd>←</kbd> Thẻ trước &nbsp;•&nbsp; <kbd>→</kbd> Thẻ sau &nbsp;•&nbsp; <kbd>Space</kbd> hoặc <kbd>Enter</kbd> Lật thẻ
            </div>

            <!-- JavaScript Xử Lý Lật & Trượt Trái Phải Chuẩn Xác 100% -->
            <script>
                (function () {
                    let currentIndex = 0;
                    const totalCards = <%= cardCount %>;
                    const cardElements = document.querySelectorAll('.card-item');
                    const progressFill = document.getElementById('progressFill');
                    const progressCount = document.getElementById('progressCount');
                    const btnPrev = document.getElementById('btnPrev');
                    const btnNext = document.getElementById('btnNext');
                    let isAnimating = false;

                    window.flipCurrentCard = function () {
                        if (cardElements[currentIndex]) {
                            cardElements[currentIndex].classList.toggle('flipped');
                        }
                    };

                    function updateControls() {
                        btnPrev.disabled = (currentIndex === 0);
                        btnNext.disabled = (currentIndex === totalCards - 1);
                        
                        const pct = ((currentIndex + 1) / totalCards) * 100;
                        if (progressFill) progressFill.style.width = pct + '%';
                        if (progressCount) progressCount.innerText = (currentIndex + 1) + ' / ' + totalCards;
                    }

                    window.showCard = function (newIndex, direction) {
                        if (isAnimating || newIndex === currentIndex || newIndex < 0 || newIndex >= totalCards) return;
                        isAnimating = true;

                        const currentCard = cardElements[currentIndex];
                        const nextCard = cardElements[newIndex];

                        // Đảm bảo thẻ mới quay về mặt trước trước khi trượt vào
                        nextCard.classList.remove('flipped');

                        // Dọn sạch class animation cũ trên tất cả thẻ
                        cardElements.forEach(function (el) {
                            el.classList.remove('slide-exit-left', 'slide-enter-right', 'slide-exit-right', 'slide-enter-left');
                        });

                        if (direction === 'next') {
                            currentCard.classList.remove('active');
                            currentCard.classList.add('slide-exit-left');

                            nextCard.classList.add('slide-enter-right');
                        } else {
                            currentCard.classList.remove('active');
                            currentCard.classList.add('slide-exit-right');

                            nextCard.classList.add('slide-enter-left');
                        }

                        currentIndex = newIndex;
                        updateControls();

                        setTimeout(function () {
                            cardElements.forEach(function (el, idx) {
                                el.classList.remove('slide-exit-left', 'slide-enter-right', 'slide-exit-right', 'slide-enter-left');
                                if (idx === currentIndex) {
                                    el.classList.add('active');
                                } else {
                                    el.classList.remove('active');
                                }
                            });
                            isAnimating = false;
                        }, 360);
                    };

                    window.nextCard = function () {
                        if (currentIndex < totalCards - 1) {
                            showCard(currentIndex + 1, 'next');
                        }
                    };

                    window.prevCard = function () {
                        if (currentIndex > 0) {
                            showCard(currentIndex - 1, 'prev');
                        }
                    };

                    // Điều khiển bằng bàn phím
                    document.addEventListener('keydown', function (e) {
                        if (!document.getElementById('flashcardStage')) return;
                        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

                        if (e.key === 'ArrowRight') {
                            e.preventDefault();
                            nextCard();
                        } else if (e.key === 'ArrowLeft') {
                            e.preventDefault();
                            prevCard();
                        } else if (e.key === ' ' || e.key === 'Enter') {
                            e.preventDefault();
                            flipCurrentCard();
                        }
                    });

                    updateControls();
                }());
            </script>
            <% } else { %>
            <div style="padding: 40px; color: var(--text-secondary);">
                <i class="fa-regular fa-folder-open" style="font-size: 36px; margin-bottom: 12px; color: #94a3b8;"></i>
                <p>Bộ thẻ này hiện chưa có câu hỏi nào.</p>
            </div>
            <% } %>
            <% } else { %>
            <div style="padding: 40px; color: var(--text-secondary);">
                <i class="fa-solid fa-arrow-left" style="font-size: 28px; margin-bottom: 12px; color: var(--primary);"></i>
                <p>Vui lòng chọn một bộ thẻ ở danh sách bên trái để bắt đầu học tập.</p>
            </div>
            <% } %>
        </section>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
