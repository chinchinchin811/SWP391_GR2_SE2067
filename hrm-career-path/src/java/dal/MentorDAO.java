/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import model.Mentor.MentorEvaluation;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Mentor.MentorAssignment;

/**
 *
 * @author HP
 */
public class MentorDAO {

    public List<User> getUnassignedNewEmployees() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.position_id, p.position_name, d.department_name, jl.level_name "
                + "FROM Users u "
                + "LEFT JOIN Positions p ON u.position_id = p.position_id "
                + "LEFT JOIN Departments d ON u.department_id = d.department_id "
                + "LEFT JOIN Job_Levels jl ON u.level_id = jl.level_id "
                + "WHERE u.role_id = 4 AND (u.is_deleted = 0 OR u.is_deleted IS NULL) "
                + "AND (LOWER(jl.level_name) LIKE '%intern%' OR LOWER(jl.level_name) LIKE '%fresher%') "
                + "AND u.user_id NOT IN (SELECT mentee_id FROM MentorAssignments WHERE status = 'ACTIVE')";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setPositionId(rs.getInt("position_id"));
                u.setPositionName(rs.getString("position_name"));
                u.setDepartmentName(rs.getString("department_name"));
                u.setLevelName(rs.getString("level_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getAllMentorsWithSpecialty() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.position_id, p.position_name, d.department_name, jl.level_name "
                + "FROM Users u "
                + "LEFT JOIN Positions p ON u.position_id = p.position_id "
                + "LEFT JOIN Departments d ON u.department_id = d.department_id "
                + "LEFT JOIN Job_Levels jl ON u.level_id = jl.level_id "
                + "INNER JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE r.role_name = 'MENTOR' AND (u.is_deleted = 0 OR u.is_deleted IS NULL)";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setPositionId(rs.getInt("position_id"));
                u.setPositionName(rs.getString("position_name"));
                u.setDepartmentName(rs.getString("department_name"));
                u.setLevelName(rs.getString("level_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean assignMentorWithPosition(int menteeId, int mentorId, int positionId, int hrId) {
        String sql = "INSERT INTO MentorAssignments (mentee_id, mentor_id, position_id, status, assigned_by) VALUES (?, ?, ?, 'ACTIVE', ?)";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, menteeId);
            ps.setInt(2, mentorId);
            if (positionId > 0) {
                ps.setInt(3, positionId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, hrId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<MentorEvaluation> getAllEvaluations() {
        List<MentorEvaluation> list = new ArrayList<>();
        String sql = "SELECT e.*, "
                + "(SELECT full_name FROM Users WHERE user_id = a.mentee_id) AS MenteeName, "
                + "(SELECT full_name FROM Users WHERE user_id = e.evaluator_id) AS MentorName "
                + "FROM MentorEvaluations e "
                + "INNER JOIN MentorAssignments a ON e.assignment_id = a.assignment_id";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MentorEvaluation eval = new MentorEvaluation();
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
    
    public List<MentorAssignment> getActiveAssignments() {
        List<MentorAssignment> list = new ArrayList<>();
        String sql = "SELECT a.assignment_id, a.status, "
                + "m.user_id as mentee_id, m.full_name as mentee_name, jl.level_name, "
                + "mt.user_id as mentor_id, mt.full_name as mentor_name, "
                + "p.position_name, d.department_name "
                + "FROM MentorAssignments a "
                + "INNER JOIN Users m ON a.mentee_id = m.user_id "
                + "INNER JOIN Users mt ON a.mentor_id = mt.user_id "
                + "LEFT JOIN Positions p ON a.position_id = p.position_id "
                + "LEFT JOIN Departments d ON m.department_id = d.department_id "
                + "WHERE a.status = 'ACTIVE'";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MentorAssignment ma = new MentorAssignment();
                ma.setAssignmentId(rs.getInt("assignment_id"));
                ma.setMenteeId(rs.getInt("mentee_id"));
                ma.setMenteeName(rs.getString("mentee_name"));
                ma.setMenteeLevel(rs.getString("level_name"));
                ma.setMentorId(rs.getInt("mentor_id"));
                ma.setMentorName(rs.getString("mentor_name"));
                ma.setPositionName(rs.getString("position_name"));
                ma.setDepartmentName(rs.getString("department_name"));
                ma.setStatus(rs.getString("status"));
                list.add(ma);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public List<model.Mentor.MentorAssignment> getAssignmentsByMentor(int mentorId) {
        List<model.Mentor.MentorAssignment> list = new ArrayList<>();
        String sql = "SELECT ma.assignment_id, ma.mentee_id, u.full_name AS mentee_name, jl.level_name AS mentee_level, p.position_name "
                   + "FROM MentorAssignments ma "
                   + "JOIN Users u ON ma.mentee_id = u.user_id "
                   + "LEFT JOIN Job_Levels jl ON u.level_id = jl.level_id "
                   + "LEFT JOIN Positions p ON ma.position_id = p.position_id "
                   + "WHERE ma.status = 'ACTIVE' AND ma.mentor_id = ?";
        try (Connection conn = new DBContext().getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mentorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                model.Mentor.MentorAssignment a = new model.Mentor.MentorAssignment();
                a.setAssignmentId(rs.getInt("assignment_id"));
                a.setMenteeId(rs.getInt("mentee_id"));
                a.setMenteeName(rs.getString("mentee_name"));
                a.setMenteeLevel(rs.getString("mentee_level"));
                a.setPositionName(rs.getString("position_name"));
                list.add(a);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
