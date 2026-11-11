-- =======================================================
-- SQL Server Script: seed_data_sqlserver.sql
-- Project: HRM & Career Path Management (SWP291 / SE2067)
-- Database: HRM_Project_DB
-- Thư mục: database/seed_data/
-- Mô tả: Dữ liệu mẫu khởi tạo toàn bộ hệ thống
-- Cấu trúc phòng ban: 4 phòng ban cốt lõi (Không có HR, không có tiền tố 'Phòng')
-- Quy mô nhân sự: Mỗi vị trí có ít nhất 5 nhân viên đầy đủ các cấp bậc (Intern, Fresher, Junior, Middle, Senior)
-- Lộ trình thăng tiến: Toàn bộ 15 vị trí đều có barem tiêu chí và minh chứng năng lực riêng biệt
-- =======================================================

USE HRM_Project_DB;
GO

-- =======================================================
-- 0. TƯƠNG THÍCH BẢNG FLASHCARD VỚI DATABASE CŨ
-- =======================================================
IF COL_LENGTH('dbo.FlashcardDecks', 'deck_type') IS NULL
BEGIN
    ALTER TABLE dbo.FlashcardDecks
        ADD deck_type NVARCHAR(20) NOT NULL
            CONSTRAINT DF_FlashcardDecks_Type DEFAULT 'professional';
END;
GO

IF COL_LENGTH('dbo.FlashcardDecks', 'position_id') IS NULL
BEGIN
    ALTER TABLE dbo.FlashcardDecks ADD position_id INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FlashcardDecks_Position')
BEGIN
    ALTER TABLE dbo.FlashcardDecks WITH CHECK
        ADD CONSTRAINT FK_FlashcardDecks_Position FOREIGN KEY (position_id)
            REFERENCES dbo.Positions(position_id) ON DELETE SET NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_FlashcardDecks_Type')
BEGIN
    ALTER TABLE dbo.FlashcardDecks WITH CHECK
        ADD CONSTRAINT CK_FlashcardDecks_Type CHECK (deck_type IN ('culture', 'professional'));
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_FlashcardDecks_CulturePosition')
BEGIN
    ALTER TABLE dbo.FlashcardDecks WITH CHECK
        ADD CONSTRAINT CK_FlashcardDecks_CulturePosition CHECK (deck_type <> 'culture' OR position_id IS NULL);
END;
GO

-- =======================================================
-- 1. SEED DATA: BẢNG PHÂN QUYỀN (ROLES)
-- =======================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE role_name = 'ADMIN')
BEGIN
    INSERT INTO dbo.Roles (role_name, description) VALUES
    ('ADMIN', N'Quản trị viên hệ thống'),
    ('HR', N'Nhân sự quản lý nhân sự, bổ nhiệm và phê duyệt thăng tiến toàn công ty'),
    ('MANAGER', N'Trưởng phòng quản lý nhân viên trong phòng ban của mình'),
    ('EMPLOYEE', N'Nhân viên công ty');
END
GO

-- =======================================================
-- 2. SEED DATA: BẢNG CẤP BẬC (JOB_LEVELS)
-- =======================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Job_Levels WHERE level_name = N'Intern')
BEGIN
    INSERT INTO dbo.Job_Levels (level_name, rank_order, description) VALUES
    (N'Intern', 1, N'Thực tập sinh'),
    (N'Fresher', 2, N'Nhân viên mới vào nghề'),
    (N'Junior', 3, N'Nhân viên có từ 1 - 2 năm kinh nghiệm'),
    (N'Middle', 4, N'Nhân viên từ 2 - 4 năm kinh nghiệm'),
    (N'Senior', 5, N'Chuyên viên từ 4+ năm kinh nghiệm'),
    (N'Lead', 6, N'Trưởng nhóm chuyên môn');
END
GO

-- =======================================================
-- 3. SEED DATA: BẢNG PHÒNG BAN (DEPARTMENTS)
-- Chỉ giữ lại tên phòng ban, không có chữ 'Phòng ban' hay 'Phòng', không có phòng HR
-- =======================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)')
BEGIN
    INSERT INTO dbo.Departments (department_name, description, status, is_deleted)
    VALUES (N'Kỹ Thuật (IT)', N'Phát triển, bảo trì và vận hành hệ thống phần mềm', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)')
BEGIN
    INSERT INTO dbo.Departments (department_name, description, status, is_deleted)
    VALUES (N'Kinh Doanh (Sales)', N'Kinh doanh giải pháp, phát triển thị trường và chăm sóc khách hàng', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông')
BEGIN
    INSERT INTO dbo.Departments (department_name, description, status, is_deleted)
    VALUES (N'Marketing & Truyền Thông', N'Xây dựng thương hiệu, tiếp thị số và truyền thông doanh nghiệp', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính')
BEGIN
    INSERT INTO dbo.Departments (department_name, description, status, is_deleted)
    VALUES (N'Kế Toán - Tài Chính', N'Quản lý dòng tiền, kế toán tổng hợp và lập kế hoạch tài chính', 1, 0);
END
GO

-- =======================================================
-- 4. SEED DATA: BẢNG VỊ TRÍ CÔNG VIỆC (POSITIONS)
-- 15 vị trí chuyên môn thuộc 4 phòng ban (Không có vị trí HR)
-- =======================================================
-- Vị trí thuộc: Kỹ Thuật (IT)
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Java Developer')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Java Developer', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'), N'Lập trình viên backend Java/Spring/Jakarta EE', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Frontend Developer')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Frontend Developer', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'), N'Lập trình viên giao diện web React/Vue/HTML/CSS', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'QA / Software Tester')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'QA / Software Tester', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'), N'Kiểm thử tự động & kiểm thử thủ công phần mềm', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'DevOps Engineer')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'DevOps Engineer', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'), N'Kỹ sư hạ tầng, Cloud và quy trình CI/CD', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Business Analyst (BA)', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'), N'Chuyên viên phân tích nghiệp vụ và quy trình phần mềm', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Mobile App Developer')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Mobile App Developer', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'), N'Lập trình viên ứng dụng di động Flutter/iOS/Android', 1, 0);
END
-- Vị trí thuộc: Kinh Doanh (Sales)
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Sales Executive')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Sales Executive', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'), N'Chuyên viên kinh doanh giải pháp doanh nghiệp B2B', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Key Account Manager (KAM)', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'), N'Quản lý và chăm sóc khách hàng doanh nghiệp trọng điểm', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Business Development Rep (BDR)', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'), N'Chuyên viên tìm kiếm và mở rộng mạng lưới khách hàng mới', 1, 0);
END
-- Vị trí thuộc: Marketing & Truyền Thông
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Digital Marketing Specialist', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'), N'Chuyên viên tiếp thị số, SEO và quảng cáo trực tuyến', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Content Creator & Copywriter', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'), N'Chuyên viên sáng tạo nội dung, bài viết truyền thông', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'UI/UX Product Designer', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'), N'Thiết kế trải nghiệm người dùng và giao diện sản phẩm số', 1, 0);
END
-- Vị trí thuộc: Kế Toán - Tài Chính
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Kế Toán Tổng Hợp (General Accountant)', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'), N'Hạch toán chi phí, doanh thu và lập báo cáo tài chính', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Chuyên Viên Kiểm Toán Nội Bộ', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'), N'Kiểm soát rủi ro tài chính và tuân thủ quy chế chi tiêu', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)')
BEGIN
    INSERT INTO dbo.Positions (position_name, department_id, description, status, is_deleted)
    VALUES (N'Financial Planning & Analysis (FP&A)', (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'), N'Chuyên viên phân tích và dự báo kế hoạch tài chính', 1, 0);
END
GO

-- =======================================================
-- 5. SEED DATA: BẢNG TÀI KHOẢN NGƯỜI DÙNG (USERS)
-- 1 Admin, 1 HR Manager, 4 Trưởng phòng ban (Managers), 75 Nhân viên (5 người/vị trí x 15 vị trí), 1 Locked User
-- Tổng cộng: 82 tài khoản người dùng, mật khẩu mặc định '123'
-- =======================================================

-- 5.1. Tài khoản Quản trị viên hệ thống (Admin)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'admin')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('admin', '123', N'Quản Trị Viên', 'admin@hrm.com', '0901000001', N'Nam', '1990-01-15',
            1, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            6, '2022-01-01', 1, 0);
END

-- 5.2. Tài khoản Cán bộ Nhân sự (HR - Phụ trách nhân sự toàn công ty, độc lập phòng ban)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'hr_manager')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('hr_manager', '123', N'Phạm Thu Hà', 'ha.pt@hrm.com', '0901000002', N'Nữ', '1992-06-20',
            2, NULL, NULL, 5, '2022-03-15', 1, 0);
END

-- 5.3. Tài khoản Trưởng phòng (Managers) của 4 phòng ban
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'manager_it')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('manager_it', '123', N'Trần Văn Minh', 'minh.tv@hrm.com', '0901000003', N'Nam', '1988-11-10',
            3, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            6, '2022-02-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'manager_sales')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('manager_sales', '123', N'Nguyễn Văn Hùng', 'hung.nv@hrm.com', '0901000004', N'Nam', '1987-05-12',
            3, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)'),
            6, '2022-02-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'manager_mkt')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('manager_mkt', '123', N'Lê Thị Tuyết Mai', 'mai.ltt@hrm.com', '0901000005', N'Nữ', '1989-08-25',
            3, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist'),
            6, '2022-02-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'manager_acc')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('manager_acc', '123', N'Phạm Hoàng Long', 'long.ph@hrm.com', '0901000008', N'Nam', '1986-12-03',
            3, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)'),
            6, '2022-02-01', 1, 0);
END

-- 5.4. Tài khoản nhân viên bị khóa để kiểm thử chức năng đăng nhập/bảo mật
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'locked_user')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('locked_user', '123', N'Nguyễn Khóa Khoản', 'locked.user@hrm.com', '0901999999', N'Nam', '2000-02-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            2, '2026-01-01', 0, 0);
END

-- 5.5. 75 Nhân viên chính thức (5 nhân viên mỗi vị trí x 15 vị trí thuộc 4 phòng ban)
-- -------------------------------------------------------
-- Nhân viên thuộc phòng: Kỹ Thuật (IT)
-- -------------------------------------------------------
-- Vị trí: Java Developer (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'java_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('java_intern', '123', N'Nguyễn Văn An', 'an.nv@hrm.com', '0901001001', N'Nam', '2003-05-10',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'dev_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('dev_fresher', '123', N'Phạm Đức Trọng', 'trong.pd@hrm.com', '0901000006', N'Nam', '2002-08-15',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            2, '2026-08-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'java_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('java_junior', '123', N'Đỗ Trung Hiếu', 'hieu.dt@hrm.com', '0901000010', N'Nam', '1999-05-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            3, '2024-03-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'java_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('java_middle', '123', N'Vũ Quang Huy', 'huy.vq@hrm.com', '0901000011', N'Nam', '1996-08-20',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            4, '2023-05-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mentor_java')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mentor_java', '123', N'Lê Hữu Mentor', 'mentor.java@hrm.com', '0988888888', N'Nam', '1993-09-05',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer'),
            5, '2021-01-01', 1, 0);
END
-- Vị trí: Frontend Developer (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fe_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fe_intern', '123', N'Hoàng Kim Ngân', 'ngan.hk@hrm.com', '0901001002', N'Nữ', '2003-02-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fe_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fe_fresher', '123', N'Lê Hoàng Nam', 'nam.lh@hrm.com', '0901000012', N'Nam', '2001-09-12',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer'),
            2, '2026-07-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fe_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fe_junior', '123', N'Nguyễn Thủy Tiên', 'tien.nt@hrm.com', '0901000013', N'Nữ', '1998-12-05',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer'),
            3, '2024-02-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fe_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fe_middle', '123', N'Bùi Thanh Tùng', 'tung.bt@hrm.com', '0901001003', N'Nam', '1996-06-25',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer'),
            4, '2023-04-12', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fe_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fe_senior', '123', N'Trần Anh Đức', 'duc.ta@hrm.com', '0901000014', N'Nam', '1995-04-18',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer'),
            5, '2022-09-01', 1, 0);
END
-- Vị trí: QA / Software Tester (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'qa_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('qa_intern', '123', N'Phan Minh Tuấn', 'tuan.pm@hrm.com', '0901001004', N'Nam', '2003-07-20',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'QA / Software Tester'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'qa_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('qa_fresher', '123', N'Bùi Tuấn Anh', 'anh.bt@hrm.com', '0901000015', N'Nam', '2002-03-22',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'QA / Software Tester'),
            2, '2026-06-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'dev_tester')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('dev_tester', '123', N'Ngô Mai Phương', 'phuong.nm@hrm.com', '0901000007', N'Nữ', '1998-04-25',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'QA / Software Tester'),
            3, '2023-06-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'qa_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('qa_middle', '123', N'Đặng Hồng Nhung', 'nhung.dh@hrm.com', '0901000016', N'Nữ', '1996-10-30',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'QA / Software Tester'),
            4, '2023-08-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'qa_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('qa_senior', '123', N'Trịnh Khắc Toàn', 'toan.tk@hrm.com', '0901001005', N'Nam', '1994-11-15',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'QA / Software Tester'),
            5, '2021-12-01', 1, 0);
END
-- Vị trí: DevOps Engineer (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'devops_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('devops_intern', '123', N'Lê Quốc Thịnh', 'thinh.lq@hrm.com', '0901001006', N'Nam', '2003-04-18',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'DevOps Engineer'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'devops_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('devops_fresher', '123', N'Ngô Đức Hưng', 'hung.nd@hrm.com', '0901001007', N'Nam', '2001-11-05',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'DevOps Engineer'),
            2, '2026-07-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'devops_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('devops_junior', '123', N'Trịnh Quốc Bảo', 'bao.tq@hrm.com', '0901000023', N'Nam', '1999-08-11',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'DevOps Engineer'),
            3, '2024-06-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'devops_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('devops_middle', '123', N'Võ Hoàng Long', 'long.vh@hrm.com', '0901000024', N'Nam', '1995-12-03',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'DevOps Engineer'),
            4, '2023-02-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'devops_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('devops_senior', '123', N'Đinh Việt Khôi', 'khoi.dv@hrm.com', '0901000025', N'Nam', '1992-05-24',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'DevOps Engineer'),
            5, '2021-10-10', 1, 0);
END
-- Vị trí: Business Analyst (BA) (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'ba_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('ba_intern', '123', N'Chu Thị Kiều', 'kieu.ct@hrm.com', '0901001008', N'Nữ', '2003-08-22',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'ba_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('ba_fresher', '123', N'Nguyễn Phương Thảo', 'thao.np@hrm.com', '0901000026', N'Nữ', '2001-04-16',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)'),
            2, '2026-08-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'ba_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('ba_junior', '123', N'Phạm Quốc Khánh', 'khanh.pq@hrm.com', '0901000027', N'Nam', '1997-09-08',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)'),
            3, '2024-03-20', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'ba_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('ba_middle', '123', N'Vũ Diệu Linh', 'linh.vd@hrm.com', '0901001009', N'Nữ', '1996-03-12',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)'),
            4, '2023-05-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'ba_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('ba_senior', '123', N'Lê Cẩm Tú', 'tu.lc@hrm.com', '0901000028', N'Nữ', '1994-01-30',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)'),
            5, '2022-04-05', 1, 0);
