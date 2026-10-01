-- =======================================================
-- SQL Server Script: seed_data_sqlserver.sql
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB
-- Thư mục: database/seed_data/
-- Mô tả: Dữ liệu mẫu khởi tạo toàn bộ hệ thống (Roles, Departments, Positions, Job_Levels, Users, History, Flashcards, Learning Materials, Classes, Enrollments, Progress)
-- =======================================================

USE HRM_Project_DB;
GO

-- =======================================================
-- 1. SEED DATA: BẢNG PHÂN QUYỀN (ROLES)
-- =======================================================
INSERT INTO dbo.Roles (role_name, description) VALUES
('ADMIN', N'Quản trị viên hệ thống'),
('HR', N'Nhân sự quản lý phòng ban, vị trí và nhân viên'),
('MANAGER', N'Trưởng phòng quản lý nhân viên trong phòng ban của mình'),
('EMPLOYEE', N'Nhân viên công ty'),
('MENTOR', N'Người hướng dẫn và đánh giá nhân viên mới');
GO

-- =======================================================
-- 2. SEED DATA: BẢNG CẤP BẬC (JOB_LEVELS)
-- =======================================================
INSERT INTO dbo.Job_Levels (level_name, rank_order, description) VALUES
(N'Intern', 1, N'Thực tập sinh'),
(N'Fresher', 2, N'Nhân viên mới vào nghề'),
(N'Junior', 3, N'Nhân viên có từ 1 - 2 năm kinh nghiệm'),
(N'Middle', 4, N'Nhân viên từ 2 - 4 năm kinh nghiệm'),
(N'Senior', 5, N'Chuyên viên từ 4+ năm kinh nghiệm'),
(N'Lead', 6, N'Trưởng nhóm chuyên môn');
GO

-- =======================================================
-- 3. SEED DATA: BẢNG PHÒNG BAN (DEPARTMENTS)
-- =======================================================
INSERT INTO dbo.Departments (department_name, description, status, is_deleted) VALUES
(N'Phòng Kỹ Thuật (IT)', N'Phát triển và vận hành hệ thống', 1, 0),
(N'Phòng Nhân Sự (HR)', N'Tuyển dụng và quản lý nhân sự', 1, 0),
(N'Phòng Kinh Doanh (Sales)', N'Kinh doanh và chăm sóc khách hàng', 1, 0);
GO

-- =======================================================
-- 4. SEED DATA: BẢNG VỊ TRÍ CÔNG VIỆC (POSITIONS)
-- =======================================================
INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted) VALUES
(N'Java Developer', 1, N'Lập trình viên Java backend', 1, 0),
(N'Frontend Developer', 1, N'Lập trình viên giao diện web', 1, 0),
(N'QA Tester', 1, N'Kiểm thử phần mềm', 1, 0),
(N'HR Officer', 2, N'Chuyên viên nhân sự', 1, 0),
(N'Sales Executive', 3, N'Chuyên viên kinh doanh', 1, 0);
GO

-- =======================================================
-- 5. SEED DATA: BẢNG TÀI KHOẢN NGƯỜI DÙNG (USERS)
-- =======================================================
INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted) VALUES
('admin', '123', N'Quản Trị Viên', 'admin@hrm.com', '0901000001', N'Nam', 1, 1, 1, 6, '2022-01-01', 1, 0),
('hr_manager', '123', N'Phạm Thu Hà', 'ha.pt@hrm.com', '0901000002', N'Nữ', 2, 2, 4, 5, '2022-03-15', 1, 0),
('manager_it', '123', N'Trần Văn Minh', 'minh.tv@hrm.com', '0901000003', N'Nam', 3, 1, 1, 6, '2022-02-01', 1, 0),
('dev_fresher', '123', N'Phạm Đức Trọng', 'trong.pd@hrm.com', '0901000006', N'Nam', 4, 1, 1, 2, '2026-08-01', 1, 0),
('dev_tester', '123', N'Ngô Mai Phương', 'phuong.nm@hrm.com', '0901000007', N'Nữ', 4, 1, 3, 3, '2023-06-01', 1, 0),
('mentor_java', '123', N'Lê Hữu Mentor', 'mentor.java@hrm.com', '0988888888', N'Nam', 5, 1, 1, 5, '2021-01-01', 1, 0);
GO

