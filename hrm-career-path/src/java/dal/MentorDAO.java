package dal;

import model.MentorEvaluation;
import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class MentorDAO {

    // Lấy danh sách Nhân viên mới (Role = 4) chưa được ghép Mentor
    public List<User> getUnassignedNewEmployees() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, p.position_name, d.department_name " +
                     "FROM Users u " +
                     "LEFT JOIN Positions p ON u.position_id = p.position_id " +
                     "LEFT JOIN Departments d ON u.department_id = d.department_id " +
                     "WHERE u.role_id = 4 AND u.is_deleted = 0 " +
                     "AND u.user_id NOT IN (SELECT mentee_id FROM MentorAssignments WHERE status = 'ACTIVE')";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setPositionName(rs.getString("position_name"));
                u.setDepartmentName(rs.getString("department_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy danh sách Mentor (Role = 5) kèm Chuyên môn/Cấp bậc
    public List<User> getAllMentorsWithSpecialty() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, p.position_name, d.department_name " +
                     "FROM Users u " +
                     "LEFT JOIN Positions p ON u.position_id = p.position_id " +
                     "LEFT JOIN Departments d ON u.department_id = d.department_id " +
                     "WHERE u.role_id = 5 AND u.is_deleted = 0";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setPositionName(rs.getString("position_name"));
                u.setDepartmentName(rs.getString("department_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Thực hiện ghép cặp
    public boolean assignMentor(int menteeId, int mentorId, int hrId) {
        String sql = "INSERT INTO MentorAssignments (mentee_id, mentor_id, status, assigned_by) VALUES (?, ?, 'ACTIVE', ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, menteeId);
            ps.setInt(2, mentorId);
            ps.setInt(3, hrId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy danh sách đánh giá
    public List<MentorEvaluation> getAllEvaluations() {
        List<MentorEvaluation> list = new ArrayList<>();
        String sql = "SELECT e.*, " +
                     "(SELECT full_name FROM Users WHERE user_id = a.mentee_id) AS MenteeName, " +
                     "(SELECT full_name FROM Users WHERE user_id = e.evaluator_id) AS MentorName " +
                     "FROM MentorEvaluations e " +
                     "INNER JOIN MentorAssignments a ON e.assignment_id = a.assignment_id";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MentorEvaluation eval = new MentorEvaluation();
                eval.setEvaluationId(rs.getInt("evaluation_id"));
                eval.setPerformanceScore(rs.getInt("performance_score"));
                eval.setFeedback(rs.getString("feedback"));
                eval.setApprovalStatus(rs.getString("approval_status"));
                eval.setMenteeName(rs.getString("MenteeName"));
                eval.setMentorName(rs.getString("MentorName"));
                list.add(eval);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}