END
-- Vị trí: Mobile App Developer (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mobile_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mobile_intern', '123', N'Tạ Minh Hùng', 'hung.tm@hrm.com', '0901001010', N'Nam', '2003-03-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Mobile App Developer'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mobile_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mobile_fresher', '123', N'Lương Duy Quang', 'quang.ld@hrm.com', '0901000029', N'Nam', '2000-11-27',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Mobile App Developer'),
            2, '2026-07-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mobile_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mobile_junior', '123', N'Hồ Minh Trí', 'tri.hm@hrm.com', '0901000030', N'Nam', '1998-03-05',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Mobile App Developer'),
            3, '2024-05-02', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mobile_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mobile_middle', '123', N'Dương Xuân Tùng', 'tung.dx@hrm.com', '0901000031', N'Nam', '1995-07-19',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Mobile App Developer'),
            4, '2023-01-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mobile_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mobile_senior', '123', N'Cao Đình Toàn', 'toan.cd@hrm.com', '0901001011', N'Nam', '1993-12-08',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Mobile App Developer'),
            5, '2021-08-20', 1, 0);
END
-- -------------------------------------------------------
-- Nhân viên thuộc phòng: Kinh Doanh (Sales)
-- -------------------------------------------------------
-- Vị trí: Sales Executive (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'sales_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('sales_intern', '123', N'Trần Đình Trọng', 'trong.td@hrm.com', '0901001012', N'Nam', '2003-09-02',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Sales Executive'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'sales_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('sales_fresher', '123', N'Vũ Ngọc Châu', 'chau.vn@hrm.com', '0901001013', N'Nữ', '2001-05-18',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Sales Executive'),
            2, '2026-07-20', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'sales_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('sales_junior', '123', N'Lý Quang Thắng', 'thang.lq@hrm.com', '0901000020', N'Nam', '1998-06-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Sales Executive'),
            3, '2024-01-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'sales_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('sales_middle', '123', N'Phan Thanh Hằng', 'hang.pt@hrm.com', '0901000021', N'Nữ', '1996-02-28',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Sales Executive'),
            4, '2023-04-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'sales_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('sales_senior', '123', N'Nguyễn Đức Mạnh', 'manh.nd@hrm.com', '0901000022', N'Nam', '1993-11-09',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Sales Executive'),
            5, '2022-07-20', 1, 0);
END
-- Vị trí: Key Account Manager (KAM) (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kam_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('kam_intern', '123', N'Bùi Hoàng Yến', 'yen.bh@hrm.com', '0901001014', N'Nữ', '2003-06-11',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kam_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('kam_fresher', '123', N'Đoàn Gia Bảo', 'bao.dg@hrm.com', '0901001015', N'Nam', '2001-10-25',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)'),
            2, '2026-06-18', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kam_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('kam_junior', '123', N'Lê Minh Triết', 'triet.lm@hrm.com', '0901000041', N'Nam', '1996-01-11',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)'),
            3, '2024-04-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kam_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('kam_middle', '123', N'Đỗ Thu Hà', 'ha.dt@hrm.com', '0901000042', N'Nữ', '1994-06-29',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)'),
            4, '2023-05-18', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kam_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('kam_senior', '123', N'Trần Hoàng Việt', 'viet.th@hrm.com', '0901000043', N'Nam', '1991-10-05',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)'),
            5, '2021-08-01', 1, 0);
END
-- Vị trí: Business Development Rep (BDR) (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'bdr_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('bdr_intern', '123', N'Mai Văn Thái', 'thai.mv@hrm.com', '0901001016', N'Nam', '2003-01-30',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'bdr_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('bdr_fresher', '123', N'Ngô Thiên Ân', 'an.nt@hrm.com', '0901000044', N'Nam', '2001-08-19',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)'),
            2, '2026-08-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'bdr_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('bdr_junior', '123', N'Phạm Ngọc Tuyền', 'tuyen.pn@hrm.com', '0901000045', N'Nữ', '1998-11-23',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)'),
            3, '2024-06-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'bdr_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('bdr_middle', '123', N'Vũ Văn Phương', 'phuong.vv@hrm.com', '0901000046', N'Nam', '1995-02-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)'),
            4, '2023-06-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'bdr_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('bdr_senior', '123', N'Lâm Quốc Hưng', 'hung.lq@hrm.com', '0901001017', N'Nam', '1992-07-04',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kinh Doanh (Sales)'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)'),
            5, '2021-09-15', 1, 0);
END
-- -------------------------------------------------------
-- Nhân viên thuộc phòng: Marketing & Truyền Thông
-- -------------------------------------------------------
-- Vị trí: Digital Marketing Specialist (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mkt_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mkt_intern', '123', N'Đào Thúy Hạnh', 'hanh.dt@hrm.com', '0901001018', N'Nữ', '2003-11-19',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mkt_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mkt_fresher', '123', N'Lê Quỳnh Nga', 'nga.lq@hrm.com', '0901000047', N'Nữ', '2000-04-08',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist'),
            2, '2026-05-20', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mkt_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mkt_junior', '123', N'Đinh Thế Anh', 'anh.dt@hrm.com', '0901000048', N'Nam', '1997-12-15',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist'),
            3, '2024-03-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mkt_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mkt_middle', '123', N'Trương Ngọc Mai', 'mai.tn@hrm.com', '0901001019', N'Nữ', '1995-05-22',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist'),
            4, '2023-03-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'mkt_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('mkt_senior', '123', N'Hoàng Mai Ly', 'ly.hm@hrm.com', '0901000049', N'Nữ', '1994-09-02',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist'),
            5, '2022-02-15', 1, 0);
END
-- Vị trí: Content Creator & Copywriter (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'content_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('content_intern', '123', N'Hà Hải Đăng', 'dang.hh@hrm.com', '0901001020', N'Nam', '2003-10-08',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'content_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('content_fresher', '123', N'Nguyễn Trà Anh', 'traanh.nt@hrm.com', '0901000050', N'Nữ', '2002-01-17',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter'),
            2, '2026-09-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'content_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('content_junior', '123', N'Trần Xuân Bắc', 'bac.tx@hrm.com', '0901000051', N'Nam', '1999-05-26',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter'),
            3, '2024-08-05', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'content_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('content_middle', '123', N'Phan Anh Thư', 'thu.pa@hrm.com', '0901000052', N'Nữ', '1996-08-11',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter'),
            4, '2023-07-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'content_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('content_senior', '123', N'Vũ Thảo Trang', 'trang.vt@hrm.com', '0901001021', N'Nữ', '1993-04-16',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter'),
            5, '2021-11-05', 1, 0);
END
-- Vị trí: UI/UX Product Designer (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'uiux_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('uiux_intern', '123', N'Lê Thảo My', 'my.lt@hrm.com', '0901001022', N'Nữ', '2003-04-26',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'uiux_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('uiux_fresher', '123', N'Vũ Minh Châu', 'chau.vm@hrm.com', '0901000053', N'Nữ', '2001-06-30',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer'),
            2, '2026-06-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'uiux_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('uiux_junior', '123', N'Lâm Gia Hưởng', 'huong.lg@hrm.com', '0901000054', N'Nam', '1997-03-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer'),
            3, '2024-01-20', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'uiux_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('uiux_middle', '123', N'Ngô Trọng Nghĩa', 'nghia.ngo@hrm.com', '0901001023', N'Nam', '1995-09-18',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer'),
            4, '2023-02-28', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'uiux_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('uiux_senior', '123', N'Đặng Thanh Vân', 'van.dt@hrm.com', '0901000055', N'Nữ', '1993-10-22',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Marketing & Truyền Thông'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer'),
            5, '2021-12-01', 1, 0);
END
-- -------------------------------------------------------
-- Nhân viên thuộc phòng: Kế Toán - Tài Chính
-- -------------------------------------------------------
-- Vị trí: Kế Toán Tổng Hợp (General Accountant) (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'acc_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('acc_intern', '123', N'Phùng Gia Huy', 'huy.pg@hrm.com', '0901001024', N'Nam', '2003-12-04',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'acc_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('acc_fresher', '123', N'Dương Mỹ Linh', 'linh.dm@hrm.com', '0901001025', N'Nữ', '2001-07-15',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)'),
            2, '2026-07-05', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'acc_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('acc_junior', '123', N'Bùi Thu Hiền', 'hien.bt@hrm.com', '0901000056', N'Nữ', '1999-07-04',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)'),
            3, '2024-04-15', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'acc_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('acc_middle', '123', N'Lê Văn Quý', 'quy.lv@hrm.com', '0901000057', N'Nam', '1996-11-18',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)'),
            4, '2023-05-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'acc_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('acc_senior', '123', N'Nguyễn Bích Ngọc', 'ngoc.nb@hrm.com', '0901000058', N'Nữ', '1992-02-09',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)'),
            5, '2021-09-10', 1, 0);
END
-- Vị trí: Chuyên Viên Kiểm Toán Nội Bộ (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'audit_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('audit_intern', '123', N'Vương Đình Hải', 'hai.vd@hrm.com', '0901001026', N'Nam', '2003-08-09',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'audit_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('audit_fresher', '123', N'Trịnh Mai Hoa', 'hoa.tm@hrm.com', '0901001027', N'Nữ', '2001-03-27',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ'),
            2, '2026-06-25', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'audit_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('audit_junior', '123', N'Trần Hồng Phúc', 'phuc.th@hrm.com', '0901000059', N'Nam', '1998-04-12',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ'),
            3, '2024-05-10', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'audit_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('audit_middle', '123', N'Phạm Hải Vân', 'van.ph@hrm.com', '0901000060', N'Nữ', '1995-08-27',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ'),
            4, '2023-08-20', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'audit_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('audit_senior', '123', N'Đỗ Quang Định', 'dinh.dq@hrm.com', '0901000061', N'Nam', '1991-03-15',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ'),
            5, '2021-07-01', 1, 0);
