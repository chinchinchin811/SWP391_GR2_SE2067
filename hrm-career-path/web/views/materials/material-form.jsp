<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.LearningMaterial,model.Department,model.VideoCheckpoint" %>
<%
    LearningMaterial material = (LearningMaterial) request.getAttribute("material");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<VideoCheckpoint> checkpoints = (List<VideoCheckpoint>) request.getAttribute("checkpoints");
    boolean isEdit = material != null && material.getMaterialId() > 0;
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("errorMessage");
    request.setAttribute("pageTitle", (isEdit ? "Cập nhật" : "Thêm") + " học liệu | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cập Nhật Học Liệu" : "Thêm Học Liệu" %></h1>
        <div class="topbar-actions">
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Quay lại kho học liệu</a>
            <% if (isEdit) { %>
            <form method="post" action="<%= request.getContextPath() %>/materials" style="display:inline-flex;margin:0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa học liệu này?')">
                <input type="hidden" name="action" value="deleteMaterial">
                <input type="hidden" name="id" value="<%= material.getMaterialId() %>">
                <button type="submit" class="btn btn-danger">Xóa học liệu</button>
            </form>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger" style="max-width:820px;margin:0 auto 16px auto"><%= errorMessage %></div>
        <% } %>

        <div class="card" style="max-width:820px;margin:0 auto">
            <div class="card-header">
                <h2>Thông Tin Học Liệu</h2>
            </div>
            <div class="card-body">
                <form method="post" action="<%= request.getContextPath() %>/materials">
                    <input type="hidden" name="action" value="saveMaterial">
                    <input type="hidden" name="id" value="<%= material != null ? material.getMaterialId() : 0 %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Tiêu đề học liệu <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="title"
                                   placeholder="Nhập tên học liệu đào tạo..."
                                   value="<%= material != null && material.getTitle() != null ? material.getTitle() : "" %>">
                        </div>
                        <div class="form-group" style="max-width:180px">
                            <label>Định dạng học liệu <span style="color:#c00">*</span></label>
                            <select class="form-control" name="materialType" id="materialTypeSelect" onchange="toggleDurationField()">
                                <option value="PDF" <%= material != null && "PDF".equals(material.getMaterialType()) ? "selected" : "" %>>PDF Trực tuyến</option>
                                <option value="SLIDE" <%= material != null && "SLIDE".equals(material.getMaterialType()) ? "selected" : "" %>>Slide Trực tuyến</option>
                                <option value="VIDEO" <%= material != null && "VIDEO".equals(material.getMaterialType()) ? "selected" : "" %>>Video Trực tuyến</option>
                            </select>
                        </div>
                        <div class="form-group" id="durationGroup" style="max-width:150px;<%= (material != null && !"VIDEO".equals(material.getMaterialType())) ? "display:none;" : "" %>">
                            <label>Thời lượng (phút)</label>
                            <input class="form-control" type="number" min="1" name="durationMinutes" id="durationInput"
                                   value="<%= material != null && material.getDurationMinutes() > 0 ? material.getDurationMinutes() : 15 %>">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Đường dẫn học liệu trực tuyến (URL) <span style="color:#c00">*</span></label>
                        <input required class="form-control" name="materialUrl"
                               value="<%= material != null && material.getMaterialUrl() != null ? material.getMaterialUrl() : "" %>"
                               placeholder="https://drive.google.com/..., https://docs.google.com/..., https://youtube.com/..., hoặc link PDF trực tiếp">
                        <div style="font-size:12px;color:#555;margin-top:6px;line-height:1.6;background:#f9fafb;padding:8px 12px;border:1px solid #e5e7eb;border-radius:4px">
                            🔗 <strong>Hỗ trợ liên kết trực tuyến:</strong><br>
                            • <strong>PDF:</strong> Link Google Drive chia sẻ công khai (hệ thống tự động nhúng preview) hoặc link file PDF trực tuyến (.pdf).<br>
                            • <strong>Slide:</strong> Link Google Slides, PowerPoint Online (OneDrive/SharePoint) hoặc file trình chiếu trên Drive.<br>
                            • <strong>Video:</strong> Link YouTube (hỗ trợ câu hỏi dừng video tương tác), video Vimeo hoặc link video trực tuyến.
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Mô tả nội dung</label>
                        <textarea class="form-control" rows="3" name="description" placeholder="Tóm tắt nội dung chính hoặc mục tiêu học tập..."><%= material != null && material.getDescription() != null ? material.getDescription() : "" %></textarea>
                    </div>

                    <input type="hidden" name="scopeType" value="CULTURE">

                    <div class="form-group">
                        <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-weight:400">
                            <input type="checkbox" name="status" <%= (material == null || material.isStatus()) ? "checked" : "" %>>
                            Công bố học liệu (cho phép học viên xem và tham gia học)
                        </label>
                    </div>

                    <div class="form-actions">
                        <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Hủy</a>
                        <button class="btn btn-primary">Lưu học liệu</button>
                    </div>
                </form>
            </div>
        </div>

        <% if (isEdit && "VIDEO".equals(material.getMaterialType())) { %>
        <div class="card" style="max-width:820px;margin:18px auto">
            <div class="card-header">
                <h2>Mốc Dừng &amp; Câu Hỏi Video</h2>
            </div>
            <div class="card-body">
                <form method="post" action="<%= request.getContextPath() %>/materials">
                    <input type="hidden" name="action" value="addCheckpoint">
                    <input type="hidden" name="materialId" value="<%= material.getMaterialId() %>">
                    <div class="form-row">
                        <div class="form-group" style="max-width:160px">
                            <label>Thời điểm dừng (giây) <span style="color:#c00">*</span></label>
                            <input required min="1" type="number" class="form-control" name="stopTimeSeconds" placeholder="VD: 60">
                        </div>
                        <div class="form-group">
                            <label>Câu hỏi <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="questionPrompt" placeholder="Nhập câu hỏi tương tác tại mốc dừng...">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Đáp án A <span style="color:#c00">*</span></label><input required class="form-control" name="optionA"></div>
                        <div class="form-group"><label>Đáp án B <span style="color:#c00">*</span></label><input required class="form-control" name="optionB"></div>
                        <div class="form-group"><label>Đáp án C</label><input class="form-control" name="optionC"></div>
                        <div class="form-group"><label>Đáp án D</label><input class="form-control" name="optionD"></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group" style="max-width:160px">
                            <label>Đáp án đúng</label>
                            <select class="form-control" name="correctOption">
                                <option value="0">A</option>
                                <option value="1">B</option>
                                <option value="2">C</option>
                                <option value="3">D</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Giải thích</label>
                            <input class="form-control" name="explanation" placeholder="Giải thích lý do đáp án đúng...">
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary">+ Thêm mốc dừng mới</button>
                    </div>
                </form>

                <% if (checkpoints != null && !checkpoints.isEmpty()) { %>
                <h3 style="font-size:14px;font-weight:700;margin:24px 0 10px 0;color:#111">Danh Sách Mốc Dừng Đã Thêm</h3>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width:70px;text-align:center">Giây</th>
                            <th>Câu hỏi &amp; Các đáp án</th>
                            <th style="width:105px;text-align:center">Đáp án đúng</th>
                            <th style="width:140px;text-align:center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (VideoCheckpoint cp : checkpoints) { %>
                        <tr>
                            <td style="text-align:center;font-weight:700;font-size:13px;color:#2c3e50">
                                <%= cp.getStopTimeSeconds() %>s
                            </td>
                            <td>
                                <div style="font-weight:600;font-size:13px;color:#111;margin-bottom:4px">
                                    <%= cp.getQuestionPrompt() %>
                                </div>
                                <div style="font-size:11.5px;color:#555;display:grid;grid-template-columns:1fr 1fr;gap:4px">
                                    <span><strong>A:</strong> <%= cp.getOptionA() %></span>
                                    <span><strong>B:</strong> <%= cp.getOptionB() %></span>
                                    <% if (cp.getOptionC() != null && !cp.getOptionC().trim().isEmpty()) { %>
                                    <span><strong>C:</strong> <%= cp.getOptionC() %></span>
                                    <% } %>
                                    <% if (cp.getOptionD() != null && !cp.getOptionD().trim().isEmpty()) { %>
                                    <span><strong>D:</strong> <%= cp.getOptionD() %></span>
                                    <% } %>
                                </div>
                                <% if (cp.getExplanation() != null && !cp.getExplanation().trim().isEmpty()) { %>
                                <div style="font-size:11px;color:#777;margin-top:3px;font-style:italic">
                                    💡 <%= cp.getExplanation() %>
                                </div>
                                <% } %>
                            </td>
                            <td style="text-align:center;font-weight:700;color:#27ae60;font-size:13px">
                                <%= cp.getCorrectOption() == 0 ? "Đáp án A" : cp.getCorrectOption() == 1 ? "Đáp án B" : cp.getCorrectOption() == 2 ? "Đáp án C" : "Đáp án D" %>
                            </td>
                            <td style="text-align:center">
                                <div style="display:inline-flex;gap:4px;align-items:center">
                                    <button type="button" class="btn btn-sm btn-secondary" onclick="openEditModal(<%= cp.getCheckpointId() %>, <%= cp.getStopTimeSeconds() %>, '<%= escapeJs(cp.getQuestionPrompt()) %>', '<%= escapeJs(cp.getOptionA()) %>', '<%= escapeJs(cp.getOptionB()) %>', '<%= escapeJs(cp.getOptionC()) %>', '<%= escapeJs(cp.getOptionD()) %>', <%= cp.getCorrectOption() %>, '<%= escapeJs(cp.getExplanation()) %>')">
                                        Sửa
                                    </button>
                                    <form method="post" action="<%= request.getContextPath() %>/materials" style="margin:0;display:inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa mốc dừng câu hỏi này?')">
                                        <input type="hidden" name="action" value="deleteCheckpoint">
                                        <input type="hidden" name="checkpointId" value="<%= cp.getCheckpointId() %>">
                                        <input type="hidden" name="materialId" value="<%= material.getMaterialId() %>">
                                        <button type="submit" class="btn btn-sm btn-danger">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>

        <div id="editCheckpointModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:99999;align-items:center;justify-content:center;backdrop-filter:blur(2px)">
            <div style="width:640px;max-width:92%;background:#fff;border-radius:8px;box-shadow:0 12px 36px rgba(0,0,0,0.3);overflow:hidden">
                <div style="background:#111;color:#fff;padding:12px 20px;display:flex;align-items:center;justify-content:space-between">
                    <h3 style="margin:0;font-size:15px;font-weight:700">Chỉnh Sửa Câu Hỏi Mốc Dừng</h3>
                    <button type="button" onclick="closeEditModal()" style="background:none;border:none;color:#fff;font-size:22px;cursor:pointer;line-height:1">&times;</button>
                </div>
                <form method="post" action="<%= request.getContextPath() %>/materials" style="padding:20px">
                    <input type="hidden" name="action" value="updateCheckpoint">
                    <input type="hidden" name="checkpointId" id="editCpId">
                    <input type="hidden" name="materialId" value="<%= material.getMaterialId() %>">
                    <div class="form-row">
                        <div class="form-group" style="max-width:160px">
                            <label>Thời điểm dừng (giây) <span style="color:#c00">*</span></label>
                            <input required min="1" type="number" class="form-control" name="stopTimeSeconds" id="editCpTime">
                        </div>
                        <div class="form-group">
                            <label>Câu hỏi <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="questionPrompt" id="editCpPrompt">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Đáp án A <span style="color:#c00">*</span></label><input required class="form-control" name="optionA" id="editCpOptA"></div>
                        <div class="form-group"><label>Đáp án B <span style="color:#c00">*</span></label><input required class="form-control" name="optionB" id="editCpOptB"></div>
                        <div class="form-group"><label>Đáp án C</label><input class="form-control" name="optionC" id="editCpOptC"></div>
                        <div class="form-group"><label>Đáp án D</label><input class="form-control" name="optionD" id="editCpOptD"></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group" style="max-width:160px">
                            <label>Đáp án đúng</label>
                            <select class="form-control" name="correctOption" id="editCpCorrect">
                                <option value="0">Đáp án A</option>
                                <option value="1">Đáp án B</option>
                                <option value="2">Đáp án C</option>
                                <option value="3">Đáp án D</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Giải thích</label>
                            <input class="form-control" name="explanation" id="editCpExplanation">
                        </div>
                    </div>
                    <div class="form-actions" style="margin-top:16px;display:flex;justify-content:flex-end;gap:10px">
                        <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</main>

<script>
    function toggleDurationField() {
        var select = document.getElementById('materialTypeSelect');
        var durationGroup = document.getElementById('durationGroup');
        if (!select || !durationGroup) return;
        if (select.value === 'VIDEO') {
            durationGroup.style.display = '';
        } else {
            durationGroup.style.display = 'none';
        }
    }

    function openEditModal(id, time, prompt, a, b, c, d, correct, explanation) {
        document.getElementById('editCpId').value = id;
        document.getElementById('editCpTime').value = time;
        document.getElementById('editCpPrompt').value = prompt || '';
        document.getElementById('editCpOptA').value = a || '';
        document.getElementById('editCpOptB').value = b || '';
        document.getElementById('editCpOptC').value = c || '';
        document.getElementById('editCpOptD').value = d || '';
        document.getElementById('editCpCorrect').value = correct;
        document.getElementById('editCpExplanation').value = explanation || '';
        document.getElementById('editCheckpointModal').style.display = 'flex';
    }

    function closeEditModal() {
        var modal = document.getElementById('editCheckpointModal');
        if (modal) modal.style.display = 'none';
    }
</script>

<jsp:include page="/views/common/footer.jsp" />

<%!
    String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
%>
