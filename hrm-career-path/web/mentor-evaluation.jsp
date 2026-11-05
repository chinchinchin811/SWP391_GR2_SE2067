<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Mentor.MentorEvaluation" %>
<%@ page import="dal.MentorDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    int roleId = (currentUser != null) ? currentUser.getRoleId() : 4;
    MentorDAO evalMentorDAO = new MentorDAO();
    boolean isMentorUser = (currentUser != null) && evalMentorDAO.isMentor(currentUser.getUserId());
    if (roleId == 4 && !isMentorUser) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    request.setAttribute("pageTitle", "Quản Lý Đánh Giá Mentee | CPMS");
    List<MentorEvaluation> evaluations = (List<MentorEvaluation>) request.getAttribute("evaluations");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Tổng Hợp Đánh Giá Mentee</h1>
    </div>

    <div class="content-body">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h2 style="margin: 0; font-size: 16px; font-weight: 600;">Danh Sách Đánh Giá Từ Mentor</h2>
                <span class="text-secondary" style="font-size: 13px;">Tổng: <%= evaluations != null ? evaluations.size() : 0 %> đánh giá</span>
            </div>
            <div class="table-responsive">
                <table class="data-table" style="width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 60px; text-align: center;">STT</th>
                            <th>Mentee (Học viên)</th>
                            <th>Mentor Đứng Lớp</th>
                            <th style="text-align: center; width: 140px;">Điểm Đánh Giá</th>
                            <th style="text-align: center; width: 140px;">Nhận Xét</th>
                            <th style="text-align: center; width: 150px;">Trạng Thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (evaluations != null && !evaluations.isEmpty()) {
                            int stt = 1;
                            for (MentorEvaluation eval : evaluations) {
                                boolean isApproved = "APPROVED".equalsIgnoreCase(eval.getApprovalStatus());                               
                                String pubFb = (eval.getPublicFeedback() != null && !eval.getPublicFeedback().isEmpty()) 
                                                ? eval.getPublicFeedback() : (eval.getFeedback() != null ? eval.getFeedback() : "");
                                pubFb = pubFb.replaceAll("\\s*\\([0-9]+(?:[.,][0-9]+)?\\s*(?:đ|điểm|pts)?\\)", "").trim();

                                String privFb = eval.getPrivateFeedback() != null ? eval.getPrivateFeedback() : "";
                                privFb = privFb.replaceAll("\\s*\\([0-9]+(?:[.,][0-9]+)?\\s*(?:đ|điểm|pts)?\\)", "").trim();
                        %>
                            <tr>
                                <td style="text-align: center; color: var(--text-secondary);">
                                    <%= stt++ %>
                                </td>
                                <td>
                                    <strong><%= eval.getMenteeName() != null ? eval.getMenteeName() : "N/A" %></strong>
                                </td>
                                <td>
                                    <%= eval.getMentorName() != null ? eval.getMentorName() : "Chưa cập nhật" %>
                                </td>
                                <td style="text-align: center;">
                                    <span class="badge" style="background: rgba(79, 70, 229, 0.1); color: var(--primary); font-weight: 700; font-size: 13px; padding: 4px 10px; border-radius: 20px;">
                                        <%= eval.getPerformanceScore() %> / 10
                                    </span>
                                </td>
                                <td style="text-align: center;">
                                    <button type="button" class="btn btn-sm btn-primary" onclick="openEvalModal(this)">
                                        <i class="fa-solid fa-eye"></i> Chi tiết
                                    </button>
                                                                        
                                    <div class="raw-eval-id" style="display:none;"><%= eval.getEvaluationId() %></div>
                                    <div class="raw-is-approved" style="display:none;"><%= isApproved %></div>
                                    <div class="raw-mentee-name" style="display:none;"><%= eval.getMenteeName() != null ? eval.getMenteeName() : "" %></div>
                                    <div class="raw-public-feedback" style="display:none;"><%= pubFb %></div>
                                    <div class="raw-private-feedback" style="display:none;"><%= privFb %></div>
                                </td>
                                <td style="text-align: center;">
                                    <% if (isApproved) { %>
                                    <span class="badge badge-status-active">
                                        <i class="fa-solid fa-circle-check"></i> APPROVED
                                    </span>
                                    <% } else { %>
                                    <span class="badge" style="background: #fef3c7; color: #b45309; border: 1px solid #fde68a; font-size: 11.5px; padding: 4px 8px; border-radius: var(--radius-sm); font-weight: 600;">
                                        <i class="fa-regular fa-clock"></i> PENDING
                                    </span>
                                    <% } %>
                                </td>
                            </tr>
                        <%  }
                        } else { %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 36px 16px; color: var(--text-secondary);">
                                <i class="fa-solid fa-clipboard-list" style="font-size: 28px; margin-bottom: 8px; display: block; opacity: 0.5;"></i>
                                Chưa có ghi nhận đánh giá nào từ Mentor.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<%-- POPUP MODAL HIỂN THỊ CHI TIẾT --%>
<div id="evalDetailModal" class="eval-modal-overlay" style="display: none;">
    <div class="eval-modal-container">
        <div class="eval-modal-header">
            <h3 style="margin: 0; font-size: 16px; color: #1e293b; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                Chi Tiết Đánh Giá Mentee
            </h3>
            <button type="button" class="eval-modal-close" onclick="closeEvalModal()">&times;</button>
        </div>
        <div class="eval-modal-body">
            <div style="margin-bottom: 18px; padding: 12px 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; display: flex; align-items: center; justify-content: space-between;">
                <div>
                    <span style="font-size: 11.5px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; font-weight: 600;">Học viên được đánh giá:</span>
                    <div id="modalMenteeName" style="font-size: 15px; font-weight: 700; color: #1e293b; margin-top: 2px;"></div>
                </div>
            </div>

            <!-- SECTION 1: ĐÁNH GIÁ CÔNG KHAI -->
            <div style="margin-bottom: 20px;">
                <h4 style="color: var(--primary); font-size: 13.5px; margin: 0 0 8px 0; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-eye"></i> 1. Kết quả đánh giá năng lực (Công khai - Mentee có thể xem)
                </h4>
                <div id="modalPublicContent" class="feedback-box public-box"></div>
            </div>

            <!-- SECTION 2: ĐÁNH GIÁ NỘI BỘ -->
            <div id="modalPrivateSection" style="margin-bottom: 10px;">
                <h4 style="color: #dc2626; font-size: 13.5px; margin: 0 0 8px 0; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-user-shield"></i> 2. Đánh giá nội bộ (Bảo mật)
                </h4>
                <div id="modalPrivateContent" class="feedback-box private-box"></div>
            </div>
        </div>
        <div class="eval-modal-footer" style="display: flex; justify-content: flex-end; align-items: center; gap: 10px;">
            <a id="modalEditBtn" class="btn btn-primary" href="#" style="display: none;">
                <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa
            </a>
            <button type="button" class="btn btn-secondary" onclick="closeEvalModal()">Đóng</button>
        </div>
    </div>
</div>

<style>
.eval-modal-overlay {
    position: fixed;
    top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(15, 23, 42, 0.55);
    backdrop-filter: blur(4px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    animation: evalFadeIn 0.2s ease;
}

@keyframes evalFadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.eval-modal-container {
    background: #ffffff;
    width: 90%;
    max-width: 680px;
    max-height: 85vh;
    border-radius: var(--radius-lg, 12px);
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    border: 1px solid var(--border-color, #e2e8f0);
}

.eval-modal-header {
    padding: 16px 22px;
    background: #ffffff;
    border-bottom: 1px solid var(--border-color, #e2e8f0);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.eval-modal-close {
    background: none;
    border: none;
    font-size: 24px;
    cursor: pointer;
    color: var(--text-muted, #94a3b8);
    line-height: 1;
    transition: color 0.15s ease;
}

.eval-modal-close:hover {
    color: #0f172a;
}

.eval-modal-body {
    padding: 20px;
    overflow-y: auto;
}

.eval-modal-footer {
    padding: 14px 22px;
    background: #f8fafc;
    border-top: 1px solid var(--border-color, #e2e8f0);
}

.feedback-box {
    padding: 14px 16px;
    border-radius: 8px;
    font-size: 13.5px;
    line-height: 1.6;
    white-space: pre-wrap;
    word-break: break-word;
}

.public-box {
    background: #f8fafc;
    border: 1px solid #e0e7ff;
    color: #1e293b;
}

.private-box {
    background: #fffdfd;
    border: 1px solid #fee2e2;
    color: #7f1d1d;
}
</style>

<script>
function openEvalModal(btn) {
    var row = btn.closest('tr');
    var mentee = row.querySelector('.raw-mentee-name').textContent;
    var pubFb = row.querySelector('.raw-public-feedback').textContent;
    var privFb = row.querySelector('.raw-private-feedback').textContent;
    var evalId = row.querySelector('.raw-eval-id').textContent;
    var isApproved = row.querySelector('.raw-is-approved').textContent === 'true';

    document.getElementById('modalMenteeName').textContent = mentee;

    var pubBox = document.getElementById('modalPublicContent');
    pubBox.textContent = pubFb.trim() ? pubFb.trim() : "Chưa có nhận xét công khai.";
    
    var editBtn = document.getElementById('modalEditBtn');
    if (editBtn) {
        if (!isApproved) {
            editBtn.href = '<%= request.getContextPath() %>/mentors?action=editEvaluation&id=' + evalId;
            editBtn.style.display = 'inline-flex';
        } else {
            editBtn.style.display = 'none';
        }
    }

    var privSec = document.getElementById('modalPrivateSection');
    var privBox = document.getElementById('modalPrivateContent');
    if (privFb && privFb.trim()) {
        privSec.style.display = 'block';
        privBox.textContent = privFb.trim();
    } else {
        privSec.style.display = 'none';
    }

    document.getElementById('evalDetailModal').style.display = 'flex';
}

function closeEvalModal() {
    document.getElementById('evalDetailModal').style.display = 'none';
}

window.addEventListener('click', function (e) {
    var modal = document.getElementById('evalDetailModal');
    if (e.target === modal) {
        closeEvalModal();
    }
});
</script>

<jsp:include page="/views/common/footer.jsp" />