END
-- Vị trí: Financial Planning & Analysis (FP&A) (5 nhân viên: Intern, Fresher, Junior, Middle, Senior)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fpa_intern')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fpa_intern', '123', N'Lục Thanh Thảo', 'thao.lt@hrm.com', '0901001028', N'Nữ', '2003-05-31',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)'),
            1, '2026-09-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fpa_fresher')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fpa_fresher', '123', N'Hoàng Nguyên Hòa', 'hoa.hn@hrm.com', '0901000062', N'Nam', '2000-12-08',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)'),
            2, '2026-07-01', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fpa_junior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fpa_junior', '123', N'Lê Thanh Mai', 'mai.lt@hrm.com', '0901000063', N'Nữ', '1997-01-20',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)'),
            3, '2024-02-25', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fpa_middle')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fpa_middle', '123', N'Võ Tấn Đạt', 'dat.vt@hrm.com', '0901001029', N'Nam', '1995-10-14',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)'),
            4, '2023-04-05', 1, 0);
END
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'fpa_senior')
BEGIN
    INSERT INTO dbo.Users (username, password, full_name, email, phone, gender, dob, role_id, department_id, position_id, level_id, hire_date, status, is_deleted)
    VALUES ('fpa_senior', '123', N'Nguyễn Trọng Nghĩa', 'nghia.nt@hrm.com', '0901000064', N'Nam', '1993-09-11',
            4, (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kế Toán - Tài Chính'),
            (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)'),
            5, '2022-03-01', 1, 0);
END
GO

-- 5.6. Cập nhật Trưởng phòng (manager_id) cho 4 phòng ban
UPDATE dbo.Departments SET manager_id = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_it') WHERE department_name = N'Kỹ Thuật (IT)';
UPDATE dbo.Departments SET manager_id = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_sales') WHERE department_name = N'Kinh Doanh (Sales)';
UPDATE dbo.Departments SET manager_id = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_mkt') WHERE department_name = N'Marketing & Truyền Thông';
UPDATE dbo.Departments SET manager_id = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_acc') WHERE department_name = N'Kế Toán - Tài Chính';
GO

-- =======================================================
-- 6. SEED DATA: LỊCH SỬ BIẾN ĐỘNG (EMPLOYEE_HISTORY)
-- =======================================================
DECLARE @u_dev_fresher INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'dev_fresher');
DECLARE @d_it INT = (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)');
DECLARE @p_java INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
DECLARE @u_hr INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'hr_manager');
IF @u_dev_fresher IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Employee_History WHERE user_id = @u_dev_fresher)
BEGIN
    INSERT INTO dbo.Employee_History (user_id, old_department_id, new_department_id, old_position_id, new_position_id, old_level_id, new_level_id, change_type, change_date, notes, created_by)
    VALUES (@u_dev_fresher, NULL, @d_it, NULL, @p_java, NULL, 2, 'NEW_HIRE', '2026-08-01', N'Tuyển dụng mới vị trí Fresher Java Developer', @u_hr);
END
GO

-- =======================================================
-- 7. SEED DATA: FLASHCARDS HỌC TẬP
-- =======================================================
IF NOT EXISTS (SELECT 1 FROM dbo.FlashcardDecks WHERE title = N'Văn hóa công ty')
BEGIN
    INSERT INTO dbo.FlashcardDecks (title, description, deck_type, position_id) VALUES
    (N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa doanh nghiệp', 'culture', NULL);
    DECLARE @deck_culture INT = SCOPE_IDENTITY();
    INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
    (@deck_culture, N'Giờ làm việc kết thúc lúc mấy giờ?', N'17:30 hàng ngày.'),
    (@deck_culture, N'Thành viên mới cần làm gì trong ngày đầu tiên?', N'Hoàn tất thủ tục onboarding, làm quen với team, tài khoản hệ thống và nội quy công ty.'),
    (@deck_culture, N'Nhân viên cần báo trước bao nhiêu ngày khi xin nghỉ phép?', N'Thực hiện theo quy định nghỉ phép của công ty và thông báo cho quản lý trước thời gian nghỉ.'),
    (@deck_culture, N'Khi gặp vấn đề trong công việc, nhân viên nên làm gì?', N'Chủ động trao đổi với Leader, Manager hoặc người hướng dẫn để được hỗ trợ.'),
    (@deck_culture, N'Onboarding là gì?', N'Là quá trình giúp nhân viên mới làm quen với công ty, công việc, văn hóa và quy trình làm việc.'),
    (@deck_culture, N'Mục đích của việc onboarding nhân viên mới là gì?', N'Giúp nhân viên nhanh chóng hòa nhập, hiểu công việc và có thể làm việc hiệu quả.'),
    (@deck_culture, N'Nhân viên có cần bảo mật thông tin công ty không?', N'Có. Nhân viên phải bảo mật thông tin nội bộ, thông tin khách hàng và dữ liệu của công ty.'),
    (@deck_culture, N'Khi đến muộn, nhân viên nên làm gì?', N'Thông báo cho quản lý hoặc người phụ trách và tuân thủ quy định chấm công của công ty.'),
    (@deck_culture, N'Tại sao cần tham gia các buổi training của công ty?', N'Để cập nhật kiến thức, quy trình, kỹ năng và các quy định cần thiết cho công việc.'),
    (@deck_culture, N'Nhân viên mới có thể hỏi ai khi không hiểu công việc?', N'Có thể hỏi Mentor, Team Leader, Manager hoặc đồng nghiệp phù hợp.');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.FlashcardDecks WHERE title = N'Java Backend')
BEGIN
    DECLARE @pos_java INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
    INSERT INTO dbo.FlashcardDecks (title, description, deck_type, position_id) VALUES
    (N'Java Backend', N'Kiến thức chuyên môn lập trình Java Backend', 'professional', @pos_java);
    DECLARE @deck_java INT = SCOPE_IDENTITY();
    INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
    (@deck_java, N'Java là gì?', N'Java là một ngôn ngữ lập trình hướng đối tượng, được sử dụng phổ biến để phát triển ứng dụng web, desktop và backend.'),
    (@deck_java, N'OOP có mấy tính chất cơ bản?', N'4 tính chất: Đóng gói, Kế thừa, Đa hình và Trừu tượng.'),
    (@deck_java, N'Class trong Java là gì?', N'Class là một khuôn mẫu dùng để định nghĩa thuộc tính và hành vi của object.'),
    (@deck_java, N'Object trong Java là gì?', N'Object là một thể hiện cụ thể được tạo ra từ một class.'),
    (@deck_java, N'Tính đóng gói trong OOP là gì?', N'Là việc đóng gói dữ liệu và các phương thức liên quan trong một class và kiểm soát quyền truy cập.'),
    (@deck_java, N'Tính kế thừa trong OOP là gì?', N'Là cơ chế cho phép một class con kế thừa thuộc tính và phương thức từ class cha.'),
    (@deck_java, N'Tính đa hình trong OOP là gì?', N'Là khả năng cùng một phương thức có thể có cách thực hiện khác nhau tùy theo object.'),
    (@deck_java, N'Tính trừu tượng trong OOP là gì?', N'Là việc ẩn đi các chi tiết cài đặt và chỉ hiển thị những thông tin cần thiết cho người sử dụng.'),
    (@deck_java, N'Constructor trong Java dùng để làm gì?', N'Dùng để khởi tạo object khi object được tạo ra.'),
    (@deck_java, N'Interface trong Java là gì?', N'Interface là một tập hợp các phương thức mà class implement cần cung cấp phần cài đặt.'),
    (@deck_java, N'Exception trong Java là gì?', N'Exception là lỗi xảy ra trong quá trình chương trình đang thực thi.'),
    (@deck_java, N'Try-catch trong Java dùng để làm gì?', N'Dùng để xử lý exception và tránh làm chương trình kết thúc đột ngột.'),
    (@deck_java, N'ArrayList trong Java là gì?', N'ArrayList là một collection có thể lưu trữ nhiều phần tử và có kích thước có thể thay đổi.'),
    (@deck_java, N'Git dùng để làm gì?', N'Git là hệ thống quản lý phiên bản giúp theo dõi, lưu trữ và quản lý các thay đổi của source code.'),
    (@deck_java, N'API là gì?', N'API là giao diện cho phép các ứng dụng hoặc hệ thống giao tiếp và trao đổi dữ liệu với nhau.');
END
GO

-- =======================================================
-- 8. SEED DATA: KHO ĐỀ THI VĂN HÓA & CHUYÊN MÔN
-- =======================================================
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @culture_creator_id INT = (SELECT TOP (1) user_id FROM dbo.Users WHERE username = 'hr_manager');
DECLARE @technical_creator_id INT = (SELECT TOP (1) user_id FROM dbo.Users WHERE username = 'manager_it');
DECLARE @technical_department_id INT = (SELECT TOP (1) department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)');

DECLARE @culture_content_id INT = (
    SELECT TOP (1) id FROM dbo.Test_Content
    WHERE title = N'Đề thi Văn hóa doanh nghiệp' AND type = 'culture' AND is_deleted = 0
);
IF @culture_content_id IS NULL AND @culture_creator_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,is_deleted)
    VALUES (N'Đề thi Văn hóa doanh nghiệp',
            N'Đánh giá kiến thức về bảo mật, giao tiếp, hợp tác và quy định làm việc.',
            'quiz','culture',NULL,@culture_creator_id,'ready',0);
    SET @culture_content_id = SCOPE_IDENTITY();
END;

IF @culture_content_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Test_Questions WHERE content_id = @culture_content_id)
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
    VALUES (@culture_content_id,N'Mọi hành vi quấy rối hoặc phân biệt đối xử tại nơi làm việc đều cần được phản ánh qua kênh phù hợp.','true_false');
    SET @question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@question_id,N'Đúng',1,1),(@question_id,N'Sai',0,2);
END;

DECLARE @technical_content_id INT = (
    SELECT TOP (1) id FROM dbo.Test_Content
    WHERE title = N'Đề thi Chuyên môn Java Backend' AND type = 'department'
      AND department_id = @technical_department_id AND is_deleted = 0
);
IF @technical_content_id IS NULL AND @technical_creator_id IS NOT NULL AND @technical_department_id IS NOT NULL
BEGIN
    INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,is_deleted)
    VALUES (N'Đề thi Chuyên môn Java Backend',
            N'Đánh giá nền tảng Java, SQL, HTTP, Git và kiểm thử dành cho phòng Kỹ thuật.',
            'quiz','department',@technical_department_id,@technical_creator_id,'ready',0);
    SET @technical_content_id = SCOPE_IDENTITY();
END;

IF @technical_content_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Test_Questions WHERE content_id = @technical_content_id)
BEGIN
    DECLARE @technical_question_id INT;
    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'PreparedStatement với tham số ràng buộc giúp giảm nguy cơ SQL Injection.','true_false');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Đúng',1,1),(@technical_question_id,N'Sai',0,2);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Khi một thao tác transaction gặp lỗi trước khi hoàn tất, hành động phù hợp là gì?','single');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Rollback transaction để khôi phục tính nhất quán',1,1),
        (@technical_question_id,N'Commit các thay đổi đã chạy được',0,2),
        (@technical_question_id,N'Bỏ qua lỗi và tiếp tục',0,3),
        (@technical_question_id,N'Xóa toàn bộ database',0,4);

    INSERT INTO dbo.Test_Questions(content_id,prompt,question_type)
    VALUES (@technical_content_id,N'Git branch giúp phát triển thay đổi tách biệt trước khi hợp nhất.','true_false');
    SET @technical_question_id = SCOPE_IDENTITY();
    INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order) VALUES
        (@technical_question_id,N'Đúng',1,1),(@technical_question_id,N'Sai',0,2);
END;

COMMIT;
GO

-- =======================================================
-- 9. SEED DATA: HỌC LIỆU & LỚP ĐÀO TẠO (LEARNING MATERIALS & TRAINING CLASSES)
-- =======================================================
DECLARE @u_manager_it INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_it');
IF NOT EXISTS (SELECT 1 FROM dbo.Learning_Materials WHERE title LIKE N'Slide Đào Tạo Quy Trình%')
BEGIN
    INSERT INTO dbo.Learning_Materials
    (title, description, material_type, scope_type, department_id, position_id, level_id, material_url, video_url, duration_minutes, status, created_by, created_at)
    VALUES
    (N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum',
     N'Trình chiếu bài giảng chi tiết về quy trình vận hành Sprint, các buổi lễ Scrum và văn hóa phối hợp đội ngũ.',
     'SLIDE', 'CULTURE', NULL, NULL, NULL, 'https://docs.google.com/presentation/d/1WX3Lvh6A8TqQBmbr4XyRN8SaWSsxIoQo/edit?slide=id.p1#slide=id.p1', 'https://docs.google.com/presentation/d/1WX3Lvh6A8TqQBmbr4XyRN8SaWSsxIoQo/edit?slide=id.p1#slide=id.p1', 0, 1, @u_manager_it, '2026-09-01 08:05:00'),
    (N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE',
     N'Khóa học video cô đọng chuẩn kiến trúc phần mềm MVC, vòng đời Servlet, Bộ lọc Filter và JDBC Transaction.',
     'VIDEO', 'CULTURE', NULL, NULL, NULL, 'https://www.youtube.com/watch?v=X5nt9_11Ozg&list=PLW1k06REn7HsHn6D6e27gtFm-HXrZDLPX', 'https://www.youtube.com/watch?v=X5nt9_11Ozg&list=PLW1k06REn7HsHn6D6e27gtFm-HXrZDLPX', 15, 1, @u_manager_it, '2026-09-01 08:10:00'),
    (N'Bộ Tiêu Chuẩn Lập Trình Java',
     N'Tài liệu quy định chi tiết về cấu trúc mã nguồn, quy chuẩn đặt tên biến/hàm/lớp và nguyên tắc Clean Code.',
     'PDF', 'CULTURE', NULL, NULL, NULL, '/hrm-career-path/assets/docs/java-clean-code-conventions.pdf', '/hrm-career-path/assets/docs/java-clean-code-conventions.pdf', 0, 1, @u_manager_it, '2026-09-01 08:15:00');
