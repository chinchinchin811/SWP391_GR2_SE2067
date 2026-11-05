package model.Mentor;

import java.io.Serializable;

/**
 * Các bộ tiêu chí đánh giá Mentee:
 * - 5 câu hỏi đánh giá công khai (Mentee có thể xem được)
 * - 5 câu hỏi đánh giá nội bộ (Chỉ Mentor, HR, và Manager xem được)
 */
public class EvaluationCriteria implements Serializable {

    public static class Option implements Serializable {
        private final String code;
        private final String label;
        private final String description;
        private final double score; // Thang điểm thành phần (cho câu hỏi công khai: 0.8 đến 2.0đ)

        public Option(String code, String label, String description, double score) {
            this.code = code;
            this.label = label;
            this.description = description;
            this.score = score;
        }

        public String getCode() { return code; }
        public String getLabel() { return label; }
        public String getDescription() { return description; }
        public double getScore() { return score; }
    }

    public static class Question implements Serializable {
        private final String code;
        private final String title;
        private final Option[] options;

        public Question(String code, String title, Option[] options) {
            this.code = code;
            this.title = title;
            this.options = options;
        }

        public String getCode() { return code; }
        public String getTitle() { return title; }
        public Option[] getOptions() { return options; }

        public Option findOption(String optCode) {
            if (optCode == null || optCode.trim().isEmpty()) return null;
            for (Option opt : options) {
                if (opt.getCode().equalsIgnoreCase(optCode.trim())) {
                    return opt;
                }
            }
            return null;
        }
    }

    // 5 câu hỏi công khai dành cho Mentee (Tổng điểm tối đa: 10 điểm)
    public static final Question[] PUBLIC_QUESTIONS = new Question[] {
        new Question(
            "pub_1",
            "1. Tiến độ và mức độ hoàn thành nhiệm vụ được giao",
            new Option[] {
                new Option("A", "Xuất sắc", "Luôn hoàn thành trước hạn, chủ động nhận thêm nhiệm vụ mới và tối ưu kế hoạch.", 2.0),
                new Option("B", "Tốt", "Hoàn thành công việc đúng hạn, bám sát các mốc tiến độ đề ra.", 1.6),
                new Option("C", "Đạt yêu cầu", "Cơ bản hoàn thành đúng hạn, thỉnh thoảng cần mentor nhắc nhở, đôn đốc.", 1.2),
                new Option("D", "Cần cải thiện", "Thường xuyên trễ hạn hoặc bàn giao chậm, ảnh hưởng tiến độ chung.", 0.8)
            }
        ),
        new Question(
            "pub_2",
            "2. Chất lượng kết quả công việc và kỹ năng chuyên môn",
            new Option[] {
                new Option("A", "Xuất sắc", "Sản phẩm đạt độ chính xác cao, chuẩn mực, tối ưu tốt, gần như không có lỗi sai.", 2.0),
                new Option("B", "Tốt", "Nắm vững chuyên môn, đáp ứng đầy đủ tiêu chuẩn kỹ thuật được phân công.", 1.6),
                new Option("C", "Đạt yêu cầu", "Chất lượng chấp nhận được, còn một vài lỗi nhỏ đã tự tiếp thu và sửa chữa.", 1.2),
                new Option("D", "Cần cải thiện", "Nhiều sai sót kỹ thuật cơ bản, kết quả chưa đạt yêu cầu bàn giao.", 0.8)
            }
        ),
        new Question(
            "pub_3",
            "3. Khả năng tiếp thu kiến thức và tinh thần chủ động tự học",
            new Option[] {
                new Option("A", "Xuất sắc", "Nắm bắt công nghệ mới cực nhanh, chủ động nghiên cứu và áp dụng sáng tạo.", 2.0),
                new Option("B", "Tốt", "Tiếp thu nhanh kiến thức mới, tích cực tìm tòi tài liệu học tập bổ sung.", 1.6),
                new Option("C", "Đạt yêu cầu", "Tiếp thu mức độ trung bình, cần mentor giải thích và hướng dẫn trực tiếp nhiều lần.", 1.2),
                new Option("D", "Cần cải thiện", "Thụ động, chậm tiếp thu kiến thức, ít có ý thức tự học hỏi thêm.", 0.8)
            }
        ),
        new Question(
            "pub_4",
            "4. Kỹ năng giao tiếp, làm việc nhóm và phối hợp công việc",
            new Option[] {
                new Option("A", "Xuất sắc", "Giao tiếp rõ ràng, hòa đồng, tích cực hỗ trợ và gắn kết đồng đội trong lớp.", 2.0),
                new Option("B", "Tốt", "Phối hợp nhịp nhàng, thông tin kịp thời với mentor và các thành viên khác.", 1.6),
                new Option("C", "Đạt yêu cầu", "Tương tác cơ bản khi được yêu cầu, còn thiếu sự chủ động trao đổi công việc.", 1.2),
                new Option("D", "Cần cải thiện", "Ngại giao tiếp, phối hợp rời rạc, gây khó khăn cho tiến độ làm việc nhóm.", 0.8)
            }
        ),
        new Question(
            "pub_5",
            "5. Ý thức kỷ luật, chuyên cần và thái độ với công việc",
            new Option[] {
                new Option("A", "Xuất sắc", "Tinh thần trách nhiệm cao, tác phong gương mẫu, tuyệt đối chấp hành nội quy.", 2.0),
                new Option("B", "Tốt", "Chuyên cần, thái độ tích cực, tôn trọng quy định làm việc của tổ chức.", 1.6),
                new Option("C", "Đạt yêu cầu", "Đi làm và sinh hoạt đúng giờ, đôi khi cần nhắc nhở về tác phong công sở.", 1.2),
                new Option("D", "Cần cải thiện", "Thường vi phạm giờ giấc, thái độ làm việc chưa nghiêm túc hoặc thiếu trách nhiệm.", 0.8)
            }
        )
    };

