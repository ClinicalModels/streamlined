SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_appointment]
AS
 BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


        IF OBJECT_ID('dbo.data_appointment') IS NOT NULL
            DROP TABLE dbo.data_appointment;


        IF OBJECT_ID('dbo.data_enc_appt_status') IS NOT NULL
            DROP TABLE dbo.data_enc_appt_status;

        IF OBJECT_ID('tempdb..#ar') IS NOT NULL
            DROP TABLE #ar;
        IF OBJECT_ID('tempdb..#appt_enc') IS NOT NULL
            DROP TABLE #appt_enc;

        IF OBJECT_ID('tempdb..#appt_DQ') IS NOT NULL
            DROP TABLE #appt_DQ;

        IF OBJECT_ID('tempdb..#appt_enc2') IS NOT NULL
            DROP TABLE #appt_enc2;

        IF OBJECT_ID('tempdb..#appt_enc3') IS NOT NULL
            DROP TABLE #appt_enc3;

        IF OBJECT_ID('tempdb..#temp_dim') IS NOT NULL
            DROP TABLE #temp_dim;


        IF OBJECT_ID('dbo.data_event') IS NOT NULL
            DROP TABLE dbo.data_event;


        SELECT  IDENTITY( INT, 1, 1 ) AS event_key ,
                e.event_id ,
                e.event AS event_name
        INTO    dbo.data_event
        FROM    [10.183.0.94].NGProd.dbo.[events] e;

/*
-- all appts from start date forward
-- include enc info if available, but get standalone appts as well
-- get all appts regardless of cancel/resched/delete status

-- 2nd query to get standalone encounters as well


link between appts and slots based on
- date
- begintime
- resource
- location

*/

-- calculate start date
        DECLARE @dt_start VARCHAR(8);
        SELECT  @dt_start = '20100301';



-- use last modified person resource to deal with any multi-resource appts
--Issue specific to NextGen
        SELECT   resource_id ,
                appt_id ,
                interval
        INTO    #ar
        FROM    ( SELECT    am.resource_id ,
                            am.appt_id ,
                            r.interval ,
                            rank_order = ROW_NUMBER() OVER ( PARTITION BY am.appt_id ORDER BY am.modify_timestamp DESC )
                  FROM      [10.183.0.94].NGProd.dbo.appointment_members am
                            INNER JOIN [10.183.0.94].NGProd.dbo.resources r ON am.resource_id = r.resource_id
                  WHERE    
				  -- r.resource_type = 'Person' AND
                             am.delete_ind = 'N'
                ) x
        WHERE   rank_order = 1;


