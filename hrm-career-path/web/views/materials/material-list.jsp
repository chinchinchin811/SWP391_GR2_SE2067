<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.text.SimpleDateFormat,model.LearningMaterial,model.TrainingClass,model.User,model.Flashcard.FlashcardDeck" %>
<%
    request.setAttribute("pageTitle", "Kho Học Liệu | HRM");
    List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("materials");
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("classes");
    List<FlashcardDeck> flashcardDecks = (List<FlashcardDeck>) request.getAttribute("flashcardDecks");
    if (flashcardDecks == null) {
        try {
            flashcardDecks = new dal.FlashcardDAO().getAllDecks();
        } catch (Exception ignored) {}
    }
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && (currentUser.getRoleId() == 2 || currentUser.getRoleId() == 3);
    boolean isClassMember = classes != null && !classes.isEmpty();
    String successMessage = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Kho Học Liệu</h1>
        <div class="topbar-actions" style="display:flex;gap:10px;align-items:center">
            <% if (canManage) { %>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=create">+ Thêm học liệu</a>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <!-- BỘ THẺ FLASHCARD ÔN TẬP -->
        <div class="card" style="margin-bottom:20px;border:1px solid #e0e7ff;background:linear-gradient(180deg, #f8faff 0%, #ffffff 100%)">
            <div class="card-header" style="background:transparent;border-bottom:1px solid #edf2f7;display:flex;justify-content:space-between;align-items:center">
                <div style="display:flex;align-items:center;gap:10px">
                    <div style="width:36px;height:36px;border-radius:8px;background:linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);color:#fff;display:flex;align-items:center;justify-content:center;font-size:16px;box-shadow:0 3px 8px rgba(79,70,229,0.3)">
                        <i class="fa-solid fa-clone"></i>
                    </div>
                    <div>
                        <h2 style="font-size:16px;margin:0;font-weight:700;color:#1e1b4b">Bộ Thẻ Ghi Nhớ Flashcards</h2>
                        <span style="font-size:12px;color:#6b7280">Học tập và ôn luyện kiến thức nhanh qua thẻ lật tương tác</span>
                    </div>
                </div>
                <a href="<%= request.getContextPath() %>/flashcards" class="btn btn-sm btn-primary" style="background:linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);border:none;font-weight:600">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Mở phòng học Flashcards
                </a>
            </div>
            <div class="card-body" style="padding:16px 20px">
                <div style="display:grid;grid-template-columns:repeat(auto-fill, minmax(280px, 1fr));gap:14px">
                    <% if (flashcardDecks != null && !flashcardDecks.isEmpty()) {
                        for (FlashcardDeck d : flashcardDecks) {
                            boolean isCulture = "culture".equals(d.getType());
                    %>
                    <div style="background:#fff;border:1px solid <%= isCulture ? "#c7d2fe" : "#bbf7d0" %>;border-radius:10px;padding:14px;display:flex;flex-direction:column;justify-content:space-between;transition:transform 0.15s,box-shadow 0.15s;box-shadow:0 1px 3px rgba(0,0,0,0.04)"
                         onmouseover="this.style.transform='translateY(-2px)';this.style.boxShadow='0 4px 12px rgba(0,0,0,0.08)';"
                         onmouseout="this.style.transform='none';this.style.boxShadow='0 1px 3px rgba(0,0,0,0.04)';">
                        <div>
                            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:8px">
                                <span class="badge" style="background:<%= isCulture ? "#e0e7ff;color:#4338ca" : "#dcfce7;color:#15803d" %>;font-size:11px;font-weight:700;border-radius:20px;padding:3px 10px">
                                    <%= isCulture ? "Văn hóa công ty" : (d.getPositionName() != null ? d.getPositionName() : "Chuyên môn") %>
                                </span>
                                <i class="fa-solid fa-layer-group" style="color:<%= isCulture ? "#818cf8" : "#86efac" %>;font-size:14px"></i>
                            </div>
                            <h3 style="font-size:14.5px;font-weight:700;margin:0 0 4px 0;color:#0f172a">
                                <a href="<%= request.getContextPath() %>/flashcards?deckId=<%= d.getDeckId() %>" style="color:inherit;text-decoration:none">
                                    <%= d.getTitle() %>
                                </a>
                            </h3>
                            <p style="font-size:12px;color:#64748b;margin:0 0 12px 0;line-height:1.4">
                                <%= d.getDescription() != null ? d.getDescription() : "Bộ câu hỏi ôn tập kiến thức cốt lõi." %>
                            </p>
                        </div>
                        <a href="<%= request.getContextPath() %>/flashcards?deckId=<%= d.getDeckId() %>"
                           class="btn btn-sm"
                           style="background:linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);color:#fff;font-weight:600;font-size:12px;padding:6px 12px;border-radius:6px;display:flex;align-items:center;justify-content:center;gap:6px;text-decoration:none">
                            <i class="fa-solid fa-play"></i> Bắt đầu ôn tập thẻ này
                        </a>
                    </div>
                    <% } } %>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2>Tài Liệu Và Video</h2>
                <span class="badge-count">Tổng: <%= materials != null ? materials.size() : 0 %> mục</span>
            </div>
            <div class="card-body" style="padding:0">
                <table class="data-table">
                    <colgroup>
                        <col style="width:48%">
                        <col style="width:14%">
                        <col style="width:16%">
                        <col style="width:22%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th style="text-align:left;padding-left:14px"></th>
                            <th style="text-align:center">Loại</th>
                            <th style="text-align:center">Thời lượng</th>
                            <th style="text-align:center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (materials != null && !materials.isEmpty()) {
                            for (LearningMaterial m : materials) { 
                        %>
                        <tr>
                            <td style="padding-left:14px">
                                <div style="font-size:13px;font-weight:600;line-height:1.4">
                                    <a href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>" style="color:#111;text-decoration:none">
                                        <%= m.getTitle() %>
                                    </a>
                                </div>
                                <% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
                                <div style="font-size:11.5px;color:#666;margin-top:2px;line-height:1.4"><%= m.getDescription() %></div>
                                <% } %>
                            </td>
                            <td style="text-align:center"><span class="badge"><%= m.getMaterialType() %></span></td>
                            <td style="text-align:center;font-size:12.5px"><%= ("VIDEO".equals(m.getMaterialType()) && m.getDurationMinutes() > 0) ? (m.getDurationMinutes() + " phút") : "—" %></td>
                            <td style="text-align:center">
                                <div class="action-btn-group">
                                    <a class="btn btn-sm btn-primary" href="<%= request.getContextPath() %>/materials?action=view&id=<%= m.getMaterialId() %>">Xem học liệu</a>
                                    <% if (canManage) { %>
                                    <a class="btn btn-sm btn-secondary" href="<%= request.getContextPath() %>/materials?action=edit&id=<%= m.getMaterialId() %>">Sửa</a>
                                    <form method="post" action="<%= request.getContextPath() %>/materials" style="display:inline-flex;margin:0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa học liệu này?')">
                                        <input type="hidden" name="action" value="deleteMaterial">
                                        <input type="hidden" name="id" value="<%= m.getMaterialId() %>">
                                        <button type="submit" class="btn btn-sm btn-danger">Xóa</button>
                                    </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="4" style="text-align:center;padding:28px;color:#666;font-size:13px">
                                Chưa có học liệu nào trong hệ thống.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
