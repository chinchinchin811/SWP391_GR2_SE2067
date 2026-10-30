USE HRM_Project_DB;
GO

-- Xóa dữ liệu mẫu cũ nếu có
DELETE FROM dbo.Criteria_Requirements;
DELETE FROM dbo.Position_Level_Criteria;
GO

-- 1. BAREM CHO JAVA DEVELOPER (position_id = 1)
-- Nấc 1: Fresher (level_id = 2) -> Junior (level_id = 3)
INSERT INTO dbo.Position_Level_Criteria 
(position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
VALUES 
(1, 2, 3, 75.0, N'Nắm vững Java Core, OOP, Spring Boot căn bản, RESTful API và làm việc với CSDL quan hệ.', 7.5, 1);

DECLARE @c1 INT = SCOPE_IDENTITY();
INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
VALUES 
(@c1, N'Tham gia tối thiểu 1 dự án thực tế đạt tiến độ bàn giao', 'PROJECT_EXPERIENCE', N'Nộp link tài liệu nghiệm thu hoặc báo cáo đóng góp các module tính năng trong dự án.', 1, 1),
(@c1, N'Có chứng chỉ đào tạo Java Backend hoặc chứng chỉ tương đương', 'CERTIFICATE', N'Upload ảnh/file PDF chứng chỉ chuyên môn liên quan.', 0, 2),
(@c1, N'Đánh giá hiệu suất từ PM/Tech Lead đạt mức Tốt trở lên', 'CUSTOMER_SATISFACTION', N'Nộp ảnh chụp email đánh giá hoặc biên bản đánh giá định kỳ của PM.', 1, 3);

-- Nấc 2: Junior (level_id = 3) -> Middle (level_id = 4)
INSERT INTO dbo.Position_Level_Criteria 
(position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
VALUES 
(1, 3, 4, 80.0, N'Làm chủ kiến trúc Microservices, Clean Architecture, Docker, CI/CD và tối ưu hóa truy vấn CSDL.', 8.0, 1);

DECLARE @c2 INT = SCOPE_IDENTITY();
INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
VALUES 
(@c2, N'Tham gia tối thiểu 2 dự án thực tế với vai trò Core Developer', 'PROJECT_EXPERIENCE', N'Nộp bản tóm tắt danh sách các dự án tham gia, kiến trúc sử dụng và kết quả bàn giao.', 1, 1),
(@c2, N'Đạt tỷ lệ khách hàng/PM hài lòng (CSAT) >= 85%', 'CUSTOMER_SATISFACTION', N'Minh chứng khảo sát CSAT hoặc xác nhận từ Trưởng dự án.', 1, 2),
(@c2, N'Có chứng chỉ quốc tế Oracle Certified Professional (OCP) Java hoặc AWS Developer', 'CERTIFICATE', N'Upload chứng chỉ quốc tế kèm mã tra cứu xác thực.', 0, 3),
(@c2, N'Thực hiện tối thiểu 1 buổi chia sẻ kỹ thuật (Tech Talk) cho nội bộ', 'OTHER', N'Đính kèm slide thuyết trình hoặc link video ghi lại buổi chia sẻ.', 0, 4);

-- Nấc 3: Middle (level_id = 4) -> Senior (level_id = 5)
INSERT INTO dbo.Position_Level_Criteria 
(position_id, from_level_id, to_level_id, min_test_score, competency_summary, min_manager_rating, status)
VALUES 
(1, 4, 5, 85.0, N'Thiết kế giải pháp High Availability, chịu tải cao, giải quyết bài toán phân tán và định hướng kỹ thuật cho team.', 8.5, 1);

DECLARE @c3 INT = SCOPE_IDENTITY();
INSERT INTO dbo.Criteria_Requirements (criteria_id, requirement_title, requirement_type, description, is_mandatory, order_index)
VALUES 
(@c3, N'Đóng vai trò Technical Lead / Module Lead cho ít nhất 2 hệ thống lớn', 'PROJECT_EXPERIENCE', N'Tài liệu đặc tả kiến trúc giải pháp (Architecture Blueprint) do ứng viên thiết kế.', 1, 1),
(@c3, N'Đạt đánh giá CSAT trung bình >= 90%, không có vi phạm SLA', 'CUSTOMER_SATISFACTION', N'Báo cáo tổng kết chất lượng dịch vụ của các dự án phụ trách.', 1, 2),
(@c3, N'Sở hữu chứng chỉ AWS Solutions Architect hoặc TOGAF hoặc tương đương', 'CERTIFICATE', N'Chứng chỉ kiến trúc chuyên sâu còn hạn sử dụng.', 1, 3);

PRINT 'Đã nạp thành công bộ dữ liệu mẫu Tiêu chí Barem thăng cấp cho Java Developer!';
GO
