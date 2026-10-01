-- =======================================================
-- SQL Server Script: create_tables_sqlserver.sql
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB
-- Thư mục: database/schema/
-- Mô tả: Tạo Database và toàn bộ các Bảng DDL (Hệ thống HRM, Flashcard, Mentor, Học liệu & Đào tạo, Bài test)
-- =======================================================

USE master;
GO

-- 1. Xóa database nếu đã tồn tại
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HRM_Project_DB')
BEGIN
    ALTER DATABASE HRM_Project_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HRM_Project_DB;
END
GO

-- 2. Tạo database mới
CREATE DATABASE HRM_Project_DB;
GO

-- 3. Sử dụng database HRM_Project_DB
USE HRM_Project_DB;
GO

-- =======================================================
-- 1. BẢNG PHÂN QUYỀN (ROLES)
-- =======================================================
CREATE TABLE dbo.Roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE, -- 'ADMIN', 'HR', 'MANAGER', 'EMPLOYEE', 'MENTOR'
    description NVARCHAR(255) NULL
);
GO

-- =======================================================
-- 2. BẢNG PHÒNG BAN (DEPARTMENTS)
-- =======================================================
CREATE TABLE dbo.Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name NVARCHAR(100) NOT NULL UNIQUE,
    manager_id INT NULL, -- Trưởng phòng phụ trách
    description NVARCHAR(500) NULL,
    status BIT DEFAULT 1, -- 1: Hoạt động, 0: Tạm ngưng
    is_deleted BIT DEFAULT 0, -- 0: Tồn tại, 1: Đã xóa mềm
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- =======================================================
-- 3. BẢNG VỊ TRÍ CÔNG VIỆC (POSITIONS)
-- =======================================================
CREATE TABLE dbo.Positions (
    position_id INT IDENTITY(1,1) PRIMARY KEY,
    position_name NVARCHAR(100) NOT NULL,
    department_id INT NULL, -- Thuộc phòng ban nào
    description NVARCHAR(500) NULL,
    status BIT DEFAULT 1,
    is_deleted BIT DEFAULT 0, -- 0: Tồn tại, 1: Đã xóa mềm
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Positions_Department FOREIGN KEY (department_id) 
        REFERENCES dbo.Departments(department_id) ON DELETE SET NULL
);
GO

-- =======================================================
-- 4. BẢNG CẤP BẬC / NGẠCH CÔNG VIỆC (JOB_LEVELS)
-- =======================================================
CREATE TABLE dbo.Job_Levels (
    level_id INT IDENTITY(1,1) PRIMARY KEY,
    level_name NVARCHAR(50) NOT NULL UNIQUE, -- 'Intern', 'Fresher', 'Junior', 'Middle', 'Senior', 'Lead'
    rank_order INT NOT NULL,
    description NVARCHAR(255) NULL
);
GO

-- =======================================================
-- 5. BẢNG NHÂN SỰ (USERS)
-- =======================================================
CREATE TABLE dbo.Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    gender NVARCHAR(10) NULL,
    dob DATE NULL,
    role_id INT NOT NULL,
    department_id INT NULL,
    position_id INT NULL,
    level_id INT NULL,
    hire_date DATE NOT NULL DEFAULT GETDATE(),
    status BIT DEFAULT 1, -- 1: Đang làm việc, 0: Nghỉ việc / Khóa
    is_deleted BIT DEFAULT 0, -- 0: Tồn tại, 1: Đã xóa mềm
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Role FOREIGN KEY (role_id) 
        REFERENCES dbo.Roles(role_id),
    CONSTRAINT FK_Users_Department FOREIGN KEY (department_id) 
        REFERENCES dbo.Departments(department_id) ON DELETE SET NULL,
    CONSTRAINT FK_Users_Position FOREIGN KEY (position_id) 
        REFERENCES dbo.Positions(position_id) ON DELETE SET NULL,
    CONSTRAINT FK_Users_JobLevel FOREIGN KEY (level_id) 
        REFERENCES dbo.Job_Levels(level_id) ON DELETE SET NULL
);
GO

-- Gán khóa ngoại manager_id trong bảng Departments trỏ tới Users
ALTER TABLE dbo.Departments
ADD CONSTRAINT FK_Departments_Manager FOREIGN KEY (manager_id) 
    REFERENCES dbo.Users(user_id);
GO

