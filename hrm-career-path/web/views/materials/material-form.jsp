<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.LearningMaterial,model.Department,model.VideoCheckpoint" %>
<%
    LearningMaterial material = (LearningMaterial) request.getAttribute("material");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<VideoCheckpoint> checkpoints = (List<VideoCheckpoint>) request.getAttribute("checkpoints");
    boolean isEdit = material != null && material.getMaterialId() > 0;
    request.setAttribute("pageTitle", (isEdit ? "Cập nhật" : "Thêm") + " học liệu | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1><%= isEdit ? "Cập Nhật Học Liệu" : "Thêm Học Liệu" %></h1>
        <div class="topbar-actions">
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Quay lại kho học liệu</a>
        </div>
    </div>
    <div class="content-body">
        <div class="card" style="max-width:820px;margin:0 auto">
            <div class="card-header">
                <h2>Thông Tin Học Liệu</h2>
            </div>
            <div class="card-body">
                <form method="post" enctype="multipart/form-data" action="<%= request.getContextPath() %>/materials">
                    <input type="hidden" name="action" value="saveMaterial">
                    <input type="hidden" name="id" value="<%= material.getMaterialId() %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Tiêu đề <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="title"
                                   value="<%= material.getTitle() != null ? material.getTitle() : "" %>">
                        </div>
                        <div class="form-group" style="max-width:160px">
                            <label>Loại học liệu</label>
                            <select class="form-control" name="materialType">
                                <option <%= "PDF".equals(material.getMaterialType()) ? "selected" : "" %>>PDF</option>
                                <option <%= "SLIDE".equals(material.getMaterialType()) ? "selected" : "" %>>SLIDE</option>
                                <option <%= "VIDEO".equals(material.getMaterialType()) ? "selected" : "" %>>VIDEO</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Mô tả</label>
                        <textarea class="form-control" rows="3" name="description"><%= material.getDescription() != null ? material.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Phạm vi</label>
                            <select class="form-control" name="scopeType">
                                <option <%= "CULTURE".equals(material.getScopeType()) ? "selected" : "" %>>CULTURE</option>
                                <option <%= "DEPARTMENT".equals(material.getScopeType()) ? "selected" : "" %>>DEPARTMENT</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Phòng ban</label>
                            <select class="form-control" name="departmentId">
                                <option value="">— Không áp dụng —</option>
                                <% if (departments != null) {
                                    for (Department d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>"
                                    <%= material.getDepartmentId() != null && material.getDepartmentId().equals(d.getDepartmentId()) ? "selected" : "" %>>
                                    <%= d.getDepartmentName() %>
                                </option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="form-group" style="max-width:140px">
                            <label>Thời lượng (phút)</label>
                            <input class="form-control" type="number" min="1" name="durationMinutes"
                                   value="<%= material.getDurationMinutes() %>">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Tệp tải lên <span style="color:#999;font-weight:400;font-size:11.5px">(PDF, Slide hoặc Video)</span></label>
                        <input class="form-control" type="file" name="materialFile" accept=".pdf,.ppt,.pptx,.mp4,.webm">
                    </div>

                    <div class="form-group">
                        <label>Liên kết xem trực tuyến</label>
                        <input class="form-control" name="videoUrl"
                               value="<%= material.getVideoUrl() != null ? material.getVideoUrl() : "" %>"
                               placeholder="YouTube, Google Slides, Google Drive, Office Online hoặc URL MP4">
                        <div style="font-size:11.5px;color:#777;margin-top:5px;line-height:1.6">
                            Slide .ppt/.pptx tải lên từ máy không thể được trình duyệt render trực tiếp.
                            Để xem trên web, hãy dán liên kết công khai Google Slides, Google Drive hoặc Office Online.
                        </div>
                    </div>

                    <div class="form-group">
                        <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-weight:400">
                            <input type="checkbox" name="status" <%= material.isStatus() ? "checked" : "" %>>
                            Công bố học liệu (hiển thị cho nhân viên)
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
                            <input required min="1" type="number" class="form-control" name="stopTimeSeconds">
                        </div>
                        <div class="form-group">
                            <label>Câu hỏi <span style="color:#c00">*</span></label>
                            <input required class="form-control" name="questionPrompt">
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
                            <input class="form-control" name="explanation">
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary">Thêm mốc dừng</button>
                    </div>
                </form>
                <% if (checkpoints != null && !checkpoints.isEmpty()) { %>
                <table class="data-table" style="margin-top:16px">
                    <thead>
                        <tr>
                            <th style="width:80px;text-align:center">Giây</th>
                            <th>Câu hỏi</th>
                            <th style="width:100px;text-align:center">Đáp án đúng</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (VideoCheckpoint checkpoint : checkpoints) { %>
                        <tr>
                            <td style="text-align:center;font-weight:600"><%= checkpoint.getStopTimeSeconds() %></td>
                            <td><%= checkpoint.getQuestionPrompt() %></td>
                            <td style="text-align:center;font-weight:700">
                                <%= checkpoint.getCorrectOption() == 0 ? "A" : checkpoint.getCorrectOption() == 1 ? "B" : checkpoint.getCorrectOption() == 2 ? "C" : "D" %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
