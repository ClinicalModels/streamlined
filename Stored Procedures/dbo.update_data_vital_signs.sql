SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_vital_signs]
AS
 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


        IF OBJECT_ID('tempdb..#temp_vital_1') IS NOT NULL
            DROP TABLE #temp_vital_1;

		IF OBJECT_ID('tempdb..#recency_vitals') IS NOT NULL
            DROP TABLE #recency_vitals;

        IF OBJECT_ID('dwh.data_vital_signs') IS NOT NULL
            DROP TABLE dwh.data_vital_signs;

			
        IF OBJECT_ID('dwh.data_enc_vital') IS NOT NULL
            DROP TABLE dwh.data_enc_vital;
		IF OBJECT_ID('tempdb..#vital') IS NOT NULL
            DROP TABLE #vital;

		IF OBJECT_ID('tempdb..#vital_final') IS NOT NULL
            DROP TABLE #vital_final;
	     IF OBJECT_ID('tempdb..#temp_vital') IS NOT NULL
            DROP TABLE #temp_vital;
			
			

		--Temp table is required because we insert different data sets for NextGen and ECW
		CREATE TABLE #temp_vital_1(
			[per_mon_id] INT  NULL,
			[person_key] INT  NULL,
			[first_mon_date] DATE NULL,
			[enc_appt_key] INT NULL,
			[person_id] UNIQUEIDENTIFIER NULL,
			[person_id_ecw] INT NULL,
			[encounterID] UNIQUEIDENTIFIER NULL,
			[encounter_id_ecw] INT NULL,
			[create_timestamp] DATE NULL,
			[BP_date] DATE NULL,
			[Date of Measurement] DATE NULL,
				[Datetime of Measurement] DATEtime NULL,
			[Blood Pressure Systolic] NUMERIC NULL,
			[Blood Pressure Diastolic] NUMERIC NULL,
			[BMI] NUMERIC NULL,
			[Height Cm] NUMERIC NULL,
			[Weight Kg] NUMERIC NULL,
			[Weight Lb] NUMERIC NULL,
			[Recency] INT NOT NULL,
			[RecencyDay] INT NOT NULL,
			[RecencyAllTime] INT NOT NULL,
			[NextDate] DATETIME NULL,
			[ng_data] INT NULL


		)

		
