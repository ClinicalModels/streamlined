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
	


	   IF OBJECT_ID('dbo.data_person_dp_month') IS NOT NULL
            DROP TABLE dbo.data_person_dp_month

	   IF OBJECT_ID('dbo.data_person_cur') IS NOT NULL
            DROP TABLE dbo.data_person_cur
		
			
	   IF OBJECT_ID('tempdb..#person_list') IS NOT NULL
            DROP TABLE #person_list

	   IF OBJECT_ID('tempdb..#last_visit') IS NOT NULL
            DROP TABLE #last_visit

	   IF OBJECT_ID('tempdb..#person_cur') IS NOT NULL
            DROP TABLE #person_cur

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
                       FROM     dbo.data_appointment
                       WHERE    nbr_bill_enc = 1

		SELECT DISTINCT person_id
			   INTO #person_list
			   FROM dbo.data_person_nd_month


		--Pull info on a patient's last visit and next visit for the patient_cur table
		SELECT
			p.person_id,
			(SELECT TOP 1 enc_app_date
							FROM dbo.data_appointment app
							WHERE app.person_id = p.person_id
							AND app.nbr_bill_enc = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_enc_date,

			(SELECT TOP 1 enc_app_date
							FROM dbo.data_appointment app
							WHERE app.person_id = p.person_id
							AND app.nbr_appts = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_appt_date,

			(SELECT TOP 1 prov.FullName
							FROM dbo.data_appointment app
							INNER JOIN dbo.data_provider prov ON prov.provider_key = app.provider_key
							WHERE app.person_id = p.person_id
							AND app.nbr_bill_enc = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_enc_provider,

			(SELECT TOP 1 prov.FullName
							FROM dbo.data_appointment app
							INNER JOIN dbo.data_provider prov ON prov.provider_key = app.provider_key
							WHERE app.person_id = p.person_id
							AND app.nbr_appts = 1
							AND app.enc_app_date < GETDATE()
							ORDER BY app.enc_app_date DESC) AS last_appt_provider,

			(SELECT TOP 1 enc_app_date
							FROM dbo.data_appointment app
							WHERE app.person_id = p.person_id
							AND app.nbr_appts = 1
							AND app.enc_app_date >= GETDATE()
							ORDER BY app.enc_app_date ASC) AS next_appt_date,

			(SELECT TOP 1 prov.FullName
							FROM dbo.data_appointment app
							INNER JOIN dbo.data_provider prov ON prov.provider_key = app.provider_key
							WHERE app.person_id = p.person_id
							AND app.nbr_appts = 1
							AND app.enc_app_date >= GETDATE()
							ORDER BY app.enc_app_date ASC) AS next_appt_provider


			INTO #last_visit
			FROM #person_list p


		SELECT [per_mon_id],[person_key],[person_id],[first_mon_date],[mh_cur_key],[pcp_cur_key]
	  ,[status_cur_key],[First_enc_age_months],[nbr_new_pt],[nbr_pt_seen_office_ever],[nbr_pt_deceased]
      ,[age_cur],[dob],[full_name],[first_name],[last_name],[middle_name],[address_line_1],[address_line_2]
      ,[city],[state],[zip],[home_phone],[sex],[ssn],[alt_phone],[marital_status],[race],[ethnicity]
      ,[language],[disability_1],[disability_2],[homeless_status],[homeless_count],[med_rec_nbr]
      ,[chart_create_date],[chart_create_user],[person_create_date],[person_create_user],[hedis_crc_denom]
      ,[hedis_bc_denom],hedis_bp_denom,[hedis_crc_num],[hedis_bc_num],[hedis_bp_num]
INTO #person_cur
FROM [sharepoint_dev].[dbo].[data_person_nd_month]
WHERE first_mon_date = CAST(CONVERT(VARCHAR(6),getdate(),112)+'01' AS DATE)





            SELECT 
				dp.[per_mon_id]
				,dp.[person_key]
				,dp.[person_id]
				,dp.[first_mon_date]	
				,dp.hedis_crc_denom
				,dp.hedis_bc_denom
				,dp.hedis_bp_denom
				,dp.hedis_crc_num
				,dp.hedis_bc_num
				,dp.hedis_bp_num
				,dp.[expired_date]				
				,dp.[hedis_last_colon]
				,dp.[hedis_last_sigmoid]
				,dp.[hedis_last_fit]
				,dp.[hedis_last_mammo]
				,dp.[mh_hx_key]
				,dp.[pcp_hx_key]
				,dp.[status_hx_key]
				,dp.[nbr_pt_deceased_this_month]
				,dp.[patient_vintage]
				,dp.[age_hx]
				,dp.[cr_first_office_enc_date],
					--Checks if patients had an encounter over a certain period of time, making them active by LifeLong standards
					--person_key was created specifically to use in this situation, as it is an ID field which is not null for any patient
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_3m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 5 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_6m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 11 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_12m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 17 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_18m ,
                    MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 23 PRECEDING AND CURRENT ROW ) AS nbr_pt_act_24m ,
                    IIF(LAG(dp.mh_hx_key, 1) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC ) != dp.mh_hx_key, 1, 0) AS nbr_pt_mh_change ,
                    IIF(LAG(dp.pcp_hx_key, 1) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC ) != dp.pcp_hx_key, 1, 0) AS nbr_pt_pcp_change ,
                    IIF(MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ) = 0, 1, 0) AS nbr_pt_never_active

            INTO #temp1
            FROM    dbo.data_person_nd_month dp
                    LEFT JOIN #enc_app ea ON ea.per_mon_id = dp.per_mon_id;

--clean up zip data by matching first 5 digits to zip data from a clean list of zip codes
UPDATE  p

    set  zip = (SELECT TOP 1 ez.zipcode FROM dbo.data_zipcode ez WHERE LEFT(p.[zip],5) = LEFT(ez.zipcode,5) )

FROM  #person_cur p

--Any patients not listed active in a period are listed as inactive
SELECT t.*, 
                    CASE WHEN COALESCE(t.nbr_pt_act_3m,0)=0 THEN 1 ELSE 0 end AS nbr_pt_inact_3m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_6m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_6m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_12m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_12m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_18m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_18m ,
                    CASE WHEN COALESCE(t.nbr_pt_act_24m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_24m

 INTO dbo.data_person_dp_month 
 FROM #temp1 t

 Select 
	 p.*,
	 --concatenate address fields into a long form address, to be used in geocoding reports
		p.[address_line_1] +' ' +p.[address_line_2]+' '+p.[city]+' '+ p.[state]+' '+p.[zip] AS [Address Full],
	 v.last_enc_date,
	v.last_appt_date,
	v.last_enc_provider,
	v.last_appt_provider,
	v.next_appt_date,
v.next_appt_provider
 INTO dbo.data_person_cur 
 FROM #person_cur p
 LEFT JOIN #last_visit v ON v.person_id = p.person_id

		ALTER TABLE dbo.data_person_cur
        ADD CONSTRAINT person_key_pk32 PRIMARY KEY (person_key);

        ALTER TABLE dbo.data_person_dp_month
        ADD CONSTRAINT per_mon_id_pk32 PRIMARY KEY (per_mon_id);

    END;
GO
