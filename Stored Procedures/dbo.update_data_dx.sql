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
		enc.create_timestamp AS enc_date,
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


		--**HEDIS UDS ** Flag diagnosis for quick reference in Hedis/UDS measures

		[dbo].[exclude_dx_hedis_crc](pd.diagnosis_code_id) AS crc_excl_dx,--crc exclusionary flag
		--Breast cancer control exclusionary flags
		[dbo].[unilateral_mastectomy_dx](pd.diagnosis_code_id) AS uni_mastec_dx,
		[dbo].[bilateral_mastectomy_dx](pd.diagnosis_code_id) AS bi_mastec_dx,
		[dbo].[diabetes_dx](pd.diagnosis_code_id) AS diab_dx,
		[dbo].[pregnant_esrd_dx](pd.diagnosis_code_id) AS preg_esrd_dx --For Htn control exclusionary flag
			
INTO #temp_dp
FROM  [10.183.0.94].NGProd.dbo.[patient_diagnosis] pd WITH (NOLOCK)
LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter enc ON enc.enc_id=pd.enc_id



SELECT
	IDENTITY(INT,1,1) AS dx_key,
	dp.*
INTO dbo.data_dx
FROM #temp_dp dp

END
GO
