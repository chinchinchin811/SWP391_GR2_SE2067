SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Flashcards](
	[card_id] [int] IDENTITY(1,1) NOT NULL,
	[deck_id] [int] NOT NULL,
	[question] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[answer] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[card_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlashcardDecks](
	[deck_id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[deck_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[position_id] [int] NULL,
	[created_at] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[deck_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Positions](
	[position_id] [int] IDENTITY(1,1) NOT NULL,
	[position_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[department_id] [int] NULL,
	[description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [bit] NULL,
	[is_deleted] [bit] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[position_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MentorEvaluations](
	[evaluation_id] [int] IDENTITY(1,1) NOT NULL,
	[assignment_id] [int] NOT NULL,
	[evaluator_id] [int] NOT NULL,
	[performance_score] [int] NULL,
	[feedback] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[public_feedback] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[private_feedback] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[approval_status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[evaluation_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[evaluation_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Video_Checkpoints](
	[checkpoint_id] [int] IDENTITY(1,1) NOT NULL,
	[material_id] [int] NOT NULL,
	[stop_time_seconds] [int] NOT NULL,
	[question_prompt] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[option_a] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[option_b] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[option_c] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[option_d] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[correct_option] [int] NOT NULL,
	[explanation] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[checkpoint_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Video_Question_Answers](
	[answer_id] [int] IDENTITY(1,1) NOT NULL,
	[checkpoint_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[selected_option] [int] NOT NULL,
	[is_correct] [bit] NOT NULL,
	[attempt_count] [int] NOT NULL,
	[answered_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[answer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Position_Requests](
	[request_id] [int] IDENTITY(1,1) NOT NULL,
	[manager_id] [int] NOT NULL,
	[department_id] [int] NOT NULL,
	[position_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reason] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[decision_note] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reviewed_by] [int] NULL,
	[created_at] [datetime] NULL,
	[reviewed_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MentorAssignments](
	[assignment_id] [int] IDENTITY(1,1) NOT NULL,
	[mentee_id] [int] NOT NULL,
	[mentor_id] [int] NOT NULL,
	[position_id] [int] NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[assigned_by] [int] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[assignment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee_History](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[old_department_id] [int] NULL,
	[new_department_id] [int] NULL,
	[old_position_id] [int] NULL,
	[new_position_id] [int] NULL,
	[old_level_id] [int] NULL,
	[new_level_id] [int] NULL,
	[change_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[change_date] [datetime] NULL,
	[notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[department_id] [int] IDENTITY(1,1) NOT NULL,
	[department_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[manager_id] [int] NULL,
	[description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [bit] NULL,
	[is_deleted] [bit] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[department_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transfer_Requests](
	[request_id] [int] IDENTITY(1,1) NOT NULL,
	[employee_id] [int] NOT NULL,
	[current_department_id] [int] NOT NULL,
	[current_position_id] [int] NULL,
	[target_department_id] [int] NOT NULL,
	[target_position_id] [int] NULL,
	[reason] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[manager_status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[manager_note] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[manager_reviewed_by] [int] NULL,
	[manager_reviewed_at] [datetime] NULL,
	[hr_status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[hr_note] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hr_reviewed_by] [int] NULL,
	[hr_reviewed_at] [datetime] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Learning_Progress](
	[progress_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[material_id] [int] NOT NULL,
	[class_id] [int] NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[last_accessed_at] [datetime] NULL,
	[completed_at] [datetime] NULL,
	[notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[progress_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Class_Materials](
	[class_id] [int] NOT NULL,
	[material_id] [int] NOT NULL,
	[order_index] [int] NOT NULL,
	[is_mandatory] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[class_id] ASC,
	[material_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Class_Enrollments](
	[enrollment_id] [int] IDENTITY(1,1) NOT NULL,
	[class_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[enrolled_by] [int] NOT NULL,
	[enrollment_type] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[assigned_reason] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[progress_percent] [int] NOT NULL,
	[enrolled_at] [datetime] NULL,
	[completed_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[enrollment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Question_Options](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[question_id] [int] NOT NULL,
	[option_text] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_correct] [bit] NOT NULL,
	[display_order] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Templates](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[department_id] [int] NULL,
	[created_by] [int] NOT NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[start_time] [datetime2](7) NOT NULL,
	[end_time] [datetime2](7) NOT NULL,
	[default_content_id] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[class_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Questions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[content_id] [int] NOT NULL,
	[prompt] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[question_type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Content](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[prompt] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[kind] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[department_id] [int] NULL,
	[created_by] [int] NOT NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[learning_material_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Evaluations](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[test_assignment_id] [int] NOT NULL,
	[evaluator_id] [int] NOT NULL,
	[score] [decimal](4, 2) NOT NULL,
	[comment] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[evaluated_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Assignments](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[test_template_id] [int] NOT NULL,
	[assignee_id] [int] NOT NULL,
	[assigned_by] [int] NOT NULL,
	[content_id] [int] NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[quiz_score] [decimal](4, 2) NULL,
	[assigned_at] [datetime2](7) NOT NULL,
	[duration_minutes] [int] NOT NULL,
	[started_at] [datetime2](7) NULL,
	[submitted_at] [datetime2](7) NULL,
	[submission_content] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_data] [varbinary](max) NULL,
	[is_deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Answer_Options](
	[assignment_id] [int] NOT NULL,
	[question_id] [int] NOT NULL,
	[option_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[assignment_id] ASC,
	[question_id] ASC,
	[option_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[role_id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[password] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[full_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[email] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[phone] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gender] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dob] [date] NULL,
	[role_id] [int] NOT NULL,
	[department_id] [int] NULL,
	[position_id] [int] NULL,
	[level_id] [int] NULL,
	[hire_date] [date] NOT NULL,
	[status] [bit] NULL,
	[is_deleted] [bit] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Training_Classes](
	[class_id] [int] IDENTITY(1,1) NOT NULL,
	[class_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[class_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[department_id] [int] NULL,
	[target_position_id] [int] NULL,
	[target_level_id] [int] NULL,
	[mentor_id] [int] NULL,
	[start_date] [date] NOT NULL,
	[end_date] [date] NULL,
	[status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_deleted] [bit] NULL,
	[created_by] [int] NOT NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Learning_Materials](
	[material_id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[material_type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[scope_type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[department_id] [int] NULL,
	[position_id] [int] NULL,
	[level_id] [int] NULL,
	[material_url] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[video_url] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[duration_minutes] [int] NULL,
	[file_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_data] [varbinary](max) NULL,
	[file_size] [bigint] NULL,
	[status] [bit] NULL,
	[is_deleted] [bit] NULL,
	[created_by] [int] NOT NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[material_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Job_Levels](
	[level_id] [int] IDENTITY(1,1) NOT NULL,
	[level_name] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rank_order] [int] NOT NULL,
	[description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[level_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Flashcards] ON 

INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (1, 1, N'Giờ làm việc kết thúc lúc mấy giờ?', N'17:30 hàng ngày.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (2, 1, N'Thành viên mới cần làm gì trong ngày đầu tiên?', N'Hoàn tất thủ tục onboarding, làm quen với team, tài khoản hệ thống và nội quy công ty.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (3, 1, N'Nhân viên cần báo trước bao nhiêu ngày khi xin nghỉ phép?', N'Thực hiện theo quy định nghỉ phép của công ty và thông báo cho quản lý trước thời gian nghỉ.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (4, 1, N'Khi gặp vấn đề trong công việc, nhân viên nên làm gì?', N'Chủ động trao đổi với Leader, Manager hoặc người hướng dẫn để được hỗ trợ.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (5, 1, N'Onboarding là gì?', N'Là quá trình giúp nhân viên mới làm quen với công ty, công việc, văn hóa và quy trình làm việc.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (6, 1, N'Mục đích của việc onboarding nhân viên mới là gì?', N'Giúp nhân viên nhanh chóng hòa nhập, hiểu công việc và có thể làm việc hiệu quả.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (7, 1, N'Nhân viên có cần bảo mật thông tin công ty không?', N'Có. Nhân viên phải bảo mật thông tin nội bộ, thông tin khách hàng và dữ liệu của công ty.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (8, 1, N'Khi đến muộn, nhân viên nên làm gì?', N'Thông báo cho quản lý hoặc người phụ trách và tuân thủ quy định chấm công của công ty.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (9, 1, N'Tại sao cần tham gia các buổi training của công ty?', N'Để cập nhật kiến thức, quy trình, kỹ năng và các quy định cần thiết cho công việc.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (10, 1, N'Nhân viên mới có thể hỏi ai khi không hiểu công việc?', N'Có thể hỏi Mentor, Team Leader, Manager hoặc đồng nghiệp phù hợp.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (11, 2, N'Java là gì?', N'Java là một ngôn ngữ lập trình hướng đối tượng, được sử dụng phổ biến để phát triển ứng dụng web, desktop và backend.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (12, 2, N'OOP có mấy tính chất cơ bản?', N'4 tính chất: Đóng gói, Kế thừa, Đa hình và Trừu tượng.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (13, 2, N'Class trong Java là gì?', N'Class là một khuôn mẫu dùng để định nghĩa thuộc tính và hành vi của object.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (14, 2, N'Object trong Java là gì?', N'Object là một thể hiện cụ thể được tạo ra từ một class.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (15, 2, N'Tính đóng gói trong OOP là gì?', N'Là việc đóng gói dữ liệu và các phương thức liên quan trong một class và kiểm soát quyền truy cập.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (16, 2, N'Tính kế thừa trong OOP là gì?', N'Là cơ chế cho phép một class con kế thừa thuộc tính và phương thức từ class cha.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (17, 2, N'Tính đa hình trong OOP là gì?', N'Là khả năng cùng một phương thức có thể có cách thực hiện khác nhau tùy theo object.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (18, 2, N'Tính trừu tượng trong OOP là gì?', N'Là việc ẩn đi các chi tiết cài đặt và chỉ hiển thị những thông tin cần thiết cho người sử dụng.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (19, 2, N'Constructor trong Java dùng để làm gì?', N'Dùng để khởi tạo object khi object được tạo ra.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (20, 2, N'Interface trong Java là gì?', N'Interface là một tập hợp các phương thức mà class implement cần cung cấp phần cài đặt.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (21, 2, N'Exception trong Java là gì?', N'Exception là lỗi xảy ra trong quá trình chương trình đang thực thi.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (22, 2, N'Try-catch trong Java dùng để làm gì?', N'Dùng để xử lý exception và tránh làm chương trình kết thúc đột ngột.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (23, 2, N'ArrayList trong Java là gì?', N'ArrayList là một collection có thể lưu trữ nhiều phần tử và có kích thước có thể thay đổi.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (24, 2, N'Git dùng để làm gì?', N'Git là hệ thống quản lý phiên bản giúp theo dõi, lưu trữ và quản lý các thay đổi của source code.')
INSERT [dbo].[Flashcards] ([card_id], [deck_id], [question], [answer]) VALUES (25, 2, N'API là gì?', N'API là giao diện cho phép các ứng dụng hoặc hệ thống giao tiếp và trao đổi dữ liệu với nhau.')
SET IDENTITY_INSERT [dbo].[Flashcards] OFF
GO
SET IDENTITY_INSERT [dbo].[FlashcardDecks] ON 

INSERT [dbo].[FlashcardDecks] ([deck_id], [title], [description], [deck_type], [position_id], [created_at]) VALUES (1, N'Văn hóa công ty', N'Kiến thức nhập môn và văn hóa công ty', N'professional', NULL, CAST(N'2026-11-01T22:20:31.590' AS DateTime))
INSERT [dbo].[FlashcardDecks] ([deck_id], [title], [description], [deck_type], [position_id], [created_at]) VALUES (2, N'Chuyên môn Java Backend', N'Kiến thức chuyên môn lập trình Java', N'professional', NULL, CAST(N'2026-11-01T22:20:31.590' AS DateTime))
SET IDENTITY_INSERT [dbo].[FlashcardDecks] OFF
GO
SET IDENTITY_INSERT [dbo].[Positions] ON 

INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (1, N'Java Developer', 1, N'Lập trình viên backend Java/Spring/Jakarta EE', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (2, N'Frontend Developer', 1, N'Lập trình viên giao diện web React/Vue/HTML/CSS', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (3, N'QA / Software Tester', 1, N'Kiểm thử tự động & kiểm thử thủ công phần mềm', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (4, N'HR Officer', 2, N'Chuyên viên nhân sự tổng hợp', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (5, N'Sales Executive', 3, N'Chuyên viên kinh doanh giải pháp doanh nghiệp B2B', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (6, N'DevOps Engineer', 1, N'Kỹ sư hạ tầng, Cloud và quy trình CI/CD', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (7, N'Business Analyst (BA)', 1, N'Chuyên viên phân tích nghiệp vụ và quy trình phần mềm', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (8, N'Mobile App Developer', 1, N'Lập trình viên ứng dụng di động Flutter/iOS/Android', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (9, N'Talent Acquisition Specialist', 2, N'Chuyên viên tuyển dụng nhân tài', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (10, N'C&B Specialist', 2, N'Chuyên viên tiền lương, bảo hiểm và chính sách đãi ngộ', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (11, N'Training & Development Executive', 2, N'Chuyên viên đào tạo và phát triển năng lực nhân viên', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (12, N'Key Account Manager (KAM)', 3, N'Quản lý và chăm sóc khách hàng doanh nghiệp trọng điểm', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (13, N'Business Development Rep (BDR)', 3, N'Chuyên viên tìm kiếm và mở rộng mạng lưới khách hàng mới', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (14, N'Digital Marketing Specialist', 4, N'Chuyên viên tiếp thị số, SEO và quảng cáo trực tuyến', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (15, N'Content Creator & Copywriter', 4, N'Chuyên viên sáng tạo nội dung, bài viết truyền thông', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (16, N'UI/UX Product Designer', 4, N'Thiết kế trải nghiệm người dùng và giao diện sản phẩm số', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (17, N'Kế Toán Tổng Hợp (General Accountant)', 5, N'Hạch toán chi phí, doanh thu và lập báo cáo tài chính', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (18, N'Chuyên Viên Kiểm Toán Nội Bộ', 5, N'Kiểm soát rủi ro tài chính và tuân thủ quy chế chi tiêu', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
INSERT [dbo].[Positions] ([position_id], [position_name], [department_id], [description], [status], [is_deleted], [created_at]) VALUES (19, N'Financial Planning & Analysis (FP&A)', 5, N'Chuyên viên phân tích và dự báo kế hoạch tài chính', 1, 0, CAST(N'2026-11-01T22:20:31.407' AS DateTime))
SET IDENTITY_INSERT [dbo].[Positions] OFF
GO
SET IDENTITY_INSERT [dbo].[Video_Checkpoints] ON 

INSERT [dbo].[Video_Checkpoints] ([checkpoint_id], [material_id], [stop_time_seconds], [question_prompt], [option_a], [option_b], [option_c], [option_d], [correct_option], [explanation], [created_at]) VALUES (1, 3, 45, N'Theo mô hình kiến trúc MVC trong Jakarta EE, tầng nào trực tiếp nhận và điều phối HTTP Request từ phía người dùng?', N'Model (Java Bean / Entity)', N'Controller (Servlet)', N'View (JSP / JSTL)', N'DAL (Data Access Object)', 1, N'Chính xác! Servlet đóng vai trò Controller, trực tiếp đón nhận HTTP Request, xử lý điều phối và chuyển tiếp dữ liệu đến View.', CAST(N'2026-11-01T22:20:32.727' AS DateTime))
INSERT [dbo].[Video_Checkpoints] ([checkpoint_id], [material_id], [stop_time_seconds], [question_prompt], [option_a], [option_b], [option_c], [option_d], [correct_option], [explanation], [created_at]) VALUES (2, 3, 120, N'Để đảm bảo tính toàn vẹn dữ liệu (ACID) khi thực hiện nhiều thao tác INSERT/UPDATE liên quan mật thiết với nhau, kỹ thuật nào bắt buộc phải áp dụng?', N'Bật chế độ tự động lưu (AutoCommit = true)', N'Chỉ dùng câu lệnh Statement thông thường', N'Quản lý giao dịch Database Transaction (setAutoCommit(false), commit() và rollback())', N'Bỏ qua việc bắt lỗi ngoại lệ SQLException', 2, N'Chính xác! Database Transaction bảo đảm tính nguyên tử (Atomicity) và nhất quán, rollback lại toàn bộ nếu có bất kỳ bước nào thất bại.', CAST(N'2026-11-01T22:20:32.727' AS DateTime))
INSERT [dbo].[Video_Checkpoints] ([checkpoint_id], [material_id], [stop_time_seconds], [question_prompt], [option_a], [option_b], [option_c], [option_d], [correct_option], [explanation], [created_at]) VALUES (3, 3, 240, N'Để ngăn chặn triệt để lỗ hổng tấn công SQL Injection nguy hiểm trong ứng dụng Java Web, lập trình viên cần sử dụng đối tượng nào?', N'Statement và nối chuỗi trực tiếp (String concatenation)', N'PreparedStatement kết hợp cơ chế Parameterized Query', N'Đổi tên bảng trong cơ sở dữ liệu', N'Không cần xử lý nếu chỉ chạy trên môi trường nội bộ (localhost)', 1, N'Chính xác! PreparedStatement tự động xử lý ký tự đặc biệt và ngăn chặn kẻ tấn công chèn mã SQL độc hại.', CAST(N'2026-11-01T22:20:32.727' AS DateTime))
INSERT [dbo].[Video_Checkpoints] ([checkpoint_id], [material_id], [stop_time_seconds], [question_prompt], [option_a], [option_b], [option_c], [option_d], [correct_option], [explanation], [created_at]) VALUES (4, 5, 30, N'Đâu là khẩu hiệu (Slogan) hành động gắn liền với giá trị cốt lõi của công ty công nghệ chúng ta?', N'Tối ưu quy trình - Nâng tầm giải pháp công nghệ', N'Chấp nhận mọi rủi ro để tăng trưởng bằng mọi giá', N'Giữ nguyên hiện trạng, không thay đổi công nghệ cũ', N'Tập trung cá nhân, hạn chế tinh thần làm việc nhóm', 0, N'Chính xác! Công ty luôn hướng tới đổi mới sáng tạo, tối ưu giải pháp và hỗ trợ khách hàng bằng các công nghệ tiên tiến nhất.', CAST(N'2026-11-01T22:20:32.763' AS DateTime))
INSERT [dbo].[Video_Checkpoints] ([checkpoint_id], [material_id], [stop_time_seconds], [question_prompt], [option_a], [option_b], [option_c], [option_d], [correct_option], [explanation], [created_at]) VALUES (5, 5, 90, N'Kênh liên lạc chính thức nào được ưu tiên để cập nhật thông báo nội bộ và trao đổi công việc hàng ngày?', N'Nhắn tin qua các hội nhóm mạng xã hội tự do', N'Hệ thống Email công vụ và phần mềm giao tiếp nội bộ đã được cấp quyền', N'Chỉ trao đổi truyền miệng không lưu vết', N'Gửi tài liệu mật qua các dịch vụ lưu trữ bên ngoài', 1, N'Chính xác! Mọi trao đổi và tài liệu dự án phải được thực hiện trên kênh chính thức để đảm bảo tính minh bạch và an toàn dữ liệu.', CAST(N'2026-11-01T22:20:32.763' AS DateTime))
SET IDENTITY_INSERT [dbo].[Video_Checkpoints] OFF
GO
SET IDENTITY_INSERT [dbo].[Employee_History] ON 

INSERT [dbo].[Employee_History] ([history_id], [user_id], [old_department_id], [new_department_id], [old_position_id], [new_position_id], [old_level_id], [new_level_id], [change_type], [change_date], [notes], [created_by]) VALUES (1, 4, NULL, 1, NULL, 1, NULL, 2, N'NEW_HIRE', CAST(N'2026-08-01T00:00:00.000' AS DateTime), N'Tuyển dụng mới vị trí Java Developer', 2)
SET IDENTITY_INSERT [dbo].[Employee_History] OFF
GO
SET IDENTITY_INSERT [dbo].[Departments] ON 

INSERT [dbo].[Departments] ([department_id], [department_name], [manager_id], [description], [status], [is_deleted], [created_at]) VALUES (1, N'Phòng Kỹ Thuật (IT)', 3, N'Phát triển, bảo trì và vận hành hệ thống phần mềm', 1, 0, CAST(N'2026-11-01T22:20:31.357' AS DateTime))
INSERT [dbo].[Departments] ([department_id], [department_name], [manager_id], [description], [status], [is_deleted], [created_at]) VALUES (2, N'Phòng Nhân Sự (HR)', 2, N'Tuyển dụng, đào tạo và quản lý chế độ chính sách nhân sự', 1, 0, CAST(N'2026-11-01T22:20:31.357' AS DateTime))
INSERT [dbo].[Departments] ([department_id], [department_name], [manager_id], [description], [status], [is_deleted], [created_at]) VALUES (3, N'Phòng Kinh Doanh (Sales)', NULL, N'Kinh doanh giải pháp, phát triển thị trường và chăm sóc khách hàng', 1, 0, CAST(N'2026-11-01T22:20:31.357' AS DateTime))
INSERT [dbo].[Departments] ([department_id], [department_name], [manager_id], [description], [status], [is_deleted], [created_at]) VALUES (4, N'Phòng Marketing & Truyền Thông', NULL, N'Xây dựng thương hiệu, tiếp thị số và truyền thông doanh nghiệp', 1, 0, CAST(N'2026-11-01T22:20:31.357' AS DateTime))
INSERT [dbo].[Departments] ([department_id], [department_name], [manager_id], [description], [status], [is_deleted], [created_at]) VALUES (5, N'Phòng Kế Toán - Tài Chính', NULL, N'Quản lý dòng tiền, kế toán tổng hợp và lập kế hoạch tài chính', 1, 0, CAST(N'2026-11-01T22:20:31.357' AS DateTime))
SET IDENTITY_INSERT [dbo].[Departments] OFF
GO
SET IDENTITY_INSERT [dbo].[Learning_Progress] ON 

INSERT [dbo].[Learning_Progress] ([progress_id], [user_id], [material_id], [class_id], [status], [last_accessed_at], [completed_at], [notes]) VALUES (1, 4, 1, 1, N'COMPLETED', CAST(N'2026-10-30T22:20:32.950' AS DateTime), CAST(N'2026-10-30T22:20:32.950' AS DateTime), N'Đã đọc xong sổ tay văn hóa doanh nghiệp')
INSERT [dbo].[Learning_Progress] ([progress_id], [user_id], [material_id], [class_id], [status], [last_accessed_at], [completed_at], [notes]) VALUES (2, 4, 5, 1, N'COMPLETED', CAST(N'2026-10-31T22:20:32.950' AS DateTime), CAST(N'2026-10-31T22:20:32.950' AS DateTime), N'Đã xem xong video giới thiệu và hoàn thành câu hỏi tương tác')
INSERT [dbo].[Learning_Progress] ([progress_id], [user_id], [material_id], [class_id], [status], [last_accessed_at], [completed_at], [notes]) VALUES (3, 4, 6, 1, N'IN_PROGRESS', CAST(N'2026-11-01T22:20:32.950' AS DateTime), NULL, N'Đang nghiên cứu cẩm nang an toàn thông tin & bảo mật')
SET IDENTITY_INSERT [dbo].[Learning_Progress] OFF
GO
INSERT [dbo].[Class_Materials] ([class_id], [material_id], [order_index], [is_mandatory]) VALUES (1, 1, 1, 1)
INSERT [dbo].[Class_Materials] ([class_id], [material_id], [order_index], [is_mandatory]) VALUES (1, 2, 4, 1)
INSERT [dbo].[Class_Materials] ([class_id], [material_id], [order_index], [is_mandatory]) VALUES (1, 3, 6, 1)
INSERT [dbo].[Class_Materials] ([class_id], [material_id], [order_index], [is_mandatory]) VALUES (1, 4, 5, 1)
INSERT [dbo].[Class_Materials] ([class_id], [material_id], [order_index], [is_mandatory]) VALUES (1, 5, 2, 1)
INSERT [dbo].[Class_Materials] ([class_id], [material_id], [order_index], [is_mandatory]) VALUES (1, 6, 3, 1)
GO
SET IDENTITY_INSERT [dbo].[Class_Enrollments] ON 

INSERT [dbo].[Class_Enrollments] ([enrollment_id], [class_id], [user_id], [enrolled_by], [enrollment_type], [assigned_reason], [status], [progress_percent], [enrolled_at], [completed_at]) VALUES (1, 1, 4, 3, N'SMART_ASSIGN', N'Phân bổ tự động theo lộ trình vị trí Fresher Java Developer', N'IN_PROGRESS', 33, CAST(N'2026-11-01T22:20:32.947' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[Class_Enrollments] OFF
GO
SET IDENTITY_INSERT [dbo].[Test_Question_Options] ON 

INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (1, 1, N'Đúng', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (2, 1, N'Sai', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (3, 2, N'Báo sớm cho quản lý khi có nguy cơ trễ tiến độ', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (4, 2, N'Bảo mật dữ liệu khách hàng và dữ liệu nội bộ', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (5, 2, N'Phản hồi dựa trên sự việc và hướng đến giải pháp', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (6, 2, N'Chia sẻ mật khẩu cho đồng nghiệp để xử lý nhanh hơn', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (7, 2, N'Bỏ qua quy trình phê duyệt khi công việc gấp', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (8, 2, N'Đưa tài liệu công ty lên thiết bị công cộng', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (9, 3, N'Hỏi quản lý, HR hoặc người phụ trách để được hướng dẫn', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (10, 3, N'Tự suy đoán rồi áp dụng cho cả nhóm', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (11, 3, N'Bỏ qua quy định đó', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (12, 3, N'Đợi đến khi có vi phạm mới tìm hiểu', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (13, 3, N'Hỏi trên mạng xã hội công khai', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (14, 3, N'Sao chép cách làm của một công ty khác', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (15, 4, N'Không cung cấp thông tin và báo bộ phận phụ trách', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (16, 4, N'Nhập mật khẩu để kiểm tra liên kết', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (17, 4, N'Chuyển tiếp email cho toàn công ty', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (18, 4, N'Trả lời email bằng tài khoản cá nhân', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (19, 5, N'Đúng', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (20, 5, N'Sai', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (21, 6, N'Báo ngay cho quản lý hoặc bộ phận phụ trách an toàn thông tin', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (22, 6, N'Tự xóa mọi dữ liệu liên quan rồi không báo cáo', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (23, 6, N'Đăng sự việc lên mạng xã hội để cảnh báo', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (24, 6, N'Chờ đến cuộc họp tuần mới thông báo', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (25, 6, N'Gửi dữ liệu cho bạn bè kiểm tra', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (26, 6, N'Bỏ qua nếu chưa thấy thiệt hại', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (27, 7, N'Cập nhật tiến độ và trở ngại một cách minh bạch', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (28, 7, N'Lắng nghe và phản hồi ý kiến đồng đội với sự tôn trọng', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (29, 7, N'Chủ động hỗ trợ khi thành viên khác cần giúp đỡ', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (30, 7, N'Giữ riêng thông tin quan trọng để tạo lợi thế cá nhân', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (31, 7, N'Đổ lỗi ngay khi có sự cố', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (32, 7, N'Từ chối mọi góp ý trái quan điểm', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (33, 8, N'Chủ động khai báo với quản lý hoặc HR để được hướng dẫn', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (34, 8, N'Giữ kín vì đây là chuyện cá nhân', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (35, 8, N'Tự quyết định mà không cần báo cáo', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (36, 8, N'Nhờ đồng nghiệp che giấu thông tin', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (37, 9, N'Đúng', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (38, 9, N'Sai', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (39, 10, N'Địa chỉ người gửi bất thường hoặc gần giống tên miền thật', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (40, 10, N'Yêu cầu cung cấp mật khẩu hoặc thông tin nhạy cảm', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (41, 10, N'Tạo cảm giác khẩn cấp để buộc người nhận hành động ngay', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (42, 10, N'Email được gửi qua kênh nội bộ đã xác minh', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (43, 10, N'Nội dung đúng với công việc đã trao đổi trước đó', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (44, 10, N'Có chữ ký chuẩn của công ty và không yêu cầu thao tác', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (45, 11, N'Đúng', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (46, 11, N'Sai', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (47, 12, N'Dùng PreparedStatement cho dữ liệu đầu vào', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (48, 12, N'Đóng tài nguyên JDBC bằng try-with-resources', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (49, 12, N'Tách tầng controller, service và data access', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (50, 12, N'Ghi mật khẩu trực tiếp vào source code', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (51, 12, N'Nuốt mọi exception mà không ghi log', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (52, 12, N'Nối trực tiếp input người dùng vào câu SQL', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (53, 13, N'200 OK', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (54, 13, N'201 Created', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (55, 13, N'204 No Content', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (56, 13, N'400 Bad Request', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (57, 13, N'404 Not Found', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (58, 13, N'500 Internal Server Error', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (59, 14, N'Kiểm tra một hành vi nhỏ và xác định', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (60, 14, N'Có thể chạy độc lập và lặp lại', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (61, 14, N'Phụ thuộc trực tiếp vào dữ liệu production', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (62, 14, N'Luôn gọi dịch vụ bên ngoài thật', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (63, 14, N'Thất bại phải chỉ ra hành vi bị sai', 1, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (64, 15, N'Đúng', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (65, 15, N'Sai', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (66, 16, N'Tự động đóng tài nguyên triển khai AutoCloseable', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (67, 16, N'Tạo nhiều thread cùng lúc', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (68, 16, N'Bỏ qua mọi exception', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (69, 16, N'Thay thế toàn bộ câu lệnh điều kiện', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (70, 16, N'Tự động commit mọi transaction', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (71, 16, N'Biên dịch Java thành JavaScript', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (72, 17, N'Dùng danh từ để biểu diễn tài nguyên', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (73, 17, N'Dùng mã trạng thái HTTP phù hợp với kết quả', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (74, 17, N'Kiểm tra và xác thực dữ liệu đầu vào', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (75, 17, N'Luôn trả HTTP 200 cho mọi trường hợp', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (76, 17, N'Đưa mật khẩu và token vào URL', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (77, 17, N'Dùng một endpoint duy nhất cho mọi tài nguyên', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (78, 18, N'Rollback transaction để khôi phục tính nhất quán', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (79, 18, N'Commit các thay đổi đã chạy được', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (80, 18, N'Bỏ qua lỗi và tiếp tục', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (81, 18, N'Xóa toàn bộ database', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (82, 18, N'Tắt kiểm tra khóa ngoại', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (83, 18, N'Chạy lại vô hạn không ghi log', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (84, 19, N'Đúng', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (85, 19, N'Sai', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (86, 20, N'Yêu cầu hợp lệ tạo dữ liệu và trả kết quả thành công', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (87, 20, N'Dữ liệu đầu vào sai bị từ chối với thông báo phù hợp', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (88, 20, N'Người không có quyền không thể tạo tài nguyên', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (89, 20, N'API chấp nhận mọi dữ liệu mà không kiểm tra', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (90, 20, N'Test phụ thuộc vào thứ tự chạy ngẫu nhiên', 0, 5)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (91, 20, N'Test dùng trực tiếp database production', 0, 6)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (92, 21, N'Trạng thái tương lai doanh nghiệp hướng tới', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (93, 21, N'Lịch chấm công từng ngày', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (94, 21, N'Mật khẩu hệ thống', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (95, 21, N'Danh sách thiết bị cá nhân', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (96, 22, N'Nhân viên dùng điện thoại hãng nào?', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (97, 22, N'Doanh nghiệp tồn tại để tạo giá trị gì và cho ai?', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (98, 22, N'Màu áo yêu thích của từng người?', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (99, 22, N'Ai đến văn phòng sớm nhất?', 0, 4)
GO
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (100, 23, N'Thay thế mọi quy định pháp luật', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (101, 23, N'Chỉ dùng trang trí văn phòng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (102, 23, N'Định hướng hành vi và quyết định trong công việc', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (103, 23, N'Chỉ áp dụng cho nhân sự mới', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (104, 24, N'Tự suy đoán rồi phổ biến cho cả nhóm', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (105, 24, N'Bỏ qua nội quy', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (106, 24, N'Làm theo tin đồn', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (107, 24, N'Tra cứu sổ tay và hỏi bộ phận phụ trách', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (108, 25, N'Đúng giờ và chuẩn bị nội dung trước cuộc họp', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (109, 25, N'Thường xuyên trễ hẹn không báo', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (110, 25, N'Ngắt lời mọi người', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (111, 25, N'Bỏ qua cam kết đã nhận', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (112, 26, N'Giấu thông tin đến ngày cuối', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (113, 26, N'Báo sớm và thống nhất phương án xử lý', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (114, 26, N'Đổi hạn mà không thông báo', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (115, 26, N'Đổ lỗi cho đồng nghiệp', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (116, 27, N'Công kích cá nhân', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (117, 27, N'Phát tán tin chưa kiểm chứng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (118, 27, N'Tôn trọng và góp ý dựa trên sự việc cụ thể', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (119, 27, N'Dùng lời lẽ xúc phạm', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (120, 28, N'Tự nghỉ không báo', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (121, 28, N'Nhờ người khác chấm công hộ', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (122, 28, N'Xóa lịch làm việc', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (123, 28, N'Thực hiện quy trình xin phép và bàn giao công việc', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (124, 29, N'Văn bản chính thức và bộ phận nhân sự', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (125, 29, N'Bình luận ẩn danh', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (126, 29, N'Tin nhắn quảng cáo', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (127, 29, N'Tin truyền miệng ngoài công ty', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (128, 30, N'Né tránh mọi trao đổi', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (129, 30, N'Trao đổi dựa trên mục tiêu chung và dữ kiện', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (130, 30, N'Đưa chuyện cá nhân lên mạng', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (131, 30, N'Giữ thông tin để gây khó dễ', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (132, 31, N'Tự ý mang về cho người thân', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (133, 31, N'Cho mượn không kiểm soát', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (134, 31, N'Sử dụng đúng mục đích và báo hỏng kịp thời', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (135, 31, N'Che giấu việc làm mất', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (136, 32, N'Chỉ nhận tên công việc', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (137, 32, N'Không hỏi dù chưa hiểu', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (138, 32, N'Tự bỏ các yêu cầu chưa thích', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (139, 32, N'Xác nhận phạm vi, thời hạn và đầu mối phối hợp', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (140, 33, N'Cải thiện công việc bằng góp ý cụ thể và tôn trọng', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (141, 33, N'Tìm người để đổ lỗi', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (142, 33, N'Chỉ trích trước đám đông', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (143, 33, N'Tránh nêu mọi vấn đề', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (144, 34, N'Đăng thông tin cá nhân lên mạng', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (145, 34, N'Phản ánh qua kênh phù hợp với thông tin xác thực', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (146, 34, N'Bao che vô điều kiện', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (147, 34, N'Tự áp dụng hình phạt', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (148, 35, N'Chỉ đọc tiêu đề một lần', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (149, 35, N'Chỉ nhớ tên tài liệu', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (150, 35, N'Đối chiếu hành vi và quy trình với hướng dẫn chính thức', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (151, 35, N'Coi mọi quy định là tùy chọn', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (152, 36, N'Khoảng thời gian cố định để tạo giá trị hướng tới Sprint Goal', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (153, 36, N'Một cuộc họp không giới hạn thời gian', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (154, 36, N'Toàn bộ vòng đời công ty', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (155, 36, N'Một danh sách lỗi bất kỳ', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (156, 37, N'Chỉ báo cáo giờ làm tháng trước', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (157, 37, N'Thống nhất mục tiêu Sprint và kế hoạch thực hiện', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (158, 37, N'Đánh giá lương từng người', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (159, 37, N'Đóng dự án ngay lập tức', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (160, 38, N'Báo cáo cá nhân để quản lý chấm điểm', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (161, 38, N'Thay thế mọi trao đổi kỹ thuật', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (162, 38, N'Kiểm tra tiến độ tới Sprint Goal và điều chỉnh kế hoạch', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (163, 38, N'Duyệt ngân sách công ty', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (164, 39, N'2 giờ', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (165, 39, N'Một ngày', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (166, 39, N'Không giới hạn', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (167, 39, N'15 phút', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (168, 40, N'Kiểm tra kết quả Sprint với bên liên quan và thích ứng hướng đi', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (169, 40, N'Chỉ tìm lỗi tác phong cá nhân', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (170, 40, N'Chỉ phân công nghỉ phép', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (171, 40, N'Chỉ đọc lại toàn bộ mã nguồn', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (172, 41, N'Logo sản phẩm', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (173, 41, N'Chất lượng và hiệu quả cách nhóm làm việc', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (174, 41, N'Số lượng chức danh', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (175, 41, N'Mật khẩu Jira', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (176, 42, N'Mọi khách hàng tự sửa độc lập', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (177, 42, N'Bất kỳ người ngoài nhóm', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (178, 42, N'Product Owner', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (179, 42, N'Chỉ bộ phận kế toán', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (180, 43, N'Giao từng task bắt buộc cho Developers', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (181, 43, N'Thay Product Owner quyết định mọi ưu tiên', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (182, 43, N'Chấm công thay cả nhóm', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (183, 43, N'Giúp thiết lập Scrum và nâng cao hiệu quả Scrum Team', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (184, 44, N'Danh sách được sắp thứ tự về những gì cần để cải thiện sản phẩm', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (185, 44, N'Danh sách riêng không ai được xem', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (186, 44, N'Chỉ là các lỗi đã đóng', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (187, 44, N'Biên bản nghỉ phép', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (188, 45, N'Toàn bộ ý tưởng tương lai không chọn lọc', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (189, 45, N'Sprint Goal, các hạng mục được chọn và kế hoạch thực hiện', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (190, 45, N'Chỉ tên người quản lý', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (191, 45, N'Mọi tài liệu của công ty', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (192, 46, N'Tự coi mọi task đang làm là xong', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (193, 46, N'Loại bỏ kiểm thử', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (194, 46, N'Thống nhất tiêu chuẩn chất lượng để xác định Increment hoàn thành', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (195, 46, N'Thay đổi mục tiêu công ty', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (196, 47, N'Giữ trạng thái Done dù chưa xong', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (197, 47, N'Xóa mọi bình luận', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (198, 47, N'Để im đến hết Sprint', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (199, 47, N'Ghi rõ trở ngại và trao đổi để tháo gỡ', 1, 4)
GO
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (200, 48, N'Giúp nhóm nhìn thấy tiến độ và phối hợp kịp thời', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (201, 48, N'Bảo đảm không cần họp hay trao đổi', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (202, 48, N'Tự động loại bỏ mọi lỗi', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (203, 48, N'Thay thế toàn bộ kiểm thử', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (204, 49, N'Tự đoán rồi giấu quyết định', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (205, 49, N'Trao đổi với Product Owner để làm rõ và cùng thống nhất', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (206, 49, N'Bỏ mọi tiêu chí chấp nhận', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (207, 49, N'Chờ đến ngày bàn giao mới hỏi', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (208, 50, N'Chỉ ghi biên bản rồi bỏ qua', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (209, 50, N'Luôn thay toàn bộ thành viên', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (210, 50, N'Chọn hành động cụ thể và theo dõi hiệu quả', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (211, 50, N'Chỉ tăng số cuộc họp', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (212, 51, N'Controller tiếp nhận và điều phối request', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (213, 51, N'View trình bày HTML', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (214, 51, N'Máy chủ cơ sở dữ liệu', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (215, 51, N'Công cụ biên dịch CSS', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (216, 52, N'Quản lý transaction trực tiếp cho mọi request', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (217, 52, N'Hiển thị dữ liệu cho người dùng', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (218, 52, N'Thay thế JDBC driver', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (219, 52, N'Lưu mật khẩu database trong HTML', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (220, 53, N'Thiết kế màu giao diện', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (221, 53, N'Quản lý cookie của trình duyệt', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (222, 53, N'Truy cập và ánh xạ dữ liệu từ database', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (223, 53, N'Biên dịch Servlet', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (224, 54, N'Trước mọi câu SQL', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (225, 54, N'Sau mỗi lần render một thẻ HTML', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (226, 54, N'Chỉ khi người dùng đăng xuất', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (227, 54, N'Khi container khởi tạo Servlet', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (228, 55, N'doGet', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (229, 55, N'doPostOnly', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (230, 55, N'renderDatabase', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (231, 55, N'startSession', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (232, 56, N'Xóa toàn bộ database', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (233, 56, N'Giải phóng tài nguyên khi Servlet bị đưa khỏi phục vụ', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (234, 56, N'Xóa tài khoản người truy cập', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (235, 56, N'Tạo session mới', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (236, 57, N'Mỗi field luôn tự mã hóa', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (237, 57, N'Servlet chỉ có thể xử lý một người dùng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (238, 57, N'Nhiều request có thể dùng chung một Servlet đồng thời', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (239, 57, N'Field không tồn tại trong Java', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (240, 58, N'Thay thế toàn bộ database', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (241, 58, N'Tạo khóa ngoại trên HTML', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (242, 58, N'Biên dịch JSP bằng SQL', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (243, 58, N'Kiểm tra đăng nhập trước khi request tới Servlet', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (244, 59, N'Chuyển tiếp request tới bước xử lý tiếp theo', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (245, 59, N'Luôn đóng ứng dụng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (246, 59, N'Xóa session của mọi người', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (247, 59, N'Commit mọi transaction', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (248, 60, N'Mọi dữ liệu bí mật trong URL công khai', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (249, 60, N'Trạng thái gắn với phiên người dùng phía server', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (250, 60, N'Toàn bộ database trên trình duyệt', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (251, 60, N'Chỉ CSS của trang', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (252, 61, N'session.toString()', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (253, 61, N'request.getMethod()', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (254, 61, N'session.invalidate()', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (255, 61, N'response.getStatus()', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (256, 62, N'Mất điện máy chủ', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (257, 62, N'Trình duyệt không hỗ trợ CSS', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (258, 62, N'Ổ đĩa đầy', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (259, 62, N'SQL Injection do nối dữ liệu đầu vào vào SQL', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (260, 63, N'Gọi setAutoCommit(false)', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (261, 63, N'Gọi setAutoCommit(true) sau mỗi câu lệnh', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (262, 63, N'Đóng connection trước khi ghi', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (263, 63, N'Chuyển SQL thành HTML', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (264, 64, N'Commit phần đã chạy bất kể lỗi', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (265, 64, N'Rollback các thay đổi của transaction', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (266, 64, N'Bỏ qua SQLException', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (267, 64, N'Tạo session khác', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (268, 65, N'Tự sửa mọi câu SQL sai', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (269, 65, N'Bảo đảm không bao giờ mất kết nối', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (270, 65, N'Đóng tài nguyên như ResultSet và Statement đúng cách', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (271, 65, N'Thay thế hoàn toàn transaction', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (272, 66, N'Ý nghĩa của dữ liệu trong ngữ cảnh sử dụng', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (273, 66, N'Chỉ một ký tự cho mọi biến', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (274, 66, N'Tên người viết mã', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (275, 66, N'Số dòng trong file', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (276, 67, N'snake_case như employee_service', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (277, 67, N'PascalCase như EmployeeService', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (278, 67, N'Toàn chữ thường có dấu cách', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (279, 67, N'Tên bắt đầu bằng chữ số', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (280, 68, N'PascalCase cho mọi phương thức', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (281, 68, N'Tên có dấu cách', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (282, 68, N'camelCase như calculateScore', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (283, 68, N'Chỉ dùng dấu gạch ngang', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (284, 69, N'Gộp giao diện, SQL và gửi mail vào cùng một hàm', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (285, 69, N'Luôn có hàng nghìn dòng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (286, 69, N'Không có tên mô tả', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (287, 69, N'Thực hiện một nhiệm vụ rõ ràng', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (288, 70, N'Một mô-đun nên có một lý do chính để thay đổi', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (289, 70, N'Một lớp phải xử lý mọi chức năng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (290, 70, N'Mỗi dự án chỉ có một lớp', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (291, 70, N'Không được tạo interface', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (292, 71, N'Mọi thay đổi đều sửa tất cả lớp', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (293, 71, N'Mở cho mở rộng và hạn chế sửa đổi mã ổn định', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (294, 71, N'Không được thêm chức năng', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (295, 71, N'Chỉ dùng biến public', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (296, 72, N'Kiểu con luôn ném lỗi cho mọi hàm kế thừa', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (297, 72, N'Mọi lớp con phải bỏ kiểm thử', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (298, 72, N'Kiểu con có thể thay kiểu cha mà vẫn giữ hợp đồng hành vi', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (299, 72, N'Lớp cha phải biết mọi lớp con', 0, 4)
GO
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (300, 73, N'Một interface khổng lồ cho mọi client', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (301, 73, N'Không được chia interface', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (302, 73, N'Mọi interface đều phải có một trăm hàm', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (303, 73, N'Interface chuyên biệt để client không phụ thuộc hàm không dùng', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (304, 74, N'Mô-đun cấp cao và cấp thấp phụ thuộc abstraction', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (305, 74, N'Service luôn tự tạo mọi dependency cụ thể', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (306, 74, N'UI phải biết mật khẩu database', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (307, 74, N'Mọi lớp chỉ dùng static', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (308, 75, N'Để catch rỗng cho mọi lỗi', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (309, 75, N'Xử lý có ý nghĩa hoặc chuyển tiếp với ngữ cảnh phù hợp', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (310, 75, N'Luôn trả thành công bất kể lỗi', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (311, 75, N'Xóa stack trace và không ghi nhận', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (312, 76, N'Để loại bỏ mọi phương thức', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (313, 76, N'Để không cần review code', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (314, 76, N'Giảm nguy cơ sửa thiếu và hành vi không nhất quán', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (315, 76, N'Để mọi biến thành global', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (316, 77, N'Chỉ số lượng dòng mã', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (317, 77, N'Tên tác giả commit', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (318, 77, N'Thứ tự ngẫu nhiên của các test khác', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (319, 77, N'Hành vi có thể quan sát của đơn vị được kiểm thử', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (320, 78, N'Chuẩn bị, thực hiện, kiểm tra kết quả', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (321, 78, N'Commit, push, merge', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (322, 78, N'Đăng nhập, đăng xuất, xóa user', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (323, 78, N'Tải file, đổi tên, đóng máy', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (324, 79, N'Chỉ một giá trị đẹp nhất', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (325, 79, N'Giá trị hợp lệ, biên và không hợp lệ', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (326, 79, N'Chỉ dữ liệu production', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (327, 79, N'Chỉ chuỗi rỗng cho mọi hàm', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (328, 80, N'Sở thích cá nhân không giải thích', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (329, 80, N'Chỉ đếm số ký tự', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (330, 80, N'Tính đúng, khả năng đọc, bảo trì và tuân thủ quy ước', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (331, 80, N'Bỏ qua logic nếu tên file đẹp', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (332, 81, N'Tối ưu quy trình - Nâng tầm giải pháp công nghệ', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (333, 81, N'Chấp nhận mọi rủi ro để tăng trưởng bằng mọi giá', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (334, 81, N'Giữ nguyên hiện trạng, không thay đổi công nghệ cũ', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (335, 81, N'Tập trung cá nhân, hạn chế tinh thần làm việc nhóm', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (336, 82, N'Mật khẩu tài khoản đồng nghiệp', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (337, 82, N'Bối cảnh phát triển và những giá trị được xây dựng', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (338, 82, N'Đáp án mọi bài kiểm tra kỹ thuật', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (339, 82, N'Lịch nghỉ riêng của lãnh đạo', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (340, 83, N'Thay thế mọi dữ liệu thực tế', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (341, 83, N'Chỉ quyết định màu đồng phục', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (342, 83, N'Tạo định hướng dài hạn cho lựa chọn và ưu tiên', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (343, 83, N'Loại bỏ trách nhiệm cá nhân', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (344, 84, N'Sở thích giải trí của đồng nghiệp', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (345, 84, N'Kích thước văn phòng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (346, 84, N'Số lượng email quảng cáo', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (347, 84, N'Giá trị doanh nghiệp tạo ra cho khách hàng và cộng đồng', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (348, 85, N'Kết quả lâu dài cùng trách nhiệm với con người và môi trường', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (349, 85, N'Lợi ích ngắn hạn bằng mọi giá', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (350, 85, N'Che giấu mọi tác động tiêu cực', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (351, 85, N'Chỉ tăng giờ làm liên tục', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (352, 86, N'Phân biệt đối xử', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (353, 86, N'Lắng nghe và đối xử công bằng', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (354, 86, N'Công kích khi người khác góp ý', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (355, 86, N'Ngăn mọi trao đổi giữa các nhóm', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (356, 87, N'Thay đổi tùy tiện không trao đổi', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (357, 87, N'Luôn từ chối ý tưởng mới', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (358, 87, N'Đề xuất cải tiến có mục tiêu và đánh giá kết quả', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (359, 87, N'Bỏ mọi quy trình kiểm soát', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (360, 88, N'Tăng bước duyệt mà không đánh giá', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (361, 88, N'Đổi tên mọi biểu mẫu', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (362, 88, N'Xóa toàn bộ tài liệu hướng dẫn', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (363, 88, N'Xác định điểm nghẽn và nhu cầu thực tế', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (364, 89, N'Cải thiện giá trị và chất lượng giải pháp cho người dùng', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (365, 89, N'Chọn công nghệ chỉ vì đang nổi tiếng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (366, 89, N'Tăng độ phức tạp bất kể nhu cầu', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (367, 89, N'Loại bỏ mọi phản hồi khách hàng', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (368, 90, N'Tự bỏ mục tiêu của nhóm', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (369, 90, N'Trao đổi để điều chỉnh mục tiêu và cách đóng góp', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (370, 90, N'Giấu tiến độ', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (371, 90, N'Ngừng phối hợp với đồng nghiệp', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (372, 91, N'Giữ mọi thông tin để tạo lợi thế cá nhân', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (373, 91, N'Đổ lỗi qua lại', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (374, 91, N'Chia sẻ thông tin cần thiết qua kênh phù hợp', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (375, 91, N'Chỉ hỗ trợ người quen', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (376, 92, N'Tự động thay thế mọi quyết định quản lý', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (377, 92, N'Bảo đảm mọi ý kiến đều phải được áp dụng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (378, 92, N'Chỉ dùng để so sánh cá nhân', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (379, 92, N'Giúp phát hiện vấn đề và đề xuất cải tiến', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (380, 93, N'Nội dung chính thức đã được xác nhận', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (381, 93, N'Tin đồn chưa kiểm chứng', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (382, 93, N'Bình luận ẩn danh', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (383, 93, N'Thông tin tự suy diễn', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (384, 94, N'Chỉ hoàn thành việc dễ nhìn thấy', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (385, 94, N'Thực hiện cam kết và chủ động báo cáo trở ngại', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (386, 94, N'Bỏ qua chất lượng để báo xong sớm', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (387, 94, N'Đẩy trách nhiệm cho người khác', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (388, 95, N'Chỉ ghi nhớ độ dài video', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (389, 95, N'Bỏ qua các kênh trao đổi chính thức', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (390, 95, N'Liên hệ giá trị và mục tiêu chung với công việc của mình', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (391, 95, N'Coi định hướng là trách nhiệm riêng của lãnh đạo', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (392, 96, N'Dài, khó đoán và riêng cho từng tài khoản', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (393, 96, N'Tên công ty kèm 123', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (394, 96, N'Ngày sinh công khai', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (395, 96, N'Một mật khẩu dùng cho mọi dịch vụ', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (396, 97, N'Cho phép chia sẻ tài khoản an toàn', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (397, 97, N'Bổ sung lớp xác minh ngoài mật khẩu', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (398, 97, N'Thay thế mọi biện pháp bảo mật', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (399, 97, N'Công khai mã OTP cho đồng nghiệp', 0, 4)
GO
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (400, 98, N'Bấm link và nhập mật khẩu ngay', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (401, 98, N'Chuyển tiếp cho mọi người làm theo', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (402, 98, N'Kiểm tra qua kênh chính thức và báo bộ phận phụ trách', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (403, 98, N'Gửi kèm mã OTP để xác nhận', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (404, 99, N'Tăng tốc đường truyền', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (405, 99, N'Sửa lỗi giao diện tự động', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (406, 99, N'Nén file an toàn', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (407, 99, N'Lừa người dùng cung cấp thông tin hoặc thực hiện hành động nguy hiểm', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (408, 100, N'Xác minh người gửi và mức độ tin cậy của tệp', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (409, 100, N'Tắt phần mềm bảo vệ', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (410, 100, N'Mở ngay vì có logo công ty', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (411, 100, N'Đổi đuôi file rồi chạy', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (412, 101, N'Cấp quyền admin cho mọi người', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (413, 101, N'Chỉ cấp quyền cần thiết cho nhiệm vụ', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (414, 101, N'Chia sẻ tài khoản quản trị', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (415, 101, N'Giữ quyền cũ vĩnh viễn', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (416, 102, N'Trong repository public', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (417, 102, N'Trong bình luận của mã JavaScript gửi xuống client', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (418, 102, N'Trong cơ chế quản lý bí mật phù hợp, ngoài mã nguồn công khai', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (419, 102, N'Trong ảnh chụp đăng lên mạng', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (420, 103, N'Chỉ xóa dòng ở commit mới rồi coi như an toàn', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (421, 103, N'Đổi tên repository', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (422, 103, N'Tắt máy cá nhân', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (423, 103, N'Thu hồi hoặc thay secret bị lộ và báo sự cố', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (424, 104, N'Khóa màn hình', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (425, 104, N'Để session quản trị mở sẵn', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (426, 104, N'Gửi mật khẩu cho người ngồi cạnh', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (427, 104, N'Tắt mọi kiểm soát truy cập', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (428, 105, N'Bất kỳ link công khai nào cũng phù hợp', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (429, 105, N'Đúng người nhận, quyền truy cập và kênh được phép', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (430, 105, N'Gửi toàn bộ dữ liệu để tiết kiệm thời gian', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (431, 105, N'Dùng tài khoản người khác', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (432, 106, N'Giấu sự việc', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (433, 106, N'Tiếp tục dùng rồi chờ tự hết', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (434, 106, N'Báo ngay qua kênh xử lý sự cố và thực hiện hướng dẫn bảo vệ tài khoản', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (435, 106, N'Gửi mật khẩu lên nhóm chat', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (436, 107, N'Thay thế hoàn toàn kiểm soát truy cập', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (437, 107, N'Cho phép bỏ qua mọi cập nhật bảo mật', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (438, 107, N'Bảo đảm không bao giờ có sự cố', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (439, 107, N'Hỗ trợ khôi phục khi dữ liệu bị mất hoặc hỏng', 1, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (440, 108, N'Giảm nguy cơ bị khai thác lỗ hổng đã biết', 1, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (441, 108, N'Để công khai mọi dữ liệu', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (442, 108, N'Để không cần mật khẩu', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (443, 108, N'Để tự động cấp quyền quản trị', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (444, 109, N'Ghi đầy đủ mật khẩu để dễ debug', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (445, 109, N'Hạn chế ghi và che thông tin theo quy định', 1, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (446, 109, N'Gửi log công khai cho mọi người', 0, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (447, 109, N'Luôn ghi mã OTP rõ ràng', 0, 4)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (448, 110, N'Làm ngay chỉ vì lời nhắn khẩn', 0, 1)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (449, 110, N'Bỏ qua quy định bảo mật', 0, 2)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (450, 110, N'Xác minh danh tính và thẩm quyền qua kênh độc lập', 1, 3)
INSERT [dbo].[Test_Question_Options] ([id], [question_id], [option_text], [is_correct], [display_order]) VALUES (451, 110, N'Gửi cả thông tin không được yêu cầu', 0, 4)
SET IDENTITY_INSERT [dbo].[Test_Question_Options] OFF
GO
SET IDENTITY_INSERT [dbo].[Test_Questions] ON 

INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (1, 1, N'Nhân viên được phép chia sẻ tài liệu nội bộ lên mạng xã hội nếu không ghi tên công ty.', N'true_false')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (2, 1, N'Chọn đúng 3 hành vi thể hiện cách làm việc chuyên nghiệp.', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (3, 1, N'Khi chưa hiểu một quy định nội bộ, lựa chọn phù hợp nhất là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (4, 1, N'Khi nhận email đáng ngờ yêu cầu cung cấp mật khẩu, nhân viên nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (5, 1, N'Nhân viên có thể gửi dữ liệu khách hàng qua email cá nhân nếu chỉ dùng trong công việc.', N'true_false')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (6, 1, N'Khi phát hiện nguy cơ mất an toàn thông tin, nhân viên cần ưu tiên hành động nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (7, 1, N'Chọn đúng 3 hành động giúp phối hợp nhóm hiệu quả.', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (8, 1, N'Khi có khả năng phát sinh xung đột lợi ích, nhân viên nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (9, 1, N'Mọi hành vi quấy rối hoặc phân biệt đối xử tại nơi làm việc đều cần được phản ánh qua kênh phù hợp.', N'true_false')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (10, 1, N'Chọn đúng 3 dấu hiệu thường gặp của email lừa đảo.', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (11, 2, N'PreparedStatement với tham số ràng buộc giúp giảm nguy cơ SQL Injection.', N'true_false')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (12, 2, N'Chọn đúng 3 thực hành tốt khi phát triển Java Backend.', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (13, 2, N'Mã trạng thái HTTP nào biểu thị tài nguyên được tạo thành công?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (14, 2, N'Những đặc điểm nào đúng về một unit test tốt?', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (15, 2, N'Toán tử == luôn là cách đúng để so sánh nội dung của hai String trong Java.', N'true_false')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (16, 2, N'Try-with-resources trong Java được dùng chủ yếu để làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (17, 2, N'Chọn đúng 3 nguyên tắc phù hợp khi thiết kế REST API.', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (18, 2, N'Khi một thao tác transaction gặp lỗi trước khi hoàn tất, hành động phù hợp là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (19, 2, N'Git branch giúp phát triển thay đổi tách biệt trước khi hợp nhất.', N'true_false')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (20, 2, N'Chọn đúng 3 kiểm tra quan trọng cho một API tạo tài nguyên.', N'multiple')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (21, 3, N'Tầm nhìn doanh nghiệp mô tả điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (22, 3, N'Sứ mệnh doanh nghiệp trả lời câu hỏi nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (23, 3, N'Giá trị cốt lõi có vai trò gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (24, 3, N'Khi chưa rõ một nội quy, nhân viên nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (25, 3, N'Hành vi nào thể hiện tác phong chuyên nghiệp?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (26, 3, N'Khi nhận thấy có nguy cơ trễ hạn, nên xử lý thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (27, 3, N'Cách trao đổi nào phù hợp trong môi trường làm việc?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (28, 3, N'Khi cần nghỉ phép, nhân viên nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (29, 3, N'Nguồn nào phù hợp để kiểm tra chính sách phúc lợi?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (30, 3, N'Khi có bất đồng trong nhóm, cách xử lý phù hợp là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (31, 3, N'Trách nhiệm với tài sản công ty thể hiện ở đâu?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (32, 3, N'Khi tiếp nhận công việc từ đồng nghiệp, cần làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (33, 3, N'Văn hóa phản hồi tích cực hướng đến điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (34, 3, N'Khi thấy hành vi vi phạm nội quy, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (35, 3, N'Để áp dụng sổ tay vào công việc hằng ngày, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (36, 4, N'Sprint trong Scrum là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (37, 4, N'Sprint Planning nhằm mục đích gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (38, 4, N'Daily Scrum chủ yếu giúp Developers làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (39, 4, N'Thời lượng timebox của Daily Scrum là bao lâu?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (40, 4, N'Sprint Review tập trung vào điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (41, 4, N'Sprint Retrospective nhằm cải thiện điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (42, 4, N'Ai chịu trách nhiệm quản lý Product Backlog hiệu quả?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (43, 4, N'Scrum Master có trách nhiệm nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (44, 4, N'Product Backlog là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (45, 4, N'Sprint Backlog thể hiện điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (46, 4, N'Definition of Done giúp nhóm làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (47, 4, N'Khi task bị chặn trên Jira, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (48, 4, N'Cập nhật trạng thái task đúng thực tế mang lại lợi ích gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (49, 4, N'Khi phát hiện yêu cầu chưa rõ, Developers nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (50, 4, N'Một cải tiến từ Retrospective nên được thực hiện thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (51, 5, N'Trong MVC, Servlet thường đóng vai trò gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (52, 5, N'Trong MVC, JSP thường đảm nhận nhiệm vụ nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (53, 5, N'Tầng DAO chịu trách nhiệm chính về việc gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (54, 5, N'Phương thức init của Servlet thường chạy khi nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (55, 5, N'Phương thức nào xử lý HTTP GET trong HttpServlet?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (56, 5, N'Phương thức destroy của Servlet dùng để làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (57, 5, N'Vì sao không nên lưu dữ liệu riêng từng người dùng trong field Servlet?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (58, 5, N'Filter có thể được dùng cho công việc nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (59, 5, N'Trong Filter, chain.doFilter có tác dụng gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (60, 5, N'HttpSession thường dùng để lưu thông tin gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (61, 5, N'Khi đăng xuất, thao tác nào giúp kết thúc session hiện tại?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (62, 5, N'PreparedStatement với tham số ràng buộc giúp giảm nguy cơ gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (63, 5, N'Để bắt đầu quản lý transaction JDBC thủ công, cần làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (64, 5, N'Khi một bước trong transaction thất bại, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (65, 5, N'Try-with-resources giúp ích gì khi làm việc với JDBC?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (66, 6, N'Tên biến tốt nên thể hiện điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (67, 6, N'Quy ước thông dụng cho tên lớp Java là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (68, 6, N'Quy ước thông dụng cho tên phương thức Java là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (69, 6, N'Một hàm dễ bảo trì thường có đặc điểm nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (70, 6, N'Single Responsibility Principle đề cập điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (71, 6, N'Open/Closed Principle khuyến khích điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (72, 6, N'Liskov Substitution Principle yêu cầu điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (73, 6, N'Interface Segregation Principle khuyến khích điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (74, 6, N'Dependency Inversion Principle hướng tới điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (75, 6, N'Khi bắt exception, cách xử lý phù hợp là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (76, 6, N'Vì sao nên tránh lặp lại cùng một quy tắc nghiệp vụ ở nhiều nơi?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (77, 6, N'Unit test tốt nên kiểm tra điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (78, 6, N'Mẫu Arrange–Act–Assert gồm những bước nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (79, 6, N'Khi kiểm thử đầu vào, trường hợp nào cần được cân nhắc?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (80, 6, N'Review mã nguồn nên ưu tiên điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (81, 7, N'Khẩu hiệu hành động trong checkpoint của video là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (82, 7, N'Tìm hiểu lịch sử hình thành công ty giúp nhân viên hiểu điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (83, 7, N'Tầm nhìn hỗ trợ việc ra quyết định như thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (84, 7, N'Sứ mệnh giúp nhân viên liên hệ công việc với điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (85, 7, N'Định hướng phát triển bền vững cần cân nhắc điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (86, 7, N'Môi trường làm việc tôn trọng con người thể hiện qua hành vi nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (87, 7, N'Đổi mới sáng tạo trong công việc nên được thực hiện thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (88, 7, N'Tối ưu quy trình nên bắt đầu từ đâu?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (89, 7, N'Nâng tầm giải pháp công nghệ hướng tới điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (90, 7, N'Khi mục tiêu cá nhân chưa phù hợp định hướng chung, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (91, 7, N'Tinh thần phối hợp giữa các bộ phận được thể hiện thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (92, 7, N'Phản hồi của nhân viên có thể đóng góp gì cho môi trường làm việc?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (93, 7, N'Khi truyền đạt thông tin về công ty, nên ưu tiên nguồn nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (94, 7, N'Hành động nào thể hiện trách nhiệm với định hướng chung?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (95, 7, N'Sau khi xem video định hướng, nhân viên nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (96, 8, N'Mật khẩu nào có đặc điểm an toàn hơn?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (97, 8, N'Xác thực đa yếu tố có tác dụng gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (98, 8, N'Khi nhận email yêu cầu đăng nhập khẩn cấp qua link lạ, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (99, 8, N'Phishing thường nhằm mục đích gì?', N'single')
GO
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (100, 8, N'Trước khi mở tệp đính kèm bất ngờ, cần làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (101, 8, N'Nguyên tắc đặc quyền tối thiểu nghĩa là gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (102, 8, N'API key và mật khẩu database nên được lưu thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (103, 8, N'Nếu đã commit nhầm secret vào repository, nên làm gì trước hết?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (104, 8, N'Khi rời máy làm việc, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (105, 8, N'Chia sẻ dữ liệu nội bộ cần tuân thủ điều gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (106, 8, N'Khi nghi ngờ tài khoản bị chiếm quyền, nên làm gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (107, 8, N'Sao lưu dữ liệu có ý nghĩa gì?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (108, 8, N'Vì sao cần cập nhật bản vá bảo mật?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (109, 8, N'Dữ liệu nhạy cảm trong log nên được xử lý thế nào?', N'single')
INSERT [dbo].[Test_Questions] ([id], [content_id], [prompt], [question_type]) VALUES (110, 8, N'Khi nhận yêu cầu chuyển dữ liệu từ người tự xưng là lãnh đạo, nên làm gì?', N'single')
SET IDENTITY_INSERT [dbo].[Test_Questions] OFF
GO
SET IDENTITY_INSERT [dbo].[Test_Content] ON 

INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (1, N'Đề thi Văn hóa doanh nghiệp', N'Đánh giá kiến thức về bảo mật, giao tiếp, hợp tác và quy định làm việc.', N'quiz', N'culture', NULL, 1, N'ready', 0, CAST(N'2026-11-01T15:20:32.0285038' AS DateTime2), NULL)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (2, N'Đề thi Chuyên môn Java Backend', N'Đánh giá nền tảng Java, SQL, HTTP, Git và kiểm thử dành cho phòng Kỹ thuật.', N'quiz', N'department', 1, 3, N'ready', 0, CAST(N'2026-11-01T15:20:32.0496822' AS DateTime2), NULL)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (3, N'Học liệu: Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty', N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. Tài liệu định hướng chuẩn mực dành cho toàn bộ nhân sự mới: Tầm nhìn sứ mệnh, 5 giá trị cốt lõi, tác phong làm việc chuyên nghiệp, nội quy lao động và chính sách phúc lợi.', N'quiz', N'learning', NULL, 2, N'ready', 0, CAST(N'2026-11-01T15:20:32.6515106' AS DateTime2), 1)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (4, N'Học liệu: Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum', N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. Trình chiếu bài giảng chi tiết về quy trình vận hành Sprint, các buổi lễ Scrum (Planning, Daily Standup, Review, Retrospective), cách quản lý Task trên Jira và văn hóa phối hợp đội ngũ.', N'quiz', N'learning', 1, 3, N'ready', 0, CAST(N'2026-11-01T15:20:32.6565176' AS DateTime2), 2)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (5, N'Học liệu: Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE', N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. Khóa học video cô đọng chuẩn kiến trúc phần mềm MVC, vòng đời Servlet, Bộ lọc Filter, quản lý Session và tương tác cơ sở dữ liệu qua JDBC Transaction trong dự án doanh nghiệp thực tế.', N'quiz', N'learning', 1, 3, N'ready', 0, CAST(N'2026-11-01T15:20:32.6628786' AS DateTime2), 3)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (6, N'Học liệu: Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)', N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. Tài liệu quy định chi tiết về cấu trúc mã nguồn, quy chuẩn đặt tên biến/hàm/lớp, nguyên tắc SOLID, kỹ thuật xử lý ngoại lệ và viết Unit Test theo chuẩn dự án doanh nghiệp.', N'quiz', N'learning', 1, 3, N'ready', 0, CAST(N'2026-11-01T15:20:32.6693999' AS DateTime2), 4)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (7, N'Học liệu: Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026', N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. Thước phim truyền thông nội bộ giới thiệu lịch sử hình thành, đội ngũ ban điều hành, giá trị con người và định hướng phát triển bền vững của công ty trong năm 2026.', N'quiz', N'learning', NULL, 2, N'ready', 0, CAST(N'2026-11-01T15:20:32.6764096' AS DateTime2), 5)
INSERT [dbo].[Test_Content] ([id], [title], [prompt], [kind], [type], [department_id], [created_by], [status], [is_deleted], [created_at], [learning_material_id]) VALUES (8, N'Học liệu: Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp', N'Bộ đề 15 câu ôn tập theo chủ đề học liệu. Nội dung được biên soạn từ mô tả và checkpoint trong hệ thống; cần đối chiếu tài liệu gốc trước khi dùng đánh giá chính thức. Hướng dẫn thực thi các tiêu chuẩn an toàn bảo mật thông tin nội bộ, nguyên tắc đặt mật khẩu định kỳ, bảo mật mã nguồn dự án và phòng ngừa tấn công lừa đảo qua mạng (Phishing).', N'quiz', N'learning', NULL, 2, N'ready', 0, CAST(N'2026-11-01T15:20:32.6819282' AS DateTime2), 6)
SET IDENTITY_INSERT [dbo].[Test_Content] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (1, N'ADMIN', N'Quản trị viên hệ thống')
INSERT [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (2, N'HR', N'Nhân sự quản lý phòng ban, vị trí và nhân viên')
INSERT [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (3, N'MANAGER', N'Trưởng phòng quản lý nhân viên trong phòng ban của mình')
INSERT [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (4, N'EMPLOYEE', N'Nhân viên công ty')
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (1, N'admin', N'123', N'Quản Trị Viên', N'admin@hrm.com', N'0901000001', N'Nam', NULL, 1, 1, 1, 6, CAST(N'2022-01-01' AS Date), 1, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (2, N'hr_manager', N'123', N'Phạm Thu Hà', N'ha.pt@hrm.com', N'0901000002', N'Nữ', NULL, 2, 2, 4, 5, CAST(N'2022-03-15' AS Date), 1, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (3, N'manager_it', N'123', N'Trần Văn Minh', N'minh.tv@hrm.com', N'0901000003', N'Nam', NULL, 3, 1, 1, 6, CAST(N'2022-02-01' AS Date), 1, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (4, N'dev_fresher', N'123', N'Phạm Đức Trọng', N'trong.pd@hrm.com', N'0901000006', N'Nam', NULL, 4, 1, 1, 2, CAST(N'2026-08-01' AS Date), 1, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (5, N'dev_tester', N'123', N'Ngô Mai Phương', N'phuong.nm@hrm.com', N'0901000007', N'Nữ', NULL, 4, 1, 3, 3, CAST(N'2023-06-01' AS Date), 1, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (6, N'mentor_java', N'123', N'Lê Hữu Mentor', N'mentor.java@hrm.com', N'0988888888', N'Nam', NULL, 4, 1, 1, 5, CAST(N'2021-01-01' AS Date), 1, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [gender], [dob], [role_id], [department_id], [position_id], [level_id], [hire_date], [status], [is_deleted], [created_at]) VALUES (7, N'locked_user', N'123', N'Nguyễn Khóa Khoản', N'locked.user@hrm.com', N'0901999999', N'Nam', NULL, 4, 1, 1, 2, CAST(N'2026-01-01' AS Date), 0, 0, CAST(N'2026-11-01T22:20:31.493' AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET IDENTITY_INSERT [dbo].[Training_Classes] ON 

INSERT [dbo].[Training_Classes] ([class_id], [class_code], [class_name], [description], [department_id], [target_position_id], [target_level_id], [mentor_id], [start_date], [end_date], [status], [is_deleted], [created_by], [created_at]) VALUES (1, N'CLS-IT-FRESHER-2026', N'Khóa Đào Tạo Onboarding Kỹ Thuật Cho Fresher 2026', N'Lớp đào tạo nền tảng kiến thức công nghệ, văn hóa làm việc và quy trình kỹ thuật dành cho các bạn Fresher/Junior mới gia nhập phòng IT.', 1, 1, 2, 3, CAST(N'2026-11-01' AS Date), CAST(N'2026-12-01' AS Date), N'OPEN', 0, 2, CAST(N'2026-11-01T22:20:32.800' AS DateTime))
SET IDENTITY_INSERT [dbo].[Training_Classes] OFF
GO
SET IDENTITY_INSERT [dbo].[Learning_Materials] ON 

INSERT [dbo].[Learning_Materials] ([material_id], [title], [description], [material_type], [scope_type], [department_id], [position_id], [level_id], [material_url], [video_url], [duration_minutes], [file_name], [file_type], [file_data], [file_size], [status], [is_deleted], [created_by], [created_at], [updated_at]) VALUES (1, N'Sổ Tay Văn Hóa Doanh Nghiệp & Quy Định Công Ty', N'Tài liệu định hướng chuẩn mực dành cho toàn bộ nhân sự mới: Tầm nhìn sứ mệnh, 5 giá trị cốt lõi, tác phong làm việc chuyên nghiệp, nội quy lao động và chính sách phúc lợi.', N'PDF', N'CULTURE', NULL, NULL, NULL, N'https://viethandvh.com/wp-content/uploads/2026/04/So-tay-van-hoa.pdf', N'https://viethandvh.com/wp-content/uploads/2026/04/So-tay-van-hoa.pdf', 30, N'So_Tay_Van_Hoa_Doanh_Nghiep.pdf', N'application/pdf', NULL, 1048576, 1, 0, 2, CAST(N'2026-09-28T08:24:23.550' AS DateTime), CAST(N'2026-09-28T08:24:23.550' AS DateTime))
INSERT [dbo].[Learning_Materials] ([material_id], [title], [description], [material_type], [scope_type], [department_id], [position_id], [level_id], [material_url], [video_url], [duration_minutes], [file_name], [file_type], [file_data], [file_size], [status], [is_deleted], [created_by], [created_at], [updated_at]) VALUES (2, N'Slide Đào Tạo Quy Trình Phát Triển Phần Mềm Agile/Scrum', N'Trình chiếu bài giảng chi tiết về quy trình vận hành Sprint, các buổi lễ Scrum (Planning, Daily Standup, Review, Retrospective), cách quản lý Task trên Jira và văn hóa phối hợp đội ngũ.', N'SLIDE', N'DEPARTMENT', 1, 1, 2, N'https://docs.google.com/presentation/d/1WX3Lvh6A8TqQBmbr4XyRN8SaWSsxIoQo/edit?rtpof=true', N'https://docs.google.com/presentation/d/1WX3Lvh6A8TqQBmbr4XyRN8SaWSsxIoQo/edit?rtpof=true', 45, N'Agile_Scrum_Onboarding.pptx', N'application/vnd.openxmlformats-officedocument.presentationml.presentation', NULL, 2097152, 1, 0, 3, CAST(N'2026-09-28T08:24:23.553' AS DateTime), CAST(N'2026-09-28T08:29:17.967' AS DateTime))
INSERT [dbo].[Learning_Materials] ([material_id], [title], [description], [material_type], [scope_type], [department_id], [position_id], [level_id], [material_url], [video_url], [duration_minutes], [file_name], [file_type], [file_data], [file_size], [status], [is_deleted], [created_by], [created_at], [updated_at]) VALUES (3, N'Video Bài Giảng: Kiến Trúc Java Backend & Servlet Jakarta EE', N'Khóa học video cô đọng chuẩn kiến trúc phần mềm MVC, vòng đời Servlet, Bộ lọc Filter, quản lý Session và tương tác cơ sở dữ liệu qua JDBC Transaction trong dự án doanh nghiệp thực tế.', N'VIDEO', N'DEPARTMENT', 1, 1, 2, N'https://www.youtube.com/watch?v=4wqMsmSEllA&t=532s', N'https://www.youtube.com/watch?v=4wqMsmSEllA&t=532s', 25, NULL, N'video/mp4', NULL, NULL, 1, 0, 3, CAST(N'2026-09-28T08:24:23.557' AS DateTime), CAST(N'2026-09-28T08:30:25.600' AS DateTime))
INSERT [dbo].[Learning_Materials] ([material_id], [title], [description], [material_type], [scope_type], [department_id], [position_id], [level_id], [material_url], [video_url], [duration_minutes], [file_name], [file_type], [file_data], [file_size], [status], [is_deleted], [created_by], [created_at], [updated_at]) VALUES (4, N'Bộ Tiêu Chuẩn Lập Trình Java & Quy Định Đặt Mã Nguồn (Clean Code)', N'Tài liệu quy định chi tiết về cấu trúc mã nguồn, quy chuẩn đặt tên biến/hàm/lớp, nguyên tắc SOLID, kỹ thuật xử lý ngoại lệ và viết Unit Test theo chuẩn dự án doanh nghiệp.', N'PDF', N'DEPARTMENT', 1, 1, 2, N'/assets/docs/Java_Clean_Code_Conventions.pdf', NULL, 40, N'Java_Clean_Code_Conventions.pdf', N'application/pdf', NULL, 1258291, 1, 0, 3, CAST(N'2026-09-28T08:24:23.560' AS DateTime), CAST(N'2026-09-28T08:24:23.560' AS DateTime))
INSERT [dbo].[Learning_Materials] ([material_id], [title], [description], [material_type], [scope_type], [department_id], [position_id], [level_id], [material_url], [video_url], [duration_minutes], [file_name], [file_type], [file_data], [file_size], [status], [is_deleted], [created_by], [created_at], [updated_at]) VALUES (5, N'Video Giới Thiệu Tầm Nhìn, Sứ Mệnh & Môi Trường Làm Việc 2026', N'Thước phim truyền thông nội bộ giới thiệu lịch sử hình thành, đội ngũ ban điều hành, giá trị con người và định hướng phát triển bền vững của công ty trong năm 2026.', N'VIDEO', N'CULTURE', NULL, NULL, NULL, N'https://www.youtube.com/watch?v=KRYONejN6SU', N'https://www.youtube.com/watch?v=KRYONejN6SU', 15, NULL, N'video/mp4', NULL, NULL, 1, 0, 2, CAST(N'2026-09-28T08:24:23.560' AS DateTime), CAST(N'2026-09-28T08:27:47.147' AS DateTime))
INSERT [dbo].[Learning_Materials] ([material_id], [title], [description], [material_type], [scope_type], [department_id], [position_id], [level_id], [material_url], [video_url], [duration_minutes], [file_name], [file_type], [file_data], [file_size], [status], [is_deleted], [created_by], [created_at], [updated_at]) VALUES (6, N'Cẩm Nang Quy Chuẩn An Toàn Thông Tin & Bảo Mật Dữ Liệu Doanh Nghiệp', N'Hướng dẫn thực thi các tiêu chuẩn an toàn bảo mật thông tin nội bộ, nguyên tắc đặt mật khẩu định kỳ, bảo mật mã nguồn dự án và phòng ngừa tấn công lừa đảo qua mạng (Phishing).', N'PDF', N'CULTURE', NULL, NULL, NULL, N'/assets/docs/Cam_Nang_Quy_Chuan_An_Toan_Thong_Tin_Bao_Mat.pdf', NULL, 20, N'Cam_Nang_Quy_Chuan_An_Toan_Thong_Tin_Bao_Mat.pdf', N'application/pdf', NULL, 10518152, 1, 0, 2, CAST(N'2026-09-28T08:24:23.560' AS DateTime), CAST(N'2026-09-28T08:27:09.823' AS DateTime))
SET IDENTITY_INSERT [dbo].[Learning_Materials] OFF
GO
SET IDENTITY_INSERT [dbo].[Job_Levels] ON 

INSERT [dbo].[Job_Levels] ([level_id], [level_name], [rank_order], [description]) VALUES (1, N'Intern', 1, N'Thực tập sinh')
INSERT [dbo].[Job_Levels] ([level_id], [level_name], [rank_order], [description]) VALUES (2, N'Fresher', 2, N'Nhân viên mới vào nghề')
INSERT [dbo].[Job_Levels] ([level_id], [level_name], [rank_order], [description]) VALUES (3, N'Junior', 3, N'Nhân viên có từ 1 - 2 năm kinh nghiệm')
INSERT [dbo].[Job_Levels] ([level_id], [level_name], [rank_order], [description]) VALUES (4, N'Middle', 4, N'Nhân viên từ 2 - 4 năm kinh nghiệm')
INSERT [dbo].[Job_Levels] ([level_id], [level_name], [rank_order], [description]) VALUES (5, N'Senior', 5, N'Chuyên viên từ 4+ năm kinh nghiệm')
INSERT [dbo].[Job_Levels] ([level_id], [level_name], [rank_order], [description]) VALUES (6, N'Lead', 6, N'Trưởng nhóm chuyên môn')
SET IDENTITY_INSERT [dbo].[Job_Levels] OFF
GO
CREATE NONCLUSTERED INDEX [IX_Checkpoints_Material] ON [dbo].[Video_Checkpoints]
(
	[material_id] ASC,
	[stop_time_seconds] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Video_Question_Answers] ADD  CONSTRAINT [UQ_Checkpoint_User] UNIQUE NONCLUSTERED 
(
	[checkpoint_id] ASC,
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_PosReq_Dept_Status] ON [dbo].[Position_Requests]
(
	[department_id] ASC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Departments] ADD UNIQUE NONCLUSTERED 
(
	[department_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Departments_SingleManager] ON [dbo].[Departments]
(
	[manager_id] ASC
)
WHERE ([manager_id] IS NOT NULL AND [is_deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_TransferReq_Status] ON [dbo].[Transfer_Requests]
(
	[manager_status] ASC,
	[hr_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Learning_Progress] ADD  CONSTRAINT [UQ_User_Material_Class] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[material_id] ASC,
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Class_Enrollments] ADD  CONSTRAINT [UQ_Class_User] UNIQUE NONCLUSTERED 
(
	[class_id] ASC,
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Enrollment_User] ON [dbo].[Class_Enrollments]
(
	[user_id] ASC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Test_Question_Options] ADD  CONSTRAINT [UQ_Test_Option_Order] UNIQUE NONCLUSTERED 
(
	[question_id] ASC,
	[display_order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Test_Question_Options] ADD  CONSTRAINT [UQ_Test_Option_Question] UNIQUE NONCLUSTERED 
(
	[question_id] ASC,
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Test_Options_Question] ON [dbo].[Test_Question_Options]
(
	[question_id] ASC,
	[display_order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Test_Scope] ON [dbo].[Test_Templates]
(
	[department_id] ASC,
	[status] ASC,
	[start_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Questions_Content] ON [dbo].[Test_Questions]
(
	[content_id] ASC,
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Test_Content_Learning_Material] ON [dbo].[Test_Content]
(
	[learning_material_id] ASC
)
WHERE ([learning_material_id] IS NOT NULL AND [is_deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Test_Evaluations] ADD UNIQUE NONCLUSTERED 
(
	[test_assignment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Test_Assignments] ADD  CONSTRAINT [UQ_Test_Assignee] UNIQUE NONCLUSTERED 
(
	[test_template_id] ASC,
	[assignee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Assignment_Owner] ON [dbo].[Test_Assignments]
(
	[assignee_id] ASC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Test_Answer_Question] ON [dbo].[Test_Answer_Options]
(
	[assignment_id] ASC,
	[question_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Roles] ADD UNIQUE NONCLUSTERED 
(
	[role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Users_SingleAdmin] ON [dbo].[Users]
(
	[role_id] ASC
)
WHERE ([role_id]=(1) AND [is_deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Users_SingleManagerPerDept] ON [dbo].[Users]
(
	[department_id] ASC
)
WHERE ([role_id]=(3) AND [is_deleted]=(0) AND [department_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Training_Classes] ADD UNIQUE NONCLUSTERED 
(
	[class_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Class_Dept_Status] ON [dbo].[Training_Classes]
(
	[department_id] ASC,
	[status] ASC,
	[is_deleted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Material_Dept_Type] ON [dbo].[Learning_Materials]
(
	[department_id] ASC,
	[material_type] ASC,
	[is_deleted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Job_Levels] ADD UNIQUE NONCLUSTERED 
(
	[level_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FlashcardDecks] ADD  CONSTRAINT [DF_FlashcardDecks_Type]  DEFAULT ('professional') FOR [deck_type]
GO
ALTER TABLE [dbo].[FlashcardDecks] ADD  CONSTRAINT [DF_FlashcardDecks_CreatedAt]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Positions] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[Positions] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Positions] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[MentorEvaluations] ADD  DEFAULT ('PENDING') FOR [approval_status]
GO
ALTER TABLE [dbo].[MentorEvaluations] ADD  DEFAULT (getdate()) FOR [evaluation_date]
GO
ALTER TABLE [dbo].[Video_Checkpoints] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Video_Question_Answers] ADD  DEFAULT ((1)) FOR [attempt_count]
GO
ALTER TABLE [dbo].[Video_Question_Answers] ADD  DEFAULT (getdate()) FOR [answered_at]
GO
ALTER TABLE [dbo].[Position_Requests] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[Position_Requests] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[MentorAssignments] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[MentorAssignments] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Employee_History] ADD  DEFAULT (getdate()) FOR [change_date]
GO
ALTER TABLE [dbo].[Departments] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[Departments] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Departments] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Transfer_Requests] ADD  DEFAULT ('PENDING') FOR [manager_status]
GO
ALTER TABLE [dbo].[Transfer_Requests] ADD  DEFAULT ('WAITING_MANAGER') FOR [hr_status]
GO
ALTER TABLE [dbo].[Transfer_Requests] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Learning_Progress] ADD  DEFAULT ('NOT_STARTED') FOR [status]
GO
ALTER TABLE [dbo].[Learning_Progress] ADD  DEFAULT (getdate()) FOR [last_accessed_at]
GO
ALTER TABLE [dbo].[Class_Materials] ADD  DEFAULT ((1)) FOR [order_index]
GO
ALTER TABLE [dbo].[Class_Materials] ADD  DEFAULT ((1)) FOR [is_mandatory]
GO
ALTER TABLE [dbo].[Class_Enrollments] ADD  DEFAULT ('MANUAL') FOR [enrollment_type]
GO
ALTER TABLE [dbo].[Class_Enrollments] ADD  DEFAULT ('ENROLLED') FOR [status]
GO
ALTER TABLE [dbo].[Class_Enrollments] ADD  DEFAULT ((0)) FOR [progress_percent]
GO
ALTER TABLE [dbo].[Class_Enrollments] ADD  DEFAULT (getdate()) FOR [enrolled_at]
GO
ALTER TABLE [dbo].[Test_Question_Options] ADD  DEFAULT ((0)) FOR [is_correct]
GO
ALTER TABLE [dbo].[Test_Templates] ADD  CONSTRAINT [DF_Test_Template_Status]  DEFAULT ('published') FOR [status]
GO
ALTER TABLE [dbo].[Test_Templates] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Test_Templates] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Test_Templates] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Test_Questions] ADD  DEFAULT ('single') FOR [question_type]
GO
ALTER TABLE [dbo].[Test_Content] ADD  DEFAULT ('draft') FOR [status]
GO
ALTER TABLE [dbo].[Test_Content] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Test_Content] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Test_Evaluations] ADD  DEFAULT (sysutcdatetime()) FOR [evaluated_at]
GO
ALTER TABLE [dbo].[Test_Assignments] ADD  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[Test_Assignments] ADD  DEFAULT (sysutcdatetime()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[Test_Assignments] ADD  CONSTRAINT [DF_Test_Assignment_Duration]  DEFAULT ((30)) FOR [duration_minutes]
GO
ALTER TABLE [dbo].[Test_Assignments] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [hire_date]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Training_Classes] ADD  DEFAULT ('OPEN') FOR [status]
GO
ALTER TABLE [dbo].[Training_Classes] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Training_Classes] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Learning_Materials] ADD  DEFAULT ('CULTURE') FOR [scope_type]
GO
ALTER TABLE [dbo].[Learning_Materials] ADD  DEFAULT ((15)) FOR [duration_minutes]
GO
ALTER TABLE [dbo].[Learning_Materials] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[Learning_Materials] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Learning_Materials] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Learning_Materials] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Flashcards]  WITH CHECK ADD  CONSTRAINT [FK_Flashcards_Deck] FOREIGN KEY([deck_id])
REFERENCES [dbo].[FlashcardDecks] ([deck_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Flashcards] CHECK CONSTRAINT [FK_Flashcards_Deck]
GO
ALTER TABLE [dbo].[FlashcardDecks]  WITH CHECK ADD  CONSTRAINT [FK_FlashcardDecks_Position] FOREIGN KEY([position_id])
REFERENCES [dbo].[Positions] ([position_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[FlashcardDecks] CHECK CONSTRAINT [FK_FlashcardDecks_Position]
GO
ALTER TABLE [dbo].[Positions]  WITH CHECK ADD  CONSTRAINT [FK_Positions_Department] FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Positions] CHECK CONSTRAINT [FK_Positions_Department]
GO
ALTER TABLE [dbo].[MentorEvaluations]  WITH CHECK ADD FOREIGN KEY([assignment_id])
REFERENCES [dbo].[MentorAssignments] ([assignment_id])
GO
ALTER TABLE [dbo].[Video_Checkpoints]  WITH CHECK ADD FOREIGN KEY([material_id])
REFERENCES [dbo].[Learning_Materials] ([material_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Video_Question_Answers]  WITH CHECK ADD FOREIGN KEY([checkpoint_id])
REFERENCES [dbo].[Video_Checkpoints] ([checkpoint_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Video_Question_Answers]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Position_Requests]  WITH CHECK ADD FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Position_Requests]  WITH CHECK ADD FOREIGN KEY([manager_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Position_Requests]  WITH CHECK ADD FOREIGN KEY([reviewed_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[MentorAssignments]  WITH CHECK ADD FOREIGN KEY([mentee_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[MentorAssignments]  WITH CHECK ADD FOREIGN KEY([mentor_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[MentorAssignments]  WITH CHECK ADD FOREIGN KEY([position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[Employee_History]  WITH CHECK ADD  CONSTRAINT [FK_EmpHistory_Creator] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Employee_History] CHECK CONSTRAINT [FK_EmpHistory_Creator]
GO
ALTER TABLE [dbo].[Employee_History]  WITH CHECK ADD  CONSTRAINT [FK_EmpHistory_NewDept] FOREIGN KEY([new_department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Employee_History] CHECK CONSTRAINT [FK_EmpHistory_NewDept]
GO
ALTER TABLE [dbo].[Employee_History]  WITH CHECK ADD  CONSTRAINT [FK_EmpHistory_NewPos] FOREIGN KEY([new_position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[Employee_History] CHECK CONSTRAINT [FK_EmpHistory_NewPos]
GO
ALTER TABLE [dbo].[Employee_History]  WITH CHECK ADD  CONSTRAINT [FK_EmpHistory_OldDept] FOREIGN KEY([old_department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Employee_History] CHECK CONSTRAINT [FK_EmpHistory_OldDept]
GO
ALTER TABLE [dbo].[Employee_History]  WITH CHECK ADD  CONSTRAINT [FK_EmpHistory_OldPos] FOREIGN KEY([old_position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[Employee_History] CHECK CONSTRAINT [FK_EmpHistory_OldPos]
GO
ALTER TABLE [dbo].[Employee_History]  WITH CHECK ADD  CONSTRAINT [FK_EmpHistory_User] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Employee_History] CHECK CONSTRAINT [FK_EmpHistory_User]
GO
ALTER TABLE [dbo].[Departments]  WITH CHECK ADD  CONSTRAINT [FK_Departments_Manager] FOREIGN KEY([manager_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Departments] CHECK CONSTRAINT [FK_Departments_Manager]
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([current_department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([current_position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([employee_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([hr_reviewed_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([manager_reviewed_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([target_department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD FOREIGN KEY([target_position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[Learning_Progress]  WITH CHECK ADD FOREIGN KEY([class_id])
REFERENCES [dbo].[Training_Classes] ([class_id])
GO
ALTER TABLE [dbo].[Learning_Progress]  WITH CHECK ADD FOREIGN KEY([material_id])
REFERENCES [dbo].[Learning_Materials] ([material_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Learning_Progress]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Class_Materials]  WITH CHECK ADD FOREIGN KEY([class_id])
REFERENCES [dbo].[Training_Classes] ([class_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Class_Materials]  WITH CHECK ADD FOREIGN KEY([material_id])
REFERENCES [dbo].[Learning_Materials] ([material_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Class_Enrollments]  WITH CHECK ADD FOREIGN KEY([class_id])
REFERENCES [dbo].[Training_Classes] ([class_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Class_Enrollments]  WITH CHECK ADD FOREIGN KEY([enrolled_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Class_Enrollments]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Test_Question_Options]  WITH CHECK ADD FOREIGN KEY([question_id])
REFERENCES [dbo].[Test_Questions] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD FOREIGN KEY([default_content_id])
REFERENCES [dbo].[Test_Content] ([id])
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD  CONSTRAINT [FK_Test_Template_Class] FOREIGN KEY([class_id])
REFERENCES [dbo].[Training_Classes] ([class_id])
GO
ALTER TABLE [dbo].[Test_Templates] CHECK CONSTRAINT [FK_Test_Template_Class]
GO
ALTER TABLE [dbo].[Test_Questions]  WITH CHECK ADD FOREIGN KEY([content_id])
REFERENCES [dbo].[Test_Content] ([id])
GO
ALTER TABLE [dbo].[Test_Content]  WITH CHECK ADD FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Test_Content]  WITH CHECK ADD FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Test_Content]  WITH CHECK ADD  CONSTRAINT [FK_Test_Content_Learning_Material] FOREIGN KEY([learning_material_id])
REFERENCES [dbo].[Learning_Materials] ([material_id])
GO
ALTER TABLE [dbo].[Test_Content] CHECK CONSTRAINT [FK_Test_Content_Learning_Material]
GO
ALTER TABLE [dbo].[Test_Evaluations]  WITH CHECK ADD FOREIGN KEY([evaluator_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Test_Evaluations]  WITH CHECK ADD FOREIGN KEY([test_assignment_id])
REFERENCES [dbo].[Test_Assignments] ([id])
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD FOREIGN KEY([assignee_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD FOREIGN KEY([assigned_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD FOREIGN KEY([content_id])
REFERENCES [dbo].[Test_Content] ([id])
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD FOREIGN KEY([test_template_id])
REFERENCES [dbo].[Test_Templates] ([id])
GO
ALTER TABLE [dbo].[Test_Answer_Options]  WITH CHECK ADD FOREIGN KEY([assignment_id])
REFERENCES [dbo].[Test_Assignments] ([id])
GO
ALTER TABLE [dbo].[Test_Answer_Options]  WITH CHECK ADD FOREIGN KEY([question_id])
REFERENCES [dbo].[Test_Questions] ([id])
GO
ALTER TABLE [dbo].[Test_Answer_Options]  WITH CHECK ADD  CONSTRAINT [FK_Test_Answer_Selected_Option] FOREIGN KEY([question_id], [option_id])
REFERENCES [dbo].[Test_Question_Options] ([question_id], [id])
GO
ALTER TABLE [dbo].[Test_Answer_Options] CHECK CONSTRAINT [FK_Test_Answer_Selected_Option]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Department] FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Department]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_JobLevel] FOREIGN KEY([level_id])
REFERENCES [dbo].[Job_Levels] ([level_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_JobLevel]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Position] FOREIGN KEY([position_id])
REFERENCES [dbo].[Positions] ([position_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Position]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Role] FOREIGN KEY([role_id])
REFERENCES [dbo].[Roles] ([role_id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Role]
GO
ALTER TABLE [dbo].[Training_Classes]  WITH CHECK ADD FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Training_Classes]  WITH CHECK ADD FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Training_Classes]  WITH CHECK ADD FOREIGN KEY([mentor_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Training_Classes]  WITH CHECK ADD FOREIGN KEY([target_position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[Training_Classes]  WITH CHECK ADD FOREIGN KEY([target_level_id])
REFERENCES [dbo].[Job_Levels] ([level_id])
GO
ALTER TABLE [dbo].[Learning_Materials]  WITH CHECK ADD FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Learning_Materials]  WITH CHECK ADD FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([department_id])
GO
ALTER TABLE [dbo].[Learning_Materials]  WITH CHECK ADD FOREIGN KEY([level_id])
REFERENCES [dbo].[Job_Levels] ([level_id])
GO
ALTER TABLE [dbo].[Learning_Materials]  WITH CHECK ADD FOREIGN KEY([position_id])
REFERENCES [dbo].[Positions] ([position_id])
GO
ALTER TABLE [dbo].[FlashcardDecks]  WITH CHECK ADD  CONSTRAINT [CK_FlashcardDecks_CulturePosition] CHECK  (([deck_type]<>'culture' OR [position_id] IS NULL))
GO
ALTER TABLE [dbo].[FlashcardDecks] CHECK CONSTRAINT [CK_FlashcardDecks_CulturePosition]
GO
ALTER TABLE [dbo].[FlashcardDecks]  WITH CHECK ADD  CONSTRAINT [CK_FlashcardDecks_Type] CHECK  (([deck_type]='professional' OR [deck_type]='culture'))
GO
ALTER TABLE [dbo].[FlashcardDecks] CHECK CONSTRAINT [CK_FlashcardDecks_Type]
GO
ALTER TABLE [dbo].[MentorEvaluations]  WITH CHECK ADD CHECK  (([performance_score]>=(1) AND [performance_score]<=(10)))
GO
ALTER TABLE [dbo].[Video_Checkpoints]  WITH CHECK ADD  CONSTRAINT [CK_Checkpoint_Correct] CHECK  (([correct_option]>=(0) AND [correct_option]<=(3)))
GO
ALTER TABLE [dbo].[Video_Checkpoints] CHECK CONSTRAINT [CK_Checkpoint_Correct]
GO
ALTER TABLE [dbo].[Video_Checkpoints]  WITH CHECK ADD  CONSTRAINT [CK_Checkpoint_Time] CHECK  (([stop_time_seconds]>=(0)))
GO
ALTER TABLE [dbo].[Video_Checkpoints] CHECK CONSTRAINT [CK_Checkpoint_Time]
GO
ALTER TABLE [dbo].[Position_Requests]  WITH CHECK ADD CHECK  (([status]='REJECTED' OR [status]='APPROVED' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD CHECK  (([hr_status]='REJECTED' OR [hr_status]='COMPLETED' OR [hr_status]='PENDING' OR [hr_status]='WAITING_MANAGER'))
GO
ALTER TABLE [dbo].[Transfer_Requests]  WITH CHECK ADD CHECK  (([manager_status]='REJECTED' OR [manager_status]='APPROVED' OR [manager_status]='PENDING'))
GO
ALTER TABLE [dbo].[Learning_Progress]  WITH CHECK ADD  CONSTRAINT [CK_Progress_Status] CHECK  (([status]='COMPLETED' OR [status]='IN_PROGRESS' OR [status]='NOT_STARTED'))
GO
ALTER TABLE [dbo].[Learning_Progress] CHECK CONSTRAINT [CK_Progress_Status]
GO
ALTER TABLE [dbo].[Class_Enrollments]  WITH CHECK ADD  CONSTRAINT [CK_Enrollment_Progress] CHECK  (([progress_percent]>=(0) AND [progress_percent]<=(100)))
GO
ALTER TABLE [dbo].[Class_Enrollments] CHECK CONSTRAINT [CK_Enrollment_Progress]
GO
ALTER TABLE [dbo].[Class_Enrollments]  WITH CHECK ADD  CONSTRAINT [CK_Enrollment_Status] CHECK  (([status]='FAILED' OR [status]='PASSED' OR [status]='IN_PROGRESS' OR [status]='ENROLLED'))
GO
ALTER TABLE [dbo].[Class_Enrollments] CHECK CONSTRAINT [CK_Enrollment_Status]
GO
ALTER TABLE [dbo].[Test_Question_Options]  WITH CHECK ADD  CONSTRAINT [CK_Test_Option_Order] CHECK  (([display_order]>(0)))
GO
ALTER TABLE [dbo].[Test_Question_Options] CHECK CONSTRAINT [CK_Test_Option_Order]
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD  CONSTRAINT [CK_Test_Class_Type] CHECK  (([class_id] IS NULL OR [type]='learning'))
GO
ALTER TABLE [dbo].[Test_Templates] CHECK CONSTRAINT [CK_Test_Class_Type]
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD  CONSTRAINT [CK_Test_Status] CHECK  (([status]='closed' OR [status]='published'))
GO
ALTER TABLE [dbo].[Test_Templates] CHECK CONSTRAINT [CK_Test_Status]
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD  CONSTRAINT [CK_Test_Time] CHECK  (([start_time]<[end_time]))
GO
ALTER TABLE [dbo].[Test_Templates] CHECK CONSTRAINT [CK_Test_Time]
GO
ALTER TABLE [dbo].[Test_Templates]  WITH CHECK ADD  CONSTRAINT [CK_Test_Type] CHECK  (([type]='learning' OR [type]='department' OR [type]='culture'))
GO
ALTER TABLE [dbo].[Test_Templates] CHECK CONSTRAINT [CK_Test_Type]
GO
ALTER TABLE [dbo].[Test_Questions]  WITH CHECK ADD  CONSTRAINT [CK_Test_Question_Type] CHECK  (([question_type]='true_false' OR [question_type]='multiple' OR [question_type]='single'))
GO
ALTER TABLE [dbo].[Test_Questions] CHECK CONSTRAINT [CK_Test_Question_Type]
GO
ALTER TABLE [dbo].[Test_Content]  WITH CHECK ADD CHECK  (([status]='ready' OR [status]='draft'))
GO
ALTER TABLE [dbo].[Test_Content]  WITH CHECK ADD CHECK  (([kind]='question' OR [kind]='quiz'))
GO
ALTER TABLE [dbo].[Test_Content]  WITH CHECK ADD  CONSTRAINT [CK_Content_Scope] CHECK  (([type]='learning' OR [type]='department' OR [type]='culture'))
GO
ALTER TABLE [dbo].[Test_Content] CHECK CONSTRAINT [CK_Content_Scope]
GO
ALTER TABLE [dbo].[Test_Evaluations]  WITH CHECK ADD CHECK  (([score]>=(0) AND [score]<=(10)))
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD CHECK  (([quiz_score]>=(0) AND [quiz_score]<=(10)))
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH NOCHECK ADD  CONSTRAINT [CK_Assignment_Duration] CHECK  (([duration_minutes]>=(1) AND [duration_minutes]<=(60)))
GO
ALTER TABLE [dbo].[Test_Assignments] CHECK CONSTRAINT [CK_Assignment_Duration]
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Assignment_Status] CHECK  (([status]='evaluated' OR [status]='submitted' OR [status]='in_progress' OR [status]='pending'))
GO
ALTER TABLE [dbo].[Test_Assignments] CHECK CONSTRAINT [CK_Assignment_Status]
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Submission_File] CHECK  (([file_name] IS NULL AND [file_data] IS NULL OR [file_name] IS NOT NULL AND [file_data] IS NOT NULL AND (datalength([file_data])>=(1) AND datalength([file_data])<=(5242880))))
GO
ALTER TABLE [dbo].[Test_Assignments] CHECK CONSTRAINT [CK_Submission_File]
GO
ALTER TABLE [dbo].[Test_Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Submission_Time] CHECK  ((([status]='in_progress' OR [status]='pending') AND [submitted_at] IS NULL OR ([status]='evaluated' OR [status]='submitted') AND [submitted_at] IS NOT NULL))
GO
ALTER TABLE [dbo].[Test_Assignments] CHECK CONSTRAINT [CK_Submission_Time]
GO
ALTER TABLE [dbo].[Training_Classes]  WITH CHECK ADD  CONSTRAINT [CK_Class_Status] CHECK  (([status]='CANCELLED' OR [status]='COMPLETED' OR [status]='IN_PROGRESS' OR [status]='OPEN'))
GO
ALTER TABLE [dbo].[Training_Classes] CHECK CONSTRAINT [CK_Class_Status]
GO
ALTER TABLE [dbo].[Learning_Materials]  WITH CHECK ADD  CONSTRAINT [CK_Material_Scope] CHECK  (([scope_type]='CULTURE' AND [department_id] IS NULL OR [scope_type]='DEPARTMENT' AND [department_id] IS NOT NULL))
GO
ALTER TABLE [dbo].[Learning_Materials] CHECK CONSTRAINT [CK_Material_Scope]
GO
ALTER TABLE [dbo].[Learning_Materials]  WITH CHECK ADD  CONSTRAINT [CK_Material_Type] CHECK  (([material_type]='VIDEO' OR [material_type]='SLIDE' OR [material_type]='PDF'))
GO
ALTER TABLE [dbo].[Learning_Materials] CHECK CONSTRAINT [CK_Material_Type]
GO
