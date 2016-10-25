SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_person_nd_month]
AS
BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;

        IF OBJECT_ID('dbo.data_person_nd_month') IS NOT NULL
            DROP TABLE dbo.data_person_nd_month;

        IF OBJECT_ID('tempdb..#person_patient') IS NOT NULL
            DROP TABLE #person_patient;

        IF OBJECT_ID('tempdb..#first_enc_date_scrub') IS NOT NULL
            DROP TABLE #first_enc_date_scrub

        IF OBJECT_ID('tempdb..#Status') IS NOT NULL
            DROP TABLE #Status

        IF OBJECT_ID('tempdb..#pcp_remap') IS NOT NULL
            DROP TABLE #pcp_remap

        IF OBJECT_ID('tempdb..#location_id_remap') IS NOT NULL
            DROP TABLE #location_id_remap

        IF OBJECT_ID('tempdb..#ND_roll_up') IS NOT NULL
            DROP TABLE #ND_roll_up

		IF OBJECT_ID('tempdb..#temp_disable') IS NOT NULL
            DROP TABLE #temp_disable

		IF OBJECT_ID('tempdb..#colon') IS NOT NULL
            DROP TABLE #colon

		IF OBJECT_ID('tempdb..#fit') IS NOT NULL
            DROP TABLE #fit

		IF OBJECT_ID('tempdb..#sigmoid') IS NOT NULL
            DROP TABLE #sigmoid

		IF OBJECT_ID('tempdb..#mammo') IS NOT NULL
            DROP TABLE #mammo

			

        --What date range to include in the person month table?
        --Since the earliest implementation date is 20100301 all data starts at that point to the current date

        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);

        SET @build_dt_start = CONVERT(VARCHAR(8), DATEADD(MONTH, 6, GETDATE()));
        SET @build_dt_end = CONVERT(VARCHAR(8), DATEADD(m,6,GETDATE()), 112);
        SET @build_dt_start = '20100301';


		--Rather than join master list, create temp table holding only the disabilities and homeless status
		SELECT 
			mstr_list_type,
			mstr_list_item_id,
			mstr_list_item_desc
		INTO #temp_disable
		FROM [10.183.0.94].NGProd.dbo.mstr_lists
		WHERE mstr_list_type LIKE 'ud_demo1'
		OR mstr_list_type LIKE 'ud_demo2'
		OR mstr_list_type LIKE 'uds_homeless_status'


        --Temp table is created in a separate statement to account for the later addition of ECW fields
        --Even UNIQUEIDENTIFIER is NULL because ECW does not use this data type
        CREATE TABLE #person_patient(
            [person_id] UNIQUEIDENTIFIER NULL,
			--Used in future procedures instead of person_id/person_id_ecw. Windowing functions where having issues with null values in id columns
			--Acts as a unique identifier for all patients
			[person_key] INT IDENTITY(1,1), 
            [expired_date] VARCHAR(8) NULL,
            [primarycare_prov_id] UNIQUEIDENTIFIER NULL,
            [full_name] VARCHAR(150) NULL,
            [last_name] VARCHAR(70) NULL,
            [first_name] VARCHAR(70) NULL,
            [middle_name] VARCHAR(25) NULL,
            [dob] VARCHAR(19) NULL,
            [address_line_1] VARCHAR(60) NULL,
            [address_line_2] VARCHAR(60) NULL,
            [city] VARCHAR(35) NULL,
            [state] VARCHAR(10) NULL,
            [zip] VARCHAR(12) NULL,
            [home_phone] VARCHAR(30) NULL,
            [sex] VARCHAR(1)  NULL,
            [ssn] VARCHAR(15) NULL,
            [alt_phone] VARCHAR(15) NULL,
            [marital_status] VARCHAR(1) NULL,
            [race] VARCHAR(100) NULL,
            [language] VARCHAR(100) NULL,
            [ethnicity] VARCHAR(40) NULL,
			[disability_1] VARCHAR(100) NULL,
			[disability_2] VARCHAR(100) NULL,
			[homeless_status] VARCHAR(100) NULL,
			[homeless_count] INT NULL,
            [med_rec_nbr] VARCHAR(30) NULL,
            [first_enc_date] DATE NULL,
			[chart_create_date] DATE NULL,
			[chart_create_user] VARCHAR(92) NULL,
			[person_create_date] DATE NULL,
			[person_create_user] VARCHAR(92) NULL,
            [deceased] INT NULL

        )

        --Insert the NextGen patient data into the temp table first
        INSERT INTO #person_patient
                ( person_id ,
                  expired_date ,
                  primarycare_prov_id ,
                  full_name ,
                  last_name ,
                  first_name ,
                  middle_name ,
                  dob ,
                  address_line_1 ,
                  address_line_2 ,
                  city ,
                  state ,
                  zip ,
                  home_phone ,
                  sex ,
                  ssn ,
                  alt_phone ,
                  marital_status ,
                  race ,
                  language ,
                  ethnicity ,
				  disability_1,
				  disability_2,
				  homeless_status,
				
				  homeless_count,
                  med_rec_nbr ,
				  chart_create_date,
				  chart_create_user,
				  person_create_date,
				  person_create_user
                )

        SELECT  DISTINCT 
				per.person_id ,
                COALESCE(per.expired_date, '') AS expired_date ,
                per.primarycare_prov_id ,
                COALESCE(LTRIM(RTRIM(per.first_name)) + ' ' + LTRIM(RTRIM(per.middle_name)) + ' '
                         + LTRIM(RTRIM(per.last_name)), '') AS full_name ,
                COALESCE(per.last_name, '') AS last_name ,
                COALESCE(per.first_name, '') AS first_name ,
                COALESCE(per.middle_name, '') AS middle_name ,
                COALESCE(per.date_of_birth, '') AS dob ,
                COALESCE(per.address_line_1, '') AS address_line_1 ,
                COALESCE(per.address_line_2, '') AS address_line_2 ,
                COALESCE(per.city, '') AS city ,
                COALESCE(per.state, '') AS state ,
                COALESCE(per.zip, '') AS zip ,
                COALESCE(per.home_phone, '') AS home_phone ,
                COALESCE(per.sex, '') AS sex ,
                COALESCE(per.ssn, '') AS ssn ,
                COALESCE(per.alt_phone, '') AS alt_phone ,
                COALESCE(per.marital_status, '') AS marital_status ,
                COALESCE(per.race, '') AS race ,
                COALESCE(per.language, '') AS language ,
                COALESCE(per.ethnicity, '') AS ethnicity ,
				COALESCE(d1.mstr_list_item_desc, '') AS disability_1,
				COALESCE(d2.mstr_list_item_desc, '') AS disability_2,
				COALESCE(h.mstr_list_item_desc, '') AS homeless_status,
				CASE
					 WHEN per.uds_homeless_status_id IN ( 'A482F60C-0704-4047-961E-7EFC4AFF3D11' ,
                                                        '5FFAD6B3-A050-42FD-AF7A-25367AB43273' ,
                                                        '402146F0-9F50-4A57-AF18-C7D725B724F9' ,
                                                        'FC3F7F5E-7443-4747-BD5E-91F9C45E14FC' ,
                                                        'B4CB49AA-09F0-41AC-A22E-1453768E1C9B' ) THEN 1
					ELSE 0
				END
					AS homeless_count,

                COALESCE(pat.med_rec_nbr, '') AS med_rec_nbr,
				CAST(pat.create_timestamp AS DATE) AS chart_create_date,
				us.FullName,
				CAST(per.create_timestamp AS DATE) AS person_create_date,
				pc.FullName
        FROM    [10.183.0.94].NGProd.dbo.person per
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient pat ON per.person_id = pat.person_id
				LEFT JOIN [10.183.0.94].NGProd.dbo.person_ud pud ON pud.person_id=per.person_id
				LEFT JOIN #temp_disable d1 ON d1.mstr_list_item_id=pud.ud_demo1_id
				LEFT JOIN #temp_disable d2 ON d2.mstr_list_item_id=pud.ud_demo2_id
				LEFT JOIN #temp_disable h ON h.mstr_list_item_id=per.uds_homeless_status_id
				LEFT JOIN dbo.data_user_v2 us ON us.user_id=pat.created_by
				LEFT JOIN dbo.data_user_v2 pc ON pc.user_id=per.created_by


                  --DQ Issue -
                  -- This table brings in the actual visit data for first office encounter as the NG field appears on audit to be unreliable.
        SELECT  per.person_id ,
                enc.billable_timestamp AS cr_first_bill_enc_date ,
                pat.first_office_enc_date ,
                CASE WHEN ISDATE(enc.billable_timestamp) = 1
                          AND ISDATE(pat.first_office_enc_date) = 1
                          AND COALESCE(pat.first_office_enc_date, '') < COALESCE(enc.billable_timestamp, '')
                     THEN CAST(pat.first_office_enc_date AS DATE)
                     WHEN ISDATE(enc.billable_timestamp) = 1 THEN CAST(enc.billable_timestamp AS DATE)
                     ELSE NULL
                END AS cr_first_office_enc_date ,
                ROW_NUMBER() OVER ( PARTITION BY per.person_id ORDER BY enc.billable_timestamp ASC ) AS Enc_row
        INTO    #first_enc_date_scrub
        FROM    [10.183.0.94].NGProd.dbo.person per
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient pat ON per.person_id = pat.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter enc ON per.person_id = enc.person_id
        WHERE   enc.billable_ind = 'Y';

        -- Create a temp table to hold key for Current Medical Home
        CREATE TABLE #location_id_remap(
            [person_id] UNIQUEIDENTIFIER NULL,
            [mh_cur_key] INT NULL
        )

        --Insert NextGen medical home data
        INSERT INTO #location_id_remap
                ( person_id ,
                  mh_cur_key
                )
        SELECT
                per.person_id AS person_id ,
                loc.location_key AS mh_cur_key
        FROM    [10.183.0.94].NGProd.dbo.person per
                LEFT JOIN [10.183.0.94].NGProd.dbo.person_ud ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient pat ON per.person_id = pat.person_id
                LEFT JOIN dbo.data_location loc ON loc.ud_demo3_id = ud.ud_demo3_id
                                                              AND [location_id_unique_flag] = 1;


        --Create a temp table to hold key for Current PCP
        CREATE TABLE #pcp_remap(
            [person_id] UNIQUEIDENTIFIER NULL,
            [pcp_cur_key] INT
        )

        INSERT INTO #pcp_remap
                ( person_id ,
                  pcp_cur_key
                )
        SELECT  per.person_id AS person_id ,
                pro.user_key AS pcp_cur_key
        FROM    [10.183.0.94].NGProd.dbo.person per
                LEFT JOIN dbo.data_user pro ON per.primarycare_prov_id = pro.provider_id
        WHERE   pro.unique_provider_id_flag = 1;

     

        -- This table brings in the actual visit data for first office encounter as the NG field appears on audit to be unreliable.
        --Need to find Patient Status in ECW to add in
        SELECT  ps.person_id ,
                psm.description AS patient_status_cur
        INTO    #Status
        FROM    [10.183.0.94].NGProd.dbo.patient_status ps
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient_status_mstr psm ON ps.patient_status_id = psm.patient_status_id;



		--Create temp tables for Colonoscopy, Sigmoidoscopy, Fit test, and Mammograms for later HEDIS subqueris
		SELECT person_id, seq_no, create_timestamp, modify_timestamp,  actText, CAST(completedDate AS DATE) AS date
		INTO #colon
		FROM [10.183.0.94].NGProd.dbo.order_ WHERE [actText] LIKE 'Colonoscopy' 
		AND completedDate IS NOT NULL 
		AND completedDate NOT LIKE ''

		SELECT person_id, CAST(result_date AS DATE) AS date
		INTO #fit
		FROM dbo.data_labs
		WHERE crc_lab=1
		AND result_date <= GETDATE()

		SELECT person_id, CAST(completedDate AS DATE) AS date
		INTO #sigmoid
		FROM [10.183.0.94].NGProd.dbo.order_ WHERE [actText] LIKE 'Sigmoidoscopy' 
		AND completedDate IS NOT NULL 
		AND completedDate NOT LIKE ''


		SELECT person_id, CAST(completedDate AS DATE) AS date
		INTO #mammo
		FROM [10.183.0.94].NGProd.dbo.order_ WHERE [actText] LIKE 'Mammogram' 
		AND completedDate IS NOT NULL 
		AND completedDate NOT LIKE ''



		SELECT
			v.person_id, v.BP_date AS date,Value, bp_sys, bp_dia
        INTO #bp_tab
		FROM dbo.data_vital_signs v
		WHERE bp_sys=1 OR bp_dia=1




        SELECT
				pp.person_key,
                pp.person_id AS person_id,
                pp.full_name ,
                pp.first_name ,
                pp.last_name ,
                pp.middle_name ,
                CASE WHEN ISDATE(pp.dob) = 1 THEN CAST(pp.dob AS DATE)
                     ELSE NULL
                END
                    AS dob ,
                CASE WHEN ISDATE(pp.expired_date) = 1 THEN CAST(pp.expired_date AS DATE)
                     ELSE NULL
                END
                    AS expired_date ,
                pp.address_line_1 ,
                pp.address_line_2 ,
                pp.city ,
                pp.state ,
                pp.zip ,
                pp.home_phone ,
                pp.sex ,
                pp.ssn ,
                pp.alt_phone ,
                pp.marital_status ,
                pp.race ,
                pp.ethnicity ,
				pp.disability_1,
				pp.disability_2,
				pp.homeless_status,
				pp.homeless_count,
                pp.language ,
                pp.med_rec_nbr ,
				pp.chart_create_date,
				pp.chart_create_user,
				pp.person_create_date,
				pp.person_create_user,
                tim.first_mon_date ,
                mh.mh_cur_key  AS mh_cur_key ,
                pcp.pcp_cur_key AS pcp_cur_key ,
                fed.cr_first_office_enc_date AS cr_first_office_enc_date,
                CONVERT(VARCHAR(6), fed.cr_first_office_enc_date, 112) AS patient_vintage ,
                COALESCE(st.patient_status_cur, '')
                    AS status_cur_key ,

                  --First_Enc_Age_months can be time since first encounter or zero if no encounters ever
        CASE
                  --Expired, but not yet expired, Has had an encounter in the past -- calculate months since first encounter
             WHEN ISDATE(pp.expired_date) = 1
                                          --date of census is before the person expired
                  AND tim.first_mon_date < DATEADD(MONTH, DATEDIFF(MONTH, 0, pp.expired_date), 0)

                                         --date of census is after the first office encounter date
                  AND tim.first_mon_date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, fed.cr_first_office_enc_date), 0)
             THEN DATEDIFF(m, DATEADD(MONTH, DATEDIFF(MONTH, 0, fed.cr_first_office_enc_date), 0), tim.first_mon_date)
                  + 1

                  --Expired and has had encounter at some point -- Age is fixed to the number of months to death date
                  --I have commented out this section.  Once a person has expired they will no longer have a first enc AGE
                   -- This is similar to the logic I use for actual age

                           /*          WHEN ISDATE(pp.expired_date) = 1

                                        --census date is after the person expired
                                          AND tim.first_mon_date >= CAST(CONVERT(VARCHAR(6), pp.expired_date, 112) + '01' AS DATE)
                                          -- and the person has had a first visit
                                          AND fed.cr_first_office_enc_date IS  NOT NULL
                                          AND CAST(CONVERT(VARCHAR(6), fed.cr_first_office_enc_date, 112)
                                          + '01' AS DATE) >= tim.first_mon_date
                                     THEN DATEDIFF(m,
                                                   CAST(CONVERT(VARCHAR(6), fed.cr_first_office_enc_date, 112) + '01' AS DATE),
                                                   CAST(CONVERT(VARCHAR(6), pp.expired_date, 112) + '01' AS DATE)) + 1

                  */

                   --Has never expired and has had an encounter in the past
             WHEN ISDATE(pp.expired_date) = 0
                  AND fed.cr_first_office_enc_date IS  NOT NULL
                  AND tim.first_mon_date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, fed.cr_first_office_enc_date), 0)
             THEN DATEDIFF(m, DATEADD(MONTH, DATEDIFF(MONTH, 0, fed.cr_first_office_enc_date), 0), tim.first_mon_date)
                  + 1
             ELSE NULL

                  --Expired, but not yet expired, But they havent yet had there first enounter
                  --Has expired and has never had an ecounter
        END AS First_enc_age_months ,

                        --Create a New patient Flag 1 or 0 (expired patients do not get a NULL-- for the month the patient has their first encounter
        CASE                                       --This means when the first office visit is populated and is greater than the current date
             WHEN tim.first_mon_date = DATEADD(MONTH, DATEDIFF(MONTH, 0, fed.cr_first_office_enc_date), 0) THEN 1
             ELSE 0
        END AS nbr_new_pt ,
        CASE
              --This means when the first office visit is populated and is greater than the current date
             WHEN cr_first_office_enc_date IS NOT NULL
                  AND tim.first_mon_date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, fed.cr_first_office_enc_date), 0) THEN 1
             ELSE 0
        END AS nbr_pt_seen_office_ever ,
        CASE WHEN ISDATE(pp.expired_date) = 1
                  AND tim.first_mon_date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, pp.expired_date), 0) THEN 1
             ELSE 0
        END AS nbr_pt_deceased ,
        CASE WHEN ISDATE(pp.expired_date) = 1
                  AND DATEADD(MONTH, DATEDIFF(MONTH, 0, pp.expired_date), 0) = tim.first_mon_date THEN 1
             ELSE 0
        END AS nbr_pt_deceased_this_month ,

				--Quality measures
				(SELECT TOP 1 v.Value
				FROM #bp_tab v
				WHERE v.person_id=pp.person_id
				AND v.date < DATEADD(MONTH,1,tim.first_mon_date)
				AND v.bp_sys=1
				ORDER BY v.date DESC)
					AS last_bp_sys,
				(SELECT TOP 1 v.Value
				FROM #bp_tab v
				WHERE v.person_id=pp.person_id
				AND v.date < DATEADD(MONTH,1,tim.first_mon_date)
				AND v.bp_dia=1
				ORDER BY v.date DESC)
					AS last_bp_dia,

				--HEDIS
				--CRC Denominator, adults 50-75
				CASE
					WHEN DATEDIFF(YY, pp.dob, tim.first_mon_date) > 75
						OR DATEDIFF(YY, pp.dob, tim.first_mon_date) < 50 THEN 0
					ELSE 1
                END
					AS hedis_crc_denom,
				--Breast cancer denominator, women age 50-74
				CASE
					WHEN pp.sex ='M'
						OR DATEDIFF(YY, pp.dob, tim.first_mon_date) > 74
						OR DATEDIFF(YY, pp.dob, tim.first_mon_date) < 50 THEN 0
					ELSE 1
				END
					AS hedis_bc_denom,
				--last colonoscopy for patient over 50
				CASE
					WHEN DATEDIFF(YY, pp.dob, tim.first_mon_date) < 50 THEN NULL
                    ELSE (SELECT TOP 1 c.date 
						FROM #colon c
						WHERE c.person_id=pp.person_id
						AND c.date < DATEADD(MONTH,1,tim.first_mon_date)
						ORDER BY c.date DESC)
				END
					AS hedis_last_colon,
				--last sigmoidoscopy for patien over 50
				CASE
					WHEN DATEDIFF(YY, pp.dob, tim.first_mon_date) < 50 THEN NULL
                    ELSE (SELECT TOP 1 s.date 
						FROM #sigmoid s
						WHERE s.person_id=pp.person_id
						AND s.date < DATEADD(MONTH,1,tim.first_mon_date)
						ORDER BY s.date DESC)
				END
					AS hedis_last_sigmoid,
				--Last fit test for patient over 50
				CASE
					WHEN DATEDIFF(YY, pp.dob, tim.first_mon_date) < 50 THEN NULL
					ELSE (SELECT TOP 1 f.date
						FROM #fit f
						WHERE f.person_id=pp.person_id
						AND f.date < DATEADD(MONTH,1,tim.first_mon_date))
                END 
					AS hedis_last_fit,
				--Pull date of a woman over 50's last mammogram
				CASE
					WHEN pp.sex='M' 
					OR DATEDIFF(YY, pp.dob, tim.first_mon_date) < 50 THEN NULL
					ELSE (SELECT TOP 1 m.date
						FROM #mammo m
						WHERE m.person_id=pp.person_id
						AND m.date < DATEADD(MONTH,1,tim.first_mon_date)
						ORDER BY m.date DESC)
				END
					AS hedis_last_mammo
        INTO    #ND_roll_up
        FROM    #person_patient pp
                LEFT JOIN #location_id_remap mh ON pp.person_id = mh.person_id
                LEFT JOIN #Status st ON st.person_id = pp.person_id
                LEFT JOIN #pcp_remap pcp ON pcp.person_id = pp.person_id
                LEFT JOIN ( SELECT  cr_first_office_enc_date ,
                                    person_id ,
                                    cr_first_bill_enc_date ,
                                    first_office_enc_date
                            FROM    #first_enc_date_scrub
                            WHERE   #first_enc_date_scrub.Enc_row = 1
                          ) fed ON fed.person_id = pp.person_id
                --Cross join creates a patient record for every month from start date to end date
                --Allows patient table to be a snapshot table
				--Only creates rows for a patient after their patient record was created 
                CROSS JOIN ( SELECT DISTINCT
                                    first_mon_date
                             FROM   dbo.data_time
                             WHERE  first_mon_date >= CAST(@build_dt_start AS DATETIME)
                                    AND first_mon_date <= CAST(@build_dt_end AS DATETIME)
									
                           ) tim WHERE tim.first_mon_date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, pp.person_create_date), 0);

		--Drop temp tables to conserve memory
		DROP TABLE #colon
		DROP TABLE #mammo
		DROP TABLE #fit
		DROP TABLE #sigmoid

        SELECT  mh.person_id ,
                mh.mh_changed_from_name ,
                mh.mh_changed_to_name ,
                mh.last_changed_date ,
                mh.next_changed_date ,
                mh.mh_changed_date ,
                mh.last_Change ,
                ROW_NUMBER() OVER ( PARTITION BY mh.person_id ORDER BY mh.create_timestamp ASC ) AS change_count
        INTO    #Hx_med_home
        FROM    ( SELECT    source1_id AS person_id ,
                            pre_mod AS mh_changed_from_name ,
                            post_mod AS mh_changed_to_name ,
                            create_timestamp ,
                            LAG(CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE), 1,
                                CAST(@build_dt_start AS DATE)) OVER ( PARTITION BY source1_id ORDER BY create_timestamp ASC ) AS last_changed_date ,
                            LEAD(CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE), 1,
                                 CAST(@build_dt_end AS DATE)) OVER ( PARTITION BY source1_id ORDER BY create_timestamp ASC ) AS next_changed_date ,
                            CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE) AS mh_changed_date ,
                            ROW_NUMBER() OVER ( PARTITION BY source1_id,
                                                CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE) ORDER BY create_timestamp DESC ) AS last_Change
                  FROM      [10.183.0.94].NGProd.dbo.sig_events
                  WHERE     CAST(sig_msg AS VARCHAR(18)) = 'Medical Home  from'
                ) mh
        WHERE   mh.last_Change = 1;

        SELECT  hpcp.person_id ,
                hpcp.pcp_changed_from_name ,
                hpcp.pre_LastName,
                hpcp.pre_FirstName,
                hpcp.post_LastName,
                hpcp.post_FirstName,
                hpcp.pcp_changed_to_name ,
                hpcp.last_changed_date ,
                hpcp.next_changed_date ,
                hpcp.pcp_changed_date ,
                hpcp.last_Change ,
                ROW_NUMBER() OVER ( PARTITION BY hpcp.person_id ORDER BY hpcp.create_timestamp ASC ) AS change_count
        INTO    #Hx_pcp
        FROM    ( SELECT    source1_id AS person_id ,
                            pre_mod AS pcp_changed_from_name ,
                            post_mod AS pcp_changed_to_name ,
                            create_timestamp ,
                            LAG(CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE), 1,
                                CAST(@build_dt_start AS DATE)) OVER ( PARTITION BY source1_id ORDER BY create_timestamp ASC ) AS last_changed_date ,
                            LEAD(CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE), 1,
                                 CAST(@build_dt_end AS DATE)) OVER ( PARTITION BY source1_id ORDER BY create_timestamp ASC ) AS next_changed_date ,
                            CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE) AS pcp_changed_date ,
                            ROW_NUMBER() OVER ( PARTITION BY source1_id,
                                                CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE) ORDER BY create_timestamp DESC ) AS last_Change ,
                            IIF(CHARINDEX(' ',
                                          IIF(CHARINDEX(',', post_mod) > 0, LTRIM(SUBSTRING(post_mod, 1,
                                                                                            CHARINDEX(',', post_mod) - 1)), 'Failed')) > 0, SUBSTRING(IIF(CHARINDEX(',',
                                                                                                        post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        post_mod) - 1)), 'Failed'),
                                                                                                        1,
                                                                                                        CHARINDEX(' ',
                                                                                                        IIF(CHARINDEX(',',
                                                                                                        post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        post_mod) - 1)), 'Failed'))
                                                                                                        - 1), IIF(CHARINDEX(',',
                                                                                                        post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        post_mod) - 1)), 'Failed')) AS post_LastName ,
                            IIF(CHARINDEX(' ',
                                          IIF(CHARINDEX(',', post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                            CHARINDEX(',', post_mod) + 1,
                                                                                            8000)), 'Failed')) > 0, SUBSTRING(IIF(CHARINDEX(',',
                                                                                                        post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                                        CHARINDEX(',',
                                                                                                        post_mod) + 1,
                                                                                                        8000)), 'Failed'),
                                                                                                        1,
                                                                                                        CHARINDEX(' ',
                                                                                                        IIF(CHARINDEX(',',
                                                                                                        post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                                        CHARINDEX(',',
                                                                                                        post_mod) + 1,
                                                                                                        8000)), 'Failed'))
                                                                                                        - 1), IIF(CHARINDEX(',',
                                                                                                        post_mod) > 0, LTRIM(SUBSTRING(post_mod,
                                                                                                        CHARINDEX(',',
                                                                                                        post_mod) + 1,
                                                                                                        8000)), 'Failed')) AS post_FirstName ,
                            IIF(CHARINDEX(' ',
                                          IIF(CHARINDEX(',', pre_mod) > 0, LTRIM(SUBSTRING(pre_mod, 1,
                                                                                           CHARINDEX(',', pre_mod) - 1)), 'Failed')) > 0, SUBSTRING(IIF(CHARINDEX(',',
                                                                                                        pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        pre_mod) - 1)), 'Failed'),
                                                                                                        1,
                                                                                                        CHARINDEX(' ',
                                                                                                        IIF(CHARINDEX(',',
                                                                                                        pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        pre_mod) - 1)), 'Failed'))
                                                                                                        - 1), IIF(CHARINDEX(',',
                                                                                                        pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                                        1,
                                                                                                        CHARINDEX(',',
                                                                                                        pre_mod) - 1)), 'Failed')) AS pre_LastName ,
                            IIF(CHARINDEX(' ',
                                          IIF(CHARINDEX(',', pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                           CHARINDEX(',', pre_mod) + 1,
                                                                                           8000)), 'Failed')) > 0, SUBSTRING(IIF(CHARINDEX(',',
                                                                                                        pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                                        CHARINDEX(',',
                                                                                                        pre_mod) + 1,
                                                                                                        8000)), 'Failed'),
                                                                                                        1,
                                                                                                        CHARINDEX(' ',
                                                                                                        IIF(CHARINDEX(',',
                                                                                                        pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                                        CHARINDEX(',',
                                                                                                        pre_mod) + 1,
                                                                                                        8000)), 'Failed'))
                                                                                                        - 1), IIF(CHARINDEX(',',
                                                                                                        pre_mod) > 0, LTRIM(SUBSTRING(pre_mod,
                                                                                                        CHARINDEX(',',
                                                                                                        pre_mod) + 1,
                                                                                                        8000)), 'Failed')) AS pre_FirstName
                  FROM      [10.183.0.94].NGProd.dbo.sig_events
                  WHERE     CAST(sig_msg AS VARCHAR(29)) = 'Primary Care Provider Changed'
                ) hpcp
        WHERE   hpcp.last_Change = 1;

        SELECT  nr.person_id ,
                nr.first_mon_date ,

                    -- next check if most recent medical home is the last medical home change
                    -- if never medical home change then set all historical medical data to current medical home
                    -- if there has been a change but last change does not == current medical home then keep the last
                    -- change only for 3  months after the change (4 months total including change month)
                    --  If mh does not appear in the look up key or it is set to unassigned or unknown clinic, then assigned key is NULL
                CASE WHEN nr.pcp_cur_key != ( SELECT TOP 1  -- yes I wish I didn't have to use top, but the DQ issues are so prevelant that this is a work around.
                                                        user_key
                                              FROM      dbo.data_user
                                              WHERE    ( (COALESCE(pcp.pcp_changed_to_name, pcp_pre.pcp_changed_from_name) = provider_name) OR
                                                        (COALESCE(pcp.post_FirstName,pcp_pre.pre_FirstName)= firstname_cleaned AND
                                                         COALESCE(pcp.post_LastName,pcp_pre.pre_LastName)= lastname_cleaned
                                                         AND lastname_cleaned != 'Failed' AND FirstName_cleaned !='Failed'

                                                         ))
                                                           AND [unique_provider_id_flag] = 1
                                                           AND COALESCE(provider_name,'') !=''
                                              ORDER BY  provider_name ,
                                                        delete_ind
                                            )
                          AND pcp.change_count >= 1
                          AND MAX(pcp.change_count) OVER ( PARTITION BY nr.person_id ) = pcp.change_count
                          AND DATEDIFF(m, COALESCE(pcp.pcp_changed_date, pcp_pre.pcp_changed_date), nr.first_mon_date) > 3
                     THEN nr.pcp_cur_key
                                    --if the mh was never tracked change the assign it to the current key
                     WHEN MAX(pcp.change_count) OVER ( PARTITION BY nr.person_id ) IS NULL THEN nr.pcp_cur_key
                     WHEN COALESCE ( (SELECT TOP 1  -- yes I wish I didn't have to use top, but the DQ issues are so prevelant that this is a work around.
                                                        user_key
                                              FROM      dbo.data_user
                                              WHERE    ( (COALESCE(pcp.pcp_changed_to_name, pcp_pre.pcp_changed_from_name) = provider_name) OR
                                                        (COALESCE(pcp.post_FirstName,pcp_pre.pre_FirstName)= firstname_cleaned AND
                                                         COALESCE(pcp.post_LastName,pcp_pre.pre_LastName)= lastname_cleaned
                                                         AND lastname_cleaned != 'Failed' AND FirstName_cleaned !='Failed'
                                                                                                  )

                                                         )
                                                           AND [unique_provider_id_flag] = 1
                                                                  AND COALESCE(provider_name,'') !=''
                                              ORDER BY  provider_name ,
                                                        delete_ind
                                            ),'') !='' THEN (SELECT TOP 1  -- yes I wish I didn't have to use top, but the DQ issues are so prevelant that this is a work around.
                                                        user_key
                                              FROM      dbo.data_user
                                              WHERE    ( (COALESCE(pcp.pcp_changed_to_name, pcp_pre.pcp_changed_from_name) = provider_name) OR
                                                        (COALESCE(pcp.post_FirstName,pcp_pre.pre_FirstName)= firstname_cleaned AND
                                                         COALESCE(pcp.post_LastName,pcp_pre.pre_LastName)= lastname_cleaned
                                                        AND lastname_cleaned != 'Failed' AND FirstName_cleaned !='Failed'

                                                         ))
                                                           AND [unique_provider_id_flag] = 1
                                                                  AND COALESCE(provider_name,'') !=''
                                              ORDER BY  provider_name ,
                                                        delete_ind
                                            )
                    WHEN nr.first_mon_date = CAST(CONVERT(VARCHAR(6), GETDATE(), 112)+'01' AS DATE)
                         THEN nr.pcp_cur_key
                    ELSE NULL

                END AS pcp_hx_key
        INTO    #Hx_pcp_process
        FROM    #ND_roll_up nr --Populate change tracking data -- add it based on the date of the change going forward until the month before the next change
                                --A few comments about changes -- There is a possibility that this could introduce duplicates if change tracking records
                                --get merged onto same first_mon_date, my audit shows that based on typical behavior this is not happening
                                --Would be worth checking for this constraint.
                                --If this routine ever gets moved to production there could be an instance where the first_mon_date = @build_dt_end and
                                --a tracked change was made to the medical home on the same day, its possible that the change will not be tracked
                LEFT JOIN #Hx_pcp pcp ON pcp.person_id = nr.person_id
                                         AND nr.first_mon_date >= pcp.pcp_changed_date
                                         AND nr.first_mon_date > pcp.last_changed_date
                                         AND nr.first_mon_date < pcp.next_changed_date

                                --Populate Hx based on build date with changed from information if available up until the month before the next change date
                LEFT JOIN #Hx_pcp pcp_pre ON pcp_pre.person_id = nr.person_id
                                             AND pcp_pre.last_changed_date = CAST(@build_dt_start AS DATE)
                                             AND nr.first_mon_date < pcp_pre.pcp_changed_date

              --SELECT * FROM #Hx_pcp WHERE person_id = '87690A72-0B44-42A1-8A78-8BA3B316861A' ORDER BY first_mon_date
             

        SELECT  hstatus.person_id ,
                hstatus.status_changed_from_name ,
                hstatus.status_changed_to_name ,
                hstatus.last_changed_date ,
                hstatus.next_changed_date ,
                hstatus.status_changed_date ,
                hstatus.last_Change ,
                ROW_NUMBER() OVER ( PARTITION BY hstatus.person_id ORDER BY hstatus.create_timestamp ASC ) AS change_count
        INTO    #Hx_status
        FROM    ( SELECT    source1_id AS person_id ,
                            pre_mod AS status_changed_from_name ,
                            post_mod AS status_changed_to_name ,
                            create_timestamp ,
                            LAG(CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE), 1,
                                CAST(@build_dt_start AS DATE)) OVER ( PARTITION BY source1_id ORDER BY create_timestamp ASC ) AS last_changed_date ,
                            LEAD(CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE), 1,
                                 CAST(@build_dt_end AS DATE)) OVER ( PARTITION BY source1_id ORDER BY create_timestamp ASC ) AS next_changed_date ,
                            CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE) AS status_changed_date ,
                            ROW_NUMBER() OVER ( PARTITION BY source1_id,
                                                CAST(CONVERT(VARCHAR(6), create_timestamp, 112) + '01' AS DATE) ORDER BY create_timestamp DESC ) AS last_Change
                  FROM      [10.183.0.94].NGProd.dbo.sig_events
                  WHERE     sig_msg = 'Patient Status Changed'
                ) hstatus
        WHERE   hstatus.last_Change = 1;

        SELECT  nr.person_id ,
                nr.first_mon_date ,

                    -- next check if most recent medical home is the last medical home change
                    -- if never medical home change then set all historical medical data to current medical home
                    -- if there has been a change but last change does not == current medical home then keep the last
                    -- change only for 3  months after the change (4 months total including change month)
                    --  If mh does not appear in the look up key or it is set to unassigned or unknown clinic, then assigned key is NULL
                CASE WHEN nr.status_cur_key != COALESCE(stat.status_changed_to_name, stat_pre.status_changed_from_name)
                          AND stat.change_count >= 1
                          AND MAX(stat.change_count) OVER ( PARTITION BY nr.person_id ) = stat.change_count
                          AND DATEDIFF(m, COALESCE(stat.status_changed_date, stat_pre.status_changed_date),
                                       nr.first_mon_date) > 3 THEN nr.status_cur_key
                                    --if the mh was never tracked change the assign it to the current key
                     WHEN MAX(stat.change_count) OVER ( PARTITION BY nr.person_id ) IS NULL THEN nr.status_cur_key
                     ELSE COALESCE(stat.status_changed_to_name, stat_pre.status_changed_from_name)
                END AS status_hx_key
        INTO    #Hx_status_process
        FROM    #ND_roll_up nr --Populate change tracking data -- add it based on the date of the change going forward until the month before the next change
                                --A few comments about changes -- There is a possibility that this could introduce duplicates if change tracking records
                                --get merged onto same first_mon_date, my audit shows that based on typical behavior this is not happening
                                --Would be worth checking for this constraint.
                                --If this routine ever gets moved to production there could be an instance where the first_mon_date = @build_dt_end and
                                --a tracked change was made to the medical home on the same day, its possible that the change will not be tracked
                LEFT JOIN #Hx_status stat ON stat.person_id = nr.person_id
                                             AND nr.first_mon_date >= stat.status_changed_date
                                             AND nr.first_mon_date > stat.last_changed_date
                                             AND nr.first_mon_date < stat.next_changed_date

                                --Populate Hx based on build date with changed from information if available up until the month before the next change date
                LEFT JOIN #Hx_status stat_pre ON stat_pre.person_id = nr.person_id
                                                 AND stat_pre.last_changed_date = CAST(@build_dt_start AS DATE)
                                                 AND nr.first_mon_date < stat_pre.status_changed_date

        SELECT  nr.person_id ,
                nr.first_mon_date ,

                    -- next check if most recent medical home is the last medical home change
                    -- if never medical home change then set all historical medical data to current medical home
                    -- if there has been a change but last change does not == current medical home then keep the last
                    -- change only for 3  months after the change (4 months total including change month)
                    --  If mh does not appear in the look up key or it is set to unassigned or unknown clinic, then assigned key is NULL
                CASE WHEN
                         nr.mh_cur_key != ( SELECT TOP 1
                                                    location_key
                                             FROM   dbo.data_location
                                             WHERE  COALESCE(hmh.mh_changed_to_name, hmh_pre.mh_changed_from_name) = location_mh_name
                                                    AND [location_id_unique_flag] = 1
                                           )
                          AND hmh.change_count >= 1
                          AND MAX(hmh.change_count) OVER ( PARTITION BY nr.person_id ) = hmh.change_count
                          AND DATEDIFF(m, COALESCE(hmh.mh_changed_date, hmh_pre.mh_changed_date), nr.first_mon_date) > 3
                     THEN nr.mh_cur_key
                                    --if the mh was never tracked change the assign it to the current key
                     WHEN MAX(hmh.change_count) OVER ( PARTITION BY nr.person_id ) IS NULL THEN nr.mh_cur_key
                     ELSE ( SELECT TOP 1
                                    location_key
                            FROM    dbo.data_location
                            WHERE   COALESCE(hmh.mh_changed_to_name, hmh_pre.mh_changed_from_name) = location_mh_name
                                    AND [location_id_unique_flag] = 1
                          )
                END AS mh_hx_key
        INTO    #Hx_med_home_process
        FROM    #ND_roll_up nr --Populate change tracking data -- add it based on the date of the change going forward until the month before the next change
                                --A few comments about changes -- There is a possibility that this could introduce duplicates if change tracking records
                                --get merged onto same first_mon_date, my audit shows that based on typical behavior this is not happening
                                --Would be worth checking for this constraint.
                                --If this routine ever gets moved to production there could be an instance where the first_mon_date = @build_dt_end and
                                --a tracked change was made to the medical home on the same day, its possible that the change will not be tracked
                LEFT JOIN #Hx_med_home hmh ON hmh.person_id = nr.person_id
                                              AND nr.first_mon_date >= hmh.mh_changed_date
                                              AND nr.first_mon_date > hmh.last_changed_date
                                                            -- AND hmh.last_changed_date != CAST(@build_dt_start AS DATE)
                                              AND nr.first_mon_date < hmh.next_changed_date

                                --Populate Hx based on build date with changed from information if available up until the month before the next change date
                LEFT JOIN #Hx_med_home hmh_pre ON hmh_pre.person_id = nr.person_id
                                                  AND hmh_pre.last_changed_date = CAST(@build_dt_start AS DATE)
                                                  AND nr.first_mon_date < hmh_pre.mh_changed_date

        SELECT  IDENTITY( INT, 1, 1 )  AS per_mon_id ,
				nr.person_key,
                nr.person_id ,
                nr.first_mon_date ,
                nr.mh_cur_key ,
                hx_mh.mh_hx_key ,
                nr.pcp_cur_key ,
                hx_pcp.pcp_hx_key ,
                nr.status_cur_key ,
                hx_stat.status_hx_key ,
                nr.cr_first_office_enc_date ,
                nr.expired_date ,
                nr.First_enc_age_months ,
                nr.nbr_new_pt ,
                nr.nbr_pt_seen_office_ever ,
                nr.nbr_pt_deceased ,
                nr.nbr_pt_deceased_this_month ,
                nr.patient_vintage ,

                       --Populate age if patient has not expired
                CASE
                     WHEN nr.dob IS NOT NULL
                          AND nr.nbr_pt_deceased != 1 THEN DATEDIFF(YY, nr.dob, nr.first_mon_date)
                     WHEN nr.dob IS NOT NULL
                          AND nr.nbr_pt_deceased = 1
                          AND nr.expired_date IS NOT NULL THEN DATEDIFF(YY, nr.dob, nr.expired_date)
                     ELSE NULL
                END
                    AS age_hx ,

                    --If patient is deceased then age = null
                CASE
                     WHEN nr.dob IS NOT NULL
                          AND nr.nbr_pt_deceased != 1 THEN DATEDIFF(YY, nr.dob, GETDATE())
                     WHEN nr.dob IS NOT NULL
                          AND nr.nbr_pt_deceased = 1
                          AND nr.expired_date IS NOT NULL THEN DATEDIFF(YY, nr.dob, nr.expired_date)
                     ELSE NULL
                END
                     AS age_cur ,
                nr.dob ,
                nr.full_name ,
                nr.first_name ,
                nr.last_name ,
                nr.middle_name ,
                nr.address_line_1 ,
                nr.address_line_2 ,
                nr.city ,
                nr.state ,
                RIGHT('00000' + LTRIM(RTRIM(nr.zip)), 5) AS zip , --DQ Change
                nr.home_phone ,
                nr.sex ,
                nr.ssn ,
                nr.alt_phone ,
                nr.marital_status ,
                nr.race ,
				nr.ethnicity,
                REPLACE(nr.language, '*', '') AS language , --DQ Change
				nr.disability_1,
				nr.disability_2,
				nr.homeless_status,
				nr.homeless_count,
                nr.med_rec_nbr,
				nr.chart_create_date,
				nr.chart_create_user,
				nr.person_create_date,
				nr.person_create_user,
				nr.last_bp_sys,
				nr.last_bp_dia,
				nr.hedis_crc_denom,
				nr.hedis_bc_denom,
				nr.hedis_last_colon,
				nr.hedis_last_sigmoid,
				nr.hedis_last_fit,
				nr.hedis_last_mammo,
				CASE
					WHEN nr.hedis_crc_denom = 0 THEN 0
					--**DQ** 10 years or 119 months? 5 years or 59 months?Does first_mon_date throw it off?
					WHEN DATEDIFF(MONTH,nr.hedis_last_colon,nr.first_mon_date) <= 119
					OR DATEDIFF(MONTH,nr.hedis_last_sigmoid,nr.first_mon_date) <= 59
					OR DATEDIFF(MONTH,nr.hedis_last_fit,nr.first_mon_date) <= 11 THEN 1
					ELSE 0
				END
					AS hedis_crc_num,
				CASE
					WHEN nr.hedis_bc_denom = 0 THEN 0
					WHEN DATEDIFF(MONTH,nr.hedis_last_mammo,nr.first_mon_date) <= 23 THEN 1
					ELSE 0
				END
					AS hedis_bc_num
        INTO    dbo.data_person_nd_month
        FROM    #ND_roll_up nr
                LEFT JOIN #Hx_med_home_process hx_mh ON hx_mh.person_id = nr.person_id
                                                        AND hx_mh.first_mon_date = nr.first_mon_date
                LEFT JOIN #Hx_pcp_process hx_pcp ON hx_pcp.person_id = nr.person_id
                                                    AND hx_pcp.first_mon_date = nr.first_mon_date
                LEFT JOIN #Hx_status_process hx_stat ON hx_stat.person_id = nr.person_id
                                                        AND hx_stat.first_mon_date = nr.first_mon_date


        ALTER TABLE dbo.data_person_nd_month
        ADD CONSTRAINT per_mon_id_pk PRIMARY KEY (per_mon_id);

        CREATE NONCLUSTERED INDEX IX_person_mon_x_first_mon_date2
        ON dbo.data_person_nd_month (per_mon_id, first_mon_date);

    END;
GO
