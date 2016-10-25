CREATE TABLE [dbo].[data_dx]
(
[dx_key] [int] NOT NULL IDENTITY(1, 1),
[enc_id] [uniqueidentifier] NULL,
[person_id] [uniqueidentifier] NOT NULL,
[diagnosis_code_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[diag_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diag_full_name] [varchar] (268) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chronic_ind] [int] NOT NULL,
[dx_status] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hedis_crc_exclude] [int] NULL
) ON [PRIMARY]
GO
