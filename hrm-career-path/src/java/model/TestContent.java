package model;

/**
 * Nội dung tái sử dụng: bộ trắc nghiệm hoặc câu hỏi tự luận; ready thì không
 * sửa nữa.
 */
public record TestContent(int id, String title, String prompt, String kind, String type,
        Integer departmentId, int createdBy, String status, Integer learningMaterialId) {

    public TestContent(int id, String title, String prompt, String kind, String type,
            Integer departmentId, int createdBy, String status) {
        this(id, title, prompt, kind, type, departmentId, createdBy, status, null);
    }

}