END
GO

-- Checkpoint câu hỏi tương tác video
DECLARE @video_mat_id INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title LIKE N'Video Bài Giảng: Kiến Trúc Java Backend%');
IF @video_mat_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Video_Checkpoints WHERE material_id = @video_mat_id)
BEGIN
    INSERT INTO dbo.Video_Checkpoints
    (material_id, stop_time_seconds, question_prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
    VALUES
    (@video_mat_id, 15,
     N'Theo mô hình MVC trong Jakarta EE, thành phần nào chịu trách nhiệm tiếp nhận HTTP Request từ người dùng và chuyển tiếp yêu cầu đến các thành phần xử lý phù hợp?',
     N'Model (Java Bean / Entity)', N'Controller (Servlet)', N'View (JSP / JSTL)', N'DAL (Data Access Object)', 1,
     N'Trong mô hình MVC, Controller (thường được triển khai bằng Servlet trong Jakarta EE) tiếp nhận HTTP Request từ người dùng, điều phối quá trình xử lý và chuyển dữ liệu đến View để hiển thị kết quả.'),
    (@video_mat_id, 30,
     N'Để đảm bảo tính toàn vẹn dữ liệu (ACID) khi thực hiện nhiều thao tác INSERT/UPDATE liên quan mật thiết với nhau, kỹ thuật nào bắt buộc phải áp dụng?',
     N'Bật chế độ tự động lưu (AutoCommit = true)', N'Chỉ dùng câu lệnh Statement thông thường', N'Quản lý giao dịch Database Transaction (setAutoCommit(false), commit() và rollback())', N'Bỏ qua việc bắt lỗi ngoại lệ SQLException', 2,
     N'Chính xác! Database Transaction bảo đảm tính nguyên tử (Atomicity) và nhất quán, rollback lại toàn bộ nếu có bất kỳ bước nào thất bại.');
END
GO

-- Lớp đào tạo Onboarding Kỹ thuật
IF NOT EXISTS (SELECT 1 FROM dbo.Training_Classes WHERE class_code = 'CLS-IT-FRESHER-2026')
BEGIN
    DECLARE @d_it INT = (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)');
    DECLARE @p_java INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
    DECLARE @u_manager_it INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_it');
    DECLARE @u_hr INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'hr_manager');
    INSERT INTO dbo.Training_Classes
    (class_code, class_name, description, department_id, target_position_id, target_level_id, mentor_id, start_date, end_date, status, is_deleted, created_by)
    VALUES
    ('CLS-IT-FRESHER-2026',
     N'Khóa Đào Tạo Onboarding Kỹ Thuật Cho Fresher 2026',
     N'Lớp đào tạo nền tảng kiến thức công nghệ, văn hóa làm việc và quy trình kỹ thuật dành cho các bạn Fresher mới gia nhập.',
     @d_it, @p_java, 2, @u_manager_it, CAST(GETDATE() AS DATE), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'OPEN', 0, @u_hr);
END
GO

-- Gắn học liệu vào lớp đào tạo và ghi danh học viên
DECLARE @class_id INT = (SELECT TOP 1 class_id FROM dbo.Training_Classes WHERE class_code = 'CLS-IT-FRESHER-2026');
DECLARE @id_agile INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title LIKE N'Slide Đào Tạo Quy Trình%');
DECLARE @id_backend INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title LIKE N'Video Bài Giảng: Kiến Trúc Java Backend%');
DECLARE @id_cleancode INT = (SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title LIKE N'Bộ Tiêu Chuẩn Lập Trình Java%');
DECLARE @u_dev_fresher INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'dev_fresher');
DECLARE @u_manager_it INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_it');

IF @class_id IS NOT NULL AND @id_agile IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Class_Materials WHERE class_id = @class_id)
BEGIN
    INSERT INTO dbo.Class_Materials (class_id, material_id, order_index, is_mandatory) VALUES
    (@class_id, @id_agile, 1, 1),
    (@class_id, @id_backend, 2, 1),
    (@class_id, @id_cleancode, 3, 1);
END

IF @class_id IS NOT NULL AND @u_dev_fresher IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Class_Enrollments WHERE class_id = @class_id AND user_id = @u_dev_fresher)
BEGIN
    INSERT INTO dbo.Class_Enrollments (class_id, user_id, enrolled_by, enrollment_type, assigned_reason, status, progress_percent)
    VALUES (@class_id, @u_dev_fresher, @u_manager_it, 'SMART_ASSIGN', N'Phân bổ tự động theo lộ trình vị trí Fresher Java Developer', 'IN_PROGRESS', 33);

    INSERT INTO dbo.Learning_Progress (user_id, material_id, class_id, status, last_accessed_at, completed_at, notes)
    VALUES (@u_dev_fresher, @id_agile, @class_id, 'COMPLETED', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), N'Đã hoàn thành slide quy trình Agile/Scrum'),
           (@u_dev_fresher, @id_backend, @class_id, 'IN_PROGRESS', DATEADD(DAY, -1, GETDATE()), NULL, N'Đang xem video kiến trúc Java Backend và làm câu hỏi dừng'),
           (@u_dev_fresher, @id_cleancode, @class_id, 'NOT_STARTED', GETDATE(), NULL, N'Chuẩn bị nghiên cứu quy chuẩn Clean Code');
END
GO

-- =======================================================
-- 10. SEED DATA: GHÉP NỐI MENTOR (MENTOR_ASSIGNMENTS)
-- =======================================================
DECLARE @u_dev_fresher INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'dev_fresher');
DECLARE @u_mentor_java INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'mentor_java');
DECLARE @p_java INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
DECLARE @u_hr INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'hr_manager');
IF @u_dev_fresher IS NOT NULL AND @u_mentor_java IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.MentorAssignments WHERE mentee_id = @u_dev_fresher)
BEGIN
    INSERT INTO dbo.MentorAssignments (mentee_id, mentor_id, position_id, status, assigned_by, created_at)
    VALUES (@u_dev_fresher, @u_mentor_java, @p_java, 'ACTIVE', @u_hr, DATEADD(DAY, -15, GETDATE()));
END
GO

-- =======================================================
-- 11. SEED DATA: ĐỀ XUẤT VỊ TRÍ & ĐỀ XUẤT ĐIỀU CHUYỂN
-- =======================================================
DECLARE @u_manager_it INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_it');
DECLARE @d_it INT = (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)');
DECLARE @u_admin INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'admin');
IF @u_manager_it IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Position_Requests WHERE department_id = @d_it)
BEGIN
    INSERT INTO dbo.Position_Requests (manager_id, department_id, position_name, description, reason, status, created_at)
    VALUES (@u_manager_it, @d_it, N'AI / Machine Learning Engineer', N'Nghiên cứu và triển khai mô hình học máy cho các sản phẩm nội bộ', N'Dự án quý mới cần bổ sung nhân sự chuyên sâu về xử lý dữ liệu và AI phục vụ khách hàng doanh nghiệp.', 'PENDING', DATEADD(DAY, -3, GETDATE()));

    INSERT INTO dbo.Position_Requests (manager_id, department_id, position_name, description, reason, status, decision_note, reviewed_by, created_at, reviewed_at)
    VALUES (@u_manager_it, @d_it, N'DevOps Engineer', N'Vận hành hệ thống CI/CD, Docker, Kubernetes', N'Đội ngũ backend cần tự động hóa quy trình deploy để giảm tải thời gian release.', 'APPROVED', N'Đồng ý phê duyệt bổ sung vị trí này vào cơ cấu phòng Kỹ thuật.', @u_admin, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -8, GETDATE()));
END
GO

DECLARE @u_dev_fresher INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'dev_fresher');
DECLARE @d_it INT = (SELECT TOP 1 department_id FROM dbo.Departments WHERE department_name = N'Kỹ Thuật (IT)');
DECLARE @p_java INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
DECLARE @p_fe INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer');
IF @u_dev_fresher IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Transfer_Requests WHERE employee_id = @u_dev_fresher)
BEGIN
    INSERT INTO dbo.Transfer_Requests (employee_id, current_department_id, current_position_id, target_department_id, target_position_id, reason, manager_status, hr_status, created_at)
    VALUES (@u_dev_fresher, @d_it, @p_java, @d_it, @p_fe, N'Em đã hoàn thành các khóa đào tạo nâng cao về React và UI/UX, mong muốn được thử sức ở vị trí Frontend Developer.', 'PENDING', 'WAITING_MANAGER', DATEADD(DAY, -2, GETDATE()));
END
GO

