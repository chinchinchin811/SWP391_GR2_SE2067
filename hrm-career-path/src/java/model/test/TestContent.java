package model;

/** Nội dung tái sử dụng: bộ trắc nghiệm hoặc câu hỏi tự luận; ready thì không sửa nữa. */
public record TestContent(int id, String title, String prompt, String kind, String type,
        Integer departmentId, String status) { }
