<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Mentor.MentorEvaluation" %>
<%@ page import="dal.MentorDAO" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;")
                .replace("\r", "&#13;").replace("\n", "&#10;");
    }
%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    int roleId = currentUser.getRoleId();
    boolean mentorUser = new MentorDAO().isMentor(currentUser.getUserId());
    if ((roleId != 3 && roleId != 4) || (roleId == 4 && !mentorUser)) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    request.setAttribute("pageTitle", "Đánh giá Mentee | CPMS");
    List<MentorEvaluation> evaluations = (List<MentorEvaluation>) request.getAttribute("evaluations");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar"><h1>Tổng Hợp Đánh Giá Mentee</h1></div>
    <div class="content-body">
        <div class="card">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center">
                <h2 style="margin:0;font-size:16px;font-weight:600">Đánh giá Mentee</h2>
                <span class="text-secondary" style="font-size:13px">Tổng: <%= evaluations == null ? 0 : evaluations.size() %> đánh giá</span>
            </div>
            <div class="table-responsive">
                <table class="data-table" style="width:100%">
                    <thead><tr><th style="width:60px;text-align:center">STT</th><th>Mentee</th><th>Mentor đứng lớp</th><th style="text-align:center;width:140px">Điểm đánh giá</th><th style="text-align:center;width:140px">Nhận xét</th></tr></thead>
                    <tbody>
                    <% if (evaluations != null && !evaluations.isEmpty()) {
                        int index = 1;
                        for (MentorEvaluation evaluation : evaluations) {
                            boolean approved = "APPROVED".equalsIgnoreCase(evaluation.getApprovalStatus());
                            String publicFeedback = evaluation.getPublicFeedback() != null ? evaluation.getPublicFeedback() : evaluation.getFeedback();
                    %>
                        <tr>
                            <td style="text-align:center"><%= index++ %></td>
                            <td><strong><%= escapeHtml(evaluation.getMenteeName()) %></strong></td>
                            <td><%= escapeHtml(evaluation.getMentorName()) %></td>
                            <td style="text-align:center"><span class="badge" style="background:rgba(79,70,229,.1);color:var(--primary);font-weight:700;padding:4px 10px;border-radius:20px"><%= evaluation.getPerformanceScore() %> / 10</span></td>
                            <td style="text-align:center">
                                <button type="button" class="btn btn-sm btn-primary" onclick="openEvalModal(this)"
                                    data-mentee="<%= escapeHtml(evaluation.getMenteeName()) %>"
                                    data-public="<%= escapeHtml(publicFeedback) %>"
                                    data-private="<%= escapeHtml(evaluation.getPrivateFeedback()) %>"
                                    data-eval-id="<%= evaluation.getEvaluationId() %>"
                                    data-approved="<%= approved %>"><i class="fa-solid fa-eye"></i> Chi tiết</button>
                            </td>
                        </tr>
                    <% } } else { %><tr><td colspan="5" style="text-align:center;padding:36px 16px;color:var(--text-secondary)">Chưa có ghi nhận đánh giá nào.</td></tr><% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<div id="evalDetailModal" class="eval-modal-overlay" style="display:none" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="eval-modal-container">
        <div class="eval-modal-header"><h3 id="modalTitle" style="margin:0;font-size:16px;color:#1e293b;font-weight:700">Chi tiết đánh giá mentee</h3><button type="button" class="eval-modal-close" onclick="closeEvalModal()" aria-label="Đóng">&times;</button></div>
        <div class="eval-modal-body">
            <div style="margin-bottom:18px;padding:12px 16px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px">
                <span style="font-size:11.5px;text-transform:uppercase;letter-spacing:.5px;color:#64748b;font-weight:600">Employee</span>
                <div id="modalMenteeName" style="font-size:15px;font-weight:700;color:#1e293b;margin-top:2px"></div>
            </div>
            <div style="margin-bottom:20px"><h4 style="color:var(--primary);font-size:13.5px;margin:0 0 8px;font-weight:700"><i class="fa-solid fa-eye"></i> Đánh giá công khai</h4><div id="modalPublicContent" class="feedback-box public-box"></div></div>
            <div id="modalPrivateSection" style="margin-bottom:10px"><h4 style="color:#dc2626;font-size:13.5px;margin:0 0 8px;font-weight:700"><i class="fa-solid fa-user-shield"></i> Đánh giá nội bộ</h4><div id="modalPrivateContent" class="feedback-box private-box"></div></div>
        </div>
        <div class="eval-modal-footer">
            <a id="modalEditBtn" class="btn btn-primary" href="#" style="display:none;margin-right:10px"><i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa</a>
            <button type="button" class="btn btn-secondary" onclick="closeEvalModal()">Đóng</button>
        </div>
    </div>
</div>

<style>
.eval-modal-overlay{position:fixed;inset:0;background:rgba(15,23,42,.55);backdrop-filter:blur(4px);display:flex;align-items:center;justify-content:center;z-index:9999}
.eval-modal-container{background:#fff;width:90%;max-width:680px;max-height:85vh;border-radius:var(--radius-lg,12px);box-shadow:0 20px 25px -5px rgba(0,0,0,.1);display:flex;flex-direction:column;overflow:hidden;border:1px solid var(--border-color,#e2e8f0)}
.eval-modal-header{padding:16px 22px;border-bottom:1px solid var(--border-color,#e2e8f0);display:flex;justify-content:space-between;align-items:center}
.eval-modal-close{background:none;border:0;font-size:24px;cursor:pointer;color:#64748b;line-height:1}
.eval-modal-body{padding:20px;overflow-y:auto}.eval-modal-footer{padding:14px 22px;background:#f8fafc;border-top:1px solid var(--border-color,#e2e8f0);display:flex;justify-content:flex-end}
.feedback-box{padding:14px 16px;border-radius:8px;font-size:13.5px;line-height:1.6;white-space:pre-wrap;word-break:break-word}
.public-box{background:#f8fafc;border:1px solid #e0e7ff;color:#1e293b}.private-box{background:#fffdfd;border:1px solid #fee2e2;color:#7f1d1d}
</style>
<script>
function openEvalModal(button) {
    document.getElementById('modalMenteeName').textContent = button.dataset.mentee || '';
    var publicText = button.dataset.public || '';
    var privateText = button.dataset.private || '';
    document.getElementById('modalPublicContent').textContent = publicText.trim() || 'Chưa có nhận xét công khai.';
    document.getElementById('modalPrivateContent').textContent = privateText.trim();
    document.getElementById('modalPrivateSection').style.display = privateText.trim() ? 'block' : 'none';
    var editButton = document.getElementById('modalEditBtn');
    if (editButton) {
        if (button.dataset.approved === 'false') {
            editButton.href = '<%= request.getContextPath() %>/mentors?action=editEvaluation&id=' + button.dataset.evalId;
            editButton.style.display = 'inline-flex';
        } else {
            editButton.style.display = 'none';
        }
    }
    document.getElementById('evalDetailModal').style.display = 'flex';
}
function closeEvalModal() { document.getElementById('evalDetailModal').style.display = 'none'; }
window.addEventListener('click', function(event) { var modal=document.getElementById('evalDetailModal'); if(event.target===modal) closeEvalModal(); });
window.addEventListener('keydown', function(event) { if(event.key==='Escape') closeEvalModal(); });
</script>
<jsp:include page="/views/common/footer.jsp" />
