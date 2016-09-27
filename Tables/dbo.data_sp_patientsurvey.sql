CREATE TABLE [dbo].[data_sp_patientsurvey]
(
[EncounterNumber] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConfirmEncounterNumber] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Survey_q1] [float] NULL,
[Survey_q2] [float] NULL,
[Survey_q3] [float] NULL,
[Survey_q4] [float] NULL,
[Survey_q5] [float] NULL,
[Survey_q6] [float] NULL,
[Survey_q7] [float] NULL,
[AdditionalComments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Created] [datetime] NULL,
[Id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
