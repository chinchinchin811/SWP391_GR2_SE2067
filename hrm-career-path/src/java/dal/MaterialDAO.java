package dal;

import java.sql.*;
import java.util.*;
import model.*;

/**
 * Data access for the learning and training module. All writes use prepared
 * statements.
 */
public class MaterialDAO {

    public List<LearningMaterial> getMaterials(Integer userId) {
        return getMaterials(userId, null);
    }

    public List<LearningMaterial> getMaterials(Integer userId, Integer roleId) {
        List<LearningMaterial> out = new ArrayList<LearningMaterial>();
        String sql = "SELECT m.*,d.department_name,p.position_name,l.level_name,u.full_name creator_name,"
                + "(SELECT COUNT(*) FROM Video_Checkpoints v WHERE v.material_id=m.material_id) checkpoint_count,"
                + "COALESCE((SELECT TOP 1 lp.status FROM Learning_Progress lp WHERE lp.material_id=m.material_id AND lp.user_id=?),'NOT_STARTED') user_progress_status,"
                + "(SELECT COUNT(*) FROM Class_Materials cm JOIN Training_Classes tc ON tc.class_id=cm.class_id WHERE cm.material_id=m.material_id AND tc.is_deleted=0 AND (tc.mentor_id=? OR EXISTS (SELECT 1 FROM Class_Enrollments ce WHERE ce.class_id=tc.class_id AND ce.user_id=?))) enrolled_class_count "
                + "FROM Learning_Materials m LEFT JOIN Departments d ON d.department_id=m.department_id LEFT JOIN Positions p ON p.position_id=m.position_id LEFT JOIN Job_Levels l ON l.level_id=m.level_id LEFT JOIN Users u ON u.user_id=m.created_by WHERE m.is_deleted=0 AND m.status=1 ORDER BY m.created_at DESC";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setObject(2, userId);
            ps.setObject(3, userId);
            try (ResultSet r = ps.executeQuery()) {
                while (r.next()) {
                    LearningMaterial m = mapMaterial(r);
                    if (roleId != null && (roleId == 2 || roleId == 3)) {
                        m.setUserHasAccess(true);
                    } else if (userId != null) {
                        m.setUserHasAccess(m.getEnrolledClassCount() > 0);
                    }
                    out.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public LearningMaterial getMaterial(int id) {
        String sql = "SELECT m.*,d.department_name,p.position_name,l.level_name,u.full_name creator_name,(SELECT COUNT(*) FROM Video_Checkpoints v WHERE v.material_id=m.material_id) checkpoint_count FROM Learning_Materials m LEFT JOIN Departments d ON d.department_id=m.department_id LEFT JOIN Positions p ON p.position_id=m.position_id LEFT JOIN Job_Levels l ON l.level_id=m.level_id LEFT JOIN Users u ON u.user_id=m.created_by WHERE m.material_id=? AND m.is_deleted=0";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? mapMaterial(r) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public byte[] getMaterialFile(int id) {
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement("SELECT file_data FROM Learning_Materials WHERE material_id=? AND is_deleted=0")) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? r.getBytes(1) : null;
            }
        } catch (SQLException e) {
            return null;
        }
    }

    public boolean saveMaterial(LearningMaterial m) {
        if (m.getDepartmentId() == null || m.getDepartmentId() <= 0) {
            m.setScopeType("CULTURE");
            m.setDepartmentId(null);
        } else {
            m.setScopeType("DEPARTMENT");
        }
        String url = m.getMaterialUrl();
        String sqlWithBoth = "INSERT INTO Learning_Materials(title,description,material_type,scope_type,department_id,position_id,level_id,material_url,video_url,duration_minutes,status,created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
        String sqlFallback = "INSERT INTO Learning_Materials(title,description,material_type,scope_type,department_id,position_id,level_id,video_url,duration_minutes,status,created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBContext.getInstance().getConnection()) {
            try (PreparedStatement p = c.prepareStatement(sqlWithBoth)) {
                p.setString(1, m.getTitle());
                p.setString(2, m.getDescription());
                p.setString(3, m.getMaterialType());
                p.setString(4, m.getScopeType());
                setInt(p, 5, m.getDepartmentId());
                setInt(p, 6, m.getPositionId());
                setInt(p, 7, m.getLevelId());
                p.setString(8, url);
                p.setString(9, url);
                p.setInt(10, m.getDurationMinutes());
                p.setBoolean(11, m.isStatus());
                p.setInt(12, m.getCreatedBy());
                return p.executeUpdate() > 0;
            } catch (SQLException ex) {
                try (PreparedStatement p = c.prepareStatement(sqlFallback)) {
                    p.setString(1, m.getTitle());
                    p.setString(2, m.getDescription());
                    p.setString(3, m.getMaterialType());
                    p.setString(4, m.getScopeType());
                    setInt(p, 5, m.getDepartmentId());
                    setInt(p, 6, m.getPositionId());
                    setInt(p, 7, m.getLevelId());
                    p.setString(8, url);
                    p.setInt(9, m.getDurationMinutes());
                    p.setBoolean(10, m.isStatus());
                    p.setInt(11, m.getCreatedBy());
                    return p.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateMaterial(LearningMaterial m) {
        if (m.getDepartmentId() == null || m.getDepartmentId() <= 0) {
            m.setScopeType("CULTURE");
            m.setDepartmentId(null);
        } else {
            m.setScopeType("DEPARTMENT");
        }
        String url = m.getMaterialUrl();
        String sqlWithBoth = "UPDATE Learning_Materials SET title=?,description=?,material_type=?,scope_type=?,department_id=?,position_id=?,level_id=?,material_url=?,video_url=?,duration_minutes=?,status=?,updated_at=GETDATE() WHERE material_id=?";
        String sqlFallback = "UPDATE Learning_Materials SET title=?,description=?,material_type=?,scope_type=?,department_id=?,position_id=?,level_id=?,video_url=?,duration_minutes=?,status=?,updated_at=GETDATE() WHERE material_id=?";
        try (Connection c = DBContext.getInstance().getConnection()) {
            try (PreparedStatement p = c.prepareStatement(sqlWithBoth)) {
                p.setString(1, m.getTitle());
                p.setString(2, m.getDescription());
                p.setString(3, m.getMaterialType());
                p.setString(4, m.getScopeType());
                setInt(p, 5, m.getDepartmentId());
                setInt(p, 6, m.getPositionId());
                setInt(p, 7, m.getLevelId());
                p.setString(8, url);
                p.setString(9, url);
                p.setInt(10, m.getDurationMinutes());
                p.setBoolean(11, m.isStatus());
                p.setInt(12, m.getMaterialId());
                return p.executeUpdate() > 0;
            } catch (SQLException ex) {
                try (PreparedStatement p = c.prepareStatement(sqlFallback)) {
                    p.setString(1, m.getTitle());
                    p.setString(2, m.getDescription());
                    p.setString(3, m.getMaterialType());
                    p.setString(4, m.getScopeType());
                    setInt(p, 5, m.getDepartmentId());
                    setInt(p, 6, m.getPositionId());
                    setInt(p, 7, m.getLevelId());
                    p.setString(8, url);
                    p.setInt(9, m.getDurationMinutes());
                    p.setBoolean(10, m.isStatus());
                    p.setInt(11, m.getMaterialId());
                    return p.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void bindMaterial(PreparedStatement p, LearningMaterial m, boolean update) throws SQLException {
        p.setString(1, m.getTitle());
        p.setString(2, m.getDescription());
        p.setString(3, m.getMaterialType());
        p.setString(4, m.getScopeType());
        setInt(p, 5, m.getDepartmentId());
        setInt(p, 6, m.getPositionId());
        setInt(p, 7, m.getLevelId());
        p.setString(8, m.getFileName());
        p.setString(9, m.getFileType());
        p.setString(10, m.getVideoUrl());
        p.setInt(11, m.getDurationMinutes());
        p.setBoolean(12, m.isStatus());
        if (update) {
            p.setInt(13, m.getMaterialId());
        } else {
            p.setInt(13, m.getCreatedBy());
        }
    }

    public boolean deleteMaterial(int id) {
        return exec("UPDATE Learning_Materials SET is_deleted=1 WHERE material_id=?", id);
    }

    public boolean checkUserCanAccessMaterial(int materialId, int userId, int roleId) {
        if (roleId == 2 || roleId == 3) {
            // HR (2) và MANAGER (3) tạo được học liệu và xem được tất cả
            return true;
        }
        // Mentor hoặc Mentee (học viên) chỉ xem được học liệu trong lớp của mình
        String sql = "SELECT COUNT(*) FROM Class_Materials cm "
                + "JOIN Training_Classes tc ON tc.class_id = cm.class_id AND tc.is_deleted = 0 "
                + "WHERE cm.material_id = ? AND ("
                + "    tc.mentor_id = ? "
                + "    OR EXISTS (SELECT 1 FROM Class_Enrollments ce WHERE ce.class_id = tc.class_id AND ce.user_id = ?)"
                + ")";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, materialId);
            p.setInt(2, userId);
            p.setInt(3, userId);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    return r.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<TrainingClass> getClassesByMaterial(int materialId) {
        List<TrainingClass> list = new ArrayList<>();
        String sql = "SELECT tc.*, u.full_name AS mentor_name, "
                + "(SELECT COUNT(*) FROM Class_Enrollments e WHERE e.class_id = tc.class_id) AS enrollment_count, "
                + "(SELECT COUNT(*) FROM Class_Materials cm2 WHERE cm2.class_id = tc.class_id) AS material_count "
                + "FROM Class_Materials cm "
                + "JOIN Training_Classes tc ON tc.class_id = cm.class_id "
                + "LEFT JOIN Users u ON u.user_id = tc.mentor_id "
                + "WHERE cm.material_id = ? AND tc.is_deleted = 0 "
                + "ORDER BY tc.start_date DESC";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, materialId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    list.add(mapClass(r));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<TrainingClass> getClasses(Integer userId, boolean mine) {
        List<TrainingClass> out = new ArrayList<TrainingClass>();
        String sql = "SELECT c.*,u.full_name mentor_name,"
                + "(SELECT COUNT(*) FROM Class_Enrollments e WHERE e.class_id=c.class_id) enrollment_count,"
                + "(SELECT COUNT(*) FROM Class_Materials x WHERE x.class_id=c.class_id) material_count "
                + "FROM Training_Classes c "
                + "LEFT JOIN Users u ON u.user_id=c.mentor_id "
                + "WHERE c.is_deleted=0 "
                + (mine ? "AND (c.mentor_id=? OR EXISTS (SELECT 1 FROM Class_Enrollments me WHERE me.class_id=c.class_id AND me.user_id=?)) " : "")
                + "ORDER BY c.start_date DESC";
        try (Connection cn = DBContext.getInstance().getConnection(); PreparedStatement p = cn.prepareStatement(sql)) {
            if (mine) {
                p.setObject(1, userId);
                p.setObject(2, userId);
            }
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    out.add(mapClass(r));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public TrainingClass getClassById(int id) {
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement("SELECT c.*,u.full_name mentor_name FROM Training_Classes c LEFT JOIN Users u ON u.user_id=c.mentor_id WHERE c.class_id=? AND c.is_deleted=0")) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (!r.next()) {
                    return null;
                }
                TrainingClass x = mapClass(r);
                x.setMaterials(getClassMaterials(id));
                return x;
            }
        } catch (SQLException e) {
            return null;
        }
    }

    public List<LearningMaterial> getClassMaterials(int id) {
        List<LearningMaterial> out = new ArrayList<LearningMaterial>();
        String sql = "SELECT m.*, d.department_name, p.position_name, l.level_name, u.full_name creator_name, "
                + "(SELECT COUNT(*) FROM Video_Checkpoints v WHERE v.material_id = m.material_id) checkpoint_count, "
                + "cm.order_index, cm.is_mandatory "
                + "FROM Class_Materials cm "
                + "JOIN Learning_Materials m ON m.material_id = cm.material_id "
                + "LEFT JOIN Departments d ON d.department_id = m.department_id "
                + "LEFT JOIN Positions p ON p.position_id = m.position_id "
                + "LEFT JOIN Job_Levels l ON l.level_id = m.level_id "
                + "LEFT JOIN Users u ON u.user_id = m.created_by "
                + "WHERE cm.class_id = ? AND m.is_deleted = 0 "
                + "ORDER BY cm.order_index";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    out.add(mapMaterial(r));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public int saveClass(TrainingClass x, int[] materials) {
        Connection c = null;
        try {
            c = DBContext.getInstance().getConnection();
            c.setAutoCommit(false);
            try (PreparedStatement p = c.prepareStatement("INSERT INTO Training_Classes(class_code,class_name,description,department_id,target_position_id,target_level_id,mentor_id,start_date,end_date,status,created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
                p.setString(1, x.getClassCode());
                p.setString(2, x.getClassName());
                p.setString(3, x.getDescription());
                setInt(p, 4, x.getDepartmentId());
                setInt(p, 5, x.getTargetPositionId());
                setInt(p, 6, x.getTargetLevelId());
                setInt(p, 7, x.getMentorId());
                p.setDate(8, x.getStartDate());
                p.setDate(9, x.getEndDate());
                p.setString(10, x.getStatus());
                p.setInt(11, x.getCreatedBy());
                p.executeUpdate();
                try (ResultSet r = p.getGeneratedKeys()) {
                    r.next();
                    int id = r.getInt(1);
                    linkMaterials(c, id, materials);
                    c.commit();
                    return id;
                }
            }
        } catch (SQLException e) {
            try {
                if (c != null) {
                    c.rollback();
                }
            } catch (SQLException ignored) {
            }
            e.printStackTrace();
            return 0;
        } finally {
            try {
                if (c != null) {
                    c.close();
                }
            } catch (SQLException ignored) {
            }
        }
    }

    public boolean deleteClass(int classId) {
        return exec("UPDATE Training_Classes SET is_deleted=1 WHERE class_id=?", classId);
    }

    private void linkMaterials(Connection c, int id, int[] ids) throws SQLException {
        if (ids == null) {
            return;
        }
        try (PreparedStatement p = c.prepareStatement("INSERT INTO Class_Materials(class_id,material_id,order_index,is_mandatory) VALUES(?,?,?,1)")) {
            for (int i = 0; i < ids.length; i++) {
                p.setInt(1, id);
                p.setInt(2, ids[i]);
                p.setInt(3, i + 1);
                p.addBatch();
            }
            p.executeBatch();
        }
    }

    public boolean addMaterialToClass(int classId, int materialId) {
        String sql = "IF NOT EXISTS (SELECT 1 FROM Class_Materials WHERE class_id = ? AND material_id = ?) "
                + "INSERT INTO Class_Materials(class_id, material_id, order_index, is_mandatory) "
                + "SELECT ?, ?, ISNULL(MAX(order_index), 0) + 1, 1 FROM Class_Materials WHERE class_id = ?";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, classId);
            p.setInt(2, materialId);
            p.setInt(3, classId);
            p.setInt(4, materialId);
            p.setInt(5, classId);
            return p.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeMaterialFromClass(int classId, int materialId) {
        String sql = "DELETE FROM Class_Materials WHERE class_id = ? AND material_id = ?";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, classId);
            p.setInt(2, materialId);
            return p.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<SmartCandidate> getSmartCandidatesForClass(int id) {
        List<SmartCandidate> out = new ArrayList<SmartCandidate>();
        String sql = "SELECT u.user_id,u.full_name,u.email,d.department_name,p.position_name,l.level_name,h.change_type, CASE WHEN h.change_type='NEW_HIRE' AND DATEDIFF(DAY,h.change_date,GETDATE())<=60 THEN 100 WHEN h.change_type IN ('ROLE_CHANGE','PROMOTION') AND DATEDIFF(DAY,h.change_date,GETDATE())<=60 THEN 85 WHEN u.position_id=c.target_position_id AND u.level_id=c.target_level_id THEN 75 WHEN u.department_id=c.department_id THEN 60 ELSE 40 END score FROM Training_Classes c CROSS JOIN Users u LEFT JOIN Departments d ON d.department_id=u.department_id LEFT JOIN Positions p ON p.position_id=u.position_id LEFT JOIN Job_Levels l ON l.level_id=u.level_id OUTER APPLY (SELECT TOP 1 change_type,change_date FROM Employee_History h WHERE h.user_id=u.user_id ORDER BY change_date DESC) h WHERE c.class_id=? AND u.is_deleted=0 AND u.status=1 AND NOT EXISTS(SELECT 1 FROM Class_Enrollments e WHERE e.class_id=c.class_id AND e.user_id=u.user_id) ORDER BY score DESC,u.user_id DESC";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    SmartCandidate x = new SmartCandidate();
                    x.setUserId(r.getInt(1));
                    x.setFullName(r.getString(2));
                    x.setEmail(r.getString(3));
                    x.setDepartmentName(r.getString(4));
                    x.setPositionName(r.getString(5));
                    x.setLevelName(r.getString(6));
                    x.setMatchScore(r.getInt(8));
                    String t = r.getString(7);
                    x.setMatchReason("NEW_HIRE".equals(t) ? "Nhân sự mới (Onboarding)" : "ROLE_CHANGE".equals(t) ? "Vừa chuyển ngạch chuyên môn" : "PROMOTION".equals(t) ? "Vừa được thăng cấp" : x.getMatchScore() >= 75 ? "Đúng vị trí và cấp bậc" : "Phù hợp theo cơ cấu phòng ban");
                    out.add(x);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public int enrollBatch(int classId, String[] ids, int actor) {
        if (ids == null) {
            return 0;
        }
        int n = 0;
        String sql = "INSERT INTO Class_Enrollments(class_id,user_id,enrolled_by,enrollment_type,assigned_reason) SELECT ?,?,?,?,? WHERE NOT EXISTS(SELECT 1 FROM Class_Enrollments WHERE class_id=? AND user_id=?)";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            for (String s : ids) {
                int uid = Integer.parseInt(s);
                p.setInt(1, classId);
                p.setInt(2, uid);
                p.setInt(3, actor);
                p.setString(4, "SMART_ASSIGN");
                p.setString(5, "Được gợi ý bởi Smart Match");
                p.setInt(6, classId);
                p.setInt(7, uid);
                n += p.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return n;
    }

    public List<ClassEnrollment> getEnrollments(int classId) {
        List<ClassEnrollment> out = new ArrayList<ClassEnrollment>();
        String sql = "SELECT e.*,u.full_name FROM Class_Enrollments e JOIN Users u ON u.user_id=e.user_id WHERE e.class_id=? ORDER BY e.enrolled_at DESC";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, classId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    ClassEnrollment e = new ClassEnrollment();
                    e.setEnrollmentId(r.getInt("enrollment_id"));
                    e.setClassId(classId);
                    e.setUserId(r.getInt("user_id"));
                    e.setUserName(r.getString("full_name"));
                    e.setStatus(r.getString("status"));
                    e.setProgressPercent(r.getInt("progress_percent"));
                    e.setEnrollmentType(r.getString("enrollment_type"));
                    e.setAssignedReason(r.getString("assigned_reason"));
                    e.setEnrolledAt(r.getTimestamp("enrolled_at"));
                    out.add(e);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public boolean deleteEnrollment(int enrollmentId) {
        return exec("DELETE FROM Class_Enrollments WHERE enrollment_id=?", enrollmentId);
    }

    public List<VideoCheckpoint> getCheckpoints(int materialId) {
        List<VideoCheckpoint> out = new ArrayList<VideoCheckpoint>();
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement("SELECT * FROM Video_Checkpoints WHERE material_id=? ORDER BY stop_time_seconds")) {
            p.setInt(1, materialId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    VideoCheckpoint x = new VideoCheckpoint();
                    x.setCheckpointId(r.getInt("checkpoint_id"));
                    x.setMaterialId(materialId);
                    x.setStopTimeSeconds(r.getInt("stop_time_seconds"));
                    x.setQuestionPrompt(r.getString("question_prompt"));
                    x.setOptionA(r.getString("option_a"));
                    x.setOptionB(r.getString("option_b"));
                    x.setOptionC(r.getString("option_c"));
                    x.setOptionD(r.getString("option_d"));
                    x.setCorrectOption(r.getInt("correct_option"));
                    x.setExplanation(r.getString("explanation"));
                    out.add(x);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    public boolean addCheckpoint(VideoCheckpoint x) {
        String q = "INSERT INTO Video_Checkpoints(material_id,stop_time_seconds,question_prompt,option_a,option_b,option_c,option_d,correct_option,explanation) VALUES(?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(q)) {
            p.setInt(1, x.getMaterialId());
            p.setInt(2, x.getStopTimeSeconds());
            p.setString(3, x.getQuestionPrompt());
            p.setString(4, x.getOptionA());
            p.setString(5, x.getOptionB());
            p.setString(6, x.getOptionC());
            p.setString(7, x.getOptionD());
            p.setInt(8, x.getCorrectOption());
            p.setString(9, x.getExplanation());
            return p.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean updateCheckpoint(VideoCheckpoint x) {
        String q = "UPDATE Video_Checkpoints SET stop_time_seconds=?,question_prompt=?,option_a=?,option_b=?,option_c=?,option_d=?,correct_option=?,explanation=? WHERE checkpoint_id=?";
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(q)) {
            p.setInt(1, x.getStopTimeSeconds());
            p.setString(2, x.getQuestionPrompt());
            p.setString(3, x.getOptionA());
            p.setString(4, x.getOptionB());
            p.setString(5, x.getOptionC());
            p.setString(6, x.getOptionD());
            p.setInt(7, x.getCorrectOption());
            p.setString(8, x.getExplanation());
            p.setInt(9, x.getCheckpointId());
            return p.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteCheckpoint(int checkpointId) {
        return exec("DELETE FROM Video_Checkpoints WHERE checkpoint_id=?", checkpointId);
    }

    public boolean recordAnswer(int checkpointId, int userId, int option) {
        VideoCheckpoint cp = getCheckpoint(checkpointId);
        if (cp == null) {
            return false;
        }
        boolean correct = cp.getCorrectOption() == option;
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement up = c.prepareStatement("UPDATE Video_Question_Answers SET selected_option=?,is_correct=?,attempt_count=attempt_count+1,answered_at=GETDATE() WHERE checkpoint_id=? AND user_id=?")) {
            up.setInt(1, option);
            up.setBoolean(2, correct);
            up.setInt(3, checkpointId);
            up.setInt(4, userId);
            if (up.executeUpdate() == 0) {
                try (PreparedStatement in = c.prepareStatement("INSERT INTO Video_Question_Answers(checkpoint_id,user_id,selected_option,is_correct) VALUES(?,?,?,?)")) {
                    in.setInt(1, checkpointId);
                    in.setInt(2, userId);
                    in.setInt(3, option);
                    in.setBoolean(4, correct);
                    in.executeUpdate();
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public VideoCheckpoint getCheckpoint(int id) {
        for (VideoCheckpoint x : getCheckpointsById(id)) {
            return x;
        }
        return null;
    }

    private List<VideoCheckpoint> getCheckpointsById(int id) {
        List<VideoCheckpoint> a = new ArrayList<VideoCheckpoint>();
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement("SELECT * FROM Video_Checkpoints WHERE checkpoint_id=?")) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    VideoCheckpoint x = new VideoCheckpoint();
                    x.setCheckpointId(id);
                    x.setCorrectOption(r.getInt("correct_option"));
                    x.setExplanation(r.getString("explanation"));
                    a.add(x);
                }
            }
        } catch (SQLException e) {
        }
        return a;
    }

    private boolean exec(String s, int id) {
        try (Connection c = DBContext.getInstance().getConnection(); PreparedStatement p = c.prepareStatement(s)) {
            p.setInt(1, id);
            return p.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    private void setInt(PreparedStatement p, int i, Integer v) throws SQLException {
        if (v == null || v <= 0) {
            p.setNull(i, Types.INTEGER);
        } else {
            p.setInt(i, v);
        }
    }

    private LearningMaterial mapMaterial(ResultSet r) throws SQLException {
        LearningMaterial m = new LearningMaterial();
        m.setMaterialId(r.getInt("material_id"));
        m.setTitle(r.getString("title"));
        m.setDescription(r.getString("description"));
        m.setMaterialType(r.getString("material_type"));
        m.setScopeType(r.getString("scope_type"));
        m.setDepartmentId((Integer) r.getObject("department_id"));
        m.setPositionId((Integer) r.getObject("position_id"));
        m.setLevelId((Integer) r.getObject("level_id"));
        try {
            m.setDepartmentName(r.getString("department_name"));
        } catch (SQLException ignored) {
        }
        try {
            m.setPositionName(r.getString("position_name"));
        } catch (SQLException ignored) {
        }
        try {
            m.setLevelName(r.getString("level_name"));
        } catch (SQLException ignored) {
        }
        m.setFileName(r.getString("file_name"));
        m.setFileType(r.getString("file_type"));
        String mUrl = null;
        try {
            mUrl = r.getString("material_url");
        } catch (SQLException ignored) {
        }
        if (mUrl == null || mUrl.trim().isEmpty()) {
            try {
                mUrl = r.getString("video_url");
            } catch (SQLException ignored) {
            }
        }
        m.setMaterialUrl(mUrl);
        m.setDurationMinutes(r.getInt("duration_minutes"));
        m.setStatus(r.getBoolean("status"));
        m.setCreatedBy(r.getInt("created_by"));
        try {
            m.setCreatorName(r.getString("creator_name"));
        } catch (SQLException ignored) {
        }
        try {
            m.setCheckpointCount(r.getInt("checkpoint_count"));
            m.setUserProgressStatus(r.getString("user_progress_status"));
        } catch (SQLException ignored) {
        }
        try {
            m.setEnrolledClassCount(r.getInt("enrolled_class_count"));
        } catch (SQLException ignored) {
        }
        return m;
    }

    private TrainingClass mapClass(ResultSet r) throws SQLException {
        TrainingClass x = new TrainingClass();
        x.setClassId(r.getInt("class_id"));
        x.setClassCode(r.getString("class_code"));
        x.setClassName(r.getString("class_name"));
        x.setDescription(r.getString("description"));
        x.setDepartmentId((Integer) r.getObject("department_id"));
        x.setTargetPositionId((Integer) r.getObject("target_position_id"));
        x.setTargetLevelId((Integer) r.getObject("target_level_id"));
        x.setMentorId((Integer) r.getObject("mentor_id"));
        x.setMentorName(r.getString("mentor_name"));
        x.setStartDate(r.getDate("start_date"));
        x.setEndDate(r.getDate("end_date"));
        x.setStatus(r.getString("status"));
        try {
            x.setEnrollmentCount(r.getInt("enrollment_count"));
            x.setMaterialCount(r.getInt("material_count"));
        } catch (SQLException ignored) {
        }
        return x;
    }
}