-- Cập nhật Trưởng phòng cho các phòng ban
UPDATE dbo.Departments SET manager_id = 3 WHERE department_id = 1;
UPDATE dbo.Departments SET manager_id = 2 WHERE department_id = 2;
GO

-- =======================================================
-- 6. SEED DATA: LỊCH SỬ BIẾN ĐỘNG (EMPLOYEE_HISTORY)
-- =======================================================
INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) VALUES
(4, NULL, 1, NULL, 1, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyển dụng mới vị trí Java Developer', 2);
GO

-- =======================================================
-- 7. SEED DATA: FLASHCARDS HỌC TẬP
-- =======================================================
INSERT INTO dbo.FlashcardDecks (title, description) VALUES
(N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa công ty'),
(N'Chuyên môn Java Backend', N'Kiến thức chuyên môn lập trình Java');
GO

INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
(1, N'Giờ làm việc kết thúc lúc mấy giờ?', N'17:30 hàng ngày.'),
(1, N'Thành viên mới cần làm gì trong ngày đầu tiên?', N'Hoàn tất thủ tục onboarding, làm quen với team, tài khoản hệ thống và nội quy công ty.'),
(1, N'Nhân viên cần báo trước bao nhiêu ngày khi xin nghỉ phép?', N'Thực hiện theo quy định nghỉ phép của công ty và thông báo cho quản lý trước thời gian nghỉ.'),
(1, N'Khi gặp vấn đề trong công việc, nhân viên nên làm gì?', N'Chủ động trao đổi với Leader, Manager hoặc người hướng dẫn để được hỗ trợ.'),
(1, N'Onboarding là gì?', N'Là quá trình giúp nhân viên mới làm quen với công ty, công việc, văn hóa và quy trình làm việc.'),
(1, N'Mục đích của việc onboarding nhân viên mới là gì?', N'Giúp nhân viên nhanh chóng hòa nhập, hiểu công việc và có thể làm việc hiệu quả.'),
(1, N'Nhân viên có cần bảo mật thông tin công ty không?', N'Có. Nhân viên phải bảo mật thông tin nội bộ, thông tin khách hàng và dữ liệu của công ty.'),
(1, N'Khi đến muộn, nhân viên nên làm gì?', N'Thông báo cho quản lý hoặc người phụ trách và tuân thủ quy định chấm công của công ty.'),
(1, N'Tại sao cần tham gia các buổi training của công ty?', N'Để cập nhật kiến thức, quy trình, kỹ năng và các quy định cần thiết cho công việc.'),
(1, N'Nhân viên mới có thể hỏi ai khi không hiểu công việc?', N'Có thể hỏi Mentor, Team Leader, Manager hoặc đồng nghiệp phù hợp.');
GO

INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
(2, N'Java là gì?', N'Java là một ngôn ngữ lập trình hướng đối tượng, được sử dụng phổ biến để phát triển ứng dụng web, desktop và backend.'),
(2, N'OOP có mấy tính chất cơ bản?', N'4 tính chất: Đóng gói, Kế thừa, Đa hình và Trừu tượng.'),
(2, N'Class trong Java là gì?', N'Class là một khuôn mẫu dùng để định nghĩa thuộc tính và hành vi của object.'),
(2, N'Object trong Java là gì?', N'Object là một thể hiện cụ thể được tạo ra từ một class.'),
(2, N'Tính đóng gói trong OOP là gì?', N'Là việc đóng gói dữ liệu và các phương thức liên quan trong một class và kiểm soát quyền truy cập.'),
(2, N'Tính kế thừa trong OOP là gì?', N'Là cơ chế cho phép một class con kế thừa thuộc tính và phương thức từ class cha.'),
(2, N'Tính đa hình trong OOP là gì?', N'Là khả năng cùng một phương thức có thể có cách thực hiện khác nhau tùy theo object.'),
(2, N'Tính trừu tượng trong OOP là gì?', N'Là việc ẩn đi các chi tiết cài đặt và chỉ hiển thị những thông tin cần thiết cho người sử dụng.'),
(2, N'Constructor trong Java dùng để làm gì?', N'Dùng để khởi tạo object khi object được tạo ra.'),
(2, N'Interface trong Java là gì?', N'Interface là một tập hợp các phương thức mà class implement cần cung cấp phần cài đặt.'),
(2, N'Exception trong Java là gì?', N'Exception là lỗi xảy ra trong quá trình chương trình đang thực thi.'),
(2, N'Try-catch trong Java dùng để làm gì?', N'Dùng để xử lý exception và tránh làm chương trình kết thúc đột ngột.'),
(2, N'ArrayList trong Java là gì?', N'ArrayList là một collection có thể lưu trữ nhiều phần tử và có kích thước có thể thay đổi.'),
(2, N'Git dùng để làm gì?', N'Git là hệ thống quản lý phiên bản giúp theo dõi, lưu trữ và quản lý các thay đổi của source code.'),
(2, N'API là gì?', N'API là giao diện cho phép các ứng dụng hoặc hệ thống giao tiếp và trao đổi dữ liệu với nhau.');
GO

-- =======================================================
-- 8. SEED DATA: KHO ĐỀ THI VĂN HÓA & CHUYÊN MÔN
-- Câu hỏi chỉ được nạp từ database, không tạo thủ công trên giao diện.
-- Hỗ trợ: đúng/sai, một đáp án, nhiều đáp án đúng và hơn 4 lựa chọn.
-- =======================================================
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @culture_creator_id INT = (SELECT TOP (1) user_id FROM dbo.Users WHERE username = 'hr_manager');
DECLARE @technical_creator_id INT = (SELECT TOP (1) user_id FROM dbo.Users WHERE username = 'manager_it');
DECLARE @technical_department_id INT = (
    SELECT TOP (1) department_id FROM dbo.Users
    WHERE username = 'manager_it' AND department_id IS NOT NULL
);

IF @culture_creator_id IS NULL OR @technical_creator_id IS NULL OR @technical_department_id IS NULL
    THROW 50001, N'Không tìm thấy tài khoản hoặc phòng ban để seed kho đề thi.', 1;

DECLARE @culture_content_id INT = (
    SELECT TOP (1) id FROM dbo.Test_Content
    WHERE title = N'Đề thi Văn hóa doanh nghiệp' AND type = 'culture' AND is_deleted = 0
);
IF @culture_content_id IS NULL
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,is_deleted)
    VALUES (N'Đề thi Văn hóa doanh nghiệp',
            N'Đánh giá kiến thức về bảo mật, giao tiếp, hợp tác và quy định làm việc.',
            'quiz','culture',NULL,@culture_creator_id,'ready',0);
    SET @culture_content_id = SCOPE_IDENTITY();
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Test_Questions WHERE content_id = @culture_content_id)
BEGIN
    DECLARE @question_id INT;

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Nhân viên được phép chia sẻ tài liệu nội bộ lên mạng xã hội nếu không ghi tên công ty.','true_false');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Đúng',0,1),(@question_id,N'Sai',1,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Chọn đúng 3 hành vi thể hiện cách làm việc chuyên nghiệp.','multiple');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Báo sớm cho quản lý khi có nguy cơ trễ tiến độ',1,1),
        (@question_id,N'Bảo mật dữ liệu khách hàng và dữ liệu nội bộ',1,2),
        (@question_id,N'Phản hồi dựa trên sự việc và hướng đến giải pháp',1,3),
        (@question_id,N'Chia sẻ mật khẩu cho đồng nghiệp để xử lý nhanh hơn',0,4),
        (@question_id,N'Bỏ qua quy trình phê duyệt khi công việc gấp',0,5),
        (@question_id,N'Đưa tài liệu công ty lên thiết bị công cộng',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Khi chưa hiểu một quy định nội bộ, lựa chọn phù hợp nhất là gì?','single');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Hỏi quản lý, HR hoặc người phụ trách để được hướng dẫn',1,1),
        (@question_id,N'Tự suy đoán rồi áp dụng cho cả nhóm',0,2),
        (@question_id,N'Bỏ qua quy định đó',0,3),
        (@question_id,N'Đợi đến khi có vi phạm mới tìm hiểu',0,4),
        (@question_id,N'Hỏi trên mạng xã hội công khai',0,5),
        (@question_id,N'Sao chép cách làm của một công ty khác',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Khi nhận email đáng ngờ yêu cầu cung cấp mật khẩu, nhân viên nên làm gì?','single');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Không cung cấp thông tin và báo bộ phận phụ trách',1,1),
        (@question_id,N'Nhập mật khẩu để kiểm tra liên kết',0,2),
        (@question_id,N'Chuyển tiếp email cho toàn công ty',0,3),
        (@question_id,N'Trả lời email bằng tài khoản cá nhân',0,4);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Nhân viên có thể gửi dữ liệu khách hàng qua email cá nhân nếu chỉ dùng trong công việc.','true_false');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Đúng',0,1),(@question_id,N'Sai',1,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Khi phát hiện nguy cơ mất an toàn thông tin, nhân viên cần ưu tiên hành động nào?','single');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Báo ngay cho quản lý hoặc bộ phận phụ trách an toàn thông tin',1,1),
        (@question_id,N'Tự xóa mọi dữ liệu liên quan rồi không báo cáo',0,2),
        (@question_id,N'Đăng sự việc lên mạng xã hội để cảnh báo',0,3),
        (@question_id,N'Chờ đến cuộc họp tuần mới thông báo',0,4),
        (@question_id,N'Gửi dữ liệu cho bạn bè kiểm tra',0,5),
        (@question_id,N'Bỏ qua nếu chưa thấy thiệt hại',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Chọn đúng 3 hành động giúp phối hợp nhóm hiệu quả.','multiple');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Cập nhật tiến độ và trở ngại một cách minh bạch',1,1),
        (@question_id,N'Lắng nghe và phản hồi ý kiến đồng đội với sự tôn trọng',1,2),
        (@question_id,N'Chủ động hỗ trợ khi thành viên khác cần giúp đỡ',1,3),
        (@question_id,N'Giữ riêng thông tin quan trọng để tạo lợi thế cá nhân',0,4),
        (@question_id,N'Đổ lỗi ngay khi có sự cố',0,5),
        (@question_id,N'Từ chối mọi góp ý trái quan điểm',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Khi có khả năng phát sinh xung đột lợi ích, nhân viên nên làm gì?','single');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Chủ động khai báo với quản lý hoặc HR để được hướng dẫn',1,1),
        (@question_id,N'Giữ kín vì đây là chuyện cá nhân',0,2),
        (@question_id,N'Tự quyết định mà không cần báo cáo',0,3),
        (@question_id,N'Nhờ đồng nghiệp che giấu thông tin',0,4);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Mọi hành vi quấy rối hoặc phân biệt đối xử tại nơi làm việc đều cần được phản ánh qua kênh phù hợp.','true_false');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Đúng',1,1),(@question_id,N'Sai',0,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@culture_content_id,N'Chọn đúng 3 dấu hiệu thường gặp của email lừa đảo.','multiple');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Địa chỉ người gửi bất thường hoặc gần giống tên miền thật',1,1),
        (@question_id,N'Yêu cầu cung cấp mật khẩu hoặc thông tin nhạy cảm',1,2),
        (@question_id,N'Tạo cảm giác khẩn cấp để buộc người nhận hành động ngay',1,3),
        (@question_id,N'Email được gửi qua kênh nội bộ đã xác minh',0,4),
        (@question_id,N'Nội dung đúng với công việc đã trao đổi trước đó',0,5),
        (@question_id,N'Có chữ ký chuẩn của công ty và không yêu cầu thao tác',0,6);
