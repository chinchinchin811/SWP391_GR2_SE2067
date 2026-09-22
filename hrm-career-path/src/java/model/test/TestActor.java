package model;

/**
 * Quyền hiện tại đọc từ DB mỗi request, không tin role/phòng lưu lâu trong
 * session.
 */
public record TestActor(int id, String name, String role, Integer departmentId, Integer managedDepartmentId) {

    /** ADMIN/HR có quyền quản lý đánh giá toàn công ty. */
    public boolean cultureManager() {
        return "ADMIN".equals(role) || "HR".equals(role);
    }

    /**
     * Chỉ MANAGER còn được gán quản lý chính phòng mình mới quản lý bài chuyên
     * môn.
     */
    public boolean departmentManager() {
        return "MANAGER".equals(role) && managedDepartmentId != null;
    }
}
