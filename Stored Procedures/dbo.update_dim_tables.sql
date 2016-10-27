SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_dim_tables]
AS
    BEGIN

        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        IF OBJECT_ID('dbo.[Dim NG User]') IS NOT NULL
            DROP TABLE  dbo.[Dim NG User];

        IF OBJECT_ID('dbo.[Dim Provider]') IS NOT NULL
            DROP TABLE  dbo.[Dim Provider];

        IF OBJECT_ID('dbo.[Dim NG Resource]') IS NOT NULL
            DROP TABLE  dbo.[Dim NG Resource];

        IF OBJECT_ID('dbo.[Dim PHI Patient Quality]') IS NOT NULL
            DROP TABLE dbo.[Dim PHI Patient Quality];


        IF OBJECT_ID('dbo.[Dim Status Enc and Appt]') IS NOT NULL
            DROP TABLE  dbo.[Dim Status Enc and Appt];
 
        IF OBJECT_ID('dbo.[Dim Appt Event]') IS NOT NULL
            DROP TABLE   dbo.[Dim Appt Event];

        IF OBJECT_ID('dbo.[Dim Medical Home Current]') IS NOT NULL
            DROP TABLE dbo.[Dim Medical Home Current];
			
        IF OBJECT_ID('dbo.[Dim Medical Home Historical]') IS NOT NULL
            DROP TABLE dbo.[Dim Medical Home Historical];
			   
        IF OBJECT_ID('dbo.[Dim PCP Current]') IS NOT NULL
            DROP TABLE dbo.[Dim PCP Current];

        IF OBJECT_ID('dbo.[Dim PCP Historical]') IS NOT NULL
            DROP TABLE dbo.[Dim PCP Historical];
        IF OBJECT_ID('dbo.[Dim PHI Patient]') IS NOT NULL
            DROP TABLE dbo.[Dim PHI Patient];	 

        IF OBJECT_ID('dbo.[Dim Patient]') IS NOT NULL
            DROP TABLE dbo.[Dim Patient];	 

