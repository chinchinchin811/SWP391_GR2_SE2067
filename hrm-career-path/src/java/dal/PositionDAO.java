package dal;

import model.JobLevel;
import model.Position;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class PositionDAO {

    public List<Position> getAllPositions() {
        List<Position> list = new ArrayList<>();
        String sql = """
            SELECT p.position_id, p.position_name, p.department_id, p.description, p.status, p.is_deleted, p.created_at,
                   d.department_name,
                   (SELECT COUNT(*) FROM Users WHERE position_id = p.position_id AND is_deleted = 0 AND status = 1) AS employee_count
            FROM Positions p
            LEFT JOIN Departments d ON p.department_id = d.department_id
            WHERE p.is_deleted = 0
            ORDER BY p.position_id ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Position pos = new Position(
                        rs.getInt("position_id"),
                        rs.getString("position_name"),
                        (Integer) rs.getObject("department_id"),
                        rs.getString("description"),
                        rs.getBoolean("status"),
                        rs.getTimestamp("created_at")
                );
                pos.setDeleted(rs.getBoolean("is_deleted"));
                pos.setDepartmentName(rs.getString("department_name"));
                pos.setEmployeeCount(rs.getInt("employee_count"));
                list.add(pos);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Position> getPositionsByDepartment(Integer deptId) {
        return getPositionsByDepartment(deptId, null);
    }

    public List<Position> getPositionsByDepartment(Integer deptId, String keyword) {
        List<Position> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT p.position_id, p.position_name, p.department_id, p.description, p.status, p.is_deleted, p.created_at,
                   d.department_name,
                   (SELECT COUNT(*) FROM Users WHERE position_id = p.position_id AND is_deleted = 0 AND status = 1) AS employee_count
            FROM Positions p
            LEFT JOIN Departments d ON p.department_id = d.department_id
            WHERE p.is_deleted = 0
            """);

        List<Object> params = new ArrayList<>();
        if (deptId != null && deptId > 0) {
            sql.append(" AND p.department_id = ?");
            params.add(deptId);
        } else if (deptId != null && deptId == -1) {
            sql.append(" AND 1=0");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.position_name LIKE ? OR p.description LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        sql.append(" ORDER BY p.position_name ASC");

        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Position pos = new Position(
                            rs.getInt("position_id"),
                            rs.getString("position_name"),
                            (Integer) rs.getObject("department_id"),
                            rs.getString("description"),
                            rs.getBoolean("status"),
                            rs.getTimestamp("created_at")
                    );
                    pos.setDeleted(rs.getBoolean("is_deleted"));
                    pos.setDepartmentName(rs.getString("department_name"));
                    pos.setEmployeeCount(rs.getInt("employee_count"));
                    list.add(pos);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Position getPositionById(int id) {
        String sql = """
            SELECT p.position_id, p.position_name, p.department_id, p.description, p.status, p.is_deleted, p.created_at,
                   d.department_name,
                   (SELECT COUNT(*) FROM Users WHERE position_id = p.position_id AND is_deleted = 0 AND status = 1) AS employee_count
            FROM Positions p
            LEFT JOIN Departments d ON p.department_id = d.department_id
            WHERE p.position_id = ? AND p.is_deleted = 0
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Position pos = new Position(
                            rs.getInt("position_id"),
                            rs.getString("position_name"),
                            (Integer) rs.getObject("department_id"),
                            rs.getString("description"),
                            rs.getBoolean("status"),
                            rs.getTimestamp("created_at")
                    );
                    pos.setDeleted(rs.getBoolean("is_deleted"));
                    pos.setDepartmentName(rs.getString("department_name"));
                    pos.setEmployeeCount(rs.getInt("employee_count"));
                    return pos;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isPositionNameExists(String name, Integer departmentId, Integer excludePositionId) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) 
            FROM Positions 
            WHERE LOWER(LTRIM(RTRIM(position_name))) = LOWER(?) 
              AND is_deleted = 0
            """);
        if (departmentId != null && departmentId > 0) {
            sql.append(" AND department_id = ?");
        } else {
            sql.append(" AND department_id IS NULL");
        }
        if (excludePositionId != null && excludePositionId > 0) {
            sql.append(" AND position_id <> ?");
        }
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, name.trim());
            int idx = 2;
            if (departmentId != null && departmentId > 0) {
                ps.setInt(idx++, departmentId);
            }
            if (excludePositionId != null && excludePositionId > 0) {
                ps.setInt(idx++, excludePositionId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addPosition(Position pos) {
        String sql = """
            INSERT INTO Positions (position_name, department_id, description, status, is_deleted) 
            VALUES (?, ?, ?, ?, 0)
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pos.getPositionName());
            if (pos.getDepartmentId() != null && pos.getDepartmentId() > 0) {
                ps.setInt(2, pos.getDepartmentId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, pos.getDescription());
            ps.setBoolean(4, pos.isStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePosition(Position pos) {
        String sql = """
            UPDATE Positions 
            SET position_name = ?, department_id = ?, description = ?, status = ? 
            WHERE position_id = ? AND is_deleted = 0
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pos.getPositionName());
            if (pos.getDepartmentId() != null && pos.getDepartmentId() > 0) {
                ps.setInt(2, pos.getDepartmentId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, pos.getDescription());
            ps.setBoolean(4, pos.isStatus());
            ps.setInt(5, pos.getPositionId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // XOA MEM (Soft Delete): Cap nhat is_deleted = 1
    public boolean deletePosition(int id) {
        String sql = """
            UPDATE Positions 
            SET is_deleted = 1 
            WHERE position_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<JobLevel> getAllJobLevels() {
        List<JobLevel> list = new ArrayList<>();
        String sql = """
            SELECT level_id, position_id, level_name, rank_order, description 
            FROM Job_Levels 
            ORDER BY rank_order ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                JobLevel level = new JobLevel(
                        rs.getInt("level_id"),
                        (Integer) rs.getObject("position_id"),
                        rs.getString("level_name"),
                        rs.getInt("rank_order"),
                        rs.getString("description")
                );
                list.add(level);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<JobLevel> getLevelsByPosition(int positionId) {
        List<JobLevel> list = new ArrayList<>();
        String sql = """
            SELECT level_id, position_id, level_name, rank_order, description 
            FROM Job_Levels 
            WHERE position_id = ?
            ORDER BY rank_order ASC, level_id ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JobLevel level = new JobLevel(
                            rs.getInt("level_id"),
                            (Integer) rs.getObject("position_id"),
                            rs.getString("level_name"),
                            rs.getInt("rank_order"),
                            rs.getString("description")
                    );
                    list.add(level);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public JobLevel getJobLevelById(int levelId) {
        String sql = """
            SELECT level_id, position_id, level_name, rank_order, description 
            FROM Job_Levels 
            WHERE level_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, levelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new JobLevel(
                            rs.getInt("level_id"),
                            (Integer) rs.getObject("position_id"),
                            rs.getString("level_name"),
                            rs.getInt("rank_order"),
                            rs.getString("description")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int addJobLevel(JobLevel level) {
        String countSql = "SELECT ISNULL(MAX(rank_order), 0) FROM Job_Levels WHERE position_id = ?";
        String shiftSql = "UPDATE Job_Levels SET rank_order = rank_order + 1 WHERE position_id = ? AND rank_order >= ?";
        String insertSql = """
            INSERT INTO Job_Levels (position_id, level_name, rank_order, description)
            VALUES (?, ?, ?, ?)
            """;

        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            int targetRank = level.getRankOrder();
            if (level.getPositionId() != null) {
                int posId = level.getPositionId();
                int maxRank = 0;
                try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                    psCount.setInt(1, posId);
                    try (ResultSet rs = psCount.executeQuery()) {
                        if (rs.next()) {
                            maxRank = rs.getInt(1);
                        }
                    }
                }

                if (targetRank <= 0) {
                    targetRank = 1;
                } else if (targetRank > maxRank + 1) {
                    targetRank = maxRank + 1;
                }

                // Nếu chèn vào vị trí rank đã có -> Tự động đẩy các bậc từ targetRank trở đi lên 1 bậc
                if (targetRank <= maxRank) {
                    try (PreparedStatement psShift = conn.prepareStatement(shiftSql)) {
                        psShift.setInt(1, posId);
                        psShift.setInt(2, targetRank);
                        psShift.executeUpdate();
                    }
                }
            } else {
                if (targetRank <= 0) targetRank = 1;
            }

            int newId = -1;
            try (PreparedStatement ps = conn.prepareStatement(insertSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                if (level.getPositionId() != null) {
                    ps.setInt(1, level.getPositionId());
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setString(2, level.getLevelName());
                ps.setInt(3, targetRank);
                ps.setString(4, level.getDescription());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            newId = rs.getInt(1);
                        }
                    }
                }
            }

            conn.commit();
            return newId;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
        return -1;
    }

    public boolean updateJobLevel(JobLevel level) {
        JobLevel existing = getJobLevelById(level.getLevelId());
        if (existing == null) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            int oldRank = existing.getRankOrder();
            int newRank = level.getRankOrder();
            Integer posId = existing.getPositionId();

            if (posId != null && oldRank != newRank) {
                int maxRank = 0;
                String countSql = "SELECT ISNULL(MAX(rank_order), 0) FROM Job_Levels WHERE position_id = ?";
                try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                    psCount.setInt(1, posId);
                    try (ResultSet rs = psCount.executeQuery()) {
                        if (rs.next()) {
                            maxRank = rs.getInt(1);
                        }
                    }
                }

                if (newRank <= 0) newRank = 1;
                if (newRank > maxRank) newRank = maxRank;

                if (newRank > oldRank) {
                    // Chuyển lên bậc cao hơn: Các bậc ở giữa giảm 1
                    String shiftDown = "UPDATE Job_Levels SET rank_order = rank_order - 1 WHERE position_id = ? AND rank_order > ? AND rank_order <= ?";
                    try (PreparedStatement psShift = conn.prepareStatement(shiftDown)) {
                        psShift.setInt(1, posId);
                        psShift.setInt(2, oldRank);
                        psShift.setInt(3, newRank);
                        psShift.executeUpdate();
                    }
                } else if (newRank < oldRank) {
                    // Chuyển xuống bậc thấp hơn: Các bậc ở giữa tăng 1
                    String shiftUp = "UPDATE Job_Levels SET rank_order = rank_order + 1 WHERE position_id = ? AND rank_order >= ? AND rank_order < ?";
                    try (PreparedStatement psShift = conn.prepareStatement(shiftUp)) {
                        psShift.setInt(1, posId);
                        psShift.setInt(2, newRank);
                        psShift.setInt(3, oldRank);
                        psShift.executeUpdate();
                    }
                }
            }

            String updateSql = """
                UPDATE Job_Levels 
                SET level_name = ?, rank_order = ?, description = ?
                WHERE level_id = ?
                """;
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, level.getLevelName());
                ps.setInt(2, newRank);
                ps.setString(3, level.getDescription());
                ps.setInt(4, level.getLevelId());
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    public boolean deleteJobLevel(int levelId) {
        JobLevel existing = getJobLevelById(levelId);
        if (existing == null) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            String delSql = "DELETE FROM Job_Levels WHERE level_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(delSql)) {
                ps.setInt(1, levelId);
                int affected = ps.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // Tự động dồn các bậc phía sau giảm 1
            if (existing.getPositionId() != null) {
                String shiftSql = "UPDATE Job_Levels SET rank_order = rank_order - 1 WHERE position_id = ? AND rank_order > ?";
                try (PreparedStatement ps = conn.prepareStatement(shiftSql)) {
                    ps.setInt(1, existing.getPositionId());
                    ps.setInt(2, existing.getRankOrder());
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    public boolean isLevelUsed(int levelId) {
        String sql = """
            SELECT (SELECT COUNT(*) FROM Users WHERE level_id = ?) +
                   (SELECT COUNT(*) FROM Position_Level_Criteria WHERE from_level_id = ? OR to_level_id = ?) +
                   (SELECT COUNT(*) FROM Promotion_Requests WHERE current_level_id = ? OR target_level_id = ?) AS total_ref
            """;
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, levelId);
            ps.setInt(2, levelId);
            ps.setInt(3, levelId);
            ps.setInt(4, levelId);
            ps.setInt(5, levelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_ref") > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countPositions() {
        String sql = """
            SELECT COUNT(*) 
            FROM Positions 
            WHERE is_deleted = 0 AND status = 1
            """;
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
