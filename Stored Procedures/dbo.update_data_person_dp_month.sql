SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_person_dp_month]
AS
 BEGIN

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
       IF OBJECT_ID('dwh.data_person_dp_month') IS NOT NULL
            DROP TABLE dwh.data_person_dp_month

	   IF OBJECT_ID('tempdb..#person_list') IS NOT NULL
            DROP TABLE #person_list

	   IF OBJECT_ID('tempdb..#last_visit') IS NOT NULL
            DROP TABLE #last_visit

     --Ok First go to the enc and appt table and grab all the per_mon_id with nbr_billable_enc =1
     --Then create a lagging variable for different counts
     --Then save back to the table dp table.
     --Then create new fact table with that data

     --Add counts of PCP changes (Probably should do that in NP)
     --Add countts of Medical Home Changes

        DECLARE @build_dt_start VARCHAR(8)

        SET @build_dt_start = '20100301';

         SELECT DISTINCT per_mon_id ,
                                nbr_bill_enc
                       INTO #enc_app
                       FROM     dwh.data_appointment
                       WHERE    nbr_bill_enc = 1

		SELECT DISTINCT person_key
			   INTO #person_list
			   FROM dwh.data_person_nd_month

		SELECT
			p.person_key,
			(SELECT TOP 1 enc_app_date
							FROM dwh.data_appointment app
							WHERE app.person_key = p.person_key
							AND app.nbr_bill_enc = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_enc_date,

			(SELECT TOP 1 enc_app_date
							FROM dwh.data_appointment app
							WHERE app.person_key = p.person_key
							AND app.nbr_appts = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_appt_date,

			(SELECT TOP 1 prov.FullName
							FROM dwh.data_appointment app
							INNER JOIN dwh.data_provider prov ON prov.provider_key = app.provider_key
							WHERE app.person_key = p.person_key
							AND app.nbr_bill_enc = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_enc_provider,

			(SELECT TOP 1 prov.FullName
							FROM dwh.data_appointment app
							INNER JOIN dwh.data_provider prov ON prov.provider_key = app.provider_key
							WHERE app.person_key = p.person_key
							AND app.nbr_appts = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_appt_provider,

			(SELECT TOP 1 enc_app_date
							FROM dwh.data_appointment app
							WHERE app.person_key = p.person_key
							AND app.nbr_appts = 1
							AND app.enc_app_date >= GETDATE()
							ORDER BY app.enc_app_date ASC) AS next_appt_date,

			(SELECT TOP 1 prov.FullName
							FROM dwh.data_appointment app
							INNER JOIN dwh.data_provider prov ON prov.provider_key = app.provider_key
							WHERE app.person_key = p.person_key
							AND app.nbr_appts = 1
							AND app.enc_app_date >= GETDATE()
							ORDER BY app.enc_app_date ASC) AS next_appt_provider


			INTO #last_visit
			FROM #person_list p





            SELECT 
                    dp.* ,
					--Checks if patients had an encounter over a certain period of time, making them active by LifeLong standards
					--person_key was created specifically to use in this situation, as it is an ID field which is not null for any patient
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_3m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 5 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_6m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 11 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_12m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 17 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_18m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 23 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_24m ,
                    IIF(LAG(dp.mh_hx_key, 1) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC ) != dp.mh_hx_key, 1, 0) AS nbr_pt_mh_change ,
                    IIF(LAG(dp.pcp_hx_key, 1) OVER ( PARTITION BY dp.person_key ORDER BY dp.first_mon_date ASC ) != dp.pcp_hx_key, 1, 0) AS nbr_pt_pcp_change ,
                    IIF(MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_key ) = 0, 1, 0) AS nbr_pt_never_active

            INTO #temp1
            FROM    dwh.data_person_nd_month dp
                    LEFT JOIN #enc_app ea ON ea.per_mon_id = dp.per_mon_id;

--clean up zip data by matching first 5 digits to zip data from a clean list of zip codes
UPDATE  dp

    set  zip = (SELECT TOP 1 ez.zipcode FROM etl.data_zipcode ez WHERE LEFT(dp.[zip],5) = LEFT(ez.zipcode,5) )

FROM  #temp1 dp

--Any patients not listed active in a period are listed as inactive
SELECT t.*, 
		--concatenate address fields into a long form address, to be used in geocoding reports
		t.[address_line_1] +' ' +t.[address_line_2]+' '+t.[city]+' '+ t.[state]+' '+t.[zip] AS [Address Full],
                    CASE WHEN COALESCE(t.nbr_pt_act_3m,0)=0 THEN 1 ELSE 0 end AS nbr_pt_inact_3m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_6m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_6m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_12m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_12m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_18m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_18m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_24m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_24m,
					v.last_enc_date,
					v.last_appt_date,
					v.last_enc_provider,
					v.last_appt_provider,
					v.next_appt_date,
					v.next_appt_provider

 INTO dwh.data_person_dp_month 
 FROM #temp1 t
 LEFT JOIN #last_visit v ON v.person_key = t.person_key 
 

        ALTER TABLE Prod_Ghost.dwh.data_person_dp_month
        ADD CONSTRAINT per_mon_id_pk32 PRIMARY KEY (per_mon_id);

    END;
GO
