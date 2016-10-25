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

        IF OBJECT_ID('dbo.data_vital_signs') IS NOT NULL
            DROP TABLE dbo.data_vital_signs;

			
        IF OBJECT_ID('dbo.data_enc_vital') IS NOT NULL
            DROP TABLE dbo.data_enc_vital;
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
			[encounterID] UNIQUEIDENTIFIER NULL,
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

	
--using UNPIVOT statetment to show vital signs as Type and Value
 ;
        WITH    vital
                  AS ( SELECT   [encounterID] ,
                                [person_id] ,
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
            INTO    dbo.data_vital_signs
            FROM    vital; 



ALTER TABLE dbo.data_vital_signs ADD bp_sys INT NULL
ALTER TABLE dbo.data_vital_signs ADD bp_dia INT NULL 


UPDATE dbo.data_vital_signs
	SET bp_sys =
		(CASE
			WHEN Type LIKE 'Blood Pressure Systolic' THEN 1
			ELSE 0
		END)

UPDATE dbo.data_vital_signs
    SET bp_dia =
		(CASE
			WHEN Type LIKE 'Blood Pressure Diastolic' THEN 1
			ELSE 0
		END)

 END;
GO
