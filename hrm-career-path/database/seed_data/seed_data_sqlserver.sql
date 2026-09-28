-- =======================================================
-- SQL Server Script: seed_data_sqlserver.sql
-- Project: HRM & Career Path Management (SWP391 / SE2067)
-- Database: HRM_Project_DB
-- =======================================================

USE HRM_Project_DB;
GO

-- 1. BẢNG VAI TRÒ (ROLES)
INSERT INTO dbo.Roles (role_name, description) VALUES
('ADMIN', N'Quản trị viên hệ thống'),
('HR', N'Nhân sự quản lý phòng ban, vị trí và nhân viên'),
('MANAGER', N'Trưởng phòng quản lý nhân viên trong phòng ban của mình'),
('EMPLOYEE', N'Nhân viên công ty'),
('MENTOR', N'Người hướng dẫn và đánh giá nhân viên mới');
GO

-- 2. BẢNG CẤP BẬC / NGẠCH CÔNG VIỆC (JOB_LEVELS)
INSERT INTO dbo.Job_Levels (level_name, rank_order, description) VALUES
(N'Intern', 1, N'Thực tập sinh'),
(N'Fresher', 2, N'Nhân viên mới vào nghề'),
(N'Junior', 3, N'Nhân viên có từ 1 - 2 năm kinh nghiệm'),
(N'Middle', 4, N'Nhân viên từ 2 - 4 năm kinh nghiệm'),
(N'Senior', 5, N'Chuyên viên từ 4+ năm kinh nghiệm'),
(N'Lead', 6, N'Trưởng nhóm chuyên môn');
GO

-- 3. BẢNG PHÒNG BAN (DEPARTMENTS)
INSERT INTO dbo.Departments (department_name, description, status, is_deleted) VALUES
(N'Phòng Kỹ Thuật (IT)', N'Phát triển và vận hành hệ thống phần mềm', 1, 0),
(N'Phòng Nhân Sự (HR)', N'Tuyển dụng, đào tạo và quản lý nhân sự', 1, 0),
(N'Phòng Kinh Doanh (Sales)', N'Kinh doanh và chăm sóc khách hàng doanh nghiệp', 1, 0);
GO

-- 4. BẢNG VỊ TRÍ CÔNG VIỆC (POSITIONS)
INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted) VALUES
(N'Java Developer', 1, N'Lập trình viên Java Backend', 1, 0),
(N'Frontend Developer', 1, N'Lập trình viên giao diện Web Frontend', 1, 0),
(N'QA Tester', 1, N'Kiểm thử chất lượng phần mềm (QA/QC)', 1, 0),
(N'HR Officer', 2, N'Chuyên viên nhân sự & Đào tạo', 1, 0),
(N'Sales Executive', 3, N'Chuyên viên phát triển kinh doanh', 1, 0);
GO

-- 5. BẢNG TÀI KHOẢN NGƯỜI DÙNG (USERS)
INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted) VALUES
('admin', '123', N'Quản Trị Viên', 'admin@hrm.com', '0901000001', N'Nam', 1, 1, 1, 6, '2022-01-01', 1, 0),
('hr_manager', '123', N'Phạm Thu Hà', 'ha.pt@hrm.com', '0901000002', N'Nữ', 2, 2, 4, 5, '2022-03-15', 1, 0),
('manager_it', '123', N'Trần Văn Minh', 'minh.tv@hrm.com', '0901000003', N'Nam', 3, 1, 1, 6, '2022-02-01', 1, 0),
('dev_fresher', '123', N'Phạm Đức Trọng', 'trong.pd@hrm.com', '0901000006', N'Nam', 4, 1, 1, 2, '2026-08-01', 1, 0),
('dev_tester', '123', N'Ngô Mai Phương', 'phuong.nm@hrm.com', '0901000007', N'Nữ', 4, 1, 3, 3, '2023-06-01', 1, 0),
('mentor_java', '123', N'Lê Hữu Mentor', 'mentor.java@hrm.com', '0988888888', N'Nam', 5, 1, 1, 5, '2021-01-01', 1, 0);
GO

-- Cập nhật vai trò Trưởng phòng
UPDATE dbo.Departments SET manager_id = 3 WHERE department_id = 1;
UPDATE dbo.Departments SET manager_id = 2 WHERE department_id = 2;
GO

