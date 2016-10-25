SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_employee_payroll]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        IF OBJECT_ID('dwh.data_employee_payroll') IS NOT NULL
            DROP TABLE dwh.data_employee_payroll;





--This payroll extract is still dropping employees who have left over a year ago (as far as I can tell)  Examples would be Chavon and Edwards



        SELECT  
--Important Keys 
		  IDENTITY( INT, 1, 1 )  AS employee_payroll_key,
                CASE WHEN COALESCE([Period Beginning Date], '') = '' THEN DATEADD(d, -13, [Period End Date - Check])
                     ELSE [Period Beginning Date]
                END AS [Period Beginning Date] ,
                [Period End Date - Check] , -- It appears that the earliest date available for analysis is 2012-08-05
                [Pay Date] ,
                [File Number] ,
                SUBSTRING([Cost Number Worked In], 1, CASE CHARINDEX('-', [Cost Number Worked In])
                                                        WHEN 0 THEN LEN([Cost Number Worked In])
                                                        ELSE CHARINDEX('-', [Cost Number Worked In]) - 1
                                                      END) AS cn_account_code ,
                SUBSTRING([Cost Number Worked In], 1, 2) AS cn_account_code_sub ,
                CASE WHEN SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In])
                                                               WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                               ELSE CHARINDEX('-', [Cost Number Worked In]) + 1
                                                             END, 3) = '' THEN [Location Code]
                     ELSE SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In])
                                                               WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                               ELSE CHARINDEX('-', [Cost Number Worked In]) + 1
                                                             END, 3)
                END AS cn_site ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 7)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 7) + 1
                                                   END, 2) AS cn_fund ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 11)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 11) + 1
                                                   END, 1) AS cn_dir_indir ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 14)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 14) + 1
                                                   END, 2) AS cn_category ,
                SUBSTRING([Cost Number Worked In], CASE CHARINDEX('-', [Cost Number Worked In], 16)
                                                     WHEN 0 THEN LEN([Cost Number Worked In]) + 1
                                                     ELSE CHARINDEX('-', [Cost Number Worked In], 16) + 1
                                                   END, 4) AS cn_proj_grant ,
                [Cost Number Worked In] ,
                [Cost Number Worked In Desc] ,
                [Current Status] ,
                [Hire Date] ,
                [Termination Date] ,
                [Termination Reason] ,
                [Termination Reason Code] ,
                [Data Control] ,
             

