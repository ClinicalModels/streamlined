SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_schedule_slots]
AS
 BEGIN



        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        IF OBJECT_ID('tempdb..#open_appt_slots') IS NOT NULL
            DROP TABLE #open_appt_slots;

-- INITIALIZE VARIABLES

        DECLARE @dt_start VARCHAR(8) ,
            @dt_end VARCHAR(8) ,
            @dt VARCHAR(8);
  
  
-- GET END DATE FROM RESOURCE TEMPLATES

        SET @dt_start = CONVERT(VARCHAR(8), DATEADD(d, -30, GETDATE()), 112);
        SET @dt_end = CONVERT(VARCHAR(8), DATEADD(d, 180, GETDATE()), 112);
/*
SET  @dt_end = (SELECT
  MAX(rt.week_end_date)
  FROM [10.183.0.94].[NGProd].[dbo].resource_templates rt)
 */

  --   SET  @dt_end =convert(varchar(8), DATEADD(d,180,cast(@dt_end as datetime)), 112)
    
  
 --    SET @dt_start = '20100301';


  --      SET @dt_end = '20151201';

 
        SET @dt = @dt_start;  





--START LOOKING FOR OPEN APPOINTMENT SLOTS
--1) APPT WITH BOOKED < LIMIT
--2) OPEN SLOTS


--LOOP UNTIL END DATE


        CREATE TABLE #open_appt_slots
            (
              resource_id [UNIQUEIDENTIFIER] NULL ,
              begintime VARCHAR(4) ,
              duration INT ,
              category_id [UNIQUEIDENTIFIER] NULL ,
              location_id [UNIQUEIDENTIFIER] NULL ,
              appt_date VARCHAR(8) ,
              nbr_appt_avail INT ,
              nbr_slots_open_07am INT ,
              nbr_slots_open_final INT ,
              nbr_slots_open_07am_any INT ,
              nbr_slots_open_final_any INT ,
              nbr_slots_available INT ,
              nbr_slots_overbook INT
            );



        CREATE INDEX PIndex
        ON #open_appt_slots (location_id, resource_id, appt_date, category_id, begintime, duration  );
        
        CREATE INDEX XIndex
        ON #open_appt_slots (resource_id);

        CREATE INDEX YIndex
        ON #open_appt_slots (appt_date,begintime);


        CREATE INDEX ZIndex
        ON #open_appt_slots (begintime);

        WHILE ( @dt <= @dt_end )  -- LOOP UNTIL END DATE
            BEGIN 


-- **DQ** Need to change this algorithm, remove null out duration because we want the schedules to add uo and add app date to group and create a case statement  to count appointments
--This gives us all the slots that still have room for additional appointments, This only give open slot if the overbook limit is not reached as this is an aggregate

-- 1) APPT WITH BOOKED < LIMIT
-- TEMPLATE SLOTS WITH AVAILABLE APPOINTMENTS BASED ON APPT BOOKED < APPT LIMIT

                INSERT  INTO #open_appt_slots
                        ( resource_id ,
                          begintime ,
                          duration ,
                          category_id ,
                          location_id ,
                          appt_date ,
                          nbr_appt_avail ,
                          nbr_slots_open_07am ,
                          nbr_slots_open_final ,
                          nbr_slots_open_07am_any ,
                          nbr_slots_open_final_any ,
                          nbr_slots_available ,
                          nbr_slots_overbook
                        )
                        SELECT  rt.resource_id ,
                                ast.begintime ,
                                ast.duration ,
                                ast.category_id ,
                                ast.location_id ,
                                appt_date = @dt ,
                                nbr_appt_avail = 1 ,
                                nbr_slots_open_07am = 0 ,
                                nbr_slots_open_final = 0 ,
                                nbr_slots_open_07am_any = 0 ,
                                nbr_slots_open_final_any = 0 ,
                                nbr_slots_available = 1 ,
                                nbr_slots_overbook = 1
                        FROM    [10.183.0.94].[NGProd].[dbo].appointments a
                                INNER JOIN [10.183.0.94].[NGProd].[dbo].appointment_members am ON a.appt_id = am.appt_id
                                INNER JOIN [10.183.0.94].[NGProd].[dbo].events ev ON a.event_id = ev.event_id
                                INNER JOIN [10.183.0.94].[NGProd].[dbo].resources r ON am.resource_id = r.resource_id
                                LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_slot_templates ast ON a.begintime <= ast.begintime
                                                                                                  AND a.endtime > ast.begintime
                                                                                                  AND ( ast.day = 0
                                                                                                        OR ast.day = DATEPART(dw,
                                                                                                        @dt)
                                                                                                      )
                                INNER JOIN [10.183.0.94].[NGProd].[dbo].resource_templates rt ON ast.appt_template_id = rt.appt_template_id
                                                                                                 AND rt.week_start_date <= @dt
                                                                                     AND rt.week_end_date >= @dt
                


				        WHERE   ( a.appt_date = @dt
                                  AND a.create_timestamp <= CONVERT(DATETIME, @dt + ' 06:59:59.99')
                                  AND ( a.cancel_ind = 'N'
                                        AND a.resched_ind = 'N'
                                        AND a.delete_ind = 'N'
                                      )
                                ) 
 

 -- **DQ** I have discovered that the below criteria is dropping one appointment for me on 12/01 for some reason, my next step is to try to figure out why it is getting dropped
 --The answer is that the appointment was cancelled about a week after the appointment by zara ortiz, it looks like it was a hospital follow up appointment that was later rescheduled.
	

