-- =======================================================
-- SQL Server Script: seed_data_sqlserver.sql
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB
-- Thư mục: database/seed_data/
-- Mô tả: Dữ liệu mẫu khởi tạo toàn bộ hệ thống (Roles, Departments, Positions, Job_Levels, Users, History, Flashcards, Learning Materials, Classes, Enrollments, Progress)
-- =======================================================

USE HRM_Project_DB;
GO

-- Có thể chạy lại: chỉ thêm dữ liệu mẫu còn thiếu, không ghi đè dữ liệu đang có.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

-- =======================================================
-- 1. SEED DATA: BẢNG PHÂN QUYỀN (ROLES)
-- =======================================================
INSERT INTO dbo.Roles (role_name, description)
SELECT src.role_name, src.description
FROM (
    SELECT s.role_name AS role_name,
        s.description AS description
    FROM (VALUES
('ADMIN', N'Quản trị viên hệ thống'),
('HR', N'Nhân sự quản lý phòng ban, vị trí và nhân viên'),
('MANAGER', N'Trưởng phòng quản lý nhân viên trong phòng ban của mình'),
('EMPLOYEE', N'Nhân viên công ty')
    ) AS s (role_name, description)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.role_name=src.role_name OR (existing.role_name IS NULL AND src.role_name IS NULL)));
GO

-- =======================================================
-- 2. SEED DATA: BẢNG CẤP BẬC (JOB_LEVELS)
-- =======================================================
INSERT INTO dbo.Job_Levels (level_name, rank_order, description)
SELECT src.level_name, src.rank_order, src.description
FROM (
    SELECT s.level_name AS level_name,
        s.rank_order AS rank_order,
        s.description AS description
    FROM (VALUES
(N'Intern', 1, N'Thực tập sinh'),
(N'Fresher', 2, N'Nhân viên mới vào nghề'),
(N'Junior', 3, N'Nhân viên có từ 1 - 2 năm kinh nghiệm'),
(N'Middle', 4, N'Nhân viên từ 2 - 4 năm kinh nghiệm'),
(N'Senior', 5, N'Chuyên viên từ 4+ năm kinh nghiệm'),
(N'Lead', 6, N'Trưởng nhóm chuyên môn')
    ) AS s (level_name, rank_order, description)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Job_Levels existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.level_name=src.level_name OR (existing.level_name IS NULL AND src.level_name IS NULL)));
GO

-- =======================================================
-- 3. SEED DATA: BẢNG PHÒNG BAN (DEPARTMENTS)
-- =======================================================
INSERT INTO dbo.Departments (department_name, description, status, is_deleted)
SELECT src.department_name, src.description, src.status, src.is_deleted
FROM (
    SELECT s.department_name AS department_name,
        s.description AS description,
        s.status AS status,
        s.is_deleted AS is_deleted
    FROM (VALUES
(N'Phòng Kỹ Thuật (IT)', N'Phát triển, bảo trì và vận hành hệ thống phần mềm', 1, 0),
(N'Phòng Nhân Sự (HR)', N'Tuyển dụng, đào tạo và quản lý chế độ chính sách nhân sự', 1, 0),
(N'Phòng Kinh Doanh (Sales)', N'Kinh doanh giải pháp, phát triển thị trường và chăm sóc khách hàng', 1, 0),
(N'Phòng Marketing & Truyền Thông', N'Xây dựng thương hiệu, tiếp thị số và truyền thông doanh nghiệp', 1, 0),
(N'Phòng Kế Toán - Tài Chính', N'Quản lý dòng tiền, kế toán tổng hợp và lập kế hoạch tài chính', 1, 0)
    ) AS s (department_name, description, status, is_deleted)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Departments existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.department_name=src.department_name OR (existing.department_name IS NULL AND src.department_name IS NULL)));
GO

-- =======================================================
-- 4. SEED DATA: BẢNG VỊ TRÍ CÔNG VIỆC (POSITIONS)
-- =======================================================
INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
SELECT src.position_name, src.department_id, src.description, src.status, src.is_deleted
FROM (
    SELECT s.position_name AS position_name,
        (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name=CASE s.department_id WHEN 1 THEN N'Phòng Kỹ Thuật (IT)' WHEN 2 THEN N'Phòng Nhân Sự (HR)' WHEN 3 THEN N'Phòng Kinh Doanh (Sales)' WHEN 4 THEN N'Phòng Marketing & Truyền Thông' WHEN 5 THEN N'Phòng Kế Toán - Tài Chính' END ORDER BY department_id) AS department_id,
        s.description AS description,
        s.status AS status,
        s.is_deleted AS is_deleted
    FROM (VALUES
-- 1. Phòng Kỹ Thuật (IT - Department 1)
(N'Java Developer', 1, N'Lập trình viên backend Java/Spring/Jakarta EE', 1, 0),
(N'Frontend Developer', 1, N'Lập trình viên giao diện web React/Vue/HTML/CSS', 1, 0),
(N'QA / Software Tester', 1, N'Kiểm thử tự động & kiểm thử thủ công phần mềm', 1, 0),
-- 2. Phòng Nhân Sự (HR - Department 2)
(N'HR Officer', 2, N'Chuyên viên nhân sự tổng hợp', 1, 0),
-- 3. Phòng Kinh Doanh (Sales - Department 3)
(N'Sales Executive', 3, N'Chuyên viên kinh doanh giải pháp doanh nghiệp B2B', 1, 0),
-- Bổ sung tiếp cho Phòng Kỹ Thuật (IT - Department 1)
(N'DevOps Engineer', 1, N'Kỹ sư hạ tầng, Cloud và quy trình CI/CD', 1, 0),
(N'Business Analyst (BA)', 1, N'Chuyên viên phân tích nghiệp vụ và quy trình phần mềm', 1, 0),
(N'Mobile App Developer', 1, N'Lập trình viên ứng dụng di động Flutter/iOS/Android', 1, 0),
-- Bổ sung tiếp cho Phòng Nhân Sự (HR - Department 2)
(N'Talent Acquisition Specialist', 2, N'Chuyên viên tuyển dụng nhân tài', 1, 0),
(N'C&B Specialist', 2, N'Chuyên viên tiền lương, bảo hiểm và chính sách đãi ngộ', 1, 0),
(N'Training & Development Executive', 2, N'Chuyên viên đào tạo và phát triển năng lực nhân viên', 1, 0),
-- Bổ sung tiếp cho Phòng Kinh Doanh (Sales - Department 3)
(N'Key Account Manager (KAM)', 3, N'Quản lý và chăm sóc khách hàng doanh nghiệp trọng điểm', 1, 0),
(N'Business Development Rep (BDR)', 3, N'Chuyên viên tìm kiếm và mở rộng mạng lưới khách hàng mới', 1, 0),
-- 4. Phòng Marketing & Truyền Thông (Marketing - Department 4)
(N'Digital Marketing Specialist', 4, N'Chuyên viên tiếp thị số, SEO và quảng cáo trực tuyến', 1, 0),
(N'Content Creator & Copywriter', 4, N'Chuyên viên sáng tạo nội dung, bài viết truyền thông', 1, 0),
(N'UI/UX Product Designer', 4, N'Thiết kế trải nghiệm người dùng và giao diện sản phẩm số', 1, 0),
-- 5. Phòng Kế Toán - Tài Chính (Department 5)
(N'Kế Toán Tổng Hợp (General Accountant)', 5, N'Hạch toán chi phí, doanh thu và lập báo cáo tài chính', 1, 0),
(N'Chuyên Viên Kiểm Toán Nội Bộ', 5, N'Kiểm soát rủi ro tài chính và tuân thủ quy chế chi tiêu', 1, 0),
(N'Financial Planning & Analysis (FP&A)', 5, N'Chuyên viên phân tích và dự báo kế hoạch tài chính', 1, 0)
    ) AS s (position_name, department_id, description, status, is_deleted)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Positions existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.position_name=src.position_name OR (existing.position_name IS NULL AND src.position_name IS NULL)) AND (existing.department_id=src.department_id OR (existing.department_id IS NULL AND src.department_id IS NULL)));
GO

