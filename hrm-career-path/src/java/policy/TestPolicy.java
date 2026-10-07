package policy;

import java.time.Instant;
import java.util.Objects;
import model.TestActor;
import model.TestAssignment;
import model.TestTemplate;

/**
 * Phân quyền tái sử dụng; DAO còn giới hạn phạm vi trong SQL trước khi trả dữ
 * liệu.
 */
public final class TestPolicy {

    /** ADMIN chỉ quản lý Văn hóa; HR quản lý cả hai; MANAGER quản lý Chuyên môn đúng phòng. */
    public boolean canManage(TestActor actor, TestTemplate t) {
        return "culture".equals(t.type()) ? actor.cultureManager()
                : "HR".equals(actor.role())
                || (actor.departmentManager() && Objects.equals(actor.managedDepartmentId(), t.departmentId()));
    }

    /** Đề đã tạo hiển thị theo phạm vi; ADMIN chỉ xem đề văn hóa. */
    public boolean canView(TestActor actor, TestTemplate t) {
        return !"ADMIN".equals(actor.role()) || canManage(actor, t);
    }

    /**
     * Chỉ giao đề đã công bố, chưa hết hạn; từng người nhận còn được kiểm tra ở
     * service.
     */
    public boolean canAssign(TestActor actor, TestTemplate t, Instant now) {
        return canManage(actor, t) && "published".equals(t.status()) && now.isBefore(t.endTime());
    }

    /**
     * Bài nộp chỉ chủ bài hoặc người quản lý đề được đọc, không mở cho cả
     * phòng.
     */
    public boolean canViewAssignment(TestActor actor, TestAssignment a, TestTemplate t) {
        return canView(actor, t) && (a.assigneeId() == actor.id() || canManage(actor, t));
    }

    /**
     * Cho chấm cả sau khi đóng đề, nhưng chỉ chấm bài submitted một lần.
     */
    public boolean canEvaluate(TestActor actor, TestAssignment a, TestTemplate t) {
        return canViewAssignment(actor, a, t) && canManage(actor, t) && canEvaluateAssignee(actor, a)
                && "submitted".equals(a.status());
    }

    /** Người chấm phải có vai trò cao hơn người làm; cùng vai trò không được tự chấm lẫn nhau. */
    public boolean canEvaluateAssignee(TestActor actor, TestAssignment assignment) {
        return actor.id() != assignment.assigneeId()
                && roleRank(actor.role()) > roleRank(assignment.assigneeRole());
    }

    /** Chỉ bắt đầu trong khoảng mở của đợt và khi bài vẫn đang chờ làm. */
    public boolean canStart(TestActor actor, TestAssignment a, TestTemplate t, Instant now) {
        return a.assigneeId() == actor.id() && canView(actor, t) && "published".equals(t.status())
                && !now.isBefore(t.startTime()) && now.isBefore(t.endTime())
                && "pending".equals(a.status());
    }

    /** Hạn nộp cá nhân không vượt quá giờ đóng chung của đợt. */
    public boolean canSubmit(TestActor actor, TestAssignment a, TestTemplate t, Instant now) {
        return a.assigneeId() == actor.id() && canView(actor, t) && "published".equals(t.status())
                && !now.isBefore(t.startTime()) && now.isBefore(t.endTime())
                && "in_progress".equals(a.status())
                && (a.startedAt() == null || now.isBefore(a.submissionDeadline()));
    }

    /** Chỉ người giao hoặc vai trò cấp trên trong hệ thống được thu hồi. */
    public boolean canRevoke(TestActor actor, TestAssignment assignment) {
        return "pending".equals(assignment.status())
                && (actor.id() == assignment.assignedBy()
                || roleRank(actor.role()) > roleRank(assignment.assignedByRole()));
    }

    private int roleRank(String role) {
        if ("ADMIN".equals(role)) return 4;
        if ("HR".equals(role)) return 3;
        if ("MANAGER".equals(role)) return 2;
        return 1;
    }
}
