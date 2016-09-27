CREATE TABLE [dbo].[data_provider]
(
[provider_key] [int] NOT NULL IDENTITY(1, 1),
[provider_id] [uniqueidentifier] NOT NULL,
[employee_key] [int] NULL,
[role_status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[first_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[provider_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName_cleaned] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName_cleaned] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[degree] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delete_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active_3m_provider] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_loc_3m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_3ms_provider] [varchar] (54) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[secondary_loc_3m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_6m_provider] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_loc_6m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_12m_provider] [varchar] (37) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_loc_12m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_key] [int] NULL,
[user_id] [int] NULL,
[rownum] [bigint] NULL
) ON [PRIMARY]
GO
