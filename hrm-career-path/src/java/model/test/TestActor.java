package model;

/**
 * Quyền hiện tại đọc từ DB mỗi request, không tin role/phòng lưu lâu trong
 * session.
 */
public record TestActor(int id, String name, String role, Integer departmentId, Integer managedDepartmentId) {

    /** ADMIN quản lý bài văn hóa; HR làm bài như nhân viên thường. */
    public boolean cultureManager() {
        return "ADMIN".equals(role);
    }

    /**
     * Chỉ MANAGER còn được gán quản lý chính phòng mình mới quản lý bài chuyên
     * môn.
     */
    public boolean departmentManager() {
        return "MANAGER".equals(role) && managedDepartmentId != null;
    }

    /** MANAGER chỉ quản lý bài chuyên môn của phòng được giao. */
    public boolean professionalManager() {
        return departmentManager();
    }
}
