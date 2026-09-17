package model;

import java.util.List;

/**
 * correctOption luôn null khi trả cho người làm; đáp án đúng chỉ dùng ở
 * server/người quản lý.
 */
public record TestQuestion(int id, String prompt, List<String> options, Integer correctOption) {

}
