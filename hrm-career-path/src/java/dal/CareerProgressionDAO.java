package dal;

import model.CriteriaRequirement;
import model.PositionLevelCriteria;
import model.PromotionEvidence;
import model.PromotionRequest;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class CareerProgressionDAO {

    // ==========================================
    // 1. POSITION LEVEL CRITERIA (BAREM TIÊU CHÍ)
    // ==========================================

    public List<PositionLevelCriteria> getCriteriaByPosition(int positionId) {
        List<PositionLevelCriteria> list = new ArrayList<>();
        String sql = """
            SELECT c.*, p.position_name,
                   fl.level_name AS from_level_name,
                   tl.level_name AS to_level_name,
                   tt.title AS target_test_title
            FROM Position_Level_Criteria c
            JOIN Positions p ON c.position_id = p.position_id
            JOIN Job_Levels fl ON c.from_level_id = fl.level_id
            JOIN Job_Levels tl ON c.to_level_id = tl.level_id
            LEFT JOIN Test_Templates tt ON c.target_test_template_id = tt.id
            WHERE c.position_id = ?
            ORDER BY fl.rank_order ASC, tl.rank_order ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PositionLevelCriteria item = mapCriteria(rs);
                    item.setRequirements(getRequirementsByCriteria(item.getCriteriaId()));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public PositionLevelCriteria getCriteriaById(int criteriaId) {
        String sql = """
            SELECT c.*, p.position_name,
                   fl.level_name AS from_level_name,
                   tl.level_name AS to_level_name,
                   tt.title AS target_test_title
            FROM Position_Level_Criteria c
            JOIN Positions p ON c.position_id = p.position_id
            JOIN Job_Levels fl ON c.from_level_id = fl.level_id
            JOIN Job_Levels tl ON c.to_level_id = tl.level_id
            LEFT JOIN Test_Templates tt ON c.target_test_template_id = tt.id
            WHERE c.criteria_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, criteriaId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PositionLevelCriteria item = mapCriteria(rs);
                    item.setRequirements(getRequirementsByCriteria(item.getCriteriaId()));
                    return item;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public PositionLevelCriteria getCriteriaByStep(int positionId, int fromLevelId, int toLevelId) {
        String sql = """
            SELECT c.*, p.position_name,
                   fl.level_name AS from_level_name,
                   tl.level_name AS to_level_name,
                   tt.title AS target_test_title
            FROM Position_Level_Criteria c
            JOIN Positions p ON c.position_id = p.position_id
            JOIN Job_Levels fl ON c.from_level_id = fl.level_id
            JOIN Job_Levels tl ON c.to_level_id = tl.level_id
            LEFT JOIN Test_Templates tt ON c.target_test_template_id = tt.id
            WHERE c.position_id = ? AND c.from_level_id = ? AND c.to_level_id = ? AND c.status = 1
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            ps.setInt(2, fromLevelId);
            ps.setInt(3, toLevelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PositionLevelCriteria item = mapCriteria(rs);
                    item.setRequirements(getRequirementsByCriteria(item.getCriteriaId()));
                    return item;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int addCriteria(PositionLevelCriteria c) {
        String sql = """
            INSERT INTO Position_Level_Criteria 
            (position_id, from_level_id, to_level_id, target_test_template_id, min_test_score, competency_summary, min_manager_rating, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getPositionId());
            ps.setInt(2, c.getFromLevelId());
            ps.setInt(3, c.getToLevelId());
            if (c.getTargetTestTemplateId() != null && c.getTargetTestTemplateId() > 0) {
                ps.setInt(4, c.getTargetTestTemplateId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            if (c.getMinTestScore() != null) {
                ps.setBigDecimal(5, c.getMinTestScore());
            } else {
                ps.setBigDecimal(5, new BigDecimal("80.0"));
            }
            ps.setString(6, c.getCompetencySummary());
            if (c.getMinManagerRating() != null) {
                ps.setBigDecimal(7, c.getMinManagerRating());
            } else {
                ps.setBigDecimal(7, new BigDecimal("7.5"));
            }
            ps.setBoolean(8, c.isStatus());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean updateCriteria(PositionLevelCriteria c) {
        String sql = """
            UPDATE Position_Level_Criteria
            SET target_test_template_id = ?, min_test_score = ?, competency_summary = ?, min_manager_rating = ?, status = ?, updated_at = GETDATE()
            WHERE criteria_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (c.getTargetTestTemplateId() != null && c.getTargetTestTemplateId() > 0) {
                ps.setInt(1, c.getTargetTestTemplateId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setBigDecimal(2, c.getMinTestScore());
            ps.setString(3, c.getCompetencySummary());
            ps.setBigDecimal(4, c.getMinManagerRating());
            ps.setBoolean(5, c.isStatus());
            ps.setInt(6, c.getCriteriaId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCriteria(int criteriaId) {
        String sql = "DELETE FROM Position_Level_Criteria WHERE criteria_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, criteriaId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 2. CRITERIA REQUIREMENTS (TIÊU CHÍ MỞ)
    // ==========================================

    public List<CriteriaRequirement> getRequirementsByCriteria(int criteriaId) {
        List<CriteriaRequirement> list = new ArrayList<>();
        String sql = "SELECT * FROM Criteria_Requirements WHERE criteria_id = ? ORDER BY order_index ASC, requirement_id ASC";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, criteriaId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CriteriaRequirement r = new CriteriaRequirement();
                    r.setRequirementId(rs.getInt("requirement_id"));
                    r.setCriteriaId(rs.getInt("criteria_id"));
                    r.setRequirementTitle(rs.getString("requirement_title"));
                    r.setRequirementType(rs.getString("requirement_type"));
                    r.setDescription(rs.getString("description"));
                    r.setMandatory(rs.getBoolean("is_mandatory"));
                    r.setOrderIndex(rs.getInt("order_index"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int addRequirement(CriteriaRequirement r) {
        String sql = """
            INSERT INTO Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, r.getCriteriaId());
            ps.setString(2, r.getRequirementTitle());
            ps.setString(3, r.getRequirementType());
            ps.setString(4, r.getDescription());
            ps.setBoolean(5, r.isMandatory());
            ps.setInt(6, r.getOrderIndex());
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean deleteRequirement(int requirementId) {
        String sql = "DELETE FROM Criteria_Requirements WHERE requirement_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requirementId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 3. PROMOTION REQUESTS & EVIDENCE
    // ==========================================

    public int createPromotionRequest(PromotionRequest r) {
        String sql = """
            INSERT INTO Promotion_Requests
            (user_id, position_id, current_level_id, target_level_id, criteria_id, test_assignment_id, test_score, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'SUBMITTED')
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, r.getUserId());
            ps.setInt(2, r.getPositionId());
            ps.setInt(3, r.getCurrentLevelId());
            ps.setInt(4, r.getTargetLevelId());
            ps.setInt(5, r.getCriteriaId());
            if (r.getTestAssignmentId() != null && r.getTestAssignmentId() > 0) {
                ps.setInt(6, r.getTestAssignmentId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            if (r.getTestScore() != null) {
                ps.setBigDecimal(7, r.getTestScore());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }

            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean addPromotionEvidence(PromotionEvidence ev) {
        String sql = """
            INSERT INTO Promotion_Evidence (request_id, requirement_id, evidence_summary, evidence_url, attachment_path, is_verified)
            VALUES (?, ?, ?, ?, ?, 0)
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ev.getRequestId());
            ps.setInt(2, ev.getRequirementId());
            ps.setString(3, ev.getEvidenceSummary());
            ps.setString(4, ev.getEvidenceUrl());
            ps.setString(5, ev.getAttachmentPath());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public PromotionRequest getPromotionRequestById(int requestId) {
        String sql = """
            SELECT pr.*, u.full_name AS user_full_name, u.username, u.email AS user_email,
                   p.position_name,
                   cl.level_name AS current_level_name,
                   tl.level_name AS target_level_name,
                   m.full_name AS manager_name,
                   h.full_name AS hr_name
            FROM Promotion_Requests pr
            JOIN Users u ON pr.user_id = u.user_id
            JOIN Positions p ON pr.position_id = p.position_id
            JOIN Job_Levels cl ON pr.current_level_id = cl.level_id
            JOIN Job_Levels tl ON pr.target_level_id = tl.level_id
            LEFT JOIN Users m ON pr.manager_id = m.user_id
            LEFT JOIN Users h ON pr.hr_id = h.user_id
            WHERE pr.request_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PromotionRequest r = mapPromotionRequest(rs);
                    r.setEvidenceList(getEvidenceByRequest(r.getRequestId()));
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<PromotionRequest> getPromotionRequestsByUser(int userId) {
        List<PromotionRequest> list = new ArrayList<>();
        String sql = """
            SELECT pr.*, u.full_name AS user_full_name, u.username, u.email AS user_email,
                   p.position_name,
                   cl.level_name AS current_level_name,
                   tl.level_name AS target_level_name,
                   m.full_name AS manager_name,
                   h.full_name AS hr_name
            FROM Promotion_Requests pr
            JOIN Users u ON pr.user_id = u.user_id
            JOIN Positions p ON pr.position_id = p.position_id
            JOIN Job_Levels cl ON pr.current_level_id = cl.level_id
            JOIN Job_Levels tl ON pr.target_level_id = tl.level_id
            LEFT JOIN Users m ON pr.manager_id = m.user_id
            LEFT JOIN Users h ON pr.hr_id = h.user_id
            WHERE pr.user_id = ?
            ORDER BY pr.created_at DESC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PromotionRequest r = mapPromotionRequest(rs);
                    r.setEvidenceList(getEvidenceByRequest(r.getRequestId()));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PromotionRequest> getPromotionRequestsByDepartment(int departmentId) {
        List<PromotionRequest> list = new ArrayList<>();
        String sql = """
            SELECT pr.*, u.full_name AS user_full_name, u.username, u.email AS user_email,
                   p.position_name,
                   cl.level_name AS current_level_name,
                   tl.level_name AS target_level_name,
                   m.full_name AS manager_name,
                   h.full_name AS hr_name
            FROM Promotion_Requests pr
            JOIN Users u ON pr.user_id = u.user_id
            JOIN Positions p ON pr.position_id = p.position_id
            JOIN Job_Levels cl ON pr.current_level_id = cl.level_id
            JOIN Job_Levels tl ON pr.target_level_id = tl.level_id
            LEFT JOIN Users m ON pr.manager_id = m.user_id
            LEFT JOIN Users h ON pr.hr_id = h.user_id
            WHERE u.department_id = ?
            ORDER BY pr.created_at DESC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PromotionRequest r = mapPromotionRequest(rs);
                    r.setEvidenceList(getEvidenceByRequest(r.getRequestId()));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PromotionRequest> getAllPromotionRequests() {
        List<PromotionRequest> list = new ArrayList<>();
        String sql = """
            SELECT pr.*, u.full_name AS user_full_name, u.username, u.email AS user_email,
                   p.position_name,
                   cl.level_name AS current_level_name,
                   tl.level_name AS target_level_name,
                   m.full_name AS manager_name,
                   h.full_name AS hr_name
            FROM Promotion_Requests pr
            JOIN Users u ON pr.user_id = u.user_id
            JOIN Positions p ON pr.position_id = p.position_id
            JOIN Job_Levels cl ON pr.current_level_id = cl.level_id
            JOIN Job_Levels tl ON pr.target_level_id = tl.level_id
            LEFT JOIN Users m ON pr.manager_id = m.user_id
            LEFT JOIN Users h ON pr.hr_id = h.user_id
            ORDER BY pr.created_at DESC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PromotionRequest r = mapPromotionRequest(rs);
                r.setEvidenceList(getEvidenceByRequest(r.getRequestId()));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PromotionEvidence> getEvidenceByRequest(int requestId) {
        List<PromotionEvidence> list = new ArrayList<>();
        String sql = """
            SELECT pe.*, cr.requirement_title, cr.requirement_type
            FROM Promotion_Evidence pe
            JOIN Criteria_Requirements cr ON pe.requirement_id = cr.requirement_id
            WHERE pe.request_id = ?
            ORDER BY pe.evidence_id ASC
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PromotionEvidence ev = new PromotionEvidence();
                    ev.setEvidenceId(rs.getInt("evidence_id"));
                    ev.setRequestId(rs.getInt("request_id"));
                    ev.setRequirementId(rs.getInt("requirement_id"));
                    ev.setRequirementTitle(rs.getString("requirement_title"));
                    ev.setRequirementType(rs.getString("requirement_type"));
                    ev.setEvidenceSummary(rs.getString("evidence_summary"));
                    ev.setEvidenceUrl(rs.getString("evidence_url"));
                    ev.setAttachmentPath(rs.getString("attachment_path"));
                    ev.setVerified(rs.getBoolean("is_verified"));
                    ev.setVerificationComment(rs.getString("verification_comment"));
                    ev.setVerifiedAt(rs.getTimestamp("verified_at"));
                    list.add(ev);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean managerReview(int requestId, int managerId, BigDecimal rating, String notes, String status) {
        String sql = """
            UPDATE Promotion_Requests
            SET manager_id = ?, manager_rating = ?, manager_confidential_notes = ?,
                manager_status = ?, manager_action_date = GETDATE(),
                status = ?
            WHERE request_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            ps.setBigDecimal(2, rating);
            ps.setString(3, notes);
            ps.setString(4, status);
            ps.setString(5, "RECOMMENDED".equals(status) ? "MANAGER_REVIEWED" : "REJECTED");
            ps.setInt(6, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean verifyEvidence(int evidenceId, boolean isVerified, String comment) {
        String sql = """
            UPDATE Promotion_Evidence
            SET is_verified = ?, verification_comment = ?, verified_at = GETDATE()
            WHERE evidence_id = ?
            """;
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isVerified);
            ps.setString(2, comment);
            ps.setInt(3, evidenceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hrApproveAndPromote(int requestId, int hrId, String decision, String notes,
                                      int userId, int newLevelId, int oldLevelId, int positionId) {
        Connection conn = null;
        try {
            conn = DBContext.getInstance().getConnection();
            conn.setAutoCommit(false);

            // 1. Update Promotion Request status
            String updateRequestSql = """
                UPDATE Promotion_Requests
                SET hr_id = ?, hr_decision = ?, hr_notes = ?, hr_action_date = GETDATE(),
                    status = ?
                WHERE request_id = ?
                """;
            try (PreparedStatement ps1 = conn.prepareStatement(updateRequestSql)) {
                ps1.setInt(1, hrId);
                ps1.setString(2, decision);
                ps1.setString(3, notes);
                ps1.setString(4, "APPROVED".equals(decision) ? "APPROVED" : "REJECTED");
                ps1.setInt(5, requestId);
                ps1.executeUpdate();
            }

            // If APPROVED, update User level & write Employee_History
            if ("APPROVED".equals(decision)) {
                String updateUserSql = "UPDATE Users SET level_id = ? WHERE user_id = ?";
                try (PreparedStatement ps2 = conn.prepareStatement(updateUserSql)) {
                    ps2.setInt(1, newLevelId);
                    ps2.setInt(2, userId);
                    ps2.executeUpdate();
                }

                String insertHistorySql = """
                    INSERT INTO Employee_History (user_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, notes, created_by)
                    VALUES (?, ?, ?, ?, ?, 'PROMOTION', ?, ?)
                    """;
                try (PreparedStatement ps3 = conn.prepareStatement(insertHistorySql)) {
                    ps3.setInt(1, userId);
                    ps3.setInt(2, positionId);
                    ps3.setInt(3, positionId);
                    ps3.setInt(4, oldLevelId);
                    ps3.setInt(5, newLevelId);
                    ps3.setString(6, notes != null ? notes : "Thăng cấp theo phê duyệt mã hồ sơ #" + requestId);
                    ps3.setInt(7, hrId);
                    ps3.executeUpdate();
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
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    // ==========================================
    // HELPER MAPPERS
    // ==========================================

    private PositionLevelCriteria mapCriteria(ResultSet rs) throws SQLException {
        PositionLevelCriteria c = new PositionLevelCriteria();
        c.setCriteriaId(rs.getInt("criteria_id"));
        c.setPositionId(rs.getInt("position_id"));
        c.setPositionName(rs.getString("position_name"));
        c.setFromLevelId(rs.getInt("from_level_id"));
        c.setFromLevelName(rs.getString("from_level_name"));
        c.setToLevelId(rs.getInt("to_level_id"));
        c.setToLevelName(rs.getString("to_level_name"));
        c.setTargetTestTemplateId((Integer) rs.getObject("target_test_template_id"));
        c.setTargetTestTitle(rs.getString("target_test_title"));
        c.setMinTestScore(rs.getBigDecimal("min_test_score"));
        c.setCompetencySummary(rs.getString("competency_summary"));
        c.setMinManagerRating(rs.getBigDecimal("min_manager_rating"));
        c.setStatus(rs.getBoolean("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        return c;
    }

    private PromotionRequest mapPromotionRequest(ResultSet rs) throws SQLException {
        PromotionRequest r = new PromotionRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setUserFullName(rs.getString("user_full_name"));
        r.setUsername(rs.getString("username"));
        r.setUserEmail(rs.getString("user_email"));
        r.setPositionId(rs.getInt("position_id"));
        r.setPositionName(rs.getString("position_name"));
        r.setCurrentLevelId(rs.getInt("current_level_id"));
        r.setCurrentLevelName(rs.getString("current_level_name"));
        r.setTargetLevelId(rs.getInt("target_level_id"));
        r.setTargetLevelName(rs.getString("target_level_name"));
        r.setCriteriaId(rs.getInt("criteria_id"));
        r.setTestAssignmentId((Integer) rs.getObject("test_assignment_id"));
        r.setTestScore(rs.getBigDecimal("test_score"));
        r.setManagerId((Integer) rs.getObject("manager_id"));
        r.setManagerName(rs.getString("manager_name"));
        r.setManagerRating(rs.getBigDecimal("manager_rating"));
        r.setManagerConfidentialNotes(rs.getString("manager_confidential_notes"));
        r.setManagerStatus(rs.getString("manager_status"));
        r.setManagerActionDate(rs.getTimestamp("manager_action_date"));
        r.setHrId((Integer) rs.getObject("hr_id"));
        r.setHrName(rs.getString("hr_name"));
        r.setHrDecision(rs.getString("hr_decision"));
        r.setHrNotes(rs.getString("hr_notes"));
        r.setHrActionDate(rs.getTimestamp("hr_action_date"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }
}