-- =======================================================
-- 12. SEED DATA: BAREM LỘ TRÌNH THĂNG TIẾN & MINH CHỨNG NĂNG LỰC
-- Cấu hình riêng biệt cho toàn bộ 15 vị trí thuộc 4 phòng ban
-- Mỗi vị trí có 3 nấc: Fresher->Junior (2->3), Junior->Middle (3->4), Middle->Senior (4->5)
-- =======================================================

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Java Developer
-- =======================================================
DECLARE @pos_463706 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
DECLARE @crit_id INT;
IF @pos_463706 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_463706 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_463706, 2, 3, 75.0, N'Nắm vững Java Core, OOP, Spring Boot căn bản, RESTful API và làm việc với CSDL quan hệ.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Tham gia tối thiểu 1 dự án thực tế đạt tiến độ bàn giao', 'PROJECT_EXPERIENCE', N'Nộp link tài liệu nghiệm thu hoặc báo cáo đóng góp các module tính năng trong dự án.', 1, 1),
        (@crit_id, N'Có chứng chỉ đào tạo Java Backend hoặc chứng chỉ tương đương', 'CERTIFICATE', N'Upload ảnh/file PDF chứng chỉ chuyên môn liên quan.', 0, 2),
        (@crit_id, N'Đánh giá hiệu suất từ PM/Tech Lead đạt mức Tốt trở lên', 'CUSTOMER_SATISFACTION', N'Nộp ảnh chụp email đánh giá hoặc biên bản đánh giá định kỳ của PM.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_463706 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_463706, 3, 4, 80.0, N'Làm chủ kiến trúc Microservices, Clean Architecture, Docker, CI/CD và tối ưu hóa truy vấn CSDL.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Tham gia tối thiểu 2 dự án thực tế với vai trò Core Developer', 'PROJECT_EXPERIENCE', N'Nộp bản tóm tắt danh sách các dự án tham gia, kiến trúc sử dụng và kết quả bàn giao.', 1, 1),
        (@crit_id, N'Đạt tỷ lệ khách hàng/PM hài lòng (CSAT) >= 85%', 'CUSTOMER_SATISFACTION', N'Minh chứng khảo sát CSAT hoặc xác nhận từ Trưởng dự án.', 1, 2),
        (@crit_id, N'Có chứng chỉ quốc tế Oracle Certified Professional (OCP) Java hoặc AWS Developer', 'CERTIFICATE', N'Upload chứng chỉ quốc tế kèm mã tra cứu xác thực.', 0, 3),
        (@crit_id, N'Thực hiện tối thiểu 1 buổi chia sẻ kỹ thuật (Tech Talk) cho nội bộ', 'OTHER', N'Đính kèm slide thuyết trình hoặc link video ghi lại buổi chia sẻ.', 0, 4);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_463706 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_463706, 4, 5, 85.0, N'Thiết kế giải pháp High Availability, chịu tải cao, giải quyết bài toán phân tán và định hướng kỹ thuật cho team.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Đóng vai trò Technical Lead / Module Lead cho ít nhất 2 hệ thống lớn', 'PROJECT_EXPERIENCE', N'Tài liệu đặc tả kiến trúc giải pháp (Architecture Blueprint) do ứng viên thiết kế.', 1, 1),
        (@crit_id, N'Đạt đánh giá CSAT trung bình >= 90%, không có vi phạm SLA', 'CUSTOMER_SATISFACTION', N'Báo cáo tổng kết chất lượng dịch vụ của các dự án phụ trách.', 1, 2),
        (@crit_id, N'Sở hữu chứng chỉ AWS Solutions Architect hoặc TOGAF hoặc tương đương', 'CERTIFICATE', N'Chứng chỉ kiến trúc chuyên sâu còn hạn sử dụng.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Frontend Developer
-- =======================================================
DECLARE @pos_162181 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Frontend Developer');
DECLARE @crit_id INT;
IF @pos_162181 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_162181 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_162181, 2, 3, 75.0, N'Làm chủ HTML5/CSS3, JavaScript ES6+, ReactJS / VueJS cơ bản, Responsive Web Design và chuẩn tương thích trình duyệt.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Cắt giao diện và tích hợp API cho ít nhất 1 dự án web thực tế', 'PROJECT_EXPERIENCE', N'Link demo sản phẩm web và mã nguồn pull request đã được merge.', 1, 1),
        (@crit_id, N'Chứng chỉ Meta Frontend Developer hoặc khóa học chuyên sâu tương đương', 'CERTIFICATE', N'Bản sao chứng chỉ lập trình frontend.', 0, 2),
        (@crit_id, N'Tỷ lệ lỗi giao diện phát sinh trong giai đoạn nghiệm thử dưới 5%', 'CUSTOMER_SATISFACTION', N'Báo cáo kiểm thử giao diện từ đội ngũ QA/QC.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_162181 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_162181, 3, 4, 80.0, N'Thành thạo TypeScript, Next.js, quản lý trạng thái phức tạp (Redux/Zustand), Web Performance và chuẩn Accessibility.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Độc lập xây dựng Single Page Application (SPA) cho 2 dự án phức tạp', 'PROJECT_EXPERIENCE', N'Hồ sơ kỹ thuật mô tả cấu trúc component và luồng dữ liệu của dự án.', 1, 1),
        (@crit_id, N'Tối ưu hóa điểm Google Lighthouse Performance đạt trên 85 điểm', 'CUSTOMER_SATISFACTION', N'Ảnh chụp màn hình kết quả kiểm tra hiệu năng Lighthouse trước và sau khi tối ưu.', 1, 2),
        (@crit_id, N'Chứng chỉ quốc tế TypeScript / Advanced Frontend Specialist', 'CERTIFICATE', N'Chứng chỉ xác thực năng lực lập trình giao diện nâng cao.', 0, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_162181 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_162181, 4, 5, 85.0, N'Thiết kế kiến trúc Micro-Frontend, Design System doanh nghiệp đa nền tảng, bảo mật Web (OWASP) và cố vấn kỹ thuật.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Chủ trì xây dựng Design System và thư viện Component dùng chung cho công ty', 'PROJECT_EXPERIENCE', N'Tài liệu hướng dẫn sử dụng và Storybook component của hệ thống.', 1, 1),
        (@crit_id, N'Đạt tỷ lệ người dùng đánh giá trải nghiệm giao diện xuất sắc >= 90%', 'CUSTOMER_SATISFACTION', N'Báo cáo khảo sát trải nghiệm người dùng thực tế trên hệ thống sản xuất.', 1, 2),
        (@crit_id, N'Chứng chỉ kiến trúc Cloud Frontend hoặc Web Security Professional', 'CERTIFICATE', N'Chứng chỉ chứng minh năng lực kiến trúc giao diện cấp cao.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: QA / Software Tester
-- =======================================================
DECLARE @pos_980174 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'QA / Software Tester');
DECLARE @crit_id INT;
IF @pos_980174 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_980174 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_980174, 2, 3, 75.0, N'Nắm vững kỹ thuật thiết kế Test Case (BVA, Equivalence Partitioning), Manual Testing, quản lý lỗi trên Jira và Postman API.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Thiết kế và thực thi kiểm thử hoàn tất cho tối thiểu 1 dự án phát hành', 'PROJECT_EXPERIENCE', N'Tài liệu Test Plan, Test Cases và báo cáo Test Summary của dự án.', 1, 1),
        (@crit_id, N'Chứng chỉ kiểm thử phần mềm quốc tế ISTQB Foundation Level (CTFL)', 'CERTIFICATE', N'Chứng chỉ ISTQB CTFL kèm mã tra cứu online.', 1, 2),
        (@crit_id, N'Tỷ lệ phát hiện lỗi nghiêm trọng trước giai đoạn UAT đạt trên 90%', 'CUSTOMER_SATISFACTION', N'Xác nhận của Quản trị dự án về hiệu quả kiểm thử phát hiện lỗi sớm.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_980174 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_980174, 3, 4, 80.0, N'Làm chủ Automation Testing (Selenium/Playwright), API Automation (RestAssured), Performance Test (JMeter) và CI/CD testing.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng Automation Test Framework cho 2 dự án phần mềm', 'PROJECT_EXPERIENCE', N'Mã nguồn kịch bản tự động hóa và báo cáo kết quả chạy kiểm thử tự động.', 1, 1),
        (@crit_id, N'Tỷ lệ ca kiểm thử hồi quy được tự động hóa đạt trên 60%', 'CUSTOMER_SATISFACTION', N'Báo cáo độ phủ kiểm thử tự động hóa được Tech Lead phê duyệt.', 1, 2),
        (@crit_id, N'Chứng chỉ ISTQB Advanced Level (Test Analyst hoặc Technical Test Analyst)', 'CERTIFICATE', N'Chứng chỉ kiểm thử phần mềm cấp độ nâng cao.', 0, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_980174 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_980174, 4, 5, 85.0, N'Thiết kế chiến lược QA tổng thể, Security Testing, Chaos Testing và thiết lập quy chuẩn Quality Gate doanh nghiệp.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Đảm nhiệm vai trò QA Lead xây dựng quy trình bảo đảm chất lượng cho 2 hệ thống lớn', 'PROJECT_EXPERIENCE', N'Quy chuẩn Quality Gate và báo cáo quản trị chất lượng toàn dự án.', 1, 1),
        (@crit_id, N'Dự án vận hành ổn định không phát sinh lỗi thoát nghiêm trọng lên Production', 'CUSTOMER_SATISFACTION', N'Báo cáo số liệu bảo hành sản phẩm và đánh giá chất lượng bàn giao.', 1, 2),
        (@crit_id, N'Chứng chỉ ISTQB Test Manager hoặc Certified Software Quality Engineer (CSQE)', 'CERTIFICATE', N'Chứng chỉ quản lý kiểm thử chất lượng phần mềm chuyên nghiệp.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: DevOps Engineer
-- =======================================================
DECLARE @pos_184742 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'DevOps Engineer');
DECLARE @crit_id INT;
IF @pos_184742 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_184742 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_184742, 2, 3, 75.0, N'Quản trị Linux, viết kịch bản Bash/Python, đóng gói Docker, GitOps và duy trì CI/CD pipeline căn bản.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng và vận hành thành công pipeline CI/CD cho ít nhất 1 dự án', 'PROJECT_EXPERIENCE', N'File cấu hình pipeline (GitHub Actions/GitLab CI) và nhật ký triển khai.', 1, 1),
        (@crit_id, N'Chứng chỉ Linux Professional Institute (LPIC-1) hoặc Docker Certified Associate', 'CERTIFICATE', N'Chứng chỉ quản trị hệ thống mã nguồn mở.', 0, 2),
        (@crit_id, N'Thời gian xử lý sự cố máy chủ và khôi phục dịch vụ đạt chuẩn SLA yêu cầu', 'CUSTOMER_SATISFACTION', N'Báo cáo chỉ số MTTR (Mean Time to Resolution) trong quý.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_184742 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_184742, 3, 4, 80.0, N'Thành thạo Kubernetes (K8s), Terraform (IaC), Cloud Computing (AWS/GCP), giám sát Prometheus/Grafana và ELK Stack.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Tự động hóa hạ tầng bằng Terraform và quản trị cụm K8s cho 2 dự án', 'PROJECT_EXPERIENCE', N'Mã nguồn hạ tầng Terraform và sơ đồ kiến trúc cụm container K8s.', 1, 1),
        (@crit_id, N'Tối ưu hóa chi phí vận hành hạ tầng Cloud giảm thiểu tối thiểu 15%', 'CUSTOMER_SATISFACTION', N'Báo cáo đối soát hóa đơn Cloud trước và sau khi tối ưu tài nguyên.', 1, 2),
        (@crit_id, N'Chứng chỉ Certified Kubernetes Administrator (CKA) hoặc AWS SysOps Administrator', 'CERTIFICATE', N'Chứng chỉ quốc tế K8s hoặc Cloud Ops.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_184742 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_184742, 4, 5, 85.0, N'Kiến trúc Multi-Cloud, Site Reliability Engineering (SRE), DevSecOps, kế hoạch khắc phục thảm họa (Disaster Recovery).', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Thiết kế hạ tầng chịu tải lớn bảo đảm SLA Uptime hệ thống đạt 99.95%', 'PROJECT_EXPERIENCE', N'Báo cáo kiến trúc High Availability và nhật ký diễn tập Disaster Recovery.', 1, 1),
        (@crit_id, N'Không có vi phạm an toàn thông tin hạ tầng và vượt qua kỳ kiểm toán bảo mật', 'CUSTOMER_SATISFACTION', N'Biên bản kiểm toán an ninh mạng và đánh giá an toàn hạ tầng.', 1, 2),
        (@crit_id, N'Chứng chỉ AWS Certified DevOps Engineer Professional hoặc Certified Kubernetes Security (CKS)', 'CERTIFICATE', N'Chứng chỉ chuyên gia DevOps/Cloud cấp độ cao nhất.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Business Analyst (BA)
-- =======================================================
DECLARE @pos_53767 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Analyst (BA)');
DECLARE @crit_id INT;
IF @pos_53767 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_53767 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_53767, 2, 3, 75.0, N'Kỹ năng phỏng vấn yêu cầu, vẽ biểu đồ Use Case, Activity, viết tài liệu SRS và User Stories kèm Acceptance Criteria rõ ràng.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Hoàn thiện tài liệu đặc tả yêu cầu SRS/BRD cho ít nhất 1 dự án được ký duyệt', 'PROJECT_EXPERIENCE', N'Biên bản bàn giao và chữ ký phê duyệt tài liệu đặc tả của khách hàng.', 1, 1),
        (@crit_id, N'Chứng chỉ Entry Certificate in Business Analysis (ECBA - IIBA)', 'CERTIFICATE', N'Chứng chỉ phân tích nghiệp vụ sơ cấp quốc tế.', 0, 2),
        (@crit_id, N'Đánh giá độ rõ ràng của tài liệu đặc tả từ đội phát triển đạt >= 80% hài lòng', 'CUSTOMER_SATISFACTION', N'Khảo sát ý kiến nội bộ từ Tech Lead và QA của dự án.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_53767 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_53767, 3, 4, 80.0, N'Phân tích quy trình kinh doanh (BPMN), thiết kế Prototype/Wireframe, quản lý phạm vi dự án và Data Flow Diagram.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Đảm nhiệm vai trò BA chính phụ trách phân tích nghiệp vụ cho 2 dự án phức tạp', 'PROJECT_EXPERIENCE', N'Bộ tài liệu quy trình nghiệp vụ BPMN và prototype chức năng phần mềm.', 1, 1),
        (@crit_id, N'Chỉ số hài lòng khách hàng (CSAT) về giải pháp nghiệp vụ đề xuất đạt >= 85%', 'CUSTOMER_SATISFACTION', N'Khảo sát CSAT chính thức của khách hàng đối tác.', 1, 2),
        (@crit_id, N'Chứng chỉ Certification of Capability in Business Analysis (CCBA) hoặc PMI-PBA', 'CERTIFICATE', N'Chứng chỉ hành nghề phân tích nghiệp vụ trung cấp.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_53767 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_53767, 4, 5, 85.0, N'Tư vấn chuyển đổi số, Enterprise Architecture, chiến lược sản phẩm (Product Strategy) và tư vấn tiền bán hàng (Pre-sales).', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Dẫn dắt phân tích giải pháp chiến lược chuyển đổi số cho 2 khách hàng doanh nghiệp lớn', 'PROJECT_EXPERIENCE', N'Hồ sơ đề xuất giải pháp kỹ thuật số và phân tích hiệu quả đầu tư ROI.', 1, 1),
        (@crit_id, N'Khách hàng gia hạn hợp đồng tư vấn hoặc mở rộng thêm phạm vi giải pháp', 'CUSTOMER_SATISFACTION', N'Hợp đồng phụ lục mở rộng giải pháp chuyển đổi số.', 1, 2),
        (@crit_id, N'Chứng chỉ Certified Business Analysis Professional (CBAP - IIBA)', 'CERTIFICATE', N'Chứng chỉ chuyên gia phân tích nghiệp vụ cao cấp nhất của IIBA.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Mobile App Developer
-- =======================================================
DECLARE @pos_63811 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Mobile App Developer');
DECLARE @crit_id INT;
IF @pos_63811 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_63811 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_63811, 2, 3, 75.0, N'Phát triển ứng dụng di động Flutter/React Native/Native, tích hợp RESTful API, quản lý State và xuất bản ứng dụng lên Store.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Tham gia phát triển và release thành công ít nhất 1 ứng dụng di động lên Store', 'PROJECT_EXPERIENCE', N'Link ứng dụng trên App Store / Google Play Store và danh sách module phụ trách.', 1, 1),
        (@crit_id, N'Chứng chỉ hoàn thành khóa đào tạo Mobile App Engineering chuyên sâu', 'CERTIFICATE', N'Chứng chỉ chuyên môn lập trình di động.', 0, 2),
        (@crit_id, N'Tỷ lệ phiên người dùng không bị crash (Crash-free session) đạt >= 98%', 'CUSTOMER_SATISFACTION', N'Báo cáo thống kê chỉ số từ Firebase Crashlytics.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_63811 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_63811, 3, 4, 80.0, N'Kiến trúc Offline-first (Local DB SQLite/Realm), Push Notification, Deep Linking, tối ưu hóa mức tiêu thụ pin và bộ nhớ.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Làm chủ kiến trúc và phát triển tính năng cốt lõi cho 2 ứng dụng di động', 'PROJECT_EXPERIENCE', N'Tài liệu thiết kế kiến trúc phần mềm di động và mã nguồn dự án.', 1, 1),
        (@crit_id, N'Đạt tỷ lệ crash-free session >= 99.5% và điểm đánh giá trên Store đạt >= 4.5 sao', 'CUSTOMER_SATISFACTION', N'Báo cáo số liệu người dùng và điểm xếp hạng từ Google Play / App Store.', 1, 2),
        (@crit_id, N'Chứng chỉ Meta Android/iOS Developer hoặc Google Associate Android Developer', 'CERTIFICATE', N'Chứng chỉ phát triển ứng dụng di động chuyên nghiệp.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_63811 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_63811, 4, 5, 85.0, N'Kiến trúc ứng dụng di động quy mô lớn, Native Bridging, Mobile Security & Obfuscation, xây dựng SDK dùng chung.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Chủ trì kiến trúc ứng dụng di động phục vụ trên 100.000 người dùng tích cực', 'PROJECT_EXPERIENCE', N'Báo cáo kiến trúc phân hệ Mobile và bộ SDK dùng chung đã triển khai.', 1, 1),
        (@crit_id, N'Không có lỗ hổng bảo mật ứng dụng di động theo tiêu chuẩn OWASP Mobile Top 10', 'CUSTOMER_SATISFACTION', N'Biên bản kiểm tra an toàn mã nguồn di động (SAST/DAST).', 1, 2),
        (@crit_id, N'Chứng chỉ chuyên gia kỹ thuật di động hoặc giải thưởng sáng tạo sản phẩm số', 'CERTIFICATE', N'Bằng khen hoặc chứng chỉ chuyên sâu di động cấp độ cao cấp.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Sales Executive
-- =======================================================
DECLARE @pos_914358 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Sales Executive');
DECLARE @crit_id INT;
IF @pos_914358 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_914358 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_914358, 2, 3, 75.0, N'Kỹ năng tìm kiếm khách hàng tiềm năng B2B, thuyết trình giải pháp, lập báo giá chuyên nghiệp và xử lý từ chối cơ bản.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Đạt tối thiểu 100% chỉ tiêu doanh số bán hàng được giao trong 2 quý liên tiếp', 'PROJECT_EXPERIENCE', N'Báo cáo doanh số CRM và bản nghiệm thu chỉ tiêu KPI kinh doanh.', 1, 1),
        (@crit_id, N'Chứng chỉ đào tạo kỹ năng bán hàng B2B chuyên nghiệp', 'CERTIFICATE', N'Chứng chỉ hoàn thành khóa học kỹ thuật bán hàng giải pháp B2B.', 0, 2),
        (@crit_id, N'Khảo sát mức độ hài lòng của khách hàng mới ký hợp đồng đạt >= 80%', 'CUSTOMER_SATISFACTION', N'Biên bản khảo sát chất lượng dịch vụ từ khách hàng ký mới.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_914358 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_914358, 3, 4, 80.0, N'Đàm phán hợp đồng giá trị cao, chốt đơn hàng phức tạp, phối hợp xây dựng giải pháp kỹ thuật thử nghiệm (POC).', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Hoàn thành chỉ tiêu doanh thu lũy kế trên 2 tỷ đồng trong năm tài chính', 'PROJECT_EXPERIENCE', N'Bảng sao kê doanh số bán hàng và danh sách hợp đồng đã thanh lý.', 1, 1),
        (@crit_id, N'Tỷ lệ chốt hợp đồng thành công (Conversion Rate) tăng trưởng tối thiểu 15%', 'CUSTOMER_SATISFACTION', N'Báo cáo chỉ số chuyển đổi phễu bán hàng từ phần mềm CRM.', 1, 2),
        (@crit_id, N'Chứng chỉ đàm phán thương mại quốc tế hoặc quản trị khách hàng B2B', 'CERTIFICATE', N'Chứng chỉ đàm phán và thuyết phục trong kinh doanh.', 0, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_914358 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_914358, 4, 5, 85.0, N'Đấu thầu dự án lớn cấp tập đoàn, đàm phán hợp đồng khung nhiều năm, hoạch định chiến lược kinh doanh ngành nghề.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Ký kết thành công ít nhất 2 hợp đồng chiến lược có giá trị trên 5 tỷ đồng/hợp đồng', 'PROJECT_EXPERIENCE', N'Bản sao hợp đồng kinh tế và quyết định trúng thầu dự án lớn.', 1, 1),
        (@crit_id, N'Khách hàng đánh giá CSAT >= 90% và tỷ lệ gia hạn hợp đồng đạt >= 85%', 'CUSTOMER_SATISFACTION', N'Khảo sát khách hàng chiến lược và xác nhận gia hạn hợp đồng.', 1, 2),
        (@crit_id, N'Chứng chỉ Certified Professional Sales Person (CPSP) hoặc tương đương', 'CERTIFICATE', N'Chứng chỉ chuyên gia bán hàng chuyên nghiệp quốc tế.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Key Account Manager (KAM)
-- =======================================================
DECLARE @pos_341153 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Key Account Manager (KAM)');
DECLARE @crit_id INT;
IF @pos_341153 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_341153 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_341153, 2, 3, 75.0, N'Quản lý hồ sơ khách hàng trọng điểm, chăm sóc quan hệ đối tác, xử lý kịp thời khiếu nại phát sinh và theo dõi công nợ VIP.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Duy trì 100% tài khoản khách hàng VIP được giao không bị hủy hợp đồng', 'PROJECT_EXPERIENCE', N'Báo cáo tỷ lệ duy trì khách hàng (Retention Rate) trên hệ thống.', 1, 1),
        (@crit_id, N'Chứng chỉ Quản trị quan hệ khách hàng chuyên nghiệp (CRM/KAM)', 'CERTIFICATE', N'Chứng chỉ hoàn tất chương trình đào tạo quản trị tài khoản trọng điểm.', 0, 2),
        (@crit_id, N'Điểm đánh giá độ hài lòng CSAT từ khách hàng trọng điểm đạt >= 85%', 'CUSTOMER_SATISFACTION', N'Phiếu đánh giá chất lượng dịch vụ định kỳ từ đại diện khách hàng VIP.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_341153 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_341153, 3, 4, 80.0, N'Thực hiện thành công bán chéo (Cross-selling) và bán thêm (Up-selling), xây dựng kế hoạch Joint Business Plan hàng năm.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Tăng trưởng doanh thu từ tệp khách hàng trọng điểm phụ trách tối thiểu 20%/năm', 'PROJECT_EXPERIENCE', N'Báo cáo doanh số bán thêm và phân tích tăng trưởng tài khoản khách hàng.', 1, 1),
        (@crit_id, N'Xây dựng thành công kế hoạch kinh doanh hợp tác (Joint Business Plan) cho 3 khách hàng lớn', 'CUSTOMER_SATISFACTION', N'Bản kế hoạch Joint Business Plan có xác nhận của đối tác.', 1, 2),
        (@crit_id, N'Chứng chỉ Strategic Account Management Association (SAMA) hoặc tương đương', 'CERTIFICATE', N'Chứng chỉ quốc tế về quản lý tài khoản chiến lược.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_341153 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_341153, 4, 5, 85.0, N'Đàm phán cấp C-level, giải quyết khủng hoảng quan hệ đối tác lớn, thiết lập liên minh chiến lược lâu dài.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Giữ chân 100% Top 5 khách hàng lớn nhất công ty và tăng trưởng doanh thu 25%', 'PROJECT_EXPERIENCE', N'Báo cáo doanh thu Top khách hàng chiến lược do Ban Giám Đốc xác nhận.', 1, 1),
        (@crit_id, N'Chỉ số đo lường mức độ thiện cảm của khách hàng VIP (NPS) đạt >= 70 điểm', 'CUSTOMER_SATISFACTION', N'Báo cáo khảo sát Net Promoter Score độc lập.', 1, 2),
        (@crit_id, N'Chứng chỉ Executive Key Account Director hoặc chứng chỉ lãnh đạo kinh doanh cấp cao', 'CERTIFICATE', N'Chứng chỉ quản trị tài khoản chiến lược cấp chuyên gia.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Business Development Rep (BDR)
-- =======================================================
DECLARE @pos_339749 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Business Development Rep (BDR)');
DECLARE @crit_id INT;
IF @pos_339749 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_339749 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_339749, 2, 3, 75.0, N'Nghiên cứu thị trường mục tiêu, lọc tệp Outbound Lead, thiết lập các cuộc hẹn demo giải pháp kỹ thuật chất lượng.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Đạt chỉ tiêu tạo lập tối thiểu 30 cuộc họp đánh giá nhu cầu (Discovery Call) chất lượng/quý', 'PROJECT_EXPERIENCE', N'Nhật ký cuộc gọi và lịch họp được xác nhận trên hệ thống CRM.', 1, 1),
        (@crit_id, N'Chứng chỉ Sales Prospecting hoặc Inbound Sales Certified', 'CERTIFICATE', N'Chứng chỉ tìm kiếm và khai thác khách hàng tiềm năng.', 0, 2),
        (@crit_id, N'Tỷ lệ chuyển đổi từ Lead sang Cơ hội bán hàng (Opportunity) đạt >= 25%', 'CUSTOMER_SATISFACTION', N'Báo cáo hiệu suất chuyển đổi đường ống bán hàng trong quý.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_339749 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_339749, 3, 4, 80.0, N'Mở rộng mạng lưới đối tác liên kết (Channel Partners), tối ưu hóa quy trình luân chuyển Sales Pipeline.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Thiết lập thành công mạng lưới với ít nhất 3 đối tác phân phối chiến lược mới', 'PROJECT_EXPERIENCE', N'Biên bản ghi nhớ hợp tác kinh doanh (MOU) đã ký kết.', 1, 1),
        (@crit_id, N'Đóng góp giá trị đường ống bán hàng (Pipeline Value) trên 5 tỷ đồng trong năm', 'CUSTOMER_SATISFACTION', N'Báo cáo thống kê giá trị đường ống bán hàng trên CRM.', 1, 2),
        (@crit_id, N'Chứng chỉ Business Development Specialist hoặc Channel Management', 'CERTIFICATE', N'Chứng chỉ chuyên viên phát triển kinh doanh đối tác.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_339749 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_339749, 4, 5, 85.0, N'Khai phá thị trường mới, xây dựng mô hình liên kết kinh doanh mới, dẫn dắt chiến lược phát triển thị phần toàn quốc.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Khai phá thành công 1 thị trường địa lý hoặc phân khúc ngành mới mang lại doanh thu bền vững', 'PROJECT_EXPERIENCE', N'Báo cáo phân tích thị trường mới và các hợp đồng thương mại đầu tiên.', 1, 1),
        (@crit_id, N'Đóng góp trên 30% tổng số cơ hội bán hàng lớn cho toàn bộ khối kinh doanh', 'CUSTOMER_SATISFACTION', N'Báo cáo đánh giá đóng góp doanh thu của Giám Đốc Kinh Doanh.', 1, 2),
        (@crit_id, N'Đề án phát triển thị trường 3 năm được Hội Đồng Quản Trị thông qua', 'CERTIFICATE', N'Nghị quyết phê duyệt đề án phát triển kinh doanh mới.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Digital Marketing Specialist
-- =======================================================
DECLARE @pos_535874 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Digital Marketing Specialist');
DECLARE @crit_id INT;
IF @pos_535874 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_535874 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_535874, 2, 3, 75.0, N'Vận hành chiến dịch Google Ads, Meta Ads cơ bản, tối ưu On-page SEO, theo dõi chỉ số lưu lượng trên Google Analytics.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Quản lý và tối ưu ít nhất 2 chiến dịch quảng cáo trực tuyến đạt chỉ số CPA mục tiêu', 'PROJECT_EXPERIENCE', N'Báo cáo hiệu quả chiến dịch quảng cáo kỹ thuật số và chi phí CPA.', 1, 1),
        (@crit_id, N'Chứng chỉ Google Ads Search Certification hoặc Meta Certified Media Associate', 'CERTIFICATE', N'Chứng chỉ quảng cáo trực tuyến chính thức của Google/Meta.', 1, 2),
        (@crit_id, N'Tỷ lệ chuyển đổi lưu lượng truy cập tự nhiên website tăng trưởng dương trong 3 tháng', 'CUSTOMER_SATISFACTION', N'Báo cáo phân tích lưu lượng từ Google Search Console.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_535874 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_535874, 3, 4, 80.0, N'Tối ưu phễu chuyển đổi (Funnel Optimization), Performance Marketing đa kênh, Marketing Automation (HubSpot/Mailchimp).', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Tối ưu hóa chi phí thu hút khách hàng (CAC) giảm 15% trong khi duy trì lượng Lead chất lượng', 'PROJECT_EXPERIENCE', N'Báo cáo phân tích chi phí CAC và số lượng khách hàng tiềm năng thu được.', 1, 1),
        (@crit_id, N'Đạt chỉ số hoàn vốn đầu tư quảng cáo (ROAS) trung bình >= 3.5 lần trên các kênh trả phí', 'CUSTOMER_SATISFACTION', N'Báo cáo tài chính doanh thu phát sinh từ kênh quảng cáo số.', 1, 2),
        (@crit_id, N'Chứng chỉ Google Analytics 4 (GA4) Certification và HubSpot Marketing Automation', 'CERTIFICATE', N'Chứng chỉ chuyên sâu về đo lường và tự động hóa tiếp thị số.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_535874 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_535874, 4, 5, 85.0, N'Hoạch định chiến lược Digital Marketing tổng thể, mô hình phân bổ đa kênh (Attribution Modeling), Growth Hacking.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Chủ trì chiến lược tiếp thị số mang lại mức tăng trưởng doanh thu trực tuyến trên 40%', 'PROJECT_EXPERIENCE', N'Kế hoạch chiến lược Digital Marketing tổng thể năm và kết quả thực hiện.', 1, 1),
        (@crit_id, N'Báo cáo phân bổ ngân sách tối ưu lợi nhuận đầu tư tiếp thị (MROI) đạt xuất sắc', 'CUSTOMER_SATISFACTION', N'Báo cáo đánh giá hiệu quả đầu tư tiếp thị được Giám đốc Marketing phê duyệt.', 1, 2),
        (@crit_id, N'Chứng chỉ Professional Diploma in Digital Marketing (DMI) hoặc tương đương', 'CERTIFICATE', N'Chứng chỉ quốc tế chuyên gia tiếp thị kỹ thuật số của Viện DMI.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Content Creator & Copywriter
-- =======================================================
DECLARE @pos_849801 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Content Creator & Copywriter');
DECLARE @crit_id INT;
IF @pos_849801 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_849801 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_849801, 2, 3, 75.0, N'Biên soạn bài viết chuẩn SEO, bài đăng truyền thông xã hội (Social Media Copy), kịch bản video ngắn và thông cáo báo chí cơ bản.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xuất bản tối thiểu 20 bài viết chuẩn SEO đạt vị trí Top 10 tìm kiếm Google', 'PROJECT_EXPERIENCE', N'Danh sách liên kết bài viết và báo cáo xếp hạng từ khóa tìm kiếm.', 1, 1),
        (@crit_id, N'Chứng chỉ Content Marketing Certified của HubSpot hoặc Semrush', 'CERTIFICATE', N'Chứng chỉ tiếp thị nội dung kỹ thuật số.', 0, 2),
        (@crit_id, N'Tỷ lệ tương tác tự nhiên (Organic Engagement Rate) trên các kênh xã hội tăng >= 20%', 'CUSTOMER_SATISFACTION', N'Báo cáo chỉ số tương tác bài viết trên Facebook/LinkedIn.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_849801 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_849801, 3, 4, 80.0, N'Sáng tạo Concept truyền thông, viết Copywriting cho Landing Page chuyển đổi cao, định hình Brand Voice nhất quán.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng thông điệp chủ đạo (Key Hook) cho 2 chiến dịch ra mắt sản phẩm thành công', 'PROJECT_EXPERIENCE', N'Hồ sơ Creative Brief và bộ nội dung quảng bá đa kênh của chiến dịch.', 1, 1),
        (@crit_id, N'Tỷ lệ chuyển đổi hành động (CR) trên các trang Landing Page đạt >= 4.5%', 'CUSTOMER_SATISFACTION', N'Báo cáo số liệu chuyển đổi Landing Page từ công cụ phân tích.', 1, 2),
        (@crit_id, N'Chứng chỉ Copywriting chuyên nghiệp hoặc nghệ thuật kể chuyện thương hiệu (Storytelling)', 'CERTIFICATE', N'Chứng chỉ nâng cao về nghệ thuật biên soạn nội dung quảng cáo.', 0, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_849801 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_849801, 4, 5, 85.0, N'Định vị ngôn ngữ thương hiệu doanh nghiệp, xuất bản nội dung dẫn dắt tư tưởng (Whitepaper/Ebook), quản trị khủng hoảng nội dung.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Chủ biên 2 ấn phẩm báo cáo chuyên ngành / Whitepaper khẳng định uy tín thương hiệu công ty', 'PROJECT_EXPERIENCE', N'Bản in hoặc tài liệu số ấn phẩm Whitepaper đã phát hành rộng rãi.', 1, 1),
        (@crit_id, N'Xây dựng Bộ quy chuẩn giọng văn thương hiệu (Brand Voice Guideline) áp dụng toàn tập đoàn', 'CUSTOMER_SATISFACTION', N'Tài liệu Brand Guideline đã được Ban Điều Hành phê duyệt ban hành.', 1, 2),
        (@crit_id, N'Chứng chỉ Strategic Brand Communication hoặc giải thưởng bài viết xuất sắc ngành truyền thông', 'CERTIFICATE', N'Bằng khen hoặc chứng chỉ chiến lược truyền thông thương hiệu.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: UI/UX Product Designer
-- =======================================================
DECLARE @pos_271722 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'UI/UX Product Designer');
DECLARE @crit_id INT;
IF @pos_271722 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_271722 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_271722, 2, 3, 75.0, N'Thiết kế Wireframe, giao diện người dùng trên Figma, am hiểu Typography, Color Theory và xây dựng User Flow trực quan.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Hoàn thiện bộ thiết kế UI và Prototype tương tác cho ít nhất 1 tính năng phần mềm lớn', 'PROJECT_EXPERIENCE', N'File Figma thiết kế hệ thống màn hình và luồng thao tác người dùng.', 1, 1),
        (@crit_id, N'Chứng chỉ Google UX Design Professional Certificate', 'CERTIFICATE', N'Chứng chỉ thiết kế trải nghiệm người dùng chuyên nghiệp của Google.', 1, 2),
        (@crit_id, N'Kết quả kiểm thử tính khả dụng (Usability Testing) đạt mức độ dễ sử dụng cao', 'CUSTOMER_SATISFACTION', N'Báo cáo kết quả phỏng vấn và quan sát người dùng thao tác mẫu.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_271722 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_271722, 3, 4, 80.0, N'Xây dựng Design System toàn diện, thực hiện User Research, A/B Testing giao diện và tối ưu kiến trúc thông tin.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng và duy trì Design System đồng bộ trên Figma cho 2 dòng sản phẩm số', 'PROJECT_EXPERIENCE', N'Bộ thư viện Design System với đầy đủ components, tokens và guidelines.', 1, 1),
        (@crit_id, N'Báo cáo A/B Testing chứng minh cải thiện trải nghiệm và tăng 15% tỷ lệ hoàn thành tác vụ', 'CUSTOMER_SATISFACTION', N'Báo cáo phân tích dữ liệu kiểm thử A/B Testing thực tế.', 1, 2),
        (@crit_id, N'Chứng chỉ Nielsen Norman Group (NN/g) UX Certification hoặc Interaction Design Foundation', 'CERTIFICATE', N'Chứng chỉ quốc tế uy tín về thiết kế tương tác người dùng.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_271722 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_271722, 4, 5, 85.0, N'Định hình chiến lược trải nghiệm sản phẩm số (Product Experience Strategy), cố vấn văn hóa tư duy thiết kế (Design Thinking).', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Dẫn dắt thiết kế trải nghiệm sản phẩm chủ lực đạt chỉ số hài lòng người dùng CSAT >= 90%', 'PROJECT_EXPERIENCE', N'Báo cáo nghiên cứu người dùng và lộ trình cải tiến UX/UI chiến lược.', 1, 1),
        (@crit_id, N'Thiết kế đạt chuẩn Accessibility quốc tế (WCAG 2.1 AA) và tối ưu hóa chuyển đổi thương mại', 'CUSTOMER_SATISFACTION', N'Chứng nhận kiểm toán khả năng tiếp cận WCAG của sản phẩm số.', 1, 2),
        (@crit_id, N'Chứng chỉ Senior UX Master Certified hoặc bằng khen thiết kế sản phẩm số xuất sắc', 'CERTIFICATE', N'Chứng nhận chuyên gia thiết kế trải nghiệm cấp cao.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Kế Toán Tổng Hợp (General Accountant)
-- =======================================================
DECLARE @pos_245052 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Kế Toán Tổng Hợp (General Accountant)');
DECLARE @crit_id INT;
IF @pos_245052 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_245052 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_245052, 2, 3, 75.0, N'Hạch toán sổ sách chứng từ kế toán, kê khai thuế GTGT, TNCN, đối chiếu công nợ và vận hành phần mềm kế toán doanh nghiệp.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Hoàn thành công tác khóa sổ kế toán tháng đúng thời hạn và bảo đảm tính hợp pháp chứng từ', 'PROJECT_EXPERIENCE', N'Biên bản khóa sổ tài chính tháng và bảng cân đối số phát sinh kế toán.', 1, 1),
        (@crit_id, N'Chứng chỉ bồi dưỡng Kế toán trưởng hoặc Kế toán doanh nghiệp thực hành chuyên sâu', 'CERTIFICATE', N'Chứng chỉ nghiệp vụ kế toán chuyên nghiệp do cơ quan có thẩm quyền cấp.', 1, 2),
        (@crit_id, N'Đối chiếu công nợ phải thu, phải trả với khách hàng và đối tác khớp chính xác 100%', 'CUSTOMER_SATISFACTION', N'Biên bản đối chiếu công nợ quý có xác nhận của đối tác.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_245052 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_245052, 3, 4, 80.0, N'Lập Báo cáo tài chính năm, quyết toán thuế TNDN, kiểm soát chi phí hoạt động theo định mức ngân sách và quản trị dòng tiền.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Độc lập lập hoàn chỉnh Báo cáo tài chính năm được đơn vị kiểm toán độc lập chấp nhận toàn phần', 'PROJECT_EXPERIENCE', N'Báo cáo tài chính năm và hồ sơ quyết toán thuế thu nhập doanh nghiệp.', 1, 1),
        (@crit_id, N'Phân tích biến động chi phí quý và đề xuất giải pháp tiết giảm 5% chi phí vận hành gián tiếp', 'CUSTOMER_SATISFACTION', N'Báo cáo phân tích quản trị chi phí được Kế toán trưởng phê duyệt.', 1, 2),
        (@crit_id, N'Chứng chỉ Kế toán viên hành nghề (CPA Việt Nam) hoặc chứng chỉ kế toán quốc tế CMA', 'CERTIFICATE', N'Chứng chỉ CPA Việt Nam còn hiệu lực.', 0, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_245052 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_245052, 4, 5, 85.0, N'Hợp nhất Báo cáo tài chính, hoạch định chính sách thuế hợp pháp, thiết lập hệ thống kiểm soát nội bộ tài chính theo chuẩn IFRS.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng thành công hệ thống tài chính kế toán chuyển đổi theo chuẩn mực báo cáo IFRS', 'PROJECT_EXPERIENCE', N'Bộ quy chế kế toán tài chính và sổ tay hạch toán IFRS của doanh nghiệp.', 1, 1),
        (@crit_id, N'Tối ưu hóa chi phí thuế hợp pháp và không bị xử phạt vi phạm hành chính về thuế', 'CUSTOMER_SATISFACTION', N'Biên bản thanh tra kiểm tra thuế với kết quả tuân thủ xuất sắc.', 1, 2),
        (@crit_id, N'Chứng chỉ ACCA (Association of Chartered Certified Accountants) hoặc CPA Úc', 'CERTIFICATE', N'Chứng chỉ kế toán công chứng quốc tế.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Chuyên Viên Kiểm Toán Nội Bộ
-- =======================================================
DECLARE @pos_316647 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Chuyên Viên Kiểm Toán Nội Bộ');
DECLARE @crit_id INT;
IF @pos_316647 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_316647 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_316647, 2, 3, 75.0, N'Kiểm tra tính tuân thủ quy chế chi tiêu, rà soát tính hợp lý hợp lệ chứng từ thanh toán, lập biên bản ghi nhận sai phạm nội bộ.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Thực hiện kiểm toán tuân thủ cho ít nhất 2 quy trình nội bộ của các phòng ban', 'PROJECT_EXPERIENCE', N'Biên bản kiểm toán tuân thủ và danh mục các điểm lưu ý kiểm toán.', 1, 1),
        (@crit_id, N'Chứng chỉ Kiểm toán nội bộ cơ bản hoặc Cử nhân chuyên ngành Kiểm toán', 'CERTIFICATE', N'Văn bằng cử nhân kiểm toán hoặc chứng nhận đào tạo kiểm toán tuân thủ.', 0, 2),
        (@crit_id, N'Tỷ lệ đôn đốc và theo dõi khắc phục các khuyến nghị kiểm toán đạt 100% hoàn thành', 'CUSTOMER_SATISFACTION', N'Báo cáo theo dõi thực hiện kiến nghị kiểm toán nội bộ.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_316647 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_316647, 3, 4, 80.0, N'Đánh giá rủi ro hoạt động, kiểm toán chuyên đề gian lận, tư vấn hoàn thiện quy trình kiểm soát nội bộ các phòng ban.', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Chủ trì 2 cuộc kiểm toán nội bộ chuyên đề độc lập và ban hành báo cáo kiểm toán chuẩn mực', 'PROJECT_EXPERIENCE', N'Báo cáo kiểm toán chuyên đề được Trưởng ban kiểm toán nội bộ thông qua.', 1, 1),
        (@crit_id, N'Đề xuất tối thiểu 5 cải tiến kiểm soát nội bộ giúp ngăn ngừa thất thoát tài sản doanh nghiệp', 'CUSTOMER_SATISFACTION', N'Văn bản tiếp thu kiến nghị cải tiến từ Ban Tổng Giám Đốc.', 1, 2),
        (@crit_id, N'Chứng chỉ Certified Internal Auditor (CIA) Part 1 & Part 2', 'CERTIFICATE', N'Chứng chỉ kiểm toán nội bộ quốc tế của Viện IIA.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_316647 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_316647, 4, 5, 85.0, N'Thiết kế khung quản trị rủi ro doanh nghiệp (ERM - COSO Framework), điều tra gian lận trọng yếu, báo cáo Hội Đồng Quản Trị.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng Bản đồ rủi ro toàn diện (Risk Heatmap) cho toàn bộ hoạt động kinh doanh công ty', 'PROJECT_EXPERIENCE', N'Tài liệu khung quản trị rủi ro và ma trận kiểm soát rủi ro doanh nghiệp.', 1, 1),
        (@crit_id, N'Báo cáo độc lập trước Ủy Ban Kiểm Toán thuộc Hội Đồng Quản Trị đạt tín nhiệm cao', 'CUSTOMER_SATISFACTION', N'Nghị quyết của Ủy Ban Kiểm Toán ghi nhận đóng góp kiểm toán nội bộ.', 1, 2),
        (@crit_id, N'Chứng chỉ Certified Internal Auditor (CIA) đầy đủ hoặc Certified Fraud Examiner (CFE)', 'CERTIFICATE', N'Chứng chỉ kiểm toán nội bộ hoặc chuyên gia điều tra gian lận quốc tế.', 1, 3);
    END
END
GO

-- =======================================================
-- BAREM THĂNG CẤP CHO VỊ TRÍ: Financial Planning & Analysis (FP&A)
-- =======================================================
DECLARE @pos_968032 INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Financial Planning & Analysis (FP&A)');
DECLARE @crit_id INT;
IF @pos_968032 IS NOT NULL
BEGIN
    -- Nấc 2 -> 3
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_968032 AND from_level_id = 2 AND to_level_id = 3)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_968032, 2, 3, 75.0, N'Thu thập số liệu tài chính, xây dựng báo cáo phân tích Variance (Thực tế vs Ngân sách), theo dõi chỉ số KPI tài chính định kỳ.', 7.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Hoàn thành báo cáo phân tích hiệu quả tài chính hàng tháng phục vụ cuộc họp Ban Giám Đốc', 'PROJECT_EXPERIENCE', N'Bộ tài liệu phân tích tài chính hàng tháng kèm biểu đồ trực quan.', 1, 1),
        (@crit_id, N'Chứng chỉ Financial Modeling & Valuation Analyst (FMVA) hoặc tương đương', 'CERTIFICATE', N'Chứng chỉ mô hình hóa tài chính và định giá doanh nghiệp.', 0, 2),
        (@crit_id, N'Độ chính xác và kịp thời của các bảng đối soát dữ liệu tài chính đạt trên 98%', 'CUSTOMER_SATISFACTION', N'Xác nhận của Giám Đốc Tài Chính về tính chuẩn xác của báo cáo định kỳ.', 1, 3);
    END
    -- Nấc 3 -> 4
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_968032 AND from_level_id = 3 AND to_level_id = 4)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_968032, 3, 4, 80.0, N'Xây dựng mô hình tài chính 3 báo cáo (3-Statement Financial Model), thẩm định hiệu quả dự án đầu tư (NPV, IRR, Payback).', 8.0, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Xây dựng mô hình tài chính thẩm định cho ít nhất 2 dự án đầu tư phát triển sản phẩm mới', 'PROJECT_EXPERIENCE', N'File mô hình tài chính Excel động với phân tích độ nhạy (Sensitivity Analysis).', 1, 1),
        (@crit_id, N'Sai lệch giữa dự báo dòng tiền hàng quý so với thực tế phát sinh không vượt quá 8%', 'CUSTOMER_SATISFACTION', N'Báo cáo kiểm chứng độ chuẩn xác của mô hình dự báo tài chính.', 1, 2),
        (@crit_id, N'Chứng chỉ Chartered Financial Analyst (CFA) Level 1 hoặc Level 2', 'CERTIFICATE', N'Chứng chỉ phân tích đầu tư tài chính quốc tế của Viện CFA.', 1, 3);
    END
    -- Nấc 4 -> 5
    IF NOT EXISTS (SELECT 1 FROM dbo.Position_Level_Criteria WHERE position_id = @pos_968032 AND from_level_id = 4 AND to_level_id = 5)
    BEGIN
        INSERT INTO dbo.Position_Level_Criteria (position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
        VALUES (@pos_968032, 4, 5, 85.0, N'Hoạch định cấu trúc vốn tối ưu, mô hình hóa kịch bản kinh doanh chiến lược (Scenario Modeling), tư vấn tài chính M&A.', 8.5, 1);
        SET @crit_id = SCOPE_IDENTITY();
        INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
        VALUES
        (@crit_id, N'Chủ trì xây dựng kế hoạch ngân sách và dự phóng tài chính 3 - 5 năm cho doanh nghiệp', 'PROJECT_EXPERIENCE', N'Bản kế hoạch tài chính trung và dài hạn trình bày trước Hội Đồng Quản Trị.', 1, 1),
        (@crit_id, N'Đóng góp mô hình tư vấn cấu trúc vốn giúp tối ưu hóa chi phí sử dụng vốn bình quân (WACC)', 'CUSTOMER_SATISFACTION', N'Nghị quyết phê duyệt phương án cấu trúc vốn của Ban Lãnh Đạo.', 1, 2),
        (@crit_id, N'Chứng chỉ CFA Charterholder hoặc Certified Management Accountant (CMA) đầy đủ', 'CERTIFICATE', N'Chứng chỉ chuyên gia phân tích tài chính cao cấp quốc tế.', 1, 3);
    END
END
GO

-- =======================================================
-- 13. SEED DATA: HỒ SƠ ĐỀ XUẤT THĂNG CẤP MẪU (PROMOTION_REQUESTS & EVIDENCE)
-- Mẫu 1 hồ sơ của nhân viên dev_fresher để kiểm thử giao diện duyệt thăng cấp
-- =======================================================
DECLARE @u_dev_fresher INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'dev_fresher');
DECLARE @p_java INT = (SELECT TOP 1 position_id FROM dbo.Positions WHERE position_name = N'Java Developer');
DECLARE @c_java_fresher_junior INT = (SELECT TOP 1 criteria_id FROM dbo.Position_Level_Criteria WHERE position_id = @p_java AND from_level_id = 2 AND to_level_id = 3);
DECLARE @u_manager_it INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'manager_it');
DECLARE @u_hr INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE username = 'hr_manager');

IF @u_dev_fresher IS NOT NULL AND @c_java_fresher_junior IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Promotion_Requests WHERE user_id = @u_dev_fresher)
BEGIN
    INSERT INTO dbo.Promotion_Requests
    (user_id, position_id, current_level_id, target_level_id, criteria_id, test_score, manager_id, manager_rating, manager_confidential_notes, manager_status, manager_action_date, hr_id, hr_decision, hr_notes, hr_action_date, status, created_at)
    VALUES
    (@u_dev_fresher, @p_java, 2, 3, @c_java_fresher_junior, 82.5, @u_manager_it, 8.0,
     N'Nhân viên nắm vững kiến thức backend Java, có tinh thần cầu tiến và hoàn thành tốt các module trong dự án.',
     'RECOMMENDED', DATEADD(DAY, -1, GETDATE()), @u_hr, 'PENDING', NULL, NULL, 'MANAGER_REVIEWED', DATEADD(DAY, -5, GETDATE()));

    DECLARE @prom_req_id INT = SCOPE_IDENTITY();
    DECLARE @req1 INT = (SELECT TOP 1 requirement_id FROM dbo.Criteria_Requirements WHERE criteria_id = @c_java_fresher_junior AND order_index = 1);
    DECLARE @req2 INT = (SELECT TOP 1 requirement_id FROM dbo.Criteria_Requirements WHERE criteria_id = @c_java_fresher_junior AND order_index = 2);
    DECLARE @req3 INT = (SELECT TOP 1 requirement_id FROM dbo.Criteria_Requirements WHERE criteria_id = @c_java_fresher_junior AND order_index = 3);

    IF @req1 IS NOT NULL
        INSERT INTO dbo.Promotion_Evidence (request_id, requirement_id, evidence_summary, evidence_url, is_verified, verification_comment, verified_at)
        VALUES (@prom_req_id, @req1, N'Đã tham gia dự án HRM Career Path, phụ trách xây dựng module Quản lý Lớp học và Học liệu đào tạo đạt tiến độ bàn giao.', 'https://github.com/company/hrm-career-path/pull/42', 1, N'Xác nhận nhân viên hoàn thành tốt công việc được giao.', GETDATE());
    IF @req2 IS NOT NULL
        INSERT INTO dbo.Promotion_Evidence (request_id, requirement_id, evidence_summary, evidence_url, is_verified, verification_comment, verified_at)
        VALUES (@prom_req_id, @req2, N'Chứng chỉ Java Spring Boot Developer từ Coursera.', 'https://coursera.org/verify/sample-certificate-java', 1, N'Chứng chỉ hợp lệ.', GETDATE());
    IF @req3 IS NOT NULL
        INSERT INTO dbo.Promotion_Evidence (request_id, requirement_id, evidence_summary, evidence_url, is_verified, verification_comment, verified_at)
        VALUES (@prom_req_id, @req3, N'Đánh giá hiệu suất từ Quản lý dự án Sprint vừa qua đạt 9/10.', 'https://jira.internal/browse/EVAL-2026', 1, N'Đồng ý với đánh giá năng lực.', GETDATE());
END
GO

-- =======================================================
-- 14. KIỂM TRA TỔNG QUAN DỮ LIỆU ĐÃ NẠP
-- =======================================================
SELECT 'Roles' AS TableName, COUNT(*) AS TotalRows FROM dbo.Roles;
SELECT 'Job_Levels' AS TableName, COUNT(*) AS TotalRows FROM dbo.Job_Levels;
SELECT 'Departments' AS TableName, COUNT(*) AS TotalRows FROM dbo.Departments;
SELECT 'Positions' AS TableName, COUNT(*) AS TotalRows FROM dbo.Positions;
SELECT 'Users' AS TableName, COUNT(*) AS TotalRows FROM dbo.Users;
SELECT 'Position_Level_Criteria' AS TableName, COUNT(*) AS TotalRows FROM dbo.Position_Level_Criteria;
SELECT 'Criteria_Requirements' AS TableName, COUNT(*) AS TotalRows FROM dbo.Criteria_Requirements;
SELECT 'Promotion_Requests' AS TableName, COUNT(*) AS TotalRows FROM dbo.Promotion_Requests;
SELECT 'Promotion_Evidence' AS TableName, COUNT(*) AS TotalRows FROM dbo.Promotion_Evidence;
GO