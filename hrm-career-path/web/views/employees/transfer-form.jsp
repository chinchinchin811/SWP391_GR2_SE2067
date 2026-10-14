<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Department" %>
<%@ page import="model.Position" %>
<%@ page import="model.User" %>
<%
    User emp = (User) request.getAttribute("employee");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Position> positions = (List<Position>) request.getAttribute("positions");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("errorMessage");
    request.setAttribute("pageTitle", "Đề Xuất Điều Chuyển Vị Trí | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1>Nguyện Vọng Điều Chuyển Vị Trí / Phòng Ban</h1>
        <div>
            <a href="<%= request.getContextPath() %>/transfer?action=myRequests" class="btn btn-secondary">
                <i class="fa-solid fa-list-check"></i> Đề Xuất Của Tôi
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger"><%= errorMessage %></div>
        <% } %>

        <div class="card" style="max-width: 720px; margin: 0 auto;">
            <div class="card-header">
                <h2>Biểu Mẫu Gửi Đề Xuất Điều Chuyển (Internal Mobility)</h2>
            </div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/transfer" method="POST">
                    <input type="hidden" name="action" value="create">

                    <div style="font-weight: bold; margin-bottom: 12px; color: #1e293b; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                        1. Thông tin hiện tại
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Họ và tên nhân sự:</label>
                            <input type="text" class="form-control" value="<%= emp != null ? emp.getFullName() : "" %>" readonly style="background: #f8fafc;">
                        </div>
                        <div class="form-group">
                            <label>Phòng ban hiện tại:</label>
                            <input type="text" class="form-control" value="<%= emp != null && emp.getDepartmentName() != null ? emp.getDepartmentName() : "Chưa xếp phòng" %>" readonly style="background: #f8fafc;">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Vị trí chuyên môn hiện tại:</label>
                            <input type="text" class="form-control" value="<%= emp != null && emp.getPositionName() != null ? emp.getPositionName() : "Chưa có vị trí" %>" readonly style="background: #f8fafc;">
                        </div>
                        <div class="form-group">
                            <label>Cấp bậc hiện tại:</label>
                            <input type="text" class="form-control" value="<%= emp != null && emp.getLevelName() != null ? emp.getLevelName() : "N/A" %>" readonly style="background: #f8fafc;">
                        </div>
                    </div>

                    <div style="font-weight: bold; margin: 20px 0 12px; color: #1e293b; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                        2. Nguyện vọng điều chuyển mới
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="targetDepartmentId">Phòng ban mong muốn đến (*):</label>
                            <select id="targetDepartmentId" name="targetDepartmentId" class="form-control" required onchange="filterPositionsByDept()">
                                <option value="">-- Chọn Phòng Ban Đích --</option>
                                <%
                                    if (departments != null) {
                                        for (Department d : departments) {
                                %>
                                    <option value="<%= d.getDepartmentId() %>"><%= d.getDepartmentName() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="targetPositionId">Vị trí chuyên môn mong muốn:</label>
                            <select id="targetPositionId" name="targetPositionId" class="form-control">
                                <option value="0">-- Chọn Vị Trí Mong Muốn --</option>
                                <%
                                    if (positions != null) {
                                        for (Position p : positions) {
                                            int pDeptId = p.getDepartmentId() != null ? p.getDepartmentId() : 0;
                                %>
                                    <option value="<%= p.getPositionId() %>" data-dept="<%= pDeptId %>">
                                        <%= p.getPositionName() %> (<%= p.getDepartmentName() != null ? p.getDepartmentName() : "Dùng chung" %>)
                                    </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group" style="margin-top: 15px;">
                        <label for="reason">Lý do & Động lực đề xuất điều chuyển (*):</label>
                        <textarea id="reason" name="reason" class="form-control" rows="4" required
                                  placeholder="Trình bày nguyện vọng phát triển, kỹ năng mới đã tích lũy (ví dụ: đã hoàn thành bài test/học liệu Onboarding, mong muốn thử sức mảng Backend/Frontend...)"></textarea>
                    </div>

                    <div class="form-actions" style="margin-top: 25px; display: flex; gap: 10px;">
                        <button type="submit" class="btn btn-primary" style="padding: 10px 24px; font-weight: 600;">
                            <i class="fa-solid fa-paper-plane"></i> GỬI ĐỀ XUẤT CHO TRƯỞNG PHÒNG
                        </button>
                        <a href="<%= request.getContextPath() %>/transfer?action=myRequests" class="btn btn-secondary">
                            Hủy bỏ
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<script>
function filterPositionsByDept() {
    var deptSelect = document.getElementById("targetDepartmentId");
    var posSelect = document.getElementById("targetPositionId");
    var selectedDept = deptSelect.value;
    
    for (var i = 0; i < posSelect.options.length; i++) {
        var opt = posSelect.options[i];
        if (opt.value === "0") continue;
        var optDept = opt.getAttribute("data-dept");
        if (!selectedDept || optDept === "0" || optDept === selectedDept) {
            opt.style.display = "";
        } else {
            opt.style.display = "none";
        }
    }
}
</script>

<jsp:include page="/views/common/footer.jsp" />
