package model;

import java.time.Instant;

/**
 * Thông báo nhắc lịch riêng cho người được giao bài.
 */
public record TestNotification(int id, int assignmentId, String message, Instant createdAt, boolean read) {

}
