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


UPDATE dbo.Departments SET manager_id = 3 WHERE department_id = 1;
UPDATE dbo.Departments SET manager_id = 2 WHERE department_id = 2;
GO


INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) VALUES
(4, NULL, 1, NULL, 1, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyen dung moi vi tri Java Developer', 2);
GO

-- =======================================================
-- SEED DATA: HỌC LIỆU (LEARNING MATERIALS) & LỚP ĐÀO TẠO
-- =======================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Learning_Materials WHERE title = N'So Tay Van Hoa & Quy Dinh Cong Ty')
BEGIN
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'So Tay Van Hoa & Quy Dinh Cong Ty', 
     N'Tai lieu dinh huong nhan su moi ve tam nhin, su menh, gia tri cot loi va noi quy lao dong cong ty.', 
     'PDF', 'CULTURE', NULL, NULL, NULL, 'So_Tay_Van_Hoa_Doanh_Nghiep.pdf', 'application/pdf', NULL, 30, 1, 2);

    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Slide Gioi Thieu Quy Trinh Phat Trien Phan Mem Scrum/Agile', 
     N'Trinh chieu tong quan ve quy trinh phoi hop Agile/Scrum, cac buoi le Sprint va trach nhiem vi tri.', 
     'SLIDE', 'DEPARTMENT', 1, 1, 2, 'Agile_Scrum_Onboarding.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', NULL, 45, 1, 3);

    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Video Bai Giang: Kien Truc Java Backend & Servlet Jakarta EE', 
     N'Video huong dan chuan kien truc MVC, vong doi Servlet va tuong tac co so du lieu qua JDBC trong du an doanh nghiep.', 
     'VIDEO', 'DEPARTMENT', 1, 1, 2, NULL, 'video/mp4', 'https://www.youtube.com/watch?v=kYJzphqI3qA', 25, 1, 3);

    DECLARE @video_id INT = SCOPE_IDENTITY();

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_id, 45, 
     N'Theo kien truc MVC trong Jakarta EE, tang nao truc tiep nhan va dieu phoi HTTP Request tu nguoi dung?',
     N'Model (Java Bean)',
     N'Controller (Servlet)',
     N'View (JSP/HTML)',
     N'DAL (Data Access Layer)',
     1, 
     N'Chinh xac! Servlet dong vai tro Controller, tiep nhan request, kiem tra xac thuc va dieu huong toi Service/JSP.');

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_id, 120, 
     N'De bao ve an toan toan ven du lieu khi thuc hien nhieu thao tac INSERT/UPDATE lien quan, ky thuat nao duoc ap dung?',
     N'Bat AutoCommit = true',
     N'Su dung Statement thay vi PreparedStatement',
     N'Su dung Database Transaction (setAutoCommit(false), commit, rollback)',
     N'Bo qua viec bat SQLException',
     2, 
     N'Chinh xac! Database Transaction dam bao tinh toan ven (ACID) khi cap nhat nhieu bang cung luc.');

    INSERT INTO dbo.Training_Classes 
    (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
    VALUES 
    ('CLS-IT-FRESHER-2026', 
     N'Khoa Dao Tao Onboarding Ky Thuat Cho Fresher 2026', 
     N'Lop dao tao nen tang kien thuc cong nghe, van hoa lam viec va quy trinh ky thuat danh cho cac ban Fresher/Junior moi gia nhap phong IT.', 
     1, 1, 2, 3, CAST(GETDATE() AS DATE), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'OPEN', 2);

    DECLARE @class_id INT = SCOPE_IDENTITY();

    DECLARE @culture_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'So Tay Van Hoa & Quy Dinh Cong Ty');
    DECLARE @slide_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Slide Gioi Thieu Quy Trinh Phat Trien Phan Mem Scrum/Agile');
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_id, @culture_id, 1, 1),
    (@class_id, @slide_id, 2, 1),
    (@class_id, @video_id, 3, 1);
END;
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
SELECT * FROM dbo.Learning_Materials;
SELECT * FROM dbo.Training_Classes;
SELECT * FROM dbo.Class_Materials;
SELECT * FROM dbo.Video_Checkpoints;
GO