--The below criteria is looking at appointments from the perspective of 7am of the appointment day
                                OR ( a.appt_date = @dt
                                     AND a.modify_timestamp >= DATEADD(d, 0, CONVERT(DATETIME, @dt + ' 06:59:59.99'))
                                     AND a.create_timestamp <= CONVERT(DATETIME, @dt + ' 06:59:59.99')
                                     AND ( a.cancel_ind = 'Y'
                                           OR a.resched_ind = 'Y'
                                           OR a.delete_ind = 'Y'
                                         )
                                   )
                        GROUP BY ast.location_id ,
                                rt.resource_id ,
                                a.appt_date ,
                                ast.category_id ,
                                ast.begintime ,
                                ast.duration
                        HAVING  COUNT(ast.begintime) < MAX(ast.overbook_limit);











-- 2) OPEN SLOTS
-- GRAB ALL OPEN SLOTS AND ADD TO OPEN APPT SLOT TABLE


             
                INSERT  INTO #open_appt_slots
                        ( resource_id ,
                          begintime ,
                          duration ,
                          category_id ,
                          location_id ,
                          appt_date ,
                          nbr_appt_avail ,
                          nbr_slots_open_07am ,
                          nbr_slots_open_final ,
                          nbr_slots_open_07am_any ,
                          nbr_slots_open_final_any ,
                          nbr_slots_available ,
                          nbr_slots_overbook
                        )
                        SELECT DISTINCT
                                rt.resource_id ,
                                COALESCE(ast.begintime, tm.begintime) ,
                                COALESCE(ast.duration, tm.duration) ,
                                COALESCE(ast.category_id, tm.category_id) ,
                                tl.location_id ,
                                appt_date = @dt ,
                                CASE WHEN cat.prevent_appts_ind != 'Y' THEN 1
                                     ELSE 0
                                END AS nbr_appt_avail ,
                                nbr_slots_open_07am = 0 ,
                                nbr_slots_open_final = 0 ,
                                nbr_slots_open_07am_any = 0 ,
                                nbr_slots_open_final_any = 0 ,
                                nbr_slots_available = 1 ,
                                nbr_slots_overbook = 0
                        FROM    [10.183.0.94].[NGProd].[dbo].resources r --start with all resources
						        --Add range of template_ids for that date and resource -- this is based on the resource templates for that week
                                LEFT JOIN [10.183.0.94].[NGProd].[dbo].resource_templates rt ON r.resource_id = rt.resource_id
                                                                                                AND rt.week_start_date <= @dt
                                                                                                AND rt.week_end_date >= @dt
                                
								--Join all the templates that are active for that week -- this join appears to be just to grab the name and exception info
                                LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_templates t ON rt.appt_template_id = t.appt_template_id
                                
								--Template member gives all the days of the week and times for all the slots
                                LEFT JOIN [10.183.0.94].[NGProd].[dbo].template_members tm ON t.appt_template_id = tm.appt_template_id
                                                                                              AND ( tm.day = 0
                                                                                                    OR tm.day = DATEPART(dw,
                                                                                                        @dt)
                                                                                                  )
                                LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_slot_templates ast ON ast.appt_template_id = t.appt_template_id
                                                                                                  AND ast.day = tm.day
                                                                                                  AND ast.begintime >= tm.begintime
                                                                                                  AND tm.endtime > ast.begintime
                                                                                                  AND ( ast.day = 0
                                                                                                        OR ast.day = DATEPART(dw,
                                                                                                        @dt)
                                                                                                      )
                                LEFT JOIN [10.183.0.94].[NGProd].[dbo].template_locations tl ON t.appt_template_id = tl.appt_template_id
                                                                                                AND ( DATEPART(dw,
                                                                                                        CAST(@dt AS DATETIME)) = tl.day
                                                                                                      OR tl.day = 0
                                                                                                    )
                                                                                                AND tm.begintime BETWEEN tl.begintime AND tl.endtime
								
								LEFT JOIN [10.183.0.94].[NGProd].[dbo].categories cat on cat.category_id = tm.category_id
																				



        


                SET @dt = CONVERT(VARCHAR(8), DATEADD(d, 1, CAST(@dt AS DATETIME)), 112);
            END;
		

     
		--Update count of open slots
        UPDATE  #open_appt_slots
        SET     nbr_slots_open_07am = CASE WHEN a1.appt_id IS  NULL
                                                AND nbr_slots_overbook != 1
                                                AND nbr_appt_avail = 1 THEN 1
                                           ELSE 0
                                      END ,
                nbr_slots_open_07am_any = CASE WHEN a1.appt_id IS  NULL
                                                    AND nbr_slots_overbook != 1 THEN 1
                                               ELSE 0
                                          END
        FROM    #open_appt_slots os
                LEFT JOIN ( SELECT  a.appt_date ,
                                    a.appt_id ,
                                    a.begintime ,
                                    a.endtime ,
                                    a.event_id ,
                                    am.resource_id
                            FROM    [10.183.0.94].[NGProd].[dbo].appointments a
                                    INNER JOIN [10.183.0.94].[NGProd].[dbo].appointment_members am ON a.appt_id = am.appt_id
  


  --Appointments availabity on date @dt as seen from  perspective of @dt_start  at 7AM 
  --First is all appointments never changed and then add back appointment that were later changed.
  --Problem here is if there are multiple appointments per slots
                            WHERE   ( a.appt_date >= @dt_start
                                      AND a.appt_date <= @dt_end
                                      AND a.create_timestamp <= CONVERT(DATETIME, a.appt_date + ' 06:59:59.99')
                                      AND ( a.cancel_ind = 'N'
                                            AND a.resched_ind = 'N'
                                            AND a.delete_ind = 'N'
                                          )
                                    ) 
 

 --I have discovered that the below criteria is dropping one appointment for me on 12/01 for some reason, my next step is to try to figure out why it is getting dropped
 --The answer is that the appointment was cancelled about a week after the appointment by zara ortiz, it looks like it was a hospital follow up appointment that was later rescheduled.
	

--The below criteria is looking at appointments from the perspective of 7am of the appointment day
                                    OR ( a.appt_date >= @dt_start
                                         AND a.appt_date <= @dt_end
                                         AND a.modify_timestamp >= DATEADD(d, 0,
                                                                           CONVERT(DATETIME, a.appt_date
                                                                           + ' 06:59:59.99'))
                                         AND a.create_timestamp <= CONVERT(DATETIME, a.appt_date + ' 06:59:59.99')
                                         AND ( a.cancel_ind = 'Y'
                                               OR a.resched_ind = 'Y'
                                               OR a.delete_ind = 'Y'
                                             )
                                       )
                          ) a1 ON os.appt_date = a1.appt_date
                                  AND os.begintime >= a1.begintime
                                  AND os.begintime < a1.endtime
                                  AND os.resource_id = a1.resource_id
        WHERE   a1.appt_id IS NULL; 



		--Update number of open slots
        UPDATE  #open_appt_slots
        SET     nbr_slots_open_final = CASE WHEN a1.appt_id IS  NULL
                                                 AND nbr_slots_overbook != 1
                                                 AND nbr_appt_avail = 1 THEN 1
                                            ELSE 0
                                       END ,
                nbr_slots_open_final_any = CASE WHEN a1.appt_id IS  NULL
                                                     AND nbr_slots_overbook != 1 THEN 1
                                                ELSE 0
                                           END
        FROM    #open_appt_slots os
                LEFT JOIN ( SELECT  a.appt_date ,
                                    a.appt_id ,
                                    a.begintime ,
                                    a.endtime ,
                                    a.event_id ,
                                    am.resource_id
                            FROM    [10.183.0.94].[NGProd].[dbo].appointments a
                                    INNER JOIN [10.183.0.94].[NGProd].[dbo].appointment_members am ON a.appt_id = am.appt_id
  


  --Appointments availabity on date @dt as seen from  perspective of @dt_start  at 7AM 
  --First is all appointments never changed and then add back appointment that were later changed.
  --Problem here is if there are multiple appointments per slots
                            WHERE   ( a.appt_date >= @dt_start
                                      AND a.appt_date <= @dt_end
                                      AND ( a.cancel_ind = 'N'
                                            AND a.resched_ind = 'N'
                                            AND a.delete_ind = 'N'
                                          )
                                    )
                          ) a1 ON os.appt_date = a1.appt_date
                                  AND os.begintime >= a1.begintime
                                  AND os.begintime < a1.endtime
                                  AND os.resource_id = a1.resource_id
        WHERE   a1.appt_id IS NULL; 