-- 6. BẢNG LỊCH SỬ ĐIỀU CHUYỂN (EMPLOYEE_HISTORY)
INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) VALUES
(4, NULL, 1, NULL, 1, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyển dụng mới vị trí Java Developer (Fresher)', 2);
GO

-- =======================================================
-- 7. SEED DATA: HỌC LIỆU (LEARNING MATERIALS) & ĐÀO TẠO
-- =======================================================

-- Xóa dữ liệu mẫu cũ không dấu nếu tồn tại trước đó để cập nhật đồng bộ
IF EXISTS (SELECT 1 FROM dbo.Learning_Materials WHERE title = N'So Tay Van Hoa & Quy Dinh Cong Ty')
BEGIN
    DELETE FROM dbo.Video_Question_Answers;
    DELETE FROM dbo.Learning_Progress;
    DELETE FROM dbo.Class_Enrollments;
    DELETE FROM dbo.Class_Materials;
    DELETE FROM dbo.Video_Checkpoints;
    DELETE FROM dbo.Training_Classes;
    DELETE FROM dbo.Learning_Materials;
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty')
BEGIN
    -- 7.1. HỌC LIỆU VĂN HÓA DOANH NGHIỆP (CULTURE) - Dành cho toàn bộ nhân sự
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_data, file_size, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty', 
     N'Tài liệu định hướng chuẩn mực dành cho toàn bộ nhân sự mới: Tầm nhìn sứ mệnh, 5 giá trị cốt lõi, tác phong làm việc chuyên nghiệp, nội quy lao động và chính sách phúc lợi.', 
     'PDF', 'CULTURE', NULL, NULL, NULL, 'So_Tay_Van_Hoa_Doanh_Nghiep.pdf', 'application/pdf', 
     CONVERT(VARBINARY(MAX), '%PDF-1.4 Mock Content - So Tay Van Hoa Doanh Nghiep'), 1048576, NULL, 30, 1, 2);

    -- 7.2. HỌC LIỆU SLIDE QUY TRÌNH AGILE/SCRUM (DEPARTMENT - IT)
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_data, file_size, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum', 
     N'Trình chiếu bài giảng chi tiết về quy trình vận hành Sprint, các buổi lễ Scrum (Planning, Daily Standup, Review, Retrospective), cách quản lý Task trên Jira và văn hóa phối hợp đội ngũ.', 
     'SLIDE', 'DEPARTMENT', 1, 1, 2, 'Agile_Scrum_Onboarding.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 
     CONVERT(VARBINARY(MAX), 'Mock Presentation Content - Agile Scrum Onboarding'), 2097152, 
     'https://docs.google.com/presentation/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/embed', 45, 1, 3);

    -- 7.3. HỌC LIỆU VIDEO BÀI GIẢNG JAVA BACKEND (DEPARTMENT - IT)
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_data, file_size, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE', 
     N'Khóa học video cô đọng chuẩn kiến trúc phần mềm MVC, vòng đời Servlet, Bộ lọc Filter, quản lý Session và tương tác cơ sở dữ liệu qua JDBC Transaction trong dự án doanh nghiệp thực tế.', 
     'VIDEO', 'DEPARTMENT', 1, 1, 2, NULL, 'video/mp4', NULL, NULL, 'https://www.youtube.com/watch?v=kYJzphqI3qA', 25, 1, 3);

    DECLARE @video_java_id INT = SCOPE_IDENTITY();

    -- Checkpoints cho Video Java Backend
    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_java_id, 45, 
     N'Theo mô hình kiến trúc MVC trong Jakarta EE, tầng nào trực tiếp nhận và điều phối HTTP Request từ phía người dùng?',
     N'Model (Java Bean / Entity)',
     N'Controller (Servlet)',
     N'View (Trang JSP / HTML)',
     N'DAL (Data Access Layer / DAO)',
     1, 
     N'Chính xác! Servlet đóng vai trò Controller trong mô hình MVC, chịu trách nhiệm đón nhận request, kiểm tra dữ liệu và phân phối điều hướng tới Service hoặc View.');

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_java_id, 120, 
     N'Để đảm bảo tính toàn vẹn dữ liệu (ACID) khi thực hiện nhiều thao tác INSERT/UPDATE liên quan mật thiết với nhau, kỹ thuật nào bắt buộc phải áp dụng?',
     N'Bật AutoCommit = true',
     N'Sử dụng Statement thuần thay vì PreparedStatement',
     N'Quản lý Database Transaction qua Connection (setAutoCommit(false), commit(), rollback())',
     N'Bỏ qua việc bắt ngoại lệ SQLException',
     2, 
     N'Chính xác! Database Transaction đảm bảo nguyên tắc tất cả cùng thành công hoặc khôi phục dữ liệu ban đầu nếu xảy ra lỗi (Atomicity).');

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_java_id, 240, 
     N'Để ngăn chặn triệt để lỗ hổng tấn công SQL Injection nguy hiểm trong ứng dụng Java Web, lập trình viên cần sử dụng đối tượng nào?',
     N'Statement với chuỗi ghép dấu cộng (+)',
     N'PreparedStatement kết hợp truyền tham số qua dấu hỏi chấm (?)',
     N'CallableStatement không tham số',
     N'Thực thi câu lệnh SQL trực tiếp từ chuỗi do người dùng nhập',
     1, 
     N'Chính xác! PreparedStatement tự động tiền biên dịch và escape các ký tự đặc biệt, loại bỏ hoàn toàn rủi ro SQL Injection.');

    -- 7.4. HỌC LIỆU AN TOÀN THÔNG TIN (CULTURE) - Dành cho toàn công ty
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_data, file_size, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp', 
     N'Hướng dẫn thực thi các tiêu chuẩn an toàn bảo mật thông tin nội bộ, nguyên tắc đặt mật khẩu định kỳ, bảo mật mã nguồn dự án và phòng ngừa tấn công lừa đảo qua mạng (Phishing).', 
     'PDF', 'CULTURE', NULL, NULL, NULL, 'Cam_Nang_An_Toan_Thong_Tin.pdf', 'application/pdf', 
     CONVERT(VARBINARY(MAX), '%PDF-1.4 Mock Content - An Toan Thong Tin'), 1572864, NULL, 20, 1, 2);

    -- 7.5. HỌC LIỆU VIDEO VĂN HÓA DOANH NGHIỆP & TẦM NHÌN (CULTURE)
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_data, file_size, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026', 
     N'Thước phim truyền thông nội bộ giới thiệu lịch sử hình thành, đội ngũ ban điều hành, giá trị con người và định hướng phát triển bền vững của công ty trong năm 2026.', 
     'VIDEO', 'CULTURE', NULL, NULL, NULL, NULL, 'video/mp4', NULL, NULL, 'https://www.youtube.com/watch?v=kYJzphqI3qA', 15, 1, 2);

    DECLARE @video_culture_id INT = SCOPE_IDENTITY();

    -- Checkpoints cho Video Văn Hóa
    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_culture_id, 30, 
     N'Đâu là khẩu hiệu (Slogan) hành động gắn liền với giá trị cốt lõi của công ty?',
     N'Đoàn kết - Tiên phong - Đột phá',
     N'Tận tâm - Chuyên nghiệp - Sáng tạo',
     N'Chính trực - Khát vọng - Vươn xa',
     N'Nhanh chóng - Đơn giản - Tiết kiệm',
     1, 
     N'Chính xác! "Tận tâm - Chuyên nghiệp - Sáng tạo" là kim chỉ nam cho mọi hoạt động của toàn thể đội ngũ nhân sự công ty.');

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_culture_id, 90, 
     N'Kênh liên lạc chính thức nào được ưu tiên để cập nhật thông báo nội bộ và trao đổi công việc hàng ngày?',
     N'Nhắn tin qua các hội nhóm mạng xã hội tự do',
     N'Hệ thống Email công vụ và phần mềm giao tiếp nội bộ đã được cấp quyền',
     N'Chỉ trao đổi truyền miệng không lưu vết',
     N'Gửi tài liệu mật qua các dịch vụ lưu trữ bên ngoài',
     1, 
     N'Chính xác! Mọi trao đổi và tài liệu dự án phải được thực hiện trên kênh chính thức để đảm bảo tính minh bạch và an toàn dữ liệu.');

    -- 7.6. HỌC LIỆU CLEAN CODE & CODING CONVENTIONS (DEPARTMENT - IT)
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_data, file_size, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)', 
     N'Tài liệu quy định chi tiết về cấu trúc mã nguồn, quy chuẩn đặt tên biến/hàm/lớp, nguyên tắc SOLID, kỹ thuật xử lý ngoại lệ và viết Unit Test theo chuẩn dự án doanh nghiệp.', 
     'PDF', 'DEPARTMENT', 1, 1, 2, 'Java_Clean_Code_Conventions.pdf', 'application/pdf', 
     CONVERT(VARBINARY(MAX), '%PDF-1.4 Mock Content - Clean Code Conventions'), 1258291, NULL, 40, 1, 3);

    -- Lấy ID các học liệu vừa tạo
    DECLARE @mat_culture_handbook_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty');
    DECLARE @mat_agile_slide_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum');
    DECLARE @mat_security_guide_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp');
    DECLARE @mat_clean_code_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)');

    -- -------------------------------------------------------------
    -- 7.7. TẠO CÁC LỚP ĐÀO TẠO (TRAINING_CLASSES)
    -- -------------------------------------------------------------
    -- LỚP 1: Onboarding Kỹ Thuật cho Fresher IT
    INSERT INTO dbo.Training_Classes 
    (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
    VALUES 
    ('CLS-IT-FRESHER-2026', 
     N'Khóa Đào Tạo Onboarding Kỹ Thuật Cho Fresher 2026', 
     N'Lớp đào tạo nền tảng kiến thức công nghệ, văn hóa làm việc và quy trình kỹ thuật chuẩn chỉnh dành riêng cho các bạn Fresher/Junior mới gia nhập phòng Kỹ Thuật IT.', 
     1, 1, 2, 6, CAST(GETDATE() AS DATE), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'IN_PROGRESS', 2);

    DECLARE @class_fresher_id INT = SCOPE_IDENTITY();

    -- Gắn học liệu vào Lớp 1
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_fresher_id, @mat_culture_handbook_id, 1, 1),
    (@class_fresher_id, @mat_agile_slide_id, 2, 1),
    (@class_fresher_id, @video_java_id, 3, 1),
    (@class_fresher_id, @mat_clean_code_id, 4, 1);

    -- LỚP 2: Đào tạo Văn hóa & Hội nhập chung (Toàn công ty)
    INSERT INTO dbo.Training_Classes 
    (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
    VALUES 
    ('CLS-CULTURE-ONBOARDING', 
     N'Chương Trình Hội Nhập & Văn Hóa Doanh Nghiệp Toàn Diện', 
     N'Chương trình đào tạo bắt buộc dành cho 100% nhân viên mới thuộc mọi phòng ban nhằm nắm bắt giá trị văn hóa, quy chế nội bộ và chính sách an toàn bảo mật.', 
     NULL, NULL, NULL, 2, DATEADD(DAY, -15, CAST(GETDATE() AS DATE)), DATEADD(DAY, 15, CAST(GETDATE() AS DATE)), 'IN_PROGRESS', 2);

    DECLARE @class_culture_id INT = SCOPE_IDENTITY();

    -- Gắn học liệu vào Lớp 2
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_culture_id, @mat_culture_handbook_id, 1, 1),
    (@class_culture_id, @video_culture_id, 2, 1),
    (@class_culture_id, @mat_security_guide_id, 3, 1);

    -- LỚP 3: Huấn luyện nâng cao Java Backend
    INSERT INTO dbo.Training_Classes 
    (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
    VALUES 
    ('CLS-JAVA-ADVANCED-2026', 
     N'Khóa Huấn Luyện Nâng Cao Kỹ Năng Lập Trình & Thiết Kế Kiến Trúc Backend', 
     N'Chương trình bồi dưỡng nâng cao kiến thức chuyên sâu về Clean Architecture, tối ưu hóa truy vấn Database và nâng cấp kỹ năng cho đội ngũ lập trình viên Java.', 
     1, 1, 3, 6, DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), DATEADD(DAY, 45, CAST(GETDATE() AS DATE)), 'OPEN', 3);

    DECLARE @class_advanced_id INT = SCOPE_IDENTITY();

    -- Gắn học liệu vào Lớp 3
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_advanced_id, @video_java_id, 1, 1),
    (@class_advanced_id, @mat_clean_code_id, 2, 1);

    -- -------------------------------------------------------------
    -- 7.8. GHI DANH HỌC VIÊN (CLASS_ENROLLMENTS)
    -- -------------------------------------------------------------
    -- Lớp Fresher: Ghi danh dev_fresher (user 4) và dev_tester (user 5)
    INSERT INTO dbo.Class_Enrollments 
    (class_id, user_id, enrolled_by, enrollment_type, assigned_reason, status, progress_percent, enrolled_at, completed_at)
    VALUES 
    (@class_fresher_id, 4, 2, 'SMART_ASSIGN', N'Gợi ý tự động: Đúng vị trí Java Developer và cấp bậc Fresher', 'IN_PROGRESS', 65, DATEADD(DAY, -5, GETDATE()), NULL),
    (@class_fresher_id, 5, 3, 'MANUAL', N'Phân công bổ sung: Nắm bắt kiến trúc hệ thống phục vụ kiểm thử QA', 'IN_PROGRESS', 40, DATEADD(DAY, -4, GETDATE()), NULL);

    -- Lớp Văn Hóa Onboarding: Ghi danh dev_fresher (đã hoàn thành) và dev_tester (đang học)
    INSERT INTO dbo.Class_Enrollments 
    (class_id, user_id, enrolled_by, enrollment_type, assigned_reason, status, progress_percent, enrolled_at, completed_at)
    VALUES 
    (@class_culture_id, 4, 2, 'SMART_ASSIGN', N'Nhân viên mới gia nhập công ty (Onboarding bắt buộc)', 'PASSED', 100, DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, -2, GETDATE())),
    (@class_culture_id, 5, 2, 'SMART_ASSIGN', N'Nhân viên mới gia nhập công ty (Onboarding bắt buộc)', 'IN_PROGRESS', 75, DATEADD(DAY, -12, GETDATE()), NULL);

    -- -------------------------------------------------------------
    -- 7.9. TIẾN ĐỘ HỌC TẬP TỪNG HỌC LIỆU (LEARNING_PROGRESS)
    -- -------------------------------------------------------------
    -- Tiến độ của dev_fresher (user 4)
    INSERT INTO dbo.Learning_Progress 
    (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
    VALUES 
    (4, @mat_culture_handbook_id, @class_culture_id, 'COMPLETED', DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -10, GETDATE()), N'Đã đọc kỹ và nắm vững toàn bộ nội quy công ty.'),
    (4, @video_culture_id, @class_culture_id, 'COMPLETED', DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, GETDATE()), N'Đã xem trọn vẹn video và trả lời đúng 100% câu hỏi.'),
    (4, @mat_security_guide_id, @class_culture_id, 'COMPLETED', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), N'Đã hoàn thành và kích hoạt bảo mật tài khoản.'),
    (4, @mat_agile_slide_id, @class_fresher_id, 'COMPLETED', DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, GETDATE()), N'Đã nắm rõ quy trình họp Daily và cách chia nhỏ User Story.'),
    (4, @video_java_id, @class_fresher_id, 'IN_PROGRESS', GETDATE(), NULL, N'Đang xem đến phần kiến trúc MVC và tương tác Transaction.');

    -- Tiến độ của dev_tester (user 5)
    INSERT INTO dbo.Learning_Progress 
    (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
    VALUES 
    (5, @mat_culture_handbook_id, @class_culture_id, 'COMPLETED', DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, -8, GETDATE()), N'Đã tiếp thu đầy đủ quy định công ty.'),
    (5, @video_culture_id, @class_culture_id, 'COMPLETED', DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -4, GETDATE()), N'Đã hoàn thành phần trả lời câu hỏi trắc nghiệm.'),
    (5, @mat_security_guide_id, @class_culture_id, 'IN_PROGRESS', GETDATE(), NULL, N'Đang nghiên cứu phần chính sách bảo vệ dữ liệu khách hàng.'),
    (5, @mat_agile_slide_id, @class_fresher_id, 'COMPLETED', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), N'Nắm vững vai trò QA trong quy trình Scrum.');

    -- -------------------------------------------------------------
    -- 7.10. KẾT QUẢ TRẢ LỜI CÂU HỎI TRẮC NGHIỆM VIDEO (VIDEO_QUESTION_ANSWERS)
    -- -------------------------------------------------------------
    DECLARE @cp_java_45 INT = (SELECT checkpoint_id FROM dbo.Video_Checkpoints WHERE material_id = @video_java_id AND stop_time_seconds = 45);
    DECLARE @cp_java_120 INT = (SELECT checkpoint_id FROM dbo.Video_Checkpoints WHERE material_id = @video_java_id AND stop_time_seconds = 120);
    DECLARE @cp_culture_30 INT = (SELECT checkpoint_id FROM dbo.Video_Checkpoints WHERE material_id = @video_culture_id AND stop_time_seconds = 30);
    DECLARE @cp_culture_90 INT = (SELECT checkpoint_id FROM dbo.Video_Checkpoints WHERE material_id = @video_culture_id AND stop_time_seconds = 90);

    -- dev_fresher (user 4) trả lời
    IF @cp_java_45 IS NOT NULL
        INSERT INTO dbo.Video_Question_Answers (checkpoint_id, user_id, selected_option, is_correct, attempt_count, answered_at)
        VALUES (@cp_java_45, 4, 1, 1, 1, DATEADD(DAY, -1, GETDATE()));

    IF @cp_java_120 IS NOT NULL
        INSERT INTO dbo.Video_Question_Answers (checkpoint_id, user_id, selected_option, is_correct, attempt_count, answered_at)
        VALUES (@cp_java_120, 4, 2, 1, 1, DATEADD(DAY, -1, GETDATE()));

    IF @cp_culture_30 IS NOT NULL
        INSERT INTO dbo.Video_Question_Answers (checkpoint_id, user_id, selected_option, is_correct, attempt_count, answered_at)
        VALUES (@cp_culture_30, 4, 1, 1, 1, DATEADD(DAY, -5, GETDATE()));

    IF @cp_culture_90 IS NOT NULL
        INSERT INTO dbo.Video_Question_Answers (checkpoint_id, user_id, selected_option, is_correct, attempt_count, answered_at)
        VALUES (@cp_culture_90, 4, 1, 1, 1, DATEADD(DAY, -5, GETDATE()));

    -- dev_tester (user 5) trả lời
    IF @cp_culture_30 IS NOT NULL
        INSERT INTO dbo.Video_Question_Answers (checkpoint_id, user_id, selected_option, is_correct, attempt_count, answered_at)
        VALUES (@cp_culture_30, 5, 1, 1, 1, DATEADD(DAY, -4, GETDATE()));

    IF @cp_culture_90 IS NOT NULL
        INSERT INTO dbo.Video_Question_Answers (checkpoint_id, user_id, selected_option, is_correct, attempt_count, answered_at)
        VALUES (@cp_culture_90, 5, 1, 1, 1, DATEADD(DAY, -4, GETDATE()));
END;
GO

-- =======================================================
-- 8. FLASHCARD DATA
-- =======================================================
IF NOT EXISTS (SELECT 1 FROM dbo.FlashcardDecks WHERE title = N'Văn hóa công ty')
BEGIN
    INSERT INTO dbo.FlashcardDecks (title, description) VALUES
    (N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa công ty'),
    (N'Chuyên môn', N'Kiến thức chuyên môn Java');

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
END;
GO

-- =======================================================
-- KIỂM TRA DỮ LIỆU: SELECT TẤT CẢ CÁC BẢNG
-- =======================================================
SELECT * FROM dbo.Roles;
SELECT * FROM dbo.Job_Levels;
SELECT * FROM dbo.Departments;
SELECT * FROM dbo.Positions;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Employee_History;
SELECT * FROM dbo.Learning_Materials;
SELECT * FROM dbo.Video_Checkpoints;
SELECT * FROM dbo.Training_Classes;
SELECT * FROM dbo.Class_Materials;
SELECT * FROM dbo.Class_Enrollments;
SELECT * FROM dbo.Learning_Progress;
SELECT * FROM dbo.Video_Question_Answers;
SELECT * FROM dbo.FlashcardDecks;
SELECT * FROM dbo.Flashcards;
GO
