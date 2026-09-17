package service;

/** Lỗi nghiệp vụ có mã HTTP; không đưa SQL hoặc chi tiết nội bộ ra trình duyệt. */
public class TestException extends RuntimeException {
    private final int status;
    public TestException(int status, String message) { super(message); this.status = status; }
    public int status() { return status; }
}