-- all appts


        --Create helps avoid issues which can stem from SELECT INTO, such as
        -- implied data types and NULL values not being allowed,
        CREATE TABLE #appt_enc
            (
              [appt_date] [DATE] NULL ,
              [slot_time] [CHAR](4) NULL ,
              [appt_type] [CHAR](1) NULL ,
              [resource_id] [UNIQUEIDENTIFIER] NULL ,
              [appt_loc_id] [UNIQUEIDENTIFIER] NULL ,
              [appt_person_id] [UNIQUEIDENTIFIER] NULL ,
              [enc_person_id] [UNIQUEIDENTIFIER] NULL ,
			  [person_key] [INT] NULL,
              [enc_id] [UNIQUEIDENTIFIER] NULL ,
              [enc_nbr] [NUMERIC](12, 0) NULL ,
              [enc_slot_type] [VARCHAR](40) NULL ,
              [appt_nbr] [NUMERIC](12, 0) NULL ,
              [interval] [INT] NULL ,
              [duration] [INT] NULL ,
              [slot_count] [INT] NULL ,
              [enc_loc_id] [UNIQUEIDENTIFIER] NULL ,
              [enc_date] [DATE] NULL ,
              [enc_rendering_id] [UNIQUEIDENTIFIER] NULL ,
              [appt_status] [CHAR](1) NULL ,
              [appt_kept_ind] [CHAR](1) NULL ,
              [cancel_ind] [CHAR](1) NULL ,
              [cancel_reason] [UNIQUEIDENTIFIER] NULL ,
              [delete_ind] [CHAR](1) NULL ,
              [resched_ind] [CHAR](1) NULL ,
              [noshow_ind] [CHAR] (1) NULL,
              [checkin_datetime] [DATETIME] NULL ,
              [enc_status] [CHAR](1) NULL ,
              [user_enc_created] [INT] NULL ,
              [pcp_id] [UNIQUEIDENTIFIER] NULL ,
              [billable_ind] [CHAR](1) NULL ,
              [event_id] [UNIQUEIDENTIFIER] NULL ,
              [event_name] [VARCHAR](30) NULL ,
              [appt_create_time] [DATETIME] NULL ,
              [appt_modify_time] [DATETIME] NULL ,
              [user_appt_created] [INT] NULL,
              [pay1_name][VARCHAR](110) NULL,
              [pay2_name] [VARCHAR](110) NULL,
              [pay3_name] [VARCHAR](110) NULL,
              [pay1_finclass] [VARCHAR](110) NULL,
              [pay2_finclass] [VARCHAR](110) NULL,
              [pay3_finclass] [VARCHAR](110) NULL,
              [ng_data] [INT] NULL --Necessary flag to determine whether pulling from NG or ECW tables
            );




        --DQ Issue -- Apparently some appointments are getting linked to the same same enc_id. to get the number of billable appointments correct
                   -- So, I will null out the enc_id for the remailing appointments (so unique by enc Id on the field)-- the effect may displace
                   -- Its not clear to me how to know which of the billable encounters is properly mapped with the appointment, but
                   -- I will keep the encounter date that matched the appointment date and null the remaining ID in the appointment table


        SELECT    DQ_enc_id = ROW_NUMBER() OVER ( PARTITION BY enc_id ORDER BY a.modify_timestamp DESC ) ,
                a.*
        INTO    #appt_DQ
        FROM    [10.183.0.94].NGProd.dbo.appointments a;


        INSERT  INTO #appt_enc
                ( appt_date ,
                  slot_time ,
                  appt_type ,
                  resource_id ,
                  appt_loc_id ,
                  appt_person_id ,
                  enc_person_id ,
				  person_key,
                  enc_id ,
                  enc_nbr ,
                  enc_slot_type ,
                  appt_nbr ,
                  interval ,
                  duration ,
                  slot_count ,
                  enc_loc_id ,
                  enc_date ,
                  enc_rendering_id ,
                  appt_status ,
                  appt_kept_ind ,
                  cancel_ind ,
                  cancel_reason ,
                  delete_ind ,
                  resched_ind ,
                  checkin_datetime ,
                  enc_status ,
                  user_enc_created ,
                  pcp_id ,
                  billable_ind ,
                  event_id ,
                  event_name ,
                  appt_create_time ,
                  appt_modify_time ,
                  user_appt_created,
                  d.ng_data
                )
                SELECT   
                        CAST(a.appt_date AS DATE) AS appt_date ,
                        a.begintime AS slot_time ,
                        a.appt_type ,
                        ar.resource_id ,
                        a.location_id AS appt_loc_id ,
                        a.person_id AS appt_person_id ,
                        enc.person_id AS enc_person_id ,
						(SELECT TOP 1 nd.person_key
							FROM dbo.data_person_nd_month nd
							WHERE nd.person_id=per.person_Id)
						AS person_key,
                        CASE WHEN a.DQ_enc_id = 1
                                  AND a.enc_id IS NOT NULL THEN enc.enc_id
                             ELSE NULL
                        END AS enc_id ,
                        CASE WHEN a.DQ_enc_id = 1
                                  AND a.enc_id IS NOT NULL THEN enc.enc_nbr
                             ELSE NULL
                        END AS enc_nbr ,
                        enc_slot_type = CASE WHEN a.enc_id IS NULL THEN 'Appt without encounter'
                                             ELSE 'Appt with Encounter'
                                        END ,
                        a.appt_nbr ,
                        ar.interval ,
                        a.duration AS duration ,
                        slot_count = FLOOR(a.duration / ar.interval) , --Gives number of individual slots
                        enc_loc_id = enc.location_id ,
                        enc_date = CAST(enc.billable_timestamp AS DATE) ,
                        enc_rendering_id = a.rendering_provider_id ,
                        a.appt_status ,
                        a.appt_kept_ind ,
                        a.cancel_ind ,
                        a.cancel_reason ,
                        a.delete_ind ,
                        a.resched_ind ,
                        enc.checkin_datetime ,
                        enc.enc_status ,
                        enc.created_by AS user_enc_created ,
                        per.primarycare_prov_id AS pcp_id ,
                        enc.billable_ind ,
                        a.event_id ,
                        e.event AS event_name ,
                        a.create_timestamp AS appt_create_time ,
                        a.modify_timestamp AS appt_modify_time ,
                        a.created_by AS user_appt_created,
                        1 AS ng_data --mark all records being entered as NextGen
                FROM    #appt_DQ a
                        INNER JOIN #ar ar ON a.appt_id = ar.appt_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter enc ON a.enc_id = enc.enc_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON per.person_id = a.person_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.events e ON e.event_id = a.event_id
                WHERE   a.appt_date >= @dt_start;


  --This insert adds past encounters not linked to an appointment
        INSERT  INTO #appt_enc
                ( appt_date ,
                  slot_time ,
                  appt_type ,
                  resource_id ,
                  appt_loc_id ,
                  appt_person_id ,
                  enc_person_id ,
				  person_key,
                  enc_id ,
                  enc_nbr ,
                  enc_slot_type ,
                  appt_nbr ,
                  interval ,
                  duration ,
                  slot_count ,
                  enc_loc_id ,
                  enc_date ,
                  enc_rendering_id ,
                  appt_status ,
                  appt_kept_ind ,
                  cancel_ind ,
                  cancel_reason ,
                  delete_ind ,
                  resched_ind ,
                  checkin_datetime ,
                  enc_status ,
                  user_enc_created ,
                  pcp_id ,
                  billable_ind ,
                  event_id ,
                  event_name ,
                  appt_create_time ,
                  appt_modify_time ,
                  user_appt_created ,
                  d.ng_data
                )

               --**DQ** This section of the procedure began running endlessly or taking 8 hours
				--There is a bug in SQL server 2012 for linked servers that requires CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) as workaround for NULL as uniqueindetifier
               --See this post http://sqlwithmanoj.com/2015/03/27/sqlncli11-for-linked-server-xyz-returned-message-requested-conversion-is-not-supported-sql-server-2012-upgrade-behavior-changes/
                SELECT  
                        CAST(NULL AS DATE) AS appt_date ,
                        CAST(NULL AS CHAR(4)) AS slot_time ,
                        CAST(NULL AS CHAR(1)) AS appt_type ,
                        CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS resource_id ,
                        CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS appt_loc_id ,
                        CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS appt_person_id ,
                        CAST(enc.person_id AS UNIQUEIDENTIFIER) AS enc_person_id ,
						(SELECT TOP 1 nd.person_key
							FROM dbo.data_person_nd_month nd
							WHERE nd.person_id=per.person_Id)
						AS person_key,
                        CAST(enc.enc_id AS UNIQUEIDENTIFIER) AS enc_id ,
                        CAST(enc.enc_nbr AS NUMERIC(12, 0)) AS enc_nbr ,
                        CAST('Encounter no appt' AS VARCHAR(20)) AS enc_slot_type ,
                        CAST(NULL AS NUMERIC(12, 0)) AS appt_nbr ,
                        CAST(NULL AS INT) AS interval ,
                        CAST(NULL AS INT) AS duration ,
                        CAST(NULL AS INT) AS slot_count ,
                        CAST(enc.location_id AS UNIQUEIDENTIFIER) AS enc_loc_id ,
                        CAST(enc.billable_timestamp AS DATE) AS enc_date ,
                        CAST(enc.rendering_provider_id AS UNIQUEIDENTIFIER) AS enc_rendering_id ,
                        CAST (NULL AS CHAR(1)) AS appt_status ,
                        CAST (NULL AS CHAR(1)) AS appt_kept_ind ,
                        CAST (NULL AS CHAR(1)) AS cancel_ind ,
                        CAST (NULL AS CHAR(1)) AS delete_ind ,
                        CAST(a.cancel_reason AS UNIQUEIDENTIFIER) AS cancel_reason ,
                        CAST (NULL AS CHAR(1)) AS resched_ind ,
                        CAST(enc.checkin_datetime AS DATETIME) AS checkin_datetime ,
                        CAST(enc.enc_status AS CHAR(1)) AS enc_status ,
                        CAST(enc.created_by AS INT) AS user_enc_created ,
                        CAST(per.primarycare_prov_id AS UNIQUEIDENTIFIER) AS pcp_id ,
                        CAST(enc.billable_ind AS CHAR(1)) AS billable_ind ,
                        CAST(a.event_id AS UNIQUEIDENTIFIER) AS event_id ,
                        CAST(NULL AS VARCHAR(30)) AS event_name ,
                        CAST(NULL AS DATETIME) AS appt_create_time ,
                        CAST(NULL AS DATETIME) AS appt_modify_time ,
                        CAST(NULL AS INT) AS user_appt_created,
                        1 AS ng_data
                FROM    [10.183.0.94].NGProd.dbo.patient_encounter enc
                        LEFT JOIN [10.183.0.94].NGProd.dbo.appointments a ON enc.enc_id = a.enc_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON per.person_id = enc.person_id
                WHERE   a.enc_id IS NULL
                        AND CONVERT(CHAR(8), enc.billable_timestamp, 112) >= @dt_start;





       --Builds the statuses used for the composite key creation later
        SELECT  d.* ,
                CASE WHEN ( d.appt_date IS NOT NULL
                            AND d.slot_time IS NOT NULL
                            AND d.appt_modify_time IS NOT NULL
                            AND ISNULL(d.cancel_ind, 'N') = 'Y'
                            AND ISNULL(d.resched_ind, 'N') = 'N'
                            AND DATEDIFF(MINUTE, d.appt_modify_time,
                                         CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112), ' ',
                                                     SUBSTRING(d.slot_time, 1, 2), ':', SUBSTRING(d.slot_time, 3, 2),
                                                     ':00') AS DATETIME)) <= 4 * 60
                          ) THEN 'Cancelled < 4 Hrs before appt'
                     WHEN ( d.appt_date IS NOT NULL
                            AND d.slot_time IS NOT NULL
                            AND d.appt_modify_time IS NOT NULL
                            AND ISNULL(d.cancel_ind, 'N') = 'Y'
                            AND ISNULL(d.resched_ind, 'N') = 'N'
                            AND DATEDIFF(MINUTE, d.appt_modify_time,
                                         CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112), ' ',
                                                     SUBSTRING(d.slot_time, 1, 2), ':', SUBSTRING(d.slot_time, 3, 2),
                                                     ':00') AS DATETIME)) <= 48 * 60
                          ) THEN 'Cancelled 4-48 Hrs before appt'
                     WHEN ( d.appt_date IS NOT NULL
                            AND d.slot_time IS NOT NULL
                            AND d.appt_modify_time IS NOT NULL
                            AND ISNULL(d.cancel_ind, 'N') = 'Y'
                            AND ISNULL(d.resched_ind, 'N') = 'N'
                            AND DATEDIFF(MINUTE, d.appt_modify_time,
                                         CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112), ' ',
                                                     SUBSTRING(d.slot_time, 1, 2), ':', SUBSTRING(d.slot_time, 3, 2),
                                                     ':00') AS DATETIME)) > 48 * 60
                          ) THEN 'Cancelled  > 48 Hrs before appt'
                     WHEN ISNULL(d.delete_ind, 'N') = 'Y'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 'Deleted'
                     WHEN ISNULL(d.resched_ind, 'N') = 'Y' THEN 'Rescheduled'
                     WHEN d.appt_date >= CONVERT(CHAR(8), GETDATE(), 112)
                          AND d.appt_person_id IS NOT NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 'Future'
                     WHEN d.appt_date < CONVERT(CHAR(8), GETDATE(), 112)
                          AND d.appt_person_id IS NOT NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 'No show'
                     WHEN d.appt_date > CONVERT(CHAR(8), GETDATE(), 112)
                          AND d.appt_person_id IS  NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 'Future blocks'
                     WHEN d.appt_date <= CONVERT(CHAR(8), GETDATE(), 112)
                          AND d.appt_person_id IS  NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 'Historic blocks'
                     WHEN ISNULL(d.appt_kept_ind, 'N') = 'Y'
                          AND d.appt_nbr IS NOT NULL THEN 'Kept'
                     WHEN d.appt_nbr IS  NULL THEN 'No appointment'
                     ELSE 'Unknown'
                END AS status_appt ,
                CASE WHEN ( d.appt_nbr IS NOT NULL
                            AND d.appt_person_id IS NULL
                          ) THEN 'Appointment without patient'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.appt_person_id IS NOT NULL
                          ) THEN 'Appointment with a patient'
                     ELSE 'No appointment'
                END AS status_appt_person ,
                CASE WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id = d.enc_rendering_id
                          ) THEN 'Appointment booked with PCP'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id != d.enc_rendering_id
                          ) THEN 'Appointment not booked with PCP'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NULL
                            AND d.enc_rendering_id IS NOT NULL
                          ) THEN 'Patient has no PCP assigned'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NULL
                          ) THEN 'No rendering provider for appt'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS  NULL
                            AND d.enc_rendering_id IS NULL
                          ) THEN 'No rendering provider and No PCP assigned for appt'
                     WHEN ( d.appt_nbr IS NULL ) THEN 'No appointment'
                     ELSE 'Unknown'
                END AS status_appt_pcp ,
                CASE WHEN ( d.enc_id IS NOT NULL
                            AND d.appt_nbr IS NOT NULL
                          ) THEN 'Appointment with encounter'
                     WHEN ( d.enc_id IS NOT NULL
                            AND d.appt_nbr IS  NULL
                          ) THEN 'Encounter without appointment'
                     WHEN ( d.enc_id IS NULL
                            AND d.appt_nbr IS NOT NULL
                          ) THEN 'Appointment without encounter'
                     WHEN ( d.enc_id IS NULL
                            AND d.appt_nbr IS NULL
                          ) THEN 'No appointment and no encounter'
                     ELSE 'Unknown'
                END AS status_appt_enc ,
                CASE WHEN ( d.enc_id IS NOT NULL
                            AND d.appt_nbr IS NOT NULL
                          ) THEN 'Encounter with appointment'
                     WHEN ( d.enc_id IS NOT NULL
                            AND d.appt_nbr IS  NULL
                          ) THEN 'Encounter without appointment'
                     WHEN ( d.enc_id IS NULL
                            AND d.appt_nbr IS NOT NULL
                          ) THEN 'Appointment without encounter'
                     WHEN ( d.enc_id IS NULL
                            AND d.appt_nbr IS NULL
                          ) THEN 'No appointment and no encounter'
                     ELSE 'Unknown'
                END AS status_enc_appt ,
                CASE WHEN ISNULL(d.billable_ind, 'N') = 'Y'
                          AND d.enc_id IS NOT NULL THEN 'Billable visit'
                     WHEN ISNULL(d.billable_ind, 'N') != 'Y'
                          AND d.enc_id IS NOT NULL THEN 'Non-billable visit'
                     ELSE 'No encounter'
                END AS status_enc_billable ,
                CASE WHEN d.enc_status = 'U' THEN 'Unbilled'
                     WHEN d.enc_status = 'R' THEN 'Rebilled'
                     WHEN d.enc_status = 'H' THEN 'Historical'
                     WHEN d.enc_status = 'B' THEN 'Billed'
                     WHEN d.enc_status = 'D' THEN 'Bad Debt'
                     WHEN d.enc_id IS NULL THEN 'No encounter'
                     ELSE 'Unknown'
                END AS status_enc ,
                CASE WHEN ISNULL(d.appt_kept_ind, 'N') = 'Y'
                          AND d.appt_nbr IS NOT NULL THEN 'Kept'
                     WHEN ISNULL(d.appt_kept_ind, 'N') != 'Y'
                          AND d.appt_nbr IS NOT NULL THEN 'Not kept'
                     ELSE 'No appointment'
                END AS status_appt_kept ,
                CASE WHEN ISNULL(m.mstr_list_item_desc, '') != '' THEN ( m.mstr_list_item_desc )
                     ELSE 'Unknown'
                END AS status_cancel_reason ,
                --CASE WHEN chg.source_id IS NOT NULL THEN 'Has Charges'
                --     ELSE 'No Charges'
                --END AS status_charges ,
				'Unknown    ' AS status_charges,

                --Crossbooking measure
                --This is an appointment that is booked with one provider when there are
                --open slots available with PCP at the same time
                --That means checking if schedule slots has an [nbr_slots_open_final] =1 for the date and pcp of a patient being
                --seen by someone other than their provider
                CASE WHEN

                         --Appointment not booked with PCP
                          ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id != d.enc_rendering_id
                          )
                          AND
                           --Appointment is available with PCP
                          ( SELECT TOP 1
                                    [nbr_slots_open_final]
                            FROM    dbo.data_schedule_slots ss
                            WHERE   d.pcp_id = ss.provider_id
                                    AND d.appt_date = ss.appt_date
                                    AND ss.[nbr_slots_open_final] = 1
                          ) = 1 THEN 'PCP available for appt'
                     ELSE 'PCP not available for appt'
                END AS status_pcpcrossbook,

				/* **DQ**Finance filters out certain events when counting billable visits. This marker is used
				to determine a patients first billable visit annually in the final select procedure*/
				CASE WHEN ISNULL(d.billable_ind, 'N') = 'Y'
					AND d.enc_rendering_id NOT IN ('8EA64044-F175-4D14-A779-EB590B7215DF',
												'DB3C72C9-2C77-4262-AC15-5AD76908926F',
												'495A2560-F950-4EF1-848C-AF0A4F664FB6',
												'7308B84D-C03C-47A7-B9ED-A0082C058DA2',
												'5A92DC65-D6B1-48D8-BB56-4D7854F697C0') THEN 1
						  --filtering out providers who aren't counted as billable visits
						  --AND (SELECT TOP 1
								--		prov.FullName
								--  FROM  dbo.data_provider prov
								--  WHERE prov.provider_id = d.enc_rendering_id
								--) NOT IN ('%services%',
								--		   '%UDS%',
								--		   '%Mental%',
								--		   '%Enabling%')	     THEN 1
                     ELSE 0
				END
					AS billable_event

        INTO    #appt_enc2
        FROM    #appt_enc d
                LEFT JOIN [10.183.0.94].NGProd.dbo.[mstr_lists] m ON d.cancel_reason = m.mstr_list_item_id
                LEFT JOIN ( SELECT DISTINCT
                                    source_id
                            FROM    [10.183.0.94].NGProd.dbo.charges
                          ) chg ON chg.source_id = d.enc_id;




		--/* **DQ** For some reason when the above query evaluates the chg table it was throwing an 
		--error on converting varchare to date/time. Haven't figured out why, but the update statement fixes the issue*/
		--UPDATE d 
		--	SET d.status_charges = CASE WHEN chg.source_id IS NOT NULL THEN 'Has Charges'
		--							ELSE 'No Charges'
		--							END
  --     FROM #appt_enc2 d
		--LEFT JOIN ( SELECT DISTINCT
  --                                  source_id
  --                          FROM    [10.183.0.94].NGProd.dbo.charges
  --                        ) chg ON chg.source_id = d.enc_id	
	 --  WHERE ng_data = 1

 


        /*
        The Cross Join builds a composite key table consisting of every possible combination of the
        statuses we are tracking.
        */   
        SELECT  ROW_NUMBER() OVER ( ORDER BY x1.status_appt , x2.status_appt_pcp , x3.status_appt_person ,
                x4.status_appt_enc , x5.status_enc_appt , x6.status_enc_billable , x7.status_enc,
                x8.status_appt_kept, x9.status_cancel_reason, x10.status_charges, x11.status_pcpcrossbook )
                    AS enc_appt_comp_key ,
                x1.status_appt ,
                x2.status_appt_pcp ,
                x3.status_appt_person ,
                x4.status_appt_enc ,
                x5.status_enc_appt ,
                x6.status_enc_billable ,
                x7.status_enc ,
                x8.status_appt_kept ,
                x9.status_cancel_reason ,
                x10.status_charges ,
                x11.status_pcpcrossbook
        INTO    dbo.data_enc_appt_status
        FROM    ( SELECT DISTINCT
                            status_appt
                  FROM      #appt_enc2
                ) x1
                CROSS JOIN ( SELECT DISTINCT
                                    status_appt_pcp
                             FROM   #appt_enc2
                           ) x2
                CROSS JOIN ( SELECT DISTINCT
                                    status_appt_person
                             FROM   #appt_enc2
                           ) x3
                CROSS JOIN ( SELECT DISTINCT
                                    status_appt_enc
                             FROM   #appt_enc2
                           ) x4
                CROSS JOIN ( SELECT DISTINCT
                                    status_enc_appt
                             FROM   #appt_enc2
                           ) x5
                CROSS JOIN ( SELECT DISTINCT
                                    status_enc_billable
                             FROM   #appt_enc2
                           ) x6
                CROSS JOIN ( SELECT DISTINCT
                                    status_enc
                             FROM   #appt_enc2
                           ) x7
                CROSS JOIN ( SELECT DISTINCT
                                    status_appt_kept
                             FROM   #appt_enc2
                           ) x8
                CROSS JOIN ( SELECT DISTINCT
                                    status_cancel_reason
                             FROM   #appt_enc2
                           ) x9
                CROSS JOIN ( SELECT DISTINCT
                                    status_charges
                             FROM   #appt_enc2
                           ) x10
                CROSS JOIN ( SELECT DISTINCT
                                    status_pcpcrossbook
                             FROM   #appt_enc2
                           ) x11;



        /*  **DQ**
        --Each appointment is matched with the composite key corresponding to the row with
        --their same combination of statuses, so many rows can share a key if their statuses are
        --match in each column
        */
        SELECT  d.* ,
				ROW_NUMBER() OVER(PARTITION BY d.person_key, YEAR(d.enc_date),billable_event ORDER BY d.enc_date ASC) AS unduplicated_annually,
                e.enc_appt_comp_key
        INTO    #appt_enc3
        FROM    #appt_enc2 d
                LEFT JOIN dbo.data_enc_appt_status e ON e.status_appt = d.status_appt
                                                        AND e.status_appt_pcp = d.status_appt_pcp
                                                        AND e.status_appt_person = d.status_appt_person
                                                        AND e.status_appt_enc = d.status_appt_enc
                                                        AND e.status_enc_appt = d.status_enc_appt
                                                        AND e.status_enc_billable = d.status_enc_billable
                                                        AND e.status_enc = d.status_enc
                                                        AND e.status_appt_kept = d.status_appt_kept
                                                        AND e.status_cancel_reason = d.status_cancel_reason
                                                        AND e.status_charges = d.status_charges
                                                        AND e.status_pcpcrossbook = d.status_pcpcrossbook;