--Bring vital signs data. convert to numeric(16,2) all the vital signs because UNPIVOT only accepts same data type 
        SELECT  
				vital.person_id ,
                vital.encounterID ,
                vital.[create_timestamp] ,
                CAST(vital.create_timestamp AS DATE) AS BP_date ,
				vital.create_timestamp  AS [Datetime of Measurement] ,
				 CAST(vital.create_timestamp AS DATE) AS [Date of Measurement] ,
                CAST([vital].[bp_systolic] AS NUMERIC(16, 2)) AS [Blood Pressure Systolic] ,
                CAST([vital].[bp_diastolic] AS NUMERIC(16, 2)) AS [Blood Pressure Diastolic] ,
                [vital].BMI_calc AS BMI ,
                [vital].height_cm AS [Height Cm] ,
                CAST([vital].[weight_kg] AS NUMERIC(16, 2)) AS [Weight Kg] ,
                [vital].weight_lb AS [Weight Lb] ,
                ROW_NUMBER() OVER ( PARTITION BY vital.person_id, CONVERT(CHAR(8), create_timestamp, 112) ORDER BY create_timestamp DESC ) AS RecencyDay ,
                ROW_NUMBER() OVER ( PARTITION BY vital.person_id ORDER BY create_timestamp DESC ) AS RecencyAllTime ,
                LEAD(vital.create_timestamp, 1) OVER ( PARTITION BY vital.person_id ORDER BY create_timestamp ASC ) AS NextDate
		INTO #recency_vitals
        FROM    [10.183.0.94].NGProd.dbo.[vital_signs_] vital; 
	
		INSERT INTO #temp_vital_1
		        ( 
		          person_id ,
		          encounterID ,
		          create_timestamp ,
		          BP_date ,
				  [Datetime of Measurement],
		          [Date of Measurement] ,
		          [Blood Pressure Systolic] ,
		          [Blood Pressure Diastolic] ,
		          BMI ,
		          [Height Cm] ,
		          [Weight Kg] ,
		          [Weight Lb] ,
		          RecencyDay ,
		          RecencyAllTime ,
		          NextDate ,
				  Recency ,
		          person_key ,
				  per_mon_id ,
		          first_mon_date ,
		          enc_appt_key ,
		          ng_data
		        )
        SELECT 
                vital.person_id,
				vital.encounterID,
				vital.create_timestamp,
				vital.BP_date,
				vital.[Datetime of Measurement],
				vital.[Date of Measurement],
			
				vital.[Blood Pressure Systolic],
				vital.[Blood Pressure Diastolic],
				vital.BMI,
				vital.[Height Cm],
				vital.[Weight Kg],
				vital.[Weight Lb],
				vital.RecencyDay,
				vital.RecencyAllTime,
				vital.NextDate,
				vital.RecencyDay,
                person_dp.person_key ,
                person_dp.per_mon_id ,
                person_dp.first_mon_date ,
                data_appointment.enc_appt_key,
				1 AS ng_data
        FROM    #recency_vitals vital
                LEFT OUTER JOIN dbo.[data_person_dp_month] person_dp WITH ( NOLOCK ) ON person_dp.[person_id] = vital.person_id
                                                                                          AND
						



						
																						  
																						  --Measurement is Date Month of 
																						   ( ( person_dp.[first_mon_date] = ( CAST(CONVERT(CHAR(6), vital.create_timestamp, 112)
                                                                                                        + '01' AS DATE) ) )
                                                                                             
						/*   OR 
																								
																								--Greater than Month of and Less than Next Value -- Use Previous Month ID
																								( person_dp.[first_mon_date] > ( CAST(CONVERT(CHAR(6), vital.create_timestamp, 112)
                                                                                                        + '01' AS DATE) )
                                                                                                     AND person_dp.[first_mon_date] < ( CAST(CONVERT(CHAR(6), vital.NextDate, 112)
                                                                                                        + '01' AS DATE) )
                                                                                                   )
																								   OR
																								   --The vital was the last one taken
																								   --The vital was not taken in the current month
																								   --The grab the per_mon_ids all the way to the current date

																								   	( vital.NextDate IS NULL AND
																									
																									 ( CAST(CONVERT(CHAR(6), vital.create_timestamp, 112)+ '01' AS DATE) )  != 
																									  ( CAST(CONVERT(CHAR(6), GETDATE(), 112) + '01' AS DATE) )
																									AND
																									person_dp.[first_mon_date] <= ( CAST(CONVERT(CHAR(6), GETDATE(), 112)
                                                                                                        + '01' AS DATE) )
                                                                                                   )

																								   */
                                                                                              )
                LEFT OUTER JOIN [dbo].[data_appointment] data_appointment WITH ( NOLOCK ) ON data_appointment.[enc_id] = vital.[encounterID]
        ORDER BY data_appointment.person_id ,
                data_appointment.first_mon_date

		--Insert ECW data
		INSERT INTO #temp_vital_1
		        ( per_mon_id ,
		          person_key ,
		          first_mon_date ,
		          enc_appt_key ,
		          person_id_ecw ,
		          encounter_id_ecw ,
		          create_timestamp ,
		          BP_date ,
		          [Date of Measurement] ,
				  [Datetime of Measurement],
		          [Blood Pressure Systolic] ,
		          [Blood Pressure Diastolic] ,
		          BMI ,
		          [Height Cm] ,
		          [Weight Kg] ,
		          [Weight Lb] ,
		          Recency ,
		          RecencyDay ,
		          RecencyAllTime ,
		          --NextDate ,
		          ng_data
		        )
		SELECT
			COALESCE(per.per_mon_id, app.per_mon_id),
			COALESCE(per.person_key,app.person_key),
			COALESCE(per.first_mon_date,app.first_mon_date),
			app.enc_appt_key,
			v.person_id,
			v.encounter_id,
			v.create_timestamp,
			v.create_timestamp,
			CAST(v.create_timestamp AS DATE),
			v.create_timestamp,
			v.bp_syst_clean,
			v.bp_diast_clean,
			v.bmi_clean,
			v.height_cm_calc,
			v.weight_kg_calc,
			v.weight_lb_clean,
			v.recency_day,
			v.recency_day,
			v.recency_all,
			--v.NextDate,
			0 AS ng_data
		FROM dwh.data_vital_signs_ecw v
		LEFT OUTER JOIN [dwh].[data_person_dp_month] per WITH ( NOLOCK ) ON per.[person_id_ecw] = v.person_id
                                                                         AND ( ( per.[first_mon_date] = ( CAST(CONVERT(CHAR(6), v.create_timestamp, 112)
                                                                                                        + '01' AS DATE) ) )
                                                                                             
						
                                                                                              )
                LEFT OUTER JOIN [dwh].[data_appointment] app WITH ( NOLOCK ) ON app.[enc_nbr] = v.encounter_id AND app.ng_data = 0
        ORDER BY app.person_id ,
                app.first_mon_date

