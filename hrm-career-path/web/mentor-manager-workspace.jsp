<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.TrainingClass" %>
<%@ page import="model.User" %>
<%@ page import="model.Mentor.ClassMenteeEvaluation" %>
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
    if (currentUser == null || currentUser.getRoleId() != 3) { response.sendRedirect(request.getContextPath() + "/dashboard"); return; }
    List<TrainingClass> classes = (List<TrainingClass>) request.getAttribute("managerClasses");
    Map<Integer, List<ClassMenteeEvaluation>> menteesByClass = (Map<Integer, List<ClassMenteeEvaluation>>) request.getAttribute("classMentees");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
    request.setAttribute("pageTitle", "Đánh giá Mentee | CPMS");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1>Đánh giá Mentee</h1>
        <span class="badge-count"><%= classes == null ? 0 : classes.size() %> lớp đào tạo</span>
    </div>
    <div class="content-body">
        <% if (successMessage != null) { %><div class="alert alert-success"><%= successMessage %></div><% } %>
        <% if (errorMessage != null) { %><div class="alert alert-danger"><%= errorMessage %></div><% } %>
        <p style="margin:0 0 20px;color:var(--text-secondary)">Theo dõi đánh giá của mentor và ghi nhận đánh giá của bạn cho mentee trong các lớp thuộc phòng ban.</p>

        <% if (classes != null && !classes.isEmpty()) { for (TrainingClass trainingClass : classes) {
            List<ClassMenteeEvaluation> mentees = menteesByClass == null ? null : menteesByClass.get(trainingClass.getClassId());
            int menteeCount = mentees == null ? 0 : mentees.size();
            String classContentId = "mentee-list-" + trainingClass.getClassId(); %>
        <section class="card">
            <div class="card-header" style="padding:14px 20px">
                <div>
                    <h2 style="margin:0"><i class="fa-solid fa-chalkboard-user" style="color:var(--primary);margin-right:7px"></i><%= trainingClass.getClassName() %></h2>
                    <span style="display:inline-block;margin-top:4px;font-size:12px;color:var(--text-secondary)"><%= trainingClass.getClassCode() %> · <%= trainingClass.getMentorName() == null ? "Chưa phân công mentor" : "Mentor: " + trainingClass.getMentorName() %></span>
                </div>
                <div style="display:flex;align-items:center;gap:12px">
                    <span class="badge-count"><%= menteeCount %> mentee</span>
                    <button class="btn btn-sm btn-secondary" type="button" aria-expanded="false" aria-controls="<%= classContentId %>" onclick="toggleMenteeList(this,'<%= classContentId %>')"><i class="fa-solid fa-chevron-down"></i> Mở danh sách</button>
                </div>
            </div>
            <div id="<%= classContentId %>" style="display:none">
                <div style="overflow-x:auto">
                    <table class="data-table">
                        <thead><tr><th>Mentee</th><th style="text-align:center">Mentor</th><th style="text-align:center">Manager</th><th style="width:230px;text-align:center">Thao tác</th></tr></thead>
                        <tbody>
                        <% if (mentees != null && !mentees.isEmpty()) { for (ClassMenteeEvaluation mentee : mentees) { %>
                            <tr>
                                <td><strong><%= mentee.getMenteeName() %></strong></td>
                                <td style="text-align:center"><%= mentee.getEvaluationId() == null ? "<span style='color:var(--text-muted)'>Chưa đánh giá</span>" : "<span class='badge'><i class='fa-solid fa-star'></i> " + mentee.getScore() + "/10</span>" %></td>
                                <td style="text-align:center"><%= mentee.getManagerEvaluationId() == null ? "<span style='color:var(--text-muted)'>Chưa đánh giá</span>" : "<span class='badge badge-manager'><i class='fa-solid fa-star'></i> " + mentee.getManagerScore() + "/10</span>" %></td>
                                <td style="text-align:center">
                                    <div class="action-btn-group">
                                        <% if (mentee.getEvaluationId() != null || mentee.getManagerEvaluationId() != null) { %>
                                        <button type="button" class="btn btn-sm btn-secondary" onclick="openMenteeEvaluation(this)"
                                            data-mentee="<%= escapeHtml(mentee.getMenteeName()) %>"
                                            data-mentor-score="<%= mentee.getScore() == null ? "" : mentee.getScore() %>"
                                            data-mentor-public="<%= escapeHtml(mentee.getPublicFeedback()) %>"
                                            data-mentor-private="<%= escapeHtml(mentee.getPrivateFeedback()) %>"
                                            data-manager-score="<%= mentee.getManagerScore() == null ? "" : mentee.getManagerScore() %>"
                                            data-manager-public="<%= escapeHtml(mentee.getManagerPublicFeedback()) %>"
                                            data-manager-private="<%= escapeHtml(mentee.getManagerPrivateFeedback()) %>"><i class="fa-solid fa-eye"></i> Chi tiết</button>
                                        <% } %>
                                        <a class="btn btn-sm btn-primary" href="<%= request.getContextPath() %>/mentors?action=evaluateForm&amp;classId=<%= trainingClass.getClassId() %>&amp;menteeId=<%= mentee.getMenteeId() %>"><i class="fa-solid fa-pen-to-square"></i> <%= mentee.getManagerEvaluationId() == null ? "Đánh giá" : "Cập nhật" %></a>
                                    </div>
                                </td>
                            </tr>
                        <% } } else { %><tr><td colspan="4" style="text-align:center;padding:28px;color:var(--text-secondary)">Lớp chưa có nhân viên được ghi danh.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
        <% } } else { %>
        <div class="card"><div class="card-body" style="text-align:center;padding:36px;color:var(--text-secondary)"><i class="fa-solid fa-chalkboard-user" style="font-size:24px;color:var(--text-muted);margin-bottom:10px"></i><p>Chưa có lớp đào tạo nào thuộc phòng ban của bạn.</p></div></div>
        <% } %>
    </div>
</main>

<div id="menteeEvaluationModal" class="mentee-modal-overlay" style="display:none" role="dialog" aria-modal="true" aria-labelledby="menteeModalTitle" onclick="if(event.target===this)closeMenteeEvaluation()">
    <div class="mentee-modal">
        <div class="mentee-modal-header"><div><h2 id="menteeModalTitle">Chi tiết đánh giá</h2><span id="menteeModalName"></span></div><button type="button" class="mentee-modal-close" onclick="closeMenteeEvaluation()" aria-label="Đóng">&times;</button></div>
        <div class="mentee-modal-body">
            <section class="mentee-review"><h3>Đánh giá của mentor <span id="mentorModalScore" class="badge"></span></h3><p id="mentorModalPublic" class="mentee-feedback"></p><p id="mentorModalPrivate" class="mentee-feedback mentee-private"></p></section>
            <section class="mentee-review"><h3>Đánh giá của manager <span id="managerModalScore" class="badge badge-manager"></span></h3><p id="managerModalPublic" class="mentee-feedback"></p><p id="managerModalPrivate" class="mentee-feedback mentee-private"></p></section>
        </div>
        <div class="mentee-modal-footer"><button type="button" class="btn btn-secondary" onclick="closeMenteeEvaluation()">Đóng</button></div>
    </div>
</div>
<style>
.mentee-modal-overlay{position:fixed;inset:0;z-index:1000;background:rgba(15,23,42,.52);display:flex;align-items:center;justify-content:center;padding:20px}
.mentee-modal{width:min(680px,100%);max-height:85vh;overflow:auto;background:var(--bg-surface);border:1px solid var(--border-color);border-radius:var(--radius-lg);box-shadow:var(--shadow-lg)}
.mentee-modal-header,.mentee-modal-footer{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid var(--border-light)}
.mentee-modal-header h2{font-size:16px;margin:0 0 3px}.mentee-modal-header span{font-size:12px;color:var(--text-secondary)}
.mentee-modal-close{border:0;background:none;color:var(--text-secondary);font-size:26px;cursor:pointer;line-height:1}
.mentee-modal-body{display:grid;grid-template-columns:1fr 1fr;gap:14px;padding:18px 20px}
.mentee-review{min-width:0;padding:14px;border:1px solid var(--border-color);border-radius:var(--radius-md);background:#fff}
.mentee-review h3{display:flex;align-items:center;justify-content:space-between;gap:8px;font-size:13px;margin:0 0 12px}
.mentee-feedback{font-size:12.5px;line-height:1.55;color:var(--text-secondary);white-space:pre-wrap;overflow-wrap:anywhere}
.mentee-feedback:empty{display:none}.mentee-private{margin-top:10px;padding-top:10px;border-top:1px solid var(--border-light);color:#9f1239}
.mentee-modal-footer{justify-content:flex-end;border-top:1px solid var(--border-light);border-bottom:0}
@media(max-width:700px){.mentee-modal-body{grid-template-columns:1fr}.topbar .badge-count{display:none}}
</style>
<script>
function toggleMenteeList(button,id){var panel=document.getElementById(id);var opening=panel.style.display==='none';panel.style.display=opening?'block':'none';button.setAttribute('aria-expanded',opening?'true':'false');button.innerHTML=opening?'<i class="fa-solid fa-chevron-up"></i> Thu gọn':'<i class="fa-solid fa-chevron-down"></i> Mở danh sách';}
function setReviewText(id,value,emptyText){var node=document.getElementById(id);node.textContent=value||emptyText;}
function openMenteeEvaluation(button){var data=button.dataset;document.getElementById('menteeModalName').textContent=data.mentee||'';document.getElementById('mentorModalScore').textContent=data.mentorScore?data.mentorScore+'/10':'Chưa đánh giá';document.getElementById('managerModalScore').textContent=data.managerScore?data.managerScore+'/10':'Chưa đánh giá';setReviewText('mentorModalPublic',data.mentorPublic,'Chưa có nhận xét công khai.');setReviewText('mentorModalPrivate',data.mentorPrivate,'');setReviewText('managerModalPublic',data.managerPublic,'Chưa có nhận xét công khai.');setReviewText('managerModalPrivate',data.managerPrivate,'');document.getElementById('menteeEvaluationModal').style.display='flex';}
function closeMenteeEvaluation(){document.getElementById('menteeEvaluationModal').style.display='none';}
window.addEventListener('keydown',function(event){if(event.key==='Escape')closeMenteeEvaluation();});
</script>
<jsp:include page="/views/common/footer.jsp" />
