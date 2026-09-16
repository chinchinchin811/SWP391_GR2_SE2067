-- =======================================================
-- SQL Server Script: create_tables_sqlserver.sql
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB
-- Module: To chuc Vi tri, Quan ly Phong ban, Gan Manager, Khai bao & Phan bo Nhan su
-- Co che: Ap dung Xoa Mem (Soft Delete) qua cot is_deleted
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
-- 2. BANG PHONG BAN (DEPARTMENTS) - CO XOA MEM (is_deleted)
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
-- 3. BANG VI TRI CONG VIEC (POSITIONS) - CO XOA MEM (is_deleted)
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
-- 5. BANG NHAN SU (USERS) - CO XOA MEM (is_deleted)
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
-- 7. DU LIEU MAU KHOI TAO (SEED DATA)
-- =======================================================

-- 1. Roles
INSERT INTO dbo.Roles (role_name, description) VALUES
('ADMIN', N'Quan tri vien he thong'),
('HR', N'Nhan su quan ly phong ban, vi tri va nhan vien'),
('MANAGER', N'Truong phong quan ly nhan vien trong phong ban cua minh'),
('EMPLOYEE', N'Nhan vien cong ty');
GO

-- 2. Job Levels
INSERT INTO dbo.Job_Levels (level_name, rank_order, description) VALUES
(N'Intern', 1, N'Thuc tap sinh'),
(N'Fresher', 2, N'Nhan vien moi vao nghe'),
(N'Junior', 3, N'Nhan vien co tu 1 - 2 nam kinh nghiem'),
(N'Middle', 4, N'Nhan vien tu 2 - 4 nam kinh nghiem'),
(N'Senior', 5, N'Chuyen vien tu 4+ nam kinh nghiem'),
(N'Lead', 6, N'Truong nhom chuyen mon');
GO

-- 3. Departments
INSERT INTO dbo.Departments (department_name, description, status, is_deleted) VALUES
(N'Phong Ky Thuat (IT)', N'Phat trien va van hanh he thong', 1, 0),
(N'Phong Nhan Su (HR)', N'Tuyen dung va quan ly nhan su', 1, 0),
(N'Phong Kinh Doanh (Sales)', N'Kinh doanh va cham soc khach hang', 1, 0);
GO

-- 4. Positions
INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted) VALUES
(N'Java Developer', 1, N'Lap trinh vien Java backend', 1, 0),
(N'Frontend Developer', 1, N'Lap trinh vien giao dien web', 1, 0),
(N'QA Tester', 1, N'Kiem thu phan mem', 1, 0),
(N'HR Officer', 2, N'Chuyen vien nhan su', 1, 0),
(N'Sales Executive', 3, N'Chuyen vien kinh doanh', 1, 0);
GO

-- 5. Users
-- Mat khau mac dinh cho tat ca: 123
INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, role_id, department_id, position_id, level_id, hire_date, status, is_deleted) VALUES
('admin', '123', N'Quan Tri Vien', 'admin@hrm.com', '0901000001', N'Nam', 1, 1, 1, 6, '2022-01-01', 1, 0),
('hr_manager', '123', N'Pham Thu Ha', 'ha.pt@hrm.com', '0901000002', N'Nu', 2, 2, 4, 5, '2022-03-15', 1, 0),
('manager_it', '123', N'Tran Van Minh', 'minh.tv@hrm.com', '0901000003', N'Nam', 3, 1, 1, 6, '2022-02-01', 1, 0),
('dev_fresher', '123', N'Pham Duc Trong', 'trong.pd@hrm.com', '0901000006', N'Nam', 4, 1, 1, 2, '2026-08-01', 1, 0),
('dev_tester', '123', N'Ngo Mai Phuong', 'phuong.nm@hrm.com', '0901000007', N'Nu', 4, 1, 3, 3, '2023-06-01', 1, 0);
GO

-- 6. Cap nhat Truong phong cho Departments
UPDATE dbo.Departments SET manager_id = 3 WHERE department_id = 1;
UPDATE dbo.Departments SET manager_id = 2 WHERE department_id = 2;
GO

-- 7. Ghi nhan lich su mau
INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by) VALUES
(4, NULL, 1, NULL, 1, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyen dung moi vi tri Java Developer', 2);
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
GO
