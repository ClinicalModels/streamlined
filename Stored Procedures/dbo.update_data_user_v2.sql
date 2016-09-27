SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_user_v2]
AS
 BEGIN


        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        IF OBJECT_ID('dbo.data_resource') IS NOT NULL
            DROP TABLE dbo.data_resource;

       IF OBJECT_ID('dbo.data_provider') IS NOT NULL
            DROP TABLE dbo.data_provider;

			
       IF OBJECT_ID('dbo.data_user_v2') IS NOT NULL
            DROP TABLE dbo.data_user_v2;



--Create a user table  and match up to employees
--Create a provider table and match up to users
--Create a Resource table and match up to user table (employees)


--Pull the name from the user table and build provider and resource filter tables

--Will need to restructure many of the exisiting reports to accomodate these changes


   SELECT   IDENTITY( INT, 1, 1 )  AS user_key,
   
                xr.[provider_id] AS self_provider_id,
			    ar.employee_key,
				um.[user_id] ,
                COALESCE(um.first_name,'') AS first_name ,
                                COALESCE(um.last_name, '') AS last_name ,
                                CASE WHEN CONCAT(COALESCE(um.last_name,  ''), ', ',
                                                 COALESCE(um.first_name,  '')) != ', '
                                     THEN CONCAT(COALESCE(um.last_name,''), ', ',
                                                 COALESCE(um.first_name,  ''))
                                     ELSE ''
                                END AS FullName 
        
             INTO #user
				FROM     [10.183.0.94].[NGProd].[dbo].[user_mstr] um
                                LEFT JOIN ( SELECT  provider_id ,
                                                    user_id
                                            FROM    [10.183.0.94].[NGProd].[dbo].[user_provider_xref]
                                            WHERE   [relationship_id] = '3FF021CC-6C25-4DBC-B7CE-2303A720C1D7'
                                          ) xr ON um.user_id = xr.user_id
                      LEFT JOIN  [sqlprod1\ghost].Prod_Ghost.dwh.data_employee_v2 ar ON REPLACE(UPPER(LEFT(um.first_name, 3)), '''', '') = REPLACE(UPPER(LEFT(ar.[Payroll First Name],
                                                                                                        3)), '''', '')
                                                      AND REPLACE(UPPER(um.last_name), '''', '') = REPLACE(UPPER(ar.[Payroll Last Name]),
                                                                                                        '''', '');


  SELECT   

                                prov.provider_id ,
						  ar.employee_key,
                                CASE WHEN COALESCE(prov.degree, '') != '' THEN 'Provider'
                                     ELSE 'Not Provider'
                                END AS role_status ,
                                COALESCE(prov.first_name,'') AS first_name ,
                                COALESCE( prov.last_name, '') AS last_name ,
                                CASE WHEN CONCAT(COALESCE( prov.last_name, ''), ', ',
                                                 COALESCE( prov.first_name, '')) != ', '
                                     THEN CONCAT(COALESCE(prov.last_name, ''), ', ',
                                                 COALESCE(prov.first_name, ''))
                                     ELSE ''
                                END AS FullName ,
                                COALESCE(prov.description, '') AS provider_name ,
                                COALESCE(prov.degree, '') AS degree ,
                                COALESCE(prov.[delete_ind], '') AS delete_ind 
                               
					
               INTO #provider
				       FROM     [10.183.0.94].[NGProd].[dbo].[provider_mstr] prov
					   LEFT JOIN [sqlprod1\ghost].Prod_Ghost.dwh.data_employee_v2 ar ON REPLACE(UPPER(LEFT(prov.first_name, 3)), '''', '') = REPLACE(UPPER(LEFT(ar.[Payroll First Name],
                                                                                                        3)), '''', '')
                                                      AND REPLACE(UPPER(prov.last_name), '''', '') = REPLACE(UPPER(ar.[Payroll Last Name]),
                                                                                                        '''', '');

                    



              --Select the location where provider had the most encounters over the past 3 months  
              SELECT   *
			  INTO #enc3m
                       FROM     ( SELECT    e.* ,
                                            ROW_NUMBER() OVER ( PARTITION BY e.rendering_provider_id ORDER BY e.rendering_provider_id, e.QTY DESC ) AS Most_enc
                                  FROM      ( SELECT    enc.rendering_provider_id ,
                                                        loc.location_name ,
                                                        COUNT(*) AS QTY
                                              FROM      [10.183.0.94].NGProd.dbo.patient_encounter enc
                                                        INNER JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON loc.location_id = enc.location_id
                                              WHERE     enc.billable_ind = 'Y'
                                                        AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 3
                                              GROUP BY  enc.rendering_provider_id ,
                                                        loc.location_name
                                            ) e
                                ) f
                       WHERE    f.Most_enc = 1
                    




               --Location where provider had second most encounters over the past 3 months
                  SELECT   *
                  INTO #enc3ms
				       FROM     ( SELECT    e.* ,
                                            ROW_NUMBER() OVER ( PARTITION BY e.rendering_provider_id ORDER BY e.rendering_provider_id, e.QTY DESC ) AS Most_enc
                                  FROM      ( SELECT    enc.rendering_provider_id ,
                                                        loc.location_name ,
                                                        COUNT(*) AS QTY
                                              FROM      [10.183.0.94].NGProd.dbo.patient_encounter enc
                                                        INNER JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON loc.location_id = enc.location_id
                                              WHERE     enc.billable_ind = 'Y'
                                                        AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 3
                                              GROUP BY  enc.rendering_provider_id ,
                                                        loc.location_name
                                            ) e
                                ) f
               
			   
			           WHERE    f.Most_enc = 2
               
			   
			   
			   
			    
                  SELECT   *
                       INTO #enc6m
					   FROM     ( SELECT    e.* ,
                                            ROW_NUMBER() OVER ( PARTITION BY e.rendering_provider_id ORDER BY e.rendering_provider_id, e.QTY DESC ) AS Most_enc
                                  FROM      ( SELECT    enc.rendering_provider_id ,
                                                        loc.location_name ,
                                                        COUNT(*) AS QTY
                                              FROM      [10.183.0.94].NGProd.dbo.patient_encounter enc
                                                        INNER JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON loc.location_id = enc.location_id
                                              WHERE     enc.billable_ind = 'Y'
                                                        AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 6
                                              GROUP BY  enc.rendering_provider_id ,
                                                        loc.location_name
                                            ) e
                                ) f
                       WHERE    f.Most_enc = 1
                 
				 
				 
		
                   SELECT   *
                       INTO #enc12m
					   FROM     ( SELECT    e.* ,
                                            ROW_NUMBER() OVER ( PARTITION BY e.rendering_provider_id ORDER BY e.rendering_provider_id, e.QTY DESC ) AS Most_enc
                                  FROM      ( SELECT    enc.rendering_provider_id ,
                                                        loc.location_name ,
                                                        COUNT(*) AS QTY
                                              FROM      [10.183.0.94].NGProd.dbo.patient_encounter enc
                                                        INNER JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON loc.location_id = enc.location_id
                                              WHERE     enc.billable_ind = 'Y'
                                                        AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 12
                                              GROUP BY  enc.rendering_provider_id ,
                                                        loc.location_name
                                            ) e
                                ) f
                       WHERE    f.Most_enc = 1
                     
                
                   SELECT  
                                res.resource_id ,
                          												 
res.phys_id,
                                res.description AS resource_name
					
            
        
		--Create an aggregate user_key with provider_id and user_id Null is not present in both
                       INTO #resource
					   FROM    [10.183.0.94].[NGProd].[dbo].[resources] res

           






            SELECT 
                    process.provider_id ,
					process.employee_key,
                    process.role_status ,
                    process.first_name ,
                    process.last_name ,
                    process.FullName ,
                    process.provider_name ,
                    IIF(CHARINDEX(' ',
                                  IIF(CHARINDEX(',', process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                 1,
                                                                                                 CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                 - 1)), 'Failed')) > 0, SUBSTRING(IIF(CHARINDEX(',',
                                                                                                        process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                        - 1)), 'Failed'),
                                                                                                        1,
                                                                                                        CHARINDEX(' ',
                                                                                                        IIF(CHARINDEX(',',
                                                                                                        process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                        - 1)), 'Failed'))
                                                                                                        - 1), IIF(CHARINDEX(',',
                                                                                                        process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                        - 1)), 'Failed')) AS LastName_cleaned ,
                    IIF(CHARINDEX(' ',
                                  IIF(CHARINDEX(',', process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                 CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                 + 1, 8000)), 'Failed')) > 0, SUBSTRING(IIF(CHARINDEX(',',
                                                                                                        process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                        CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                        + 1, 8000)), 'Failed'),
                                                                                                        1,
                                                                                                        CHARINDEX(' ',
                                                                                                        IIF(CHARINDEX(',',
                                                                                                        process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                        CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                        + 1, 8000)), 'Failed'))
                                                                                                        - 1), IIF(CHARINDEX(',',
                                                                                                        process.provider_name) > 0, LTRIM(SUBSTRING(process.provider_name,
                                                                                                        CHARINDEX(',',
                                                                                                        process.provider_name)
                                                                                                        + 1, 8000)), 'Failed')) AS FirstName_cleaned ,
                 
                    process.degree ,
                    process.delete_ind ,
                    CASE WHEN e3.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN 'Provider active in past 3 months'
                         WHEN e3.location_name IS  NULL
                              AND provider_id IS NOT NULL THEN 'Provider not active in past 3 months'
                         ELSE 'Unknown'
                    END AS active_3m_provider ,
                    CASE WHEN e3.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN e3.location_name
                         ELSE 'Unknown'
                    END AS primary_loc_3m_provider ,
                    CASE WHEN e3s.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN 'Provider active in past 3 months at secondary site'
                         WHEN e3s.location_name IS  NULL
                              AND provider_id IS NOT NULL THEN 'Provider not active in past 3 months at secondary site'
                         ELSE 'Unknown'
                    END AS active_3ms_provider ,
                    CASE WHEN e3s.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN e3s.location_name
                         ELSE 'Unknown'
                    END AS secondary_loc_3m_provider ,
                    CASE WHEN e6.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN 'Provider active in past 6 months'
                         WHEN e6.location_name IS  NULL
                              AND provider_id IS NOT NULL THEN 'Provider not active in past 6 months'
                         ELSE 'Unknown'
                    END AS active_6m_provider ,
                    CASE WHEN e6.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN e6.location_name
                         ELSE 'Unknown'
                    END AS primary_loc_6m_provider ,
                    CASE WHEN e12.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN 'Provider active in past 12 months'
                         WHEN e12.location_name IS  NULL
                              AND provider_id IS NOT NULL THEN 'Provider not active in past 12 months'
                         ELSE 'Unknown'
                    END AS active_12m_provider ,
                    CASE WHEN e12.location_name IS NOT NULL
                              AND provider_id IS NOT NULL THEN e12.location_name
                         ELSE 'Unknown'
                    END AS primary_loc_12m_provider 
                
              INTO    #provider2
            FROM    #provider process
                    LEFT JOIN #enc3m e3 ON process.provider_id = e3.rendering_provider_id
                    LEFT JOIN #enc3ms e3s ON process.provider_id = e3s.rendering_provider_id
                    LEFT JOIN #enc6m e6 ON process.provider_id = e6.rendering_provider_id
                    LEFT JOIN #enc12m e12 ON process.provider_id = e12.rendering_provider_id
                  


