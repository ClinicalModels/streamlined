SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_employee_payroll_v2]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        IF OBJECT_ID('dwh.data_employee_payroll_v2') IS NOT NULL
            DROP TABLE dwh.data_employee_payroll_v2;


--- **DQ** , Need to create a routine that assigns missing homecost number worked in by file number for new hires to the cost number that is inputted in their subsequent payrolls for new hires
--Also noted that we are dropping FTE for internal transfers on rehire payrol (first) they do not get a cost number worked in.
--The Rehire logic is they get a term date and a rehire date, during transition it looks like cost number worked in is dropped
--The internal transfers are not counted as terms because the payroll continues (No change to file number)
--We could create an internal transfer FTE.  Same logic as termination except wouldn't be last term but no last row requirement.  Would instead use rehire date in
--as tight window (<14 days) to grab that payroll as a flag for internal transfer.
        SELECT 


--Fix missing cost numbers by using LAG() to pull in most recent existing cost number based on pay date
                CASE WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 1) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 1) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 2) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 2) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 3) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 3) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 4) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 4) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 5) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 5) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 6) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 6) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 7) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 7) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 8) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 8) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 9) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 9) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     WHEN [Cost Number Worked In] = ''
                          AND LAG([Cost Number Worked In], 10) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) != ''
                     THEN LAG([Cost Number Worked In], 10) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC )
                     ELSE [Cost Number Worked In]
                END 
					AS [Cost Number Worked In] ,

                [Home Cost Number - Check] ,
                [Home Cost Number Desc - Check] ,
                [Cost Number Worked In Desc] ,
                [Home Department - Check] ,
                [Home Department Desc - Check] ,
                Location ,
                [Location Code] ,
                [Hire Source] ,
                [Hire Source Code] ,
                [Hire Date] ,
                [Rehire Date] ,
                [Rehire Status] ,
                [Rehire Status Code] ,
                [Termination Date] ,
                [Termination Reason] ,
                [Termination Reason Code] ,
                [Manager First Name] ,
                [Manager Last Name] ,
                [Manager ID] ,
                [Current Status] ,
                [File Number] ,
                [Job Title] ,
                [Payroll First Name] ,
                [Payroll Last Name] ,
                [Payroll Name] ,
                [Birth Date] ,
                Gender ,
                [EEO Ethnic Code] ,
                [Zip/Postal Code] ,
                [Hourly Rate (001)] ,
                [Rate Amount] ,
                [Rate Type Code] ,
                [Annual Salary] ,
                [Data Control] ,
                FTE ,
                [Pay Date] ,
                [Period Beginning Date] ,
                [Period End Date - Check] ,
                [Standard Hours] ,
                [Regular Hours] ,
                [Overtime Hours] ,
                [All Other Coded Hours] ,
                [Regular Earnings] ,
                [Other Earnings] ,
                [Overtime Earnings] ,
                [Net Pay] ,
                [Gross Pay] ,
                [_Hours Coded1] ,
                [_Hours Coded2] ,
                [_Hours Coded3] ,
                [_Hours Coded4] ,
                [_Hours Coded5] ,
                [_Hours Coded6] ,
                [_Hours Coded7] ,
                [_Hours Coded8] ,
                [_Hours Coded9] ,
                [_Hours Coded10] ,
                [_Hours Coded11] ,
                [_Hours Coded12] ,
                [_Hours Coded13] ,
                [_Hours Coded14] ,
                [_Hours Coded15] ,
                [_Hours Coded16] ,
                [_Hours Coded17] ,
                [_Hours Coded18] ,
                [_Hours Coded19] ,
                [_Hours Coded20] ,
                [_Hours Coded21] ,
                [_Hours Coded22] ,
                [_Hours Coded23] ,
                [_Hours Coded24] ,
                [_Hours Coded25] ,
                [_Hours Coded26] ,
                [_Hours Coded27] ,
                [_Hours Coded28] ,
                [_Hours Coded29] ,
                [_Hours Coded30] ,
                [_Hours Coded31] ,
                [_Hours Coded32] ,
                [_Hours Coded33] ,
                [_Earnings Coded1] ,
                [_Earnings Coded2] ,
                [_Earnings Coded3] ,
                [_Earnings Coded4] ,
                [_Earnings Coded5] ,
                [_Earnings Coded6] ,
                [_Earnings Coded7] ,
                [_Earnings Coded8] ,
                [_Earnings Coded9] ,
                [_Earnings Coded10] ,
                [_Earnings Coded11] ,
                [_Earnings Coded12] ,
                [_Earnings Coded13] ,
                [_Earnings Coded14] ,
                [_Earnings Coded15] ,
                [_Earnings Coded16] ,
                [_Earnings Coded17] ,
                [_Earnings Coded18] ,
                [_Earnings Coded19] ,
                [_Earnings Coded20] ,
                [_Earnings Coded21] ,
                [_Earnings Coded22] ,
                [_Earnings Coded23] ,
                [_Earnings Coded24] ,
                [_Earnings Coded25] ,
                [_Earnings Coded26] ,
                [_Earnings Coded27] ,
                [_Earnings Coded28] ,
                [_Earnings Coded29] ,
                [_Earnings Coded30] ,
                [_Earnings Coded31] ,
                [_Earnings Coded32] ,
                [_Earnings Coded33] ,
                [_Earnings Coded34] ,
                [_Earnings Coded35] ,
                [_Earnings Coded36] ,
                [_Earnings Coded37] ,
                [_Earnings Coded38] ,
                [_Earnings Coded39] ,
                [_Earnings Coded40] ,
                [_Earnings Coded41] ,
                [_Earnings Coded42] ,
                [_Earnings Coded43] ,
                [_Earnings Coded44] ,
                [_Earnings Coded45] ,
                [_Earnings Coded46] ,
                [_Earnings Coded47] ,
                [_Earnings Coded48] ,
                [_Earnings Coded49] ,
                [_Earnings Coded50] ,
                [_Earnings Coded51] ,
                [_Earnings Coded52] ,
                [_Earnings Coded53] ,
                [_Earnings Coded54] ,
                [_Earnings Coded55] ,
                [_Earnings Coded56] ,
                [_Earnings Coded57] ,
                [_Earnings Coded58] ,
                [_Earnings Coded59] ,
                [_To_Date Allowed1] ,
                [_To_Date Allowed2] ,
                [_To_Date Allowed3] ,
                [_To_Date Allowed4] ,
                [_To_Date Allowed5] ,
                [_To_Date Taken1] ,
                [_To_Date Taken2] ,
                [_To_Date Taken3] ,
                [_To_Date Taken4] ,
                [_To_Date Taken5]
        INTO    #temp1
        FROM    [Prod_Ghost].[etl].[data_adp_payroll_v3]; 



        CREATE TABLE #test
            (
              [Home Cost Number - Check] [NVARCHAR](255) NULL ,
              [Home Cost Number Desc - Check] [NVARCHAR](255) NULL ,
              [Cost Number Worked In] [NVARCHAR](255) NULL ,
              [Cost Number Worked In Desc] [NVARCHAR](255) NULL ,
              [Home Department - Check] [NVARCHAR](255) NULL ,
              [Home Department Desc - Check] [NVARCHAR](255) NULL ,
              [Location] [NVARCHAR](255) NULL ,
              [Location Code] [NVARCHAR](255) NULL ,
              [Hire Source] [NVARCHAR](255) NULL ,
              [Hire Source Code] [NVARCHAR](255) NULL ,
              [Hire Date] [DATE] NULL ,
              [Rehire Date] [DATE] NULL ,
              [Rehire Status] [NVARCHAR](255) NULL ,
              [Rehire Status Code] [NVARCHAR](255) NULL ,
              [Termination Date] [DATE] NULL ,
              [Termination Reason] [NVARCHAR](255) NULL ,
              [Termination Reason Code] [NVARCHAR](255) NULL ,
              [Manager First Name] [NVARCHAR](255) NULL ,
              [Manager Last Name] [NVARCHAR](255) NULL ,
              [Manager ID] [NVARCHAR](255) NULL ,
              [Current Status] [NVARCHAR](255) NULL ,
              [File Number] [NVARCHAR](255) NULL ,
              [Job Title] [NVARCHAR](255) NULL ,
              [Payroll First Name] [NVARCHAR](255) NULL ,
              [Payroll Last Name] [NVARCHAR](255) NULL ,
              [Payroll Name] [NVARCHAR](255) NULL ,
              [Birth Date] [DATE] NULL ,
              [Gender] [NVARCHAR](255) NULL ,
              [EEO Ethnic Code] [NVARCHAR](255) NULL ,
              [Zip/Postal Code] [NVARCHAR](255) NULL ,
              [Hourly Rate (001)] [DECIMAL](38, 4) NULL ,
              [Rate Amount] [DECIMAL](38, 4) NULL ,
              [Rate Type Code] [NVARCHAR](255) NULL ,
              [Annual Salary] [DECIMAL](38, 4) NULL ,
              [Data Control] [NVARCHAR](255) NULL ,
              [FTE] [DECIMAL](38, 4) NULL ,
              [Pay Date] [DATE] NULL ,
              [Period Beginning Date] [DATE] NULL ,
              [Period End Date - Check] [DATE] NULL ,
              [Standard Hours] [DECIMAL](38, 6) NULL ,
              [Regular Hours] [DECIMAL](38, 6) NULL ,
              [Overtime Hours] [DECIMAL](38, 6) NULL ,
              [All Other Coded Hours] [DECIMAL](38, 6) NULL ,
              [Regular Earnings] [DECIMAL](38, 6) NULL ,
              [Other Earnings] [DECIMAL](38, 6) NULL ,
              [Overtime Earnings] [DECIMAL](38, 6) NULL ,
              [Net Pay] [DECIMAL](38, 6) NULL ,
              [Gross Pay] [DECIMAL](38, 6) NULL ,
              [_Hours Coded1] [DECIMAL](38, 6) NULL ,
              [_Hours Coded2] [DECIMAL](38, 6) NULL ,
              [_Hours Coded3] [DECIMAL](38, 6) NULL ,
              [_Hours Coded4] [DECIMAL](38, 6) NULL ,
              [_Hours Coded5] [DECIMAL](38, 6) NULL ,
              [_Hours Coded6] [DECIMAL](38, 6) NULL ,
              [_Hours Coded7] [DECIMAL](38, 6) NULL ,
              [_Hours Coded8] [DECIMAL](38, 6) NULL ,
              [_Hours Coded9] [DECIMAL](38, 6) NULL ,
              [_Hours Coded10] [DECIMAL](38, 6) NULL ,
              [_Hours Coded11] [DECIMAL](38, 6) NULL ,
              [_Hours Coded12] [DECIMAL](38, 6) NULL ,
              [_Hours Coded13] [DECIMAL](38, 6) NULL ,
              [_Hours Coded14] [DECIMAL](38, 6) NULL ,
              [_Hours Coded15] [DECIMAL](38, 6) NULL ,
              [_Hours Coded16] [DECIMAL](38, 6) NULL ,
              [_Hours Coded17] [DECIMAL](38, 6) NULL ,
              [_Hours Coded18] [DECIMAL](38, 6) NULL ,
              [_Hours Coded19] [DECIMAL](38, 6) NULL ,
              [_Hours Coded20] [DECIMAL](38, 6) NULL ,
              [_Hours Coded21] [DECIMAL](38, 6) NULL ,
              [_Hours Coded22] [DECIMAL](38, 6) NULL ,
              [_Hours Coded23] [DECIMAL](38, 6) NULL ,
              [_Hours Coded24] [DECIMAL](38, 6) NULL ,
              [_Hours Coded25] [DECIMAL](38, 6) NULL ,
              [_Hours Coded26] [DECIMAL](38, 6) NULL ,
              [_Hours Coded27] [DECIMAL](38, 6) NULL ,
              [_Hours Coded28] [DECIMAL](38, 6) NULL ,
              [_Hours Coded29] [DECIMAL](38, 6) NULL ,
              [_Hours Coded30] [DECIMAL](38, 6) NULL ,
              [_Hours Coded31] [DECIMAL](38, 6) NULL ,
              [_Hours Coded32] [DECIMAL](38, 6) NULL ,
              [_Hours Coded33] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded1] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded2] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded3] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded4] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded5] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded6] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded7] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded8] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded9] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded10] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded11] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded12] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded13] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded14] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded15] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded16] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded17] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded18] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded19] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded20] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded21] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded22] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded23] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded24] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded25] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded26] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded27] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded28] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded29] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded30] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded31] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded32] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded33] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded34] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded35] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded36] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded37] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded38] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded39] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded40] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded41] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded42] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded43] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded44] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded45] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded46] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded47] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded48] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded49] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded50] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded51] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded52] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded53] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded54] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded55] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded56] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded57] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded58] [DECIMAL](38, 6) NULL ,
              [_Earnings Coded59] [DECIMAL](38, 6) NULL ,
              [_To_Date Allowed1] [DECIMAL](38, 4) NULL ,
              [_To_Date Allowed2] [DECIMAL](38, 4) NULL ,
              [_To_Date Allowed3] [DECIMAL](38, 4) NULL ,
              [_To_Date Allowed4] [DECIMAL](38, 4) NULL ,
              [_To_Date Allowed5] [DECIMAL](38, 4) NULL ,
              [_To_Date Taken1] [DECIMAL](38, 4) NULL ,
              [_To_Date Taken2] [DECIMAL](38, 4) NULL ,
              [_To_Date Taken3] [DECIMAL](38, 4) NULL ,
              [_To_Date Taken4] [DECIMAL](38, 4) NULL ,
              [_To_Date Taken5] [DECIMAL](38, 4) NULL
            )
        ON  [PRIMARY];


