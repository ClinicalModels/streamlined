CREATE TABLE [dbo].[data_task_lists]
(
[task_to_user_key] [int] NULL,
[task_from_user_key] [int] NULL,
[mec_rec_nbr] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_timestamp] [date] NULL,
[create_datetime] [datetime] NULL,
[Complete Datetime] [datetime] NOT NULL,
[task_from_user_id] [int] NOT NULL,
[task_to_user_id] [int] NULL,
[HourstoCompeletion] [decimal] (24, 6) NULL,
[DaystoCompeletion] [decimal] (29, 11) NULL,
[Task_completed] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task_Assigned] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task_Read] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task_rejected] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[task_desc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_subj] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Request_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Nbr of active Inbox] [int] NOT NULL,
[provider_key] [int] NULL
) ON [PRIMARY]
GO
