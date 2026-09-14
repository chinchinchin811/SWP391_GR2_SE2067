-- =======================================================
-- SQL Server Script: create_tables_sqlserver.sql
-- Project: HRM & Career Path Management
-- Database: HRM_Project_DB
-- =======================================================

USE master;
GO

-- 1. Xóa database nếu đã tồn tại (đóng các kết nối đang mở trước khi drop)
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
-- TẠO CÁC BẢNG KHỞI TẠO CƠ BẢN
-- =======================================================

-- Bảng Roles (Phân quyền: Admin, HR Manager, Employee, ...)
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL
    DROP TABLE dbo.Roles;
GO

CREATE TABLE dbo.Roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(255) NULL
);
GO

-- Bảng Admin (Quản trị viên hệ thống)
IF OBJECT_ID('dbo.Admin', 'U') IS NOT NULL
    DROP TABLE dbo.Admin;
GO

CREATE TABLE dbo.Admin (
    admin_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    status BIT DEFAULT 1, -- 1: Hoạt động, 0: Khóa
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- =======================================================
-- CHÈN DỮ LIỆU MẪU (SEED DATA) BAN ĐẦU
-- =======================================================

INSERT INTO dbo.Roles (role_name, description) VALUES
(N'ADMIN', N'Quản trị viên toàn quyền hệ thống'),
(N'HR_MANAGER', N'Quản lý nhân sự và lộ trình nghề nghiệp'),
(N'EMPLOYEE', N'Nhân viên');
GO

-- Tài khoản Admin mặc định để kiểm tra đăng nhập: username: admin / password: 123
INSERT INTO dbo.Admin (username, password, full_name, email, phone, status)
VALUES ('admin', '123', N'Hệ Thống Quản Trị', 'admin@hrm.com', '0987654321', 1);
GO