END;

DECLARE @technical_content_id INT = (
    SELECT TOP (1) id FROM dbo.Test_Content
    WHERE title = N'Đề thi Chuyên môn Java Backend' AND type = 'department'
      AND department_id = @technical_department_id AND is_deleted = 0
);
IF @technical_content_id IS NULL
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,is_deleted)
    VALUES (N'Đề thi Chuyên môn Java Backend',
            N'Đánh giá nền tảng Java, SQL, HTTP, Git và kiểm thử dành cho phòng Kỹ thuật.',
            'quiz','department',@technical_department_id,@technical_creator_id,'ready',0);
    SET @technical_content_id = SCOPE_IDENTITY();
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Test_Questions WHERE content_id = @technical_content_id)
BEGIN
    DECLARE @technical_question_id INT;

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'PreparedStatement với tham số ràng buộc giúp giảm nguy cơ SQL Injection.','true_false');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Đúng',1,1),(@technical_question_id,N'Sai',0,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Chọn đúng 3 thực hành tốt khi phát triển Java Backend.','multiple');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Dùng PreparedStatement cho dữ liệu đầu vào',1,1),
        (@technical_question_id,N'Đóng tài nguyên JDBC bằng try-with-resources',1,2),
        (@technical_question_id,N'Tách tầng controller, service và data access',1,3),
        (@technical_question_id,N'Ghi mật khẩu trực tiếp vào source code',0,4),
        (@technical_question_id,N'Nuốt mọi exception mà không ghi log',0,5),
        (@technical_question_id,N'Nối trực tiếp input người dùng vào câu SQL',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Mã trạng thái HTTP nào biểu thị tài nguyên được tạo thành công?','single');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'200 OK',0,1),
        (@technical_question_id,N'201 Created',1,2),
        (@technical_question_id,N'204 No Content',0,3),
        (@technical_question_id,N'400 Bad Request',0,4),
        (@technical_question_id,N'404 Not Found',0,5),
        (@technical_question_id,N'500 Internal Server Error',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Những đặc điểm nào đúng về một unit test tốt?','multiple');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Kiểm tra một hành vi nhỏ và xác định',1,1),
        (@technical_question_id,N'Có thể chạy độc lập và lặp lại',1,2),
        (@technical_question_id,N'Phụ thuộc trực tiếp vào dữ liệu production',0,3),
        (@technical_question_id,N'Luôn gọi dịch vụ bên ngoài thật',0,4),
        (@technical_question_id,N'Thất bại phải chỉ ra hành vi bị sai',1,5);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Toán tử == luôn là cách đúng để so sánh nội dung của hai String trong Java.','true_false');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Đúng',0,1),(@technical_question_id,N'Sai',1,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Try-with-resources trong Java được dùng chủ yếu để làm gì?','single');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Tự động đóng tài nguyên triển khai AutoCloseable',1,1),
        (@technical_question_id,N'Tạo nhiều thread cùng lúc',0,2),
        (@technical_question_id,N'Bỏ qua mọi exception',0,3),
        (@technical_question_id,N'Thay thế toàn bộ câu lệnh điều kiện',0,4),
        (@technical_question_id,N'Tự động commit mọi transaction',0,5),
        (@technical_question_id,N'Biên dịch Java thành JavaScript',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Chọn đúng 3 nguyên tắc phù hợp khi thiết kế REST API.','multiple');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Dùng danh từ để biểu diễn tài nguyên',1,1),
        (@technical_question_id,N'Dùng mã trạng thái HTTP phù hợp với kết quả',1,2),
        (@technical_question_id,N'Kiểm tra và xác thực dữ liệu đầu vào',1,3),
        (@technical_question_id,N'Luôn trả HTTP 200 cho mọi trường hợp',0,4),
        (@technical_question_id,N'Đưa mật khẩu và token vào URL',0,5),
        (@technical_question_id,N'Dùng một endpoint duy nhất cho mọi tài nguyên',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Khi một thao tác transaction gặp lỗi trước khi hoàn tất, hành động phù hợp là gì?','single');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Rollback transaction để khôi phục tính nhất quán',1,1),
        (@technical_question_id,N'Commit các thay đổi đã chạy được',0,2),
        (@technical_question_id,N'Bỏ qua lỗi và tiếp tục',0,3),
        (@technical_question_id,N'Xóa toàn bộ database',0,4),
        (@technical_question_id,N'Tắt kiểm tra khóa ngoại',0,5),
        (@technical_question_id,N'Chạy lại vô hạn không ghi log',0,6);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Git branch giúp phát triển thay đổi tách biệt trước khi hợp nhất.','true_false');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Đúng',1,1),(@technical_question_id,N'Sai',0,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Chọn đúng 3 kiểm tra quan trọng cho một API tạo tài nguyên.','multiple');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Yêu cầu hợp lệ tạo dữ liệu và trả kết quả thành công',1,1),
        (@technical_question_id,N'Dữ liệu đầu vào sai bị từ chối với thông báo phù hợp',1,2),
        (@technical_question_id,N'Người không có quyền không thể tạo tài nguyên',1,3),
        (@technical_question_id,N'API chấp nhận mọi dữ liệu mà không kiểm tra',0,4),
        (@technical_question_id,N'Test phụ thuộc vào thứ tự chạy ngẫu nhiên',0,5),
        (@technical_question_id,N'Test dùng trực tiếp database production',0,6);
