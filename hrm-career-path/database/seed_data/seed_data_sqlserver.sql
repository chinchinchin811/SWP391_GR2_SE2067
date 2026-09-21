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
(N'Quy trình Onboarding', N'Kien thuc nhap môn công ty'),
(N'Java Core', N'Kien thuc chuyen mon Java');

SELECT *
FROM dbo.FlashcardDecks
WHERE title IN (N'Quy trình Onboarding', N'Java Core', N'Kien thuc nhap môn công ty' );


UPDATE dbo.FlashcardDecks
SET title = N'Van hoa cong ty'
WHERE deck_id = 1;

UPDATE dbo.FlashcardDecks
SET title = N'Chuyen mon'
WHERE deck_id = 2;


INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES 
(1, N'Gio lam viec bat dau luc may gio', N'8:30 Sang'),
(2, N'OOP có may tinh chat co ban?', N'4 tinh chat: Dong goi, Ke thua, Da hinh, Truu tuong');
GO

INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
(1, N'Gio lam viec ket thuc luc may gio?', 
    N'17:30 hang ngay.'),

(1, N'Thanh vien moi can lam gi trong ngay dau tien?', 
    N'Hoan tat thu tuc onboarding, lam quen voi team, tai khoan he thong va noi quy cong ty.'),

(1, N'Nhan vien can bao truoc bao nhieu ngay khi xin nghi phep?', 
    N'Thuc hien theo quy dinh nghi phep cua cong ty va thong bao cho quan ly truoc thoi gian nghi.'),

(1, N'Khi gap van de trong cong viec, nhan vien nen lam gi?', 
    N'Chu dong trao doi voi Leader, Manager hoac nguoi huong dan de duoc ho tro.'),

(1, N'Onboarding la gi?', 
    N'La qua trinh giup nhan vien moi lam quen voi cong ty, cong viec, van hoa va quy trinh lam viec.'),

(1, N'Muc dich cua viec onboarding nhan vien moi la gi?', 
    N'Giup nhan vien nhanh chong hoa nhap, hieu cong viec va co the lam viec hieu qua.'),

(1, N'Nhan vien co can bao mat thong tin cong ty khong?', 
    N'Co. Nhan vien phai bao mat thong tin noi bo, thong tin khach hang va du lieu cua cong ty.'),

(1, N'Khi den muon, nhan vien nen lam gi?', 
    N'Thong bao cho quan ly hoac nguoi phu trach va tuan thu quy dinh cham cong cua cong ty.'),

(1, N'Tai sao can tham gia cac buoi training cua cong ty?', 
    N'De cap nhat kien thuc, quy trinh, ky nang va cac quy dinh can thiet cho cong viec.'),

(1, N'Nhan vien moi co the hoi ai khi khong hieu cong viec?', 
    N'Co the hoi Mentor, Team Leader, Manager hoac dong nghiep phu hop.');

GO


INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
(2, N'Java la gi?', 
    N'Java la mot ngon ngu lap trinh huong doi tuong, duoc su dung pho bien de phat trien ung dung web, desktop va backend.'),

(2, N'OOP co may tinh chat co ban?', 
    N'4 tinh chat: Dong goi, Ke thua, Da hinh va Truu tuong.'),

(2, N'Class trong Java la gi?', 
    N'Class la mot khuon mau dung de dinh nghia thuoc tinh va hanh vi cua object.'),

(2, N'Object trong Java la gi?', 
    N'Object la mot the hien cu the duoc tao ra tu mot class.'),

(2, N'Tinh dong goi trong OOP la gi?', 
    N'La viec dong goi du lieu va cac phuong thuc lien quan trong mot class va kiem soat quyen truy cap.'),

(2, N'Tinh ke thua trong OOP la gi?', 
    N'La co che cho phep mot class con ke thua thuoc tinh va phuong thuc tu class cha.'),

(2, N'Tinh da hinh trong OOP la gi?', 
    N'La kha nang cung mot phuong thuc co the co cach thuc hien khac nhau tuy theo object.'),

(2, N'Tinh truu tuong trong OOP la gi?', 
    N'La viec an di cac chi tiet cai dat va chi hien thi nhung thong tin can thiet cho nguoi su dung.'),

(2, N'Constructor trong Java dung de lam gi?', 
    N'Dung de khoi tao object khi object duoc tao ra.'),

(2, N'Interface trong Java la gi?', 
    N'Interface la mot tap hop cac phuong thuc ma class implement can cung cap phan cai dat.'),

(2, N'Exception trong Java la gi?', 
    N'Exception la loi xay ra trong qua trinh chuong trinh dang thuc thi.'),

(2, N'Try-catch trong Java dung de lam gi?', 
    N'Dung de xu ly exception va tranh lam chuong trinh ket thuc dot ngot.'),

(2, N'ArrayList trong Java la gi?', 
    N'ArrayList la mot collection co the luu tru nhieu phan tu va co kich thuoc co the thay doi.'),

(2, N'Git dung de lam gi?', 
    N'Git la he thong quan ly phien ban giup theo doi, luu tru va quan ly cac thay doi cua source code.'),

(2, N'API la gi?', 
    N'API la giao dien cho phep cac ung dung hoac he thong giao tiep va trao doi du lieu voi nhau.');

GO

use HRM_Project_DB
-- =======================================================
-- KIEM TRA DU LIEU: SELECT * FROM TAT CA BANG
-- =======================================================
SELECT * FROM dbo.Roles;
SELECT * FROM dbo.Job_Levels;
SELECT * FROM dbo.Departments;
SELECT * FROM dbo.Positions;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Employee_History;
select * from Flashcards
select * from FlashcardDecks
GO