-- CHECK NEXT DAY AND LOOP FROM START

--DROP TABLE dbo.data_schedule_slots
/*
   
        CREATE TABLE dbo.data_schedule_slots
            ( 
               schedule_resource_key int NULL ,
               slot_loc_key int NULL,
			   category_key int NULL ,
			   resource_id UNIQUEIDENTIFIER NULL,
			   provider_id UNIQUEIDENTIFIER NULL,
	    	   location_id UNIQUEIDENTIFIER NULL,
     		   category_id UNIQUEIDENTIFIER NULL,
               appt_date DATE ,
			   slot_time VARCHAR(4) ,
               slot_duration INT ,
		       nbr_slots_can_appt INT,
               nbr_slots_open_07am INT ,
               nbr_slots_open_final INT ,
			   nbr_slots_open_07am_any INT ,
               nbr_slots_open_final_any INT ,
               nbr_slots_available INT ,
               nbr_slots_overbook INT
            );


*/

		--Clear out any overlapping rows to be recalculated
        DELETE  FROM dbo.data_schedule_slots
        WHERE   appt_date >= @dt_start
                AND appt_date <= @dt_end;

     --SET IDENTITY_INSERT dbo.data_schedule_slots OFF;
        INSERT  INTO dbo.data_schedule_slots
                ( schedule_resource_key ,
				  resource_key,
                  slot_loc_key ,
                  category_key ,
                  resource_id ,
				  provider_id,
                  location_id ,
                  category_id ,
                  appt_date ,
                  slot_time ,
                  slot_duration ,
                  nbr_slots_can_appt ,
                  nbr_slots_open_07am ,
                  nbr_slots_open_final ,
				  nbr_slots_open_07am_any,
				  nbr_slots_open_final_any,
				  nbr_slots_available ,
                  nbr_slots_overbook
                )
                SELECT  NULL AS schedule_resource_key ,
				        NULL AS resource_key,
                        NULL AS slot_loc_key ,
                        NULL AS category_key ,
                        resource_id ,
						NULL AS provider_id,
                        location_id ,
                        category_id ,
                        CAST(appt_date AS DATE) AS appt_date ,
                        begintime AS slot_time ,
                        CAST(duration AS INT) AS slot_duration ,
                        nbr_appt_avail ,
                        nbr_slots_open_07am ,
                        nbr_slots_open_final ,
							  nbr_slots_open_07am_any,
				  nbr_slots_open_final_any,
                        nbr_slots_available ,
                        nbr_slots_overbook
                FROM    #open_appt_slots os;


     --   SET IDENTITY_INSERT dbo.data_schedule_slots OFF;
        UPDATE  dbo.data_schedule_slots
        SET     schedule_resource_key = ( SELECT TOP 1
                                                    user_key
                                          FROM      dbo.data_user du
                                          WHERE     du.resource_id = os.resource_id
                                                    AND du.[unique_resource_id_flag] = 1
                                                    AND os.resource_id IS NOT NULL
                                          ORDER BY  du.unique_resource_id_flag ASC ,
                                                    du.unique_provider_id_flag ASC
                                        ) ,
                   resource_key = (SELECT TOP 1 resource_key FROM dbo.data_resource dr
				                     WHERE dr.resource_id=os.resource_id
									 AND os.resource_id IS NOT null),




                provider_id = ( SELECT TOP 1
                                                    du.provider_id
                                          FROM      dbo.data_user du
                                          WHERE     du.resource_id = os.resource_id
                                                    AND du.[unique_resource_id_flag] = 1
                                                    AND os.resource_id IS NOT NULL
                                          ORDER BY  du.unique_resource_id_flag ASC ,
                                                    du.unique_provider_id_flag ASC
                                        ) ,


                slot_loc_key = ( SELECT TOP 1
                                        location_key
                                 FROM   dbo.data_location dl
                                 WHERE  dl.location_id = os.location_id
                                        AND dl.location_id_unique_flag = 1
                                        AND os.location_id IS NOT NULL
                               ) ,
                category_key = ( SELECT TOP 1
                                        cat_event_key
                                 FROM   dbo.data_category_event ce
                                 WHERE  ce.category_id = os.category_id
                                        AND os.category_id IS NOT NULL
                               )
        FROM    dbo.data_schedule_slots os;
                         
				


        ALTER TABLE dbo.data_schedule_slots DROP COLUMN slot_key;

