SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_employee_month]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        IF OBJECT_ID('dwh.data_employee_month') IS NOT NULL
            DROP TABLE dwh.data_employee_month;

        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);


        SET @build_dt_start = CONVERT(VARCHAR(8), DATEADD(MONTH, 6, GETDATE()));
        SET @build_dt_end = CONVERT(VARCHAR(8), GETDATE(), 112);
        SET @build_dt_start = '20100301';
		
		-- Need to aggregate all Data control and translate into actual FTE
	
		-- Gonna need overtime report 
		-- Months of employement
		-- Vintage of employee
		-- Balances Vacation and sick





        SELECT 
				IDENTITY( INT, 1, 1 )  AS employee_month_key ,  
				ar.*,
		
				CASE
		--Employee current
                     WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) = 0 --Hired and not terminated gives current employee
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6), ar.[Hire Date], 112) + '01' AS DATE) 
						  THEN  DATEDIFF(YEAR,CAST(CONVERT(VARCHAR(6),ar.[Date of Birth], 112) + '01' AS DATE),CAST(CONVERT(VARCHAR(6),tim.first_mon_date, 112) + '01' AS DATE))
	--Employee current but terminated later
                     WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) != 0
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE)
                           AND first_mon_date <= CAST(CONVERT(VARCHAR(6), ar.[Termination Date], 112) + '01' AS DATE)
                     THEN  DATEDIFF(YEAR,CAST(CONVERT(VARCHAR(6),ar.[Date of Birth], 112) + '01' AS DATE),CAST(CONVERT(VARCHAR(6),tim.first_mon_date, 112) + '01' AS DATE))
                     ELSE null
                END 
					AS age_hx,



		        tim.first_mon_date,
				--flag for tracking all current employees
                CASE 
	
	
	--Employee current
                     WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) = 0
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6), ar.[Hire Date], 112) + '01' AS DATE) THEN 1
	--Employee current but terminated later
                     WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) != 0
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE)
                           AND first_mon_date <= CAST(CONVERT(VARCHAR(6), ar.[Termination Date], 112) + '01' AS DATE)
                     THEN 1
                     ELSE 0
                END 
					AS nbr_census_employee,
				--Flag for tracking terminated employees
				CASE 
				     WHEN COALESCE(ar.[Termination Date], 0) != 0
                          AND first_mon_date = CAST(CONVERT(VARCHAR(6), ar.[Termination Date], 112) + '01' AS DATE)
                     THEN 1
                     ELSE 0
                END 
					AS nbr_census_separated,
				--Person is flagged as a bad hire if they left or were terminated in the first 6 months
				CASE 
					 WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) != 0
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6), ar.[Hire Date], 112) + '01' AS DATE)
						   AND first_mon_date <= CAST(CONVERT(VARCHAR(6), ar.[Termination Date], 112) + '01' AS DATE)
						  AND DATEDIFF(m,CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE),CAST(CONVERT(VARCHAR(6),ar.[Termination Date], 112) + '01' AS DATE)) <= 6
						   THEN 1
	                 ELSE 0
                END 
					AS nbr_census_bad_hire,
				--Calculate the amount of time since employee's hire date
				CASE 
				      WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) = 0
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6), ar.[Hire Date], 112) + '01' AS DATE) THEN DATEDIFF(m,CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE), tim.first_mon_date) + 1
	--Employee current but terminated later
                     WHEN COALESCE(ar.[Hire Date], 0) != 0
                          AND COALESCE(ar.[Termination Date], 0) != 0
                          AND first_mon_date >= CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE)
                           AND first_mon_date <= CAST(CONVERT(VARCHAR(6), ar.[Termination Date], 112) + '01' AS DATE)
                     THEN DATEDIFF(m,CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE), tim.first_mon_date) + 1
                     ELSE  0
                END 
					AS months_since_start,

			CASE
				WHEN COALESCE(ar.[Hire Date], 0) != 0
                     AND COALESCE(ar.[Termination Date], 0) = 0
                     AND first_mon_date >= CAST(CONVERT(VARCHAR(6), ar.[Hire Date], 112) + '01' AS DATE) THEN 

						CASE 

							WHEN [Data Control] IN ( 'FULL', 'FUL' , 'FUL3', 'DRFU')THEN 1
							WHEN [Data Control] ='0005' THEN 0.05
							WHEN [Data Control] ='0010' THEN 0.10
							WHEN [Data Control] ='0015' THEN 0.15
							WHEN [Data Control] ='0020' THEN 0.20
							WHEN [Data Control] ='0025' THEN 0.25
							WHEN [Data Control] ='0030' THEN 0.30
							WHEN [Data Control] ='0035' THEN 0.35
							WHEN [Data Control] ='0037' THEN 0.37
							WHEN [Data Control] ='0040' THEN 0.40
							WHEN [Data Control] ='0045' THEN 0.45
							WHEN [Data Control] ='0050' THEN 0.50
							WHEN [Data Control] ='0051' THEN 0.51
							WHEN [Data Control] ='0055' THEN 0.55
							WHEN [Data Control] ='0060' THEN 0.60
							WHEN [Data Control] ='0063' THEN 0.63
							WHEN [Data Control] ='0065' THEN 0.65
							WHEN [Data Control] ='0070' THEN 0.70
							WHEN [Data Control] ='0075' THEN 0.75
							WHEN [Data Control] ='0080' THEN 0.80
							WHEN [Data Control] ='0085' THEN 0.85
							WHEN [Data Control] ='0088' THEN 0.88
							WHEN [Data Control] ='0090' THEN 0.90
							WHEN [Data Control] ='0095' THEN 0.95
							WHEN [Data Control] ='0875' THEN 0.875
							WHEN [Data Control] ='DR50' THEN 0.50
							WHEN [Data Control] ='DR55' THEN 0.55
							WHEN [Data Control] ='DR60' THEN 0.60
							WHEN [Data Control] ='DR65' THEN 0.65
							WHEN [Data Control] ='DR70' THEN 0.70
							WHEN [Data Control] ='DR75' THEN 0.75
							WHEN [Data Control] ='DR80' THEN 0.80
							WHEN [Data Control] ='DR85' THEN 0.85
							WHEN [Data Control] ='DR90' THEN 0.90
							WHEN [Data Control] ='DRFS' THEN 1.00
							WHEN [Data Control] ='DRFU' THEN 1.00
							WHEN [Data Control] ='DS80' THEN 0.80
							WHEN [Data Control] ='DS90' THEN 0.90
						END
					
				WHEN COALESCE(ar.[Hire Date], 0) != 0
                    AND COALESCE(ar.[Termination Date], 0) != 0
                    AND first_mon_date >= CAST(CONVERT(VARCHAR(6),ar.[Hire Date], 112) + '01' AS DATE)
                    AND first_mon_date <= CAST(CONVERT(VARCHAR(6), ar.[Termination Date], 112) + '01' AS DATE) THEN

					CASE 

							WHEN [Data Control] IN ( 'FULL', 'FUL' , 'FUL3', 'DRFU')THEN 1
							WHEN [Data Control] ='0005' THEN 0.05
							WHEN [Data Control] ='0010' THEN 0.10
							WHEN [Data Control] ='0015' THEN 0.15
							WHEN [Data Control] ='0020' THEN 0.20
							WHEN [Data Control] ='0025' THEN 0.25
							WHEN [Data Control] ='0030' THEN 0.30
							WHEN [Data Control] ='0035' THEN 0.35
							WHEN [Data Control] ='0037' THEN 0.37
							WHEN [Data Control] ='0040' THEN 0.40
							WHEN [Data Control] ='0045' THEN 0.45
							WHEN [Data Control] ='0050' THEN 0.50
							WHEN [Data Control] ='0051' THEN 0.51
							WHEN [Data Control] ='0055' THEN 0.55
							WHEN [Data Control] ='0060' THEN 0.60
							WHEN [Data Control] ='0063' THEN 0.63
							WHEN [Data Control] ='0065' THEN 0.65
							WHEN [Data Control] ='0070' THEN 0.70
							WHEN [Data Control] ='0075' THEN 0.75
							WHEN [Data Control] ='0080' THEN 0.80
							WHEN [Data Control] ='0085' THEN 0.85
							WHEN [Data Control] ='0088' THEN 0.88
							WHEN [Data Control] ='0090' THEN 0.90
							WHEN [Data Control] ='0095' THEN 0.95
							WHEN [Data Control] ='0875' THEN 0.875
							WHEN [Data Control] ='DR50' THEN 0.50
							WHEN [Data Control] ='DR55' THEN 0.55
							WHEN [Data Control] ='DR60' THEN 0.60
							WHEN [Data Control] ='DR65' THEN 0.65
							WHEN [Data Control] ='DR70' THEN 0.70
							WHEN [Data Control] ='DR75' THEN 0.75
							WHEN [Data Control] ='DR80' THEN 0.80
							WHEN [Data Control] ='DR85' THEN 0.85
							WHEN [Data Control] ='DR90' THEN 0.90
							WHEN [Data Control] ='DRFS' THEN 0.00
							WHEN [Data Control] ='DRFU' THEN 0.00
							WHEN [Data Control] ='DS80' THEN 0.80
							WHEN [Data Control] ='DS90' THEN 0.90
						END

					ELSE 0

				END 
						AS fte_created

					


				

        INTO dwh.data_employee_month
        FROM    dwh.data_employee ar
				--Cross join creates a snapshot table giving every employee 1 row for every month of each year
                CROSS JOIN ( SELECT DISTINCT
                                    first_mon_date
                             FROM   dwh.data_time
                             WHERE  first_mon_date >= CAST(@build_dt_start AS DATETIME)
                                    AND first_mon_date <= CAST(@build_dt_end AS DATETIME)
                           ) tim



		 ALTER TABLE dwh.data_employee_month
        ADD CONSTRAINT  employee_month_key_pk PRIMARY KEY (employee_month_key);



    END
GO
