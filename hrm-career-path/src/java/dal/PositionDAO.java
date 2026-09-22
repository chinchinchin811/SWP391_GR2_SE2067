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
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
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
        List<Position> list = new ArrayList<>();
        String sql = """
            SELECT p.position_id, p.position_name, p.department_id, p.description, p.status, p.is_deleted, p.created_at,
                   d.department_name,
                   (SELECT COUNT(*) FROM Users WHERE position_id = p.position_id AND is_deleted = 0 AND status = 1) AS employee_count
            FROM Positions p
            LEFT JOIN Departments d ON p.department_id = d.department_id
            WHERE p.is_deleted = 0 AND (? IS NULL OR p.department_id = ?)
            ORDER BY p.position_name ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (deptId == null || deptId == 0) {
                ps.setNull(1, Types.INTEGER);
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(1, deptId);
                ps.setInt(2, deptId);
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
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public boolean addPosition(Position pos) {
        String sql = """
            INSERT INTO Positions (position_name, department_id, description, status, is_deleted) 
            VALUES (?, ?, ?, ?, 0)
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
            SELECT level_id, level_name, rank_order, description 
            FROM Job_Levels 
            ORDER BY rank_order ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                JobLevel level = new JobLevel(
                    rs.getInt("level_id"),
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

    public int countPositions() {
        String sql = """
            SELECT COUNT(*) 
            FROM Positions 
            WHERE is_deleted = 0 AND status = 1
            """;
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
}
