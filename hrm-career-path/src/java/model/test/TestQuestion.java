package model;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Câu hỏi lấy từ database với số lựa chọn linh hoạt. Cờ đáp án đúng trong từng
 * lựa chọn luôn null khi trả cho người làm bài.
 */
public record TestQuestion(int id, String prompt, String type, List<TestQuestionOption> options) {

    public TestQuestion {
        options = List.copyOf(options);
    }

    public boolean multipleChoice() {
        return "multiple".equals(type);
    }

    public Set<Integer> correctOptionIds() {
        return options.stream()
                .filter(option -> Boolean.TRUE.equals(option.correct()))
                .map(TestQuestionOption::id)
                .collect(Collectors.toUnmodifiableSet());
    }
}