-- add new "RowId" column, make it IDENTITY (= auto-incrementing)
        ALTER TABLE dbo.data_schedule_slots
        ADD slot_key INT NOT NULL IDENTITY(1,1);

---- add new primary key constraint on new column   
--ALTER TABLE dbo.data_schedule_slots 
--ADD CONSTRAINT PK_data_schedule_slots 
--PRIMARY KEY CLUSTERED (slot_key)


--ALTER TABLE dbo.data_schedule_slots 
--DROP CONSTRAINT PK_data_schedule_slots 

/*  AUDIT REPORT

    SELECT  r.resource_name ,
            c.category ,
            ss.appt_date ,
            ss.slot_time ,
            ss.slot_duration ,
	ss.nbr_slots_can_appt,
            ss.nbr_slots_open_07am ,
            ss.nbr_slots_open_final ,
            ss.nbr_slots_available ,
            ss.nbr_slots_overbook
    FROM    dbo.data_schedule_slots ss
            LEFT JOIN dbo.data_user r ON r.user_key = ss.schedule_resource_key
            LEFT JOIN [10.183.0.94].[NGProd].[dbo].categories c ON ss.category_id = c.category_id
    WHERE   ss.slot_loc_key = 37
            AND appt_date = '20151201'
    ORDER BY r.resource_name ,
            ss.appt_date ,
            ss.slot_time;


--Still missing mendozas 9:30 appointment

    SELECT  rs.description ,
           c.category ,
            ss.*
    FROM    #open_appt_slots ss
            LEFT JOIN [10.183.0.94].[NGProd].[dbo].resources rs ON rs.resource_id = ss.resource_id
            LEFT JOIN [10.183.0.94].[NGProd].[dbo].categories c ON ss.category_id = c.category_id
    WHERE   ss.location_id = '8BAD2EFD-B455-43B7-AA73-687ACFFF789E'
      
	 -- WHERE   ss.resource_id = '3EC63192-6390-4E02-BDF2-418F9CD75008'
      
	        AND appt_date = '20151201'
    ORDER BY rs.description ,
            ss.appt_date ,
            ss.begintime;

*/

            
    END;
GO