-- RÀNG BUỘC TOÀN VẸN NGHIỆP VỤ (UNIQUE FILTERED INDEXES)
-- 1. Toàn bộ hệ thống chỉ có DUY NHẤT 1 Quản trị viên (ADMIN - role_id = 1)
CREATE UNIQUE NONCLUSTERED INDEX UQ_Users_SingleAdmin 
ON dbo.Users(role_id) 
WHERE role_id = 1 AND is_deleted = 0;
GO

-- 2. Mỗi phòng ban chỉ có DUY NHẤT 1 Trưởng phòng (MANAGER - role_id = 3)
CREATE UNIQUE NONCLUSTERED INDEX UQ_Users_SingleManagerPerDept 
ON dbo.Users(department_id) 
WHERE role_id = 3 AND is_deleted = 0 AND department_id IS NOT NULL;
GO

-- 3. Mỗi Trưởng phòng chỉ phụ trách tối đa 1 phòng ban
CREATE UNIQUE NONCLUSTERED INDEX UQ_Departments_SingleManager 
ON dbo.Departments(manager_id) 
WHERE manager_id IS NOT NULL AND is_deleted = 0;
GO

-- =======================================================
-- 6. BẢNG LỊCH SỬ BIẾN ĐỘNG (EMPLOYEE_HISTORY)
-- =======================================================
CREATE TABLE dbo.Employee_History (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    old_department_id INT NULL,
    new_department_id INT NULL,
    old_position_id INT NULL,
    new_position_id INT NULL,
    old_level_id INT NULL,
    new_level_id INT NULL,
    change_type VARCHAR(50) NOT NULL, -- 'NEW_HIRE', 'DEPARTMENT_TRANSFER', 'ROLE_CHANGE', 'PROMOTION'
    change_date DATETIME DEFAULT GETDATE(),
    notes NVARCHAR(500) NULL,
    created_by INT NULL,
    CONSTRAINT FK_EmpHistory_User FOREIGN KEY (user_id) 
        REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_EmpHistory_OldDept FOREIGN KEY (old_department_id) 
        REFERENCES dbo.Departments(department_id),
    CONSTRAINT FK_EmpHistory_NewDept FOREIGN KEY (new_department_id) 
        REFERENCES dbo.Departments(department_id),
    CONSTRAINT FK_EmpHistory_OldPos FOREIGN KEY (old_position_id) 
        REFERENCES dbo.Positions(position_id),
    CONSTRAINT FK_EmpHistory_NewPos FOREIGN KEY (new_position_id) 
        REFERENCES dbo.Positions(position_id),
    CONSTRAINT FK_EmpHistory_Creator FOREIGN KEY (created_by) 
        REFERENCES dbo.Users(user_id)
);
GO

-- =======================================================
-- 7. BẢNG FLASHCARD (FLASHCARD_DECKS & FLASHCARDS)
-- =======================================================
CREATE TABLE dbo.FlashcardDecks (
    deck_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX) NULL,
    created_at DATETIME NOT NULL CONSTRAINT DF_FlashcardDecks_CreatedAt DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.Flashcards (
    card_id INT IDENTITY(1,1) PRIMARY KEY,
    deck_id INT NOT NULL,
    question NVARCHAR(MAX) NOT NULL,
    answer NVARCHAR(MAX) NOT NULL,
    CONSTRAINT FK_Flashcards_Deck
        FOREIGN KEY (deck_id) REFERENCES dbo.FlashcardDecks(deck_id) ON DELETE CASCADE
);
GO

-- =======================================================
-- 8. BẢNG MENTOR (MENTOR_ASSIGNMENTS & MENTOR_EVALUATIONS)
-- =======================================================
CREATE TABLE dbo.MentorAssignments (
    assignment_id INT IDENTITY(1,1) PRIMARY KEY,
    mentee_id INT NOT NULL,
    mentor_id INT NOT NULL,
    position_id INT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    assigned_by INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (mentee_id) REFERENCES dbo.Users(user_id),
    FOREIGN KEY (mentor_id) REFERENCES dbo.Users(user_id),
    FOREIGN KEY (position_id) REFERENCES dbo.Positions(position_id)
);
GO

CREATE TABLE dbo.MentorEvaluations (
    evaluation_id INT IDENTITY(1,1) PRIMARY KEY,
    assignment_id INT NOT NULL,
    evaluator_id INT NOT NULL,
    performance_score INT,
    feedback NVARCHAR(MAX),
    approval_status VARCHAR(20) DEFAULT 'PENDING',
    evaluation_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (assignment_id) REFERENCES dbo.MentorAssignments(assignment_id)
);
GO

