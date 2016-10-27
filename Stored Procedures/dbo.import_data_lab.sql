SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[import_data_lab]
AS
BEGIN 

-- =============================================
-- Author:		<Julius Abate>
-- Create date: <April 3, 2016>
-- Dependant On: person_dp_month, appointment, user_v2
-- Runtime 31 minutes w/o result comments, 41 with
/* Description:	
Procedure pulls lab orders into
the dbo. Also pull lab results with the key
corresponding to the lab order.
*/
-- =============================================


	IF OBJECT_ID('dbo.data_labs') IS NOT NULL
		DROP TABLE dbo.data_labs
	IF OBJECT_ID('tempdb..#temp_ord') IS NOT NULL
		DROP TABLE #temp_ord
	IF OBJECT_ID('tempdb..#temp_lab') IS NOT NULL
		DROP TABLE #temp_lab
	IF OBJECT_ID('tempdb..#lab_final') IS NOT NULL
		DROP TABLE #lab_final
/*
Currently tracking labs results based on text match in the description,
but considering the move to loinc codes. Have to first do some digging to
see how consistently the codes are used/generated  4/4/16  JTA
*/


--Pull orders into a temporary table with related keys
SELECT 
	   IDENTITY(INT,1,1) AS lab_ord_key,
	   ord.enc_id,
	   ord.person_id,
	   loc.location_mstr_name AS appt_location,
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
		AS test_ordered
  INTO #temp_ord
  FROM [10.183.0.94] .[NGProd]. [dbo].[lab_nor] ord  --lab_nor table holds all the lab order
  LEFT JOIN dbo.data_provider prov ON prov.provider_id=ord.ordering_provider
  LEFT JOIN dbo.data_user_v2 creat   ON creat.user_id=ord.created_by
  LEFT JOIN dbo.data_user_v2 mod  ON mod.user_id=ord.modified_by
  LEFT JOIN dbo.data_location loc ON loc.location_id=ord.test_location



--Join orders table with results to create a master labs table
SELECT 
		ord.*,
	   p.[test_desc]
      ,res.[unique_obr_num]
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
      ,res.[abnorm_flags]
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
	  res.[obx_seq_num] AS order_rank,
	  CASE
		WHEN res.loinc_code IN ( '2335-8','12503-9','12504-7','14563-1',
						'14564-9','14565-6','27396-1','27401-9',
						'27925-7','27926-5','29771-3','56490-6',
						'56491-4','57905-2','58453-2'
						) THEN 1
		ELSE 0
	END
		AS crc_lab

  INTO #temp_lab
  FROM #temp_ord ord
  LEFT JOIN [10.183.0.94] .[NGProd].[dbo].[lab_results_obr_p] p WITH(NOLOCK) ON ord.order_num=p.ngn_order_num --lab_results_obr_b is a lab bridge table lab order to lab result
  LEFT JOIN [10.183.0.94] .[NGProd]. [dbo].lab_results_obx res WITH(NOLOCK) ON res.unique_obr_num=p.unique_obr_num --lab_results_obx holds the lab order results 


  --Add a primary key, calculate ranges for the chronic conditions we are currently tracking
  SELECT
	IDENTITY (INT,1,1) AS lab_res_key,
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
		WHEN res.obs_id IS NOT NULL THEN ROW_NUMBER() OVER ( PARTITION BY res.person_id, res.obs_id ORDER BY res.result_date DESC ) 
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
	--	WHEN res.result_desc LIKE '%a1c%' AND res.cleaned_value > 9.0 THEN 1
	--	ELSE 0
	--END
	--	AS uds_dm2_lab,
	--YEAR(res.result_date) AS uds_measure_year
  INTO #lab_final
  FROM #temp_lab res

	-- Final step creates dwh table and adds type/range columns to hold the values we are tracking, instead of individual columns for each type
	--Also adds our own tracking flag for complete, based off whether a result exists for a given order. For comparison against NG
    SELECT 
		f.*,
		CASE
			WHEN f.hiv_pos_res = 1 THEN 'HIV Positive'
			WHEN f.pre_diab_flag = 1 THEN 'Diabetes'
			WHEN f.hiv_inc_res = 1 THEN 'HIV Preliminary Positive'
			ELSE NULL
		END 
			AS lab_result_dx,
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
		--ROW_NUMBER() OVER(PARTITION BY f.person_key,f.uds_measure_year,f.uds_dm2_lab ORDER BY f.order_create_date DESC) AS uds_dm2_recency
  INTO dbo.data_labs 
  FROM #lab_final f


  --ALTER TABLE dbo.data_labs ALTER COLUMN uds_dm2_lab INT NULL
  --ALTER TABLE dbo.data_labs ALTER COLUMN uds_measure_year INT NULL
  --ALTER TABLE dbo.data_labs ALTER COLUMN uds_dm2_recency BIGINT NULL 
  --ALTER TABLE dbo.data_labs ALTER COLUMN crc_lab INT NULL 

  


  END
GO
