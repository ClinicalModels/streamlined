SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[import_data_medication_rx]
AS
BEGIN

	DECLARE @start_date VARCHAR(8),
	@end_date VARCHAR(8)

	--Uncomment @start_date to only import data from a previous date forward
	--SET @start_date='20100301';
	SET @end_date=CONVERT(CHAR(8),GETDATE(),112)
	SET @start_date='2014-01-01'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --Allow for "Dirty" reads

	--Drop the tables if they already exist, as they will be re-created
	 IF OBJECT_ID('tempdb..#temp_pharmacy') IS NOT NULL
            DROP TABLE #temp_pharmacy;
	 IF OBJECT_ID('dbo.data_medication_rx') IS NOT NULL
            DROP TABLE dbo.data_medication_rx;


-- STEP 1 : Pull relevant measures from the selected date range into a #temptable, for eventual SELECT INTO final table
SELECT DISTINCT
						p.person_id,
						lm.location_id,
						prov.provider_id as provider_id,

						--Takes the Year and Month of date, appends 01 as the day to turn the start date into a first_mon_date format
						CASE WHEN ISDATE(pm.start_date)=1 THEN CAST(CONVERT(CHAR(6),pm.start_date,112)+'01' AS date) 
						     ELSE NULL END AS first_mon_date,
						f.medid AS md_id,
					 	CASE WHEN pm.start_date > CONVERT(CHAR(8),GETDATE(),112) THEN 0 --Inactive if future dated
							 WHEN pm.date_stopped IS NULL THEN 1 --active if no stop date exists
							 WHEN pm.date_stopped='' THEN 1 
						     WHEN pm.date_stopped > CONVERT(CHAR(8),GETDATE(),112) THEN 1 --active if stop date is in future
							 ELSE 0   --inactive for all other cases
							 END AS active_med,
						pm.enc_id,
						pm.medid AS rx_id,
						pm.gcn_seqno AS gcnsecno,
						pm.medication_name AS drug_name,
						pm.ndc_id AS ndc,
						p.med_rec_nbr as med_rec_nbr,

						/*
						Sending a single Rx to mulitple stores causes duplicate rows with SELECT DISTINCT, Step 2
						makes sure this does not interfere with count of active medications
						*/
						erx.pharmacy_id AS store_id,
						(CASE 
						WHEN ISDATE(pm.start_date)=1 THEN cast (pm.start_date AS DATE) END) 
						AS start_date,
						(CASE 
						WHEN ISDATE(pm.expiration_date)=1 THEN cast(pm.expiration_date AS DATE) end) 
						AS expire_date,
						prov.description AS provider_name,
						um.last_name+ ','+um.first_name AS userName,
						CASE 
							WHEN pm.prescribed_else_ind = 'Y' THEN 0 --Any medication prescribed elsewhere is listed as not by provider
							WHEN prov.description LIKE ('%'+um.last_name+'%') THEN 0 
							ELSE 1 END 
							RxNotbyProv,
						CASE
							WHEN pm.prescribed_else_ind = 'Y' THEN 1 ELSE 0 END --Holds a flag for any medication prescribed outside our organization
							Rx_prescribe_else,
						per.last_name + ', ' + per.first_name AS PatName ,
                        per.date_of_birth AS birth_date ,
                        RIGHT(p.med_rec_nbr, 6) AS chart_id ,
                        per.ssn as ssn ,
                        pm.sig_desc AS sig_text ,

						/*
						ISNUMERIC() returns 1 for '-' and '.', however they throw a conversion error when
						attempting to round, so we assign 0 when these cases are encountered
						*/
                        ( CASE
							WHEN pm.rx_quanity = '.' THEN 0
							WHEN pm.rx_quanity = '-' THEN 0 
							WHEN ISNUMERIC(pm.rx_quanity) = 1 THEN CAST(ROUND(pm.rx_quanity, 0) AS INT)
                               ELSE 0
                          END ) AS written_qty ,
                        ( CASE WHEN ISNUMERIC(pm.refills_left) = 1 THEN CAST(ROUND(pm.refills_left, 0) AS INT)
                               ELSE 0
                          END ) AS refills_left ,
                        ( CASE WHEN ISNUMERIC(pm.org_refills) = 1 THEN CAST(ROUND(pm.org_refills, 0) AS INT)
                               ELSE 0
                          END ) AS refills_orig ,
                        pharma.name AS SentTo ,
                        lm.location_name AS clinic ,
                        f.med_ref_dea_class_code AS drug_dea_class ,

						/*
						Sending a single Rx via multiple modalities causes duplicate rows with SELECT DISTINCT.
						ex. Rx sent to 2 stores, each store receives via eRx and Print, 2 * 2 = 4 rows appear in
						the table for single medication. 
						Step 2 makes sure this does not interfere with count of active medications
						*/
                        CASE WHEN pa.operation_type = 'P' THEN 'Print'
                             WHEN pa.operation_type = 'E' THEN 'eRx'
                             WHEN pa.operation_type = 'F' THEN 'Fax'
                             WHEN pa.operation_type = 'D' THEN 'DAP'
							 ELSE NULL 
                        END operation_type ,
                        SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATETIME, pm.start_date, 101), 3), 4, 5) AS mmyy ,
                        ( CASE WHEN f.med_ref_dea_class_code = 0 THEN 1
                               ELSE 0
                          END ) AS Total_Non_Controlled ,
                        ( CASE WHEN f.med_ref_dea_class_code <> 0 THEN 1
                               ELSE 0
                          END ) AS Total_Controlled ,
                        ( CASE WHEN f.med_ref_dea_class_code = 1 THEN 1
                               ELSE 0
                          END ) AS Sched_I ,
                        ( CASE WHEN f.med_ref_dea_class_code = 2 THEN 1
                               ELSE 0
                          END ) AS Sched_II ,
                        ( CASE WHEN f.med_ref_dea_class_code = 3 THEN 1
                               ELSE 0
                          END ) AS Sched_III ,
                        ( CASE WHEN f.med_ref_dea_class_code = 4 THEN 1
                               ELSE 0
                          END ) AS Sched_IV ,
                        ( CASE WHEN f.med_ref_dea_class_code = 5 THEN 1
                               ELSE 0
                          END ) AS Sched_V,
						  pm.create_timestamp AS create_date,
						  ndc.brand_name,
						  ndc.generic_name,
						  ndc.dose,
						  ndc.dose_form_desc,
						  ndc.route_desc,
						  ndc.med_cat_class_desc
						  INTO #temp_pharmacy
