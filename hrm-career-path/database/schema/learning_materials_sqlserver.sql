-- =======================================================
-- SQL Server Migration: learning_materials_sqlserver.sql
-- Module: Học liệu (PDF, Slide, Video) & Lớp đào tạo & Video tương tác
-- Database: HRM_Project_DB
-- =======================================================

USE HRM_Project_DB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- 1. BANG HOC LIEU (LEARNING_MATERIALS)
IF OBJECT_ID('dbo.Learning_Materials', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Learning_Materials (
        material_id INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX) NULL,
        material_type VARCHAR(20) NOT NULL, -- 'PDF', 'SLIDE', 'VIDEO'
        scope_type VARCHAR(20) NOT NULL DEFAULT 'CULTURE', -- 'CULTURE' hoac 'DEPARTMENT'
        department_id INT NULL REFERENCES dbo.Departments(department_id),
        position_id INT NULL REFERENCES dbo.Positions(position_id),
        level_id INT NULL REFERENCES dbo.Job_Levels(level_id),
        
        -- Danh cho file upload (PDF, SLIDE, file VIDEO mp4/webm)
        file_name NVARCHAR(255) NULL,
        file_type VARCHAR(100) NULL,
        file_data VARBINARY(MAX) NULL,
        file_size BIGINT NULL,
        
        -- Danh cho Video nhung (YouTube, Google Drive, Vimeo...)
        video_url NVARCHAR(500) NULL,
        duration_minutes INT NULL DEFAULT 15,
        
        status BIT DEFAULT 1,             -- 1: Hoat dong/Cong bo, 0: An/Ban nhap
        is_deleted BIT DEFAULT 0,         -- Xoa mem
        created_by INT NOT NULL REFERENCES dbo.Users(user_id),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT CK_Material_Type CHECK (material_type IN ('PDF', 'SLIDE', 'VIDEO')),
        CONSTRAINT CK_Material_Scope CHECK (
            (scope_type = 'CULTURE' AND department_id IS NULL) OR
            (scope_type = 'DEPARTMENT' AND department_id IS NOT NULL)
        )
    );
    CREATE INDEX IX_Material_Dept_Type ON dbo.Learning_Materials(department_id, material_type, is_deleted);
END;

-- 2. BANG LOP DAO TAO (TRAINING_CLASSES)
IF OBJECT_ID('dbo.Training_Classes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Training_Classes (
        class_id INT IDENTITY(1,1) PRIMARY KEY,
        class_code VARCHAR(50) NOT NULL UNIQUE,
        class_name NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX) NULL,
        department_id INT NULL REFERENCES dbo.Departments(department_id),
        target_position_id INT NULL REFERENCES dbo.Positions(position_id),
        target_level_id INT NULL REFERENCES dbo.Job_Levels(level_id),
        mentor_id INT NULL REFERENCES dbo.Users(user_id),
        start_date DATE NOT NULL,
        end_date DATE NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
        is_deleted BIT DEFAULT 0,
        created_by INT NOT NULL REFERENCES dbo.Users(user_id),
        created_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT CK_Class_Status CHECK (status IN ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
    );
    CREATE INDEX IX_Class_Dept_Status ON dbo.Training_Classes(department_id, status, is_deleted);
END;

