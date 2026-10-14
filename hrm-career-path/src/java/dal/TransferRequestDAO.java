package dal;

import model.TransferRequest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransferRequestDAO {

    public boolean createRequest(TransferRequest req) {
        String sql = """
            INSERT INTO dbo.Transfer_Requests 
            (employee_id, current_department_id, current_position_id, target_department_id, target_position_id, reason, manager_status, hr_status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, 'PENDING', 'WAITING_MANAGER', GETDATE())
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, req.getEmployeeId());
            ps.setInt(2, req.getCurrentDepartmentId());
            if (req.getCurrentPositionId() != null && req.getCurrentPositionId() > 0) {
                ps.setInt(3, req.getCurrentPositionId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, req.getTargetDepartmentId());
            if (req.getTargetPositionId() != null && req.getTargetPositionId() > 0) {
                ps.setInt(5, req.getTargetPositionId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, req.getReason());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<TransferRequest> getRequestsByEmployee(int employeeId) {
        String sql = """
            SELECT tr.*, 
                   u.full_name AS employee_name, u.email AS employee_email,
                   cd.department_name AS current_dept_name,
                   cp.position_name AS current_pos_name,
                   td.department_name AS target_dept_name,
                   tp.position_name AS target_pos_name,
                   mu.full_name AS manager_name,
                   hu.full_name AS hr_name
            FROM dbo.Transfer_Requests tr
            JOIN dbo.Users u ON tr.employee_id = u.user_id
            JOIN dbo.Departments cd ON tr.current_department_id = cd.department_id
            LEFT JOIN dbo.Positions cp ON tr.current_position_id = cp.position_id
            JOIN dbo.Departments td ON tr.target_department_id = td.department_id
            LEFT JOIN dbo.Positions tp ON tr.target_position_id = tp.position_id
            LEFT JOIN dbo.Users mu ON tr.manager_reviewed_by = mu.user_id
            LEFT JOIN dbo.Users hu ON tr.hr_reviewed_by = hu.user_id
            WHERE tr.employee_id = ?
            ORDER BY tr.request_id DESC
            """;
        List<TransferRequest> list = new ArrayList<>();
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<TransferRequest> getRequestsForManager(int departmentId) {
        String sql = """
            SELECT tr.*, 
                   u.full_name AS employee_name, u.email AS employee_email,
                   cd.department_name AS current_dept_name,
                   cp.position_name AS current_pos_name,
                   td.department_name AS target_dept_name,
                   tp.position_name AS target_pos_name,
                   mu.full_name AS manager_name,
                   hu.full_name AS hr_name
            FROM dbo.Transfer_Requests tr
            JOIN dbo.Users u ON tr.employee_id = u.user_id
            JOIN dbo.Departments cd ON tr.current_department_id = cd.department_id
            LEFT JOIN dbo.Positions cp ON tr.current_position_id = cp.position_id
            JOIN dbo.Departments td ON tr.target_department_id = td.department_id
            LEFT JOIN dbo.Positions tp ON tr.target_position_id = tp.position_id
            LEFT JOIN dbo.Users mu ON tr.manager_reviewed_by = mu.user_id
            LEFT JOIN dbo.Users hu ON tr.hr_reviewed_by = hu.user_id
            WHERE tr.current_department_id = ?
            ORDER BY tr.request_id DESC
            """;
        List<TransferRequest> list = new ArrayList<>();
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<TransferRequest> getAllRequestsForHR(String statusFilter) {
        StringBuilder sql = new StringBuilder("""
            SELECT tr.*, 
                   u.full_name AS employee_name, u.email AS employee_email,
                   cd.department_name AS current_dept_name,
                   cp.position_name AS current_pos_name,
                   td.department_name AS target_dept_name,
                   tp.position_name AS target_pos_name,
                   mu.full_name AS manager_name,
                   hu.full_name AS hr_name
            FROM dbo.Transfer_Requests tr
            JOIN dbo.Users u ON tr.employee_id = u.user_id
            JOIN dbo.Departments cd ON tr.current_department_id = cd.department_id
            LEFT JOIN dbo.Positions cp ON tr.current_position_id = cp.position_id
            JOIN dbo.Departments td ON tr.target_department_id = td.department_id
            LEFT JOIN dbo.Positions tp ON tr.target_position_id = tp.position_id
            LEFT JOIN dbo.Users mu ON tr.manager_reviewed_by = mu.user_id
            LEFT JOIN dbo.Users hu ON tr.hr_reviewed_by = hu.user_id
            WHERE 1=1
            """);

        if ("PENDING_HR".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND tr.manager_status = 'APPROVED' AND tr.hr_status = 'PENDING'");
        } else if ("COMPLETED".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND tr.hr_status = 'COMPLETED'");
        }

        sql.append(" ORDER BY tr.request_id DESC");

        List<TransferRequest> list = new ArrayList<>();
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public TransferRequest getRequestById(int requestId) {
        String sql = """
            SELECT tr.*, 
                   u.full_name AS employee_name, u.email AS employee_email,
                   cd.department_name AS current_dept_name,
                   cp.position_name AS current_pos_name,
                   td.department_name AS target_dept_name,
                   tp.position_name AS target_pos_name,
                   mu.full_name AS manager_name,
                   hu.full_name AS hr_name
            FROM dbo.Transfer_Requests tr
            JOIN dbo.Users u ON tr.employee_id = u.user_id
            JOIN dbo.Departments cd ON tr.current_department_id = cd.department_id
            LEFT JOIN dbo.Positions cp ON tr.current_position_id = cp.position_id
            JOIN dbo.Departments td ON tr.target_department_id = td.department_id
            LEFT JOIN dbo.Positions tp ON tr.target_position_id = tp.position_id
            LEFT JOIN dbo.Users mu ON tr.manager_reviewed_by = mu.user_id
            LEFT JOIN dbo.Users hu ON tr.hr_reviewed_by = hu.user_id
            WHERE tr.request_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean managerReview(int requestId, int managerId, String status, String note) {
        String hrStatus = "APPROVED".equalsIgnoreCase(status) ? "PENDING" : "WAITING_MANAGER";
        String sql = """
            UPDATE dbo.Transfer_Requests 
            SET manager_status = ?, manager_note = ?, manager_reviewed_by = ?, manager_reviewed_at = GETDATE(), hr_status = ?
            WHERE request_id = ? AND manager_status = 'PENDING'
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, note);
            ps.setInt(3, managerId);
            ps.setString(4, hrStatus);
            ps.setInt(5, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hrExecuteTransfer(int requestId, int hrId, String status, String note, Integer levelId) {
        TransferRequest req = getRequestById(requestId);
        if (req == null) return false;

        String sql = """
            UPDATE dbo.Transfer_Requests 
            SET hr_status = ?, hr_note = ?, hr_reviewed_by = ?, hr_reviewed_at = GETDATE()
            WHERE request_id = ? AND hr_status = 'PENDING'
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, note);
            ps.setInt(3, hrId);
            ps.setInt(4, requestId);
            boolean ok = ps.executeUpdate() > 0;

            if (ok && "COMPLETED".equalsIgnoreCase(status)) {
                // Tự động kích hoạt cập nhật phòng ban và vị trí mới cho nhân sự
                UserDAO userDAO = new UserDAO();
                userDAO.updateEmployeeAssignment(req.getEmployeeId(), req.getTargetDepartmentId(), req.getTargetPositionId(), levelId, "TRANSFER", "Điều chuyển theo đề xuất nguyện vọng #" + requestId, hrId);
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private TransferRequest mapFromResultSet(ResultSet rs) throws SQLException {
        TransferRequest tr = new TransferRequest();
        tr.setRequestId(rs.getInt("request_id"));
        tr.setEmployeeId(rs.getInt("employee_id"));
        tr.setEmployeeName(rs.getString("employee_name"));
        tr.setEmployeeEmail(rs.getString("employee_email"));
        
        tr.setCurrentDepartmentId(rs.getInt("current_department_id"));
        tr.setCurrentDepartmentName(rs.getString("current_dept_name"));
        int curPos = rs.getInt("current_position_id");
        tr.setCurrentPositionId(rs.wasNull() ? null : curPos);
        tr.setCurrentPositionName(rs.getString("current_pos_name"));
        
        tr.setTargetDepartmentId(rs.getInt("target_department_id"));
        tr.setTargetDepartmentName(rs.getString("target_dept_name"));
        int tarPos = rs.getInt("target_position_id");
        tr.setTargetPositionId(rs.wasNull() ? null : tarPos);
        tr.setTargetPositionName(rs.getString("target_pos_name"));
        
        tr.setReason(rs.getString("reason"));
        tr.setManagerStatus(rs.getString("manager_status"));
        tr.setManagerNote(rs.getString("manager_note"));
        int mgrId = rs.getInt("manager_reviewed_by");
        tr.setManagerReviewedBy(rs.wasNull() ? null : mgrId);
        tr.setManagerReviewerName(rs.getString("manager_name"));
        tr.setManagerReviewedAt(rs.getTimestamp("manager_reviewed_at"));
        
        tr.setHrStatus(rs.getString("hr_status"));
        tr.setHrNote(rs.getString("hr_note"));
        int hrId = rs.getInt("hr_reviewed_by");
        tr.setHrReviewedBy(rs.wasNull() ? null : hrId);
        tr.setHrReviewerName(rs.getString("hr_name"));
        tr.setHrReviewedAt(rs.getTimestamp("hr_reviewed_at"));
        
        tr.setCreatedAt(rs.getTimestamp("created_at"));
        return tr;
    }
}
