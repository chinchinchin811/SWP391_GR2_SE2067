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

    /**
     * Quyền quản lý không dựa riêng vào người tạo; mất phòng quản lý là mất
     * quyền.
     */
    public boolean canManage(TestActor actor, TestTemplate t) {
        return "culture".equals(t.type()) ? actor.cultureManager()
                : actor.departmentManager() && Objects.equals(actor.managedDepartmentId(), t.departmentId());
    }

    /**
     * Đề nháp chỉ người quản lý xem; đề công bố/đóng hiển thị theo loại và
     * phòng.
     */
    public boolean canView(TestActor actor, TestTemplate t) {
        boolean scope = "culture".equals(t.type()) || (actor.departmentId() != null
                && actor.departmentId().equals(t.departmentId()));
        return scope && (!"draft".equals(t.status()) || canManage(actor, t));
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
        return canViewAssignment(actor, a, t) && canManage(actor, t)
                && "submitted".equals(a.status());
    }

    /**
     * Khoảng làm bài là [start, end); đúng giờ kết thúc thì không nhận bài mới.
     */
    public boolean canSubmit(TestActor actor, TestAssignment a, TestTemplate t, Instant now) {
        return a.assigneeId() == actor.id() && canView(actor, t) && "published".equals(t.status())
                && !now.isBefore(t.startTime()) && now.isBefore(t.endTime())
                && ("pending".equals(a.status()) || "in_progress".equals(a.status()));
    }
}