--DROP TABLE #test

        DECLARE @dt_start DATE ,
            @dt_end DATE ,
            @dt DATE;
  
		--Set end date based on most recent payroll date available
        SET @dt_end = ( SELECT  MAX([Pay Date])
                        FROM    [Prod_Ghost].[etl].[data_adp_payroll_v3]
                        WHERE   [Pay Date] != CAST('1900-01-01' AS DATE)
                      );

 

		
        SET @dt_start = DATEADD(d, -34, ( SELECT    MIN([Pay Date])
                                          FROM      [Prod_Ghost].[etl].[data_adp_payroll_v3]
                                          WHERE     [Pay Date] != CAST('1900-01-01' AS DATE)
                                        ));


        SET @dt = @dt_start;
--  SET @dt_end = CAST('20121030' AS DATE) 

        WHILE ( @dt <= @dt_end )  -- LOOP UNTIL END DATE
            BEGIN 






                INSERT  INTO #test
                        SELECT  [Home Cost Number - Check] ,
                                [Home Cost Number Desc - Check] ,
                                [Cost Number Worked In] ,
                                [Cost Number Worked In Desc] ,
                                [Home Department - Check] ,
                                [Home Department Desc - Check] ,
                                Location ,
                                [Location Code] ,
                                [Hire Source] ,
                                [Hire Source Code] ,
                                [Hire Date] ,
                                [Rehire Date] ,
                                [Rehire Status] ,
                                [Rehire Status Code] ,
                                [Termination Date] ,
                                [Termination Reason] ,
                                [Termination Reason Code] ,
                                [Manager First Name] ,
                                [Manager Last Name] ,
                                [Manager ID] ,
                                [Current Status] ,
                                [File Number] ,
                                [Job Title] ,
                                [Payroll First Name] ,
                                [Payroll Last Name] ,
                                [Payroll Name] ,
                                [Birth Date] ,
                                Gender ,
                                [EEO Ethnic Code] ,
                                [Zip/Postal Code] ,
                                [Hourly Rate (001)] ,
                                [Rate Amount] ,
                                [Rate Type Code] ,
                                [Annual Salary] ,
                                [Data Control] ,
                                FTE ,
                                CAST(@dt AS DATE) AS [Pay Date] ,
                                [Period Beginning Date] ,
                                [Period End Date - Check] ,
                                [Standard Hours] [Standard Hours] ,
                                [Regular Hours] / 10 [Regular Hours] ,
                                [Overtime Hours] / 10 [Overtime Hours] ,
                                [All Other Coded Hours] / 10 [All Other Coded Hours] ,
                                [Regular Earnings] / 10 [Regular Earnings] ,
                                [Other Earnings] / 10 [Other Earnings] ,
                                [Overtime Earnings] / 10 [Overtime Earnings] ,
                                [Net Pay] / 10 [Net Pay] ,
                                [Gross Pay] / 10 [Gross Pay] ,
                                [_Hours Coded1] / 10 [_Hours Coded1] ,
                                [_Hours Coded2] / 10 [_Hours Coded2] ,
                                [_Hours Coded3] / 10 [_Hours Coded3] ,
                                [_Hours Coded4] / 10 [_Hours Coded4] ,
                                [_Hours Coded5] / 10 [_Hours Coded5] ,
                                [_Hours Coded6] / 10 [_Hours Coded6] ,
                                [_Hours Coded7] / 10 [_Hours Coded7] ,
                                [_Hours Coded8] / 10 [_Hours Coded8] ,
                                [_Hours Coded9] / 10 [_Hours Coded9] ,
                                [_Hours Coded10] / 10 [_Hours Coded10] ,
                                [_Hours Coded11] / 10 [_Hours Coded11] ,
                                [_Hours Coded12] / 10 [_Hours Coded12] ,
                                [_Hours Coded13] / 10 [_Hours Coded13] ,
                                [_Hours Coded14] / 10 [_Hours Coded14] ,
                                [_Hours Coded15] / 10 [_Hours Coded15] ,
                                [_Hours Coded16] / 10 [_Hours Coded16] ,
                                [_Hours Coded17] / 10 [_Hours Coded17] ,
                                [_Hours Coded18] / 10 [_Hours Coded18] ,
                                [_Hours Coded19] / 10 [_Hours Coded19] ,
                                [_Hours Coded20] / 10 [_Hours Coded20] ,
                                [_Hours Coded21] / 10 [_Hours Coded21] ,
                                [_Hours Coded22] / 10 [_Hours Coded22] ,
                                [_Hours Coded23] / 10 [_Hours Coded23] ,
                                [_Hours Coded24] / 10 [_Hours Coded24] ,
                                [_Hours Coded25] / 10 [_Hours Coded25] ,
                                [_Hours Coded26] / 10 [_Hours Coded26] ,
                                [_Hours Coded27] / 10 [_Hours Coded27] ,
                                [_Hours Coded28] / 10 [_Hours Coded28] ,
                                [_Hours Coded29] / 10 [_Hours Coded29] ,
                                [_Hours Coded30] / 10 [_Hours Coded30] ,
                                [_Hours Coded31] / 10 [_Hours Coded31] ,
                                [_Hours Coded32] / 10 [_Hours Coded32] ,
                                [_Hours Coded33] / 10 [_Hours Coded33] ,
                                [_Earnings Coded1] / 10 [_Earnings Coded1] ,
                                [_Earnings Coded2] / 10 [_Earnings Coded2] ,
                                [_Earnings Coded3] / 10 [_Earnings Coded3] ,
                                [_Earnings Coded4] / 10 [_Earnings Coded4] ,
                                [_Earnings Coded5] / 10 [_Earnings Coded5] ,
                                [_Earnings Coded6] / 10 [_Earnings Coded6] ,
                                [_Earnings Coded7] / 10 [_Earnings Coded7] ,
                                [_Earnings Coded8] / 10 [_Earnings Coded8] ,
                                [_Earnings Coded9] / 10 [_Earnings Coded9] ,
                                [_Earnings Coded10] / 10 [_Earnings Coded10] ,
                                [_Earnings Coded11] / 10 [_Earnings Coded11] ,
                                [_Earnings Coded12] / 10 [_Earnings Coded12] ,
                                [_Earnings Coded13] / 10 [_Earnings Coded13] ,
                                [_Earnings Coded14] / 10 [_Earnings Coded14] ,
                                [_Earnings Coded15] / 10 [_Earnings Coded15] ,
                                [_Earnings Coded16] / 10 [_Earnings Coded16] ,
                                [_Earnings Coded17] / 10 [_Earnings Coded17] ,
                                [_Earnings Coded18] / 10 [_Earnings Coded18] ,
                                [_Earnings Coded19] / 10 [_Earnings Coded19] ,
                                [_Earnings Coded20] / 10 [_Earnings Coded20] ,
                                [_Earnings Coded21] / 10 [_Earnings Coded21] ,
                                [_Earnings Coded22] / 10 [_Earnings Coded22] ,
                                [_Earnings Coded23] / 10 [_Earnings Coded23] ,
                                [_Earnings Coded24] / 10 [_Earnings Coded24] ,
                                [_Earnings Coded25] / 10 [_Earnings Coded25] ,
                                [_Earnings Coded26] / 10 [_Earnings Coded26] ,
                                [_Earnings Coded27] / 10 [_Earnings Coded27] ,
                                [_Earnings Coded28] / 10 [_Earnings Coded28] ,
                                [_Earnings Coded29] / 10 [_Earnings Coded29] ,
                                [_Earnings Coded30] / 10 [_Earnings Coded30] ,
                                [_Earnings Coded31] / 10 [_Earnings Coded31] ,
                                [_Earnings Coded32] / 10 [_Earnings Coded32] ,
                                [_Earnings Coded33] / 10 [_Earnings Coded33] ,
                                [_Earnings Coded34] / 10 [_Earnings Coded34] ,
                                [_Earnings Coded35] / 10 [_Earnings Coded35] ,
                                [_Earnings Coded36] / 10 [_Earnings Coded36] ,
                                [_Earnings Coded37] / 10 [_Earnings Coded37] ,
                                [_Earnings Coded38] / 10 [_Earnings Coded38] ,
                                [_Earnings Coded39] / 10 [_Earnings Coded39] ,
                                [_Earnings Coded40] / 10 [_Earnings Coded40] ,
                                [_Earnings Coded41] / 10 [_Earnings Coded41] ,
                                [_Earnings Coded42] / 10 [_Earnings Coded42] ,
                                [_Earnings Coded43] / 10 [_Earnings Coded43] ,
                                [_Earnings Coded44] / 10 [_Earnings Coded44] ,
                                [_Earnings Coded45] / 10 [_Earnings Coded45] ,
                                [_Earnings Coded46] / 10 [_Earnings Coded46] ,
                                [_Earnings Coded47] / 10 [_Earnings Coded47] ,
                                [_Earnings Coded48] / 10 [_Earnings Coded48] ,
                                [_Earnings Coded49] / 10 [_Earnings Coded49] ,
                                [_Earnings Coded50] / 10 [_Earnings Coded50] ,
                                [_Earnings Coded51] / 10 [_Earnings Coded51] ,
                                [_Earnings Coded52] / 10 [_Earnings Coded52] ,
                                [_Earnings Coded53] / 10 [_Earnings Coded53] ,
                                [_Earnings Coded54] / 10 [_Earnings Coded54] ,
                                [_Earnings Coded55] / 10 [_Earnings Coded55] ,
                                [_Earnings Coded56] / 10 [_Earnings Coded56] ,
                                [_Earnings Coded57] / 10 [_Earnings Coded57] ,
                                [_Earnings Coded58] / 10 [_Earnings Coded58] ,
                                [_Earnings Coded59] / 10 [_Earnings Coded59] ,
                                [_To_Date Allowed1] ,
                                [_To_Date Allowed2] ,
                                [_To_Date Allowed3] ,
                                [_To_Date Allowed4] ,
                                [_To_Date Allowed5] ,
                                [_To_Date Taken1] ,
                                [_To_Date Taken2] ,
                                [_To_Date Taken3] ,
                                [_To_Date Taken4] ,
                                [_To_Date Taken5]
                        FROM    #temp1
                        WHERE   CAST(@dt AS DATE) >= DATEADD(d, -18, [Pay Date])
                                AND CAST(@dt AS DATE) < DATEADD(d, -4, [Pay Date])
                                AND DATEPART(DW, CAST(@dt AS DATE)) IN ( 2, 3, 4, 5, 6 ); 
 


 

                SET @dt = DATEADD(d, 1, CAST(@dt AS DATE));
            END;













        SELECT  