END;

COMMIT;
GO

-- =======================================================
-- 9. SEED DATA: HỌC LIỆU & LỚP ĐÀO TẠO (LEARNING MATERIALS & TRAINING CLASSES)
-- =======================================================
INSERT INTO dbo.Learning_Materials 
(title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_size, video_url, duration_minutes, status, is_deleted, created_by, created_at, updated_at)
VALUES 
-- 1. Sổ tay văn hóa doanh nghiệp (CULTURE)
(N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty', 
 N'Tài liệu định hướng chuẩn mực dành cho toàn bộ nhân sự mới: Tầm nhìn sứ mệnh, 5 giá trị cốt lõi, tác phong làm việc chuyên nghiệp, nội quy lao động và chính sách phúc lợi.', 
 'PDF', 'CULTURE', NULL, NULL, NULL, 
 N'So_Tay_Van_Hoa_Doanh_Nghiep.pdf', 'application/pdf', 1048576, 'https://viethandvh.com/wp-content/uploads/2026/04/So-tay-van-hoa.pdf', 30, 1, 0, 2, '2026-09-28 08:24:23.550', '2026-09-28 08:24:23.550'),

-- 2. Slide đào tạo Agile/Scrum (DEPARTMENT IT)
(N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum', 
 N'Trình chiếu bài giảng chi tiết về quy trình vận hành Sprint, các buổi lễ Scrum (Planning, Daily Standup, Review, Retrospective), cách quản lý Task trên Jira và văn hóa phối hợp đội ngũ.', 
 'SLIDE', 'DEPARTMENT', 1, 1, 2, 
 N'Agile_Scrum_Onboarding.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 2097152, 'https://docs.google.com/presentation/d/1WX3Lvh6A8TqQBmbr4XyRN8SaWSsxIoQo/edit?rtpof=true', 45, 1, 0, 3, '2026-09-28 08:24:23.553', '2026-09-28 08:29:17.967'),

-- 3. Video kiến trúc Java Backend & Servlet Jakarta EE (DEPARTMENT IT)
(N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE', 
 N'Khóa học video cô đọng chuẩn kiến trúc phần mềm MVC, vòng đời Servlet, Bộ lọc Filter, quản lý Session và tương tác cơ sở dữ liệu qua JDBC Transaction trong dự án doanh nghiệp thực tế.', 
 'VIDEO', 'DEPARTMENT', 1, 1, 2, 
 NULL, 'video/mp4', NULL, 'https://www.youtube.com/watch?v=4wqMsmSEllA&t=532s', 25, 1, 0, 3, '2026-09-28 08:24:23.557', '2026-09-28 08:30:25.600'),

-- 4. Bộ tiêu chuẩn lập trình Java Clean Code (DEPARTMENT IT)
(N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)', 
 N'Tài liệu quy định chi tiết về cấu trúc mã nguồn, quy chuẩn đặt tên biến/hàm/lớp, nguyên tắc SOLID, kỹ thuật xử lý ngoại lệ và viết Unit Test theo chuẩn dự án doanh nghiệp.', 
 'PDF', 'DEPARTMENT', 1, 1, 2, 
 N'Java_Clean_Code_Conventions.pdf', 'application/pdf', 1258291, NULL, 40, 1, 0, 3, '2026-09-28 08:24:23.560', '2026-09-28 08:24:23.560'),

