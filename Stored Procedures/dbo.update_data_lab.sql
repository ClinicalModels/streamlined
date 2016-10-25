SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_lab]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


		IF OBJECT_ID('tempdb..#temp_lab') IS NOT NULL 
		DROP TABLE #temp_lab

	IF OBJECT_ID('tempdb..#lab_range') IS NOT NULL 
		DROP TABLE #lab_range

			IF OBJECT_ID('tempdb..#duplicateLabsResult') IS NOT NULL 
				DROP TABLE 	#duplicateLabsResult
	

	IF OBJECT_ID('tempdb..#lab_final') IS NOT NULL 
		DROP TABLE #lab_final

	IF OBJECT_ID('tempdb..#rekey') IS NOT NULL 
		DROP TABLE #rekey




--Grab any orders modified within the past day
SELECT 
	   
       app.enc_appt_key,
       per.per_mon_id,
	   per.person_key,
	   --Bringing in keys, names, and also IDs
	   --IDs are to be used for updating the keys daily once this 
	   prov.provider_key AS ordering_prov_key,
	   ord.ordering_provider AS ordering_prov_id,
	   prov.FullName AS ordering_provider_name,
	   creat.user_key AS create_user_key,
	   creat.user_id AS create_user_id,
	   creat.FullName AS create_user_name,
	   ord.modified_by AS mod_user_id,
	   mod.user_key AS mod_user_key,
	   mod.FullName AS mod_user_name
      ,ord.[order_num]
      ,ord.[test_status]
      ,ord.[ngn_status]
      ,p.[test_desc]
      ,ord.[delete_ind] AS ord_delete_ind
      ,ord.[order_control]
      ,ord.[order_priority]
      ,ord.[time_entered]
      ,ord.[spec_action_code] --Don't know what this field is
      ,ord.[billing_type] --Don't know what this field is
      ,ord.[clinical_info]
      ,ord.[cancel_reason]
      ,ord.[ufo_num]
      ,ord.[lab_id]
      ,ord.[create_timestamp] AS order_create_date
      ,ord.[modify_timestamp] AS order_modify_date
      ,ord.[generated_by]
      --,ord.[paq_provider_id]
      --,ord.[referring_provider_id]
      ,CASE
		WHEN ord.[order_type] LIKE 'L' THEN 'Lab'
		ELSE 'Radiology'
	   END
		AS order_type
      ,ord.[documents_ind]
      --,ord.[signoff_comments_ind]
      ,ord.[intrf_msg]
      ,
	  CASE
		WHEN ord.[completed_ind] = 'Y' THEN 'Complete'
		ELSE 'Incomplete'
	  END
		AS ng_completed_ind
	  ,CASE
		WHEN ord.test_desc LIKE 'HIV%' THEN 1
		ELSE 0
	  END
		AS hiv_test_count,
		CASE
		WHEN ord.test_desc LIKE 'HIV%' THEN 'HIV'
		ELSE 'Other'
	  END
		AS test_ordered,
		--Begin result fields
		res.[unique_obr_num]
      ,res.[value_type]
      ,res.[obs_id]
	  ,res.[loinc_code]
      ,res.[observ_value]
	  --ISNUMERIC() wasn't working, so this formula was created to create a decimal value from the result if possible
	  ,Try_CAST( LEFT(SUBSTRING(observ_value, PATINDEX('%[0-9.]%', observ_value), 8000),
		PATINDEX('%[^0-9.]%', SUBSTRING(observ_value, PATINDEX('%[0-9.]%', observ_value), 8000) + 'X') -1) AS DECIMAL(10,2)) 
		AS cleaned_value
      ,res.[units]
      ,res.[ref_range]
      ,res.[abnorm_flags] --abnorm flags 
      ,res.[nature_abnorm_chk1] -- NULL or 'N'
      ,res.[observ_result_stat]
      ,res.[last_change_dt]
      ,res.[obs_date_time]
      ,res.[prod_id_code1]
      ,res.[prod_id_code1_txt]
      ,res.[signed_off_ind]
      ,res.[result_desc]
      ,res.[delete_ind] AS res_delete_ind
      ,res.[comment_ind]
      ,res.[result_seq_num] --65536 or NULL
      ,res.[created_by]
      ,res.[create_timestamp] AS result_date
      ,res.[modified_by] 
      ,res.[modify_timestamp] AS result_mod_date
      ,res.[clinical_name]
      --,res.[result_comment] --Adds 10 minutes to the procedure, considering dropping it
      ,res.[units_batt_id],
	  --Couldn't find a distinctive code for an HIV test/result, so matching on test
	  CASE
		WHEN res.clinical_name like 'HIV%'
		and res.observ_value like '%POSITIVE%' THEN 1
		ELSE 0
	  END
		AS hiv_pos_res,
	  CASE
	   WHEN result_desc LIKE 'HIV%'
			AND (observ_value LIKE 'Reactive' 
			OR observ_value LIKE '%dly reactive' --Both Reapeatedly and rptdly show up in results
			OR observ_value LIKE 'INCONCLUSIVE') THEN 1
	   ELSE 0
	  END 
		AS hiv_inc_res,
	  CASE
		WHEN res.result_desc LIKE '%cd4%'
			OR res.result_desc LIKE '%cd3%'
			OR res.result_desc LIKE '%cd8%' THEN 1
		ELSE 0
	  END
		AS t_cell_test,
	  res.[obx_seq_num] AS order_rank


  INTO #temp_lab
  FROM [10.183.0.94] .[NGProd]. [dbo].[lab_nor] ord 
  LEFT JOIN [10.183.0.94] .[NGProd].[dbo].[lab_results_obr_p] p WITH(NOLOCK) ON ord.order_num=p.ngn_order_num
  LEFT JOIN [10.183.0.94] .[NGProd]. [dbo].lab_results_obx res WITH(NOLOCK) ON p.unique_obr_num=res.unique_obr_num --bridge lab table 
  LEFT JOIN dbo. data_appointment app  ON ord.enc_id = app.enc_id
  LEFT JOIN dbo.data_person_nd_month per ON (ord.person_id = per.person_id AND per.first_mon_date=CAST(CONVERT(CHAR(6),ord.create_timestamp,112)+'01' AS date))
  LEFT JOIN dbo.data_provider prov ON prov.provider_id=ord.ordering_provider
  LEFT JOIN dbo.data_user_v2 creat   ON creat.user_id=ord.created_by
  LEFT JOIN dbo.data_user_v2 mod  ON mod.user_id=ord.modified_by
  WHERE res.modify_timestamp >= (GETDATE() - 1) --Pull only Results or Orders modified within the last 24 hours
  OR ord.modify_timestamp >= (GETDATE() - 1)
  AND (res.observ_value NOT LIKE '%PENDING%') --somehow final table has pending result values 




  --Add a primary key, calculate ranges for the chronic conditions we are currently tracking
  SELECT
	res.*,
	CASE
		WHEN res.cleaned_value IS NOT NULL THEN CAST(res.cleaned_value AS VARCHAR) + ' ' + res.units
		ELSE NULL
	  END
		AS value_long,
	CASE
		WHEN obs_id NOT LIKE '%cd4%'
			OR units NOT LIKE 'cells/uL' THEN NULL
		WHEN cleaned_value < 200 THEN 'Below 200'
		WHEN cleaned_value > 500 THEN 'Above 500'
		ELSE '200 to 500'
	END
		AS cd4_cell_range,
	--If running a hemoglobin a1c test for diabetes, record the range
	CASE
		WHEN 
			res.result_desc NOT LIKE '%a1c%'
			OR res.cleaned_value IS NULL
			OR res.cleaned_value > 15
			OR res.cleaned_value < 4 THEN NULL
		WHEN res.cleaned_value <= 15
			AND res.cleaned_value >=14 THEN '14 to 15'
		WHEN res.cleaned_value < 14
			AND res.cleaned_value >= 13 THEN '13 to 13.9'
		WHEN res.cleaned_value < 13
			AND res.cleaned_value >= 12 THEN '12 to 12.9'
		WHEN res.cleaned_value < 12
			AND res.cleaned_value >= 11 THEN '11 to 11.9'
		WHEN res.cleaned_value < 11
			AND res.cleaned_value >= 10 THEN '10 to 10.9'
		WHEN res.cleaned_value < 10
			AND res.cleaned_value >= 9 THEN '9 to 9.9'
		WHEN res.cleaned_value < 9
			AND res.cleaned_value >= 8 THEN '8 to 8.9'
		WHEN res.cleaned_value < 8 
			AND res.cleaned_value >= 7 THEN '7 to 7.9'
		WHEN res.cleaned_value < 7
			AND res.cleaned_value >= 6.6 THEN '6.6 to 6.9'
		WHEN res.cleaned_value < 6.6
			AND res.cleaned_value >= 5.8 THEN '5.8 to 6.5'
		ELSE '4 to 5.7'
	END
		AS hb_a1c_range,
	--The range 5.8-6.5 is pre-diabetic
	CASE
		WHEN res.result_desc NOT LIKE '%a1c%' THEN 0
		WHEN res.cleaned_value < 6.6
			AND res.cleaned_value >= 5.8 THEN 1
		ELSE 0
	END
		AS pre_diab_flag ,
	 CASE
		WHEN res.clinical_name like 'HIV%'
		and res.observ_value like '%POSITIVE%' THEN 'HIV Positive'
		WHEN result_desc LIKE 'HIV%'
			AND (observ_value LIKE 'Reactive' 
			OR observ_value LIKE '%dly reactive' --Both Reapeatedly and rptdly show up in results
			OR observ_value LIKE 'INCONCLUSIVE') THEN 'HIV Preliminary Positive'
		WHEN result_desc LIKE '%a1c%'
			AND res.cleaned_value < 6.6
			AND res.cleaned_value >= 5.8 THEN 'Diabetes'
	END
		AS lab_result_dx,
	CASE 
		WHEN res.obs_id IS NOT NULL THEN ROW_NUMBER() OVER ( PARTITION BY res.person_key, res.obs_id ORDER BY res.result_date DESC ) 
		ELSE NULL
	END
		AS Recency,
	CASE
		--Any order without a result will still be distinct, as only multiple results duplicate an order row
		WHEN res.order_rank = 1
			OR res.obs_id IS NULL THEN 1
		ELSE 0
	END
		AS count_distinct_order 
	--CASE
	--	WHEN res.result_desc LIKE '%a1c%' AND res.cleaned_value > 9.0  THEN 1
	--	ELSE 0
	--END
	--	AS uds_dm2_lab,
	--YEAR(res.result_date) AS uds_measure_year,
	--ROW_NUMBER() OVER(PARTITION BY person_key,YEAR(res.result_date) ORDER BY result_date DESC) AS uds_dm2_recency
  INTO #lab_range
  FROM #temp_lab res

	-- Final step creates dwh table and adds type/range columns to hold the values we are tracking, instead of individual columns for each type
	--Also adds our own tracking flag for complete, based off whether a result exists for a given order. For comparison against NG
    SELECT 
		IDENTITY(INT,1,1) AS lab_order_key,
		f.*,
		CASE
			WHEN f.cd4_cell_range IS NOT NULL THEN 'CD4 Cells'
			WHEN f.hb_a1c_range IS NOT NULL THEN 'Hemoglobin A1C'
			ELSE 'Other'
		END
			AS type,
		CASE
			WHEN f.cd4_cell_range IS NOT NULL THEN f.cd4_cell_range
			WHEN f.hb_a1c_range IS NOT NULL THEN f.hb_a1c_range
			ELSE NULL 
		END
			AS range,
		CASE
			WHEN f.result_date IS NOT NULL
				AND f.count_distinct_order = 1 THEN 1
			ELSE 0
		END
			AS count_complete_order
  INTO #lab_final
  FROM #lab_range f