--Need to drop Fact and a few Dim Patient tables first because of FK constraints
		
		--Deprecated
        --IF OBJECT_ID('dbo.[Dim Encounter Status]') IS NOT NULL
        --    DROP TABLE dbo.[Dim Encounter Status];
					
        IF OBJECT_ID('dbo.[Dim Location for Enc or Appt]') IS NOT NULL
            DROP TABLE  dbo.[Dim Location for Enc or Appt];
			    
        IF OBJECT_ID('dbo.[Dim User Encounter Creator]') IS NOT NULL
            DROP TABLE  dbo.[Dim User Encounter Creator];

        IF OBJECT_ID('dbo.[Dim Provider Rendering]') IS NOT NULL
            DROP TABLE dbo.[Dim Provider Rendering];
		
		--Deprecated
        --IF OBJECT_ID('dbo.[Dim PHI Validate]') IS NOT NULL
        --    DROP TABLE dbo.[Dim PHI Validate];	 


        IF OBJECT_ID('dbo.[Dim Time]') IS NOT NULL
            DROP TABLE  dbo.[Dim Time];
			
        IF OBJECT_ID('dbo.[Dim User Schedule Resource]') IS NOT NULL
            DROP TABLE		 dbo.[Dim User Schedule Resource];
	
        IF OBJECT_ID('dbo.[Dim User Appointment Creator]') IS NOT NULL
            DROP TABLE	dbo.[Dim User Appointment Creator];
	 
        IF OBJECT_ID('dbo.[Dim User Checkout]') IS NOT NULL
            DROP TABLE	dbo.[Dim User Checkout];

        IF OBJECT_ID('dbo.[Dim User Checkin]') IS NOT NULL
            DROP TABLE	dbo.[Dim User Checkin];

        IF OBJECT_ID('dbo.[Dim User Ready for Provider]') IS NOT NULL
            DROP TABLE	 dbo.[Dim User Ready for Provider];


			
        IF OBJECT_ID('dbo.[Dim Employee Hour Detail]') IS NOT NULL
            DROP TABLE	dbo.[Dim Employee Hour Detail];


			
        --IF OBJECT_ID('dbo.[Dim Employee]') IS NOT NULL
        --    DROP TABLE	 dbo.[Dim Employee];

				
        --IF OBJECT_ID('dbo.[Dim Employee Historical]') IS NOT NULL
        --    DROP TABLE	 dbo.[Dim Employee Historical];


        --IF OBJECT_ID('dbo.bridge_emp_to_emp_mon') IS NOT NULL
        --    DROP TABLE	dbo.bridge_emp_to_emp_mon;
			
        --IF OBJECT_ID('dbo.bridge_usr_emp') IS NOT NULL
        --    DROP TABLE	dbo.bridge_usr_emp;
			
			
        IF OBJECT_ID('dbo.[Dim Category and Event]') IS NOT NULL
            DROP TABLE	dbo.[Dim Category and Event];
		
        IF OBJECT_ID('dbo.[Dim Time of Day]') IS NOT NULL
            DROP TABLE	dbo.[Dim Time of Day];
		
		
        SELECT  un.appt_time AS [Time of Slot] ,
                CASE WHEN SUBSTRING(un.appt_time, 1, 2) < 12 THEN 'AM'
                     ELSE 'PM'
                END AS meridiem
        INTO    dbo.[Dim Time of Day]
        FROM    ( SELECT    appt_time
                  FROM      dwh.data_appointment 
                  UNION
                  SELECT    slot_time AS appt_time
                  FROM      dwh.data_schedule_slots
                ) un
        WHERE   un.appt_time IS NOT NULL
        ORDER BY un.appt_time;
	
        ALTER TABLE dbo.[Dim Time of Day]
        ALTER COLUMN [Time of Slot] VARCHAR(4) NOT NULL;
			
        ALTER TABLE   dbo.[Dim Time of Day]
        ADD CONSTRAINT appt_time_pk2 PRIMARY KEY ([Time of Slot]);
			
		--Deprecated table in DWH
        --SELECT  DISTINCT
        --        enc_comp_key ,
        --        enc_comp_key_name AS [Encounter Status]
        --INTO    dbo.[Dim Encounter Status]
        --FROM    dwh.data_encounter;   

        --ALTER TABLE dbo.[Dim Encounter Status]
        --ALTER COLUMN enc_comp_key BIGINT NOT NULL;

        --ALTER TABLE  dbo.[Dim Encounter Status]
        --ADD CONSTRAINT enc_comp_key_pk PRIMARY KEY (enc_comp_key);

		
        SELECT  [PK_date] AS [Key Date] ,
                [date_name_short_10] AS [MM-DD-YYYY] ,
                [date_name_short_08] AS [YYYYMMDD] ,
                [first_mon_date] AS [First Day of Month Date] ,
                [Date_Name] AS [Long Day Name] ,
                [Year] AS Year_sort ,
                [Year_Name] AS [Year] ,
                [Half_Year] ,
                [Half_Year_Name] AS [Half Year] ,
                [Quarter] AS Quarter_sort ,
                [Quarter_Name] AS [Quarter] ,
                [Month] AS Month_sort ,
                [Month_Name] AS [Month] ,
                [Week] AS week_sort ,
                [Week_Name] AS [Week] ,
                [MondayOfWeek] AS [Week - Monday] ,
                [Day_Of_Year] ,
                [Day_Of_Year_Name] AS [Day of Year] ,
                [Day_Of_Half_Year] ,
                [Day_Of_Half_Year_Name] AS [Day of Half-Year] ,
                [Day_Of_Quarter] ,
                [Day_Of_Quarter_Name] AS [Day of Quarter] ,
                [Day_Of_Month] ,
                [Day_Of_Month_Name] AS [Day of Month] ,
                [Day_Of_Week] ,
                [Day_Of_Week_Name] AS [Day of Week] ,
                [Week_Of_Year] ,
                [Week_Of_Year_Name] AS [Week of Year] ,
                [Month_Of_Year] ,
                [Month_Of_Year_Name] AS [Month of Year] ,
                [Month_Of_Half_Year] ,
                [Month_Of_Half_Year_Name] AS [Month of Half Year] ,
                [Month_Of_Quarter] ,
                [Month_Of_Quarter_Name] AS [Month of Quarter] ,
                [Quarter_Of_Year] ,
                [Quarter_Of_Year_Name] AS [Quarter of Year] ,
                [Quarter_Of_Half_Year] ,
                [Quarter_Of_Half_Year_Name] AS [Quarter of Half Year] ,
                [Half_Year_Of_Year] ,
                [Half_Year_Of_Year_Name] AS [Half Year of Year] ,
                [Fiscal_Year] ,
                [Fiscal_Year_Name] AS [Fiscal Year] ,
                [Fiscal_Half_Year] ,
                [Fiscal_Half_Year_Name] AS [Fiscal Half Year] ,
                [Fiscal_Quarter] ,
                [Fiscal_Quarter_Name] AS [Fiscal Quarter] ,
                [Fiscal_Month] ,
                [Fiscal_Month_Name] AS [Fiscal Month] ,
                [Fiscal_Week] ,
                [Fiscal_Week_Name] AS [Fiscal Week] ,
                [Fiscal_Day] ,
                [Fiscal_Day_Name] AS [Fiscal Day] ,
                [Fiscal_Day_Of_Year] ,
                [Fiscal_Day_Of_Year_Name] AS [Fiscal Day OF Year] ,
                [Fiscal_Day_Of_Half_Year] ,
                [Fiscal_Day_Of_Half_Year_Name] AS [Fiscal Day of Half Year] ,
                [Fiscal_Day_Of_Quarter] ,
                [Fiscal_Day_Of_Quarter_Name] AS [Fiscal Day of Quarter] ,
                [Fiscal_Day_Of_Month] ,
                [Fiscal_Day_Of_Month_Name] AS [Fiscal Day of Month] ,
                [Fiscal_Day_Of_Week] ,
                [Fiscal_Day_Of_Week_Name] AS [Fiscal Day of Week] ,
                [Fiscal_Week_Of_Year] ,
                [Fiscal_Week_Of_Year_Name] AS [Fiscal Week of Year] ,
                [Fiscal_Month_Of_Year] ,
                [Fiscal_Month_Of_Year_Name] AS [Fiscal Month of Year] ,
                [Fiscal_Month_Of_Half_Year] ,
                [Fiscal_Month_Of_Half_Year_Name] AS [Fiscal Month of Half Year] ,
                [Fiscal_Month_Of_Quarter] ,
                [Fiscal_Month_Of_Quarter_Name] AS [Fiscal Month OF Quarter] ,
                [Fiscal_Quarter_Of_Year] ,
                [Fiscal_Quarter_Of_Year_Name] AS [Fiscal Quarter of Year] ,
                [Fiscal_Quarter_Of_Half_Year] ,
                [Fiscal_Quarter_Of_Half_Year_Name] AS [Fiscal Quarter of Half Year] ,
                [Fiscal_Half_Year_Of_Year] ,
                [Fiscal_Half_Year_Of_Year_Name] AS [Fiscal Half Year of Year ] ,
                [Relative_days_to_CurrentDate] AS [Relative Days to Today] ,
                [Relative_months_to_CurrentDate] AS [Relative Months to Today] ,
                [Relative_weeks_to_CurrentDate] AS [Relative Weeks to Today]
        INTO    dbo.[Dim Time]
        FROM    dwh.data_time;


        ALTER TABLE   dbo.[Dim Time]
        ADD CONSTRAINT date_pk1 PRIMARY KEY ([Key Date]);


        SELECT  location_key ,
                site_id ,
                location_mstr_name AS [Location for Enc or Appt],
				location_address AS [Location Address],
				location_id
        INTO    dbo.[Dim Location for Enc or Appt]
        FROM    dwh.data_location;

		--Update site ID to reflect multiple locations summarized under one site
		UPDATE dbo.[Dim Location for Enc or Appt]
		SET  site_id = CASE
								WHEN location_id LIKE '23EA0199-4D95-4D9B-97D9-75004771724F'
									 OR location_id LIKE '3B53E6CB-9574-4A33-B39D-E3F9B3966920' THEN '100'	
								WHEN location_id LIKE '93178C71-C492-465E-9F2C-5666D28ED691' THEN '400'	
								WHEN location_id LIKE 'C5AFBCAC-549D-4EB5-BAC4-B9905689FB04' THEN '620'
								WHEN location_id LIKE 'BB283B70-0942-4ED1-94D8-5F90EB4666CD' THEN '220'
								WHEN location_id LIKE '3ABEBD6C-D1BA-4295-9BB3-358506F40E80' THEN '200'
								WHEN location_id LIKE '6EBE563F-39A4-49C1-936A-B6966CECFF7C' 
								OR location_id LIKE '807D14E1-53FD-4FDF-9089-DFD8F7865251' THEN '892'
								WHEN location_id LIKE '4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD' THEN '840'
							END
		WHERE location_id IN (
								'23EA0199-4D95-4D9B-97D9-75004771724F',
								'3B53E6CB-9574-4A33-B39D-E3F9B3966920',
								'93178C71-C492-465E-9F2C-5666D28ED691',
								'C5AFBCAC-549D-4EB5-BAC4-B9905689FB04',
								'BB283B70-0942-4ED1-94D8-5F90EB4666CD',
								'3ABEBD6C-D1BA-4295-9BB3-358506F40E80',
								'6EBE563F-39A4-49C1-936A-B6966CECFF7C',
								'807D14E1-53FD-4FDF-9089-DFD8F7865251',
								'4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD')

		
        ALTER TABLE   dbo.[Dim Location for Enc or Appt]
        ADD CONSTRAINT location_key_33 PRIMARY KEY (location_key);

        SELECT  location_key ,
                location_mstr_name AS [Medical Home Current] ,
                site_id
        INTO    dbo.[Dim Medical Home Current]
        FROM    dwh.data_location;
		
        ALTER TABLE  dbo.[Dim Medical Home Current]	
        ADD CONSTRAINT location_key_pk2 PRIMARY KEY (location_key);

        SELECT  location_key ,
                site_id ,
                location_mstr_name AS [Medical Home Historical]
        INTO    dbo.[Dim Medical Home Historical]
        FROM    dwh.data_location;
		
        ALTER TABLE  dbo.[Dim Medical Home Historical]	
        ADD CONSTRAINT location_key_pk3 PRIMARY KEY (location_key);

        SELECT  user_key ,
                FullName AS [User Encounter Creator] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree
        INTO    dbo.[Dim User Encounter Creator]
        FROM    dwh.data_user;
		
        ALTER TABLE   dbo.[Dim User Encounter Creator]
        ADD CONSTRAINT user_key_pk231 PRIMARY KEY (user_key);
		
		
		







        SELECT  user_key ,
                employee_key ,
                FullName AS [PCP Current] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree ,
                [active_3m_provider] AS [Active Provider] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider] ,
                [active_3m_provider] AS [Primary Site Active Provider 3m] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider 3m] ,
                [active_3ms_provider] AS [Secondary Site Active Provider 3m] ,
                [secondary_loc_3m_provider] AS [Secondary Location for Provider 6m] ,
                [active_6m_provider] AS [Primary Active Provider 6m] ,
                [primary_loc_6m_provider] AS [Primary Location for Provider 6m] ,
                [active_12m_provider] AS [Active Provider 12m] ,
                [primary_loc_12m_provider] AS [Primary Location Provider 12m] ,
                [hr_employee_id] AS [HR Employee Number] ,
                [hr_job_title] AS [HR Employee Title] ,
                [hr_location_id] AS [HR Location ID] ,
                [hr_location_name] AS [HR Location Name]
        INTO    dbo.[Dim PCP Current]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim PCP Current]
        ADD CONSTRAINT user_key_pk2 PRIMARY KEY (user_key);


        SELECT  user_key ,
                employee_key ,
                FullName AS [PCP Historical] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree ,
                [active_3m_provider] AS [Active Provider] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider] ,
                [active_3m_provider] AS [Primary Site Active Provider 3m] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider 3m] ,
                [active_3ms_provider] AS [Secondary Site Active Provider 3m] ,
                [secondary_loc_3m_provider] AS [Secondary Location for Provider 6m] ,
                [active_6m_provider] AS [Primary Active Provider 6m] ,
                [primary_loc_6m_provider] AS [Primary Location for Provider 6m] ,
                [active_12m_provider] AS [Active Provider 12m] ,
                [primary_loc_12m_provider] AS [Primary Location Provider 12m] ,
                [hr_employee_id] AS [HR Employee Number] ,
                [hr_job_title] AS [HR Employee Title] ,
                [hr_location_id] AS [HR Location ID] ,
                [hr_location_name] AS [HR Location Name]
        INTO    dbo.[Dim PCP Historical]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim PCP Historical]
        ADD CONSTRAINT user_key_pk18 PRIMARY KEY (user_key);

		
        SELECT  user_key ,
                employee_key ,
                FullName AS [Provider Rendering] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree ,
                [active_3m_provider] AS [Active Provider] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider] ,
                [active_3m_provider] AS [Primary Site Active Provider 3m] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider 3m] ,
                [active_3ms_provider] AS [Secondary Site Active Provider 3m] ,
                [secondary_loc_3m_provider] AS [Secondary Location for Provider 6m] ,
                [active_6m_provider] AS [Primary Active Provider 6m] ,
                [primary_loc_6m_provider] AS [Primary Location for Provider 6m] ,
                [active_12m_provider] AS [Active Provider 12m] ,
                [primary_loc_12m_provider] AS [Primary Location Provider 12m] ,
                [hr_employee_id] AS [HR Employee Number] ,
                [hr_job_title] AS [HR Employee Title] ,
                [hr_location_id] AS [HR Location ID] ,
                [hr_location_name] AS [HR Location Name]
        INTO    dbo.[Dim Provider Rendering]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim Provider Rendering]
        ADD CONSTRAINT user_key_pk17 PRIMARY KEY (user_key);