-- 5. Video giới thiệu văn hóa và tầm nhìn 2026 (CULTURE)
(N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026', 
 N'Thước phim truyền thông nội bộ giới thiệu lịch sử hình thành, đội ngũ ban điều hành, giá trị con người và định hướng phát triển bền vững của công ty trong năm 2026.', 
 'VIDEO', 'CULTURE', NULL, NULL, NULL, 
 NULL, 'video/mp4', NULL, 'https://www.youtube.com/watch?v=KRYONejN6SU', 15, 1, 0, 2, '2026-09-28 08:24:23.560', '2026-09-28 08:27:47.147'),

-- 6. Cẩm nang an toàn thông tin & bảo mật dữ liệu doanh nghiệp (CULTURE)
(N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp', 
 N'Hướng dẫn thực thi các tiêu chuẩn an toàn bảo mật thông tin nội bộ, nguyên tắc đặt mật khẩu định kỳ, bảo mật mã nguồn dự án và phòng ngừa tấn công lừa đảo qua mạng (Phishing).', 
 'PDF', 'CULTURE', NULL, NULL, NULL, 
 N'Cam_Nang_Quy_Chuan_An_Toan_Thong_Tin_Bao_Mat.pdf', 'application/pdf', 10518152, NULL, 20, 1, 0, 2, '2026-09-28 08:24:23.560', '2026-09-28 08:27:09.823');