/*
Final SELECT statements creates the dwh table. Certain statements use a CASE statement which evaluates the d.ng_data
flag, and pull from a different location depending on if flag is NextGen (1) 
*/

        SELECT 
                IDENTITY( INT, 1, 1 ) AS enc_appt_key ,
                ( SELECT TOP 1
                            user_key
                  FROM      dbo.data_user du
                  WHERE     du.resource_id = d.resource_id
                            AND d.resource_id IS NOT NULL
                ) AS user_resource_key ,
                d.resource_id ,
				--**DQ** Specifically Dental does note have appt location id, only enc_location id
				--But our joins are on this location key generally
               ( SELECT TOP 1
									location_key
						  FROM      dbo.data_location dl
						  WHERE     dl.location_id = d.appt_loc_id
									AND dl.location_id_unique_flag = 1
									AND d.appt_loc_id IS NOT NULL
						)
                     AS appt_loc_key ,
                d.appt_loc_id ,
                d.enc_id ,
                ( SELECT TOP 1
                            location_key
                  FROM      dbo.data_location dl
                  WHERE     dl.location_id = d.enc_loc_id
                            AND dl.location_id_unique_flag = 1
                            AND d.enc_loc_id IS NOT NULL
                )
                   
                    AS enc_loc_key ,
                d.enc_loc_id ,
                ( SELECT TOP 1
                            user_key
                  FROM      dbo.data_user du
                  WHERE     du.provider_id = d.enc_rendering_id
                            AND d.enc_rendering_id IS NOT NULL
                ) AS enc_rendering_key ,
                        ( SELECT TOP 1
                                    provider_key
                          FROM      dbo.data_provider prov
                          WHERE     prov.provider_id = d.enc_rendering_id
                                    AND d.enc_rendering_id IS NOT NULL
                        )
                    AS provider_key ,

                d.enc_rendering_id , 
						( SELECT TOP 1
                                    per_mon_id
                          FROM      dbo.data_person_nd_month pm
                          WHERE     pm.first_mon_date = CAST(CONVERT(VARCHAR(6), COALESCE(d.enc_date, d.appt_date), 112) + '01' AS DATE)
                                    AND pm.person_id = COALESCE(d.enc_person_id, d.appt_person_id)
                                    AND COALESCE(d.enc_person_id, d.appt_person_id) IS NOT NULL
                        )
                    AS per_mon_id ,
						( SELECT TOP 1
                                    person_key
                          FROM      dbo.data_person_nd_month pm
                          WHERE     pm.first_mon_date = CAST(CONVERT(VARCHAR(6), COALESCE(d.enc_date, d.appt_date), 112) + '01' AS DATE)
                                    AND pm.person_id = COALESCE(d.enc_person_id, d.appt_person_id)
                                    AND COALESCE(d.enc_person_id, d.appt_person_id) IS NOT NULL
                        )
						AS person_key ,
                        COALESCE(( SELECT TOP 1
                                            location_key
                                   FROM     dbo.data_location dl
                                   WHERE    dl.location_id = d.enc_loc_id
                                            AND dl.location_id_unique_flag = 1
                                            AND d.enc_loc_id IS NOT NULL
                                 ), 
								 ( SELECT TOP 1
                                                location_key
                                      FROM      dbo.data_location dl
                                      WHERE     dl.location_id = d.appt_loc_id
                                                AND dl.location_id_unique_flag = 1
                                                AND d.appt_loc_id IS NOT NULL
                                    ))
									 AS location_key ,
                d.enc_appt_comp_key ,
                ( SELECT TOP 1
                            cat_event_key
                  FROM      dbo.data_category_event ed
                  WHERE     ed.event_id = d.event_id
                ) AS event_key ,
                d.event_name ,
                COALESCE(enc_date, appt_date) AS enc_app_date ,
                d.pcp_id ,
                d.appt_person_id ,
                d.enc_person_id ,
                d.event_id ,
                d.enc_date ,
                d.checkin_datetime AS enc_checkin_datetime ,
                CAST(d.appt_nbr AS NUMERIC) AS appt_nbr,
                CAST(d.enc_nbr AS NUMERIC) AS enc_nbr,
                d.appt_type ,
                d.appt_status ,
                d.enc_slot_type ,
                d.appt_date ,
                MAX(d.appt_date) OVER (PARTITION BY d.appt_person_id ) AS appt_date_last,
                MAX(d.enc_date) OVER (PARTITION BY d.enc_person_id ) AS enc_date_last,
                d.slot_time AS appt_time ,
                d.duration AS appt_duration ,
                d.interval AS appt_interval ,
                d.appt_kept_ind ,
                d.cancel_ind AS appt_cancel_ind ,
                d.resched_ind AS appt_resched_ind ,
                d.delete_ind AS appt_delete_ind ,
                d.enc_status ,
                ds.user_checkout ,
                ds.user_readyforprovider ,
                ds.user_charted ,
                ( SELECT TOP 1
                            user_key
                  FROM      dbo.data_user du
                  WHERE     du.user_id = d.user_appt_created
                            AND d.user_appt_created IS NOT NULL
                )
                    AS user_appt_created ,
                ( SELECT TOP 1
                            user_key
                  FROM      dbo.data_user du
                  WHERE     du.user_id = d.user_enc_created
                            AND d.user_enc_created IS NOT NULL
                )
                    AS user_enc_created ,

                COALESCE(d.enc_person_id, d.appt_person_id) AS person_id ,

                CAST(CONVERT(VARCHAR(6), COALESCE(d.enc_date, d.appt_date), 112) + '01' AS DATE) AS first_mon_date ,

                CASE
                    WHEN ( d.appt_date IS NOT NULL
                            AND d.slot_time IS NOT NULL
                            --AND d.checkin_datetime IS NOT NULL
                          )
                     THEN CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112), ' ', SUBSTRING(d.slot_time, 1, 2), ':',
                                      SUBSTRING(d.slot_time, 3, 2), ':00') AS DATETIME)
                END
                    AS appt_datetime ,



                --Here we are counting how many of all appoints regardless of their status as cancelled our rescheduled were booked with the PCP
                CASE
                    WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id = d.enc_rendering_id
                          ) THEN 'Appointment booked with PCP'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id != d.enc_rendering_id
                          ) THEN 'Appointment not booked with PCP'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NULL
                            AND d.enc_rendering_id IS NOT NULL
                          ) THEN 'Patient has no PCP assigned'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NULL
                          ) THEN 'No rendering provider for appt'
                     WHEN ( d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS  NULL
                            AND d.enc_rendering_id IS NULL
                          ) THEN 'No rendering provider and no PCP assigned for appt'
                     WHEN ( d.appt_nbr IS NULL ) THEN 'No appointment'
                     ELSE 'Unknown'
                END
                    AS appt_w_pcp_status_txt ,
                CASE
                    WHEN d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id = d.enc_rendering_id THEN 1
                     ELSE 0
                END
                    AS nbr_pcp_appts ,
                CASE
                    WHEN d.appt_nbr IS NOT NULL
                            AND d.pcp_id IS NOT NULL
                            AND d.enc_rendering_id IS NOT NULL
                            AND d.pcp_id = d.enc_rendering_id THEN 0
                     ELSE 1
                END
                    AS nbr_nonpcp_appt ,
                CASE
                    WHEN ( d.appt_nbr IS NOT NULL ) THEN 1
                     ELSE 0
                END
                    AS nbr_appts ,



                --This metric is appointments that aren't linked to a person -- not sure why this would be the case
                CASE
                    WHEN ( d.appt_nbr IS NOT NULL
                            AND d.appt_person_id IS NULL
                          ) THEN 1
                     ELSE 0
                END AS nbr_appt_notlinked_toperson ,



                    --Could include number of non-billable encounters completed by PCP

                --This is the number of appointments that have a linked encounter that were kept (or checked in)
                CASE
                    WHEN ISNULL(d.appt_kept_ind, 'N') = 'Y'
                          AND ISNULL(d.resched_ind, 'N') != 'Y' -- This is checking for reschedules The D are reschedules, Could have also checked resched_ind != 'Y'
                          AND d.enc_id IS NOT NULL THEN 1
                    ELSE 0
                END
                    AS nbr_appt_kept_and_linked_enc ,


                --I think of this as a data quality audit
                CASE
                    WHEN ISNULL(d.appt_kept_ind, 'N') = 'Y'
                          AND ISNULL(resched_ind, 'N') != 'Y'
                          AND d.enc_id IS NULL THEN 1
                     ELSE 0
                END
                    AS nbr_appt_kept_not_linked_enc ,

                        --These are ne counts of future appointments
                CASE
                    WHEN d.appt_date >= CONVERT(CHAR(8), GETDATE(), 112)
                         -- AND d.enc_nbr IS NOT NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 1
                     ELSE 0
                END
                    AS nbr_appt_future ,
                CASE
                    WHEN d.appt_date < CONVERT(CHAR(8), GETDATE(), 112)
                         -- AND d.enc_nbr IS NOT NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N'
                          AND d.ng_data = 1 THEN 1
                     ELSE 0
                END
                    AS nbr_appt_no_show ,
                CASE
                    WHEN d.appt_date >= CONVERT(CHAR(8), GETDATE(), 112)
                          AND d.appt_person_id IS NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 1
                     ELSE 0
                END
                    AS nbr_appt_future_no_patient ,
                CASE
                    WHEN d.appt_date < CONVERT(CHAR(8), GETDATE(), 112)
                          AND d.appt_person_id IS NULL
                          AND ISNULL(d.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(d.cancel_ind, 'N') = 'N'
                          AND ISNULL(d.delete_ind, 'N') = 'N'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 1
                    ELSE 0
                END
                    AS nbr_appt_no_show_no_patient ,
                CASE
                    WHEN ISNULL(d.cancel_ind, 'N') = 'Y'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 1
                     ELSE 0
                END
                    AS nbr_appt_cancelled , --
                CASE
                    WHEN ISNULL(d.delete_ind, 'N') = 'Y'
                          AND ISNULL(d.resched_ind, 'N') = 'N' THEN 1
                     ELSE 0
                END
                    AS nbr_appt_deleted , --
                CASE
                    WHEN ISNULL(d.resched_ind, 'N') = 'Y' THEN 1
                     ELSE 0
                END
                    AS nbr_appt_rescheduled ,  --

                --This is billable encounters of for patients
                --Here is a concern that popped up in the
                CASE
                    WHEN d.enc_id IS NOT NULL THEN 1
                    ELSE 0
                END
                    AS nbr_enc ,
                CASE
                    WHEN ISNULL(d.billable_ind, 'N') = 'Y'
                          AND d.enc_id IS NOT NULL  THEN 1
                    ELSE 0
                END
                    AS nbr_bill_enc ,
                CASE
                    WHEN d.enc_id IS NOT NULL
                        OR d.appt_nbr IS NOT NULL THEN 1
                     ELSE 0
                END
                    AS nbr_enc_or_appt ,
                CASE
                    WHEN ISNULL(d.billable_ind, 'N') != 'Y'
                          AND d.enc_id IS NOT NULL THEN 1
                     ELSE 0
                END
                    AS nbr_non_bill_enc ,
                CASE
                    WHEN ISNULL(d.billable_ind, 'N') = 'Y'
                         AND d.appt_nbr IS NOT NULL  THEN 1
                    ELSE 0
                END
                    AS nbr_bill_enc_with_an_appt ,
                CASE
                    WHEN ISNULL(d.billable_ind, 'N') != 'Y'
                        AND d.appt_nbr IS NOT NULL THEN 1
                    ELSE 0
                END
                    AS nbr_non_bill_enc_with_an_appt ,

				--**DQ** billable criteria for unduplicated
				CASE 
					WHEN d.unduplicated_annually = 1
						AND d.billable_event = 1 THEN 1
					ELSE 0
				END
					AS first_visit_annual,
                /* ECW treats all appointments as encounters, so there is no
                separate appointment number for an ECW encounter, merely an encounter
                with a future date. Previously got the error converting varchar to numeric,
                so appt_nbr is not evaluated for ECW data
                */
                CASE
                    WHEN ISNULL(d.billable_ind, 'N') = 'Y'
                        AND ISNULL (d.appt_kept_ind, 'N') = 'Y'
                        AND d.appt_nbr IS NOT NULL THEN 1
                    ELSE 0
                END
                    AS nbr_bill_enc_with_an_appt_and_kept,

                CASE
                    WHEN ISNULL(d.billable_ind, 'N') != 'Y'
                          AND ISNULL(d.appt_kept_ind, 'N') = 'Y'
                          AND d.appt_nbr IS NOT NULL THEN 1
                     ELSE 0
                END
                    AS nbr_non_bill_enc_with_an_appt_and_kept ,
                CASE WHEN ISNULL(d.appt_create_time, 0) != 0
                     THEN DATEDIFF(DAY, CAST(d.appt_create_time AS DATE), d.appt_date)
                END
                    AS days_to_appt ,
                d.appt_create_time ,
                ds.cycle_min_kept_checkedout ,
                ds.cycle_min_kept_readyforprovider ,
                ds.cycle_min_kept_charted ,
                ds.cycle_min_readyforprovider_checkout ,
                CASE WHEN ( d.appt_date IS NOT NULL
                            AND d.slot_time IS NOT NULL
                            AND d.checkin_datetime IS NOT NULL
                          )
                     THEN IIF(( COALESCE(DATEDIFF(mi,
                                                  CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112), ' ',
                                                              SUBSTRING(d.slot_time, 1, 2), ':',
                                                              SUBSTRING(d.slot_time, 3, 2), ':00') AS DATETIME),
                                                  d.checkin_datetime), 0) > 480 )
                          OR ( COALESCE(DATEDIFF(mi,
                                                 CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112), ' ',
                                                             SUBSTRING(d.slot_time, 1, 2), ':',
                                                             SUBSTRING(d.slot_time, 3, 2), ':00') AS DATETIME),
                                                 d.checkin_datetime), 0) > -480 ), NULL, COALESCE(DATEDIFF(mi,
                                                                                                        CAST(CONCAT(CONVERT(VARCHAR(8), d.appt_date, 112),
                                                                                                        ' ',
                                                                                                        SUBSTRING(d.slot_time,
                                                                                                        1, 2), ':',
                                                                                                        SUBSTRING(d.slot_time,
                                                                                                        3, 2), ':00') AS DATETIME),
                                                                                                        d.checkin_datetime),
                                                                                                  0))
                END
                    AS cycle_min_slottime_to_kept,
                CASE
                    WHEN d.ng_data = 1 then
                'Unknown                                 '
                    ELSE d.pay1_name
                END
                    AS pay1_name,
                CASE
                    WHEN d.ng_data = 1 then
                'Unknown                                 '
                    ELSE d.pay2_name
                END
                    AS pay2_name,
                CASE
                    WHEN d.ng_data = 1 then
                'Unknown                                 '
                    ELSE d.pay3_name
                END
                    AS pay3_name,
                'Unknown' AS pay1_finclass,
                'Unknown' AS pay2_finclass,
                'Unknown' AS pay3_finclass,
                d.ng_data, --to track NextGen vs ECW appointments
				--Varchar(30), alter table was causing issues when the procedure compiled
				'                              ' as payer_summary
        INTO    dbo.data_appointment
        FROM    #appt_enc3 d
                LEFT JOIN dbo.data_status ds ON (d.enc_id = ds.enc_id AND d.enc_id IS NOT NULL)
				--Using Select Top 1 instead of join, perhaps a change to be made later
                --LEFT JOIN dbo.data_person_nd_month per ON (per.person_id_ecw = d.appt_person_id_ecw
                --                                       AND per.first_mon_date=CAST(CONVERT(CHAR(6),COALESCE(d.enc_date, d.appt_date),112)+'01' AS date))