--New set of dim patient

        SELECT  [user_key] ,
                [employee_key] ,
                [first_name] [NG User First Name] ,
                [last_name] [NG User Last Name] ,
                [FullName] [NG User Full Name]
        INTO    dbo.[Dim NG User]
        FROM    [Prod_Ghost].[dwh].[data_user_v2];

        SELECT  [provider_key] ,
                user_key ,
                employee_key ,
                [role_status] [Role Status] ,
                [first_name] [NG Prov First Name] ,
                [last_name] [NG Prov Last Name] ,
                [FullName] [NG Prov Full Name] ,
                [provider_name] [NG Prov Provider Name] ,
            
                [first_name] [Prov First Name] ,
                [last_name] [Prov Last Name] ,
                [FullName] [Prov Full Name] ,
              --  [provider_name] [Prov Provider Name] ,
                
				
				
				
				[degree] [Degree] ,
                [active_3m_provider] AS [Active Provider] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider] ,
                [active_3m_provider] AS [Primary Site Active Provider 3m] ,
                [primary_loc_3m_provider] AS [Primary Location for Provider 3m] ,
                [active_3ms_provider] AS [Secondary Site Active Provider 3m] ,
                [secondary_loc_3m_provider] AS [Secondary Location for Provider 6m] ,
                [active_6m_provider] AS [Primary Active Provider 6m] ,
                [primary_loc_6m_provider] AS [Primary Location for Provider 6m] ,
                [active_12m_provider] AS [Active Provider 12m] ,
                [primary_loc_12m_provider] AS [Primary Location Provider 12m]
        INTO    dbo.[Dim Provider]
        FROM    [Prod_Ghost].[dwh].[data_provider];

        SELECT  [resource_key] ,
                [resource_name] [NG Schedule Resource Name] ,
                [provider_key]
        INTO    dbo.[Dim NG Resource]
        FROM    [Prod_Ghost].[dwh].[data_resource];
  


  -------







        SELECT  user_key ,
                employee_key ,
                FullName AS [User Schedule Resource] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree
        INTO    dbo.[Dim User Schedule Resource]
        FROM    dwh.data_user;
		
        ALTER TABLE   dbo.[Dim User Schedule Resource]
        ADD CONSTRAINT user_key_pk16 PRIMARY KEY (user_key);
	
        SELECT  user_key ,
                FullName AS [User Appointment Creator] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree
        INTO    dbo.[Dim User Appointment Creator]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim User Appointment Creator]
        ADD CONSTRAINT user_key_pk15 PRIMARY KEY (user_key);

	
        SELECT  user_key ,
                FullName AS [User Checkout] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree
        INTO    dbo.[Dim User Checkout]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim User Checkout]
        ADD CONSTRAINT user_key_pk14 PRIMARY KEY (user_key);

		 
        SELECT  user_key ,
                FullName AS [User Checkin] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree
        INTO    dbo.[Dim User Checkin]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim User Checkin]
        ADD CONSTRAINT user_key_pk13 PRIMARY KEY (user_key);
		 

        SELECT  [employee_hours_comp_key] ,
                [status_type] AS [Hours Type] ,
                [status_ec_tc] AS [Hours Category from Timecard] ,
                [status_ec_pr] AS [Hours Category from Payroll]
        INTO    dbo.[Dim Employee Hour Detail]
        FROM    [Prod_Ghost].[dwh].[data_employee_hours_status];

  
        ALTER TABLE  dbo.[Dim Employee Hour Detail]
        ADD CONSTRAINT employee_hours_comp_key_pk PRIMARY KEY ([employee_hours_comp_key]);
		
		


        SELECT  user_key ,
                FullName AS [User Ready for Provider] ,
                resource_name AS [Resource Name] ,
                role_status AS [Role Status] ,
                degree AS Degree
        INTO    dbo.[Dim User Ready for Provider]
        FROM    dwh.data_user;
		
        ALTER TABLE  dbo.[Dim User Ready for Provider]
        ADD CONSTRAINT user_key_pk34 PRIMARY KEY (user_key);
		 
        SELECT  event_key ,
                event_name AS [Appt Event Name]
        INTO    dbo.[Dim Appt Event]
        FROM    dwh.data_event;
		
        ALTER TABLE   dbo.[Dim Appt Event]
        ADD CONSTRAINT event_key_pk1 PRIMARY KEY (event_key);
		 

        SELECT  [cat_event_key] ,
                [event_id] ,
                [category_id] ,
                [category_description] AS [Category Name] ,
                [event_description] [Event Name] ,
                [prevent_appt] AS [Prevent Appt]
        INTO    dbo.[Dim Category and Event]
        FROM    [Prod_Ghost].[dwh].[data_category_event];
	
	
		
        ALTER TABLE   dbo.[Dim Category and Event]
        ADD CONSTRAINT cat_event_keypk1 PRIMARY KEY ([cat_event_key]);



        SELECT  [enc_appt_comp_key] ,
                [status_appt] AS [Status of Appointment] ,
                [status_appt_pcp] AS [Appt booked with PCP] ,
                [status_appt_person] AS [Appt booked with a patient] ,
                [status_appt_enc] AS [Appt had encounter] ,
                [status_enc_appt] AS [Enc had appt] ,
                [status_enc_billable] AS [Enc billable status] ,
                [status_enc] AS [Status of Enc] ,
                [status_appt_kept] AS [Appt was Kept] ,
                [status_cancel_reason] AS [Appt cancel reason] ,
                [status_charges] AS [Enc had charges] ,
                [status_pcpcrossbook] AS [Can crossbook with PCP]
        INTO    dbo.[Dim Status Enc and Appt]
        FROM    [Prod_Ghost].[dwh].[data_enc_appt_status];
     
        ALTER TABLE dbo.[Dim Status Enc and Appt]
        ALTER COLUMN enc_appt_comp_key [BIGINT]  NOT NULL;

        ALTER TABLE  dbo.[Dim Status Enc and Appt]
        ADD CONSTRAINT enc_appt_comp_key_pk2 PRIMARY KEY ([enc_appt_comp_key]);






			


        SELECT  per_mon_id ,
                first_mon_date ,
                mh_cur_key ,
				person_key,
                mh_hx_key ,
                pcp_cur_key ,
                pcp_hx_key ,
                expired_date AS [Date of Death] ,
                status_hx_key AS [Patient Status Historical] ,
                status_cur_key AS [Patient Status Current] ,
                CASE WHEN First_enc_age_months <= 1 THEN '1 Month - New Patient'
                     WHEN First_enc_age_months <= 6 THEN '2-6 Months'
                     WHEN First_enc_age_months <= 12 THEN '7-12 Months - 1 Year'
                     WHEN First_enc_age_months <= 24 THEN '13-24 Months- 2 Years'
                     WHEN First_enc_age_months <= 36 THEN '25-36 Months- 3 Years'
                     WHEN First_enc_age_months <= 48 THEN '37-48 Months- 4 Years'
                     WHEN First_enc_age_months <= 60 THEN '49-60 Months- 5 Years'
                     WHEN First_enc_age_months <= 120 THEN '61-120 Months- 6-10 Years'
                     WHEN First_enc_age_months <= 180 THEN '121-180 Months- 11-15 Years'
                     WHEN First_enc_age_months <= 240 THEN '181-240 Months- 15-20 Years'
                     WHEN First_enc_age_months > 240 THEN '>240 Months- 20 Years'
                END AS [Time as Member] ,
                CASE WHEN First_enc_age_months <= 1 THEN 1
                     WHEN First_enc_age_months <= 6 THEN 2
                     WHEN First_enc_age_months <= 12 THEN 3
                     WHEN First_enc_age_months <= 24 THEN 4
                     WHEN First_enc_age_months <= 36 THEN 5
                     WHEN First_enc_age_months <= 48 THEN 6
                     WHEN First_enc_age_months <= 60 THEN 7
                     WHEN First_enc_age_months <= 120 THEN 8
                     WHEN First_enc_age_months <= 180 THEN 9
                     WHEN First_enc_age_months <= 240 THEN 10
                     WHEN First_enc_age_months > 240 THEN 11
                END AS membership_time_sort ,
                CASE WHEN nbr_new_pt = 1 THEN 'New Patient This Month'
                     WHEN nbr_pt_seen_office_ever = 1 THEN 'Established Patient'
                     ELSE 'Not a Patient Yet'
                END AS [Is Patient New] ,
                CASE WHEN nbr_pt_seen_office_ever = 1 THEN 'Established Patient'
                     ELSE 'Has not Established Care'
                END AS [Is Patient Established] ,
                CASE WHEN nbr_pt_deceased = 1 THEN 'Patient Deceased'
                     ELSE 'Patient Living'
                END AS [Is Patient Alive] ,
                CASE WHEN nbr_pt_deceased_this_month = 1 THEN 'Patient Deceased This Month'
                     WHEN nbr_pt_deceased = 1 THEN 'Patient Deceased'
                     ELSE 'Patient Living'
                END AS [Is Patient Deceased this Month] ,
                First_enc_age_months AS [Membership Month] ,
                age_hx AS [Age Hx] ,
                age_cur AS [Age Cur] ,

               
			    -- Age update -- 
                CASE WHEN age_hx <= 18 THEN '0-18 Years'
                     WHEN age_hx <= 29 THEN '19-29 Years'
                     WHEN age_hx <= 39 THEN '30-39 Years'
                     WHEN age_hx <= 49 THEN '40-49 Years'
                     WHEN age_hx <= 59 THEN '50-59 Years'
                     WHEN age_hx <= 64 THEN '60-64 Years'
                     WHEN age_hx <= 74 THEN '65-74 Years'
                     WHEN age_hx <= 79 THEN '75-79 Years'
                     WHEN age_hx <= 89 THEN '80-89 Years'
                     WHEN age_hx <= 99 THEN '90-99 Years'
                     WHEN age_hx >= 100 THEN '>100 Years'
                     ELSE 'Age Unknown'
                END AS [Age Historical] ,
                CASE WHEN age_hx <= 18 THEN 1
                     WHEN age_hx <= 29 THEN 2
                     WHEN age_hx <= 39 THEN 3
                     WHEN age_hx <= 49 THEN 4
                     WHEN age_hx <= 59 THEN 5
                     WHEN age_hx <= 64 THEN 6
                     WHEN age_hx <= 74 THEN 7
                     WHEN age_hx <= 79 THEN 8
                     WHEN age_hx <= 89 THEN 9
                     WHEN age_hx <= 99 THEN 10
                     WHEN age_hx >= 100 THEN 11
                     ELSE 12
                END AS Age_Hx_sort ,
                CASE WHEN age_cur <= 18 THEN '0-18 Years'
                     WHEN age_cur <= 29 THEN '19-29 Years'
                     WHEN age_cur <= 39 THEN '30-39 Years'
                     WHEN age_cur <= 49 THEN '40-49 Years'
                     WHEN age_cur <= 59 THEN '50-59 Years'
                     WHEN age_cur <= 64 THEN '60-64 Years'
                     WHEN age_cur <= 74 THEN '65-74 Years'
                     WHEN age_cur <= 79 THEN '75-79 Years'
                     WHEN age_cur <= 89 THEN '80-89 Years'
                     WHEN age_cur <= 99 THEN '90-99 Years'
                     WHEN age_cur >= 100 THEN '>100 Years'
					 WHEN  (age_cur>=18 AND age_cur<=85) THEN '18-85'
                     ELSE 'Age Unknown'
                END AS [Age Current] ,
                CASE WHEN age_cur <= 18 THEN 1
                     WHEN age_cur <= 29 THEN 2
                     WHEN age_cur <= 39 THEN 3
                     WHEN age_cur <= 49 THEN 4
                     WHEN age_cur <= 59 THEN 5
                     WHEN age_cur <= 64 THEN 6
                     WHEN age_cur <= 74 THEN 7
                     WHEN age_cur <= 79 THEN 8
                     WHEN age_cur <= 89 THEN 9
                     WHEN age_cur <= 99 THEN 10
                     WHEN age_cur >= 100 THEN 11
                     ELSE 12
                END AS age_cur_sort ,
                patient_vintage AS [Patient Vintage Month] ,
                CASE WHEN patient_vintage <= '198912' THEN '<1990'
                     WHEN patient_vintage <= '199412' THEN '1990-1994'
                     WHEN patient_vintage <= '199912' THEN '1995-1999'
                     WHEN patient_vintage <= '200412' THEN '2000-2004'
                     WHEN patient_vintage <= '200912' THEN '2005-2009'
                     WHEN patient_vintage <= '201012' THEN '2010'
                     WHEN patient_vintage <= '201112' THEN '2011'
                     WHEN patient_vintage <= '201212' THEN '2012'
                     WHEN patient_vintage <= '201312' THEN '2013'
                     WHEN patient_vintage <= '201412' THEN '2014'
                     WHEN patient_vintage <= '201512' THEN '2015'
                     WHEN patient_vintage <= '201612' THEN '2016'
                     WHEN patient_vintage <= '201712' THEN '2017'
                     WHEN patient_vintage <= '201812' THEN '2018'
                     WHEN patient_vintage <= '201912' THEN '2019'
                     WHEN patient_vintage <= '202012' THEN '2020'
                     ELSE 'Unknown'
                END AS [Patient Vintage Month Range] ,
                CASE WHEN patient_vintage <= '198912' THEN 1
                     WHEN patient_vintage <= '199412' THEN 2
                     WHEN patient_vintage <= '199912' THEN 3
                     WHEN patient_vintage <= '200412' THEN 4
                     WHEN patient_vintage <= '200912' THEN 5
                     WHEN patient_vintage <= '201012' THEN 6
                     WHEN patient_vintage <= '201112' THEN 7
                     WHEN patient_vintage <= '201212' THEN 8
                     WHEN patient_vintage <= '201312' THEN 9
                     WHEN patient_vintage <= '201412' THEN 10
                     WHEN patient_vintage <= '201512' THEN 11
                     WHEN patient_vintage <= '201612' THEN 12
                     WHEN patient_vintage <= '201712' THEN 13
                     WHEN patient_vintage <= '201812' THEN 14
                     WHEN patient_vintage <= '201912' THEN 15
                     WHEN patient_vintage <= '202012' THEN 16
                     ELSE 17
                END AS [Patient Vintage Month sort] ,
                full_name AS [Full Name] ,
                first_name AS [First Name] ,
                last_name AS [Last Name] ,
                middle_name AS [Middle Name] ,
                address_line_1 AS [Address 1] ,
                address_line_2 AS [Adress 2] ,
                city AS [City] ,
                state AS [State] ,
                zip AS [Zipcode] ,
                home_phone [Home Phone Number] ,
                sex AS [Gender] ,
                ssn AS [SSN] ,
                dob AS [DOB] ,
                alt_phone AS [Alternate Phone Number] ,
                marital_status AS [Marital Status] ,
                race AS [Race] ,
				ethnicity AS [Ethnicity],
                language AS [Language] ,
				homeless_status AS [Homeless Status],
				homeless_count AS [Homeless Indicator],
				disability_1 AS [Disability 1],
				disability_2 AS [Disability 2],
                med_rec_nbr AS [Medical Record Number],
				[Address Full],
				last_appt_date AS [Last Appointment Date],
				last_enc_date AS [Last Encounter Date],
				next_appt_date AS [Next Appointment Date],
				last_appt_provider AS [Last Appointment Provider],
				last_enc_provider AS [Last Encounter Provider],
				next_appt_provider AS [Next Appointment Provider]
        INTO    dbo.[Dim PHI Patient]
        FROM    dwh.data_person_dp_month;	
		
				
        ALTER TABLE    dbo.[Dim PHI Patient]
        ADD CONSTRAINT per_mon_id_pk5 PRIMARY KEY (per_mon_id);
	
	
	
	
	   SELECT  per_mon_id ,
	           person_key,
                first_mon_date ,
                mh_cur_key ,
                pcp_cur_key ,
                status_cur_key AS [Patient Status Cur] ,
                First_enc_age_months AS [Membership Month Cur] ,
                CASE WHEN First_enc_age_months <= 1 THEN '1 Month - New Patient'
                     WHEN First_enc_age_months <= 6 THEN '2-6 Months'
                     WHEN First_enc_age_months <= 12 THEN '7-12 Months - 1 Year'
                     WHEN First_enc_age_months <= 24 THEN '13-24 Months- 2 Years'
                     WHEN First_enc_age_months <= 36 THEN '25-36 Months- 3 Years'
                     WHEN First_enc_age_months <= 48 THEN '37-48 Months- 4 Years'
                     WHEN First_enc_age_months <= 60 THEN '49-60 Months- 5 Years'
                     WHEN First_enc_age_months <= 120 THEN '61-120 Months- 6-10 Years'
                     WHEN First_enc_age_months <= 180 THEN '121-180 Months- 11-15 Years'
                     WHEN First_enc_age_months <= 240 THEN '181-240 Months- 15-20 Years'
                     WHEN First_enc_age_months > 240 THEN '>240 Months- 20 Years'
                END AS [Time as Member Cur] ,
                CASE WHEN First_enc_age_months <= 1 THEN 1
                     WHEN First_enc_age_months <= 6 THEN 2
                     WHEN First_enc_age_months <= 12 THEN 3
                     WHEN First_enc_age_months <= 24 THEN 4
                     WHEN First_enc_age_months <= 36 THEN 5
                     WHEN First_enc_age_months <= 48 THEN 6
                     WHEN First_enc_age_months <= 60 THEN 7
                     WHEN First_enc_age_months <= 120 THEN 8
                     WHEN First_enc_age_months <= 180 THEN 9
                     WHEN First_enc_age_months <= 240 THEN 10
                     WHEN First_enc_age_months > 240 THEN 11
                END AS membership_time_sort ,
                CASE WHEN nbr_new_pt = 1 THEN 'New Patient This Month'
                     WHEN nbr_pt_seen_office_ever = 1 THEN 'Established Patient'
                     ELSE 'Not a Patient Yet'
                END AS [Is Patient New] ,
                CASE WHEN nbr_pt_seen_office_ever = 1 THEN 'Established Patient'
                     ELSE 'Has not Established Care'
                END AS [Is Patient Established] ,
                CASE WHEN nbr_pt_deceased = 1 THEN 'Patient Deceased'
                     ELSE 'Patient Living'
                END AS [Is Patient Alive] ,
                CASE WHEN nbr_pt_deceased_this_month = 1 THEN 'Patient Deceased This Month'
                     WHEN nbr_pt_deceased = 1 THEN 'Patient Deceased'
                     ELSE 'Patient Living'
                END AS [Is Patient Deceased] ,
                patient_vintage AS [Patient Vintage Month] ,
                CASE WHEN patient_vintage <= '198912' THEN '<1990'
                     WHEN patient_vintage <= '199412' THEN '1990-1994'
                     WHEN patient_vintage <= '199912' THEN '1995-1999'
                     WHEN patient_vintage <= '200412' THEN '2000-2004'
                     WHEN patient_vintage <= '200912' THEN '2005-2009'
                     WHEN patient_vintage <= '201012' THEN '2010'
                     WHEN patient_vintage <= '201112' THEN '2011'
                     WHEN patient_vintage <= '201212' THEN '2012'
                     WHEN patient_vintage <= '201312' THEN '2013'
                     WHEN patient_vintage <= '201412' THEN '2014'
                     WHEN patient_vintage <= '201512' THEN '2015'
                     WHEN patient_vintage <= '201612' THEN '2016'
                     WHEN patient_vintage <= '201712' THEN '2017'
                     WHEN patient_vintage <= '201812' THEN '2018'
                     WHEN patient_vintage <= '201912' THEN '2019'
                     WHEN patient_vintage <= '202012' THEN '2020'
                     ELSE 'Unknown'
                END AS [Patient Vintage Month Range] ,
                CASE WHEN patient_vintage <= '198912' THEN 1
                     WHEN patient_vintage <= '199412' THEN 2
                     WHEN patient_vintage <= '199912' THEN 3
                     WHEN patient_vintage <= '200412' THEN 4
                     WHEN patient_vintage <= '200912' THEN 5
                     WHEN patient_vintage <= '201012' THEN 6
                     WHEN patient_vintage <= '201112' THEN 7
                     WHEN patient_vintage <= '201212' THEN 8
                     WHEN patient_vintage <= '201312' THEN 9
                     WHEN patient_vintage <= '201412' THEN 10
                     WHEN patient_vintage <= '201512' THEN 11
                     WHEN patient_vintage <= '201612' THEN 12
                     WHEN patient_vintage <= '201712' THEN 13
                     WHEN patient_vintage <= '201812' THEN 14
                     WHEN patient_vintage <= '201912' THEN 15
                     WHEN patient_vintage <= '202012' THEN 16
                     ELSE 17
                END AS [Patient Vintage Month sort] ,
                


			    CASE WHEN age_cur <= 18 THEN '0-18 Years'
                     WHEN age_cur <= 29 THEN '19-29 Years'
                     WHEN age_cur <= 39 THEN '30-39 Years'
                     WHEN age_cur <= 49 THEN '40-49 Years'
                     WHEN age_cur <= 59 THEN '50-59 Years'
                     WHEN age_cur <= 64 THEN '60-64 Years'
                     WHEN age_cur <= 74 THEN '65-74 Years'
                     WHEN age_cur <= 79 THEN '75-79 Years'
                     WHEN age_cur <= 89 THEN '80-89 Years'
                     WHEN age_cur <= 99 THEN '90-99 Years'
                     WHEN age_cur >= 100 THEN '>100 Years'
                     ELSE 'Age Unknown'
                END AS [Age Current] ,
  
                language AS [Language],

				      full_name AS [Full Name] ,
                first_name AS [First Name] ,
                last_name AS [Last Name] ,
                middle_name AS [Middle Name] ,
                address_line_1 AS [Address 1] ,
                address_line_2 AS [Adress 2] ,
                city AS [City] ,
                state AS [State] ,
                zip AS [Zipcode] ,
                home_phone [Home Phone Number] ,
                sex AS [Gender] ,
                ssn AS [SSN] ,
                dob AS [DOB] ,
                alt_phone AS [Alternate Phone Number] ,
                marital_status AS [Marital Status] ,
                race AS [Race] ,
				ethnicity AS [Ethnicity],
				homeless_status AS [Homeless Status],
				homeless_count AS [Homeless Indicator],
				disability_1 AS [Disability 1],
				disability_2 AS [Disability 2],
                med_rec_nbr AS [Medical Record Number],
				[Address Full],
				
				last_appt_date AS [Last Appointment Date],
				last_enc_date AS [Last Encounter Date],
				next_appt_date AS [Next Appointment Date],
				last_appt_provider AS [Last Appointment Provider],
				last_enc_provider AS [Last Encounter Provider],
				next_appt_provider AS [Next Appointment Provider],
				[chart_create_date] AS [Chart Created],
				  [chart_create_user] AS [Chart Create User],
				  [person_create_date] AS [Person Created],
				  [person_create_user] AS [Person Creat User],
				 --Enrollement start
						[Last Token Generated Time],
						CASE WHEN [enrollment_status]=1 THEN 'Enrollment Pending'
						     WHEN [enrollment_status]=0 THEN '0'
							 WHEN [enrollment_status]=2 THEN '2'
							 WHEN [enrollment_status]=3 THEN 'Finalized/Complete'
							 WHEN [enrollment_status]=4 THEN 'Expired'
							 ELSE 'Empty or Null'
						END AS [Enrollment Status Value],
						[email_address] AS [Email Address],
						[email_modify_datetime] AS [Email Modified Date],
						------------UDS Patient Age----------
                        CASE WHEN age_cur<1 THEN 'Under Age 1' 
						     WHEN age_cur=1 THEN 'Age 1'
							 WHEN age_cur=2 THEN 'Age 2'
							 WHEN age_cur=3 THEN 'Age 3'
							 WHEN age_cur=4 THEN 'Age 4'
							 WHEN age_cur=5 THEN 'Age 5'
							 WHEN age_cur=6 THEN 'Age 6'
							 WHEN age_cur=7 THEN 'Age 7'
							 WHEN age_cur=8 THEN 'Age 8'
							 WHEN age_cur=9 THEN 'Age 9'
							 WHEN age_cur=10 THEN 'Age 10'
							 WHEN age_cur=11 THEN 'Age 11'
							 WHEN age_cur=12 THEN 'Age 12'
							 WHEN age_cur=13 THEN 'Age 13'
							 WHEN age_cur=14 THEN 'Age 14'
							 WHEN age_cur=15 THEN 'Age 15'
							 WHEN age_cur=16 THEN 'Age 16'
							 WHEN age_cur=17 THEN 'Age 17'
							 WHEN age_cur=18 THEN 'Age 18'
							 WHEN age_cur=19 THEN 'Age 19'
							 WHEN age_cur=20 THEN 'Age 20'
							 WHEN age_cur=21 THEN 'Age 21'
							 WHEN age_cur=22 THEN 'Age 22'
							 WHEN age_cur=23 THEN 'Age 23'
							 WHEN age_cur=24 THEN 'Age 24'
							 WHEN age_cur<=29 THEN 'Ages 25-29'
							 WHEN age_cur<=34  THEN 'Ages 30-34'
							 WHEN age_cur<=39 THEN 'Ages 35-39'
							 WHEN age_cur<=44 THEN 'Ages 40-44'
							 WHEN age_cur<=49 THEN 'Ages 45-49'
							 WHEN age_cur<=54 THEN 'Ages 50-54'
							 WHEN age_cur<=59  THEN 'Ages 55-59'
							 WHEN age_cur<=64 THEN 'Ages 60-64'
						  ELSE 'Up to 65'
						END AS [UDS Table 3A Age Groups],
							------------UDS Patient Age----------
                        CASE WHEN sex='F' AND  age_cur<1 THEN 1 
						     WHEN sex='F' AND  age_cur=1 THEN 1
							 WHEN sex='F' AND age_cur=2 THEN 1
							 WHEN sex='F' AND age_cur=3 THEN 1
							 WHEN sex='F' AND age_cur=4 THEN 1
							 WHEN sex='F' AND age_cur=5 THEN 1
							 WHEN sex='F' AND age_cur=6 THEN 1
							 WHEN sex='F' AND age_cur=7 THEN 1
							 WHEN sex='F' AND age_cur=8 THEN 1
							 WHEN sex='F' AND age_cur=9 THEN 1
							 WHEN sex='F' AND age_cur=10 THEN 1
							 WHEN sex='F' AND age_cur=11 THEN 1
							 WHEN sex='F' AND age_cur=12 THEN 1
							 WHEN sex='F' AND age_cur=13 THEN 1
							 WHEN sex='F' AND age_cur=14 THEN 1
							 WHEN sex='F' AND age_cur=15 THEN 1
							 WHEN sex='F' AND age_cur=16 THEN 1
							 WHEN sex='F' AND age_cur=17 THEN 1
							 WHEN sex='F' AND age_cur=18 THEN 1
							 WHEN sex='F' AND age_cur=19 THEN 1
							 WHEN sex='F' AND age_cur=20 THEN 1
							 WHEN sex='F' AND age_cur=21 THEN 1
							 WHEN sex='F' AND age_cur=22 THEN 1
							 WHEN sex='F' AND age_cur=23 THEN 1
							 WHEN sex='F' AND age_cur=24 THEN 1
							 WHEN sex='F' AND age_cur<=29 THEN 1
							 WHEN sex='F' AND age_cur<=34  THEN 1
							 WHEN sex='F' AND age_cur<=39 THEN 1
							 WHEN sex='F' AND age_cur<=44 THEN 1
							 WHEN sex='F' AND age_cur<=49 THEN 1
							 WHEN sex='F' AND age_cur<=54 THEN 1
							 WHEN sex='F' AND age_cur<=59  THEN 1
							 WHEN sex='F' AND age_cur<=64 THEN 1
						ELSE 1
						END AS [UDS Table 3A Nbr of Female Patient],
						 CASE WHEN sex='M' AND  age_cur<1 THEN 1 
						     WHEN sex='M' AND  age_cur=1 THEN 1
							 WHEN sex='M' AND age_cur=2 THEN 1
							 WHEN sex='M' AND age_cur=3 THEN 1
							 WHEN sex='M' AND age_cur=4 THEN 1
							 WHEN sex='M' AND age_cur=5 THEN 1
							 WHEN sex='M' AND age_cur=6 THEN 1
							 WHEN sex='M' AND age_cur=7 THEN 1
							 WHEN sex='M' AND age_cur=8 THEN 1
							 WHEN sex='M' AND age_cur=9 THEN 1
							 WHEN sex='M' AND age_cur=10 THEN 1
							 WHEN sex='M' AND age_cur=11 THEN 1
							 WHEN sex='M' AND age_cur=12 THEN 1
							 WHEN sex='M' AND age_cur=13 THEN 1
							 WHEN sex='M' AND age_cur=14 THEN 1
							 WHEN sex='M' AND age_cur=15 THEN 1
							 WHEN sex='M' AND age_cur=16 THEN 1
							 WHEN sex='M' AND age_cur=17 THEN 1
							 WHEN sex='M' AND age_cur=18 THEN 1
							 WHEN sex='M' AND age_cur=19 THEN 1
							 WHEN sex='M' AND age_cur=20 THEN 1
							 WHEN sex='M' AND age_cur=21 THEN 1
							 WHEN sex='M' AND age_cur=22 THEN 1
							 WHEN sex='M' AND age_cur=23 THEN 1
							 WHEN sex='M' AND age_cur=24 THEN 1
							 WHEN sex='M' AND age_cur<=29 THEN 1
							 WHEN sex='M' AND age_cur<=34  THEN 1
							 WHEN sex='M' AND age_cur<=39 THEN 1
							 WHEN sex='M' AND age_cur<=44 THEN 1
							 WHEN sex='M' AND age_cur<=49 THEN 1
							 WHEN sex='M' AND age_cur<=54 THEN 1
							 WHEN sex='M' AND age_cur<=59  THEN 1
							 WHEN sex='M' AND age_cur<=64 THEN 1
						ELSE 1
						END AS [UDS Table 3A Nbr of Male Patient],

					CASE WHEN age_cur>=18 AND age_cur<=85 THEN 1
					ELSE 0
					END AS [UDS Age 18 to 85],
					CASE WHEN age_cur>=18 AND age_cur<=75 THEN 1 
						ELSE 0
					END AS [UDS Age 18 to 75]
					--,transgender AS [SOGI - GI],
					--sexual_orientation AS [SOGI  - SO]
				 --end
        INTO    dbo.[Dim PHI Patient Quality]
        FROM    dwh.data_person_dp_month dp
		WHERE first_mon_date = CAST(CONVERT(VARCHAR(6),getdate(),112)+'01' AS DATE)

	
         
		 

