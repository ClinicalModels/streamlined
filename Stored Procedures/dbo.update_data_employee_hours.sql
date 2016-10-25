SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_employee_hours]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		
        IF OBJECT_ID('dwh.data_employee_hours') IS NOT NULL
            DROP TABLE dwh.data_employee_hours;
        IF OBJECT_ID('dwh.data_employee_hours_status') IS NOT NULL
            DROP TABLE dwh.data_employee_hours_status;



		--ETL table comes from an SSIS job which imports an excel or csv report produced by payroll system
        SELECT  de.employee_key ,
	            ah.[Pay Date] ,
				--**DQ** After April the file imported from ADP changed, did not have both Timecard and Payroll in one report
				CASE
					WHEN [Pay Date] > '2016-04-24' THEN 'Payroll'
					ELSE [Type] 
				END
					AS status_type ,
			
				 ( SELECT TOP 1
                                        location_key
                                 FROM   dwh.data_location dl
                                 WHERE  dl.site_id = ah.Site
                                        AND dl.location_id_unique_flag = 1
                                        AND 	ah.Site IS NOT NULL
                               ) as location_key,
				ah.site,
				--**DQ**
					--Column not used, needs to be removed eventually
					( SELECT TOP 1
                            provider_key
                  FROM      dwh.data_provider prov
                  WHERE     prov.employee_key = de.employee_key
                            AND prov.employee_key IS NOT NULL
                ) AS provider_key,
				-- Blank, yREG, and EXTRA hours code are changed to REGLAR to be treated as clinic hours
                CASE
					WHEN ah.[Earnings Code Payroll] LIKE 'REGSAL' THEN 'REGLAR'
					WHEN [Pay Date] > '2016-04-24'
						 AND	([ah].[Earnings Code Payroll] LIKE ''
								OR [ah].[Earnings Code Payroll] LIKE 'yREG'
								OR [ah].[Earnings Code Payroll] LIKE 'EXTRA')  THEN 'REGLAR'
					ELSE [Earnings Code Timecard] 
				END 
					AS status_ec_tc ,
                CASE
					WHEN ah.[Earnings Code Payroll] LIKE 'REGSAL' THEN 'REGLAR'
					WHEN [Pay Date] > '2016-04-24'
						 AND	([ah].[Earnings Code Payroll] LIKE ''
								OR [ah].[Earnings Code Payroll] LIKE 'yREG'
								OR [ah].[Earnings Code Payroll] LIKE 'EXTRA')  THEN 'REGLAR'
					ELSE [Earnings Code Payroll] 
				END
					AS status_ec_pr ,
                COALESCE(ROUND([Rate], 0, 1), 0) AS status_rate ,
                CASE
					WHEN ah.[Earnings Code Payroll] LIKE 'REGSAL' THEN 'REGLAR'
					WHEN [Pay Date] > '2016-04-24'
						AND	([ah].[Earnings Code Payroll] LIKE ''
								OR [ah].[Earnings Code Payroll] LIKE 'yREG'
								OR [ah].[Earnings Code Payroll] LIKE 'EXTRA')  THEN 'REGLAR'
					ELSE [Earnings Code Timecard] 
				END 
					AS [Earnings Code Timecard] ,
                CASE
					WHEN ah.[Earnings Code Payroll] LIKE 'REGSAL' THEN 'REGLAR'
					WHEN [Pay Date] > '2016-04-24'
						 AND	([ah].[Earnings Code Payroll] LIKE ''
								OR [ah].[Earnings Code Payroll] LIKE 'yREG'
								OR [ah].[Earnings Code Payroll] LIKE 'EXTRA')  THEN 'REGLAR'
					ELSE [Earnings Code Payroll] 
				END
					AS [Earnings Code Payroll] ,
                [Rate] ,
                [Hours Payroll] AS [Hours Timecard] ,
                [Hours Payroll] ,
                [Dollars] ,
				ah.[Employee ID],
				ah.[Last Name],
				ah.Status,
				ah.[Worked Department]
				
               
		 
        INTO    #precomp
        FROM    etl.data_adp_hours ah
                Left JOIN dwh.data_employee_v2 de ON RIGHT(ah.[Employee ID], 6) = de.[File Number];
		      
		
		
		        
              
		--Create a composite key for employee status and rate
        SELECT  
		ROW_NUMBER() OVER ( ORDER BY x1.status_type , x2.status_ec_tc , x3.status_ec_pr , x4.status_rate ) AS employee_hours_comp_key ,
                x1.status_type ,
                x2.status_ec_tc ,
                x3.status_ec_pr ,
                x4.status_rate
        INTO    dwh.data_employee_hours_status
        FROM    ( SELECT DISTINCT
                            status_type
                  FROM      #precomp
                ) x1
                CROSS JOIN ( SELECT DISTINCT
                                    status_ec_tc
                             FROM   #precomp
                           ) x2
                CROSS JOIN ( SELECT DISTINCT
                                    status_ec_pr
                             FROM   #precomp
                           ) x3
                CROSS JOIN ( SELECT DISTINCT
                                    status_rate
                             FROM   #precomp
                           ) x4;
                



        SELECT  IDENTITY( INT, 1, 1 )  AS employee_hours_key ,
		        d.* ,
                employee_hours_comp_key
        INTO    dwh.data_employee_hours
        FROM    #precomp d
                LEFT JOIN dwh.data_employee_hours_status e ON e.status_type = d.status_type
                                                              AND e.status_ec_tc = d.status_ec_tc
                                                              AND e.status_ec_pr = d.status_ec_pr
                                                              AND e.status_rate = d.status_rate;
                     
					 
					 
					 
        ALTER TABLE dwh.data_employee_hours_status
        ALTER COLUMN employee_hours_comp_key BIGINT NOT NULL;                  

		ALTER TABLE dwh.data_employee_hours
        ALTER COLUMN [Pay Date] DATE  NULL;                  


        ALTER TABLE dwh.data_employee_hours_status
        ADD CONSTRAINT employee_hours_comp_key_pk PRIMARY KEY (employee_hours_comp_key);

		     ALTER TABLE dwh.data_employee_hours
        ADD CONSTRAINT employee_hours_key_pk PRIMARY KEY (employee_hours_key);

        DROP TABLE #precomp;

    END;
GO
