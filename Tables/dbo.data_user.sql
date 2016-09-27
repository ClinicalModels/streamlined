CREATE TABLE [dbo].[data_user]
(
[user_key] [int] NOT NULL IDENTITY(1, 1),
[user_id] [int] NULL,
[provider_id] [uniqueidentifier] NULL,
[resource_id] [uniqueidentifier] NULL,
[role_status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[first_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[provider_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName_cleaned] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName_cleaned] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resource_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[degree] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delete_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_3m_provider] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_loc_3m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_3ms_provider] [varchar] (54) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[secondary_loc_3m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_6m_provider] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_loc_6m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_12m_provider] [varchar] (37) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_loc_12m_provider] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hr_employee_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hr_job_title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hr_location_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hr_location_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_key] [int] NULL,
[unique_provider_id_flag] [bigint] NULL,
[unique_resource_id_flag] [bigint] NULL,
[unique_user_id_flag] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[data_user] ADD CONSTRAINT [user_key_pk] PRIMARY KEY CLUSTERED  ([user_key]) ON [PRIMARY]
GO
