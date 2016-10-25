SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_encounter]
AS
  BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        IF OBJECT_ID('dbo.data_encounter') IS NOT NULL
            DROP TABLE dbo.data_encounter;

        DECLARE @dt_beg CHAR(8) ,
            @dt_end CHAR(8) ,
            @prac_id CHAR(4);
  
        SET @dt_beg = CONVERT(CHAR(8), DATEADD(dd, -2, GETDATE()), 112);
        SET @dt_end = CONVERT(CHAR(8), GETDATE(), 112);

        SET @dt_beg = '20100301';


        WITH    qual_enc
                  AS ( SELECT DISTINCT
                                chg.source_id ,
                                qual_enc_ct = 1
                       FROM     [10.183.0.94].NGProd.dbo.charges chg
                                INNER JOIN [10.183.0.94].NGProd.dbo.patient_encounter enc ON chg.source_id = enc.enc_id
                                INNER JOIN [10.183.0.94].NGProd.dbo.service_item_mstr sim ON chg.service_item_id = sim.service_item_id
                                                                                             AND chg.service_item_lib_id = sim.service_item_lib_id
                                                                                             AND CONVERT(VARCHAR(8), enc.billable_timestamp, 112) >= sim.eff_date
                                                                                             AND CONVERT(VARCHAR(8), enc.billable_timestamp, 112) <= sim.exp_date
                       WHERE    chg.link_id IS NULL --given  has to be null for billable encounter 
                                AND ( sim.fqhc_enc_ind = 'Y'
                                      OR sim.self_pay_fqhc_ind = 'Y'
                                      OR sim.sliding_fee_fqhc_ind = 'Y'
                                    )
                                AND CONVERT(CHAR(8), enc.modify_timestamp, 112) BETWEEN @dt_beg AND @dt_end
                                AND ( CONVERT(VARCHAR(8), enc.billable_timestamp, 112) >= '20100301' ) -- This 20100301 is the merrit encounter import date
                     ),
                enc_data
                  AS ( SELECT   enc.enc_id ,
                                COALESCE(enc.enc_nbr,'') AS enc_nbr ,
								enc.person_id,
								enc.location_id,
								enc.rendering_provider_id,
								enc.created_by AS created_by_user_id,
                                ( SELECT TOP 1
                                            location_key
                                  FROM      dbo.data_location loc
                                  WHERE     loc.location_id_unique_flag = 1
                                            AND loc.location_id = enc.location_id
                                ) AS location_key ,
                                ( SELECT TOP 1
                                            user_key
                                  FROM      dbo.data_user prov
                                  WHERE     prov.provider_id = enc.rendering_provider_id
                                  ORDER BY  provider_name ,
                                            delete_ind
                                ) AS provider_key ,
                                                                
                                ( SELECT TOP 1
                                            per_mon_id
                                  FROM      dbo.data_person_nd_month per
								  --Only relevant to NG data currently, so ignore ECW per_mon_id
                                  WHERE     per.person_id = person_id
                                            AND per.first_mon_date = CAST(CONVERT(CHAR(6), enc.billable_timestamp, 112)
                                            + '01' AS DATE)
                                ) AS per_mon_id ,
                                ( SELECT TOP 1
                                            user_key
                                  FROM      dbo.data_user prov
                                  WHERE     prov.user_id = enc.created_by
                                ) AS enc_creator_key ,
                                CAST(enc.create_timestamp AS DATE) AS enc_cr_date ,
                                CAST(enc.modify_timestamp AS DATE) AS enc_md_date ,
                                enc_bill_date = CAST(enc.billable_timestamp AS DATE) ,
                                first_mon_date = CAST(CONVERT(CHAR(6), enc.billable_timestamp, 112) + '01' AS DATE) ,
                                billable_enc_ct = CASE WHEN enc.billable_ind = 'Y' THEN 1
                                                       ELSE 0
                                                  END ,
                                CASE WHEN ISNULL(q.qual_enc_ct, 0) = 1 THEN 1
                                     ELSE 0
                                END AS qual_enc_ct ,
                                enc_count = 1 ,
                                CASE WHEN enc.enc_status = 'U' THEN 'Unbilled'
                                     WHEN enc.enc_status = 'R' THEN 'Rebilled'
                                     WHEN enc.enc_status = 'H' THEN 'Historical'
                                     WHEN enc.enc_status = 'B' THEN 'Billed'
                                     WHEN enc.enc_status = 'D' THEN 'Bad Debt'
                                     ELSE 'Unknown'
                                END AS encounter_status ,
                                CASE WHEN enc.billable_ind = 'Y' THEN 'Billable'
                                     ELSE 'Not Billable'
                                END AS billable_ind ,
                                CASE WHEN ISNULL(q.qual_enc_ct, 0) = 1 THEN 'Qualified'
                                     ELSE 'Not Qualified'
                                END AS qualified_ind
                       FROM     [10.183.0.94].NGProd.dbo.patient_encounter enc
                                LEFT JOIN qual_enc q ON q.source_id = enc.enc_id
                       WHERE    CONVERT(CHAR(8), enc.modify_timestamp, 112) BETWEEN @dt_beg AND @dt_end
                                AND ( CONVERT(VARCHAR(8), enc.billable_timestamp, 112) >= '20100301' ) -- This 20100301 is the merrit encounter import date
                     ),
                enc_status_data
                  AS ( SELECT   ROW_NUMBER() OVER ( ORDER BY encounter_status , billable_ind , qualified_ind ) AS enc_comp_key ,
                                x1.encounter_status ,
                                x2.billable_ind ,
                                x3.qualified_ind
                       FROM     ( SELECT DISTINCT
                                            enc_data.encounter_status
                                  FROM      enc_data
                                ) x1
                                CROSS JOIN ( SELECT DISTINCT
                                                    enc_data.billable_ind
                                             FROM   enc_data
                                           ) x2
                                CROSS JOIN ( SELECT DISTINCT
                                                    enc_data.qualified_ind
                                             FROM   enc_data
                                           ) x3
                     )
            SELECT  IDENTITY( INT, 1, 1 )  AS enc_key ,
                    ed.enc_id ,
                    CAST(RIGHT('00000000000'+ LTRIM(RTRIM(ed.enc_nbr)),10) AS varchar(10)) AS  enc_nbr,
                    ed.person_id ,
                    ed.location_id ,
                    ed.rendering_provider_id ,
                    ed.created_by_user_id ,
                    ed.location_key ,
                    ed.provider_key ,
                    ed.per_mon_id ,
                    ed.enc_creator_key ,
                    ed.enc_cr_date ,
                    ed.enc_md_date ,
                    ed.enc_bill_date ,
                    ed.first_mon_date ,
                    ed.billable_enc_ct ,
                    ed.qual_enc_ct ,
                    ed.enc_count ,
                    ed.encounter_status ,
                    ed.billable_ind ,
                    ed.qualified_ind ,
                    esd.enc_comp_key ,
                    COALESCE((ed.encounter_status + ' ' + ed.billable_ind + ' ' + ed.qualified_ind),'') AS enc_comp_key_name
            INTO    dbo.data_encounter
            FROM    enc_data ed
                    LEFT JOIN enc_status_data esd ON ed.encounter_status = esd.encounter_status
                                                     AND ed.billable_ind = esd.billable_ind
                                                     AND ed.qualified_ind = esd.qualified_ind;

   
			
        ALTER TABLE dbo.data_encounter
        ADD CONSTRAINT enc_key_pk PRIMARY KEY (enc_key);

    END;
GO
