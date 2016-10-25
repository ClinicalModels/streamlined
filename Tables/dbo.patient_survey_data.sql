CREATE TABLE [dbo].[patient_survey_data]
(
[EncounterNumber] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_1] [int] NULL,
[c_2] [int] NULL,
[c_3] [int] NULL,
[c_4] [int] NULL,
[c_5] [int] NULL,
[c_6] [int] NULL,
[Created] [datetime] NULL,
[c_7] [int] NULL,
[EncounterNumberConfirm] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalComments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Id] [int] NULL,
[provider_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
