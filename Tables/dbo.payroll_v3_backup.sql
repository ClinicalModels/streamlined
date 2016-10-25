CREATE TABLE [dbo].[payroll_v3_backup]
(
[Home Cost Number - Check] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home Cost Number Desc - Check] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cost Number Worked In] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cost Number Worked In Desc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home Department - Check] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home Department Desc - Check] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hire Source] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hire Source Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hire Date] [date] NULL,
[Rehire Date] [date] NULL,
[Rehire Status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rehire Status Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Termination Date] [date] NULL,
[Termination Reason] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Termination Reason Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manager First Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manager Last Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manager ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Current Status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[File Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Job Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payroll First Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payroll Last Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payroll Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Birth Date] [date] NULL,
[Gender] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EEO Ethnic Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip/Postal Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hourly Rate (001)] [numeric] (38, 4) NULL,
[Rate Amount] [numeric] (38, 4) NULL,
[Rate Type Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Annual Salary] [numeric] (38, 4) NULL,
[Data Control] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTE] [numeric] (38, 4) NULL,
[Pay Date] [date] NULL,
[Period Beginning Date] [date] NULL,
[Period End Date - Check] [date] NULL,
[Standard Hours] [numeric] (38, 4) NULL,
[Regular Hours] [numeric] (38, 4) NULL,
[Overtime Hours] [numeric] (38, 4) NULL,
[All Other Coded Hours] [numeric] (38, 4) NULL,
[Regular Earnings] [numeric] (38, 4) NULL,
[Other Earnings] [numeric] (38, 4) NULL,
[Overtime Earnings] [numeric] (38, 4) NULL,
[Net Pay] [numeric] (38, 4) NULL,
[Gross Pay] [numeric] (38, 4) NULL,
[_Hours Coded1] [numeric] (38, 4) NULL,
[_Hours Coded2] [numeric] (38, 4) NULL,
[_Hours Coded3] [numeric] (38, 4) NULL,
[_Hours Coded4] [numeric] (38, 4) NULL,
[_Hours Coded5] [numeric] (38, 4) NULL,
[_Hours Coded6] [numeric] (38, 4) NULL,
[_Hours Coded7] [numeric] (38, 4) NULL,
[_Hours Coded8] [numeric] (38, 4) NULL,
[_Hours Coded9] [numeric] (38, 4) NULL,
[_Hours Coded10] [numeric] (38, 4) NULL,
[_Hours Coded11] [numeric] (38, 4) NULL,
[_Hours Coded12] [numeric] (38, 4) NULL,
[_Hours Coded13] [numeric] (38, 4) NULL,
[_Hours Coded14] [numeric] (38, 4) NULL,
[_Hours Coded15] [numeric] (38, 4) NULL,
[_Hours Coded16] [numeric] (38, 4) NULL,
[_Hours Coded17] [numeric] (38, 4) NULL,
[_Hours Coded18] [numeric] (38, 4) NULL,
[_Hours Coded19] [numeric] (38, 4) NULL,
[_Hours Coded20] [numeric] (38, 4) NULL,
[_Hours Coded21] [numeric] (38, 4) NULL,
[_Hours Coded22] [numeric] (38, 4) NULL,
[_Hours Coded23] [numeric] (38, 4) NULL,
[_Hours Coded24] [numeric] (38, 4) NULL,
[_Hours Coded25] [numeric] (38, 4) NULL,
[_Hours Coded26] [numeric] (38, 4) NULL,
[_Hours Coded27] [numeric] (38, 4) NULL,
[_Hours Coded28] [numeric] (38, 4) NULL,
[_Hours Coded29] [numeric] (38, 4) NULL,
[_Hours Coded30] [numeric] (38, 4) NULL,
[_Hours Coded31] [numeric] (38, 4) NULL,
[_Hours Coded32] [numeric] (38, 4) NULL,
[_Hours Coded33] [numeric] (38, 4) NULL,
[_Earnings Coded1] [numeric] (38, 4) NULL,
[_Earnings Coded2] [numeric] (38, 4) NULL,
[_Earnings Coded3] [numeric] (38, 4) NULL,
[_Earnings Coded4] [numeric] (38, 4) NULL,
[_Earnings Coded5] [numeric] (38, 4) NULL,
[_Earnings Coded6] [numeric] (38, 4) NULL,
[_Earnings Coded7] [numeric] (38, 4) NULL,
[_Earnings Coded8] [numeric] (38, 4) NULL,
[_Earnings Coded9] [numeric] (38, 4) NULL,
[_Earnings Coded10] [numeric] (38, 4) NULL,
[_Earnings Coded11] [numeric] (38, 4) NULL,
[_Earnings Coded12] [numeric] (38, 4) NULL,
[_Earnings Coded13] [numeric] (38, 4) NULL,
[_Earnings Coded14] [numeric] (38, 4) NULL,
[_Earnings Coded15] [numeric] (38, 4) NULL,
[_Earnings Coded16] [numeric] (38, 4) NULL,
[_Earnings Coded17] [numeric] (38, 4) NULL,
[_Earnings Coded18] [numeric] (38, 4) NULL,
[_Earnings Coded19] [numeric] (38, 4) NULL,
[_Earnings Coded20] [numeric] (38, 4) NULL,
[_Earnings Coded21] [numeric] (38, 4) NULL,
[_Earnings Coded22] [numeric] (38, 4) NULL,
[_Earnings Coded23] [numeric] (38, 4) NULL,
[_Earnings Coded24] [numeric] (38, 4) NULL,
[_Earnings Coded25] [numeric] (38, 4) NULL,
[_Earnings Coded26] [numeric] (38, 4) NULL,
[_Earnings Coded27] [numeric] (38, 4) NULL,
[_Earnings Coded28] [numeric] (38, 4) NULL,
[_Earnings Coded29] [numeric] (38, 4) NULL,
[_Earnings Coded30] [numeric] (38, 4) NULL,
[_Earnings Coded31] [numeric] (38, 4) NULL,
[_Earnings Coded32] [numeric] (38, 4) NULL,
[_Earnings Coded33] [numeric] (38, 4) NULL,
[_Earnings Coded34] [numeric] (38, 4) NULL,
[_Earnings Coded35] [numeric] (38, 4) NULL,
[_Earnings Coded36] [numeric] (38, 4) NULL,
[_Earnings Coded37] [numeric] (38, 4) NULL,
[_Earnings Coded38] [numeric] (38, 4) NULL,
[_Earnings Coded39] [numeric] (38, 4) NULL,
[_Earnings Coded40] [numeric] (38, 4) NULL,
[_Earnings Coded41] [numeric] (38, 4) NULL,
[_Earnings Coded42] [numeric] (38, 4) NULL,
[_Earnings Coded43] [numeric] (38, 4) NULL,
[_Earnings Coded44] [numeric] (38, 4) NULL,
[_Earnings Coded45] [numeric] (38, 4) NULL,
[_Earnings Coded46] [numeric] (38, 4) NULL,
[_Earnings Coded47] [numeric] (38, 4) NULL,
[_Earnings Coded48] [numeric] (38, 4) NULL,
[_Earnings Coded49] [numeric] (38, 4) NULL,
[_Earnings Coded50] [numeric] (38, 4) NULL,
[_Earnings Coded51] [numeric] (38, 4) NULL,
[_Earnings Coded52] [numeric] (38, 4) NULL,
[_Earnings Coded53] [numeric] (38, 4) NULL,
[_Earnings Coded54] [numeric] (38, 4) NULL,
[_Earnings Coded55] [numeric] (38, 4) NULL,
[_Earnings Coded56] [numeric] (38, 4) NULL,
[_Earnings Coded57] [numeric] (38, 4) NULL,
[_Earnings Coded58] [numeric] (38, 4) NULL,
[_Earnings Coded59] [numeric] (38, 4) NULL,
[_To_Date Allowed1] [numeric] (38, 4) NULL,
[_To_Date Allowed2] [numeric] (38, 4) NULL,
[_To_Date Allowed3] [numeric] (38, 4) NULL,
[_To_Date Allowed4] [numeric] (38, 4) NULL,
[_To_Date Allowed5] [numeric] (38, 4) NULL,
[_To_Date Taken1] [numeric] (38, 4) NULL,
[_To_Date Taken2] [numeric] (38, 4) NULL,
[_To_Date Taken3] [numeric] (38, 4) NULL,
[_To_Date Taken4] [numeric] (38, 4) NULL,
[_To_Date Taken5] [numeric] (38, 4) NULL
) ON [PRIMARY]
GO