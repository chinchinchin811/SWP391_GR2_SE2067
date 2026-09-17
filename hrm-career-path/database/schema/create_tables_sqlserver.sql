-- =======================================================
-- SQL Server Script: create_tables_sqlserver.sql
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
