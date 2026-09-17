package dal;

import model.Department;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDAO {

    public List<Department> getAllDepartments() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT d.department_id, d.department_name, d.manager_id, d.description, d.status, d.is_deleted, d.created_at, "
                + "u.full_name AS manager_name, u.email AS manager_email, "
                + "(SELECT COUNT(*) FROM Users WHERE department_id = d.department_id AND is_deleted = 0 AND status = 1) AS employee_count "
                + "FROM Departments d "
                + "LEFT JOIN Users u ON d.manager_id = u.user_id "
                + "WHERE d.is_deleted = 0 "
                + "ORDER BY d.department_id ASC";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Department dept = new Department(
                        rs.getInt("department_id"),
                        rs.getString("department_name"),
                        (Integer) rs.getObject("manager_id"),
                        rs.getString("description"),
                        rs.getBoolean("status"),
                        rs.getTimestamp("created_at")
                );
                dept.setDeleted(rs.getBoolean("is_deleted"));
                dept.setManagerName(rs.getString("manager_name"));
                dept.setManagerEmail(rs.getString("manager_email"));
                dept.setEmployeeCount(rs.getInt("employee_count"));
                list.add(dept);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Department getDepartmentById(int id) {
        String sql = "SELECT d.department_id, d.department_name, d.manager_id, d.description, d.status, d.is_deleted, d.created_at, "
                + "u.full_name AS manager_name, u.email AS manager_email, "
                + "(SELECT COUNT(*) FROM Users WHERE department_id = d.department_id AND is_deleted = 0 AND status = 1) AS employee_count "
                + "FROM Departments d "
                + "LEFT JOIN Users u ON d.manager_id = u.user_id "
                + "WHERE d.department_id = ? AND d.is_deleted = 0";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Department dept = new Department(
                            rs.getInt("department_id"),
                            rs.getString("department_name"),
                            (Integer) rs.getObject("manager_id"),
                            rs.getString("description"),
                            rs.getBoolean("status"),
                            rs.getTimestamp("created_at")
                    );
                    dept.setDeleted(rs.getBoolean("is_deleted"));
                    dept.setManagerName(rs.getString("manager_name"));
                    dept.setManagerEmail(rs.getString("manager_email"));
                    dept.setEmployeeCount(rs.getInt("employee_count"));
                    return dept;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Department getDepartmentByManagerId(int managerId) {
        String sql = "SELECT d.department_id, d.department_name, d.manager_id, d.description, d.status, d.is_deleted, d.created_at, "
                + "u.full_name AS manager_name, u.email AS manager_email, "
                + "(SELECT COUNT(*) FROM Users WHERE department_id = d.department_id AND is_deleted = 0 AND status = 1) AS employee_count "
                + "FROM Departments d "
                + "LEFT JOIN Users u ON d.manager_id = u.user_id "
                + "WHERE d.manager_id = ? AND d.is_deleted = 0";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Department dept = new Department(
                            rs.getInt("department_id"),
                            rs.getString("department_name"),
                            (Integer) rs.getObject("manager_id"),
                            rs.getString("description"),
                            rs.getBoolean("status"),
                            rs.getTimestamp("created_at")
                    );
                    dept.setDeleted(rs.getBoolean("is_deleted"));
                    dept.setManagerName(rs.getString("manager_name"));
                    dept.setManagerEmail(rs.getString("manager_email"));
                    dept.setEmployeeCount(rs.getInt("employee_count"));
                    return dept;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addDepartment(Department dept) {
        String sql = "INSERT INTO Departments (department_name, manager_id, description, status, is_deleted) VALUES (?, ?, ?, ?, 0)";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dept.getDepartmentName());
            if (dept.getManagerId() != null && dept.getManagerId() > 0) {
                ps.setInt(2, dept.getManagerId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, dept.getDescription());
            ps.setBoolean(4, dept.isStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateDepartment(Department dept) {
        String sql = "UPDATE Departments SET department_name = ?, manager_id = ?, description = ?, status = ? WHERE department_id = ? AND is_deleted = 0";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dept.getDepartmentName());
            if (dept.getManagerId() != null && dept.getManagerId() > 0) {
                ps.setInt(2, dept.getManagerId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, dept.getDescription());
            ps.setBoolean(4, dept.isStatus());
            ps.setInt(5, dept.getDepartmentId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean assignManager(int departmentId, Integer managerId) {
        String sql = "UPDATE Departments SET manager_id = ? WHERE department_id = ? AND is_deleted = 0";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (managerId != null && managerId > 0) {
                ps.setInt(1, managerId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setInt(2, departmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // XOA MEM (Soft Delete): Chi cap nhat is_deleted = 1
    public boolean deleteDepartment(int id) {
        String sql = "UPDATE Departments SET is_deleted = 1 WHERE department_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countDepartments() {
        String sql = "SELECT COUNT(*) FROM Departments WHERE is_deleted = 0 AND status = 1";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