--Sets the payer information for NextGen rows (ECW is already inserted by this point),
--Could speed up the process to add it to the insert statement

ALTER TABLE dbo.data_appointment ALTER COLUMN pay1_name VARCHAR(110)
ALTER TABLE dbo.data_appointment ALTER COLUMN pay1_finclass VARCHAR(110)
ALTER TABLE dbo.data_appointment ALTER COLUMN pay2_finclass VARCHAR(110)
ALTER TABLE dbo.data_appointment ALTER COLUMN pay3_finclass VARCHAR(110)
ALTER TABLE dbo.data_appointment ALTER COLUMN payer_summary VARCHAR(35) NULL;

update el
  set el.pay1_name = pay.payer_name
    ,el.pay1_finclass = left(ml.mstr_list_item_desc,40)
from dbo.data_appointment el
  inner join [10.183.0.94].NGPROD.dbo.encounter_payer ep
    on el.enc_id = ep.enc_id
  inner join [10.183.0.94].NGPROD.dbo.payer_mstr pay
    on ep.payer_id = pay.payer_id
  LEFT JOIN [10.183.0.94].NGPROD.dbo.mstr_lists ml
    on pay.financial_class = ml.mstr_list_item_id
  where ISNULL(ep.cob,0) = 1
  AND el.ng_data = 1


  update el
  set el.pay2_name = pay.payer_name
    ,el.pay2_finclass = left(ml.mstr_list_item_desc,40)