FROM [10.183.0.94].[NGProd].[dbo].person per
INNER JOIN [10.183.0.94].[NGProd].[dbo].patient_medication pm with(nolock) ON per.person_id=pm.person_id
INNER JOIN [10.183.0.94].[NGProd].dbo.patient p with(nolock) ON p.person_id=per.person_id
INNER JOIN [10.183.0.94].[NGProd].dbo.provider_mstr prov with(nolock) ON pm.provider_id=prov.provider_id
INNER JOIN [10.183.0.94].[NGProd].dbo.location_mstr lm with(nolock) ON pm.location_id=lm.location_id
INNER JOIN [10.183.0.94].[NGProd].dbo.fdb_med_mstr f with(nolock) ON pm.medid=f.medid AND pm.gcn_seqno=f.gcn_seqno
INNER JOIN [10.183.0.94].[NGProd].dbo.erx_message_history erx with(nolock) ON per.person_id=erx.person_id
left JOIN [10.183.0.94].[NGProd].dbo.med_rx_notes med with(nolock) ON erx.medication_id=med.medication_id
left JOIN [10.183.0.94].[NGProd].dbo.pharmacy_mstr pharma with(nolock) ON erx.pharmacy_id=pharma.pharmacy_id
INNER JOIN [10.183.0.94].[NGProd].dbo.user_mstr um with(nolock) ON pm.created_by=um.user_id
LEFT JOIN [10.183.0.94].[NGProd].dbo.prescription_audit pa with(nolock) ON pm.enc_id=pa.enc_id
left join [10.183.0.94].NGprod.dbo.fdb_medication ndc on pm.ndc_id=ndc.ndc_id
WHERE pm.start_date <= @end_date
AND pm.start_date >=@start_date   --Uncomment pm.start_date filters to import only from a specific date forward
AND lm.location_id IN (SELECT location_id FROM dbo.data_location);
--Previously filtered by pa.operation_type <>'', however this was dropping prescriptions which should have shown up as active



