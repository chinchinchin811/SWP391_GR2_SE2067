package utils;

import java.time.*;
import java.time.format.DateTimeFormatter;

/** Helper hiển thị dữ liệu người dùng an toàn trong JSP, không chứa nghiệp vụ phân quyền. */
public final class TestView {
    private TestView() { }
    /** Escape cả nội dung văn bản và thuộc tính HTML để đề/bài nộp không chèn script. */
    public static String h(Object value) {
        if (value == null) return "";
        return value.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
    /** Hiển thị lịch UTC theo giờ Việt Nam, thống nhất với form nhập ngày giờ. */
    public static String time(Instant value) {
        return value == null ? "—" : DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
                .withZone(ZoneId.of("Asia/Ho_Chi_Minh")).format(value);
    }
    /** Nhãn trạng thái tiếng Việt, giữ giá trị kỹ thuật ở DB để kiểm tra state machine. */
    public static String status(String value) {
        switch (value) {
            case "draft": return "Bản nháp";
            case "published": return "Đã công bố";
            case "closed": return "Đã đóng";
            case "pending": return "Chưa bắt đầu";
            case "in_progress": return "Đang làm";
            case "submitted": return "Đã nộp";
            case "evaluated": return "Đã chấm";
            default: return value;
        }
    }
}
