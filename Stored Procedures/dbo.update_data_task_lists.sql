SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_task_lists]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET transaction isolation level read UNCOMMITTED

    -- Insert statements for procedure here
	   IF OBJECT_ID('[dwh].[data_task_lists]') IS NOT NULL
            DROP TABLE dwh.data_task_lists; 

       ; WITH    TasksRaw1
                  AS ( SELECT   ut1.created_by AS task_from_user_id -- who orginated the task
                                ,
                                ut1.task_owner AS task_to_user_id --who the task was sent to do 
                                ,
                                ut1.pat_acct_id AS person_id --person_id of patient tasked about
                                ,
                                ut1.pat_enc_id --encounter
                                ,
                                ut1.task_id ,
                                CAST(ut1.task_id AS VARCHAR(36)) AS task_id_vchar ,
                                CAST(ut1.pat_acct_id AS VARCHAR(36)) AS pat_acct_id_vchar ,
                                CAST(ut1.pat_enc_id AS VARCHAR(36)) AS pat_enc_id_vchar ,
                                CAST(ut1.task_owner AS VARCHAR(36)) AS task_to_user_id_vchar ,
                                CAST(ut1.created_by AS VARCHAR(36)) AS task_from_user_id_vchar ,
                                CAST(ut1.create_timestamp AS DATE) create_timestamp,-- when created
								--,ut1.modify_timestamp -- likely when it was addressed
                                CAST( DATEDIFF(MINUTE, ut1.create_timestamp, ut1.modify_timestamp) AS DECIMAL)/60 AS [HourstoCompeletion] ,
                                CAST(DATEDIFF(MINUTE, ut1.create_timestamp, ut1.modify_timestamp) AS DECIMAL)/(60*24) AS [DaystoCompeletion] ,
								ut1.modify_timestamp AS [Complete Datetime],
                                ut1.task_completed ,
                                ut1.task_assgn ,
                                ut1.read_flag ,
                                ut1.rejected_ind ,
                                ut1.pat_item_type, --refill or telephone consult
                                ut1.task_desc ,
                                ut1.task_subj, -- what its for? --,per.last_name
                                ( CASE WHEN ISDATE(ut1.create_timestamp) = 1 THEN CAST(ut1.create_timestamp AS DATE)  END ) AS create_date ,
								( CASE WHEN ISDATE(ut1.create_timestamp) = 1 THEN CAST(ut1.create_timestamp AS DATETIME)  END ) AS create_datetime ,

                                pe.location_id
                       FROM     [10.183.0.94].NGProd.dbo.user_todo_list ut1
                                LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter pe (NOLOCK) ON pe.enc_id = ut1.pat_enc_id
                     ) 

            --Build dwh table
        SELECT 
		        --per.person_id ,
				userto.user_key AS task_to_user_key,
				userfrom.user_key AS task_from_user_key,
				CASE WHEN t.person_id IS NOT NULL THEN 
					(SELECT TOP 1 per.[med_rec_nbr] FROM dwh.data_person_dp_month per WHERE per.person_id=t.person_id)
				ELSE ''
				END AS mec_rec_nbr,
			  --  data_appointment.enc_appt_key,
               -- t.location_id ,
               -- per.per_mon_id ,
              --  t.pat_enc_id AS enc_id ,
              --  t.[task_id] AS NG_task_id ,
                t.create_timestamp ,
				t.create_datetime,
				t.[Complete Datetime],
                t.task_from_user_id ,
                t.task_to_user_id,
				t.[HourstoCompeletion],
				t.[DaystoCompeletion],
               -- CAST(CONVERT(CHAR(6), t.create_timestamp, 112) + '01' AS DATE) seq_date ,
                CASE WHEN task_completed = 1 THEN 'Task Completed'
                     ELSE 'Task Not Complete'
                END AS Task_completed ,
                CASE WHEN task_assgn = 'A' THEN 'Task Assigned'
                     ELSE 'Task Not Assigned'
                END AS Task_Assigned ,
                CASE WHEN read_flag = 'Y' THEN 'Task Read'
                     ELSE 'Task Not Read'
                END AS Task_Read ,
                CASE WHEN rejected_ind = 'Y' THEN 'Task Rejected'
                     ELSE 'Task Accepted'
                END AS Task_rejected ,
                task_desc ,
                task_subj ,
                CASE WHEN pat_item_type = 'U'
                          AND task_desc = 'Failed to Match SureScripts Request' THEN 'Failed SureScripts'
                     WHEN pat_item_type = 'R' THEN 'Pharmacy Refill Request'
                     WHEN task_subj = 'Referral Order' THEN 'Referral Order'
                     WHEN task_subj = 'Referral Order:' THEN 'Referral Order'
                     WHEN task_subj LIKE '%Referral%' THEN 'Referral Related'
                     WHEN task_subj LIKE '%Lab%' THEN 'Lab Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%pap%' THEN 'Pap Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%BP%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%Blood Pressure%' THEN 'Blood Pressure Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%consult%' THEN 'Consultations'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%group%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%yoga%' THEN 'Groups'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%appointment%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%appt%' THEN 'Scheduling'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%walkin%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%walk-in%' THEN 'Walk-ins'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%ORDER PRO%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%appt%' THEN 'Order Awaiting Action'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'admitted'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%hospital%' THEN 'Admitted or Hospital Follow up'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'FYI' THEN 'FYI'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'DME' THEN 'DME'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'HomeHealth'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%Home Health%' THEN 'Home Health'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'Controlled'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%pain%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%utox%' THEN 'Pain Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'medicaiton'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%renew%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%refill%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%pharmacist%' THEN 'Medication Issues'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%ERR%' THEN 'Error Erx'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%CHART%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%Medical Records%' THEN 'Medical Record Requests'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%MRI'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%ultrasound%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%CT%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%scans%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%mammogram%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%xray%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%xry%' THEN 'Imaging'					 
					 ELSE 'Other'
                END AS Request_Type
				,CASE WHEN t.task_completed=1 THEN 0 ELSE 1 END AS [Nbr of active Inbox],
				prov.provider_key
      INTO    dwh.data_task_lists
        FROM    TasksRaw1 t
			LEFT OUTER JOIN dwh.data_user_v2 userto WITH (NOLOCK) ON t.task_to_user_id = userto.user_id
			LEFT OUTER JOIN dwh.data_user_v2 userfrom WITH (NOLOCK) ON t.task_from_user_id = userfrom.user_id
			LEFT OUTER JOIN dwh.data_provider prov WITH (NOLOCK) ON t.task_to_user_id = prov.user_id
			--LEFT OUTER JOIN [dwh].[data_appointment] data_appointment WITH (NOLOCK) ON data_appointment.[enc_id] = t.pat_enc_id
                                                        
 
END
GO