--Important Keys 
                IDENTITY( INT, 1, 1 )  AS employee_payroll_key ,

   --Divide Payroll fields into static or repeating and ones that change
   --Move static ones to roster and then model changing dimensions in Dim Payroll Hx

   --Static Fields
                [File Number] ,
                [Location] ,
                [Location Code] ,
                [Current Status] ,
                [Hire Date] ,
                CASE 
					 WHEN [Termination Date] < CAST('20120801' AS DATE) THEN NULL
                     ELSE [Termination Date]
                END 
					AS [Termination Date] ,
                [Termination Reason] ,
                [Termination Reason Code] ,
                [Job Title] ,
                [Payroll First Name] ,
                [Payroll Last Name] ,
                [Payroll Name] ,
                [Birth Date] ,
                DATEDIFF(YEAR, [Birth Date], GETDATE()) AS Age_cur ,
                [Gender] ,
                [EEO Ethnic Code] ,
                [Zip/Postal Code] ,
                [Manager First Name] ,
                [Manager Last Name] ,
                [Manager ID] ,
                [Standard Hours] , -- this field only represents current FTE not at the time of the payroll
                [Hourly Rate (001)] AS [Hourly Rate ADP 1 (Direct hourly)] ,   --ADP
                [Rate Amount] AS [Hourly Rate 2 ADP (Direct-biweekly salary)] ,
                CASE 
					 WHEN [Standard Hours] = 0
                          OR [Standard Hours] IS NULL THEN [Hourly Rate (001)]
                     WHEN [Rate Type Code] = 'S' THEN [Annual Salary] / ( 26 * [Standard Hours] )
                     WHEN [Rate Type Code] = 'H' THEN [Hourly Rate (001)]   -- [Annual Salary] / ( 26 * 80 )
                     ELSE NULL
                END 
					AS [Hourly Rate ADP (Based on ADP Salary or Hourly)] ,
                [Annual Salary] AS [Annual Salary ADP not annualized] ,
                CASE 
					 WHEN [Annual Salary] IS NULL
                          AND [Hourly Rate (001)] IS NULL THEN [Annual Salary]
                     WHEN [Rate Type Code] = 'H' THEN [Hourly Rate (001)] * 2080
                     WHEN [Standard Hours] = 0 THEN NULL
                     WHEN [Rate Type Code] = 'S' THEN [Annual Salary] * ( 80 / [Standard Hours] )
                     ELSE NULL
                END 
					AS [Annual Salary ADP annualized] ,
                [UDS Table 5 Staffing Category ] ,
                [UDS Table 5 Line Number ] ,
                [UDS Table 8 Costs Category ] ,
                [UDS Table 8 Line Number ] ,

				--To obtain relevant information from Home Cost Number, it must be broken into its individual segment codes
                SUBSTRING([Home Cost Number - Check], 1, CASE CHARINDEX('-', [Home Cost Number - Check])
                                                           WHEN 0 THEN LEN([Home Cost Number - Check])
                                                           ELSE CHARINDEX('-', [Home Cost Number - Check]) - 1
                                                         END) 
															AS cn_account_code_cur ,
                SUBSTRING([Home Cost Number - Check], 1, 2) AS cn_account_code_sub_cur ,
                [Location Code] AS cn_site_cur ,
                SUBSTRING([Home Cost Number - Check], CASE CHARINDEX('-', [Home Cost Number - Check], 7)
                                                        WHEN 0 THEN LEN([Home Cost Number - Check]) + 1
                                                        ELSE CHARINDEX('-', [Home Cost Number - Check], 7) + 1
                                                      END, 2) 
														AS cn_fund_cur ,
                SUBSTRING([Home Cost Number - Check], CASE CHARINDEX('-', [Home Cost Number - Check], 11)
                                                        WHEN 0 THEN LEN([Home Cost Number - Check]) + 1
                                                        ELSE CHARINDEX('-', [Home Cost Number - Check], 11) + 1
                                                      END, 1) 
														AS cn_dir_indir_cur ,
                SUBSTRING([Home Cost Number - Check], CASE CHARINDEX('-', [Home Cost Number - Check], 14)
                                                        WHEN 0 THEN LEN([Home Cost Number - Check]) + 1
                                                        ELSE CHARINDEX('-', [Home Cost Number - Check], 14) + 1
                                                      END, 2) 
														AS cn_category_cur ,
                SUBSTRING([Home Cost Number - Check], CASE CHARINDEX('-', [Home Cost Number - Check], 16)
                                                        WHEN 0 THEN LEN([Home Cost Number - Check]) + 1
                                                        ELSE CHARINDEX('-', [Home Cost Number - Check], 16) + 1
                                                      END, 4) 
														AS cn_proj_grant_cur ,            

   

   --NOW FOR THE SCD VARIABLES     ----
                SUBSTRING([Cost Number Worked In], 1, CASE CHARINDEX('-', [Cost Number Worked In])
                                                        WHEN 0 THEN LEN([Cost Number Worked In])
                                                        ELSE CHARINDEX('-', [Cost Number Worked In]) - 1
                                                      END) AS cn_account_code_hx ,
                SUBSTRING([Cost Number Worked In], 1, 2) AS cn_account_code_sub_hx ,
                CASE WHEN SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In])
                                                               WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                               ELSE CHARINDEX('-', [Cost Number Worked In]) + 1
                                                             END, 3) = '' THEN [Location Code]
                     ELSE SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In])
                                                               WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                               ELSE CHARINDEX('-', [Cost Number Worked In]) + 1
                                                             END, 3)
                END AS cn_site_hx ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 7)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 7) + 1
                                                   END, 2) AS cn_fund_hx ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 11)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 11) + 1
                                                   END, 1) AS cn_dir_indir_hx ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 14)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 14) + 1
                                                   END, 2) AS cn_category_hx ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 16)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 16) + 1
                                                   END, 4) AS cn_proj_grant_hx ,
                [Cost Number Worked In] ,
                [Cost Number Worked In Desc] ,
                