from dbo.data_appointment el
  inner join [10.183.0.94].NGPROD.dbo.encounter_payer ep
    on el.enc_id = ep.enc_id
  inner join [10.183.0.94].NGPROD.dbo.payer_mstr pay
    on ep.payer_id = pay.payer_id
  LEFT JOIN [10.183.0.94].NGPROD.dbo.mstr_lists ml
    on pay.financial_class = ml.mstr_list_item_id
  where ISNULL(ep.cob,0) = 2
  AND el.ng_data = 1


  update el
  set el.pay3_name = pay.payer_name
    ,el.pay3_finclass = left(ml.mstr_list_item_desc,40)
from dbo.data_appointment el
  inner join [10.183.0.94].NGPROD.dbo.encounter_payer ep
    on el.enc_id = ep.enc_id
  inner join [10.183.0.94].NGPROD.dbo.payer_mstr pay
    on ep.payer_id = pay.payer_id
  LEFT JOIN [10.183.0.94].NGPROD.dbo.mstr_lists ml
    on pay.financial_class = ml.mstr_list_item_id
  where ISNULL(ep.cob,0) = 3
  AND el.ng_data = 1



  
  UPDATE dbo.data_appointment SET payer_summary = 
	CASE
		WHEN pay1_finclass LIKE 'Unknown' THEN '09 - Self Pay'
		WHEN pay1_finclass LIKE 'Federal Sliding Fee Schedule' THEN '10 - FSFS'
		WHEN pay1_finclass LIKE 'Uninsured/Grants' THEN '11 - Uninsured/Grants'
		WHEN pay1_finclass LIKE 'Private Managed Care' THEN '07 - Private Managed Care'
		WHEN pay1_finclass LIKE 'Private Insurance' THEN '06 - Private Insurance'
		WHEN pay1_finclass LIKE 'Medicare FQHC' THEN (CASE
														WHEN pay2_finclass LIKE 'Medi-Cal FQHC'
															OR pay2_finclass LIKE 'Medi-Cal Mgd Care Capitated'
															OR pay2_finclass LIKE 'Medi-cal Mgd Care Code 18'
															OR pay2_finclass LIKE 'Medi-Cal Mgd Care FFS'
															OR pay2_finclass LIKE 'Medi-Medi' THEN '03 - Medi-Medi'
														ELSE '04 - Medicare FFS'
														END)
		WHEN pay1_finclass LIKE 'Medicare Managed Care' THEN '05 - Medicare Managed Care'
		WHEN pay1_finclass LIKE 'Medi-Medi' THEN '03 - Medi-Medi'
		WHEN pay1_finclass LIKE 'Medicare FFS' OR pay1_finclass LIKE 'Medicare FQHC' THEN '04 - Medicare FFS'
		WHEN pay1_finclass LIKE 'Medi-Cal FFS' THEN (CASE
														WHEN pay1_name LIKE 'FPACT' THEN '12 - FPACT'
														WHEN pay1_name LIKE 'CHDP only' THEN '13 - Other'
														ELSE '01 - Medi-Cal FFS'
													END)
		WHEN pay1_finclass LIKE 'Health PAC' THEN '08 - Health PAC'
		WHEN pay1_finclass LIKE 'Medi-Cal FQHC' THEN '01 - Medi-Cal FFS'
		WHEN pay1_finclass LIKE 'Medi-Cal Mgd Care Capitated'
			OR pay1_finclass LIKE 'Medi-cal Mgd Care Code 18'
			OR pay1_finclass LIKE 'Medi-Cal Mgd Care FFS' THEN '02 - Medi-Cal Mgd Care'
	END

	
  
   
   --Add column to dx table so it can be updated with enc_appt_key in next step
   ALTER TABLE dbo.data_dx ADD enc_appt_key INT NULL



        ALTER TABLE dbo.data_appointment
        ALTER COLUMN appt_time VARCHAR(4) NULL;


        ALTER TABLE dbo.data_appointment
        ADD CONSTRAINT enc_appt_key_PK PRIMARY KEY (enc_appt_key);

        CREATE NONCLUSTERED INDEX IX_person_mon_id1
        ON dbo.data_appointment (per_mon_id);


        CREATE NONCLUSTERED INDEX IX_person_mon_x_first_mon_date1
        ON dbo.data_appointment (per_mon_id, first_mon_date);

    END;
GO
