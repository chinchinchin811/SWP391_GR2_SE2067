package controller;

import dal.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;
import model.*;

@MultipartConfig(maxFileSize = 52428800)
public class MaterialServlet extends HttpServlet {

    private final MaterialDAO dao = new MaterialDAO();
    private final DepartmentDAO departments = new DepartmentDAO();
    private final PositionDAO positions = new PositionDAO();
    private final UserDAO users = new UserDAO();

    protected void doGet(HttpServletRequest q, HttpServletResponse s) throws ServletException, IOException {
        User u = current(q, s);
        if (u == null) {
            return;
        }
        if (u.getRoleId() == 1) {
            s.sendRedirect(q.getContextPath() + "/departments");
            return;
        }
        String a = param(q, "action", "list");
        if ("download".equals(a) || "preview".equals(a)) {
            stream(q, s);
            return;
        }
        if ("answerCheckpoint".equals(a)) {
            answer(q, s, u);
            return;
        }
        if ("list".equals(a)) {
            List<TrainingClass> myClasses = dao.getClasses(u.getUserId(), true);
            List<LearningMaterial> allMaterials = dao.getMaterials(u.getUserId(), u.getRoleId());
            List<LearningMaterial> displayMaterials;
            boolean canManageUser = canManage(u);
            boolean isClassMember = myClasses != null && !myClasses.isEmpty();

            if (!canManageUser && isClassMember) {
                // Mentor và Mentee: chỉ hiển thị học liệu có trong lớp của mình
                displayMaterials = new ArrayList<>();
                for (LearningMaterial m : allMaterials) {
                    if (m.isUserHasAccess()) {
                        displayMaterials.add(m);
                    }
                }
            } else {
                displayMaterials = new ArrayList<>();
                for (LearningMaterial m : allMaterials) {
                    if (!canManageUser || canManageMaterial(u, m)) {
                        displayMaterials.add(m);
                    }
                }
            }

            q.setAttribute("materials", displayMaterials);
            q.setAttribute("classes", myClasses);
            go(q, s, "/views/materials/material-list.jsp");
            return;
        }
        if ("view".equals(a)) {
            int id = num(q, "id");
            LearningMaterial m = dao.getMaterial(id);
            if (m == null) {
                s.sendRedirect(q.getContextPath() + "/materials");
                return;
            }
            if (canManage(u) && !canManageMaterial(u, m)) {
                forbidden(s, "Học liệu không thuộc phạm vi phòng ban của bạn.");
                return;
            }
            boolean hasAccess = canManageMaterial(u, m) || dao.checkUserCanAccessMaterial(id, u.getUserId(), u.getRoleId());
            q.setAttribute("material", m);
            q.setAttribute("hasAccess", hasAccess);
            q.setAttribute("canManageMaterial", canManageMaterial(u, m));
            q.setAttribute("checkpoints", hasAccess ? dao.getCheckpoints(id) : Collections.emptyList());
            if (!hasAccess) {
                q.setAttribute("relatedClasses", dao.getClassesByMaterial(id));
            }
            go(q, s, "/views/materials/material-detail.jsp");
            return;
        }
        if ("classList".equals(a)) {
            List<TrainingClass> classes = new ArrayList<>();
            for (TrainingClass item : dao.getClasses(u.getUserId(), !canManage(u))) {
                if (!canManage(u) || canManageClass(u, item)) classes.add(item);
            }
            q.setAttribute("classes", classes);
            go(q, s, "/views/materials/class-list.jsp");
            return;
        }
        if ("classDetail".equals(a)) {
            TrainingClass c = dao.getClassById(num(q, "id"));
            if (c == null) {
                s.sendRedirect(q.getContextPath() + "/materials?action=classList");
                return;
            }
            if (!canManageClass(u, c) && !isMyClass(u, c.getClassId())) {
                forbidden(s, "Bạn không thuộc lớp đào tạo này.");
                return;
            }
            q.setAttribute("trainingClass", c);
            q.setAttribute("enrollments", dao.getEnrollments(c.getClassId()));
            if (canManage(u)) {
                List<LearningMaterial> available = new ArrayList<>();
                for (LearningMaterial m : dao.getMaterials(null)) {
                    if (canManageMaterial(u, m)) available.add(m);
                }
                q.setAttribute("availableMaterials", available);
            }
            go(q, s, "/views/materials/class-detail.jsp");
            return;
        }
        if ("classAssign".equals(a)) {
            TrainingClass target = dao.getClassById(num(q, "id"));
            if (!canManageClass(u, target)) {
                deny(s, q);
                return;
            }
            int id = num(q, "id");
            q.setAttribute("trainingClass", dao.getClassById(id));
            q.setAttribute("candidates", dao.getSmartCandidatesForClass(id));
            go(q, s, "/views/materials/class-assign.jsp");
            return;
        }
        if ("create".equals(a) || "edit".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            formData(q);
            LearningMaterial material = "edit".equals(a) ? dao.getMaterial(num(q, "id")) : new LearningMaterial();
            if ("edit".equals(a) && !canManageMaterial(u, material)) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phạm vi phòng ban của mình.");
                return;
            }
            q.setAttribute("material", material);
            q.setAttribute("checkpoints", material != null && material.getMaterialId() > 0 ? dao.getCheckpoints(material.getMaterialId()) : Collections.emptyList());
            go(q, s, "/views/materials/material-form.jsp");
            return;
        }
        if ("classCreate".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            formData(q);
            List<LearningMaterial> materials = new ArrayList<>();
            for (LearningMaterial m : dao.getMaterials(null)) {
                if (canManageMaterial(u, m)) materials.add(m);
            }
            q.setAttribute("materials", materials);
            go(q, s, "/views/materials/class-form.jsp");
            return;
        }
        if ("deleteMaterial".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            LearningMaterial target = dao.getMaterial(num(q, "id"));
            if (!canManageMaterial(u, target)) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phạm vi phòng ban của mình.");
                return;
            }
            dao.deleteMaterial(target.getMaterialId());
            flash(q, "Đã xóa học liệu thành công.");
            s.sendRedirect(q.getContextPath() + "/materials");
            return;
        }
        if ("deleteClass".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            TrainingClass target = dao.getClassById(num(q, "id"));
            if (!canManageClass(u, target)) {
                forbidden(s, "Bạn chỉ được quản lý lớp thuộc phòng ban của mình.");
                return;
            }
            dao.deleteClass(target.getClassId());
            flash(q, "Đã xóa lớp đào tạo thành công.");
            s.sendRedirect(q.getContextPath() + "/materials?action=classList");
            return;
        }
        s.sendRedirect(q.getContextPath() + "/materials");
    }

    protected void doPost(HttpServletRequest q, HttpServletResponse s) throws ServletException, IOException {
        User u = current(q, s);
        if (u == null) {
            return;
        }
        if (u.getRoleId() == 1) {
            s.sendRedirect(q.getContextPath() + "/departments");
            return;
        }
        String a = param(q, "action", "");
        if (!"answerCheckpoint".equals(a) && !canManage(u)) {
            deny(s, q);
            return;
        }
        if ("saveMaterial".equals(a)) {
            LearningMaterial m = material(q, u);
            if (m.getMaterialId() > 0 && !canManageMaterial(u, dao.getMaterial(m.getMaterialId()))) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phạm vi phòng ban của mình.");
                return;
            }
            if (m.getTitle() == null || m.getTitle().trim().isEmpty()) {
                error(q, "Vui lòng nhập tiêu đề học liệu!");
                s.sendRedirect(q.getContextPath() + "/materials?action=" + (m.getMaterialId() > 0 ? "edit&id=" + m.getMaterialId() : "create"));
                return;
            }
            if (m.getMaterialUrl() == null || m.getMaterialUrl().trim().isEmpty()) {
                error(q, "Vui lòng nhập đường dẫn học liệu trực tuyến (URL)!");
                s.sendRedirect(q.getContextPath() + "/materials?action=" + (m.getMaterialId() > 0 ? "edit&id=" + m.getMaterialId() : "create"));
                return;
            }
            boolean ok = m.getMaterialId() > 0 ? dao.updateMaterial(m) : dao.saveMaterial(m);
            flash(q, ok ? "Lưu học liệu thành công." : "Không thể lưu học liệu.");
            s.sendRedirect(q.getContextPath() + "/materials");
            return;
        }
        if ("deleteMaterial".equals(a)) {
            LearningMaterial target = dao.getMaterial(num(q, "id"));
            if (!canManageMaterial(u, target)) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phạm vi phòng ban của mình.");
                return;
            }
            dao.deleteMaterial(target.getMaterialId());
            flash(q, "Đã xóa học liệu.");
            s.sendRedirect(q.getContextPath() + "/materials");
            return;
        }
        if ("deleteClass".equals(a)) {
            TrainingClass target = dao.getClassById(num(q, "id"));
            if (!canManageClass(u, target)) {
                forbidden(s, "Bạn chỉ được quản lý lớp thuộc phòng ban của mình.");
                return;
            }
            dao.deleteClass(target.getClassId());
            flash(q, "Đã xóa lớp đào tạo thành công.");
            s.sendRedirect(q.getContextPath() + "/materials?action=classList");
            return;
        }
        if ("saveClass".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            TrainingClass c = new TrainingClass();
            c.setClassCode(q.getParameter("classCode"));
            c.setClassName(q.getParameter("className"));
            c.setDescription(q.getParameter("description"));
            c.setDepartmentId(u.getDepartmentId());
            c.setTargetPositionId(opt(q, "positionId"));
            c.setTargetLevelId(opt(q, "levelId"));
            c.setMentorId(opt(q, "mentorId"));
            try {
                String startStr = q.getParameter("startDate");
                String endStr = q.getParameter("endDate");
                if (startStr == null || startStr.trim().isEmpty()) {
                    error(q, "Vui lòng chọn ngày bắt đầu lớp đào tạo.");
                    s.sendRedirect(q.getContextPath() + "/materials?action=classCreate");
                    return;
                }
                if (endStr == null || endStr.trim().isEmpty()) {
                    error(q, "Vui lòng chọn ngày kết thúc lớp đào tạo.");
                    s.sendRedirect(q.getContextPath() + "/materials?action=classCreate");
                    return;
                }
                Date startDate = Date.valueOf(startStr.trim());
                Date endDate = Date.valueOf(endStr.trim());
                LocalDate startLocal = startDate.toLocalDate();
                LocalDate endLocal = endDate.toLocalDate();

                if (startLocal.isBefore(LocalDate.now())) {
                    error(q, "Ngày bắt đầu không được nằm trong quá khứ.");
                    s.sendRedirect(q.getContextPath() + "/materials?action=classCreate");
                    return;
                }
                if (!endLocal.isAfter(startLocal)) {
                    error(q, "Ngày kết thúc phải sau ngày bắt đầu ít nhất 1 ngày.");
                    s.sendRedirect(q.getContextPath() + "/materials?action=classCreate");
                    return;
                }
                c.setStartDate(startDate);
                c.setEndDate(endDate);
            } catch (IllegalArgumentException ex) {
                error(q, "Ngày bắt đầu và ngày kết thúc không hợp lệ.");
                s.sendRedirect(q.getContextPath() + "/materials?action=classCreate");
                return;
            }
            c.setStatus(param(q, "status", "OPEN"));
            c.setCreatedBy(u.getUserId());
            String[] selected = q.getParameterValues("materialIds");
            int[] ids = selected == null ? null : Arrays.stream(selected).mapToInt(Integer::parseInt).toArray();
            if (ids != null) {
                for (int materialId : ids) {
                    if (!canManageMaterial(u, dao.getMaterial(materialId))) {
                        forbidden(s, "Lớp chỉ được dùng học liệu thuộc phòng ban của mình.");
                        return;
                    }
                }
            }
            int id = dao.saveClass(c, ids);
            flash(q, id > 0 ? "Mở lớp đào tạo thành công." : "Không thể mở lớp.");
            s.sendRedirect(q.getContextPath() + "/materials?action=classList");
            return;
        }
        if ("enrollSubmit".equals(a)) {
            int classId = num(q, "classId");
            if (!canManageClass(u, dao.getClassById(classId))) {
                forbidden(s, "Bạn chỉ được quản lý lớp thuộc phòng ban của mình.");
                return;
            }
            int n = dao.enrollBatch(classId, q.getParameterValues("userIds"), u.getUserId());
            flash(q, "Đã ghi danh " + n + " nhân sự.");
            s.sendRedirect(q.getContextPath() + "/materials?action=classAssign&id=" + num(q, "classId"));
            return;
        }
        if ("deleteEnrollment".equals(a)) {
            int classId = num(q, "classId");
            if (!canManageClass(u, dao.getClassById(classId))) {
                forbidden(s, "Bạn chỉ được quản lý lớp thuộc phòng ban của mình.");
                return;
            }
            dao.deleteEnrollment(num(q, "enrollmentId"));
            flash(q, "Đã xóa học viên khỏi lớp.");
            s.sendRedirect(q.getContextPath() + "/materials?action=classDetail&id=" + classId);
            return;
        }
        if ("addClassMaterial".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            int classId = num(q, "classId");
            int materialId = num(q, "materialId");
            if (!canManageClass(u, dao.getClassById(classId)) || !canManageMaterial(u, dao.getMaterial(materialId))) {
                forbidden(s, "Lớp chỉ được dùng học liệu thuộc phòng ban của mình.");
                return;
            }
            if (materialId > 0) {
                dao.addMaterialToClass(classId, materialId);
                flash(q, "Đã thêm học liệu vào lớp đào tạo.");
            }
            s.sendRedirect(q.getContextPath() + "/materials?action=classDetail&id=" + classId);
            return;
        }
        if ("removeClassMaterial".equals(a)) {
            if (!canManage(u)) {
                deny(s, q);
                return;
            }
            int classId = num(q, "classId");
            int materialId = num(q, "materialId");
            if (!canManageClass(u, dao.getClassById(classId)) || !canManageMaterial(u, dao.getMaterial(materialId))) {
                forbidden(s, "Bạn chỉ được quản lý lớp và học liệu thuộc phòng ban của mình.");
                return;
            }
            if (materialId > 0) {
                dao.removeMaterialFromClass(classId, materialId);
                flash(q, "Đã gỡ học liệu khỏi lớp đào tạo.");
            }
            s.sendRedirect(q.getContextPath() + "/materials?action=classDetail&id=" + classId);
            return;
        }
        if ("addCheckpoint".equals(a)) {
            VideoCheckpoint x = new VideoCheckpoint();
            x.setMaterialId(num(q, "materialId"));
            if (!canManageMaterial(u, dao.getMaterial(x.getMaterialId()))) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phòng ban của mình.");
                return;
            }
            x.setStopTimeSeconds(num(q, "stopTimeSeconds"));
            x.setQuestionPrompt(q.getParameter("questionPrompt"));
            x.setOptionA(q.getParameter("optionA"));
            x.setOptionB(q.getParameter("optionB"));
            x.setOptionC(q.getParameter("optionC"));
            x.setOptionD(q.getParameter("optionD"));
            x.setCorrectOption(num(q, "correctOption"));
            boolean ok = dao.addCheckpoint(x);
            flash(q, ok ? "Đã thêm mốc dừng câu hỏi thành công." : "Không thể thêm mốc dừng.");
            s.sendRedirect(q.getContextPath() + "/materials?action=edit&id=" + x.getMaterialId());
            return;
        }
        if ("updateCheckpoint".equals(a)) {
            VideoCheckpoint x = new VideoCheckpoint();
            x.setCheckpointId(num(q, "checkpointId"));
            x.setMaterialId(num(q, "materialId"));
            if (!canManageMaterial(u, dao.getMaterial(x.getMaterialId()))) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phòng ban của mình.");
                return;
            }
            x.setStopTimeSeconds(num(q, "stopTimeSeconds"));
            x.setQuestionPrompt(q.getParameter("questionPrompt"));
            x.setOptionA(q.getParameter("optionA"));
            x.setOptionB(q.getParameter("optionB"));
            x.setOptionC(q.getParameter("optionC"));
            x.setOptionD(q.getParameter("optionD"));
            x.setCorrectOption(num(q, "correctOption"));
            x.setExplanation(q.getParameter("explanation"));
            boolean ok = dao.updateCheckpoint(x);
            flash(q, ok ? "Đã cập nhật câu hỏi mốc dừng thành công." : "Không thể cập nhật mốc dừng.");
            s.sendRedirect(q.getContextPath() + "/materials?action=edit&id=" + x.getMaterialId());
            return;
        }
        if ("deleteCheckpoint".equals(a)) {
            int cpId = num(q, "checkpointId");
            int matId = num(q, "materialId");
            if (!canManageMaterial(u, dao.getMaterial(matId))) {
                forbidden(s, "Bạn chỉ được quản lý học liệu thuộc phòng ban của mình.");
                return;
            }
            boolean ok = dao.deleteCheckpoint(cpId);
            flash(q, ok ? "Đã xóa câu hỏi mốc dừng." : "Không thể xóa mốc dừng.");
            s.sendRedirect(q.getContextPath() + "/materials?action=edit&id=" + matId);
            return;
        }
        if ("answerCheckpoint".equals(a)) {
            answer(q, s, u);
        } else {
            s.sendRedirect(q.getContextPath() + "/materials");
        }
    }

    private void answer(HttpServletRequest q, HttpServletResponse s, User u) throws IOException {
        int cp = num(q, "checkpointId"), selected = num(q, "selectedOption");
        VideoCheckpoint x = dao.getCheckpoint(cp);
        if (x != null && !canManage(u) && !dao.checkUserCanAccessMaterial(x.getMaterialId(), u.getUserId(), u.getRoleId())) {
            s.setContentType("application/json;charset=UTF-8");
            s.getWriter().print("{\"ok\":false,\"correct\":false,\"explanation\":\"Vui lòng tham gia lớp đào tạo để xem học liệu và làm bài kiểm tra.\"}");
            return;
        }
        boolean correct = x != null && x.getCorrectOption() == selected;
        dao.recordAnswer(cp, u.getUserId(), selected);
        s.setContentType("application/json;charset=UTF-8");
        s.getWriter().print("{\"ok\":true,\"correct\":" + correct + ",\"explanation\":\"" + json(x == null ? "" : x.getExplanation()) + "\"}");
    }

    private void stream(HttpServletRequest q, HttpServletResponse s) throws IOException {
        User u = (User) q.getSession().getAttribute("currentUser");
        int id = num(q, "id");
        LearningMaterial m = dao.getMaterial(id);
        if (m == null) {
            s.sendError(404);
            return;
        }
        if (u == null || (!canManage(u) && !dao.checkUserCanAccessMaterial(id, u.getUserId(), u.getRoleId()))) {
            s.sendError(HttpServletResponse.SC_FORBIDDEN, "Vui lòng tham gia lớp đào tạo để xem học liệu này.");
            return;
        }
        String target = m.getMaterialUrl();
        if (target != null && !target.trim().isEmpty()) {
            s.sendRedirect(target.trim());
            return;
        }
        byte[] data = dao.getMaterialFile(m.getMaterialId());
        if (data != null && data.length > 0) {
            s.setContentType(m.getFileType() == null ? "application/octet-stream" : m.getFileType());
            String disposition = "preview".equals(q.getParameter("action")) ? "inline" : "attachment";
            s.setHeader("Content-Disposition", disposition + "; filename=\"" + (m.getFileName() == null ? "material" : m.getFileName().replace("\"", "")) + "\"");
            s.setContentLength(data.length);
            s.getOutputStream().write(data);
            return;
        }
        s.sendError(404, "Học liệu chưa được gắn đường dẫn trực tuyến hợp lệ.");
    }

    private LearningMaterial material(HttpServletRequest q, User u) {
        LearningMaterial m = new LearningMaterial();
        m.setMaterialId(num(q, "id"));
        m.setTitle(q.getParameter("title"));
        m.setDescription(q.getParameter("description"));
        m.setMaterialType(q.getParameter("materialType"));
        Integer deptId = canManage(u) ? u.getDepartmentId() : opt(q, "departmentId");
        if (deptId != null && deptId > 0) {
            m.setScopeType("DEPARTMENT");
            m.setDepartmentId(deptId);
        } else {
            m.setScopeType("CULTURE");
            m.setDepartmentId(null);
        }
        m.setPositionId(opt(q, "positionId"));
        m.setLevelId(opt(q, "levelId"));

        String url = q.getParameter("materialUrl");
        if (url == null || url.trim().isEmpty()) {
            url = q.getParameter("videoUrl");
        }
        if (url != null) {
            url = url.trim();
        }
        m.setMaterialUrl(url);
        if ("VIDEO".equals(m.getMaterialType())) {
            m.setDurationMinutes(num(q, "durationMinutes"));
        } else {
            m.setDurationMinutes(0);
        }
        m.setStatus(q.getParameter("status") != null);
        m.setCreatedBy(u.getUserId());
        return m;
    }

    private void formData(HttpServletRequest q) {
        q.setAttribute("departments", departments.getAllDepartments());
        q.setAttribute("positions", positions.getAllPositions());
        q.setAttribute("levels", positions.getAllJobLevels());
        q.setAttribute("mentors", users.getManagersCandidates());
    }

    private User current(HttpServletRequest q, HttpServletResponse s) throws IOException {
        HttpSession h = q.getSession(false);
        if (h == null || h.getAttribute("currentUser") == null) {
            s.sendRedirect(q.getContextPath() + "/login");
            return null;
        }
        User sessionUser = (User) h.getAttribute("currentUser");
        User currentUser = users.getUserById(sessionUser.getUserId());
        if (currentUser == null) {
            h.invalidate();
            s.sendRedirect(q.getContextPath() + "/login");
            return null;
        }
        if (currentUser.getRoleId() == 2) {
            s.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return currentUser;
    }

    private boolean canManage(User u) {
        if (u == null) return false;
        int r = u.getRoleId();
        return r == 3;
    }

    private boolean canManageMaterial(User u, LearningMaterial material) {
        if (!canManage(u) || material == null) return false;
        Integer userDepartment = u.getDepartmentId();
        return userDepartment != null && userDepartment.equals(material.getDepartmentId());
    }

    private boolean canManageClass(User u, TrainingClass trainingClass) {
        return canManage(u) && trainingClass != null && u.getDepartmentId() != null
                && u.getDepartmentId().equals(trainingClass.getDepartmentId());
    }

    private boolean isMyClass(User u, int classId) {
        for (TrainingClass item : dao.getClasses(u.getUserId(), true)) {
            if (item.getClassId() == classId) return true;
        }
        return false;
    }

    private void deny(HttpServletResponse s, HttpServletRequest q) throws IOException {
        s.sendRedirect(q.getContextPath() + "/materials");
    }

    private void forbidden(HttpServletResponse s, String message) throws IOException {
        s.sendError(HttpServletResponse.SC_FORBIDDEN, message);
    }

    private int num(HttpServletRequest q, String n) {
        try {
            return Integer.parseInt(q.getParameter(n));
        } catch (Exception e) {
            return 0;
        }
    }

    private Integer opt(HttpServletRequest q, String n) {
        int x = num(q, n);
        return x > 0 ? x : null;
    }

    private String param(HttpServletRequest q, String n, String d) {
        String v = q.getParameter(n);
        return v == null || v.trim().isEmpty() ? d : v;
    }

    private void go(HttpServletRequest q, HttpServletResponse s, String p) throws ServletException, IOException {
        q.getRequestDispatcher(p).forward(q, s);
    }

    private void flash(HttpServletRequest q, String v) {
        q.getSession().setAttribute("successMessage", v);
    }

    private void error(HttpServletRequest q, String v) {
        q.getSession().setAttribute("errorMessage", v);
    }

    private String json(String x) {
        return x == null ? "" : x.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
