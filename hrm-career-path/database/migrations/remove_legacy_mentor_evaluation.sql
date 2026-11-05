USE HRM_Project_DB;
GO

-- Remove only the legacy, non-class evaluation authored by Lê Hữu Mentor
-- for Phạm Đức Trọng. Newer class-based evaluations are not affected.
DECLARE @legacy_evaluation_id INT;

SELECT TOP 1 @legacy_evaluation_id = e.evaluation_id
FROM dbo.MentorEvaluations e
JOIN dbo.MentorAssignments a ON a.assignment_id = e.assignment_id
JOIN dbo.Users evaluator ON evaluator.user_id = e.evaluator_id
JOIN dbo.Users mentee ON mentee.user_id = a.mentee_id
WHERE evaluator.full_name = N'Lê Hữu Mentor'
  AND mentee.full_name = N'Phạm Đức Trọng'
  AND a.class_id IS NULL
  AND a.mentor_id = evaluator.user_id
ORDER BY e.evaluation_id DESC;

IF @legacy_evaluation_id IS NOT NULL
BEGIN
    DELETE FROM dbo.MentorEvaluations
    WHERE evaluation_id = @legacy_evaluation_id;
    PRINT N'Đã xóa đánh giá cũ của Lê Hữu Mentor.';
END
ELSE
BEGIN
    PRINT N'Không tìm thấy đánh giá cũ cần xóa.';
END;
GO
