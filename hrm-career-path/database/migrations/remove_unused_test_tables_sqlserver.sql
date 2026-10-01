USE HRM_Project_DB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Không còn route hoặc giao diện thông báo trong module bài test.
IF OBJECT_ID(N'dbo.Test_Notifications', N'U') IS NOT NULL
    DROP TABLE dbo.Test_Notifications;

IF OBJECT_ID(N'dbo.Test_Reminder_Outbox', N'U') IS NOT NULL
    DROP TABLE dbo.Test_Reminder_Outbox;

-- Audit cũ chỉ được ghi nhưng chưa từng được đọc trong ứng dụng.
IF OBJECT_ID(N'dbo.Test_Audit', N'U') IS NOT NULL
    DROP TABLE dbo.Test_Audit;

-- Bảng đáp án A/B/C/D cũ đã được thay bằng Test_Answer_Options.
IF OBJECT_ID(N'dbo.Test_Answers', N'U') IS NOT NULL
    DROP TABLE dbo.Test_Answers;

COMMIT TRANSACTION;
GO