-- =======================================================
-- 9. BẢNG HỌC LIỆU & ĐÀO TẠO (LEARNING MATERIALS & TRAINING CLASSES)
-- =======================================================
CREATE TABLE dbo.Learning_Materials (
    material_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NULL,
    material_type VARCHAR(20) NOT NULL, -- 'PDF', 'SLIDE', 'VIDEO'
    scope_type VARCHAR(20) NOT NULL DEFAULT 'CULTURE', -- 'CULTURE' hoac 'DEPARTMENT'
    department_id INT NULL REFERENCES dbo.Departments(department_id),
    position_id INT NULL REFERENCES dbo.Positions(position_id),
    level_id INT NULL REFERENCES dbo.Job_Levels(level_id),
    
    -- Dành cho file upload (PDF, SLIDE, file VIDEO mp4/webm)
    file_name NVARCHAR(255) NULL,
    file_type VARCHAR(100) NULL,
    file_data VARBINARY(MAX) NULL,
    file_size BIGINT NULL,
    
    -- Dành cho Video nhúng (YouTube, Google Drive, Vimeo...)
    video_url NVARCHAR(500) NULL,
    duration_minutes INT NULL DEFAULT 15,
    
    status BIT DEFAULT 1,             -- 1: Hoạt động/Công bố, 0: Ẩn/Bản nháp
    is_deleted BIT DEFAULT 0,         -- Xóa mềm
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
GO

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
GO

CREATE TABLE dbo.Class_Materials (
    class_id INT NOT NULL REFERENCES dbo.Training_Classes(class_id) ON DELETE CASCADE,
    material_id INT NOT NULL REFERENCES dbo.Learning_Materials(material_id) ON DELETE CASCADE,
    order_index INT NOT NULL DEFAULT 1,
    is_mandatory BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (class_id, material_id)
);
GO

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
GO

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
GO

CREATE TABLE dbo.Video_Checkpoints (
    checkpoint_id INT IDENTITY(1,1) PRIMARY KEY,
    material_id INT NOT NULL REFERENCES dbo.Learning_Materials(material_id) ON DELETE CASCADE,
    stop_time_seconds INT NOT NULL, -- Thời điểm dừng (tính bằng giây)
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
GO

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
GO

-- BEGIN TEST MODULE
-- Migration bổ sung, chạy trên database HRM hiện có; không xóa dữ liệu.
-- Thời gian trong module luôn lưu UTC. Có thể chạy lại migration này.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID('dbo.Test_Content', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Content (
        id INT IDENTITY PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        prompt NVARCHAR(MAX) NOT NULL,
        kind VARCHAR(20) NOT NULL CHECK (kind IN ('quiz','question')),
        type VARCHAR(20) NOT NULL,
        department_id INT NULL REFERENCES dbo.Departments(department_id),
        created_by INT NOT NULL REFERENCES dbo.Users(user_id),
        status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','ready')),
        is_deleted BIT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT CK_Content_Scope CHECK (type IN ('culture','department'))
    );
END;

IF OBJECT_ID('dbo.Test_Questions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Questions (
        id INT IDENTITY PRIMARY KEY,
        content_id INT NOT NULL REFERENCES dbo.Test_Content(id),
        prompt NVARCHAR(4000) NOT NULL,
        option_a NVARCHAR(1000) NOT NULL,
        option_b NVARCHAR(1000) NOT NULL,
        option_c NVARCHAR(1000) NOT NULL,
        option_d NVARCHAR(1000) NOT NULL,
        correct_option INT NOT NULL CHECK (correct_option BETWEEN 0 AND 3)
    );
    CREATE INDEX IX_Questions_Content ON dbo.Test_Questions(content_id, id);
END;

IF OBJECT_ID('dbo.Test_Templates', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Templates (
        id INT IDENTITY PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX) NOT NULL,
        type VARCHAR(20) NOT NULL,
        department_id INT NULL REFERENCES dbo.Departments(department_id),
        created_by INT NOT NULL REFERENCES dbo.Users(user_id),
        status VARCHAR(20) NOT NULL DEFAULT 'draft',
        start_time DATETIME2 NOT NULL,
        end_time DATETIME2 NOT NULL,
        default_content_id INT NULL REFERENCES dbo.Test_Content(id),
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        is_deleted BIT NOT NULL DEFAULT 0,
        CONSTRAINT CK_Test_Type CHECK (type IN ('culture','department')),
        CONSTRAINT CK_Test_Status CHECK (status IN ('draft','published','closed')),
        CONSTRAINT CK_Test_Time CHECK (start_time < end_time)
    );
    CREATE INDEX IX_Test_Scope ON dbo.Test_Templates(department_id, status, start_time);
END;

IF OBJECT_ID('dbo.Test_Assignments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Assignments (
        id INT IDENTITY PRIMARY KEY,
        test_template_id INT NOT NULL REFERENCES dbo.Test_Templates(id),
        assignee_id INT NOT NULL REFERENCES dbo.Users(user_id),
        assigned_by INT NOT NULL REFERENCES dbo.Users(user_id),
        content_id INT NULL REFERENCES dbo.Test_Content(id),
        status VARCHAR(20) NOT NULL DEFAULT 'pending',
        quiz_score DECIMAL(4,2) NULL CHECK (quiz_score BETWEEN 0 AND 10),
        assigned_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        submitted_at DATETIME2 NULL,
        submission_content NVARCHAR(MAX) NULL,
        file_name NVARCHAR(200) NULL,
        file_data VARBINARY(MAX) NULL,
        is_deleted BIT NOT NULL DEFAULT 0,
        CONSTRAINT UQ_Test_Assignee UNIQUE (test_template_id, assignee_id),
        CONSTRAINT CK_Assignment_Status CHECK (status IN ('pending','in_progress','submitted','evaluated')),
        CONSTRAINT CK_Submission_Time CHECK ((status IN ('pending','in_progress') AND submitted_at IS NULL)
            OR (status IN ('submitted','evaluated') AND submitted_at IS NOT NULL)),
        CONSTRAINT CK_Submission_File CHECK ((file_name IS NULL AND file_data IS NULL)
            OR (file_name IS NOT NULL AND file_data IS NOT NULL AND DATALENGTH(file_data) BETWEEN 1 AND 5242880))
    );
    CREATE INDEX IX_Assignment_Owner ON dbo.Test_Assignments(assignee_id, status);
END;

IF OBJECT_ID('dbo.Test_Answers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Answers (
        assignment_id INT NOT NULL REFERENCES dbo.Test_Assignments(id),
        question_id INT NOT NULL REFERENCES dbo.Test_Questions(id),
        selected_option INT NOT NULL CHECK (selected_option BETWEEN 0 AND 3),
        PRIMARY KEY (assignment_id, question_id)
    );
END;

IF OBJECT_ID('dbo.Test_Evaluations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Evaluations (
        id INT IDENTITY PRIMARY KEY,
        test_assignment_id INT NOT NULL UNIQUE REFERENCES dbo.Test_Assignments(id),
        evaluator_id INT NOT NULL REFERENCES dbo.Users(user_id),
        score DECIMAL(4,2) NOT NULL CHECK (score BETWEEN 0 AND 10),
        comment NVARCHAR(4000) NOT NULL,
        evaluated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;

IF OBJECT_ID('dbo.Test_Reminder_Outbox', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Reminder_Outbox (
        id INT IDENTITY PRIMARY KEY,
        assignment_id INT NOT NULL REFERENCES dbo.Test_Assignments(id),
        scheduled_start DATETIME2 NOT NULL,
        delivered_at DATETIME2 NULL,
        CONSTRAINT UQ_Test_Reminder UNIQUE (assignment_id, scheduled_start)
    );
END;

IF OBJECT_ID('dbo.Test_Notifications', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Notifications (
        id INT IDENTITY PRIMARY KEY,
        outbox_id INT NOT NULL UNIQUE REFERENCES dbo.Test_Reminder_Outbox(id),
        user_id INT NOT NULL REFERENCES dbo.Users(user_id),
        assignment_id INT NOT NULL REFERENCES dbo.Test_Assignments(id),
        message NVARCHAR(300) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        read_at DATETIME2 NULL
    );
END;

IF OBJECT_ID('dbo.Test_Audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Audit (
        id BIGINT IDENTITY PRIMARY KEY,
        actor_id INT NOT NULL REFERENCES dbo.Users(user_id),
        action VARCHAR(40) NOT NULL,
        template_id INT NOT NULL REFERENCES dbo.Test_Templates(id),
        assignment_id INT NULL REFERENCES dbo.Test_Assignments(id),
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;

COMMIT;