GO

-- Checkpoint câu hỏi dừng tương tác cho Video Bài Giảng Java Backend
DECLARE @video_mat_id INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE');

IF @video_mat_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_mat_id, 45, 
     N'Theo mô hình kiến trúc MVC trong Jakarta EE, tầng nào trực tiếp nhận và điều phối HTTP Request từ phía người dùng?',
     N'Model (Java Bean / Entity)',
     N'Controller (Servlet)',
     N'View (JSP / JSTL)',
     N'DAL (Data Access Object)',
     1, 
     N'Chính xác! Servlet đóng vai trò Controller, trực tiếp đón nhận HTTP Request, xử lý điều phối và chuyển tiếp dữ liệu đến View.'),

    (@video_mat_id, 120, 
     N'Để đảm bảo tính toàn vẹn dữ liệu (ACID) khi thực hiện nhiều thao tác INSERT/UPDATE liên quan mật thiết với nhau, kỹ thuật nào bắt buộc phải áp dụng?',
     N'Bật chế độ tự động lưu (AutoCommit = true)',
     N'Chỉ dùng câu lệnh Statement thông thường',
     N'Quản lý giao dịch Database Transaction (setAutoCommit(false), commit() và rollback())',
     N'Bỏ qua việc bắt lỗi ngoại lệ SQLException',
     2, 
     N'Chính xác! Database Transaction bảo đảm tính nguyên tử (Atomicity) và nhất quán, rollback lại toàn bộ nếu có bất kỳ bước nào thất bại.'),

    (@video_mat_id, 240, 
     N'Để ngăn chặn triệt để lỗ hổng tấn công SQL Injection nguy hiểm trong ứng dụng Java Web, lập trình viên cần sử dụng đối tượng nào?',
     N'Statement và nối chuỗi trực tiếp (String concatenation)',
     N'PreparedStatement kết hợp cơ chế Parameterized Query',
     N'Đổi tên bảng trong cơ sở dữ liệu',
     N'Không cần xử lý nếu chỉ chạy trên môi trường nội bộ (localhost)',
     1, 
     N'Chính xác! PreparedStatement tự động xử lý ký tự đặc biệt và ngăn chặn kẻ tấn công chèn mã SQL độc hại.');
