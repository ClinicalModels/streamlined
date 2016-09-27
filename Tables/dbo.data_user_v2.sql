CREATE TABLE [dbo].[data_user_v2]
(
[user_key] [int] NOT NULL IDENTITY(1, 1),
[self_provider_id] [uniqueidentifier] NULL,
[employee_key] [int] NULL,
[user_id] [int] NOT NULL,
[first_name] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (33) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ng_data] [int] NOT NULL
) ON [PRIMARY]
GO
