CREATE TABLE [dbo].[data_person_dp_month]
(
[per_mon_id] [int] NOT NULL,
[person_key] [int] NOT NULL,
[person_id] [uniqueidentifier] NULL,
[first_mon_date] [date] NULL,
[expired_date] [date] NULL,
[hedis_last_colon] [date] NULL,
[hedis_last_sigmoid] [date] NULL,
[hedis_last_fit] [date] NULL,
[hedis_last_mammo] [date] NULL,
[mh_hx_key] [int] NULL,
[pcp_hx_key] [int] NULL,
[status_hx_key] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nbr_pt_deceased_this_month] [int] NOT NULL,
[patient_vintage] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[age_hx] [int] NULL,
[cr_first_office_enc_date] [date] NULL,
[nbr_pt_act_3m] [int] NULL,
[nbr_pt_act_6m] [int] NULL,
[nbr_pt_act_12m] [int] NULL,
[nbr_pt_act_18m] [int] NULL,
[nbr_pt_act_24m] [int] NULL,
[nbr_pt_mh_change] [int] NOT NULL,
[nbr_pt_pcp_change] [int] NOT NULL,
[nbr_pt_never_active] [int] NOT NULL,
[nbr_pt_inact_3m] [int] NOT NULL,
[nbr_pt_inact_6m] [int] NOT NULL,
[nbr_pt_inact_12m] [int] NOT NULL,
[nbr_pt_inact_18m] [int] NOT NULL,
[nbr_pt_inact_24m] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[data_person_dp_month] ADD CONSTRAINT [per_mon_id_pk32] PRIMARY KEY CLUSTERED  ([per_mon_id]) ON [PRIMARY]
GO