END;
GO

-- Checkpoint câu hỏi dừng tương tác cho Video Giới Thiệu Tầm Nhìn & Môi Trường Làm Việc
DECLARE @video_culture_id INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026');

IF @video_culture_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_culture_id, 30, 
     N'Đâu là khẩu hiệu (Slogan) hành động gắn liền với giá trị cốt lõi của công ty công nghệ chúng ta?',
     N'Tối ưu quy trình - Nâng tầm giải pháp công nghệ',
     N'Chấp nhận mọi rủi ro để tăng trưởng bằng mọi giá',
     N'Giữ nguyên hiện trạng, không thay đổi công nghệ cũ',
     N'Tập trung cá nhân, hạn chế tinh thần làm việc nhóm',
     0, 
     N'Chính xác! Công ty luôn hướng tới đổi mới sáng tạo, tối ưu giải pháp và hỗ trợ khách hàng bằng các công nghệ tiên tiến nhất.'),

    (@video_culture_id, 90, 
     N'Kênh liên lạc chính thức nào được ưu tiên để cập nhật thông báo nội bộ và trao đổi công việc hàng ngày?',
     N'Nhắn tin qua các hội nhóm mạng xã hội tự do',
     N'Hệ thống Email công vụ và phần mềm giao tiếp nội bộ đã được cấp quyền',
     N'Chỉ trao đổi truyền miệng không lưu vết',
     N'Gửi tài liệu mật qua các dịch vụ lưu trữ bên ngoài',
     1, 
     N'Chính xác! Mọi trao đổi và tài liệu dự án phải được thực hiện trên kênh chính thức để đảm bảo tính minh bạch và an toàn dữ liệu.');
