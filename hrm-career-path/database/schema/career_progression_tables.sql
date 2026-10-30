-- =======================================================
-- BỔ SUNG CƠ SỞ DỮ LIỆU: LUỒNG LỘ TRÌNH THĂNG TIẾN & HỒ SƠ MINH CHỨNG NĂNG LỰC
-- Career Path Management System (CPMS)
-- =======================================================

USE HRM_Project_DB;
GO

-- 1. BẢNG CẤU HÌNH BAREM THĂNG CẤP (POSITION_LEVEL_CRITERIA)
IF OBJECT_ID('dbo.Position_Level_Criteria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Position_Level_Criteria (
        criteria_id INT IDENTITY(1,1) PRIMARY KEY,
        position_id INT NOT NULL REFERENCES dbo.Positions(position_id) ON DELETE CASCADE,
        from_level_id INT NOT NULL REFERENCES dbo.Job_Levels(level_id),
        to_level_id INT NOT NULL REFERENCES dbo.Job_Levels(level_id),
        
        -- Bài test sát hạch chuyên môn của cấp bậc đích
        target_test_template_id INT NULL REFERENCES dbo.Test_Templates(id),
        min_test_score DECIMAL(5,2) NULL DEFAULT 80.0,
        
        -- Tóm tắt năng lực cốt lõi yêu cầu
        competency_summary NVARCHAR(MAX) NOT NULL,
        
        -- Điểm đánh giá năng lực thực tế tối thiểu từ Manager (1 - 10)
        min_manager_rating DECIMAL(3,1) NULL DEFAULT 7.5,
        
        status BIT DEFAULT 1,                          -- 1: Áp dụng, 0: Tạm ngưng
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT UQ_Position_Progression UNIQUE (position_id, from_level_id, to_level_id)
    );
    PRINT 'Đã tạo bảng dbo.Position_Level_Criteria';
END
GO

-- 2. BẢNG TIÊU CHÍ MINH CHỨNG NĂNG LỰC (CRITERIA_REQUIREMENTS)
IF OBJECT_ID('dbo.Criteria_Requirements', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Criteria_Requirements (
        requirement_id INT IDENTITY(1,1) PRIMARY KEY,
        criteria_id INT NOT NULL REFERENCES dbo.Position_Level_Criteria(criteria_id) ON DELETE CASCADE,
        requirement_title NVARCHAR(255) NOT NULL,
        requirement_type VARCHAR(50) NOT NULL,         -- 'PROJECT_EXPERIENCE', 'CUSTOMER_SATISFACTION', 'CERTIFICATE', 'OTHER'
        description NVARCHAR(MAX) NULL,
        is_mandatory BIT DEFAULT 1,
        order_index INT DEFAULT 1
    );
    PRINT 'Đã tạo bảng dbo.Criteria_Requirements';
END
GO

-- 3. BẢNG HỒ SƠ ĐỀ XUẤT THĂNG CẤP (PROMOTION_REQUESTS)
IF OBJECT_ID('dbo.Promotion_Requests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Promotion_Requests (
        request_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL REFERENCES dbo.Users(user_id),
        position_id INT NOT NULL REFERENCES dbo.Positions(position_id),
        current_level_id INT NOT NULL REFERENCES dbo.Job_Levels(level_id),
        target_level_id INT NOT NULL REFERENCES dbo.Job_Levels(level_id),
        criteria_id INT NOT NULL REFERENCES dbo.Position_Level_Criteria(criteria_id),
        
        -- Kết quả bài test sát hạch
        test_assignment_id INT NULL REFERENCES dbo.Test_Assignments(id),
        test_score DECIMAL(5,2) NULL,
        
        -- Thẩm định & Đánh giá kín của Manager
        manager_id INT NULL REFERENCES dbo.Users(user_id),
        manager_rating DECIMAL(3,1) NULL,
        manager_confidential_notes NVARCHAR(MAX) NULL,
        manager_status VARCHAR(20) DEFAULT 'PENDING',  -- 'PENDING', 'RECOMMENDED', 'REJECTED'
        manager_action_date DATETIME NULL,
        
        -- Phê duyệt chính thức của HR
        hr_id INT NULL REFERENCES dbo.Users(user_id),
        hr_decision VARCHAR(20) DEFAULT 'PENDING',     -- 'PENDING', 'APPROVED', 'REJECTED'
        hr_notes NVARCHAR(500) NULL,
        hr_action_date DATETIME NULL,
        
        status VARCHAR(20) DEFAULT 'PENDING',          -- 'DRAFT', 'SUBMITTED', 'MANAGER_REVIEWED', 'APPROVED', 'REJECTED'
        created_at DATETIME DEFAULT GETDATE()
    );
    PRINT 'Đã tạo bảng dbo.Promotion_Requests';
END
GO

-- 4. BẢNG CHI TIẾT MINH CHỨNG NHÂN VIÊN NỘP (PROMOTION_EVIDENCE)
IF OBJECT_ID('dbo.Promotion_Evidence', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Promotion_Evidence (
        evidence_id INT IDENTITY(1,1) PRIMARY KEY,
        request_id INT NOT NULL REFERENCES dbo.Promotion_Requests(request_id) ON DELETE CASCADE,
        requirement_id INT NOT NULL REFERENCES dbo.Criteria_Requirements(requirement_id),
        
        evidence_summary NVARCHAR(MAX) NOT NULL,
        evidence_url NVARCHAR(1000) NULL,
        attachment_path NVARCHAR(500) NULL,
        
        -- Quản lý thẩm định
        is_verified BIT DEFAULT 0,
        verification_comment NVARCHAR(500) NULL,
        verified_at DATETIME NULL
    );
    PRINT 'Đã tạo bảng dbo.Promotion_Evidence';
END
GO

