-- Chạy trên database hiện có. Xóa bộ đề học liệu và các bài làm, kết quả liên quan.
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
BEGIN TRANSACTION;

DECLARE @Content TABLE (id INT PRIMARY KEY);
DECLARE @Templates TABLE (id INT PRIMARY KEY);
DECLARE @Assignments TABLE (id INT PRIMARY KEY);
DECLARE @Questions TABLE (id INT PRIMARY KEY);

INSERT INTO @Content SELECT id FROM dbo.Test_Content WHERE type = 'learning';
INSERT INTO @Templates SELECT id FROM dbo.Test_Templates WHERE type = 'learning';
INSERT INTO @Assignments
SELECT id FROM dbo.Test_Assignments
WHERE test_template_id IN (SELECT id FROM @Templates)
   OR content_id IN (SELECT id FROM @Content);
INSERT INTO @Questions
SELECT id FROM dbo.Test_Questions WHERE content_id IN (SELECT id FROM @Content);

DELETE FROM dbo.Test_Answer_Options
WHERE assignment_id IN (SELECT id FROM @Assignments)
   OR question_id IN (SELECT id FROM @Questions);

IF OBJECT_ID('dbo.Test_Answers', 'U') IS NOT NULL
BEGIN
    DELETE FROM dbo.Test_Answers
    WHERE assignment_id IN (SELECT id FROM @Assignments)
       OR question_id IN (SELECT id FROM @Questions);
END;

DELETE FROM dbo.Test_Evaluations WHERE test_assignment_id IN (SELECT id FROM @Assignments);
DELETE FROM dbo.Test_Assignments WHERE id IN (SELECT id FROM @Assignments);
DELETE FROM dbo.Test_Templates WHERE id IN (SELECT id FROM @Templates);
UPDATE dbo.Test_Templates SET default_content_id = NULL
WHERE default_content_id IN (SELECT id FROM @Content);
DELETE FROM dbo.Test_Questions WHERE id IN (SELECT id FROM @Questions);
DELETE FROM dbo.Test_Content WHERE id IN (SELECT id FROM @Content);

DROP INDEX IF EXISTS UX_Test_Content_Learning_Material ON dbo.Test_Content;
ALTER TABLE dbo.Test_Content DROP CONSTRAINT IF EXISTS FK_Test_Content_Learning_Material;
ALTER TABLE dbo.Test_Content DROP COLUMN IF EXISTS learning_material_id;
ALTER TABLE dbo.Test_Templates DROP CONSTRAINT IF EXISTS FK_Test_Template_Class;
ALTER TABLE dbo.Test_Templates DROP CONSTRAINT IF EXISTS CK_Test_Class_Type;
ALTER TABLE dbo.Test_Templates DROP COLUMN IF EXISTS class_id;

ALTER TABLE dbo.Test_Content DROP CONSTRAINT IF EXISTS CK_Content_Scope;
ALTER TABLE dbo.Test_Content WITH CHECK ADD CONSTRAINT CK_Content_Scope CHECK (type IN ('culture', 'department'));
ALTER TABLE dbo.Test_Templates DROP CONSTRAINT IF EXISTS CK_Test_Type;
ALTER TABLE dbo.Test_Templates WITH CHECK ADD CONSTRAINT CK_Test_Type CHECK (type IN ('culture', 'department'));

COMMIT;