END;
GO

-- Lớp đào tạo mẫu
INSERT INTO dbo.Training_Classes 
(class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
VALUES 
('CLS-IT-FRESHER-2026', 
 N'Khóa Đào Tạo Onboarding Kỹ Thuật Cho Fresher 2026', 
 N'Lớp đào tạo nền tảng kiến thức công nghệ, văn hóa làm việc và quy trình kỹ thuật dành cho các bạn Fresher/Junior mới gia nhập phòng IT.', 
 1, 1, 2, 3, CAST(GETDATE() AS DATE), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'OPEN', 2);
GO

-- Gắn học liệu chuẩn công nghệ vào lớp đào tạo
DECLARE @class_id INT = (SELECT TOP 1 class_id FROM dbo.Training_Classes WHERE class_code = 'CLS-IT-FRESHER-2026');
DECLARE @id_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty');
DECLARE @id_video_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026');
DECLARE @id_security INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp');
DECLARE @id_agile INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum');
DECLARE @id_cleancode INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)');
DECLARE @id_backend INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE');

IF @class_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_id, @id_culture, 1, 1),
    (@class_id, @id_video_culture, 2, 1),
    (@class_id, @id_security, 3, 1),
    (@class_id, @id_agile, 4, 1),
    (@class_id, @id_cleancode, 5, 1),
    (@class_id, @id_backend, 6, 1);
END;
GO

-- Ghi danh học viên Fresher vào lớp đào tạo và tạo tiến độ mẫu
DECLARE @class_id INT = (SELECT TOP 1 class_id FROM dbo.Training_Classes WHERE class_code = 'CLS-IT-FRESHER-2026');
IF @class_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Class_Enrollments (class_id, user_id, enrolled_by, enrollment_type, assigned_reason, status, progress_percent)
    VALUES (@class_id, 4, 3, 'SMART_ASSIGN', N'Phân bổ tự động theo lộ trình vị trí Fresher Java Developer', 'IN_PROGRESS', 33);

    DECLARE @id_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty');
    DECLARE @id_video_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026');
    DECLARE @id_security INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp');

    IF @id_culture IS NOT NULL
        INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
        VALUES (4, @id_culture, @class_id, 'COMPLETED', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), N'Đã đọc xong sổ tay văn hóa doanh nghiệp');

    IF @id_video_culture IS NOT NULL
        INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
        VALUES (4, @id_video_culture, @class_id, 'COMPLETED', DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), N'Đã xem xong video giới thiệu và hoàn thành câu hỏi tương tác');

    IF @id_security IS NOT NULL
        INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
        VALUES (4, @id_security, @class_id, 'IN_PROGRESS', GETDATE(), NULL, N'Đang nghiên cứu cẩm nang an toàn thông tin & bảo mật');
END;
GO

-- =======================================================
-- 10. KIỂM TRA DỮ LIỆU ĐÃ NẠP: SELECT * FROM TẤT CẢ CÁC BẢNG
-- =======================================================
SELECT * FROM dbo.Roles;
SELECT * FROM dbo.Job_Levels;
SELECT * FROM dbo.Departments;
SELECT * FROM dbo.Positions;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Employee_History;
SELECT * FROM dbo.FlashcardDecks;
SELECT * FROM dbo.Flashcards;
SELECT * FROM dbo.Learning_Materials;
SELECT * FROM dbo.Training_Classes;
SELECT * FROM dbo.Class_Materials;
SELECT * FROM dbo.Class_Enrollments;
SELECT * FROM dbo.Learning_Progress;
SELECT * FROM dbo.Video_Checkpoints;
SELECT * FROM dbo.Test_Content;
SELECT * FROM dbo.Test_Questions;
SELECT * FROM dbo.Test_Question_Options;
GO
