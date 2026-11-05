<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="model.User" %>
        <%@ page import="model.Mentor.MentorAssignment" %>
            <%@ page import="model.Mentor.MentorEvaluation" %>
                <%@ page import="model.Mentor.EvaluationCriteria" %>
                    <%@ page import="model.Mentor.EvaluationCriteria.Question" %>
                        <%@ page import="model.Mentor.EvaluationCriteria.Option" %>
                            <% User currentUser=(User) session.getAttribute("currentUser"); if (currentUser==null) {
                                response.sendRedirect(request.getContextPath() + "/login" ); return; } MentorEvaluation
                                evaluation=(MentorEvaluation) request.getAttribute("evaluation"); boolean
                                isEdit=(evaluation !=null && evaluation.getEvaluationId()> 0);

                                boolean managerEvaluation =
                                Boolean.TRUE.equals(request.getAttribute("managerEvaluation"));
                                int classId = 0;
                                if (request.getAttribute("classId") != null) {
                                try { classId = Integer.parseInt(request.getAttribute("classId").toString()); } catch
                                (Exception ignored) {}
                                }
                                int menteeId = 0;
                                if (request.getAttribute("menteeId") != null) {
                                try { menteeId = Integer.parseInt(request.getAttribute("menteeId").toString()); } catch
                                (Exception ignored) {}
                                }

                                User mentee = (User) request.getAttribute("mentee");
                                MentorAssignment assignment = (MentorAssignment) request.getAttribute("assignment");

                                String menteeDisplayName = "";
                                String menteeDetails = "";
                                if (mentee != null) {
                                menteeDisplayName = mentee.getFullName() != null ? mentee.getFullName() : "";
                                menteeDetails = (mentee.getPositionName() != null ? mentee.getPositionName() : "")
                                + (mentee.getLevelName() != null ? " · " + mentee.getLevelName() : "");
                                } else if (assignment != null) {
                                menteeDisplayName = assignment.getMenteeName() != null ? assignment.getMenteeName() :
                                "";
                                menteeDetails = (assignment.getPositionName() != null ? assignment.getPositionName() :
                                "")
                                + (assignment.getMenteeLevel() != null ? " · " + assignment.getMenteeLevel() : "");
                                } else if (evaluation != null && evaluation.getMenteeName() != null) {
                                menteeDisplayName = evaluation.getMenteeName();
                                }

                                String backUrl = isEdit
                                ? (request.getContextPath() + "/mentors?action=evaluations")
                                : (request.getContextPath() + (managerEvaluation ? "/mentors?action=managerWorkspace" :
                                "/mentors?action=myMentees"));
                                request.setAttribute("pageTitle", (isEdit ? "Chỉnh Sửa Đánh Giá Mentee" : "Đánh Giá
                                Mentee") + " | CPMS");

                                // Lấy nhận xét cũ nếu đang chỉnh sửa
                                String existingComment = "";
                                if (isEdit && evaluation != null) {
                                String pFb = evaluation.getPublicFeedback() != null ? evaluation.getPublicFeedback() :
                                evaluation.getFeedback();
                                if (pFb != null) {
                                int markerIdx = pFb.indexOf("【NHẬN XÉT CỦA MENTOR】");
                                if (markerIdx != -1) {
                                existingComment = pFb.substring(markerIdx + "【NHẬN XÉT CỦA MENTOR】".length()).trim();
                                }
                                }
                                }
                                %>
                                <jsp:include page="/views/common/header.jsp" />
                                <jsp:include page="/views/common/sidebar.jsp" />

                                <main class="main-content">
                                    <div class="topbar">
                                        <h1>
                                            <%= isEdit ? "Chỉnh Sửa Đánh Giá Mentee" : "Đánh Giá Mentee" %>
                                        </h1>
                                        <a href="<%= backUrl %>" class="btn btn-secondary">
                                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                                        </a>
                                    </div>

                                    <div class="content-body" style="max-width: 960px; margin: 0 auto;">
                                        <% if (!menteeDisplayName.isEmpty()) { %>
                                            <div class="card"
                                                style="margin-bottom: 20px; padding: 18px 24px; display: flex; align-items: center; justify-content: space-between; background: linear-gradient(135deg, #f8fafc 0%, #eef2ff 100%); border: 1px solid #e0e7ff;">
                                                <div style="display: flex; align-items: center; gap: 14px;">
                                                    <div
                                                        style="width: 44px; height: 44px; border-radius: 50%; background: var(--primary, #4f46e5); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                                                        <i class="fa-solid fa-user-graduate"></i>
                                                    </div>
                                                    <div>
                                                        <div
                                                            style="font-size: 11px; text-transform: uppercase; color: var(--primary, #4f46e5); font-weight: 700; letter-spacing: 0.5px;">
                                                            <%= isEdit ? "Đang cập nhật đánh giá học viên"
                                                                : "Đang đánh giá học viên" %>
                                                        </div>
                                                        <div style="font-size: 17px; font-weight: 700; color: #1e293b;">
                                                            <%= menteeDisplayName %>
                                                        </div>
                                                        <% if (!menteeDetails.isEmpty()) { %>
                                                            <div style="font-size: 13px; color: #64748b;">
                                                                <%= menteeDetails %>
                                                            </div>
                                                            <% } %>
                                                    </div>
                                                </div>
                                                <% if (isEdit) { %>
                                                    <span class="badge"
                                                        style="background: #fef3c7; color: #b45309; border: 1px solid #fde68a; font-size: 12px; padding: 6px 12px; border-radius: var(--radius-sm); font-weight: 600;">
                                                        <i class="fa-regular fa-clock"></i> Chờ phê duyệt (Có thể chỉnh
                                                        sửa)
                                                    </span>
                                                    <% } %>
                                            </div>
                                            <% } %>

                                                <form action="<%= request.getContextPath() %>/mentors" method="POST"
                                                    id="evaluationForm" class="card" style="padding: 28px;">
                                                    <input type="hidden" name="action" value="saveEvaluation">
                                                    <% if (isEdit) { %>
                                                        <input type="hidden" name="evaluationId"
                                                            value="<%= evaluation.getEvaluationId() %>">
                                                        <% } %>
                                                            <% if (managerEvaluation) { %>
                                                                <input type="hidden" name="classId"
                                                                    value="<%= classId %>">
                                                                <input type="hidden" name="menteeId"
                                                                    value="<%= menteeId %>">
                                                                <% } else { %>
                                                                    <input type="hidden" name="assignmentId"
                                                                        value="<%= assignment != null ? assignment.getAssignmentId() : (request.getAttribute("
                                                                        assignmentId") !=null ?
                                                                        request.getAttribute("assignmentId") : "" ) %>">
                                                                    <% } %>

                                                                        <%-- SECTION 1: CÔNG KHAI CHO MENTEE XEM --%>
                                                                            <div style="margin-bottom: 32px;">
                                                                                <div
                                                                                    style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                                                                                    <span
                                                                                        style="width: 28px; height: 28px; border-radius: 6px; background: rgba(79, 70, 229, 0.1); color: var(--primary, #4f46e5); display: flex; align-items: center; justify-content: center; font-size: 14px;">
                                                                                        <i class="fa-solid fa-eye"></i>
                                                                                    </span>
                                                                                    <h2
                                                                                        style="font-size: 17px; font-weight: 700; margin: 0; color: #1e293b;">
                                                                                        1. Kết quả đánh giá năng lực
                                                                                        (Mentee có thể xem)</h2>
                                                                                </div>
                                                                                <p
                                                                                    style="font-size: 13px; color: #64748b; margin: 0 0 18px 38px;">
                                                                                    Gồm các câu hỏi đánh giá theo thang
                                                                                    đo định hướng phát triển cho Mentee.
                                                                                </p>

                                                                                <% if
                                                                                    (EvaluationCriteria.PUBLIC_QUESTIONS
                                                                                    !=null) { for (Question q :
                                                                                    EvaluationCriteria.PUBLIC_QUESTIONS)
                                                                                    { %>
                                                                                    <div class="eval-question-card"
                                                                                        style="margin-bottom: 20px; padding: 18px; border: 1px solid #e2e8f0; border-radius: 8px; background: #fafafa;">
                                                                                        <div
                                                                                            style="font-weight: 600; font-size: 14.5px; color: #1e293b; margin-bottom: 12px;">
                                                                                            <%= q.getTitle() %>
                                                                                        </div>
                                                                                        <div
                                                                                            style="display: grid; gap: 10px;">
                                                                                            <% if (q.getOptions()
                                                                                                !=null) { for (Option
                                                                                                opt : q.getOptions()) {
                                                                                                String
                                                                                                cleanLabel=opt.getLabel()
                                                                                                !=null ?
                                                                                                opt.getLabel().replaceAll("\\s*\\([0-9.,]+\\s*đ(?:iểm)?\\)", ""
                                                                                                ).trim() : "" ; String
                                                                                                cleanDesc=opt.getDescription()
                                                                                                !=null ?
                                                                                                opt.getDescription().replaceAll("\\s*\\([0-9.,]+\\s*đ(?:iểm)?\\)", ""
                                                                                                ).trim() : "" ; boolean
                                                                                                isChecked=isEdit &&
                                                                                                evaluation.getPublicFeedback()
                                                                                                !=null &&
                                                                                                evaluation.getPublicFeedback().contains(opt.getDescription());
                                                                                                %>
                                                                                                <label
                                                                                                    class="eval-option-label <%= isChecked ? "
                                                                                                    active" : "" %>"
                                                                                                    style="display:
                                                                                                    flex; align-items:
                                                                                                    flex-start; gap:
                                                                                                    10px; padding: 10px
                                                                                                    14px; border: 1px
                                                                                                    solid #e2e8f0;
                                                                                                    border-radius: 6px;
                                                                                                    background: #ffffff;
                                                                                                    cursor: pointer;
                                                                                                    transition: all
                                                                                                    0.15s ease;">
                                                                                                    <input type="radio"
                                                                                                        name="<%= q.getCode() %>"
                                                                                                        value="<%= opt.getCode() %>"
                                                                                                        <%=isChecked
                                                                                                        ? "checked" : ""
                                                                                                        %> required
                                                                                                    style="margin-top:
                                                                                                    3px; accent-color:
                                                                                                    var(--primary,
                                                                                                    #4f46e5);">
                                                                                                    <div
                                                                                                        style="flex: 1;">
                                                                                                        <div
                                                                                                            style="font-size: 13.5px; font-weight: 600; color: #334155;">
                                                                                                            <span
                                                                                                                style="color: var(--primary, #4f46e5);">
                                                                                                                <%= opt.getCode()
                                                                                                                    %>.
                                                                                                            </span>
                                                                                                            <%= cleanLabel
                                                                                                                %>
                                                                                                        </div>
                                                                                                        <% if
                                                                                                            (!cleanDesc.isEmpty())
                                                                                                            { %>
                                                                                                            <div
                                                                                                                style="font-size: 12.5px; color: #64748b; margin-top: 2px;">
                                                                                                                <%= cleanDesc
                                                                                                                    %>
                                                                                                            </div>
                                                                                                            <% } %>
                                                                                                    </div>
                                                                                                </label>
                                                                                                <% } } %>
                                                                                        </div>
                                                                                    </div>
                                                                                    <% } } %>
                                                                            </div>

                                                                            <%-- SECTION 2: ĐÁNH GIÁ NỘI BỘ --%>
                                                                                <div
                                                                                    style="margin-bottom: 32px; padding-top: 24px; border-top: 2px dashed #e2e8f0;">
                                                                                    <div
                                                                                        style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                                                                                        <span
                                                                                            style="width: 28px; height: 28px; border-radius: 6px; background: rgba(220, 38, 38, 0.1); color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 14px;">
                                                                                            <i
                                                                                                class="fa-solid fa-user-shield"></i>
                                                                                        </span>
                                                                                        <h2
                                                                                            style="font-size: 17px; font-weight: 700; margin: 0; color: #1e293b;">
                                                                                            2. Đánh giá nội bộ (Chỉ
                                                                                            Mentor, HR, và Manager xem)
                                                                                        </h2>
                                                                                    </div>
                                                                                    <p
                                                                                        style="font-size: 13px; color: #dc2626; margin: 0 0 18px 38px;">
                                                                                        <i class="fa-solid fa-lock"
                                                                                            style="font-size: 11px;"></i>
                                                                                        Thông tin bảo mật phục vụ ra
                                                                                        quyết định nhân sự và định hướng
                                                                                        nội bộ. Mentee hoàn toàn KHÔNG
                                                                                        xem được phần này.
                                                                                    </p>

                                                                                    <% if
                                                                                        (EvaluationCriteria.INTERNAL_QUESTIONS
                                                                                        !=null) { for (Question q :
                                                                                        EvaluationCriteria.INTERNAL_QUESTIONS)
                                                                                        { %>
                                                                                        <div class="eval-question-card eval-question-card-internal"
                                                                                            style="margin-bottom: 20px; padding: 18px; border: 1px solid #fee2e2; border-radius: 8px; background: #fffdfd;">
                                                                                            <div
                                                                                                style="font-weight: 600; font-size: 14.5px; color: #1e293b; margin-bottom: 12px;">
                                                                                                <%= q.getTitle() %>
                                                                                            </div>
                                                                                            <div
                                                                                                style="display: grid; gap: 10px;">
                                                                                                <% if (q.getOptions()
                                                                                                    !=null) { for
                                                                                                    (Option opt :
                                                                                                    q.getOptions()) {
                                                                                                    String
                                                                                                    cleanLabel=opt.getLabel()
                                                                                                    !=null ?
                                                                                                    opt.getLabel().replaceAll("\\s*\\([0-9.,]+\\s*đ(?:iểm)?\\)", ""
                                                                                                    ).trim() : "" ;
                                                                                                    String
                                                                                                    cleanDesc=opt.getDescription()
                                                                                                    !=null ?
                                                                                                    opt.getDescription().replaceAll("\\s*\\([0-9.,]+\\s*đ(?:iểm)?\\)", ""
                                                                                                    ).trim() : "" ;
                                                                                                    boolean
                                                                                                    isChecked=isEdit &&
                                                                                                    evaluation.getPrivateFeedback()
                                                                                                    !=null &&
                                                                                                    evaluation.getPrivateFeedback().contains(opt.getDescription());
                                                                                                    %>
                                                                                                    <label
                                                                                                        class="eval-option-label <%= isChecked ? "
                                                                                                        active" : "" %>"
                                                                                                        style="display:
                                                                                                        flex;
                                                                                                        align-items:
                                                                                                        flex-start; gap:
                                                                                                        10px; padding:
                                                                                                        10px 14px;
                                                                                                        border: 1px
                                                                                                        solid #fed7d7;
                                                                                                        border-radius:
                                                                                                        6px; background:
                                                                                                        #ffffff; cursor:
                                                                                                        pointer;
                                                                                                        transition: all
                                                                                                        0.15s ease;">
                                                                                                        <input
                                                                                                            type="radio"
                                                                                                            name="<%= q.getCode() %>"
                                                                                                            value="<%= opt.getCode() %>"
                                                                                                            <%=isChecked
                                                                                                            ? "checked"
                                                                                                            : "" %>
                                                                                                        required
                                                                                                        style="margin-top:
                                                                                                        3px;
                                                                                                        accent-color:
                                                                                                        #dc2626;">
                                                                                                        <div
                                                                                                            style="flex: 1;">
                                                                                                            <div
                                                                                                                style="font-size: 13.5px; font-weight: 600; color: #334155;">
                                                                                                                <span
                                                                                                                    style="color: #dc2626;">
                                                                                                                    <%= opt.getCode()
                                                                                                                        %>
                                                                                                                        .
                                                                                                                </span>
                                                                                                                <%= cleanLabel
                                                                                                                    %>
                                                                                                            </div>
                                                                                                            <% if
                                                                                                                (!cleanDesc.isEmpty())
                                                                                                                { %>
                                                                                                                <div
                                                                                                                    style="font-size: 12.5px; color: #64748b; margin-top: 2px;">
                                                                                                                    <%= cleanDesc
                                                                                                                        %>
                                                                                                                </div>
                                                                                                                <% } %>
                                                                                                        </div>
                                                                                                    </label>
                                                                                                    <% } } %>
                                                                                            </div>
                                                                                        </div>
                                                                                        <% } } %>
                                                                                </div>

                                                                                <%-- SECTION 3: NHẬN XÉT --%>
                                                                                    <div
                                                                                        style="margin-bottom: 28px; padding-top: 24px; border-top: 2px dashed #e2e8f0;">
                                                                                        <label for="comment"
                                                                                            style="display: block; font-weight: 700; font-size: 15px; color: #1e293b; margin-bottom: 8px;">
                                                                                            <i class="fa-solid fa-comment-dots"
                                                                                                style="color: var(--primary, #4f46e5); margin-right: 6px;"></i>
                                                                                            Nhận xét chi tiết
                                                                                        </label>
                                                                                        <p
                                                                                            style="font-size: 13px; color: #64748b; margin: 0 0 10px 0;">
                                                                                            Lời khuyên cụ thể, điểm mạnh
                                                                                            cần phát huy và các kỹ năng
                                                                                            mentee cần rèn luyện thêm:
                                                                                        </p>
                                                                                        <textarea id="comment"
                                                                                            name="comment"
                                                                                            class="form-control"
                                                                                            rows="5" maxlength="4000"
                                                                                            style="width: 100%; border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px; font-family: inherit; font-size: 14px; line-height: 1.5;"
                                                                                            placeholder="Viết nhận xét dành cho mentee..."><%= existingComment %></textarea>
                                                                                    </div>

                                                                                    <%-- ACTIONS --%>
                                                                                        <div
                                                                                            style="display: flex; justify-content: flex-end; align-items: center; gap: 12px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
                                                                                            <a href="<%= backUrl %>"
                                                                                                class="btn btn-secondary">
                                                                                                Hủy bỏ
                                                                                            </a>
                                                                                            <button type="submit"
                                                                                                class="btn btn-primary"
                                                                                                style="padding: 10px 24px; font-weight: 600;">
                                                                                                <i
                                                                                                    class="fa-solid fa-floppy-disk"></i>
                                                                                                <%= isEdit
                                                                                                    ? "Cập nhật đánh giá"
                                                                                                    : "Lưu đánh giá" %>
                                                                                            </button>
                                                                                        </div>
                                                </form>
                                    </div>
                                </main>

                                <style>
                                    .eval-option-label:hover {
                                        border-color: #cbd5e1 !important;
                                        background-color: #f8fafc !important;
                                    }

                                    .eval-option-label.active {
                                        border-color: var(--primary, #4f46e5) !important;
                                        background-color: rgba(79, 70, 229, 0.05) !important;
                                    }

                                    .eval-question-card-internal .eval-option-label.active {
                                        border-color: #ef4444 !important;
                                        background-color: #fef2f2 !important;
                                    }
                                </style>

                                <script>
                                    document.addEventListener('DOMContentLoaded', function () {
                                        var radios = document.querySelectorAll('input[type="radio"]');
                                        radios.forEach(function (r) {
                                            r.addEventListener('change', function () {
                                                var sameGroup = document.querySelectorAll('input[name="' + r.name + '"]');
                                                sameGroup.forEach(function (radio) {
                                                    var label = radio.closest('.eval-option-label');
                                                    if (label) label.classList.remove('active');
                                                });

                                                var currentLabel = r.closest('.eval-option-label');
                                                if (currentLabel) currentLabel.classList.add('active');
                                            });
                                        });
                                    });
                                </script>

                                <jsp:include page="/views/common/footer.jsp" />