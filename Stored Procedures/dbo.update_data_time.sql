SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_time]
AS
begin
        IF OBJECT_ID('dbo.data_time') IS NOT NULL
            DROP TABLE dbo.data_time;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  ISNULL(CAST([PK_Date] AS DATETIME)  ,'') AS PK_datetime,
        ISNULL(CAST(PK_Date AS DATE) ,'')  AS PK_date,
        CONVERT(CHAR(10), PK_Date, 110) AS date_name_short_10 ,
		CONVERT(CHAR(8), PK_Date, 112) AS date_name_short_08 ,
        CAST(CONVERT(CHAR(6), PK_Date,112)+'01' AS DATE) AS first_mon_date,
		[Date_Name] ,
        [Year] ,
        [Year_Name] ,
        [Half_Year] ,
        [Half_Year_Name] ,
        [Quarter] ,
        [Quarter_Name] ,
        [Trimester] ,
        [Trimester_Name] ,
        [Month] ,
        [Month_Name] ,
        [Ten_Days] ,
        [Ten_Days_Name] ,
        [Week] ,
        [Week_Name] ,
		CAST(DATEADD(wk, DATEDIFF(wk,0,ISNULL(CAST(PK_Date AS DATE) ,'') ), 0) AS DATE) AS MondayOfWeek,
		[Day_Of_Year] ,
        [Day_Of_Year_Name] ,
        [Day_Of_Half_Year] ,
        [Day_Of_Half_Year_Name] ,
        [Day_Of_Trimester] ,
        [Day_Of_Trimester_Name] ,
        [Day_Of_Quarter] ,
        [Day_Of_Quarter_Name] ,
        [Day_Of_Month] ,
        [Day_Of_Month_Name] ,
        [Day_Of_Ten_Days] ,
        [Day_Of_Ten_Days_Name] ,
        [Day_Of_Week] ,
        	CASE  
		 WHEN [Day_Of_Week]= 1 THEN 'Sunday' 
		 WHEN [Day_Of_Week]= 2 THEN 'Monday'
		 WHEN [Day_Of_Week]= 3 THEN 'Tuesday'
		 WHEN [Day_Of_Week]= 4 THEN 'Wednesday'
		 WHEN [Day_Of_Week]= 5 THEN 'Thursday'
		 WHEN [Day_Of_Week]= 6 THEN 'Friday'
		 WHEN [Day_Of_Week]= 7 THEN 'Saturday'
	   end	 AS [Day_Of_Week_Name] ,
	 
        [Week_Of_Year] ,
        [Week_Of_Year_Name] ,
        [Ten_Days_Of_Year] ,
        [Ten_Days_Of_Year_Name] ,
        [Ten_Days_Of_Half_Year] ,
        [Ten_Days_Of_Half_Year_Name] ,
        [Ten_Days_Of_Trimester] ,
        [Ten_Days_Of_Trimester_Name] ,
        [Ten_Days_Of_Quarter] ,
        [Ten_Days_Of_Quarter_Name] ,
        [Ten_Days_Of_Month] ,
        [Ten_Days_Of_Month_Name] ,
        [Month_Of_Year] ,
        [Month_Of_Year_Name] ,
        [Month_Of_Half_Year] ,
        [Month_Of_Half_Year_Name] ,
        [Month_Of_Trimester] ,
        [Month_Of_Trimester_Name] ,
        [Month_Of_Quarter] ,
        [Month_Of_Quarter_Name] ,
        [Quarter_Of_Year] ,
        [Quarter_Of_Year_Name] ,
        [Quarter_Of_Half_Year] ,
        [Quarter_Of_Half_Year_Name] ,
        [Trimester_Of_Year] ,
        [Trimester_Of_Year_Name] ,
        [Half_Year_Of_Year] ,
        [Half_Year_Of_Year_Name] ,
        [Fiscal_Year] ,
        [Fiscal_Year_Name] ,
        [Fiscal_Half_Year] ,
        [Fiscal_Half_Year_Name] ,
        [Fiscal_Quarter] ,
        [Fiscal_Quarter_Name] ,
        [Fiscal_Trimester] ,
        [Fiscal_Trimester_Name] ,
        [Fiscal_Month] ,
        [Fiscal_Month_Name] ,
        [Fiscal_Week] ,
        [Fiscal_Week_Name] ,
        [Fiscal_Day] ,
        [Fiscal_Day_Name] ,
        [Fiscal_Day_Of_Year] ,
        [Fiscal_Day_Of_Year_Name] ,
        [Fiscal_Day_Of_Half_Year] ,
        [Fiscal_Day_Of_Half_Year_Name] ,
        [Fiscal_Day_Of_Trimester] ,
        [Fiscal_Day_Of_Trimester_Name] ,
        [Fiscal_Day_Of_Quarter] ,
        [Fiscal_Day_Of_Quarter_Name] ,
        [Fiscal_Day_Of_Month] ,
        [Fiscal_Day_Of_Month_Name] ,
        [Fiscal_Day_Of_Week] ,
        [Fiscal_Day_Of_Week_Name] ,
        [Fiscal_Week_Of_Year] ,
        [Fiscal_Week_Of_Year_Name] ,
        [Fiscal_Month_Of_Year] ,
        [Fiscal_Month_Of_Year_Name] ,
        [Fiscal_Month_Of_Half_Year] ,
        [Fiscal_Month_Of_Half_Year_Name] ,
        [Fiscal_Month_Of_Trimester] ,
        [Fiscal_Month_Of_Trimester_Name] ,
        [Fiscal_Month_Of_Quarter] ,
        [Fiscal_Month_Of_Quarter_Name] ,
        [Fiscal_Trimester_Of_Year] ,
        [Fiscal_Trimester_Of_Year_Name] ,
        [Fiscal_Quarter_Of_Year] ,
        [Fiscal_Quarter_Of_Year_Name] ,
        [Fiscal_Quarter_Of_Half_Year] ,
        [Fiscal_Quarter_Of_Half_Year_Name] ,
        [Fiscal_Half_Year_Of_Year] ,
        [Fiscal_Half_Year_Of_Year_Name] ,
        [Relative_days_to_CurrentDate] ,
        [Relative_months_to_CurrentDate] ,
        [Relative_weeks_to_CurrentDate]
		INTO dbo.data_time
FROM   dbo.data_time_source;

ALTER TABLE dbo.data_time
ALTER COLUMN PK_date DATE NOT NULL


ALTER TABLE dbo.data_time
ALTER COLUMN PK_datetime DATETIME NOT NULL


ALTER TABLE dbo.data_time
ADD CONSTRAINT date_pk PRIMARY KEY (PK_date);



        UPDATE   dbo.data_time
        SET     [Relative_days_to_CurrentDate] = DATEDIFF(DAY, PK_Date, GETDATE());


        UPDATE  dbo.data_time
        SET     [Relative_weeks_to_CurrentDate] = DATEDIFF(WEEK, DATEADD(dd,-1,PK_Date), DATEADD(dd,-1,GETDATE()));


        UPDATE   dbo.data_time
        SET     [Relative_months_to_CurrentDate] = DATEDIFF(MONTH, PK_Date, GETDATE());



END
GO
