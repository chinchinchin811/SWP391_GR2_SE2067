package model;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Một kết quả duy nhất cho mỗi assignment, giữ lại người chấm và thời điểm.
 */
public record TestEvaluation(int evaluatorId, BigDecimal score, String comment, Instant evaluatedAt) {

}