--using UNPIVOT statetment to show vital signs as Type and Value
 ;
        WITH    vital
                  AS ( SELECT   [encounterID] ,
                                [person_id] ,
								person_id_ecw ,
								encounter_id_ecw,
								[create_timestamp],
                                BP_date ,
                                [Date of Measurement] ,
								[Datetime of Measurement],
                                [Recency] ,
                                RecencyDay ,
                                RecencyAllTime ,
                                person_key ,
                                per_mon_id ,
                                first_mon_date ,
                                enc_appt_key ,
								ng_data,
                                Type ,
                                Value
                       FROM     ( SELECT    [encounterID] ,
                                            [person_id] ,
											person_id_ecw,
											encounter_id_ecw,
                                            [create_timestamp] ,
                                            BP_date ,
                                            [Date of Measurement] ,
											[Datetime of Measurement],
                                            [Recency] ,
                                            RecencyDay ,
                                            RecencyAllTime ,
                                            person_key ,
                                            per_mon_id ,
                                            first_mon_date ,
                                            enc_appt_key ,
											ng_data,
                                            [Blood Pressure Systolic] ,
                                            [Blood Pressure Diastolic] ,
                                            [BMI] ,
                                            [Height Cm] ,
                                            [Weight Kg] ,
                                            [Weight Lb]
                                  FROM      #temp_vital_1
                                ) p UNPIVOT
   ( Value FOR Type IN ( [Blood Pressure Systolic], [Blood Pressure Diastolic], [BMI], [Height Cm], [Weight Kg],
                         [Weight Lb] ) )AS unpvt
                     )
            SELECT  IDENTITY(INT,1,1) AS vital_signs_key,
			*
            INTO    dwh.data_vital_signs
            FROM    vital; 

----------------This part creates dwh vital signs table uniqe by encounter ID---------------------


  SELECT * INTO #vital
  FROM dwh.data_vital_signs WHERE Type='Blood Pressure Systolic' OR Type='Blood Pressure Diastolic'


			
SELECT  [encounterID],encounter_id_ecw,[Blood Pressure Systolic], [Blood Pressure Diastolic]
 INTO #temp_vital
FROM  
(SELECT [encounterID],encounter_id_ecw,Type, Value   
    FROM #vital) AS SourceTable  
PIVOT  
(  
MAX(Value)  
FOR Type IN ([Blood Pressure Systolic], [Blood Pressure Diastolic])  
) AS PivotTable; 
				
---create vital table unique by encounterID
SELECT tv.*,
CASE WHEN (tv.encounterID IS NOT NULL) 
THEN (SELECT TOP 1 v.create_timestamp FROM #vital v  WHERE (v.encounterID=tv.encounterID)) 
else
(SELECT TOP 1 v.create_timestamp FROM #vital v  WHERE (v.encounter_id_ecw=tv.encounter_id_ecw))
END create_timestamp,
(SELECT TOP 1 v.person_id FROM #vital v  WHERE v.encounterID=tv.encounterID) AS person_id,
(SELECT TOP 1 v.person_id_ecw FROM #vital v  WHERE v.encounter_id_ecw=tv.encounter_id_ecw) AS person_id_ecw
INTO  #vital_final 
FROM #temp_vital tv


SELECT #vital_final.*,
CASE WHEN (encounterID IS NOT NULL) then (SELECT TOP 1 enc_appt_key FROM dwh.data_appointment WHERE #vital_final.encounterID=data_appointment.enc_id) 
	 ELSE (SELECT TOP 1 enc_appt_key FROM dwh.data_appointment WHERE #vital_final.encounter_id_ecw=data_appointment.enc_id_ecw)
END enc_appt_key,
CASE WHEN (encounterID IS NOT NULL)
then
 ROW_NUMBER() OVER(PARTITION BY #vital_final. person_id,YEAR(#vital_final.create_timestamp) ORDER BY create_timestamp DESC)
 WHEN (encounter_id_ecw IS NOT NULL) then ROW_NUMBER() OVER(PARTITION BY #vital_final.person_id_ecw,YEAR(#vital_final.create_timestamp) ORDER BY create_timestamp DESC) 
 END [YearRecency],
 CASE
   WHEN [Blood Pressure Systolic]<140  AND [Blood Pressure Diastolic]<90 THEN 1
   ELSE 0
 END [UDS Vital Sign],
 CASE WHEN (SELECT TOP 1 [UDS Hypertension Denominator]  FROM dwh.data_patient_dx_svc dx WHERE person_id=#vital_final.person_id AND YEAR(#vital_final.create_timestamp)=dx.measurementYear AND dx.[UDS Hypertension Denominator]=1) =1 
THEN 1 ELSE 0 END  [UDS Hypertension Dm Flag]

 INTO dbo.data_enc_vital
FROM #vital_final




 END;
GO
