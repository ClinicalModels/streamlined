CREATE TABLE [dbo].[data_vital_signs]
(
[vital_signs_key] [int] NOT NULL IDENTITY(1, 1),
[encounterID] [uniqueidentifier] NULL,
[person_id] [uniqueidentifier] NULL,
[create_timestamp] [date] NULL,
[BP_date] [date] NULL,
[Date of Measurement] [date] NULL,
[Datetime of Measurement] [datetime] NULL,
[Recency] [int] NOT NULL,
[RecencyDay] [int] NOT NULL,
[RecencyAllTime] [int] NOT NULL,
[person_key] [int] NULL,
[per_mon_id] [int] NULL,
[first_mon_date] [date] NULL,
[enc_appt_key] [int] NULL,
[ng_data] [int] NULL,
[Type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [numeric] (18, 0) NULL,
[bp_sys] [int] NULL,
[bp_dia] [int] NULL
) ON [PRIMARY]
GO
