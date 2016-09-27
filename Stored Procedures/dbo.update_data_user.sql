SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_user]
AS
 BEGIN


        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        IF OBJECT_ID('dbo.data_user') IS NOT NULL
            DROP TABLE dbo.data_user;

			-- Use SELF reference provider_id to match against provider_table
        WITH    user_match
                  AS ( SELECT   um.* ,
                                xr.[provider_id] AS self_provider_id
                       FROM     [10.183.0.94].[NGProd].[dbo].[user_mstr] um
                                LEFT JOIN ( SELECT  provider_id ,
                                                    user_id
                                            FROM    [10.183.0.94].[NGProd].[dbo].[user_provider_xref]
                                            WHERE   [relationship_id] = '3FF021CC-6C25-4DBC-B7CE-2303A720C1D7'
                                          ) xr ON um.user_id = xr.user_id
                     ),
                provider
                  AS ( SELECT   *
                       FROM     [10.183.0.94].[NGProd].[dbo].[provider_mstr]
                     ),
                enc3m
                  AS ( SELECT   *
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
                     ),
                enc3ms
                  AS ( SELECT   *
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
                     ),
                enc6m
                  AS ( SELECT   *
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
                     ),
                enc12m
                  AS ( SELECT   *
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
                     ),
                process
                  AS ( SELECT   um.[user_id] ,
                                prov.provider_id ,
                                res.resource_id ,
                                CASE WHEN COALESCE(prov.degree, '') != '' THEN 'Provider'
                                     ELSE 'Not Provider'
                                END AS role_status ,
                                COALESCE(um.first_name, prov.first_name) AS first_name ,
                                COALESCE(um.last_name, prov.last_name, '') AS last_name ,
                                CASE WHEN CONCAT(COALESCE(um.last_name, prov.last_name, ''), ', ',
                                                 COALESCE(um.first_name, prov.first_name, '')) != ', '
                                     THEN CONCAT(COALESCE(um.last_name, prov.last_name, ''), ', ',
                                                 COALESCE(um.first_name, prov.first_name, ''))
                                     ELSE ''
                                END AS FullName ,
                                COALESCE(prov.description, res.description, '') AS provider_name ,
                                COALESCE(prov.degree, '') AS degree ,
                                COALESCE(prov.[delete_ind], '') AS delete_ind ,
                                res.description AS resource_name
					
            
        
		--Create an aggregate user_key with provider_id and user_id Null is not present in both
                       FROM     user_match um
                                FULL OUTER JOIN [10.183.0.94].[NGProd].[dbo].provider_mstr prov ON um.self_provider_id = prov.provider_id
                                FULL OUTER JOIN ( SELECT  TOP 1000000  *
                                                  FROM      [10.183.0.94].[NGProd].[dbo].[resources]
												  ORDER BY resource_id, create_timestamp desc

                                                --  WHERE     resource_type = 'Person'
                                                ) res ON um.self_provider_id = res.phys_id
                     )
            SELECT  IDENTITY( INT, 1, 1 )  AS user_key ,
                    process.user_id ,
                    process.provider_id ,
                    process.resource_id ,
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
                    process.resource_name ,
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
                    END AS primary_loc_12m_provider ,
                    ar.[File Number] AS hr_employee_id ,
                    ar.[Job Title] hr_job_title ,
                    ar.[Location] AS hr_location_name ,
                    ar.[Location Code] AS hr_location_id ,
                    ar.employee_key AS employee_key ,
                    ROW_NUMBER() OVER ( PARTITION BY process.provider_id ORDER BY provider_id, resource_id, user_id ) AS unique_provider_id_flag ,
                    ROW_NUMBER() OVER ( PARTITION BY process.resource_id ORDER BY provider_id, resource_id, user_id ) AS unique_resource_id_flag ,
                    ROW_NUMBER() OVER ( PARTITION BY process.user_id ORDER BY provider_id, resource_id, user_id ) AS unique_user_id_flag
            INTO    [dbo].[data_user]
            FROM    process
                    LEFT JOIN enc3m e3 ON process.provider_id = e3.rendering_provider_id
                    LEFT JOIN enc3ms e3s ON process.provider_id = e3s.rendering_provider_id
                    LEFT JOIN enc6m e6 ON process.provider_id = e6.rendering_provider_id
                    LEFT JOIN enc12m e12 ON process.provider_id = e12.rendering_provider_id
                    LEFT JOIN [sqlprod1\ghost].Prod_Ghost.dwh.data_employee_v2 ar ON REPLACE(UPPER(LEFT(process.first_name, 3)), '''', '') = REPLACE(UPPER(LEFT(ar.[Payroll First Name],
                                                                                                        3)), '''', '')
                                                      AND REPLACE(UPPER(process.last_name), '''', '') = REPLACE(UPPER(ar.[Payroll Last Name]),
                                                                                                        '''', '');

		


		--Need to make Employee Key Unique by Provider
		--So in order to do that Need to 


        UPDATE  dbo.data_user
        SET     dbo.data_user.employee_key = pd.employee_key
        FROM    ( SELECT    user_key ,
                            CASE WHEN ROW_NUMBER() OVER ( PARTITION BY employee_key ORDER BY provider_id, resource_id, user_id ) > 1
                                 THEN NULL
                                 ELSE employee_key
                            END AS employee_key
                  FROM      dbo.data_user
                ) pd
        WHERE   dbo.data_user.user_key = pd.user_key;
		
	

        UPDATE  dbo.data_user
        SET     dbo.data_user.employee_key = pd.employee_key
        FROM    ( SELECT    user_key ,
                            CASE WHEN employee_key IS NULL THEN 10000 + user_key
                                 ELSE employee_key
                            END AS employee_key
                  FROM      dbo.data_user
                ) pd
        WHERE   dbo.data_user.user_key = pd.user_key;
		
	



        ALTER TABLE dbo.data_user
        ADD CONSTRAINT user_key_pk PRIMARY KEY (user_key);
    



	

    END;
GO