-- =======================================================
-- 5. SEED DATA: BẢNG TÀI KHOẢN NGƯỜI DÙNG (USERS)
-- =======================================================
INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
SELECT src.username, src.password, src.full_name, src.email, src.phone, src.gender, src.role_id, src.department_id, src.position_id, src.level_id, src.hire_date, src.status, src.is_deleted
FROM (
    SELECT s.username AS username,
        s.password AS password,
        s.full_name AS full_name,
        s.email AS email,
        s.phone AS phone,
        s.gender AS gender,
        (SELECT TOP (1) role_id FROM dbo.Roles WHERE role_name=CASE s.role_id WHEN 1 THEN N'ADMIN' WHEN 2 THEN N'HR' WHEN 3 THEN N'MANAGER' WHEN 4 THEN N'EMPLOYEE' END ORDER BY role_id) AS role_id,
        (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name=CASE s.department_id WHEN 1 THEN N'Phòng Kỹ Thuật (IT)' WHEN 2 THEN N'Phòng Nhân Sự (HR)' WHEN 3 THEN N'Phòng Kinh Doanh (Sales)' WHEN 4 THEN N'Phòng Marketing & Truyền Thông' WHEN 5 THEN N'Phòng Kế Toán - Tài Chính' END ORDER BY department_id) AS department_id,
        (SELECT TOP (1) position_id FROM dbo.Positions WHERE position_name=CASE s.position_id WHEN 1 THEN N'Java Developer' WHEN 2 THEN N'Frontend Developer' WHEN 3 THEN N'QA / Software Tester' WHEN 4 THEN N'HR Officer' WHEN 5 THEN N'Sales Executive' END ORDER BY position_id) AS position_id,
        (SELECT TOP (1) level_id FROM dbo.Job_Levels WHERE level_name=CASE s.level_id WHEN 1 THEN N'Intern' WHEN 2 THEN N'Fresher' WHEN 3 THEN N'Junior' WHEN 4 THEN N'Middle' WHEN 5 THEN N'Senior' WHEN 6 THEN N'Lead' END ORDER BY level_id) AS level_id,
        s.hire_date AS hire_date,
        s.status AS status,
        s.is_deleted AS is_deleted
    FROM (VALUES
('admin', '123', N'Quản Trị Viên', 'admin@hrm.com', '0901000001', N'Nam', 1, 1, 1, 6, '2022-01-01', 1, 0),
('hr_manager', '123', N'Phạm Thu Hà', 'ha.pt@hrm.com', '0901000002', N'Nữ', 2, 2, 4, 5, '2022-03-15', 1, 0),
('manager_it', '123', N'Trần Văn Minh', 'minh.tv@hrm.com', '0901000003', N'Nam', 3, 1, 1, 6, '2022-02-01', 1, 0),
('dev_fresher', '123', N'Phạm Đức Trọng', 'trong.pd@hrm.com', '0901000006', N'Nam', 4, 1, 1, 2, '2026-08-01', 1, 0),
('dev_tester', '123', N'Ngô Mai Phương', 'phuong.nm@hrm.com', '0901000007', N'Nữ', 4, 1, 3, 3, '2023-06-01', 1, 0),
('mentor_java', '123', N'Lê Hữu Mentor', 'mentor.java@hrm.com', '0988888888', N'Nam', 4, 1, 1, 5, '2021-01-01', 1, 0),
('locked_user', '123', N'Nguyễn Khóa Khoản', 'locked.user@hrm.com', '0901999999', N'Nam', 4, 1, 1, 2, '2026-01-01', 0, 0)
    ) AS s (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Users existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.username=src.username OR existing.email=src.email));
GO

-- Cập nhật Trưởng phòng cho các phòng ban
UPDATE dbo.Departments SET manager_id = (SELECT user_id FROM dbo.Users WHERE username='manager_it')
WHERE department_name=N'Phòng Kỹ Thuật (IT)' AND manager_id IS NULL;
UPDATE dbo.Departments SET manager_id = (SELECT user_id FROM dbo.Users WHERE username='hr_manager')
WHERE department_name=N'Phòng Nhân Sự (HR)' AND manager_id IS NULL;
GO