--STEP 2 : Create the dbo.data_pharmacy_rx based off the #temptable of all historical medications

SELECT
per.per_mon_id,
--Location key is selected with a subquery because locations repeat, affecting a JOIN
( SELECT TOP 1
            location_key
    FROM      dbo.data_location dl
    WHERE     dl.location_id = ph.location_id
            AND dl.location_id_unique_flag = 1
            AND ph.location_id IS NOT NULL
) AS appt_loc_key,
us.user_key AS prescribing_user_key,
app.enc_appt_key,
ph.first_mon_date,
ph.person_id,
ph.provider_id,
ph.enc_id,
ph.location_id,
ph.md_id,

/*
A single medication may show up as multiple rows despites select distinct, as it may be sent to multiple stores
and/or via multiple modalities. This statement partitions these subsets by individual medications prescribed on a given encounter,
and assigns an active_med_count flag to only the most recently created one. So we may still track all active medications by store,
but our active_med_count will only count 1 of the duplicate rows.
*/
(CASE WHEN 
(ROW_NUMBER() OVER (PARTITION BY app.enc_appt_key, ph.ndc, ph.sig_text ORDER BY ph.create_date DESC)) = 1 AND ph.active_med = 1 THEN 1
ELSE 0  END) 
AS active_med_count,

--Tracks every listed active med so we can link them to stores
ph.active_med AS active_med_all,

/*
Using the same algorithm for determing active_med_count flag, determines if medication is active + prescribed in-house,
as opposed to active and prescribed elsewhere
*/
(CASE 
	WHEN (ROW_NUMBER() OVER (PARTITION BY app.enc_appt_key, ph.ndc, ph.sig_text ORDER BY ph.create_date DESC)) = 1 AND ph.active_med = 1 AND ph.Rx_prescribe_else = 0 THEN 1
ELSE 0  END) 
AS active_count_lifelong,

(CASE 
	WHEN (ROW_NUMBER() OVER (PARTITION BY app.enc_appt_key, ph.ndc, ph.sig_text ORDER BY ph.create_date DESC)) = 1 AND ph.active_med = 1 AND ph.Rx_prescribe_else = 1 THEN 1
ELSE 0  END) 
AS active_count_elsewhere,
ph.rx_id,
ph.gcnsecno,
ph.drug_name,
ph.ndc,
ph.med_rec_nbr,
ph.store_id,
ph.start_date,
ph.expire_date,
ph.provider_name,
ph.userName,
ph.RxNotbyProv,
ph.Rx_prescribe_else,
ph.PatName,
ph.birth_date,
ph.chart_id,
ph.ssn,
ph.sig_text,
ph.written_qty,
ph.refills_left,
ph.refills_orig,
ph.SentTo,
ph.clinic,
ph.drug_dea_class,
ph.operation_type,
ph.mmyy,
ph.Total_Non_Controlled,
ph.Total_Controlled,
ph.Sched_I,
ph.Sched_II,
ph.Sched_III,
ph.Sched_IV,
ph.Sched_V,
ph.brand_name,
ph.generic_name,
ph.dose,
ph.dose_form_desc,
ph.route_desc,
ph.med_cat_class_desc
INTO dbo.data_medication_rx --Dynamically creates the table
FROM #temp_pharmacy ph 
LEFT OUTER JOIN dbo.data_person_dp_month per ON ph.first_mon_date = per.first_mon_date AND per.person_id = ph.person_id
LEFT OUTER JOIN dbo.data_appointment app ON ph.enc_id = app.enc_id
LEFT OUTER JOIN dbo.data_user_v2 us ON us.self_provider_id = ph.provider_id


    
END
GO