-- 3. BANG LIEN KET LOP HOC VA HOC LIEU (CLASS_MATERIALS)
IF OBJECT_ID('dbo.Class_Materials', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Class_Materials (
        class_id INT NOT NULL REFERENCES dbo.Training_Classes(class_id) ON DELETE CASCADE,
        material_id INT NOT NULL REFERENCES dbo.Learning_Materials(material_id) ON DELETE CASCADE,
        order_index INT NOT NULL DEFAULT 1,
        is_mandatory BIT NOT NULL DEFAULT 1,
        PRIMARY KEY (class_id, material_id)
    );
END;

-- 4. BANG GHI DANH NHAN SU VAO LOP (CLASS_ENROLLMENTS)
IF OBJECT_ID('dbo.Class_Enrollments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Class_Enrollments (
        enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
        class_id INT NOT NULL REFERENCES dbo.Training_Classes(class_id) ON DELETE CASCADE,
        user_id INT NOT NULL REFERENCES dbo.Users(user_id),
        enrolled_by INT NOT NULL REFERENCES dbo.Users(user_id),
        enrollment_type VARCHAR(30) NOT NULL DEFAULT 'MANUAL', -- 'SMART_ASSIGN', 'MANUAL'
        assigned_reason NVARCHAR(255) NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'ENROLLED', -- 'ENROLLED', 'IN_PROGRESS', 'PASSED', 'FAILED'
        progress_percent INT NOT NULL DEFAULT 0,
        enrolled_at DATETIME DEFAULT GETDATE(),
        completed_at DATETIME NULL,
        CONSTRAINT UQ_Class_User UNIQUE (class_id, user_id),
        CONSTRAINT CK_Enrollment_Status CHECK (status IN ('ENROLLED', 'IN_PROGRESS', 'PASSED', 'FAILED')),
        CONSTRAINT CK_Enrollment_Progress CHECK (progress_percent BETWEEN 0 AND 100)
    );
    CREATE INDEX IX_Enrollment_User ON dbo.Class_Enrollments(user_id, status);
END;

-- 5. BANG TIEN DO HOC TAP TUNG HOC LIEU (LEARNING_PROGRESS)
IF OBJECT_ID('dbo.Learning_Progress', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Learning_Progress (
        progress_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL REFERENCES dbo.Users(user_id),
        material_id INT NOT NULL REFERENCES dbo.Learning_Materials(material_id) ON DELETE CASCADE,
        class_id INT NULL REFERENCES dbo.Training_Classes(class_id),
        status VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED', -- 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
        last_accessed_at DATETIME DEFAULT GETDATE(),
        completed_at DATETIME NULL,
        notes NVARCHAR(500) NULL,
        CONSTRAINT UQ_User_Material_Class UNIQUE (user_id, material_id, class_id),
        CONSTRAINT CK_Progress_Status CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'))
    );
END;

-- 6. BANG MOC DUNG VIDEO & CAU HOI TRAC NGHIEM (VIDEO_CHECKPOINTS)
IF OBJECT_ID('dbo.Video_Checkpoints', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Video_Checkpoints (
        checkpoint_id INT IDENTITY(1,1) PRIMARY KEY,
        material_id INT NOT NULL REFERENCES dbo.Learning_Materials(material_id) ON DELETE CASCADE,
        stop_time_seconds INT NOT NULL, -- Thoi diem dung (tinh bang giay)
        question_prompt NVARCHAR(1000) NOT NULL,
        option_a NVARCHAR(500) NOT NULL,
        option_b NVARCHAR(500) NOT NULL,
        option_c NVARCHAR(500) NULL,
        option_d NVARCHAR(500) NULL,
        correct_option INT NOT NULL, -- 0: A, 1: B, 2: C, 3: D
        explanation NVARCHAR(1000) NULL,
        created_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT CK_Checkpoint_Correct CHECK (correct_option BETWEEN 0 AND 3),
        CONSTRAINT CK_Checkpoint_Time CHECK (stop_time_seconds >= 0)
    );
    CREATE INDEX IX_Checkpoints_Material ON dbo.Video_Checkpoints(material_id, stop_time_seconds);
END;

-- 7. BANG LUU KET QUA TRA LOI CAU HOI VIDEO (VIDEO_QUESTION_ANSWERS)
IF OBJECT_ID('dbo.Video_Question_Answers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Video_Question_Answers (
        answer_id INT IDENTITY(1,1) PRIMARY KEY,
        checkpoint_id INT NOT NULL REFERENCES dbo.Video_Checkpoints(checkpoint_id) ON DELETE CASCADE,
        user_id INT NOT NULL REFERENCES dbo.Users(user_id),
        selected_option INT NOT NULL,
        is_correct BIT NOT NULL,
        attempt_count INT NOT NULL DEFAULT 1,
        answered_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_Checkpoint_User UNIQUE (checkpoint_id, user_id)
    );
END;

COMMIT;

-- Nạp seed data mẫu
IF NOT EXISTS (SELECT 1 FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa & Quy Định Công Ty')
BEGIN
    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Sổ Tay Văn Hóa & Quy Định Công Ty', 
     N'Tài liệu định hướng nhân sự mới về tầm nhìn, sứ mệnh, giá trị cốt lõi và nội quy lao động công ty.', 
     'PDF', 'CULTURE', NULL, NULL, NULL, 'So_Tay_Van_Hoa_Doanh_Nghiep.pdf', 'application/pdf', NULL, 30, 1, 2);

    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Slide Giới Thiệu Quy Trình Phát Triển Phần Mềm Scrum/Agile', 
     N'Trình chiếu tổng quan về quy trình phối hợp Agile/Scrum, các buổi lễ Sprint và trách nhiệm vị trí.', 
     'SLIDE', 'DEPARTMENT', 1, 1, 2, 'Agile_Scrum_Onboarding.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', NULL, 45, 1, 3);

    INSERT INTO dbo.Learning_Materials 
    (title, description, material_type, scope_type, department_id, position_id, level_id, file_name, file_type, video_url, duration_minutes, status, created_by)
    VALUES 
    (N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE', 
     N'Video hướng dẫn chuẩn kiến trúc MVC, vòng đời Servlet và tương tác cơ sở dữ liệu qua JDBC trong dự án doanh nghiệp.', 
     'VIDEO', 'DEPARTMENT', 1, 1, 2, NULL, 'video/mp4', 'https://www.youtube.com/watch?v=kYJzphqI3qA', 25, 1, 3);

    DECLARE @video_id INT = SCOPE_IDENTITY();

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_id, 45, 
     N'Theo kiến trúc MVC trong Jakarta EE, tầng nào trực tiếp nhận và điều phối HTTP Request từ người dùng?',
     N'Model (Java Bean)',
     N'Controller (Servlet)',
     N'View (JSP/HTML)',
     N'DAL (Data Access Layer)',
     1, 
     N'Chính xác! Servlet đóng vai trò Controller, tiếp nhận request, kiểm tra xác thực và điều hướng tới Service/JSP.');

    INSERT INTO dbo.Video_Checkpoints 
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES 
    (@video_id, 120, 
     N'Để bảo vệ an toàn toàn vẹn dữ liệu khi thực hiện nhiều thao tác INSERT/UPDATE liên quan, kỹ thuật nào được áp dụng?',
     N'Bật AutoCommit = true',
     N'Sử dụng Statement thay vì PreparedStatement',
     N'Sử dụng Database Transaction (setAutoCommit(false), commit, rollback)',
     N'Bỏ qua việc bắt SQLException',
     2, 
     N'Chính xác! Database Transaction đảm bảo tính toàn vẹn (ACID) khi cập nhật nhiều bảng cùng lúc.');

    INSERT INTO dbo.Training_Classes 
    (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, created_by)
    VALUES 
    ('CLS-IT-FRESHER-2026', 
     N'Khóa Đào Tạo Onboarding Kỹ Thuật Cho Fresher 2026', 
     N'Lớp đào tạo nền tảng kiến thức công nghệ, văn hóa làm việc và quy trình kỹ thuật dành cho các bạn Fresher/Junior mới gia nhập phòng IT.', 
     1, 1, 2, 3, CAST(GETDATE() AS DATE), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'OPEN', 2);

    DECLARE @class_id INT = SCOPE_IDENTITY();

    -- Do not assume identity values start at 1: the migration can be run on
    -- a database that already contains materials.
    DECLARE @culture_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Sổ Tay Văn Hóa & Quy Định Công Ty');
    DECLARE @slide_id INT = (SELECT material_id FROM dbo.Learning_Materials WHERE title = N'Slide Giới Thiệu Quy Trình Phát Triển Phần Mềm Scrum/Agile');
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_id, @culture_id, 1, 1),
    (@class_id, @slide_id, 2, 1),
    (@class_id, @video_id, 3, 1);
END;