--Adding other dimensions at time of paycheck here
                [Job Title] ,
                [UDS Table 5 Staffing Category ] ,
                [UDS Table 5 Line Number ] ,
                [UDS Table 8 Costs Category ] ,
                [UDS Table 8 Line Number ] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number], YEAR([Pay Date]) ORDER BY [Pay Date] DESC ) = 1
                          AND YEAR([Pay Date]) = 2015
                          AND MONTH([Pay Date]) = 12 THEN 1
                     ELSE 0
                END AS [UDS Person 2015 Count] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number], YEAR([Pay Date]) ORDER BY [Pay Date] DESC ) = 1
                          AND YEAR([Pay Date]) = 2014
                          AND MONTH([Pay Date]) = 12 THEN 1
                     ELSE 0
                END AS [UDS Person 2014 Count] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number], YEAR([Pay Date]) ORDER BY [Pay Date] DESC ) = 1
                          AND YEAR([Pay Date]) = 2013
                          AND MONTH([Pay Date]) = 12 THEN 1
                     ELSE 0
                END AS [UDS Person 2013 Count] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number], YEAR([Pay Date]) ORDER BY [Pay Date] DESC ) = 1
                          AND YEAR([Pay Date]) = 2015
                          AND MONTH([Pay Date]) = 12
                     THEN SUM(CASE WHEN [Rate Type Code] = 'S'
                                        AND YEAR([Pay Date]) = 2015 THEN COALESCE([Regular Hours], 0) / 2080
                                   WHEN [Rate Type Code] = 'H'
                                        AND YEAR([Pay Date]) = 2015
                                   THEN ( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                                          + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) ) / 2080
                                   ELSE 0
                              END) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] ) * DATEDIFF(MONTH, [Hire Date],
                                                                                                      [Pay Date])
                     ELSE 0
                END AS [UDS Person 2015 Tenure] ,
                CASE WHEN ROW_NUMBER() OVER ( PARTITION BY [File Number], YEAR([Pay Date]) ORDER BY [Pay Date] DESC ) = 1
                          AND YEAR([Pay Date]) = 2014
                          AND MONTH([Pay Date]) = 12
                     THEN SUM(CASE WHEN [Rate Type Code] = 'S'
                                        AND YEAR([Pay Date]) = 2014 THEN COALESCE([Regular Hours], 0) / 2080
                                   WHEN [Rate Type Code] = 'H'
                                        AND YEAR([Pay Date]) = 2014
                                   THEN ( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                                          + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) ) / 2080
                                   ELSE 0
                              END) OVER ( PARTITION BY [File Number] ORDER BY [Pay Date] ) * DATEDIFF(MONTH, [Hire Date],
                                                                                                      [Pay Date])
                     ELSE 0
                END AS [UDS Person 2014 Tenure] ,
                [Payroll First Name] ,
                [Payroll Last Name] ,
                [Payroll Name] ,
                [Gender] ,
                [EEO Ethnic Code] ,
                [Zip/Postal Code] [Manager First Name] ,
                [Manager Last Name] ,
                [Manager ID] ,
                [Standard Hours] , -- this field only represents current FTE not at the time of the payroll
                [Hourly Rate (001)] AS [Hourly Rate ADP 1 (Direct Hourly)] ,
                [Rate Amount] AS [Hourly Rate 2 ADP (Direct-biweekly salary)] ,
                CASE WHEN [Rate Type Code] = 'S'
                     THEN ROUND([Annual Salary] / ( 26 * CAST([Standard Hours] AS INTEGER) ), 0, 1)
                     WHEN [Rate Type Code] = 'H' THEN ROUND([Annual Salary] / ( 26 * 80 ), 0, 1)
                     ELSE NULL
                END AS [Hourly Rate ADP (Based on ADP Salary or Hourly)] ,
			
                
	 
	 
	           -- Most of the time we can arrive at that rate from looking at regular hours and regular earning.  This is not true when someone has no regular hours for an entire payperiod 
			   --In this case we use the previous months rate, looking back up to 10 pay periods.  This happens mostly when someone goes on maternity leave.
			   --There are a few cases where the rate is above 200 -- this was an error in the ADP system  for one provider.  Using the logic below we null out those rates.  Otherwise it looks good.
                CASE WHEN ( CASE WHEN [Regular Hours] >= 0.25
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
                END AS [Hourly Rate Calculated based on Reg Earnings] ,
                CASE WHEN COALESCE([Regular Hours], 0) + COALESCE([Overtime Hours], 0) > 0
                     THEN ( [Gross Pay] ) / ( COALESCE([Regular Hours], 0) + COALESCE([Overtime Hours], 0) )
                     ELSE 0
                END AS [Hourly Rate Calculated based on Total Earnings] ,
                [Annual Salary] AS [Annual Salary ADP not annualized] ,
                CASE WHEN ( CASE WHEN [Regular Hours] >= 0.25
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
                END AS [Calculated Salary (Reg Earnings) Annualized] ,


	


      --Remaining are facts
                CASE WHEN [Rate Type Code] = 'S' THEN COALESCE([Regular Hours], 0)
                     WHEN [Rate Type Code] = 'H'
                     THEN ( [_Hours Coded19] + [_Hours Coded20] + [_Hours Coded26] + [_Hours Coded29]
                            + COALESCE([Overtime Hours], 0) + COALESCE([Regular Hours], 0) )
                     ELSE 0
                END AS [Total All Hours] ,  -- This is the logic for the UDS report.
                CASE WHEN [Regular Hours] = 0
                     THEN [_Hours Coded29] + [_Hours Coded26] + [_Hours Coded19] + [_Hours Coded20]
                     ELSE COALESCE([Regular Hours], 0)
                END AS [Regular Hours with s/v/f/h] , --When someone takes an entire pay period off this causes the Regular Hours to be 0, while if the take a day 
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
                [_Earnings Coded57]
        INTO    dwh.data_adp_payroll
        FROM    [Prod_Ghost].[etl].[data_adp_payroll_v3] pay
                LEFT JOIN etl.data_uds_map_jobtitle uds ON pay.[Job Title] = uds.[TITLE]
        ORDER BY [File Number] ,
                [Period End Date - Check] ,
                [Cost Number Worked In];
		


--Custom Fixes for UDS
        UPDATE  dwh.data_adp_payroll
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
        FROM    dwh.data_adp_payroll;


--Ran into some trouble importing excel spreadsheet data, need to reformat money $ fields into decimal in the spreadsheet itself
--What remains is the UDS table creations.
	

--Next would be to separate out the payroll data into days (although this would create a fiction in terms of daily or weekly information), it would ensure that the monly data was 
--even when reporting.
   



       -- INTO    dwh.data_employee_payroll
 --       FROM    etl.data_adp_roster ar;
        
   --     ALTER TABLE dwh.data_employee
  --      ADD CONSTRAINT employee_key_pk PRIMARY KEY (employee_key);





--SELECT  [UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ] ,
--        CAST(ROUND(( SUM([Regular Hours with s/v]) + SUM([Overtime Hours]) ) / 2080, 2, 1) AS NUMERIC(8, 2)) ,
--        CAST(ROUND(( SUM([Regular Hours]) + SUM([Total All Hours]) ) / 2080, 2, 1) AS NUMERIC(8, 2))
--FROM    #temp
--WHERE   [Period Beginning Date] >= '20140101'
--        AND [Period End Date - Check] <= '20141231'
--GROUP BY [UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ]
--ORDER BY CAST(IIF(SUBSTRING([UDS Table 5 Line Number ], 1, 1) = '9', SUBSTRING([UDS Table 5 Line Number ], 1, 1), SUBSTRING([UDS Table 5 Line Number ],
--                                                                                                        1, 2)) AS INT);



	
--SELECT   [UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ] ,
--        CAST(ROUND(( SUM([Total All Hours]) ) / 2080, 2, 1) AS NUMERIC(8, 2)) ,
--        SUM([Total All Hours]) ,
--        SUM([Regular Hours]) AS reghrs ,
--        SUM([Overtime Hours]) AS OThOURS ,
--        SUM([_Hours Coded26]) AS SICK ,
--        SUM([_Hours Coded29]) AS vAC ,
--        SUM([_Hours Coded20]) AS hOL ,
--        SUM([_Hours Coded19]) AS flp
--FROM    #temp
--WHERE   [Pay Date] >= '20150101'
--        AND [Pay Date] <= '20151231'
--GROUP BY [UDS Table 5 Staffing Category ] ,
--        [UDS Table 5 Line Number ]
--ORDER BY CAST(IIF(SUBSTRING([UDS Table 5 Line Number ], 1, 1) = '9', SUBSTRING([UDS Table 5 Line Number ], 1, 1), SUBSTRING([UDS Table 5 Line Number ],
--                                                                                                        1, 2)) AS INT);

		

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
	
		
		
--select * from #temp where ( [UDS Table 5 Staffing Category ]  like '%Family%' OR [UDS Table 5 Staffing Category ]  like '%Intern%' ) and [UDS Person 2014 Count] = 1 order by [pay date]

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

    END;
GO