----
--Build Bridge Tables--


        --SELECT  employee_key ,
        --        employee_month_key
        --INTO    dbo.bridge_emp_to_emp_mon
        --FROM    dwh.data_employee_month;

        --SELECT  employee_key ,
        --        user_key
        --INTO    dbo.bridge_usr_emp
        --FROM    dwh.data_user;
				
/*



        SELECT  [ndc_id] ,
                COALESCE([gcn_seqno], -1) AS gcn_seqno ,
                COALESCE([hicl_seqno], '') AS [hicl_seqno] ,
                COALESCE([medid], -1) AS medid ,
                COALESCE([gcn], -1) AS gcn ,
                COALESCE([brand_name], '') AS brand_name ,
                COALESCE([generic_name], '') AS generic_name ,
                COALESCE([dose], '') AS dose ,
                COALESCE([dose_form_desc], '') AS dose_form_desc ,
                COALESCE([route_desc], '') AS route_desc ,
                COALESCE([med_cat_class_desc], '') AS med_class ,
                COALESCE([dea_id], '') AS med_sched ,
                COALESCE([generic_indicator], '') AS gen_ind ,
                COALESCE([delete_ind], '') AS del_ind
        INTO    dbo.dim_medication
        FROM    [10.183.0.94].[NGProd].[dbo].[fdb_medication];

		
        SELECT  [pharmacy_id] ,
                COALESCE([name], '') AS Name ,
                COALESCE([address_line_1], '') AS Address1 ,
                COALESCE([address_line_2], '') AS address2 ,
                COALESCE([city], '') AS city ,
                COALESCE([state], '') AS state ,
                COALESCE([zip], '') AS zipcode ,
                COALESCE([phone], '') AS phone ,
                COALESCE([fax], '') AS fax ,
                COALESCE([delete_ind], '') AS deleted_ind ,
                COALESCE([store_number], '') AS store_number ,
                COALESCE([active_erx_ind], '') AS accept_erx ,
                COALESCE([mail_order_ind], '') AS accept_rx_mail_order ,
                COALESCE(rx_by_fax_ind, '') AS accept_rx_fax
        INTO    dbo.dim_pharmacy
        FROM    [10.183.0.94].[NGProd].[dbo].[pharmacy_mstr]; 


	*/ 
	 
	 
	--  [operation_type] ,  -- will need to merge this back on to pharmacy as extra attribute
               
	 

	   