SELECT u.*, 1 AS ng_data INTO dbo.data_user_v2 FROM #user u 

SELECT p.*,user_key, user_id, ROW_NUMBER() OVER(PARTITION BY p.provider_id ORDER BY (SELECT NULL)) AS rownum INTO #provider3 FROM #provider2 p LEFT JOIN  dbo.data_user_v2 u ON p.provider_id=u.self_provider_id 

SELECT IDENTITY( INT, 1, 1 )  AS provider_key, * INTO dbo.data_provider FROM #provider3 WHERE rownum <2

SELECT  IDENTITY( INT, 1, 1 )  AS resource_key,r.*, p.provider_key INTO dbo.data_resource FROM #resource r LEFT JOIN dbo.data_provider p ON p.provider_id= r.phys_id
 

/*
/* **DQ** Since we are forced to match on name, we had employee_keys being missed because Payroll and Provider name were different,
this update brings in those specific keys by associating the spelling of their Provider name with the spelling of their Payroll Name
*/
UPDATE dbo.data_provider
SET  employee_key = CASE
						WHEN FullName LIKE'Poole, D.L.' THEN (SELECT TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE 'Poole, DL')	
						WHEN FullName LIKE'OHearn, Kate' THEN (SELECT TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE '%Hearn, Kate')	
						WHEN FullName LIKE'Towner-Winchester, Barbara' THEN (SELECT TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE 'Towner-Winchester, Barbara')	
						WHEN FullName LIKE'Bui, Thu' THEN (SELECT TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE 'Anh Bui, Thu')	
						WHEN FullName LIKE'Bianchi-Wojick, Joann' THEN (SELECT TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE 'Bianchi Wojick, Joann')	
						WHEN FullName LIKE'Petta Flores, Danielle' THEN (select TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE 'Dexter, Danielle Petta-Flores')	
						WHEN provider_name LIKE 'Wilson, Teshina' THEN (SELECT TOP 1 employee_key FROM dwh.data_employee_v2 WHERE [Payroll Name] LIKE 'Wilson, Teshina Nicole') 
					END
WHERE FullName IN ('Poole, D.L.', 'OHearn, Kate', 'Towner-Winchester, Barbara','Bui, Thu', 'Bianchi-Wojick, Joann', 'Petta Flores, Danielle')
OR provider_name LIKE 'Wilson, Teshina' --Has different provider name for eCW and NextGen sites, updating if for eCW site

	*/

    END;
GO