-- =======================================================
-- 6. SEED DATA: LỊCH SỬ BIẾN ĐỘNG (EMPLOYEE_HISTORY)
-- =======================================================
INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by)
SELECT src.user_id, src.old_department_id, src.new_department_id, src.old_position_id, src.new_position_id, src.old_level_id, src.new_level_id, src.change_type, src.change_date, src.notes, src.created_by
FROM (
    SELECT (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.user_id WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS user_id,
        (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name=CASE s.old_department_id WHEN 1 THEN N'Phòng Kỹ Thuật (IT)' WHEN 2 THEN N'Phòng Nhân Sự (HR)' WHEN 3 THEN N'Phòng Kinh Doanh (Sales)' WHEN 4 THEN N'Phòng Marketing & Truyền Thông' WHEN 5 THEN N'Phòng Kế Toán - Tài Chính' END ORDER BY department_id) AS old_department_id,
        (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name=CASE s.new_department_id WHEN 1 THEN N'Phòng Kỹ Thuật (IT)' WHEN 2 THEN N'Phòng Nhân Sự (HR)' WHEN 3 THEN N'Phòng Kinh Doanh (Sales)' WHEN 4 THEN N'Phòng Marketing & Truyền Thông' WHEN 5 THEN N'Phòng Kế Toán - Tài Chính' END ORDER BY department_id) AS new_department_id,
        (SELECT TOP (1) position_id FROM dbo.Positions WHERE position_name=CASE s.old_position_id WHEN 1 THEN N'Java Developer' WHEN 2 THEN N'Frontend Developer' WHEN 3 THEN N'QA / Software Tester' WHEN 4 THEN N'HR Officer' WHEN 5 THEN N'Sales Executive' END ORDER BY position_id) AS old_position_id,
        (SELECT TOP (1) position_id FROM dbo.Positions WHERE position_name=CASE s.new_position_id WHEN 1 THEN N'Java Developer' WHEN 2 THEN N'Frontend Developer' WHEN 3 THEN N'QA / Software Tester' WHEN 4 THEN N'HR Officer' WHEN 5 THEN N'Sales Executive' END ORDER BY position_id) AS new_position_id,
        (SELECT TOP (1) level_id FROM dbo.Job_Levels WHERE level_name=CASE s.old_level_id WHEN 1 THEN N'Intern' WHEN 2 THEN N'Fresher' WHEN 3 THEN N'Junior' WHEN 4 THEN N'Middle' WHEN 5 THEN N'Senior' WHEN 6 THEN N'Lead' END ORDER BY level_id) AS old_level_id,
        (SELECT TOP (1) level_id FROM dbo.Job_Levels WHERE level_name=CASE s.new_level_id WHEN 1 THEN N'Intern' WHEN 2 THEN N'Fresher' WHEN 3 THEN N'Junior' WHEN 4 THEN N'Middle' WHEN 5 THEN N'Senior' WHEN 6 THEN N'Lead' END ORDER BY level_id) AS new_level_id,
        s.change_type AS change_type,
        s.change_date AS change_date,
        s.notes AS notes,
        (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.created_by WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS created_by
    FROM (VALUES
(4, NULL, 1, NULL, 1, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyển dụng mới vị trí Java Developer', 2)
    ) AS s (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Employee_History existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.user_id=src.user_id OR (existing.user_id IS NULL AND src.user_id IS NULL)) AND (existing.change_type=src.change_type OR (existing.change_type IS NULL AND src.change_type IS NULL)) AND (existing.change_date=src.change_date OR (existing.change_date IS NULL AND src.change_date IS NULL)));
GO

-- =======================================================
-- 7. SEED DATA: FLASHCARDS HỌC TẬP
-- =======================================================
INSERT INTO dbo.FlashcardDecks (title, description)
SELECT src.title, src.description
FROM (
    SELECT s.title AS title,
        s.description AS description
    FROM (VALUES
(N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa công ty'),
(N'Chuyên môn Java Backend', N'Kiến thức chuyên môn lập trình Java')
    ) AS s (title, description)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.FlashcardDecks existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.title=src.title OR (existing.title IS NULL AND src.title IS NULL)));
GO

INSERT INTO dbo.Flashcards (deck_id, question, answer)
SELECT src.deck_id, src.question, src.answer
FROM (
    SELECT (SELECT TOP (1) deck_id FROM dbo.FlashcardDecks WHERE title=CASE s.deck_id WHEN 1 THEN N'Văn hóa công ty' WHEN 2 THEN N'Chuyên môn Java Backend' END ORDER BY deck_id) AS deck_id,
        s.question AS question,
        s.answer AS answer
    FROM (VALUES
(1, N'Giờ làm việc kết thúc lúc mấy giờ?', N'17:30 hàng ngày.'),
(1, N'Thành viên mới cần làm gì trong ngày đầu tiên?', N'Hoàn tất thủ tục onboarding, làm quen với team, tài khoản hệ thống và nội quy công ty.'),
(1, N'Nhân viên cần báo trước bao nhiêu ngày khi xin nghỉ phép?', N'Thực hiện theo quy định nghỉ phép của công ty và thông báo cho quản lý trước thời gian nghỉ.'),
(1, N'Khi gặp vấn đề trong công việc, nhân viên nên làm gì?', N'Chủ động trao đổi với Leader, Manager hoặc người hướng dẫn để được hỗ trợ.'),
(1, N'Onboarding là gì?', N'Là quá trình giúp nhân viên mới làm quen với công ty, công việc, văn hóa và quy trình làm việc.'),
(1, N'Mục đích của việc onboarding nhân viên mới là gì?', N'Giúp nhân viên nhanh chóng hòa nhập, hiểu công việc và có thể làm việc hiệu quả.'),
(1, N'Nhân viên có cần bảo mật thông tin công ty không?', N'Có. Nhân viên phải bảo mật thông tin nội bộ, thông tin khách hàng và dữ liệu của công ty.'),
(1, N'Khi đến muộn, nhân viên nên làm gì?', N'Thông báo cho quản lý hoặc người phụ trách và tuân thủ quy định chấm công của công ty.'),
(1, N'Tại sao cần tham gia các buổi training của công ty?', N'Để cập nhật kiến thức, quy trình, kỹ năng và các quy định cần thiết cho công việc.'),
(1, N'Nhân viên mới có thể hỏi ai khi không hiểu công việc?', N'Có thể hỏi Mentor, Team Leader, Manager hoặc đồng nghiệp phù hợp.')
    ) AS s (deck_id, question, answer)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Flashcards existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.deck_id=src.deck_id OR (existing.deck_id IS NULL AND src.deck_id IS NULL)) AND (existing.question=src.question OR (existing.question IS NULL AND src.question IS NULL)));
GO

INSERT INTO dbo.Flashcards (deck_id, question, answer)
SELECT src.deck_id, src.question, src.answer
FROM (
    SELECT (SELECT TOP (1) deck_id FROM dbo.FlashcardDecks WHERE title=CASE s.deck_id WHEN 1 THEN N'Văn hóa công ty' WHEN 2 THEN N'Chuyên môn Java Backend' END ORDER BY deck_id) AS deck_id,
        s.question AS question,
        s.answer AS answer
    FROM (VALUES
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
(2, N'API là gì?', N'API là giao diện cho phép các ứng dụng hoặc hệ thống giao tiếp và trao đổi dữ liệu với nhau.')
    ) AS s (deck_id, question, answer)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Flashcards existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.deck_id=src.deck_id OR (existing.deck_id IS NULL AND src.deck_id IS NULL)) AND (existing.question=src.question OR (existing.question IS NULL AND src.question IS NULL)));
GO

-- Học liệu nguồn: khởi tạo trước kho đề để đề Học liệu liên kết đúng.
INSERT INTO dbo.Learning_Materials (title, description, material_type, scope_type, department_id, position_id, level_id, material_url, file_name, file_type, file_size, video_url, duration_minutes, status, is_deleted, created_by, created_at, updated_at)
SELECT src.title, src.description, src.material_type, src.scope_type, src.department_id, src.position_id, src.level_id, src.material_url, src.file_name, src.file_type, src.file_size, src.video_url, src.duration_minutes, src.status, src.is_deleted, src.created_by, src.created_at, src.updated_at
FROM (
    SELECT s.title AS title,
        s.description AS description,
        s.material_type AS material_type,
        s.scope_type AS scope_type,
        (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name=CASE s.department_id WHEN 1 THEN N'Phòng Kỹ Thuật (IT)' WHEN 2 THEN N'Phòng Nhân Sự (HR)' WHEN 3 THEN N'Phòng Kinh Doanh (Sales)' WHEN 4 THEN N'Phòng Marketing & Truyền Thông' WHEN 5 THEN N'Phòng Kế Toán - Tài Chính' END ORDER BY department_id) AS department_id,
        (SELECT TOP (1) position_id FROM dbo.Positions WHERE position_name=CASE s.position_id WHEN 1 THEN N'Java Developer' WHEN 2 THEN N'Frontend Developer' WHEN 3 THEN N'QA / Software Tester' WHEN 4 THEN N'HR Officer' WHEN 5 THEN N'Sales Executive' END ORDER BY position_id) AS position_id,
        (SELECT TOP (1) level_id FROM dbo.Job_Levels WHERE level_name=CASE s.level_id WHEN 1 THEN N'Intern' WHEN 2 THEN N'Fresher' WHEN 3 THEN N'Junior' WHEN 4 THEN N'Middle' WHEN 5 THEN N'Senior' WHEN 6 THEN N'Lead' END ORDER BY level_id) AS level_id,
        COALESCE(s.video_url, N'/assets/docs/' + s.file_name) AS material_url,
        s.file_name AS file_name,
        s.file_type AS file_type,
        s.file_size AS file_size,
        s.video_url AS video_url,
        s.duration_minutes AS duration_minutes,
        s.status AS status,
        s.is_deleted AS is_deleted,
        (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.created_by WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS created_by,
        s.created_at AS created_at,
        s.updated_at AS updated_at
    FROM (VALUES
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
 N'Cam_Nang_Quy_Chuan_An_Toan_Thong_Tin_Bao_Mat.pdf', 'application/pdf', 10518152, NULL, 20, 1, 0, 2, '2026-09-28 08:24:23.560', '2026-09-28 08:27:09.823')
    ) AS s (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, file_size, video_url, duration_minutes, status, is_deleted, created_by, created_at, updated_at)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Learning_Materials existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.title=src.title OR (existing.title IS NULL AND src.title IS NULL)) AND (existing.scope_type=src.scope_type OR (existing.scope_type IS NULL AND src.scope_type IS NULL)) AND (existing.department_id=src.department_id OR (existing.department_id IS NULL AND src.department_id IS NULL)));
GO

-- =======================================================
-- 8. SEED DATA: KHO ĐỀ THI VĂN HÓA & CHUYÊN MÔN & HỌC LIỆU
-- Câu hỏi chỉ được nạp từ database, không tạo thủ công trên giao diện.
-- Hỗ trợ: đúng/sai, một đáp án, nhiều đáp án đúng và hơn 4 lựa chọn.
-- =======================================================
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @culture_creator_id INT = (SELECT TOP (1) user_id FROM dbo.Users WHERE username = 'admin');
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

-- BEGIN LEARNING TEST BANK SEED
-- 15 câu / học liệu. Dựa trên mô tả và checkpoint hiện có, chưa đối chiếu toàn bộ file gốc.
-- Chạy khối BEGIN/END TEST MODULE trong file schema trước. Không sửa/xóa đề đã có khi chạy lại.
SET XACT_ABORT ON;
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
BEGIN TRANSACTION;
DECLARE @material INT, @content INT, @question INT;