--Remove any lab row which has a corresponding order_num in the temp table, so no duplicates occur
 DELETE FROM dbo.data_labs WHERE order_num IN (SELECT order_num FROM #lab_final)


 --Insert all the updated rows into the dwh table
 INSERT INTO dbo.data_labs
         ( lab_ord_key,
           enc_appt_key ,
           per_mon_id ,
           person_key ,
           ordering_prov_key ,
           ordering_prov_id ,
           ordering_provider_name ,
           create_user_key ,
           create_user_id ,
           create_user_name ,
           mod_user_id ,
           mod_user_key ,
           mod_user_name ,
           order_num ,
           test_status ,
           ngn_status ,
           test_desc ,
           ord_delete_ind ,
           order_control ,
           order_priority ,
           time_entered ,
           spec_action_code ,
           billing_type ,
           clinical_info ,
           cancel_reason ,
           ufo_num ,
           lab_id ,
           order_create_date ,
           order_modify_date ,
           generated_by ,
           order_type ,
           documents_ind ,
           intrf_msg ,
           ng_completed_ind ,
           hiv_test_count ,
		   test_ordered,
           unique_obr_num ,
           value_type ,
           obs_id ,
           loinc_code ,
           observ_value ,
           cleaned_value ,
           units ,
           ref_range ,
           abnorm_flags ,
           nature_abnorm_chk1 ,
           observ_result_stat ,
           last_change_dt ,
           obs_date_time ,
           prod_id_code1 ,
           prod_id_code1_txt ,
           signed_off_ind ,
           result_desc ,
           res_delete_ind ,
           comment_ind ,
           result_seq_num ,
           created_by ,
           result_date ,
           modified_by ,
           result_mod_date ,
           clinical_name ,
           units_batt_id ,
           hiv_pos_res ,
           hiv_inc_res ,
           t_cell_test ,
           order_rank ,
           value_long ,
           cd4_cell_range ,
           hb_a1c_range ,
           pre_diab_flag ,
           Recency ,
           count_distinct_order ,
           lab_result_dx ,
           type ,
           range ,
           count_complete_order
		   --uds_dm2_lab,
		   --uds_measure_year,
		   --uds_dm2_recency,
		   --uds_dm2_numerator_flag
		 
         )
SELECT
		lab_order_key,
		 enc_appt_key ,
          per_mon_id ,
          person_key ,
          ordering_prov_key ,
          ordering_prov_id ,
          ordering_provider_name ,
          create_user_key ,
          create_user_id ,
          create_user_name ,
          mod_user_id ,
          mod_user_key ,
          mod_user_name ,
          order_num ,
          test_status ,
          ngn_status ,
          test_desc ,
          ord_delete_ind ,
          order_control ,
          order_priority ,
          time_entered ,
          spec_action_code ,
          billing_type ,
          clinical_info ,
          cancel_reason ,
          ufo_num ,
          lab_id ,
          order_create_date ,
          order_modify_date ,
          generated_by ,
		  order_type,
          documents_ind ,
          intrf_msg ,
		  ng_completed_ind,
		  hiv_test_count,
		  test_ordered,
          unique_obr_num ,
          value_type ,
          obs_id ,
          loinc_code ,
          observ_value ,
		  cleaned_value,
          units ,
          ref_range ,
          abnorm_flags ,
          nature_abnorm_chk1 ,
          observ_result_stat ,
          last_change_dt ,
          obs_date_time ,
          prod_id_code1 ,
          prod_id_code1_txt ,
          signed_off_ind ,
          result_desc ,
          res_delete_ind ,
          comment_ind ,
          result_seq_num ,
          created_by ,
          result_date ,
          modified_by ,
          result_mod_date ,
          clinical_name ,
          units_batt_id ,
		  hiv_pos_res,
		  hiv_inc_res,
		  t_cell_test,
          order_rank,
		  value_long,
		  cd4_cell_range,
		  hb_a1c_range,
		  pre_diab_flag,
		  Recency,
		  count_distinct_order,
		  lab_result_dx,
		  type,
		  range,
		  count_complete_order
		  --uds_dm2_lab,
		  --uds_measure_year,
		  --uds_dm2_recency,0
		  
FROM #lab_final


--Each order_num is given a new order key to be used in the next step
SELECT 
	IDENTITY(INT,1,1) AS order_key_new,
	order_num
into #rekey
FROM dbo.data_labs



--All the keys need to be updated as the tables they come from are rebuilt daily
UPDATE lab 
	SET 
		lab.lab_ord_key = r.order_key_new, --Orders wil be updated with a new unique order key
		lab.enc_appt_key = app.enc_appt_key,
       lab.per_mon_id=per.per_mon_id,
	   lab.person_key =per.person_key,
	   lab.ordering_prov_key = prov.provider_key ,
	   lab.ordering_provider_name=prov.FullName,
	   lab.create_user_key=creat.user_key,
	   lab.create_user_name=creat.FullName ,
	   lab.mod_user_key=mod.user_key,
	   lab.mod_user_name=mod.FullName
FROM dbo.data_labs lab
LEFT JOIN #rekey r ON r.order_num = lab.order_num
LEFT JOIN dbo.data_appointment app ON app.enc_id=lab.enc_id
LEFT JOIN dbo.data_person_dp_month per ON (per.person_id=lab.person_id AND per.first_mon_date=CAST(CONVERT(CHAR(6),lab.order_create_date,112)+'01' AS date))
LEFT JOIN dbo.data_provider prov ON prov.provider_id=lab.ordering_prov_id
LEFT JOIN dbo.data_user_v2 creat   ON creat.user_id=lab.create_user_id
LEFT JOIN dbo.data_user_v2 mod  ON mod.user_id=lab.mod_user_id



--this will eliminate the dublicate lab result. delete all the dublicate lab results and keep the most recent one 
--***DQ*** the lab table end up having dublicate lab results. this will clean up dublciate lab results

 SELECT l.lab_res_key INTO #duplicateLabsResult
	FROM 
	(

		SELECT res.lab_res_key,(ROW_NUMBER() OVER(PARTITION BY res.person_id,res.obs_id,res.observ_value,res.result_desc,CAST(res.result_date AS DATE) ORDER BY res.result_date desc)) AS rn 
		FROM dbo.data_labs res
		WHERE  (res.observ_value NOT LIKE '%PENDING%')AND (res.person_id IS NOT NULL) --somehow final table has pending result values

	) as l
	WHERE  l.rn>1

--Cleaing up the dublicate data 
delete FROM dbo.data_labs  
WHERE (lab_res_key in(SELECT DISTINCT lab_res_key FROM #duplicateLabsResult)) or  (observ_value  LIKE '%PENDING%') --somehow final table has pending result values 



--------------------This procedure added for UDS Diabetes--------------------------------


--SELECT *
--FROM dbo.data_labs  
--WHERE (lab.units='%' AND lab.cleaned_value>9  AND lab.[type] LIKE '%Hemoglobin A1C%')
--Number of adult patients whose most recent hemoglobin A1c level during the measurement year is > 9% 
--OR who had no test during the year among those patients included in the denominator


--ALTER TABLE [dwh].[data_patient_dx_svc] ADD uds_dm2_numerator_flag int NULL


--UPDATE x
--	SET x.uds_dm2_numerator_flag = 
--		CASE
--			--In denominator and most recent a1c lab in the past year is > 9%
--			WHEN  x.[UDS Diabetes Denominator]=1
--			AND x.recency = 1
--			AND (SELECT TOP 1 l.uds_dm2_lab
--				FROM dbo.data_labs l
--				WHERE l.result_date >= DATEADD(MONTH,-12,x.create_date)
--				ORDER BY l.result_date DESC) = 1  THEN 1
--			--In denominator and no a1c lab in the past year
--			WHEN x.[UDS Diabetes Denominator]=1
--			AND x.recency = 1
--			AND (SELECT TOP 1 person_key
--							FROM dbo.data_labs l
--							WHERE l.result_date >= DATEADD(month, -2, x.create_date)
--							AND l.type LIKE 'Hemoglobin A1C') IS NULL THEN 1
--			ELSE 0
--		END 

--FROM [dwh].[data_patient_dx_svc] x


END


GO
