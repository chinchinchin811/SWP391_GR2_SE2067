-- =======================================================
-- SQL Server migration: Flashcards
-- Chay file nay khi HRM_Project_DB da ton tai.
-- File co the chay lai nhieu lan ma khong tao trung bang/du lieu mau.
-- =======================================================

USE HRM_Project_DB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.FlashcardDecks', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.FlashcardDecks (
            deck_id INT IDENTITY(1,1) PRIMARY KEY,
            title NVARCHAR(150) NOT NULL,
            description NVARCHAR(MAX) NULL,
            created_at DATETIME NOT NULL CONSTRAINT DF_FlashcardDecks_CreatedAt DEFAULT GETDATE()
        );
    END;

    IF OBJECT_ID('dbo.Flashcards', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Flashcards (
            card_id INT IDENTITY(1,1) PRIMARY KEY,
            deck_id INT NOT NULL,
            question NVARCHAR(MAX) NOT NULL,
            answer NVARCHAR(MAX) NOT NULL,
            CONSTRAINT FK_Flashcards_Deck
                FOREIGN KEY (deck_id) REFERENCES dbo.FlashcardDecks(deck_id) ON DELETE CASCADE
        );
    END;

    DECLARE @CultureDeckId INT;
    DECLARE @TechnicalDeckId INT;

    SELECT TOP (1) @CultureDeckId = deck_id
    FROM dbo.FlashcardDecks
    WHERE title = N'Văn hóa công ty'
    ORDER BY deck_id;

    IF @CultureDeckId IS NULL
    BEGIN
        INSERT INTO dbo.FlashcardDecks (title, description)
        VALUES (N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa công ty');
        SET @CultureDeckId = CONVERT(INT, SCOPE_IDENTITY());
    END;

    SELECT TOP (1) @TechnicalDeckId = deck_id
    FROM dbo.FlashcardDecks
    WHERE title = N'Chuyên môn'
    ORDER BY deck_id;

    IF @TechnicalDeckId IS NULL
    BEGIN
        INSERT INTO dbo.FlashcardDecks (title, description)
        VALUES (N'Chuyên môn', N'Kiến thức chuyên môn Java');
        SET @TechnicalDeckId = CONVERT(INT, SCOPE_IDENTITY());
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Flashcards WHERE deck_id = @CultureDeckId)
    BEGIN
        INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
        (@CultureDeckId, N'Giờ làm việc kết thúc lúc mấy giờ?', N'17:30 hàng ngày.'),
        (@CultureDeckId, N'Thành viên mới cần làm gì trong ngày đầu tiên?', N'Hoàn tất thủ tục onboarding, làm quen với team, tài khoản hệ thống và nội quy công ty.'),
        (@CultureDeckId, N'Nhân viên cần báo trước bao nhiêu ngày khi xin nghỉ phép?', N'Thực hiện theo quy định nghỉ phép của công ty và thông báo cho quản lý trước thời gian nghỉ.'),
        (@CultureDeckId, N'Khi gặp vấn đề trong công việc, nhân viên nên làm gì?', N'Chủ động trao đổi với Leader, Manager hoặc người hướng dẫn để được hỗ trợ.'),
        (@CultureDeckId, N'Onboarding là gì?', N'Là quá trình giúp nhân viên mới làm quen với công ty, công việc, văn hóa và quy trình làm việc.'),
        (@CultureDeckId, N'Mục đích của việc onboarding nhân viên mới là gì?', N'Giúp nhân viên nhanh chóng hòa nhập, hiểu công việc và có thể làm việc hiệu quả.'),
        (@CultureDeckId, N'Nhân viên có cần bảo mật thông tin công ty không?', N'Có. Nhân viên phải bảo mật thông tin nội bộ, thông tin khách hàng và dữ liệu của công ty.'),
        (@CultureDeckId, N'Khi đến muộn, nhân viên nên làm gì?', N'Thông báo cho quản lý hoặc người phụ trách và tuân thủ quy định chấm công của công ty.'),
        (@CultureDeckId, N'Tại sao cần tham gia các buổi training của công ty?', N'Để cập nhật kiến thức, quy trình, kỹ năng và các quy định cần thiết cho công việc.'),
        (@CultureDeckId, N'Nhân viên mới có thể hỏi ai khi không hiểu công việc?', N'Có thể hỏi Mentor, Team Leader, Manager hoặc đồng nghiệp phù hợp.');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Flashcards WHERE deck_id = @TechnicalDeckId)
    BEGIN
        INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES
        (@TechnicalDeckId, N'Java là gì?', N'Java là một ngôn ngữ lập trình hướng đối tượng, được dùng phổ biến cho ứng dụng web, desktop và backend.'),
        (@TechnicalDeckId, N'OOP có mấy tính chất cơ bản?', N'4 tính chất: Đóng gói, Kế thừa, Đa hình và Trừu tượng.'),
        (@TechnicalDeckId, N'Class trong Java là gì?', N'Class là một khuôn mẫu dùng để định nghĩa thuộc tính và hành vi của object.'),
        (@TechnicalDeckId, N'Object trong Java là gì?', N'Object là một thể hiện cụ thể được tạo ra từ một class.'),
        (@TechnicalDeckId, N'Tính đóng gói trong OOP là gì?', N'Là việc đóng gói dữ liệu và các phương thức liên quan trong một class và kiểm soát quyền truy cập.'),
        (@TechnicalDeckId, N'Tính kế thừa trong OOP là gì?', N'Là cơ chế cho phép một class con kế thừa thuộc tính và phương thức từ class cha.'),
        (@TechnicalDeckId, N'Tính đa hình trong OOP là gì?', N'Là khả năng cùng một phương thức có thể có cách thực hiện khác nhau tùy theo object.'),
        (@TechnicalDeckId, N'Tính trừu tượng trong OOP là gì?', N'Là việc ẩn đi các chi tiết cài đặt và chỉ hiển thị những thông tin cần thiết cho người sử dụng.'),
        (@TechnicalDeckId, N'Constructor trong Java dùng để làm gì?', N'Dùng để khởi tạo object khi object được tạo ra.'),
        (@TechnicalDeckId, N'Interface trong Java là gì?', N'Interface là một tập hợp các phương thức mà class implement cần cung cấp phần cài đặt.'),
        (@TechnicalDeckId, N'Exception trong Java là gì?', N'Exception là lỗi xảy ra trong quá trình chương trình đang thực thi.'),
        (@TechnicalDeckId, N'Try-catch trong Java dùng để làm gì?', N'Dùng để xử lý exception và tránh làm chương trình kết thúc đột ngột.'),
        (@TechnicalDeckId, N'ArrayList trong Java là gì?', N'ArrayList là một collection có thể lưu trữ nhiều phần tử và có kích thước có thể thay đổi.'),
        (@TechnicalDeckId, N'Git dùng để làm gì?', N'Git là hệ thống quản lý phiên bản giúp theo dõi, lưu trữ và quản lý các thay đổi của source code.'),
        (@TechnicalDeckId, N'API là gì?', N'API là giao diện cho phép các ứng dụng hoặc hệ thống giao tiếp và trao đổi dữ liệu với nhau.');
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT d.deck_id, d.title, COUNT(c.card_id) AS card_count
FROM dbo.FlashcardDecks AS d
LEFT JOIN dbo.Flashcards AS c ON c.deck_id = d.deck_id
GROUP BY d.deck_id, d.title
ORDER BY d.deck_id;
GO