SET @material = NULL;
SELECT TOP (1) @material=material_id FROM dbo.Learning_Materials
WHERE title=N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty' AND is_deleted=0 AND status=1 ORDER BY material_id;
IF @material IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Test_Content WITH (UPDLOCK,HOLDLOCK)
    WHERE learning_material_id=@material AND is_deleted=0)
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
    SELECT LEFT(N'Học liệu: '+title,200),
        N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. '+COALESCE(description,N''),
        'quiz','learning',department_id,created_by,'ready',material_id
    FROM dbo.Learning_Materials WHERE material_id=@material;
    SET @content=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tầm nhìn doanh nghiệp mô tả điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Trạng thái tương lai doanh nghiệp hướng tới',1,1),
        (@question,N'Lịch chấm công từng ngày',0,2),
        (@question,N'Mật khẩu hệ thống',0,3),
        (@question,N'Danh sách thiết bị cá nhân',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sứ mệnh doanh nghiệp trả lời câu hỏi nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Nhân viên dùng điện thoại hãng nào?',0,1),
        (@question,N'Doanh nghiệp tồn tại để tạo giá trị gì và cho ai?',1,2),
        (@question,N'Màu áo yêu thích của từng người?',0,3),
        (@question,N'Ai đến văn phòng sớm nhất?',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Giá trị cốt lõi có vai trò gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Thay thế mọi quy định pháp luật',0,1),
        (@question,N'Chỉ dùng trang trí văn phòng',0,2),
        (@question,N'Định hướng hành vi và quyết định trong công việc',1,3),
        (@question,N'Chỉ áp dụng cho nhân sự mới',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi chưa rõ một nội quy, nhân viên nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự suy đoán rồi phổ biến cho cả nhóm',0,1),
        (@question,N'Bỏ qua nội quy',0,2),
        (@question,N'Làm theo tin đồn',0,3),
        (@question,N'Tra cứu sổ tay và hỏi bộ phận phụ trách',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Hành vi nào thể hiện tác phong chuyên nghiệp?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Đúng giờ và chuẩn bị nội dung trước cuộc họp',1,1),
        (@question,N'Thường xuyên trễ hẹn không báo',0,2),
        (@question,N'Ngắt lời mọi người',0,3),
        (@question,N'Bỏ qua cam kết đã nhận',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi nhận thấy có nguy cơ trễ hạn, nên xử lý thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giấu thông tin đến ngày cuối',0,1),
        (@question,N'Báo sớm và thống nhất phương án xử lý',1,2),
        (@question,N'Đổi hạn mà không thông báo',0,3),
        (@question,N'Đổ lỗi cho đồng nghiệp',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Cách trao đổi nào phù hợp trong môi trường làm việc?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Công kích cá nhân',0,1),
        (@question,N'Phát tán tin chưa kiểm chứng',0,2),
        (@question,N'Tôn trọng và góp ý dựa trên sự việc cụ thể',1,3),
        (@question,N'Dùng lời lẽ xúc phạm',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi cần nghỉ phép, nhân viên nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự nghỉ không báo',0,1),
        (@question,N'Nhờ người khác chấm công hộ',0,2),
        (@question,N'Xóa lịch làm việc',0,3),
        (@question,N'Thực hiện quy trình xin phép và bàn giao công việc',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Nguồn nào phù hợp để kiểm tra chính sách phúc lợi?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Văn bản chính thức và bộ phận nhân sự',1,1),
        (@question,N'Bình luận ẩn danh',0,2),
        (@question,N'Tin nhắn quảng cáo',0,3),
        (@question,N'Tin truyền miệng ngoài công ty',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi có bất đồng trong nhóm, cách xử lý phù hợp là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Né tránh mọi trao đổi',0,1),
        (@question,N'Trao đổi dựa trên mục tiêu chung và dữ kiện',1,2),
        (@question,N'Đưa chuyện cá nhân lên mạng',0,3),
        (@question,N'Giữ thông tin để gây khó dễ',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Trách nhiệm với tài sản công ty thể hiện ở đâu?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự ý mang về cho người thân',0,1),
        (@question,N'Cho mượn không kiểm soát',0,2),
        (@question,N'Sử dụng đúng mục đích và báo hỏng kịp thời',1,3),
        (@question,N'Che giấu việc làm mất',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi tiếp nhận công việc từ đồng nghiệp, cần làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ nhận tên công việc',0,1),
        (@question,N'Không hỏi dù chưa hiểu',0,2),
        (@question,N'Tự bỏ các yêu cầu chưa thích',0,3),
        (@question,N'Xác nhận phạm vi, thời hạn và đầu mối phối hợp',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Văn hóa phản hồi tích cực hướng đến điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Cải thiện công việc bằng góp ý cụ thể và tôn trọng',1,1),
        (@question,N'Tìm người để đổ lỗi',0,2),
        (@question,N'Chỉ trích trước đám đông',0,3),
        (@question,N'Tránh nêu mọi vấn đề',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi thấy hành vi vi phạm nội quy, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Đăng thông tin cá nhân lên mạng',0,1),
        (@question,N'Phản ánh qua kênh phù hợp với thông tin xác thực',1,2),
        (@question,N'Bao che vô điều kiện',0,3),
        (@question,N'Tự áp dụng hình phạt',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Để áp dụng sổ tay vào công việc hằng ngày, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ đọc tiêu đề một lần',0,1),
        (@question,N'Chỉ nhớ tên tài liệu',0,2),
        (@question,N'Đối chiếu hành vi và quy trình với hướng dẫn chính thức',1,3),
        (@question,N'Coi mọi quy định là tùy chọn',0,4);
END;

SET @material = NULL;
SELECT TOP (1) @material=material_id FROM dbo.Learning_Materials
WHERE title=N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum' AND is_deleted=0 AND status=1 ORDER BY material_id;
IF @material IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Test_Content WITH (UPDLOCK,HOLDLOCK)
    WHERE learning_material_id=@material AND is_deleted=0)
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
    SELECT LEFT(N'Học liệu: '+title,200),
        N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. '+COALESCE(description,N''),
        'quiz','learning',department_id,created_by,'ready',material_id
    FROM dbo.Learning_Materials WHERE material_id=@material;
    SET @content=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sprint trong Scrum là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Khoảng thời gian cố định để tạo giá trị hướng tới Sprint Goal',1,1),
        (@question,N'Một cuộc họp không giới hạn thời gian',0,2),
        (@question,N'Toàn bộ vòng đời công ty',0,3),
        (@question,N'Một danh sách lỗi bất kỳ',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sprint Planning nhằm mục đích gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ báo cáo giờ làm tháng trước',0,1),
        (@question,N'Thống nhất mục tiêu Sprint và kế hoạch thực hiện',1,2),
        (@question,N'Đánh giá lương từng người',0,3),
        (@question,N'Đóng dự án ngay lập tức',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Daily Scrum chủ yếu giúp Developers làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Báo cáo cá nhân để quản lý chấm điểm',0,1),
        (@question,N'Thay thế mọi trao đổi kỹ thuật',0,2),
        (@question,N'Kiểm tra tiến độ tới Sprint Goal và điều chỉnh kế hoạch',1,3),
        (@question,N'Duyệt ngân sách công ty',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Thời lượng timebox của Daily Scrum là bao lâu?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'2 giờ',0,1),
        (@question,N'Một ngày',0,2),
        (@question,N'Không giới hạn',0,3),
        (@question,N'15 phút',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sprint Review tập trung vào điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Kiểm tra kết quả Sprint với bên liên quan và thích ứng hướng đi',1,1),
        (@question,N'Chỉ tìm lỗi tác phong cá nhân',0,2),
        (@question,N'Chỉ phân công nghỉ phép',0,3),
        (@question,N'Chỉ đọc lại toàn bộ mã nguồn',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sprint Retrospective nhằm cải thiện điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Logo sản phẩm',0,1),
        (@question,N'Chất lượng và hiệu quả cách nhóm làm việc',1,2),
        (@question,N'Số lượng chức danh',0,3),
        (@question,N'Mật khẩu Jira',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Ai chịu trách nhiệm quản lý Product Backlog hiệu quả?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mọi khách hàng tự sửa độc lập',0,1),
        (@question,N'Bất kỳ người ngoài nhóm',0,2),
        (@question,N'Product Owner',1,3),
        (@question,N'Chỉ bộ phận kế toán',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Scrum Master có trách nhiệm nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giao từng task bắt buộc cho Developers',0,1),
        (@question,N'Thay Product Owner quyết định mọi ưu tiên',0,2),
        (@question,N'Chấm công thay cả nhóm',0,3),
        (@question,N'Giúp thiết lập Scrum và nâng cao hiệu quả Scrum Team',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Product Backlog là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Danh sách được sắp thứ tự về những gì cần để cải thiện sản phẩm',1,1),
        (@question,N'Danh sách riêng không ai được xem',0,2),
        (@question,N'Chỉ là các lỗi đã đóng',0,3),
        (@question,N'Biên bản nghỉ phép',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sprint Backlog thể hiện điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Toàn bộ ý tưởng tương lai không chọn lọc',0,1),
        (@question,N'Sprint Goal, các hạng mục được chọn và kế hoạch thực hiện',1,2),
        (@question,N'Chỉ tên người quản lý',0,3),
        (@question,N'Mọi tài liệu của công ty',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Definition of Done giúp nhóm làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự coi mọi task đang làm là xong',0,1),
        (@question,N'Loại bỏ kiểm thử',0,2),
        (@question,N'Thống nhất tiêu chuẩn chất lượng để xác định Increment hoàn thành',1,3),
        (@question,N'Thay đổi mục tiêu công ty',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi task bị chặn trên Jira, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giữ trạng thái Done dù chưa xong',0,1),
        (@question,N'Xóa mọi bình luận',0,2),
        (@question,N'Để im đến hết Sprint',0,3),
        (@question,N'Ghi rõ trở ngại và trao đổi để tháo gỡ',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Cập nhật trạng thái task đúng thực tế mang lại lợi ích gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giúp nhóm nhìn thấy tiến độ và phối hợp kịp thời',1,1),
        (@question,N'Bảo đảm không cần họp hay trao đổi',0,2),
        (@question,N'Tự động loại bỏ mọi lỗi',0,3),
        (@question,N'Thay thế toàn bộ kiểm thử',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi phát hiện yêu cầu chưa rõ, Developers nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự đoán rồi giấu quyết định',0,1),
        (@question,N'Trao đổi với Product Owner để làm rõ và cùng thống nhất',1,2),
        (@question,N'Bỏ mọi tiêu chí chấp nhận',0,3),
        (@question,N'Chờ đến ngày bàn giao mới hỏi',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Một cải tiến từ Retrospective nên được thực hiện thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ ghi biên bản rồi bỏ qua',0,1),
        (@question,N'Luôn thay toàn bộ thành viên',0,2),
        (@question,N'Chọn hành động cụ thể và theo dõi hiệu quả',1,3),
        (@question,N'Chỉ tăng số cuộc họp',0,4);
END;

SET @material = NULL;
SELECT TOP (1) @material=material_id FROM dbo.Learning_Materials
WHERE title=N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE' AND is_deleted=0 AND status=1 ORDER BY material_id;
IF @material IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Test_Content WITH (UPDLOCK,HOLDLOCK)
    WHERE learning_material_id=@material AND is_deleted=0)
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
    SELECT LEFT(N'Học liệu: '+title,200),
        N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. '+COALESCE(description,N''),
        'quiz','learning',department_id,created_by,'ready',material_id
    FROM dbo.Learning_Materials WHERE material_id=@material;
    SET @content=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Trong MVC, Servlet thường đóng vai trò gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Controller tiếp nhận và điều phối request',1,1),
        (@question,N'View trình bày HTML',0,2),
        (@question,N'Máy chủ cơ sở dữ liệu',0,3),
        (@question,N'Công cụ biên dịch CSS',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Trong MVC, JSP thường đảm nhận nhiệm vụ nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Quản lý transaction trực tiếp cho mọi request',0,1),
        (@question,N'Hiển thị dữ liệu cho người dùng',1,2),
        (@question,N'Thay thế JDBC driver',0,3),
        (@question,N'Lưu mật khẩu database trong HTML',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tầng DAO chịu trách nhiệm chính về việc gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Thiết kế màu giao diện',0,1),
        (@question,N'Quản lý cookie của trình duyệt',0,2),
        (@question,N'Truy cập và ánh xạ dữ liệu từ database',1,3),
        (@question,N'Biên dịch Servlet',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Phương thức init của Servlet thường chạy khi nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Trước mọi câu SQL',0,1),
        (@question,N'Sau mỗi lần render một thẻ HTML',0,2),
        (@question,N'Chỉ khi người dùng đăng xuất',0,3),
        (@question,N'Khi container khởi tạo Servlet',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Phương thức nào xử lý HTTP GET trong HttpServlet?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'doGet',1,1),
        (@question,N'doPostOnly',0,2),
        (@question,N'renderDatabase',0,3),
        (@question,N'startSession',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Phương thức destroy của Servlet dùng để làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Xóa toàn bộ database',0,1),
        (@question,N'Giải phóng tài nguyên khi Servlet bị đưa khỏi phục vụ',1,2),
        (@question,N'Xóa tài khoản người truy cập',0,3),
        (@question,N'Tạo session mới',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Vì sao không nên lưu dữ liệu riêng từng người dùng trong field Servlet?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mỗi field luôn tự mã hóa',0,1),
        (@question,N'Servlet chỉ có thể xử lý một người dùng',0,2),
        (@question,N'Nhiều request có thể dùng chung một Servlet đồng thời',1,3),
        (@question,N'Field không tồn tại trong Java',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Filter có thể được dùng cho công việc nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Thay thế toàn bộ database',0,1),
        (@question,N'Tạo khóa ngoại trên HTML',0,2),
        (@question,N'Biên dịch JSP bằng SQL',0,3),
        (@question,N'Kiểm tra đăng nhập trước khi request tới Servlet',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Trong Filter, chain.doFilter có tác dụng gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chuyển tiếp request tới bước xử lý tiếp theo',1,1),
        (@question,N'Luôn đóng ứng dụng',0,2),
        (@question,N'Xóa session của mọi người',0,3),
        (@question,N'Commit mọi transaction',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'HttpSession thường dùng để lưu thông tin gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mọi dữ liệu bí mật trong URL công khai',0,1),
        (@question,N'Trạng thái gắn với phiên người dùng phía server',1,2),
        (@question,N'Toàn bộ database trên trình duyệt',0,3),
        (@question,N'Chỉ CSS của trang',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi đăng xuất, thao tác nào giúp kết thúc session hiện tại?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'session.toString()',0,1),
        (@question,N'request.getMethod()',0,2),
        (@question,N'session.invalidate()',1,3),
        (@question,N'response.getStatus()',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'PreparedStatement với tham số ràng buộc giúp giảm nguy cơ gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mất điện máy chủ',0,1),
        (@question,N'Trình duyệt không hỗ trợ CSS',0,2),
        (@question,N'Ổ đĩa đầy',0,3),
        (@question,N'SQL Injection do nối dữ liệu đầu vào vào SQL',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Để bắt đầu quản lý transaction JDBC thủ công, cần làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Gọi setAutoCommit(false)',1,1),
        (@question,N'Gọi setAutoCommit(true) sau mỗi câu lệnh',0,2),
        (@question,N'Đóng connection trước khi ghi',0,3),
        (@question,N'Chuyển SQL thành HTML',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi một bước trong transaction thất bại, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Commit phần đã chạy bất kể lỗi',0,1),
        (@question,N'Rollback các thay đổi của transaction',1,2),
        (@question,N'Bỏ qua SQLException',0,3),
        (@question,N'Tạo session khác',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Try-with-resources giúp ích gì khi làm việc với JDBC?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự sửa mọi câu SQL sai',0,1),
        (@question,N'Bảo đảm không bao giờ mất kết nối',0,2),
        (@question,N'Đóng tài nguyên như ResultSet và Statement đúng cách',1,3),
        (@question,N'Thay thế hoàn toàn transaction',0,4);
END;

SET @material = NULL;
SELECT TOP (1) @material=material_id FROM dbo.Learning_Materials
WHERE title=N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)' AND is_deleted=0 AND status=1 ORDER BY material_id;
IF @material IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Test_Content WITH (UPDLOCK,HOLDLOCK)
    WHERE learning_material_id=@material AND is_deleted=0)
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
    SELECT LEFT(N'Học liệu: '+title,200),
        N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. '+COALESCE(description,N''),
        'quiz','learning',department_id,created_by,'ready',material_id
    FROM dbo.Learning_Materials WHERE material_id=@material;
    SET @content=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tên biến tốt nên thể hiện điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Ý nghĩa của dữ liệu trong ngữ cảnh sử dụng',1,1),
        (@question,N'Chỉ một ký tự cho mọi biến',0,2),
        (@question,N'Tên người viết mã',0,3),
        (@question,N'Số dòng trong file',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Quy ước thông dụng cho tên lớp Java là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'snake_case như employee_service',0,1),
        (@question,N'PascalCase như EmployeeService',1,2),
        (@question,N'Toàn chữ thường có dấu cách',0,3),
        (@question,N'Tên bắt đầu bằng chữ số',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Quy ước thông dụng cho tên phương thức Java là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'PascalCase cho mọi phương thức',0,1),
        (@question,N'Tên có dấu cách',0,2),
        (@question,N'camelCase như calculateScore',1,3),
        (@question,N'Chỉ dùng dấu gạch ngang',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Một hàm dễ bảo trì thường có đặc điểm nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Gộp giao diện, SQL và gửi mail vào cùng một hàm',0,1),
        (@question,N'Luôn có hàng nghìn dòng',0,2),
        (@question,N'Không có tên mô tả',0,3),
        (@question,N'Thực hiện một nhiệm vụ rõ ràng',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Single Responsibility Principle đề cập điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Một mô-đun nên có một lý do chính để thay đổi',1,1),
        (@question,N'Một lớp phải xử lý mọi chức năng',0,2),
        (@question,N'Mỗi dự án chỉ có một lớp',0,3),
        (@question,N'Không được tạo interface',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Open/Closed Principle khuyến khích điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mọi thay đổi đều sửa tất cả lớp',0,1),
        (@question,N'Mở cho mở rộng và hạn chế sửa đổi mã ổn định',1,2),
        (@question,N'Không được thêm chức năng',0,3),
        (@question,N'Chỉ dùng biến public',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Liskov Substitution Principle yêu cầu điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Kiểu con luôn ném lỗi cho mọi hàm kế thừa',0,1),
        (@question,N'Mọi lớp con phải bỏ kiểm thử',0,2),
        (@question,N'Kiểu con có thể thay kiểu cha mà vẫn giữ hợp đồng hành vi',1,3),
        (@question,N'Lớp cha phải biết mọi lớp con',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Interface Segregation Principle khuyến khích điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Một interface khổng lồ cho mọi client',0,1),
        (@question,N'Không được chia interface',0,2),
        (@question,N'Mọi interface đều phải có một trăm hàm',0,3),
        (@question,N'Interface chuyên biệt để client không phụ thuộc hàm không dùng',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Dependency Inversion Principle hướng tới điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mô-đun cấp cao và cấp thấp phụ thuộc abstraction',1,1),
        (@question,N'Service luôn tự tạo mọi dependency cụ thể',0,2),
        (@question,N'UI phải biết mật khẩu database',0,3),
        (@question,N'Mọi lớp chỉ dùng static',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi bắt exception, cách xử lý phù hợp là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Để catch rỗng cho mọi lỗi',0,1),
        (@question,N'Xử lý có ý nghĩa hoặc chuyển tiếp với ngữ cảnh phù hợp',1,2),
        (@question,N'Luôn trả thành công bất kể lỗi',0,3),
        (@question,N'Xóa stack trace và không ghi nhận',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Vì sao nên tránh lặp lại cùng một quy tắc nghiệp vụ ở nhiều nơi?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Để loại bỏ mọi phương thức',0,1),
        (@question,N'Để không cần review code',0,2),
        (@question,N'Giảm nguy cơ sửa thiếu và hành vi không nhất quán',1,3),
        (@question,N'Để mọi biến thành global',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Unit test tốt nên kiểm tra điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ số lượng dòng mã',0,1),
        (@question,N'Tên tác giả commit',0,2),
        (@question,N'Thứ tự ngẫu nhiên của các test khác',0,3),
        (@question,N'Hành vi có thể quan sát của đơn vị được kiểm thử',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Mẫu Arrange–Act–Assert gồm những bước nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chuẩn bị, thực hiện, kiểm tra kết quả',1,1),
        (@question,N'Commit, push, merge',0,2),
        (@question,N'Đăng nhập, đăng xuất, xóa user',0,3),
        (@question,N'Tải file, đổi tên, đóng máy',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi kiểm thử đầu vào, trường hợp nào cần được cân nhắc?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ một giá trị đẹp nhất',0,1),
        (@question,N'Giá trị hợp lệ, biên và không hợp lệ',1,2),
        (@question,N'Chỉ dữ liệu production',0,3),
        (@question,N'Chỉ chuỗi rỗng cho mọi hàm',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Review mã nguồn nên ưu tiên điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Sở thích cá nhân không giải thích',0,1),
        (@question,N'Chỉ đếm số ký tự',0,2),
        (@question,N'Tính đúng, khả năng đọc, bảo trì và tuân thủ quy ước',1,3),
        (@question,N'Bỏ qua logic nếu tên file đẹp',0,4);
END;

SET @material = NULL;
SELECT TOP (1) @material=material_id FROM dbo.Learning_Materials
WHERE title=N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026' AND is_deleted=0 AND status=1 ORDER BY material_id;
IF @material IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Test_Content WITH (UPDLOCK,HOLDLOCK)
    WHERE learning_material_id=@material AND is_deleted=0)
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
    SELECT LEFT(N'Học liệu: '+title,200),
        N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. '+COALESCE(description,N''),
        'quiz','learning',department_id,created_by,'ready',material_id
    FROM dbo.Learning_Materials WHERE material_id=@material;
    SET @content=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khẩu hiệu hành động trong checkpoint của video là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tối ưu quy trình - Nâng tầm giải pháp công nghệ',1,1),
        (@question,N'Chấp nhận mọi rủi ro để tăng trưởng bằng mọi giá',0,2),
        (@question,N'Giữ nguyên hiện trạng, không thay đổi công nghệ cũ',0,3),
        (@question,N'Tập trung cá nhân, hạn chế tinh thần làm việc nhóm',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tìm hiểu lịch sử hình thành công ty giúp nhân viên hiểu điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Mật khẩu tài khoản đồng nghiệp',0,1),
        (@question,N'Bối cảnh phát triển và những giá trị được xây dựng',1,2),
        (@question,N'Đáp án mọi bài kiểm tra kỹ thuật',0,3),
        (@question,N'Lịch nghỉ riêng của lãnh đạo',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tầm nhìn hỗ trợ việc ra quyết định như thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Thay thế mọi dữ liệu thực tế',0,1),
        (@question,N'Chỉ quyết định màu đồng phục',0,2),
        (@question,N'Tạo định hướng dài hạn cho lựa chọn và ưu tiên',1,3),
        (@question,N'Loại bỏ trách nhiệm cá nhân',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sứ mệnh giúp nhân viên liên hệ công việc với điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Sở thích giải trí của đồng nghiệp',0,1),
        (@question,N'Kích thước văn phòng',0,2),
        (@question,N'Số lượng email quảng cáo',0,3),
        (@question,N'Giá trị doanh nghiệp tạo ra cho khách hàng và cộng đồng',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Định hướng phát triển bền vững cần cân nhắc điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Kết quả lâu dài cùng trách nhiệm với con người và môi trường',1,1),
        (@question,N'Lợi ích ngắn hạn bằng mọi giá',0,2),
        (@question,N'Che giấu mọi tác động tiêu cực',0,3),
        (@question,N'Chỉ tăng giờ làm liên tục',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Môi trường làm việc tôn trọng con người thể hiện qua hành vi nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Phân biệt đối xử',0,1),
        (@question,N'Lắng nghe và đối xử công bằng',1,2),
        (@question,N'Công kích khi người khác góp ý',0,3),
        (@question,N'Ngăn mọi trao đổi giữa các nhóm',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Đổi mới sáng tạo trong công việc nên được thực hiện thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Thay đổi tùy tiện không trao đổi',0,1),
        (@question,N'Luôn từ chối ý tưởng mới',0,2),
        (@question,N'Đề xuất cải tiến có mục tiêu và đánh giá kết quả',1,3),
        (@question,N'Bỏ mọi quy trình kiểm soát',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tối ưu quy trình nên bắt đầu từ đâu?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tăng bước duyệt mà không đánh giá',0,1),
        (@question,N'Đổi tên mọi biểu mẫu',0,2),
        (@question,N'Xóa toàn bộ tài liệu hướng dẫn',0,3),
        (@question,N'Xác định điểm nghẽn và nhu cầu thực tế',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Nâng tầm giải pháp công nghệ hướng tới điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Cải thiện giá trị và chất lượng giải pháp cho người dùng',1,1),
        (@question,N'Chọn công nghệ chỉ vì đang nổi tiếng',0,2),
        (@question,N'Tăng độ phức tạp bất kể nhu cầu',0,3),
        (@question,N'Loại bỏ mọi phản hồi khách hàng',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi mục tiêu cá nhân chưa phù hợp định hướng chung, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự bỏ mục tiêu của nhóm',0,1),
        (@question,N'Trao đổi để điều chỉnh mục tiêu và cách đóng góp',1,2),
        (@question,N'Giấu tiến độ',0,3),
        (@question,N'Ngừng phối hợp với đồng nghiệp',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Tinh thần phối hợp giữa các bộ phận được thể hiện thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giữ mọi thông tin để tạo lợi thế cá nhân',0,1),
        (@question,N'Đổ lỗi qua lại',0,2),
        (@question,N'Chia sẻ thông tin cần thiết qua kênh phù hợp',1,3),
        (@question,N'Chỉ hỗ trợ người quen',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Phản hồi của nhân viên có thể đóng góp gì cho môi trường làm việc?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tự động thay thế mọi quyết định quản lý',0,1),
        (@question,N'Bảo đảm mọi ý kiến đều phải được áp dụng',0,2),
        (@question,N'Chỉ dùng để so sánh cá nhân',0,3),
        (@question,N'Giúp phát hiện vấn đề và đề xuất cải tiến',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi truyền đạt thông tin về công ty, nên ưu tiên nguồn nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Nội dung chính thức đã được xác nhận',1,1),
        (@question,N'Tin đồn chưa kiểm chứng',0,2),
        (@question,N'Bình luận ẩn danh',0,3),
        (@question,N'Thông tin tự suy diễn',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Hành động nào thể hiện trách nhiệm với định hướng chung?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ hoàn thành việc dễ nhìn thấy',0,1),
        (@question,N'Thực hiện cam kết và chủ động báo cáo trở ngại',1,2),
        (@question,N'Bỏ qua chất lượng để báo xong sớm',0,3),
        (@question,N'Đẩy trách nhiệm cho người khác',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sau khi xem video định hướng, nhân viên nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ ghi nhớ độ dài video',0,1),
        (@question,N'Bỏ qua các kênh trao đổi chính thức',0,2),
        (@question,N'Liên hệ giá trị và mục tiêu chung với công việc của mình',1,3),
        (@question,N'Coi định hướng là trách nhiệm riêng của lãnh đạo',0,4);
END;

SET @material = NULL;
SELECT TOP (1) @material=material_id FROM dbo.Learning_Materials
WHERE title=N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp' AND is_deleted=0 AND status=1 ORDER BY material_id;
IF @material IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Test_Content WITH (UPDLOCK,HOLDLOCK)
    WHERE learning_material_id=@material AND is_deleted=0)
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
    SELECT LEFT(N'Học liệu: '+title,200),
        N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. '+COALESCE(description,N''),
        'quiz','learning',department_id,created_by,'ready',material_id
    FROM dbo.Learning_Materials WHERE material_id=@material;
    SET @content=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Mật khẩu nào có đặc điểm an toàn hơn?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Dài, khó đoán và riêng cho từng tài khoản',1,1),
        (@question,N'Tên công ty kèm 123',0,2),
        (@question,N'Ngày sinh công khai',0,3),
        (@question,N'Một mật khẩu dùng cho mọi dịch vụ',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Xác thực đa yếu tố có tác dụng gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Cho phép chia sẻ tài khoản an toàn',0,1),
        (@question,N'Bổ sung lớp xác minh ngoài mật khẩu',1,2),
        (@question,N'Thay thế mọi biện pháp bảo mật',0,3),
        (@question,N'Công khai mã OTP cho đồng nghiệp',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi nhận email yêu cầu đăng nhập khẩn cấp qua link lạ, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Bấm link và nhập mật khẩu ngay',0,1),
        (@question,N'Chuyển tiếp cho mọi người làm theo',0,2),
        (@question,N'Kiểm tra qua kênh chính thức và báo bộ phận phụ trách',1,3),
        (@question,N'Gửi kèm mã OTP để xác nhận',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Phishing thường nhằm mục đích gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Tăng tốc đường truyền',0,1),
        (@question,N'Sửa lỗi giao diện tự động',0,2),
        (@question,N'Nén file an toàn',0,3),
        (@question,N'Lừa người dùng cung cấp thông tin hoặc thực hiện hành động nguy hiểm',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Trước khi mở tệp đính kèm bất ngờ, cần làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Xác minh người gửi và mức độ tin cậy của tệp',1,1),
        (@question,N'Tắt phần mềm bảo vệ',0,2),
        (@question,N'Mở ngay vì có logo công ty',0,3),
        (@question,N'Đổi đuôi file rồi chạy',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Nguyên tắc đặc quyền tối thiểu nghĩa là gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Cấp quyền admin cho mọi người',0,1),
        (@question,N'Chỉ cấp quyền cần thiết cho nhiệm vụ',1,2),
        (@question,N'Chia sẻ tài khoản quản trị',0,3),
        (@question,N'Giữ quyền cũ vĩnh viễn',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'API key và mật khẩu database nên được lưu thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Trong repository public',0,1),
        (@question,N'Trong bình luận của mã JavaScript gửi xuống client',0,2),
        (@question,N'Trong cơ chế quản lý bí mật phù hợp, ngoài mã nguồn công khai',1,3),
        (@question,N'Trong ảnh chụp đăng lên mạng',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Nếu đã commit nhầm secret vào repository, nên làm gì trước hết?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Chỉ xóa dòng ở commit mới rồi coi như an toàn',0,1),
        (@question,N'Đổi tên repository',0,2),
        (@question,N'Tắt máy cá nhân',0,3),
        (@question,N'Thu hồi hoặc thay secret bị lộ và báo sự cố',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi rời máy làm việc, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Khóa màn hình',1,1),
        (@question,N'Để session quản trị mở sẵn',0,2),
        (@question,N'Gửi mật khẩu cho người ngồi cạnh',0,3),
        (@question,N'Tắt mọi kiểm soát truy cập',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Chia sẻ dữ liệu nội bộ cần tuân thủ điều gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Bất kỳ link công khai nào cũng phù hợp',0,1),
        (@question,N'Đúng người nhận, quyền truy cập và kênh được phép',1,2),
        (@question,N'Gửi toàn bộ dữ liệu để tiết kiệm thời gian',0,3),
        (@question,N'Dùng tài khoản người khác',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi nghi ngờ tài khoản bị chiếm quyền, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giấu sự việc',0,1),
        (@question,N'Tiếp tục dùng rồi chờ tự hết',0,2),
        (@question,N'Báo ngay qua kênh xử lý sự cố và thực hiện hướng dẫn bảo vệ tài khoản',1,3),
        (@question,N'Gửi mật khẩu lên nhóm chat',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Sao lưu dữ liệu có ý nghĩa gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Thay thế hoàn toàn kiểm soát truy cập',0,1),
        (@question,N'Cho phép bỏ qua mọi cập nhật bảo mật',0,2),
        (@question,N'Bảo đảm không bao giờ có sự cố',0,3),
        (@question,N'Hỗ trợ khôi phục khi dữ liệu bị mất hoặc hỏng',1,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Vì sao cần cập nhật bản vá bảo mật?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Giảm nguy cơ bị khai thác lỗ hổng đã biết',1,1),
        (@question,N'Để công khai mọi dữ liệu',0,2),
        (@question,N'Để không cần mật khẩu',0,3),
        (@question,N'Để tự động cấp quyền quản trị',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Dữ liệu nhạy cảm trong log nên được xử lý thế nào?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Ghi đầy đủ mật khẩu để dễ debug',0,1),
        (@question,N'Hạn chế ghi và che thông tin theo quy định',1,2),
        (@question,N'Gửi log công khai cho mọi người',0,3),
        (@question,N'Luôn ghi mã OTP rõ ràng',0,4);
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Khi nhận yêu cầu chuyển dữ liệu từ người tự xưng là lãnh đạo, nên làm gì?','single');
    SET @question=SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question,N'Làm ngay chỉ vì lời nhắn khẩn',0,1),
        (@question,N'Bỏ qua quy định bảo mật',0,2),
        (@question,N'Xác minh danh tính và thẩm quyền qua kênh độc lập',1,3),
        (@question,N'Gửi cả thông tin không được yêu cầu',0,4);
END;
COMMIT;
-- END LEARNING TEST BANK SEED
GO

-- =======================================================
-- 9. SEED DATA: CHECKPOINT VIDEO & LỚP ĐÀO TẠO (VIDEO CHECKPOINTS & TRAINING CLASSES)
-- =======================================================


-- Checkpoint câu hỏi dừng tương tác cho Video Bài Giảng Java Backend
DECLARE @video_mat_id INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE' ORDER BY material_id);

IF @video_mat_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Video_Checkpoints (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
SELECT src.material_id, src.stop_time_seconds, src.question_prompt, src.option_a, src.option_b, src.option_c, src.option_d, src.correct_option, src.explanation
FROM (
    SELECT s.material_id AS material_id,
        s.stop_time_seconds AS stop_time_seconds,
        s.question_prompt AS question_prompt,
        s.option_a AS option_a,
        s.option_b AS option_b,
        s.option_c AS option_c,
        s.option_d AS option_d,
        s.correct_option AS correct_option,
        s.explanation AS explanation
    FROM (VALUES
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
     N'Chính xác! PreparedStatement tự động xử lý ký tự đặc biệt và ngăn chặn kẻ tấn công chèn mã SQL độc hại.')
    ) AS s (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Video_Checkpoints existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.material_id=src.material_id OR (existing.material_id IS NULL AND src.material_id IS NULL)) AND (existing.stop_time_seconds=src.stop_time_seconds OR (existing.stop_time_seconds IS NULL AND src.stop_time_seconds IS NULL)));
END;
GO

-- Checkpoint câu hỏi dừng tương tác cho Video Giới Thiệu Tầm Nhìn & Môi Trường Làm Việc
DECLARE @video_culture_id INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026' ORDER BY material_id);

IF @video_culture_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Video_Checkpoints (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
SELECT src.material_id, src.stop_time_seconds, src.question_prompt, src.option_a, src.option_b, src.option_c, src.option_d, src.correct_option, src.explanation
FROM (
    SELECT s.material_id AS material_id,
        s.stop_time_seconds AS stop_time_seconds,
        s.question_prompt AS question_prompt,
        s.option_a AS option_a,
        s.option_b AS option_b,
        s.option_c AS option_c,
        s.option_d AS option_d,
        s.correct_option AS correct_option,
        s.explanation AS explanation
    FROM (VALUES
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
     N'Chính xác! Mọi trao đổi và tài liệu dự án phải được thực hiện trên kênh chính thức để đảm bảo tính minh bạch và an toàn dữ liệu.')
    ) AS s (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Video_Checkpoints existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.material_id=src.material_id OR (existing.material_id IS NULL AND src.material_id IS NULL)) AND (existing.stop_time_seconds=src.stop_time_seconds OR (existing.stop_time_seconds IS NULL AND src.stop_time_seconds IS NULL)));
END;
GO

-- Lớp đào tạo mẫu
INSERT INTO dbo.Training_Classes (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
SELECT src.class_code, src.class_name, src.description, src.department_id, src.target_position_id, src.target_level_id, src.mentor_id, src.start_date, src.end_date, src.status, src.created_by
FROM (
    SELECT s.class_code AS class_code,
        s.class_name AS class_name,
        s.description AS description,
        (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name=CASE s.department_id WHEN 1 THEN N'Phòng Kỹ Thuật (IT)' WHEN 2 THEN N'Phòng Nhân Sự (HR)' WHEN 3 THEN N'Phòng Kinh Doanh (Sales)' WHEN 4 THEN N'Phòng Marketing & Truyền Thông' WHEN 5 THEN N'Phòng Kế Toán - Tài Chính' END ORDER BY department_id) AS department_id,
        (SELECT TOP (1) position_id FROM dbo.Positions WHERE position_name=CASE s.target_position_id WHEN 1 THEN N'Java Developer' WHEN 2 THEN N'Frontend Developer' WHEN 3 THEN N'QA / Software Tester' WHEN 4 THEN N'HR Officer' WHEN 5 THEN N'Sales Executive' END ORDER BY position_id) AS target_position_id,
        (SELECT TOP (1) level_id FROM dbo.Job_Levels WHERE level_name=CASE s.target_level_id WHEN 1 THEN N'Intern' WHEN 2 THEN N'Fresher' WHEN 3 THEN N'Junior' WHEN 4 THEN N'Middle' WHEN 5 THEN N'Senior' WHEN 6 THEN N'Lead' END ORDER BY level_id) AS target_level_id,
        (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.mentor_id WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS mentor_id,
        s.start_date AS start_date,
        s.end_date AS end_date,
        s.status AS status,
        (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.created_by WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS created_by
    FROM (VALUES
('CLS-IT-FRESHER-2026',
 N'Khóa Đào Tạo Onboarding Kỹ Thuật Cho Fresher 2026',
 N'Lớp đào tạo nền tảng kiến thức công nghệ, văn hóa làm việc và quy trình kỹ thuật dành cho các bạn Fresher/Junior mới gia nhập phòng IT.',
 1, 1, 2, 3, CAST(GETDATE() AS DATE), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'OPEN', 2)
    ) AS s (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Training_Classes existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.class_code=src.class_code OR (existing.class_code IS NULL AND src.class_code IS NULL)));
GO

-- Gắn học liệu chuẩn công nghệ vào lớp đào tạo
DECLARE @class_id INT = (SELECT TOP 1 class_id FROM dbo.Training_Classes WHERE class_code = 'CLS-IT-FRESHER-2026');
DECLARE @id_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty' ORDER BY material_id);
DECLARE @id_video_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026' ORDER BY material_id);
DECLARE @id_security INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp' ORDER BY material_id);
DECLARE @id_agile INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum' ORDER BY material_id);
DECLARE @id_cleancode INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)' ORDER BY material_id);
DECLARE @id_backend INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE' ORDER BY material_id);

IF @class_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory)
SELECT src.class_id, src.material_id, src.order_index, src.is_mandatory
FROM (
    SELECT s.class_id AS class_id,
        s.material_id AS material_id,
        s.order_index AS order_index,
        s.is_mandatory AS is_mandatory
    FROM (VALUES
(@class_id, @id_culture, 1, 1),
    (@class_id, @id_video_culture, 2, 1),
    (@class_id, @id_security, 3, 1),
    (@class_id, @id_agile, 4, 1),
    (@class_id, @id_cleancode, 5, 1),
    (@class_id, @id_backend, 6, 1)
    ) AS s (class_id, material_id, order_index, is_mandatory)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Class_Materials existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.class_id=src.class_id OR (existing.class_id IS NULL AND src.class_id IS NULL)) AND (existing.material_id=src.material_id OR (existing.material_id IS NULL AND src.material_id IS NULL)));
END;
GO

-- Ghi danh học viên Fresher vào lớp đào tạo và tạo tiến độ mẫu
DECLARE @class_id INT = (SELECT TOP 1 class_id FROM dbo.Training_Classes WHERE class_code = 'CLS-IT-FRESHER-2026');
IF @class_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Class_Enrollments (class_id, user_id, enrolled_by, enrollment_type, assigned_reason, status, progress_percent)
SELECT src.class_id, src.user_id, src.enrolled_by, src.enrollment_type, src.assigned_reason, src.status, src.progress_percent
FROM (
    SELECT s.class_id AS class_id,
        (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.user_id WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS user_id,
        (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.enrolled_by WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS enrolled_by,
        s.enrollment_type AS enrollment_type,
        s.assigned_reason AS assigned_reason,
        s.status AS status,
        s.progress_percent AS progress_percent
    FROM (VALUES
(@class_id, 4, 3, 'SMART_ASSIGN', N'Phân bổ tự động theo lộ trình vị trí Fresher Java Developer', 'IN_PROGRESS', 33)
    ) AS s (class_id, user_id, enrolled_by, enrollment_type, assigned_reason, status, progress_percent)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Class_Enrollments existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.class_id=src.class_id OR (existing.class_id IS NULL AND src.class_id IS NULL)) AND (existing.user_id=src.user_id OR (existing.user_id IS NULL AND src.user_id IS NULL)));

    DECLARE @id_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty' ORDER BY material_id);
    DECLARE @id_video_culture INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026' ORDER BY material_id);
    DECLARE @id_security INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp' ORDER BY material_id);

    IF @id_culture IS NOT NULL
        INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
SELECT src.user_id, src.material_id, src.class_id, src.status, src.last_accessed_at, src.completed_at, src.notes
FROM (
    SELECT (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.user_id WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS user_id,
        s.material_id AS material_id,
        s.class_id AS class_id,
        s.status AS status,
        s.last_accessed_at AS last_accessed_at,
        s.completed_at AS completed_at,
        s.notes AS notes
    FROM (VALUES
(4, @id_culture, @class_id, 'COMPLETED', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), N'Đã đọc xong sổ tay văn hóa doanh nghiệp')
    ) AS s (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Learning_Progress existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.user_id=src.user_id OR (existing.user_id IS NULL AND src.user_id IS NULL)) AND (existing.material_id=src.material_id OR (existing.material_id IS NULL AND src.material_id IS NULL)) AND (existing.class_id=src.class_id OR (existing.class_id IS NULL AND src.class_id IS NULL)));

    IF @id_video_culture IS NOT NULL
        INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
SELECT src.user_id, src.material_id, src.class_id, src.status, src.last_accessed_at, src.completed_at, src.notes
FROM (
    SELECT (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.user_id WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS user_id,
        s.material_id AS material_id,
        s.class_id AS class_id,
        s.status AS status,
        s.last_accessed_at AS last_accessed_at,
        s.completed_at AS completed_at,
        s.notes AS notes
    FROM (VALUES
(4, @id_video_culture, @class_id, 'COMPLETED', DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), N'Đã xem xong video giới thiệu và hoàn thành câu hỏi tương tác')
    ) AS s (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Learning_Progress existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.user_id=src.user_id OR (existing.user_id IS NULL AND src.user_id IS NULL)) AND (existing.material_id=src.material_id OR (existing.material_id IS NULL AND src.material_id IS NULL)) AND (existing.class_id=src.class_id OR (existing.class_id IS NULL AND src.class_id IS NULL)));

    IF @id_security IS NOT NULL
        INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
SELECT src.user_id, src.material_id, src.class_id, src.status, src.last_accessed_at, src.completed_at, src.notes
FROM (
    SELECT (SELECT TOP (1) user_id FROM dbo.Users WHERE username=CASE s.user_id WHEN 1 THEN N'admin' WHEN 2 THEN N'hr_manager' WHEN 3 THEN N'manager_it' WHEN 4 THEN N'dev_fresher' WHEN 5 THEN N'dev_tester' WHEN 6 THEN N'mentor_java' WHEN 7 THEN N'locked_user' END ORDER BY user_id) AS user_id,
        s.material_id AS material_id,
        s.class_id AS class_id,
        s.status AS status,
        s.last_accessed_at AS last_accessed_at,
        s.completed_at AS completed_at,
        s.notes AS notes
    FROM (VALUES
(4, @id_security, @class_id, 'IN_PROGRESS', GETDATE(), NULL, N'Đang nghiên cứu cẩm nang an toàn thông tin & bảo mật')
    ) AS s (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
) AS src
WHERE NOT EXISTS (SELECT 1 FROM dbo.Learning_Progress existing WITH (UPDLOCK,HOLDLOCK) WHERE (existing.user_id=src.user_id OR (existing.user_id IS NULL AND src.user_id IS NULL)) AND (existing.material_id=src.material_id OR (existing.material_id IS NULL AND src.material_id IS NULL)) AND (existing.class_id=src.class_id OR (existing.class_id IS NULL AND src.class_id IS NULL)));
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
