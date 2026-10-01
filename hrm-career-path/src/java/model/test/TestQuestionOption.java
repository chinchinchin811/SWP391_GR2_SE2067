package model;

/**
 * Một lựa chọn của câu hỏi. Thuộc tính correct là null khi dữ liệu được gửi
 * cho người làm bài để không làm lộ đáp án.
 */
public record TestQuestionOption(int id, String text, Boolean correct) {
}
