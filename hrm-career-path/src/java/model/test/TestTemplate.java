package model;

import java.time.Instant;

/**
 * Đề và lịch; nội dung bài nộp được lưu riêng trong TestAssignment.
 */
public record TestTemplate(int id, String title, String description, String type,
        Integer departmentId, int createdBy, String status, Instant startTime, Instant endTime,
        Integer defaultContentId) {

}
