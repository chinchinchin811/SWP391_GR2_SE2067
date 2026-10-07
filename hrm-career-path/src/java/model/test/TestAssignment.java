package model;

import java.time.Instant;

/**
 * Không tải byte file ở trang danh sách; file chỉ đọc qua endpoint có kiểm tra
 * quyền.
 */
public record TestAssignment(int id, int templateId, int assigneeId, String assigneeName,
        String assigneeRole,
        int assignedBy, String assignedByRole,
        String title, String testType, Instant startTime, Instant endTime,
        int durationMinutes, Instant startedAt,
        String status, Instant submittedAt, String content, String fileName,
        TestEvaluation evaluation, Integer contentId, String contentKind, String contentTitle,
        java.math.BigDecimal quizScore) {

    /** Hạn cá nhân không bao giờ vượt quá giờ đóng chung của đợt giao bài. */
    public Instant submissionDeadline() {
        if (startedAt == null) {
            return null;
        }
        Instant personalDeadline = startedAt.plusSeconds(durationMinutes * 60L);
        return personalDeadline.isBefore(endTime) ? personalDeadline : endTime;
    }

    public boolean timeExpired(Instant now) {
        Instant deadline = submissionDeadline();
        return "in_progress".equals(status) && deadline != null && !now.isBefore(deadline);
    }
}
