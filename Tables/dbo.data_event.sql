CREATE TABLE [dbo].[data_event]
(
[event_key] [int] NOT NULL IDENTITY(1, 1),
[event_id] [uniqueidentifier] NOT NULL,
[event_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
