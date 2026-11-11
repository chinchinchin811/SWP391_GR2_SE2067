package model;

/**
 * Quyền hiện tại đọc từ DB mỗi request, không tin role/phòng lưu lâu trong
 * session.
 */
public record TestActor(int id, String name, String role, Integer departmentId, Integer managedDepartmentId) {

    public boolean departmentManager() {
        return "MANAGER".equals(role) && managedDepartmentId != null;
    }
}
