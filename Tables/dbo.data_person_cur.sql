CREATE TABLE [dbo].[data_person_cur]
(
[per_mon_id] [int] NOT NULL,
[person_key] [int] NOT NULL,
[person_id] [uniqueidentifier] NULL,
[first_mon_date] [date] NULL,
[mh_cur_key] [int] NULL,
[pcp_cur_key] [int] NULL,
[status_cur_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First_enc_age_months] [int] NULL,
[nbr_new_pt] [int] NOT NULL,
[nbr_pt_seen_office_ever] [int] NOT NULL,
[nbr_pt_deceased] [int] NOT NULL,
[age_cur] [int] NULL,
[dob] [date] NULL,
[full_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middle_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_line_1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_line_2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sex] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssn] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[marital_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[race] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ethnicity] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disability_1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disability_2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homeless_status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homeless_count] [int] NULL,
[med_rec_nbr] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chart_create_date] [date] NULL,
[chart_create_user] [varchar] (92) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[person_create_date] [date] NULL,
[person_create_user] [varchar] (92) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hedis_crc_denom] [int] NOT NULL,
[hedis_bc_denom] [int] NOT NULL,
[hedis_crc_num] [int] NOT NULL,
[hedis_bc_num] [int] NOT NULL,
[Address Full] [varchar] (174) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_enc_date] [date] NULL,
[last_appt_date] [date] NULL,
[last_enc_provider] [varchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_appt_provider] [varchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_appt_date] [date] NULL,
[next_appt_provider] [varchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[data_person_cur] ADD CONSTRAINT [person_key_pk32] PRIMARY KEY CLUSTERED  ([person_key]) ON [PRIMARY]
GO
