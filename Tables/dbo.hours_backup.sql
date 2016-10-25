CREATE TABLE [dbo].[hours_backup]
(
[Company Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Grant] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Worked Department] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[In time] [datetime] NULL,
[Out time] [datetime] NULL,
[Out Punch Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hours Timecard] [float] NULL,
[Earnings Code Timecard] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Employee ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pay Date] [datetime] NULL,
[Earnings Code Payroll] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hours Payroll] [float] NULL,
[Dollars] [float] NULL,
[Amount] [float] NULL,
[Rate] [float] NULL
) ON [PRIMARY]
GO
