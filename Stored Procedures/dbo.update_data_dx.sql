SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_dx]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --Allow for dirty reads

    IF OBJECT_ID('dbo.data_dx') IS NOT NULL
		DROP TABLE dbo.data_dx


	IF OBJECT_ID('tempdb..#temp_dp') IS NOT NULL
		DROP TABLE #temp_dp



SELECT  DISTINCT
		pd.enc_id,
		pd.person_id,
		pd.diagnosis_code_id, --icd code
		RTRIM(COALESCE(pd.[description],'')) AS diag_name ,
		RTRIM(COALESCE(CONCAT(pd.diagnosis_code_id, ' - ', pd.description),'')) AS diag_full_name,
		CASE
			WHEN pd.chronic_ind = 'Y' THEN 1 ELSE 0 
		END 
			AS chronic_ind,
		CASE
			WHEN pd.chronic_ind = 'Y' THEN 'Chronic' ELSE 'Acute'
		END 
			AS dx_status,
		[dbo].[exclude_dx_hedis_crc](pd.diagnosis_code_id) AS hedis_crc_exclude
			
		--Match Chronic diseases to ICD codes, only tracking Htn, DM, and HIV currently
		--CASE
		--	WHEN pd.diagnosis_code_id LIKE '250%' THEN 'Diabetes'
		--	WHEN pd.diagnosis_code_id LIKE 'E10.%' THEN 'Diabetes'
		--	WHEN pd.diagnosis_code_id LIKE 'E11.%' THEN 'Diabetes'
		--	WHEN pd.diagnosis_code_id LIKE '401%' THEN 'Hypertension'
		--	WHEN pd.diagnosis_code_id LIKE '402%' THEN 'Hypertension'
		--	WHEN pd.diagnosis_code_id LIKE 'I10.%' THEN 'Hypertension'
		--	WHEN pd.diagnosis_code_id LIKE 'I11.%' THEN 'Hypertension'
		--	WHEN pd.diagnosis_code_id LIKE 'B20%'THEN 'HIV'
		--	WHEN pd.diagnosis_code_id LIKE 'B21%'THEN 'HIV'
		--	WHEN pd.diagnosis_code_id LIKE 'B22%'THEN 'HIV'
		--	WHEN pd.diagnosis_code_id LIKE 'B23%'THEN 'HIV'
		--	WHEN pd.diagnosis_code_id LIKE 'B24%'THEN 'HIV'
		--	WHEN pd.diagnosis_code_id LIKE '042%'THEN 'HIV'
		--	WHEN pd.diagnosis_code_id LIKE 'V08%'THEN 'HIV' --Asymptomatic HIV
		--	WHEN pd.diagnosis_code_id LIKE '079.53'THEN 'HIV' --For HIV-2
		--	--WHEN d.diagnosis_code_id LIKE '795.71' THEN 1 --Inconclusive HIV Test, possibly requires its own flag
		--	ELSE NULL
		--END
		--	AS chronic_dx_label
INTO #temp_dp
FROM  [10.183.0.94].NGProd.dbo.[patient_diagnosis] pd WITH (NOLOCK)



SELECT
	IDENTITY(INT,1,1) AS dx_key,
	dp.*
INTO dbo.data_dx
FROM #temp_dp dp

END
GO