--Adding other dimensions at time of paycheck here
                CASE WHEN COALESCE([Period Beginning Date], '') = '' THEN DATEADD(d, -13, [Period End Date - Check])
                     ELSE [Period Beginning Date]
                END AS [Period Beginning Date] ,
                [Period End Date - Check] , -- It appears that the earliest date available for analysis is 2012-08-05
                [Pay Date] ,
                [Home Cost Number - Check] ,
                [Home Cost Number Desc - Check] ,
                NULL [UDS Person 2015 Tenure] ,
                NULL [UDS Person 2014 Tenure] ,
                DATEDIFF(YEAR, [Birth Date], [Pay Date]) AS Age_hx ,
                CASE 
					 WHEN [Pay Date] >= [Hire Date] THEN DATEDIFF(MONTH, [Hire Date], [Pay Date])
                     ELSE NULL
                END AS months_since_start_hx ,
                CASE 
					 WHEN [Pay Date] >= [Hire Date]
                     THEN DATEDIFF(MONTH, [Hire Date],
                                   FIRST_VALUE([Pay Date]) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ))
                     ELSE NULL
                END 
					AS months_since_start_cur ,


			


				 --this measure should be the same the allocated measure rolled up by employee
                NULL months_since_start_allocated_hx ,
                CASE 
					 WHEN [Rate Type Code] = 'S' THEN COALESCE([Regular Hours], 0) / 8
                     WHEN [Rate Type Code] = 'H'
                     THEN ( ( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                              + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) ) / 8 )
                     ELSE 0
                END 
					AS [FTE_allocated_hx] , -- measure the same as fte dim rolled by by employee
                CASE 
					 WHEN [Rate Type Code] = 'S'
                     THEN SUM(COALESCE([Regular Hours], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] )
                     WHEN [Rate Type Code] = 'H'
                     THEN ( SUM(COALESCE([_Hours Coded19], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] )
                            + SUM(COALESCE([_Hours Coded20], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] )
                            + SUM(COALESCE([_Hours Coded26], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] )
                            + SUM(COALESCE([_Hours Coded29], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] )
                            + SUM(COALESCE([Overtime Hours], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] )
                            + SUM(COALESCE([Regular Hours], 0) / 8) OVER ( PARTITION BY [File Number], [Pay Date] ) )
                     ELSE 0
                END 
					AS [FTE_hx] ,
                [Data Control] ,
                CASE 
					 WHEN [Data Control] IN ( 'FULL', 'FUL', 'FUL3', 'DRFU' ) THEN 1
                     WHEN [Data Control] = '0005' THEN 0.05
                     WHEN [Data Control] = '0010' THEN 0.10
                     WHEN [Data Control] = '0015' THEN 0.15
                     WHEN [Data Control] = '0020' THEN 0.20
                     WHEN [Data Control] = '0025' THEN 0.25
                     WHEN [Data Control] = '0030' THEN 0.30
                     WHEN [Data Control] = '0035' THEN 0.35
                     WHEN [Data Control] = '0037' THEN 0.37
                     WHEN [Data Control] = '0040' THEN 0.40
                     WHEN [Data Control] = '0045' THEN 0.45
                     WHEN [Data Control] = '0050' THEN 0.50
                     WHEN [Data Control] = '0051' THEN 0.51
                     WHEN [Data Control] = '0055' THEN 0.55
                     WHEN [Data Control] = '0060' THEN 0.60
                     WHEN [Data Control] = '0063' THEN 0.63
                     WHEN [Data Control] = '0065' THEN 0.65
                     WHEN [Data Control] = '0070' THEN 0.70
                     WHEN [Data Control] = '0075' THEN 0.75
                     WHEN [Data Control] = '0080' THEN 0.80
                     WHEN [Data Control] = '0085' THEN 0.85
                     WHEN [Data Control] = '0088' THEN 0.88
                     WHEN [Data Control] = '0090' THEN 0.90
                     WHEN [Data Control] = '0095' THEN 0.95
                     WHEN [Data Control] = '0875' THEN 0.875
                     WHEN [Data Control] = 'DR50' THEN 0.50
                     WHEN [Data Control] = 'DR55' THEN 0.55
                     WHEN [Data Control] = 'DR60' THEN 0.60
                     WHEN [Data Control] = 'DR65' THEN 0.65
                     WHEN [Data Control] = 'DR70' THEN 0.70
                     WHEN [Data Control] = 'DR75' THEN 0.75
                     WHEN [Data Control] = 'DR80' THEN 0.80
                     WHEN [Data Control] = 'DR85' THEN 0.85
                     WHEN [Data Control] = 'DR90' THEN 0.90
                     WHEN [Data Control] = 'DRFS' THEN 1.00
                     WHEN [Data Control] = 'DRFU' THEN 1.00
                     WHEN [Data Control] = 'DS80' THEN 0.80
                     WHEN [Data Control] = 'DS90' THEN 0.90
                END 
					AS [FTE based on Data Control] ,
                CASE 
					 WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number],
                                              CAST(CONVERT(VARCHAR(6), [Pay Date], 112) + '01' AS DATE) ORDER BY [Pay Date] ASC ) = 1
                     THEN 1
                     ELSE 0
                END 
					 AS [Employee Census Month] ,
              
			  			  ---- Transfers Census
                CASE 
					 WHEN [Rehire Date] >= CAST('20120101' AS DATE)
                          AND ROW_NUMBER() OVER ( PARTITION BY [File Number], [Rehire Date] ORDER BY [Pay Date] ASC ) = 1
                          AND COALESCE([Rehire Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Rehire Date])) < 90 THEN 1
                     ELSE 0
                END 
					AS [Employee Transfer Census Month] ,
                CASE 
					 WHEN [Rehire Date] >= CAST('20120101' AS DATE)
                          AND ROW_NUMBER() OVER ( PARTITION BY [File Number], [Rehire Date] ORDER BY [Pay Date] ASC ) = 1
                          AND COALESCE([Rehire Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Rehire Date])) < 90
                     THEN CASE 


					  ---Need to use a partition 
                               WHEN [Rate Type Code] = 'S'
                               THEN SUM(COALESCE([Regular Hours], 0)) OVER ( PARTITION BY [File Number],
                                                                             ROUND(DATEDIFF(DAY, [Rehire Date],
                                                                                            [Pay Date]) / 180, 1) + 1 ORDER BY [Pay Date] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
                                    / DENSE_RANK() OVER ( PARTITION BY [File Number],
                                                          ROUND(DATEDIFF(DAY, [Rehire Date], [Pay Date]) / 180, 1) + 1 ORDER BY [Pay Date] DESC )
                               WHEN [Rate Type Code] = 'H'
                               THEN SUM(( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                                          + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) )) OVER ( PARTITION BY [File Number],
                                                                                                        ROUND(DATEDIFF(DAY,
                                                                                                        [Hire Date],
                                                                                                        [Pay Date])
                                                                                                        / 180, 1) + 1 ORDER BY [Pay Date] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
                                    / DENSE_RANK() OVER ( PARTITION BY [File Number],
                                                          ROUND(DATEDIFF(DAY, [Rehire Date], [Pay Date]) / 180, 1) + 1 ORDER BY [Pay Date] DESC )
                          END
                END 
					AS [FTE Transfer 6m Avg] ,












			  ---- Terminated Census
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) = 1
                          AND COALESCE([Termination Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Termination Date])) < 90 THEN 1
                     ELSE 0
                END AS [Employee Terminated Census Month] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) = 1
                          AND COALESCE([Termination Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Termination Date])) < 90
                     THEN CASE 


					  ---Need to use a partition 
                               WHEN [Rate Type Code] = 'S'
                               THEN SUM(COALESCE([Regular Hours], 0)) OVER ( PARTITION BY [File Number],
                                                                             ROUND(DATEDIFF(DAY, [Pay Date],
                                                                                            [Termination Date]) / 180, 1)
                                                                             + 1 ORDER BY [Pay Date] RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
                                    / DENSE_RANK() OVER ( PARTITION BY [File Number],
                                                          ROUND(DATEDIFF(DAY, [Pay Date], [Termination Date]) / 180, 1)
                                                          + 1 ORDER BY [Pay Date] )
                               WHEN [Rate Type Code] = 'H'
                               THEN SUM(( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                                          + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) )) OVER ( PARTITION BY [File Number],
                                                                                                        ROUND(DATEDIFF(DAY,
                                                                                                        [Pay Date],
                                                                                                        [Termination Date])
                                                                                                        / 180, 1) + 1 ORDER BY [Pay Date] RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
                                    / DENSE_RANK() OVER ( PARTITION BY [File Number],
                                                          ROUND(DATEDIFF(DAY, [Pay Date], [Termination Date]) / 180, 1)
                                                          + 1 ORDER BY [Pay Date] )
                               ELSE 0
                          END
                END AS [FTE Terminated 6m Avg] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] ASC ) = 1
                          AND COALESCE([Hire Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Hire Date])) < 90 THEN 1
                     ELSE 0
                END 
					AS [Employee New Hire Census Month] ,
                CASE 
					WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] ASC ) = 1
                          AND COALESCE([Hire Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Hire Date])) < 90
                     THEN CASE 


					  ---Need to use a partition 
                               WHEN [Rate Type Code] = 'S'
                               THEN SUM(COALESCE([Regular Hours], 0)) OVER ( PARTITION BY [File Number],
                                                                             ROUND(DATEDIFF(DAY, [Hire Date], [Pay Date])
                                                                                   / 180, 1) + 1 ORDER BY [Pay Date] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
                                    / DENSE_RANK() OVER ( PARTITION BY [File Number],
                                                          ROUND(DATEDIFF(DAY, [Hire Date], [Pay Date]) / 180, 1) + 1 ORDER BY [Pay Date] DESC )
                               WHEN [Rate Type Code] = 'H'
                               THEN SUM(( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                                          + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) )) OVER ( PARTITION BY [File Number],
                                                                                                        ROUND(DATEDIFF(DAY,
                                                                                                        [Hire Date],
                                                                                                        [Pay Date])
                                                                                                        / 180, 1) + 1 ORDER BY [Pay Date] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
                                    / DENSE_RANK() OVER ( PARTITION BY [File Number],
                                                          ROUND(DATEDIFF(DAY, [Hire Date], [Pay Date]) / 180, 1) + 1 ORDER BY [Pay Date] DESC )
                          END
                END 
					AS [FTE New Hire 6m Avg] ,


				--Bad Hires are anyone terminated within 6 months of hire
                CASE 
					WHEN COALESCE([Hire Date], '') != ''
                          AND COALESCE([Termination Date], '') != ''
                          AND ROW_NUMBER() OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] DESC ) = 1
                          AND COALESCE([Termination Date], '') != ''
                          AND ABS(DATEDIFF(DAY, [Pay Date], [Termination Date])) < 90
                          AND DATEDIFF(DAY, [Hire Date], [Termination Date]) <= 180 THEN 1
                     ELSE 0
                END 
					AS [Employee Bad Hire Census Month] ,
           

				--Include ranges for membership months
				--Include person counts by employee, site, project -- Will need to use DAX census and allocate by month for smoothing
				--Counts for Terminated, Bad Hire

			
	           -- Most of the time we can arrive at that rate from looking at regular hours and regular earning.  This is not true when someone has no regular hours for an entire payperiod 
			   --In this case we use the previous months rate, looking back up to 10 pay periods.  This happens mostly when someone goes on maternity leave.
			   --There are a few cases where the rate is above 200 -- this was an error in the ADP system  for one provider.  Using the logic below we null out those rates.  Otherwise it looks good.
                CASE 
					WHEN ( CASE WHEN [Regular Hours] >= 0.25
                                      AND [Other Earnings] >= 0 THEN [Regular Earnings] / [Regular Hours]
                                 WHEN LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                      [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                    [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                            END ) <= 200
                     THEN CASE WHEN [Regular Hours] >= 0.25
                                    AND [Other Earnings] >= 0 THEN [Regular Earnings] / [Regular Hours]
                               WHEN LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                               WHEN LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                               [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                    [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN LAG(ISNULL([Regular Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                    / LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                          END
                     ELSE NULL
                END 
					AS [Hourly Rate Calculated based on Reg Earnings] ,
                CASE 
					 WHEN COALESCE([Regular Hours], 0) + COALESCE([Overtime Hours], 0) > 0
                     THEN ( [Gross Pay] ) / ( COALESCE([Regular Hours], 0) + COALESCE([Overtime Hours], 0) )
                     ELSE 0
                END 
					 AS [Hourly Rate Calculated based on Total Earnings] ,
                CASE 
					 WHEN ( CASE WHEN [Regular Hours] >= 0.25
                                      AND [Other Earnings] >= 0 THEN [Regular Earnings] / [Regular Hours]
                                 WHEN LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                     [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                 WHEN LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                 [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                      AND LAG(ISNULL([Other Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                      [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                                 THEN LAG(ISNULL([Regular Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                    [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                            END ) <= 200
                     THEN CASE WHEN [Regular Hours] >= 0.25
                                    AND [Other Earnings] >= 0 THEN ( [Regular Earnings] / [Regular Hours] ) * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 1) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 2) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 3) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 4) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 5) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 6) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 7) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 8) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                              [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 9) OVER ( PARTITION BY [File Number],
                                                                                  [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                               WHEN LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                               [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0.25
                                    AND LAG(ISNULL([Other Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                    [Cost Number Worked In] ORDER BY [Period End Date - Check] ) >= 0
                               THEN ( LAG(ISNULL([Regular Earnings], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                    [Cost Number Worked In] ORDER BY [Period End Date - Check] )
                                      / LAG(ISNULL([Regular Hours], 0), 10) OVER ( PARTITION BY [File Number],
                                                                                   [Cost Number Worked In] ORDER BY [Period End Date - Check] ) )
                                    * 2080
                          END
                     ELSE NULL
                END 
					AS [Salary Calculated (Reg Earnings) Annualized] ,

				
	


      --Remaining are facts
                NULL [UDS Person 2015 Count] ,
               NULL [UDS Person 2014 Count] ,
                NULL [UDS Person 2013 Count] ,
                CASE 
					 WHEN [Rate Type Code] = 'S' THEN COALESCE([Regular Hours], 0)
                     WHEN [Rate Type Code] = 'H'
                     THEN ( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                            + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) )
                     ELSE 0
                END 
					AS [Total All Hours] ,
                
                NULL [Total All Hours Terminated] ,
                NULL [Total All Hours New Hire] , 
				
				
				 -- This is the logic for the UDS report.
                CASE 
					 WHEN [Regular Hours] = 0
                     THEN [_Hours Coded29] + [_Hours Coded26] + [_Hours Coded19] + [_Hours Coded20]
                     ELSE COALESCE([Regular Hours], 0)
                END 
					 AS [Regular Hours with s/v/f/h] , --When someone takes an entire pay period off this causes the Regular Hours to be 0, while if the take a day 
                COALESCE([Regular Hours], 0) AS [Regular Hours] , --This version of regular hours from ADP only includes s/v time when it is part of a week they employee had some regular hours, otherwise there are no regular hours
                COALESCE([All Other Coded Hours], 0) AS [All Other Coded Hours] ,
                COALESCE([Overtime Hours], 0) AS [Overtime Hours] ,
                COALESCE([Regular Earnings], 0) AS [Regular Earnings] ,
                COALESCE([Other Earnings], 0) AS [Other Earnings] ,
                COALESCE([Overtime Earnings], 0) AS [Overtime Earnings] ,
                COALESCE([Net Pay], 0) AS [Net Pay] ,
                COALESCE([Gross Pay], 0) AS [Gross Pay] ,
                [_Hours Coded1] ,
                [_Hours Coded2] ,
                [_Hours Coded3] ,
                [_Hours Coded4] ,
                [_Hours Coded5] ,
                [_Hours Coded6] ,
                [_Hours Coded7] ,
                [_Hours Coded8] ,
                [_Hours Coded9] ,
                [_Hours Coded10] ,
                [_Hours Coded11] ,
                [_Hours Coded12] ,
                [_Hours Coded13] ,
                [_Hours Coded14] ,
                [_Hours Coded15] ,
                [_Hours Coded16] ,
                [_Hours Coded17] ,
                [_Hours Coded18] ,
                [_Hours Coded19] ,
                [_Hours Coded20] ,
                [_Hours Coded21] ,
                [_Hours Coded22] ,
                [_Hours Coded23] ,
                [_Hours Coded24] ,
                [_Hours Coded25] ,
                [_Hours Coded26] ,
                [_Hours Coded27] ,
                [_Hours Coded28] ,
                [_Hours Coded29] ,
                [_Hours Coded30] ,
                [_Hours Coded31] ,
                [_Hours Coded32] ,
                [_Hours Coded33] ,
                [_Earnings Coded1] ,
                [_Earnings Coded2] ,
                [_Earnings Coded3] ,
                [_Earnings Coded4] ,
                [_Earnings Coded5] ,
                [_Earnings Coded6] ,
                [_Earnings Coded7] ,
                [_Earnings Coded8] ,
                [_Earnings Coded9] ,
                [_Earnings Coded10] ,
                [_Earnings Coded11] ,
                [_Earnings Coded12] ,
                [_Earnings Coded13] ,
                [_Earnings Coded14] ,
                [_Earnings Coded15] ,
                [_Earnings Coded16] ,
                [_Earnings Coded17] ,
                [_Earnings Coded18] ,
                [_Earnings Coded19] ,
                [_Earnings Coded20] ,
                [_Earnings Coded21] ,
                [_Earnings Coded22] ,
                [_Earnings Coded23] ,
                [_Earnings Coded24] ,
                [_Earnings Coded25] ,
                [_Earnings Coded26] ,
                [_Earnings Coded27] ,
                [_Earnings Coded28] ,
                [_Earnings Coded29] ,
                [_Earnings Coded30] ,
                [_Earnings Coded31] ,
                [_Earnings Coded32] ,
                [_Earnings Coded33] ,
                [_Earnings Coded34] ,
                [_Earnings Coded35] ,
                [_Earnings Coded36] ,
                [_Earnings Coded37] ,
                [_Earnings Coded38] ,
                [_Earnings Coded39] ,
                [_Earnings Coded40] ,
                [_Earnings Coded41] ,
                [_Earnings Coded42] ,
                [_Earnings Coded43] ,
                [_Earnings Coded44] ,
                [_Earnings Coded45] ,
                [_Earnings Coded46] ,
                [_Earnings Coded47] ,
                [_Earnings Coded48] ,
                [_Earnings Coded49] ,
                [_Earnings Coded50] ,
                [_Earnings Coded51] ,
                [_Earnings Coded52] ,
                [_Earnings Coded53] ,
                [_Earnings Coded54] ,
                [_Earnings Coded55] ,
                [_Earnings Coded56] ,
                [_Earnings Coded57] ,
                [_Earnings Coded58] ,
                [_Earnings Coded59] ,
                [_To_Date Allowed1] ,
                [_To_Date Allowed2] ,
                [_To_Date Allowed3] ,
                [_To_Date Allowed4] ,
                [_To_Date Allowed5] ,
                [_To_Date Taken1] ,
                [_To_Date Taken2] ,
                [_To_Date Taken3] ,
                [_To_Date Taken4] ,
                [_To_Date Taken5] ,
                [_To_Date Allowed1] - [_To_Date Taken1] AS [Remaining Floating Hrs] ,
                [_To_Date Allowed2] - [_To_Date Taken2] AS [Remaining Holiday Hrs] ,
                [_To_Date Allowed3] - [_To_Date Taken3] AS [Remaining LTS Hrs] ,
                [_To_Date Allowed4] - [_To_Date Taken4] AS [Remaining Sick Hrs] ,
                [_To_Date Allowed5] - [_To_Date Taken5] AS [Remaining Vacation Hrs]
        INTO    dwh.data_employee_payroll_v2
        FROM    #test pay
                LEFT JOIN etl.data_uds_map_jobtitle uds ON pay.[Job Title] = uds.[TITLE]
        WHERE   COALESCE([pay].[File Number], '') != ''
        ORDER BY [File Number] ,
                [Period End Date - Check] ,
                [Cost Number Worked In];
		
		


--Custom Fixes for UDS  **DQ**
        UPDATE  dwh.data_employee_payroll_v2
        SET     [UDS Table 5 Staffing Category] = CASE WHEN [Payroll Name] = 'Brannon, Lucinda'
                                                       THEN 'Management and Support Staff'
                                                       WHEN [Payroll Name] = 'Crawford, Natasha'
                                                       THEN 'Fiscal and Billing Staff'
                                                       WHEN [Payroll Name] = 'Fifita, Mele'
                                                       THEN 'Management and Support Staff'
                                                       WHEN [Payroll Name] = 'Girma, Haregewoin'
                                                       THEN 'Fiscal and Billing Staff'
                                                       WHEN [Payroll Name] = 'Goldstein, Brenda'
                                                       THEN 'Management and Support Staff'
                                                       WHEN [Payroll Name] = 'Grayson, Aaron'
                                                       THEN 'Other Programs/Services'
                                                       WHEN [Payroll Name] = 'Rollins, Ciante'
                                                       THEN 'Fiscal and Billing Staff'
                                                       WHEN [Payroll Name] = 'Sauz, Janelle M'
                                                       THEN 'Management and Support Staff'
                                                       WHEN [Payroll Name] = 'St Julian, Cynthia' THEN 'IT Staff'
                                                       WHEN [Payroll Name] = 'Tang, Eva' THEN 'Fiscal and Billing Staff'
                                                       WHEN [Payroll Name] = 'Valdati, Amy'
                                                       THEN 'Patient/Community Education Specialists'
                                                       WHEN [Payroll Name] = 'Won, Angie'
                                                       THEN 'Management and Support Staff'
                                                       WHEN [Payroll Name] = 'Michel, Ivette'
                                                       THEN 'Management and Support Staff'
                                                       WHEN [Payroll Name] = 'Reyes, Roxann'
                                                       THEN 'Management and Support Staff'
                                                       ELSE [UDS Table 5 Staffing Category]
                                                  END ,
                [UDS Table 5 Line Number] = CASE WHEN [Payroll Name] = 'Brannon, Lucinda' THEN '30a'
                                                 WHEN [Payroll Name] = 'Henley, Eric' THEN '30a2'
                                                 WHEN [Payroll Name] = 'Lynch, Martin' THEN '30a1'
                                                 WHEN [Payroll Name] = 'Singh, Kanwar' THEN '30a3'
                                                 WHEN [Payroll Name] = 'Crawford, Natasha' THEN '30b'
                                                 WHEN [Payroll Name] = 'Fifita, Mele' THEN '30a'
                                                 WHEN [Payroll Name] = 'Girma, Haregewoin' THEN '30b'
                                                 WHEN [Payroll Name] = 'Goldstein, Brenda' THEN '30a'
                                                 WHEN [Payroll Name] = 'Grayson, Aaron' THEN '29a'
                                                 WHEN [Payroll Name] = 'Rollins, Ciante' THEN '30b'
                                                 WHEN [Payroll Name] = 'Sauz, Janelle M' THEN '30a'
                                                 WHEN [Payroll Name] = 'St Julian, Cynthia' THEN '30c'
                                                 WHEN [Payroll Name] = 'Tang, Eva' THEN '30b'
                                                 WHEN [Payroll Name] = 'Valdati, Amy' THEN '25'
                                                 WHEN [Payroll Name] = 'Won, Angie' THEN '30a'
                                                 WHEN [Payroll Name] = 'Michel, Ivette' THEN '30a'
                                                 WHEN [Payroll Name] = 'Reyes, Roxann' THEN '30a'
                                                 WHEN [Payroll Name] = 'Miller, Deborah' THEN '1Locums'
                                                 WHEN [Payroll Name] = 'Todel, Madelene' THEN '1Locums'
                                                 ELSE [UDS Table 5 Line Number]
                                            END
        FROM    dwh.data_employee_payroll_v2;


--Remap All Category Cost Numbers for Historical Data up until a certain point
--Finance provided the remap and will start separating out category in the cost number for all future payrolls
--right now category is the same for a person across all payroll cost numbers


        SELECT DISTINCT
                [Name Full] ,
                [Should Be]
        INTO    #temp
        FROM    [Prod_Ghost].[etl].[data_costnumber_remap_category] --This is a static table from Finance data, not created by any procedure
        WHERE   [Name Full] IS NOT NULL;

		--Remap cost numbers to manually defined values
        UPDATE  e
        SET     e.[cn_category_hx] = r.[Should Be] ,
                e.[cn_category_cur] = r.[Should Be]
        FROM    dwh.data_employee_payroll_v2 e
                INNER JOIN #temp r ON e.[Payroll Name] = r.[Name Full];




--UDS Code for FTE Table 5		

--SELECT   [Payroll Name],     [Job Title] ,[UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ] ,
--        CAST(ROUND(( SUM([Total All Hours]) ) / 2080, 2, 1) AS NUMERIC(8, 2)) as FTE ,
--        SUM([Total All Hours]) as [Total Hours],
--		SUM([UDS Person 2015 Count]),
--        SUM([Regular Hours]) AS REG ,
--        SUM([Overtime Hours]) AS OT ,
--        SUM([_Hours Coded26]) AS SICK ,
--        SUM([_Hours Coded29]) AS VAC ,
--        SUM([_Hours Coded20]) AS HOL ,
--        SUM([_Hours Coded19]) AS FLP
--FROM    #temp




--where  [Pay Date] >= '20150101'
--        AND [Pay Date] <= '20151231' 
		
--		--and    [UDS Table 5 Line Number ]  is null

--GROUP BY [Payroll Name],     [Job Title] ,[UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ]
--ORDER BY [Payroll Name]
	
		
		
--UDS Code for FTE Table 5A

--SELECT  [payroll name],[UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ] ,
--         SUM([Total All Hours])  / 2080 as FTE ,
--        SUM([Total All Hours]) as [Total Hours],
--        SUM([Regular Hours]) AS REG ,
--        SUM([Overtime Hours]) AS OT ,
--        SUM([_Hours Coded26]) AS SICK ,
--        SUM([_Hours Coded29]) AS VAC ,
--        SUM([_Hours Coded20]) AS HOL ,
--        SUM([_Hours Coded19]) AS FLP,
--		SUM([UDS Person 2015 Count]) as [UDS 2015 Person Count],
--		SUM( [UDS Person 2015 Tenure]) as [UDS Person 2015 Tenure],
--		SUM([UDS Person 2014 Count]) as [UDS 2014 Person Count],
--		SUM( [UDS Person 2014 Tenure]) as [UDS Person 2014 Tenure]




--FROM    #temp


--WHERE   Year([Pay Date])=2015
--GROUP BY  [payroll name],[UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ]

--Order by [Payroll Name]
----order by SUBSTRing([UDS Table 5 Line Number ],1,1)
----ORDER BY CAST(IIF(SUBSTRING([UDS Table 5 Line Number ], 1, 1) = '9', SUBSTRING([UDS Table 5 Line Number ], 1, 1), SUBSTRING([UDS Table 5 Line Number ],
               

----			                                                                                            1, 2)) AS INT) ASC, [UDS Table 5 Staffing Category ];


--UDS Code for OSHPED	

--SELECT   cn_site, loc.location_mstr_name,
--        CAST(ROUND(( SUM([Total All Hours]) ) / 2080, 2, 1) AS NUMERIC(8, 2)) as FTE ,
--        SUM([Total All Hours]) as [Total Hours],
--		SUM([UDS Person 2015 Count]) AS Employee2015Count,
--        SUM([Regular Hours]) AS REG ,
--        SUM([Overtime Hours]) AS OT ,
--        SUM([_Hours Coded26]) AS SICK ,
--        SUM([_Hours Coded29]) AS VAC ,
--        SUM([_Hours Coded20]) AS HOL ,
--        SUM([_Hours Coded19]) AS FLP
--FROM    dwh.data_adp_payroll adp INNER join dwh.data_location loc ON adp.cn_site = loc.site_id




--where  [Pay Date] >= '20150101'
--        AND [Pay Date] <= '20151231' 
		


--GROUP BY  cn_site,loc.location_mstr_name ORDER BY cn_site

	
--SELECT   cn_site, cn_category, loc.location_mstr_name, [Payroll Name],
--        CAST(ROUND(( SUM([Total All Hours]) ) / 2080, 2, 1) AS NUMERIC(8, 2)) as FTE ,
--        SUM([Total All Hours]) as [Total Hours],
--		SUM([UDS Person 2015 Count]) AS Employee2015Count,
--		SUM([Gross Pay]) AS [Gross Pay],
--        SUM([Regular Hours]) AS REG ,
--        SUM([Overtime Hours]) AS OT ,
--        SUM([_Hours Coded26]) AS SICK ,
--        SUM([_Hours Coded29]) AS VAC ,
--        SUM([_Hours Coded20]) AS HOL ,
--        SUM([_Hours Coded19]) AS FLP
--FROM    dwh.data_adp_payroll adp INNER join dwh.data_location loc ON adp.cn_site = loc.site_id




--where  [Pay Date] >= '20150701'
--        AND [Pay Date] <= '20160131' 
--		AND [cn_site]=100
		


--GROUP BY  cn_site,cn_category,loc.location_mstr_name,  [Payroll Name] ORDER BY cn_site







--DECLARE 




    END;
GO
