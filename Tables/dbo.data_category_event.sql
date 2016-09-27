CREATE TABLE [dbo].[data_category_event]
(
[cat_event_key] [int] NOT NULL IDENTITY(1, 1),
[event_id] [uniqueidentifier] NULL,
[category_id] [uniqueidentifier] NOT NULL,
[category_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prevent_appt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[event_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
