<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Flashcard.Flashcard" %>
<%@ page import="model.Flashcard.FlashcardDeck" %>
<%@ page import="model.Position" %>
<%
    FlashcardDeck deck = (FlashcardDeck) request.getAttribute("editDeck");
    List<Flashcard> cards = (List<Flashcard>) request.getAttribute("cards");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    boolean editing = deck != null && deck.getDeckId() > 0;
    boolean culture = deck != null && "culture".equals(deck.getType());
    String notice = request.getParameter("notice");
%>
<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<style>
    .flashcard-manage { max-width: 1040px; margin: 0 auto; }
    .manage-top { display: flex; align-items: center; justify-content: space-between; gap: 14px; margin-bottom: 20px; }
    .manage-top h2 { margin: 0; color: var(--text-primary); font-size: 22px; }
    .manage-top p { color: var(--text-secondary); font-size: 13px; margin: 5px 0 0; }
    .manage-back, .manage-submit, .manage-delete {
        display: inline-flex; align-items: center; justify-content: center; gap: 7px;
        border: 0; border-radius: 9px; padding: 10px 14px; text-decoration: none;
        font: inherit; font-size: 13px; font-weight: 700; cursor: pointer;
    }
    .manage-back { color: var(--text-primary); background: #f1f5f9; }
    .manage-submit { color: #fff; background: var(--primary); }
    .manage-delete { color: #b91c1c; background: #fef2f2; }
    .manage-panel { padding: 22px; margin-bottom: 18px; background: #fff; border: 1px solid var(--border-color); border-radius: var(--radius-lg); box-shadow: var(--shadow-sm); }
    .manage-panel h3 { margin: 0 0 16px; color: var(--text-primary); font-size: 16px; }
    .manage-form { display: grid; gap: 14px; }
    .manage-field { display: grid; gap: 6px; }
    .manage-field label { color: var(--text-secondary); font-size: 12px; font-weight: 700; }
    .manage-field input, .manage-field select, .manage-field textarea {
        width: 100%; box-sizing: border-box; padding: 10px 12px; border: 1px solid var(--border-color);
        border-radius: 9px; color: var(--text-primary); background: #fff; font: inherit; font-size: 13px;
    }
    .manage-field textarea { min-height: 84px; resize: vertical; }
    .manage-notice { padding: 11px 14px; margin-bottom: 16px; border: 1px solid #bbf7d0; border-radius: 10px; background: #f0fdf4; color: #166534; font-size: 13px; }
    .manage-notice.error { border-color: #fecaca; background: #fef2f2; color: #991b1b; }
    .manage-card { padding: 16px; margin-top: 12px; border: 1px solid var(--border-light); border-radius: 12px; background: #fbfdff; }
    .manage-card-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 12px; }
    .manage-card-head strong { color: var(--text-primary); font-size: 13px; }
    .manage-card-actions { display: flex; gap: 8px; }
    .manage-hint { color: var(--text-secondary); font-size: 12px; }
    @media (max-width: 640px) { .manage-top { align-items: flex-start; flex-direction: column; } .manage-panel { padding: 16px; } }
</style>

<main class="main-content">
    <div class="topbar">
        <h1><i class="fa-solid fa-clone" style="color: var(--primary);"></i> <span>Quản lý Flashcard</span></h1>
    </div>
    <div class="content-body flashcard-manage">
        <div class="manage-top">
            <div>
                <h2><%= editing ? "Chỉnh sửa bộ thẻ" : "Thêm bộ thẻ mới" %></h2>
                <p><%= culture ? "Bộ thẻ văn hóa công ty" : "Bộ thẻ kiến thức chuyên môn theo vị trí" %></p>
            </div>
            <a class="manage-back" href="<%= request.getContextPath() %>/flashcards<%= editing ? "?deckId=" + deck.getDeckId() : "" %>">
                <i class="fa-solid fa-arrow-left"></i> Quay lại Flashcard
            </a>
        </div>

        <% if ("created".equals(notice) || "updated".equals(notice)) { %>
        <div class="manage-notice">Đã lưu thay đổi.</div>
        <% } else if ("invalidTitle".equals(notice)) { %>
        <div class="manage-notice error">Vui lòng nhập tên bộ thẻ.</div>
        <% } else if ("invalidPosition".equals(notice)) { %>
        <div class="manage-notice error">Vui lòng chọn một vị trí chuyên môn hợp lệ.</div>
        <% } else if ("invalidCard".equals(notice)) { %>
        <div class="manage-notice error">Vui lòng nhập đủ câu hỏi và đáp án.</div>
        <% } %>

        <section class="manage-panel">
            <h3>Thông tin bộ thẻ</h3>
            <form class="manage-form" method="post" action="<%= request.getContextPath() %>/flashcards">
                <input type="hidden" name="action" value="<%= editing ? "updateDeck" : "createDeck" %>">
                <input type="hidden" name="deckType" value="<%= html(deck.getType()) %>">
                <% if (editing) { %><input type="hidden" name="deckId" value="<%= deck.getDeckId() %>"><% } %>
                <div class="manage-field">
                    <label for="deckTitle">Tên bộ thẻ</label>
                    <input id="deckTitle" name="title" maxlength="150" required value="<%= html(deck.getTitle()) %>" placeholder="Ví dụ: Java Backend">
                </div>
                <% if (!culture) { %>
                <div class="manage-field">
                    <label for="positionId">Vị trí chuyên môn</label>
                    <select id="positionId" name="positionId">
                        <option value="">Chuyên môn chung</option>
                        <% if (positions != null) for (Position position : positions) {
                            boolean selected = deck.getPositionId() != null && deck.getPositionId() == position.getPositionId();
                        %>
                        <option value="<%= position.getPositionId() %>" <%= selected ? "selected" : "" %>><%= html(position.getPositionName()) %></option>
                        <% } %>
                    </select>
                </div>
                <% } %>
                <div class="manage-field">
                    <label for="deckDescription">Mô tả</label>
                    <textarea id="deckDescription" name="description" placeholder="Mô tả ngắn về nội dung bộ thẻ"><%= html(deck.getDescription()) %></textarea>
                </div>
                <div><button class="manage-submit" type="submit"><i class="fa-solid fa-floppy-disk"></i> Lưu bộ thẻ</button></div>
            </form>
        </section>

        <% if (editing) { %>
        <section class="manage-panel">
            <h3>Câu hỏi và đáp án <span class="manage-hint">(<%= cards == null ? 0 : cards.size() %> thẻ)</span></h3>
            <form class="manage-form" method="post" action="<%= request.getContextPath() %>/flashcards">
                <input type="hidden" name="action" value="createCard">
                <input type="hidden" name="deckId" value="<%= deck.getDeckId() %>">
                <div class="manage-field"><label for="newQuestion">Câu hỏi mới</label><textarea id="newQuestion" name="question" required placeholder="Nhập câu hỏi"></textarea></div>
                <div class="manage-field"><label for="newAnswer">Đáp án</label><textarea id="newAnswer" name="answer" required placeholder="Nhập đáp án"></textarea></div>
                <div><button class="manage-submit" type="submit"><i class="fa-solid fa-plus"></i> Thêm thẻ</button></div>
            </form>

            <% if (cards != null) for (int i = 0; i < cards.size(); i++) {
                Flashcard card = cards.get(i);
            %>
            <div class="manage-card">
                <div class="manage-card-head"><strong>Thẻ <%= i + 1 %></strong>
                    <form method="post" action="<%= request.getContextPath() %>/flashcards" onsubmit="return confirm('Xóa thẻ này?');">
                        <input type="hidden" name="action" value="deleteCard"><input type="hidden" name="deckId" value="<%= deck.getDeckId() %>"><input type="hidden" name="cardId" value="<%= card.getCardId() %>">
                        <button class="manage-delete" type="submit"><i class="fa-solid fa-trash"></i> Xóa thẻ</button>
                    </form>
                </div>
                <form class="manage-form" method="post" action="<%= request.getContextPath() %>/flashcards">
                    <input type="hidden" name="action" value="updateCard"><input type="hidden" name="deckId" value="<%= deck.getDeckId() %>"><input type="hidden" name="cardId" value="<%= card.getCardId() %>">
                    <div class="manage-field"><label>Câu hỏi</label><textarea name="question" required><%= html(card.getQuestion()) %></textarea></div>
                    <div class="manage-field"><label>Đáp án</label><textarea name="answer" required><%= html(card.getAnswer()) %></textarea></div>
                    <div><button class="manage-submit" type="submit"><i class="fa-solid fa-floppy-disk"></i> Lưu thẻ</button></div>
                </form>
            </div>
            <% } %>
        </section>
        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
