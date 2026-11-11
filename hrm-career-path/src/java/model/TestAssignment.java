package model;

import java.time.Instant;

/**
 * Thông tin bài được giao của người làm.
 */
public record TestAssignment(int id, int templateId, int assigneeId, String assigneeName,
        String assigneeRole,
        int assignedBy, String assignedByRole,
        String title, String testType, Instant startTime, Instant endTime,
        int durationMinutes, Instant startedAt,
        String status, Instant submittedAt,
        TestEvaluation evaluation, Integer contentId, String contentKind, String contentTitle,
        java.math.BigDecimal quizScore) {

    /**
     * Hạn nộp cá nhân tính riêng từ thời điểm nhân viên bấm bắt đầu làm bài
     * cộng với thời lượng làm bài (durationMinutes).
     */
    public Instant submissionDeadline() {
        if (startedAt == null) {
            return null;
        }
        return startedAt.plusSeconds(durationMinutes * 60L);
    }

    public boolean timeExpired(Instant now) {
        Instant deadline = submissionDeadline();
        return "in_progress".equals(status) && deadline != null && !now.isBefore(deadline);
    }
}