/*	   
      
        SELECT  [cpt4_code_id] ,
                ( FLOOR(RANK() OVER ( ORDER BY cpt4_code_id ) / 1000) + 1 ) AS CPT_Group ,
                [description] ,
                [type_of_service]
        INTO    [prod_ghost].dbo.dim_cpt4
        FROM    [10.183.0.94].[NGProd].[dbo].[cpt4_code_mstr]; 

	


SELECT  service_item_id ,
        ( FLOOR(RANK() OVER ( ORDER BY service_item_id ) / 1000) + 1 ) AS Service_Item_Group ,
        eff_date ,
        exp_date ,
        COALESCE(description, '') AS description ,
        cpt4_code_id ,
        current_price,
        COALESCE(revenue_code, '') AS revenue_code ,
        COALESCE(form, '') AS form ,
        COALESCE(rental_duration_per_unit, '') AS rental_duration_per_unit ,
        COALESCE(unassigned_benefit, 0) AS unassigned_benefit ,
        COALESCE(unassigned_benefit_fac, 0) AS unassigned_benefit_fac ,
        rental_ind,
        behavioral_billing_ind,
        self_pay_fqhc_ind,
        sliding_fee_fqhc_ind,
        clinic_rate_exempt_ind,
        sliding_fee_exempt_ind,
        fqhc_enc_ind,
        delete_ind
INTO    dbo.dim_service_item
FROM    [10.183.0.94].NGProd.dbo.service_item_mstr;
*/


    END;
GO
