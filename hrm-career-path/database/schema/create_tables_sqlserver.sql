-- =======================================================
-- SQL Server Script: create_tables_sqlserver.sql
-- DDL: HRM + bai test + kho bo de/cau hoi. Seed nam trong database/seed_data/.
-- CHAY TOAN BO FILE SE XOA VA TAO LAI HRM_Project_DB (giu hanh vi script goc).
-- De cap nhat module tren DB da co: chon dung database va chi chay tu
-- moc BEGIN TEST MODULE o cuoi file; khong chay phan reset.
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB
-- Thu muc: database/schema/
-- Mo ta: Tao Database va cac Bang (DDL) ap dung Xoa Mem (Soft Delete)
-- =======================================================

USE master;
GO

-- 1. Xoa database neu da ton tai
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HRM_Project_DB')
BEGIN
    ALTER DATABASE HRM_Project_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HRM_Project_DB;
END
GO

-- 2. Tao database moi
CREATE DATABASE HRM_Project_DB;
GO

-- 3. Su dung database HRM_Project_DB
USE HRM_Project_DB;
GO

-- =======================================================
-- 1. BANG PHAN QUYEN (ROLES)
-- =======================================================
CREATE TABLE dbo.Roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE, -- 'ADMIN', 'HR', 'MANAGER', 'EMPLOYEE'
    description NVARCHAR(255) NULL
);
GO

-- =======================================================
-- 2. BANG PHONG BAN (DEPARTMENTS)
-- =======================================================
CREATE TABLE dbo.Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name NVARCHAR(100) NOT NULL UNIQUE,
    manager_id INT NULL, -- Truong phong phu trach
    description NVARCHAR(500) NULL,
    status BIT DEFAULT 1, -- 1: Hoat dong, 0: Tam ngung
    is_deleted BIT DEFAULT 0, -- 0: Ton tai, 1: Da xoa mem
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- =======================================================
-- 3. BANG VI TRI CONG VIEC (POSITIONS)
-- =======================================================
CREATE TABLE dbo.Positions (
    position_id INT IDENTITY(1,1) PRIMARY KEY,
    position_name NVARCHAR(100) NOT NULL,
    department_id INT NULL, -- Thuoc phong ban nao
    description NVARCHAR(500) NULL,
    status BIT DEFAULT 1,
    is_deleted BIT DEFAULT 0, -- 0: Ton tai, 1: Da xoa mem
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Positions_Department FOREIGN KEY (department_id) 
        REFERENCES dbo.Departments(department_id) ON DELETE SET NULL
);
GO

-- =======================================================
-- 4. BANG CAP BAC / NGACH CONG VIEC (JOB_LEVELS)
-- =======================================================
CREATE TABLE dbo.Job_Levels (
    level_id INT IDENTITY(1,1) PRIMARY KEY,
    level_name NVARCHAR(50) NOT NULL UNIQUE, -- 'Intern', 'Fresher', 'Junior', 'Middle', 'Senior', 'Lead'
    rank_order INT NOT NULL,
    description NVARCHAR(255) NULL
);
GO

-- =======================================================
-- 5. BANG NHAN SU (USERS)
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
    status BIT DEFAULT 1, -- 1: Dang lam viec, 0: Nghi viec / Khoa
    is_deleted BIT DEFAULT 0, -- 0: Ton tai, 1: Da xoa mem
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

-- Gan khoa ngoai manager_id trong bang Departments tro toi Users
ALTER TABLE dbo.Departments
ADD CONSTRAINT FK_Departments_Manager FOREIGN KEY (manager_id) 
    REFERENCES dbo.Users(user_id);
GO

-- =======================================================
-- 6. BANG LICH SU DIEU CHUYEN (EMPLOYEE_HISTORY)
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
-- 7. BANG FlashCard & Mentor
-- =======================================================
CREATE TABLE dbo.FlashcardDecks (
    deck_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE dbo.Flashcards (
    card_id INT IDENTITY(1,1) PRIMARY KEY,
    deck_id INT NOT NULL,
    question NVARCHAR(MAX) NOT NULL,
    answer NVARCHAR(MAX) NOT NULL,
    FOREIGN KEY (deck_id) REFERENCES dbo.FlashcardDecks(deck_id) ON DELETE CASCADE
);

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
-- BEGIN TEST MODULE
-- Migration bổ sung, chạy trên database HRM hiện có; không xóa dữ liệu.
-- Thời gian trong module luôn lưu UTC. Có thể chạy lại migration này.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

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
        status VARCHAR(20) NOT NULL DEFAULT 'pending',
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

-- Kho bộ đề/câu hỏi: thực hiện sau các bảng module bài test ở trên.
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
    CREATE INDEX IX_Questions_Content ON dbo.Test_Questions(content_id,id);
END;
IF COL_LENGTH('dbo.Test_Assignments','content_id') IS NULL
    ALTER TABLE dbo.Test_Assignments ADD content_id INT NULL REFERENCES dbo.Test_Content(id);
IF COL_LENGTH('dbo.Test_Templates','default_content_id') IS NULL
    ALTER TABLE dbo.Test_Templates ADD default_content_id INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Test_Templates_DefaultContent')
    ALTER TABLE dbo.Test_Templates ADD CONSTRAINT FK_Test_Templates_DefaultContent FOREIGN KEY(default_content_id) REFERENCES dbo.Test_Content(id);
IF COL_LENGTH('dbo.Test_Content','is_deleted') IS NULL
    ALTER TABLE dbo.Test_Content ADD is_deleted BIT NOT NULL CONSTRAINT DF_Test_Content_IsDeleted DEFAULT 0;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Test_Type')
    ALTER TABLE dbo.Test_Templates DROP CONSTRAINT CK_Test_Type;
ALTER TABLE dbo.Test_Templates ADD CONSTRAINT CK_Test_Type CHECK (type IN ('culture','department'));
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Content_Scope')
    ALTER TABLE dbo.Test_Content DROP CONSTRAINT CK_Content_Scope;
ALTER TABLE dbo.Test_Content ADD CONSTRAINT CK_Content_Scope CHECK (type IN ('culture','department'));
IF COL_LENGTH('dbo.Test_Assignments','quiz_score') IS NULL
    ALTER TABLE dbo.Test_Assignments ADD quiz_score DECIMAL(4,2) NULL CHECK (quiz_score BETWEEN 0 AND 10);
IF OBJECT_ID('dbo.Test_Answers','U') IS NULL
BEGIN
    CREATE TABLE dbo.Test_Answers (
        assignment_id INT NOT NULL REFERENCES dbo.Test_Assignments(id),
        question_id INT NOT NULL REFERENCES dbo.Test_Questions(id),
        selected_option INT NOT NULL CHECK (selected_option BETWEEN 0 AND 3),
        PRIMARY KEY (assignment_id,question_id)
    );
END;
COMMIT;
