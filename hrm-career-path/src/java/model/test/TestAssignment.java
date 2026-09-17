package model;

import java.time.Instant;

/**
 * Không tải byte file ở trang danh sách; file chỉ đọc qua endpoint có kiểm tra
 * quyền.
 */
public record TestAssignment(int id, int templateId, int assigneeId, String assigneeName,
        String title, String status, Instant submittedAt, String content, String fileName,
        TestEvaluation evaluation, Integer contentId, String contentKind, String contentTitle,
        java.math.BigDecimal quizScore) {

}
