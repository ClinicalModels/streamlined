CREATE TABLE [dbo].[data_encounter]
(
[enc_key] [int] NOT NULL IDENTITY(1, 1),
[enc_id] [uniqueidentifier] NOT NULL,
[enc_nbr] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[person_id] [uniqueidentifier] NOT NULL,
[location_id] [uniqueidentifier] NULL,
[rendering_provider_id] [uniqueidentifier] NULL,
[created_by_user_id] [int] NOT NULL,
[location_key] [int] NULL,
[provider_key] [int] NULL,
[per_mon_id] [int] NULL,
[enc_creator_key] [int] NULL,
[enc_cr_date] [date] NULL,
[enc_md_date] [date] NULL,
[enc_bill_date] [date] NULL,
[first_mon_date] [date] NULL,
[billable_enc_ct] [int] NOT NULL,
[qual_enc_ct] [int] NOT NULL,
[enc_count] [int] NOT NULL,
[encounter_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[billable_ind] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qualified_ind] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[enc_comp_key] [bigint] NULL,
[enc_comp_key_name] [varchar] (37) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[data_encounter] ADD CONSTRAINT [enc_key_pk] PRIMARY KEY CLUSTERED  ([enc_key]) ON [PRIMARY]
GO
