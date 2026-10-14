package dal;

import model.PositionRequest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PositionRequestDAO {

    public List<PositionRequest> getAllRequests(String statusFilter) {
        return getAllRequests(statusFilter, null, null);
    }

    public List<PositionRequest> getAllRequests(String statusFilter, Integer deptId, String searchKeyword) {
        List<PositionRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT pr.*, 
                   u.full_name AS manager_name, 
                   d.department_name,
                   adm.full_name AS reviewer_name
            FROM Position_Requests pr
            INNER JOIN Users u ON pr.manager_id = u.user_id
            INNER JOIN Departments d ON pr.department_id = d.department_id
            LEFT JOIN Users adm ON pr.reviewed_by = adm.user_id
            WHERE 1=1
            """);

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND pr.status = ?");
            params.add(statusFilter.trim());
        }

        if (deptId != null && deptId > 0) {
            sql.append(" AND pr.department_id = ?");
            params.add(deptId);
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append(" AND (pr.position_name LIKE ? OR u.full_name LIKE ? OR pr.reason LIKE ?)");
            String pattern = "%" + searchKeyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }

        sql.append(" ORDER BY pr.request_id DESC");

        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PositionRequest> getRequestsByManager(int managerId) {
        List<PositionRequest> list = new ArrayList<>();
        String sql = """
            SELECT pr.*, 
                   u.full_name AS manager_name, 
                   d.department_name,
                   adm.full_name AS reviewer_name
            FROM Position_Requests pr
            INNER JOIN Users u ON pr.manager_id = u.user_id
            INNER JOIN Departments d ON pr.department_id = d.department_id
            LEFT JOIN Users adm ON pr.reviewed_by = adm.user_id
            WHERE pr.manager_id = ?
            ORDER BY pr.request_id DESC
            """;

        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public PositionRequest getRequestById(int requestId) {
        String sql = """
            SELECT pr.*, 
                   u.full_name AS manager_name, 
                   d.department_name,
                   adm.full_name AS reviewer_name
            FROM Position_Requests pr
            INNER JOIN Users u ON pr.manager_id = u.user_id
            INNER JOIN Departments d ON pr.department_id = d.department_id
            LEFT JOIN Users adm ON pr.reviewed_by = adm.user_id
            WHERE pr.request_id = ?
            """;

        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createRequest(PositionRequest req) {
        String sql = """
            INSERT INTO Position_Requests (manager_id, department_id, position_name, description, reason, status, created_at)
            VALUES (?, ?, ?, ?, ?, 'PENDING', GETDATE())
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, req.getManagerId());
            ps.setInt(2, req.getDepartmentId());
            ps.setString(3, req.getPositionName());
            ps.setString(4, req.getDescription());
            ps.setString(5, req.getReason());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Admin duyệt hoặc từ chối đề xuất vị trí.
     * Nếu duyệt ('APPROVED'): Hệ thống tự động tạo mới vị trí vào bảng Positions.
     */
    public boolean reviewRequest(int requestId, int adminId, String status, String decisionNote) {
        String updateSql = """
            UPDATE Position_Requests
            SET status = ?, decision_note = ?, reviewed_by = ?, reviewed_at = GETDATE()
            WHERE request_id = ? AND status = 'PENDING'
            """;

        String insertPosSql = """
            INSERT INTO Positions (position_name, department_id, description, status, is_deleted, created_at)
            VALUES (?, ?, ?, 1, 0, GETDATE())
            """;

        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật trạng thái Request
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setString(1, status);
                psUpdate.setString(2, decisionNote);
                psUpdate.setInt(3, adminId);
                psUpdate.setInt(4, requestId);
                int rows = psUpdate.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Nếu APPROVED -> Tự động tạo Position mới
            if ("APPROVED".equalsIgnoreCase(status)) {
                PositionRequest req = getRequestById(requestId);
                if (req != null) {
                    try (PreparedStatement psInsert = conn.prepareStatement(insertPosSql)) {
                        psInsert.setString(1, req.getPositionName());
                        psInsert.setInt(2, req.getDepartmentId());
                        psInsert.setString(3, req.getDescription());
                        psInsert.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    private PositionRequest mapResultSet(ResultSet rs) throws SQLException {
        PositionRequest r = new PositionRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setManagerId(rs.getInt("manager_id"));
        r.setManagerName(rs.getString("manager_name"));
        r.setDepartmentId(rs.getInt("department_id"));
        r.setDepartmentName(rs.getString("department_name"));
        r.setPositionName(rs.getString("position_name"));
        r.setDescription(rs.getString("description"));
        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));
        r.setDecisionNote(rs.getString("decision_note"));
        int reviewerId = rs.getInt("reviewed_by");
        if (!rs.wasNull()) {
            r.setReviewedBy(reviewerId);
        }
        r.setReviewerName(rs.getString("reviewer_name"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setReviewedAt(rs.getTimestamp("reviewed_at"));
        return r;
    }
}
