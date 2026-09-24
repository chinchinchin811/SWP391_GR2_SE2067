-- =======================================================
-- SQL Server Script: seed_data_sqlserver.sql
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB

USE HRM_Project_DB;
GO

INSERT INTO dbo.Roles (role_name, description) VALUES
('ADMIN', N'Quan tri vien he thong'),
('HR', N'Nhan su quan ly phong ban, vi tri va nhan vien'),
('MANAGER', N'Truong phong quan ly nhan vien trong phong ban cua minh'),
('EMPLOYEE', N'Nhan vien cong ty');
GO

INSERT INTO dbo.Roles (role_name, description) VALUES
('MENTOR', N'Nguoi huong dan va danh gia nhan vien moi');
GO

INSERT INTO dbo.Job_Levels (level_name, rank_order, description) VALUES
(N'Intern', 1, N'Thuc tap sinh'),
(N'Fresher', 2, N'Nhan vien moi vao nghe'),
(N'Junior', 3, N'Nhan vien co tu 1 - 2 nam kinh nghiem'),
(N'Middle', 4, N'Nhan vien tu 2 - 4 nam kinh nghiem'),
(N'Senior', 5, N'Chuyen vien tu 4+ nam kinh nghiem'),
(N'Lead', 6, N'Truong nhom chuyen mon');
GO


INSERT INTO dbo.Departments (department_name, description, status, is_deleted) VALUES
(N'Phong Ky Thuat (IT)', N'Phat trien va van hanh he thong', 1, 0),
(N'Phong Nhan Su (HR)', N'Tuyen dung va quan ly nhan su', 1, 0),
(N'Phong Kinh Doanh (Sales)', N'Kinh doanh va cham soc khach hang', 1, 0);
GO


INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted) VALUES
(N'Java Developer', 1, N'Lap trinh vien Java backend', 1, 0),
(N'Frontend Developer', 1, N'Lap trinh vien giao dien web', 1, 0),
(N'QA Tester', 1, N'Kiem thu phan mem', 1, 0),
(N'HR Officer', 2, N'Chuyen vien nhan su', 1, 0),
(N'Sales Executive', 3, N'Chuyen vien kinh doanh', 1, 0);
GO

INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted) VALUES
('admin', '123', N'Quan Tri Vien', 'admin@hrm.com', '0901000001', N'Nam', 1, 1, 1, 6, '2022-01-01', 1, 0),
('hr_manager', '123', N'Pham Thu Ha', 'ha.pt@hrm.com', '0901000002', N'Nu', 2, 2, 4, 5, '2022-03-15', 1, 0),
('manager_it', '123', N'Tran Van Minh', 'minh.tv@hrm.com', '0901000003', N'Nam', 3, 1, 1, 6, '2022-02-01', 1, 0),
('dev_fresher', '123', N'Pham Duc Trong', 'trong.pd@hrm.com', '0901000006', N'Nam', 4, 1, 1, 2, '2026-08-01', 1, 0),
('dev_tester', '123', N'Ngo Mai Phuong', 'phuong.nm@hrm.com', '0901000007', N'Nu', 4, 1, 3, 3, '2023-06-01', 1, 0);
GO

INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted) VALUES
('mentor_java', '123', N'Le Huu Mentor', 'mentor.java@hrm.com', '0988888888',
 N'Nam', 5, 1, 1, 5, '2021-01-01', 1, 0);
GO

UPDATE dbo.Users
SET role_id = 5
WHERE email = 'mentor.java@hrm.com';

UPDATE dbo.Users
SET role_id = (SELECT TOP 1 role_id FROM dbo.Roles WHERE role_name = 'MENTOR')
WHERE email = 'mentor.java@hrm.com';

UPDATE dbo.Departments SET manager_id = 3 WHERE department_id = 1;
UPDATE dbo.Departments SET manager_id = 2 WHERE department_id = 2;
GO


INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) VALUES
(4, NULL, 1, NULL, 1, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyen dung moi vi tri Java Developer', 2);
GO

-- =======================================================
-- FLASHCARD DATA
-- =======================================================

INSERT INTO dbo.FlashcardDecks (title, description) VALUES
(N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa công ty'),
(N'Chuyên môn', N'Kiến thức chuyên môn Java');
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
-- KIEM TRA DU LIEU: SELECT * FROM TAT CA BANG
-- =======================================================
SELECT * FROM dbo.Roles;
SELECT * FROM dbo.Job_Levels;
SELECT * FROM dbo.Departments;
SELECT * FROM dbo.Positions;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Employee_History;
SELECT * FROM dbo.Flashcards;
SELECT * FROM dbo.FlashcardDecks;
GO
