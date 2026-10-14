<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Department" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    Department dept = (Department) request.getAttribute("managerDepartment");
    request.setAttribute("pageTitle", "Tạo Đề Xuất Vị Trí Mới | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />

<main class="main-content">
    <div class="topbar">
        <h1><i class="fa-solid fa-paper-plane"></i> Đề Xuất Vị Trí Chuyên Môn Mới</h1>
        <div>
            <a href="<%= request.getContextPath() %>/positions?action=myRequests" class="btn btn-secondary">
                Quay lại danh sách đề xuất
            </a>
        </div>
    </div>

    <div class="content-body">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="card" style="max-width: 650px; margin: 0 auto; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <div class="card-header" style="background: #f8f9fa;">
                <h2>Phiếu Đề Xuất Bổ Sung Vị Trí Mới (Position Request)</h2>
            </div>
            <div class="card-body">
                <p style="font-size: 13px; color: #666; margin-bottom: 20px;">
                    Phiếu đề xuất này sẽ được gửi tới <b>Quản trị viên (Admin)</b> để xem xét và phê duyệt. Nếu được duyệt, hệ thống sẽ tự động cập nhật vị trí mới vào danh mục cơ cấu của phòng ban bạn.
                </p>

                <form action="<%= request.getContextPath() %>/positions" method="POST">
                    <input type="hidden" name="action" value="createRequest">
                    <input type="hidden" name="departmentId" value="<%= dept != null ? dept.getDepartmentId() : 0 %>">

                    <div class="form-group" style="margin-bottom: 18px;">
                        <label style="font-weight: bold; font-size: 13px;">Phòng Ban Đề Xuất:</label>
                        <input type="text" class="form-control" value="<%= dept != null ? dept.getDepartmentName() : "Chưa xác định" %>" readonly style="background: #e9ecef; font-weight: bold;">
                    </div>

                    <div class="form-group" style="margin-bottom: 18px;">
                        <label for="positionName" style="font-weight: bold; font-size: 13px;">Tên Vị Trí Chuyên Môn Đề Xuất (*):</label>
                        <input type="text" id="positionName" name="positionName" class="form-control" placeholder="Ví dụ: AI Engineer, Data Analyst, Cloud DevOps..." required>
                    </div>

                    <div class="form-group" style="margin-bottom: 18px;">
                        <label for="description" style="font-weight: bold; font-size: 13px;">Mô Tả Vai Trò &amp; Trách Nhiệm Vị Trí:</label>
                        <textarea id="description" name="description" rows="3" class="form-control" placeholder="Mô tả tóm tắt kỹ năng chuyên môn yêu cầu và trách nhiệm chính..."></textarea>
                    </div>

                    <div class="form-group" style="margin-bottom: 25px;">
                        <label for="reason" style="font-weight: bold; font-size: 13px; color: #b71c1c;">Lý Do Cần Mở Vị Trí Mới (*):</label>
                        <textarea id="reason" name="reason" rows="4" class="form-control" placeholder="Trình bày căn cứ nghiệp vụ (Ví dụ: Dự án mở rộng cần bổ sung nhân sự chuyên sâu, khối lượng công việc hiện tại quá tải...)" required></textarea>
                    </div>

                    <div style="text-align: right; border-top: 1px solid #eee; padding-top: 15px;">
                        <a href="<%= request.getContextPath() %>/positions?action=myRequests" class="btn btn-secondary" style="margin-right: 8px;">Hủy bỏ</a>
                        <button type="submit" class="btn btn-primary" style="font-weight: bold;">
                            <i class="fa-solid fa-paper-plane"></i> Gửi Đề Xuất Tới Quản Trị Viên
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
