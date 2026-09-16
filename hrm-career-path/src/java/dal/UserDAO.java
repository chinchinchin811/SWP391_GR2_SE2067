package dal;

import model.EmployeeHistory;
import model.User;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User login(String username, String password) {
        String sql = "SELECT u.*, r.role_name, d.department_name, p.position_name, l.level_name "
                   + "FROM Users u "
                   + "JOIN Roles r ON u.role_id = r.role_id "
                   + "LEFT JOIN Departments d ON u.department_id = d.department_id "
                   + "LEFT JOIN Positions p ON u.position_id = p.position_id "
                   + "LEFT JOIN Job_Levels l ON u.level_id = l.level_id "
                   + "WHERE (u.username = ? OR u.email = ?) AND u.password = ? AND u.is_deleted = 0 AND u.status = 1";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> getAllEmployees(String search, Integer deptId, Integer posId, Integer roleId) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.*, r.role_name, d.department_name, p.position_name, l.level_name "
          + "FROM Users u "
          + "JOIN Roles r ON u.role_id = r.role_id "
          + "LEFT JOIN Departments d ON u.department_id = d.department_id "
          + "LEFT JOIN Positions p ON u.position_id = p.position_id "
          + "LEFT JOIN Job_Levels l ON u.level_id = l.level_id "
          + "WHERE u.is_deleted = 0 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR u.email LIKE ? OR u.username LIKE ? OR u.phone LIKE ?) ");
        }
        if (deptId != null && deptId > 0) {
            sql.append("AND u.department_id = ? ");
        } else if (deptId != null && deptId == -1) {
            sql.append("AND 1=0 "); // Manager khong quan ly phong nao
        }
        if (posId != null && posId > 0) {
            sql.append("AND u.position_id = ? ");
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
        }

        sql.append("ORDER BY u.user_id DESC");

        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String pattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, pattern);
                ps.setString(paramIndex++, pattern);
                ps.setString(paramIndex++, pattern);
                ps.setString(paramIndex++, pattern);
            }
            if (deptId != null && deptId > 0) {
                ps.setInt(paramIndex++, deptId);
            }
            if (posId != null && posId > 0) {
                ps.setInt(paramIndex++, posId);
            }
            if (roleId != null && roleId > 0) {
                ps.setInt(paramIndex++, roleId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUserFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getManagersCandidates() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.*, r.role_name, d.department_name, p.position_name, l.level_name "
                   + "FROM Users u "
                   + "JOIN Roles r ON u.role_id = r.role_id "
                   + "LEFT JOIN Departments d ON u.department_id = d.department_id "
                   + "LEFT JOIN Positions p ON u.position_id = p.position_id "
                   + "LEFT JOIN Job_Levels l ON u.level_id = l.level_id "
                   + "WHERE u.is_deleted = 0 AND u.status = 1 AND u.role_id IN (1, 2, 3) "
                   + "ORDER BY u.full_name ASC";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUserFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public User getUserById(int id) {
        String sql = "SELECT u.*, r.role_name, d.department_name, p.position_name, l.level_name "
                   + "FROM Users u "
                   + "JOIN Roles r ON u.role_id = r.role_id "
                   + "LEFT JOIN Departments d ON u.department_id = d.department_id "
                   + "LEFT JOIN Positions p ON u.position_id = p.position_id "
                   + "LEFT JOIN Job_Levels l ON u.level_id = l.level_id "
                   + "WHERE u.user_id = ? AND u.is_deleted = 0";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addEmployee(User user, int createdBy) {
        String sqlUser = "INSERT INTO Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";
        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            int newUserId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, user.getUsername());
                ps.setString(2, user.getPassword() != null && !user.getPassword().isEmpty() ? user.getPassword() : "123");
                ps.setString(3, user.getFullName());
                ps.setString(4, user.getEmail());
                ps.setString(5, user.getPhone());
                ps.setString(6, user.getGender());
                if (user.getDob() != null) {
                    ps.setDate(7, user.getDob());
                } else {
                    ps.setNull(7, Types.DATE);
                }
                ps.setInt(8, user.getRoleId());
                
                if (user.getDepartmentId() != null && user.getDepartmentId() > 0) {
                    ps.setInt(9, user.getDepartmentId());
                } else {
                    ps.setNull(9, Types.INTEGER);
                }

                if (user.getPositionId() != null && user.getPositionId() > 0) {
                    ps.setInt(10, user.getPositionId());
                } else {
                    ps.setNull(10, Types.INTEGER);
                }

                if (user.getLevelId() != null && user.getLevelId() > 0) {
                    ps.setInt(11, user.getLevelId());
                } else {
                    ps.setNull(11, Types.INTEGER);
                }

                if (user.getHireDate() != null) {
                    ps.setDate(12, user.getHireDate());
                } else {
                    ps.setDate(12, new Date(System.currentTimeMillis()));
                }
                ps.setBoolean(13, user.isStatus());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            newUserId = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            if (newUserId > 0) {
                // Ghi nhan lich su tuyen dung
                String sqlHistory = "INSERT INTO Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) "
                                  + "VALUES (?, NULL, ?, NULL, ?, NULL, ?, 'NEW_HIRE', GETDATE(), ?, ?)";
                try (PreparedStatement psHist = conn.prepareStatement(sqlHistory)) {
                    psHist.setInt(1, newUserId);
                    if (user.getDepartmentId() != null && user.getDepartmentId() > 0) {
                        psHist.setInt(2, user.getDepartmentId());
                    } else {
                        psHist.setNull(2, Types.INTEGER);
                    }
                    if (user.getPositionId() != null && user.getPositionId() > 0) {
                        psHist.setInt(3, user.getPositionId());
                    } else {
                        psHist.setNull(3, Types.INTEGER);
                    }
                    if (user.getLevelId() != null && user.getLevelId() > 0) {
                        psHist.setInt(4, user.getLevelId());
                    } else {
                        psHist.setNull(4, Types.INTEGER);
                    }
                    psHist.setString(5, "Tuyen dung nhan vien moi vao he thong");
                    if (createdBy > 0) {
                        psHist.setInt(6, createdBy);
                    } else {
                        psHist.setNull(6, Types.INTEGER);
                    }
                    psHist.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
        return false;
    }

    public boolean updateEmployee(User user) {
        String sql = "UPDATE Users SET full_name = ?, email = ?, phone = ?, gender = ?, dob = ?, role_id = ?, status = ? WHERE user_id = ? AND is_deleted = 0";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getGender());
            if (user.getDob() != null) {
                ps.setDate(5, user.getDob());
            } else {
                ps.setNull(5, Types.DATE);
            }
            ps.setInt(6, user.getRoleId());
            ps.setBoolean(7, user.isStatus());
            ps.setInt(8, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // XOA MEM NHAN SU (Soft Delete)
    public boolean deleteEmployee(int id) {
        String sql = "UPDATE Users SET is_deleted = 1 WHERE user_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateEmployeeAssignment(int userId, Integer newDeptId, Integer newPosId, Integer newLevelId, String changeType, String notes, int updatedBy) {
        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            // 1. Lay thong tin hien tai
            Integer oldDeptId = null;
            Integer oldPosId = null;
            Integer oldLevelId = null;

            String selectSql = "SELECT department_id, position_id, level_id FROM Users WHERE user_id = ? AND is_deleted = 0";
            try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
                psSelect.setInt(1, userId);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        oldDeptId = (Integer) rs.getObject("department_id");
                        oldPosId = (Integer) rs.getObject("position_id");
                        oldLevelId = (Integer) rs.getObject("level_id");
                    }
                }
            }

            // 2. Cap nhat bang Users
            String updateSql = "UPDATE Users SET department_id = ?, position_id = ?, level_id = ? WHERE user_id = ? AND is_deleted = 0";
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                if (newDeptId != null && newDeptId > 0) {
                    psUpdate.setInt(1, newDeptId);
                } else {
                    psUpdate.setNull(1, Types.INTEGER);
                }

                if (newPosId != null && newPosId > 0) {
                    psUpdate.setInt(2, newPosId);
                } else {
                    psUpdate.setNull(2, Types.INTEGER);
                }

                if (newLevelId != null && newLevelId > 0) {
                    psUpdate.setInt(3, newLevelId);
                } else {
                    psUpdate.setNull(3, Types.INTEGER);
                }
                psUpdate.setInt(4, userId);
                psUpdate.executeUpdate();
            }

            // 3. Ghi lich su
            String historySql = "INSERT INTO Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) "
                              + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";
            try (PreparedStatement psHist = conn.prepareStatement(historySql)) {
                psHist.setInt(1, userId);
                if (oldDeptId != null) psHist.setInt(2, oldDeptId); else psHist.setNull(2, Types.INTEGER);
                if (newDeptId != null && newDeptId > 0) psHist.setInt(3, newDeptId); else psHist.setNull(3, Types.INTEGER);
                if (oldPosId != null) psHist.setInt(4, oldPosId); else psHist.setNull(4, Types.INTEGER);
                if (newPosId != null && newPosId > 0) psHist.setInt(5, newPosId); else psHist.setNull(5, Types.INTEGER);
                if (oldLevelId != null) psHist.setInt(6, oldLevelId); else psHist.setNull(6, Types.INTEGER);
                if (newLevelId != null && newLevelId > 0) psHist.setInt(7, newLevelId); else psHist.setNull(7, Types.INTEGER);
                psHist.setString(8, changeType != null && !changeType.isEmpty() ? changeType : "ROLE_CHANGE");
                psHist.setString(9, notes);
                if (updatedBy > 0) psHist.setInt(10, updatedBy); else psHist.setNull(10, Types.INTEGER);
                psHist.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
        return false;
    }

    public List<EmployeeHistory> getHistoryByUserId(int userId) {
        List<EmployeeHistory> list = new ArrayList<>();
        String sql = "SELECT h.*, u.full_name AS user_name, "
                   + "d_old.department_name AS old_dept_name, d_new.department_name AS new_dept_name, "
                   + "p_old.position_name AS old_pos_name, p_new.position_name AS new_pos_name, "
                   + "l_old.level_name AS old_lvl_name, l_new.level_name AS new_lvl_name, "
                   + "creator.full_name AS creator_name "
                   + "FROM Employee_History h "
                   + "JOIN Users u ON h.user_id = u.user_id "
                   + "LEFT JOIN Departments d_old ON h.old_department_id = d_old.department_id "
                   + "LEFT JOIN Departments d_new ON h.new_department_id = d_new.department_id "
                   + "LEFT JOIN Positions p_old ON h.old_position_id = p_old.position_id "
                   + "LEFT JOIN Positions p_new ON h.new_position_id = p_new.position_id "
                   + "LEFT JOIN Job_Levels l_old ON h.old_level_id = l_old.level_id "
                   + "LEFT JOIN Job_Levels l_new ON h.new_level_id = l_new.level_id "
                   + "LEFT JOIN Users creator ON h.created_by = creator.user_id "
                   + "WHERE h.user_id = ? "
                   + "ORDER BY h.change_date DESC";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EmployeeHistory eh = new EmployeeHistory();
                    eh.setHistoryId(rs.getInt("history_id"));
                    eh.setUserId(rs.getInt("user_id"));
                    eh.setUserName(rs.getString("user_name"));
                    eh.setOldDepartmentId((Integer) rs.getObject("old_department_id"));
                    eh.setOldDepartmentName(rs.getString("old_dept_name"));
                    eh.setNewDepartmentId((Integer) rs.getObject("new_department_id"));
                    eh.setNewDepartmentName(rs.getString("new_dept_name"));
                    eh.setOldPositionId((Integer) rs.getObject("old_position_id"));
                    eh.setOldPositionName(rs.getString("old_pos_name"));
                    eh.setNewPositionId((Integer) rs.getObject("new_position_id"));
                    eh.setNewPositionName(rs.getString("new_pos_name"));
                    eh.setOldLevelId((Integer) rs.getObject("old_level_id"));
                    eh.setOldLevelName(rs.getString("old_lvl_name"));
                    eh.setNewLevelId((Integer) rs.getObject("new_level_id"));
                    eh.setNewLevelName(rs.getString("new_lvl_name"));
                    eh.setChangeType(rs.getString("change_type"));
                    eh.setChangeDate(rs.getTimestamp("change_date"));
                    eh.setNotes(rs.getString("notes"));
                    eh.setCreatedBy((Integer) rs.getObject("created_by"));
                    eh.setCreatorName(rs.getString("creator_name"));
                    list.add(eh);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countEmployees() {
        String sql = "SELECT COUNT(*) FROM Users WHERE is_deleted = 0 AND status = 1";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countNewHires() {
        String sql = "SELECT COUNT(*) FROM Employee_History h JOIN Users u ON h.user_id = u.user_id WHERE u.is_deleted = 0 AND h.change_type = 'NEW_HIRE'";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countRoleChanges() {
        String sql = "SELECT COUNT(*) FROM Employee_History h JOIN Users u ON h.user_id = u.user_id WHERE u.is_deleted = 0 AND h.change_type IN ('ROLE_CHANGE', 'DEPARTMENT_TRANSFER', 'PROMOTION')";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private User mapUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setGender(rs.getString("gender"));
        user.setDob(rs.getDate("dob"));
        user.setRoleId(rs.getInt("role_id"));
        user.setRoleName(rs.getString("role_name"));
        user.setDepartmentId((Integer) rs.getObject("department_id"));
        user.setDepartmentName(rs.getString("department_name"));
        user.setPositionId((Integer) rs.getObject("position_id"));
        user.setPositionName(rs.getString("position_name"));
        user.setLevelId((Integer) rs.getObject("level_id"));
        user.setLevelName(rs.getString("level_name"));
        user.setHireDate(rs.getDate("hire_date"));
        user.setStatus(rs.getBoolean("status"));
        user.setDeleted(rs.getBoolean("is_deleted"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}