    // 5 câu hỏi đánh giá nội bộ (Chỉ Mentor, HR, và Manager xem)
    public static final Question[] INTERNAL_QUESTIONS = new Question[] {
        new Question(
            "priv_1",
            "1. Mức độ hòa nhập và thích ứng văn hóa doanh nghiệp",
            new Option[] {
                new Option("A", "Rất cao", "Hòa nhập văn hóa doanh nghiệp rất nhanh, thể hiện rõ nét các giá trị cốt lõi công ty.", 0),
                new Option("B", "Tốt", "Thích nghi tốt với môi trường, có tinh thần gắn kết và tôn trọng văn hóa tổ chức.", 0),
                new Option("C", "Trung bình", "Cần thêm thời gian làm quen và hòa nhập sâu sắc hơn với tập thể phòng ban.", 0),
                new Option("D", "Kém", "Chưa hòa nhập được với môi trường làm việc và văn hóa ứng xử chung của công ty.", 0)
            }
        ),
        new Question(
            "priv_2",
            "2. Ý thức tuân thủ quy trình vận hành và bảo mật thông tin nội bộ",
            new Option[] {
                new Option("A", "Rất nghiêm túc", "Tuyệt đối tuân thủ chính sách bảo mật nội bộ và quy trình chuẩn của phòng ban.", 0),
                new Option("B", "Tốt", "Thực hiện đúng các quy định vận hành và hướng dẫn bảo mật dữ liệu.", 0),
                new Option("C", "Cơ bản", "Đôi lúc còn sơ suất về quy trình, đã kịp thời sửa đổi sau khi được nhắc nhở.", 0),
                new Option("D", "Chưa tốt", "Thiếu cẩn trọng trong bảo mật thông tin, nhiều lần vi phạm quy trình vận hành.", 0)
            }
        ),
        new Question(
            "priv_3",
            "3. Khả năng đón nhận phản hồi (Feedback) và tinh thần cải tiến",
            new Option[] {
                new Option("A", "Rất tích cực", "Thái độ cầu thị tuyệt vời, chủ động xin ý kiến góp ý và cải tiến rất nhanh.", 0),
                new Option("B", "Tốt", "Lắng nghe nghiêm túc phản hồi từ Mentor/Manager, có sự tiến bộ rõ nét.", 0),
                new Option("C", "Trung bình", "Lắng nghe nhưng chuyển biến còn chậm, chưa quyết liệt sửa đổi thiếu sót.", 0),
                new Option("D", "Kém", "Có phản ứng phòng thủ, thiếu tính xây dựng khi nhận góp ý đánh giá.", 0)
            }
        ),
        new Question(
            "priv_4",
            "4. Năng lực tư duy logic và giải quyết vấn đề độc lập (Problem Solving)",
            new Option[] {
                new Option("A", "Xuất sắc", "Tư duy logic sắc bén, chủ động tìm tòi phương án tối ưu trước khi tham vấn mentor.", 0),
                new Option("B", "Tốt", "Có khả năng phân tích và xử lý độc lập các bài toán kỹ thuật theo yêu cầu.", 0),
                new Option("C", "Cơ bản", "Xử lý được các tác vụ quen thuộc, gặp vấn đề mới phát sinh còn lúng túng.", 0),
                new Option("D", "Yếu", "Thiếu tư duy phản biện, ỷ lại và phụ thuộc gần như hoàn toàn vào mentor.", 0)
            }
        ),
        new Question(
            "priv_5",
            "5. Đánh giá tiềm năng và đề xuất nhân sự dài hạn (HR & Management)",
            new Option[] {
                new Option("A", "Đề xuất phát triển nòng cốt", "Tiềm năng phát triển vượt trội, đề xuất đưa vào diện bồi dưỡng nhân sự tài năng.", 0),
                new Option("B", "Đề xuất chuyển chính thức", "Đạt chuẩn yêu cầu, đề xuất ký hợp đồng lao động chính thức sau khóa đào tạo.", 0),
                new Option("C", "Cần theo dõi thêm", "Đạt mức trung bình, đề xuất gia hạn thử thách hoặc giao thêm dự án để đánh giá lại.", 0),
                new Option("D", "Không đề xuất giữ lại", "Năng lực hoặc thái độ không đáp ứng tiêu chuẩn của công ty, đề xuất kết thúc thử việc.", 0)
            }
        )
    };
}

