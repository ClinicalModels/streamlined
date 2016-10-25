CREATE TABLE [dbo].[data_enc_appt_status]
(
[enc_appt_comp_key] [bigint] NULL,
[status_appt] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_appt_pcp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_appt_person] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_appt_enc] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_enc_appt] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_enc_billable] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_enc] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_appt_kept] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_cancel_reason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_charges] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_pcpcrossbook] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
