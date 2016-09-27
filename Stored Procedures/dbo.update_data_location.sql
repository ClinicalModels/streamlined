SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_location]
AS
  BEGIN


        SET ANSI_NULLS ON; --Treats NULL as a missing value, cannot be used with comparison operators
        SET QUOTED_IDENTIFIER ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --Allow for "dirty" reads

        IF OBJECT_ID('dbo.data_location') IS NOT NULL
            DROP TABLE dbo.data_location;
 
        IF OBJECT_ID('tempdb..#location_map') IS NOT NULL
            DROP TABLE #location_map
 
 --DQ Routine--
--This added HealthPac ID information and a few historical spellings for medical home

        CREATE TABLE #Location_map
            (
              location_id UNIQUEIDENTIFIER ,
              ud_demo3_id UNIQUEIDENTIFIER ,
              healthpac_id VARCHAR(4) ,
              location_name VARCHAR(100) ,
              site_id VARCHAR(3) ,
              location_id_unique_flag INT,
			  ecw_location_id INT NULL,
			  location_address VARCHAR(140)
            );

		--Locations are manually entered to link location_id to site_id, which is not present in NextGen
        INSERT  INTO #Location_map
                ( location_id, ud_demo3_id, healthpac_id, location_name, site_id, location_id_unique_flag,location_address )
        VALUES  ( 'CE01BF12-1DC0-4C09-9694-474C8EEA8327', '8125418E-7B63-4D4C-901B-63C0BFE95A53', '4002', NULL, '550',1, '3075 ADELINE ST STE 280 , BERKELEY , CA , 94703-2580' ),  -- LifeLong Ashby Health Center
                ( 'E4CDE909-10FB-4B3E-8AEE-27298138F4AF', 'D3C9A792-EA26-4A26-9336-94399832CB79', '', NULL, NULL, 1, '2001 DWIGHT WAY, RM 1363, BERKELEY, CA 94704-2608' ),  --LifeLong Berkeley Primary Care
                --( 'B9202BC6-62BF-43CB-A63D-B0F94159B6A3', '5DED0E87-411F-4323-9051-A6215EF8883E', '', NULL, '880',1 ),  --LifeLong Brookside Richmond
				--( '7E24D5CB-1B46-4669-9D87-80ED80663402', '962C60B9-D7E0-452A-BF17-4A6ED6023E36', '', NULL,'890',1 ), --LifeLong Brookside San Pablo
                ( '6EBE563F-39A4-49C1-936A-B6966CECFF7C', '578B940F-EC70-4D1D-9DEB-A2A3AE671719', '4008', NULL, '200', 1, '1860 ALCATRAZ AVE , BERKELEY , CA , 94703-2715' ),  --LifeLong Dental Center
                ( '9567D24D-2B4F-402B-A7CA-0546A85D8CF3', '453F0729-40D3-4CD8-BC8D-F30E3865A882', '4004', NULL, '840', 1, '616 16TH ST, OAKLAND, CA , 94612-1205' ),  --LifeLong Downtown Oakland Clinic
           --     ( '9567D24D-2B4F-402B-A7CA-0546A85D8CF3', '224AA5F3-6263-4811-9C40-A57595FAE72A', '4004' ,'LifeLong SHP/DOC'),  --Alternate spelling of medical home--LifeLong Downtown Oakland Clinic
                ( '1A0FECF5-00C2-4E16-BFDA-D529166A3DC8', 'EBAF047B-B263-4489-879C-034DB96DA74D', '4012', NULL, '300', 1, '10700 MACARTHUR BLVD , STE 14B , OAKLAND , CA , 94605-5260' ),  --LifeLong East Oakland            
                ( '77DC467B-A986-4BD3-B0A3-1509ADE9B722', '76BD59E7-60AE-4160-B739-29BCEC6A7EA1', '4012', NULL, NULL,1, '' ),  --LifeLong East Oakland ADHC  -- Having a medical home of ADHC/East Oakland will map the location_id to East Oakland
                ( 'A6BCC717-C0C9-454A-90FC-1EF010256FE4', 'DE5D740A-A20C-4D45-A38F-AF00F9E99653', '', NULL, '310', 1, '	7200 BANCROFT AVENUE, SUITE 125A. OAKLAND, CA, 94605-2403' ),   --LifeLong Eastmont Center
                ( 'E9C81D34-ECF1-4851-B3E3-6A01E28AEF84', '3E675DED-89FE-4FDA-A61B-2D02668FC98D', '', NULL, '730',1, '1800 98TH AVENUE, OAKLAND, CA, 94603-2702' ),   --LifeLong Elmhurst/Alliance Academy
                ( 'A8DFDE55-EEB0-4353-ACC5-AC39B792841D', '58FEA7B9-61C9-43CA-8A24-37BE9619727D', '', NULL,'320', 1, '10700 MACARTHUR BLVD , STE 14B , OAKLAND , CA , 94605-5260' ),   --LifeLong EO Wellness Center
                ( '6678B8DA-C10E-442C-97DC-D40979D7C2DF', 'C138486D-4C26-4D92-B553-E95400E197BF', '4006', NULL, '330',1, '9933 MACARTHUR BLVD , OAKLAND , CA , 94605-4853' ),   --LifeLong Howard Daniel Clinic
                ( 'C2678A20-C0B9-46C6-8E10-7E1ACCB6D826', '0E88F95B-4790-4DB4-AF36-D025593AAB07', '', NULL,'620', 1, '150 Harbour Way, Richmond, CA 94801' ),   --LifeLong Jenkins Pediatric Center
                ( '8BAD2EFD-B455-43B7-AA73-687ACFFF789E', 'D1521C2F-3A7A-41FA-B5FA-7BBB0715A9D0', '4010', NULL, '100', 1, '3260 SACRAMENTO ST, BERKELEY, CA , 94702-2739' ),   --LifeLong Over 60 Health Center
                ( '8BAD2EFD-B455-43B7-AA73-687ACFFF789E', '1DFC42E0-321F-43DD-8F33-34BB4C753BCE', '4010', NULL, NULL,0, '3260 SACRAMENTO ST, BERKELEY, CA , 94702-2739' ),    --LifeLong SNF-Nursing Over 60 --Having a medical home of SNF will map the location_id to Over Sixty
                ( '18ABDAF4-C538-4E07-9C02-07CAA576F49B', '621890E1-B2EC-4AFB-9752-6C77063D461B', '4004', NULL, '850', 1, '2600 MCDONALD AVE, SUITE B, RICHMOND , CA , 94804-1826' ),    --LifeLong Richmond Clinic
                ( 'EAE9576F-6B6F-46F0-98AC-7D057B27E18B', '09C57FBA-16D2-4828-B884-E7B9BCBD8252', '', NULL, '080',1, '920, ALLSTON WAY, BERKELEY, CA, 94710-2389' ),    --LifeLong Rosa Parks School
                ( '0E6B0497-44E6-4C1C-AC3C-668999AA6B3F', 'FC9346CE-EB14-4060-B548-472216347BA0', '', NULL, '820', 1, '' ),    --LifeLong Supportive Housing Project
                ( '4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD', 'F6EC14C6-8ECF-4A0E-9663-FF79F88D3D51', '', NULL, NULL,1, '	390 40TH STREET, OAKLAND , CA , 94609-2633' ),     --LifeLong Thunder Road
                ( 'F62ED25A-6AC2-4355-A6E4-72B1326F39AF', '131B16DE-F576-4028-AC08-158470F42599', '4014', NULL,'400', 1, '2031 6TH ST, BERKELEY, CA  94710-2006 ' ),     --LifeLong West Berkeley Family Practice
                ( '5A972255-18DD-4F52-B4D2-F10C12C8F08F', 'D305AD2A-FBA9-4F77-9D03-4DFDEE33662C', '', NULL,'710', 1, '991 14th St. Oakland CA 94607' ) ,    --LifeLong West Oakland Middle School
			    ( 'DBA6D52D-26D1-4748-AFB7-218BAF850E33', '11111111-FBA9-4F77-9D03-4DFDEE33662C', '', NULL, '510', 1, '3075 ADELINE ST STE 280 , BERKELEY , CA , 94703-2580' ) ,  --LifeLong Urgent Care Berkeley
		        ( '4B364AA9-7538-4628-9EFC-EADAA55B1E14', 'F5CED195-9897-4346-8F25-EA07228B680D', '', NULL, '860', 1, '386 14th st Oakland CA 94612' ),    --LifeLong Trust Health Center
			    ( 'B4552247-7927-4944-8000-C70CFC0EDE7F', '11111111-FBA9-4F77-9D03-4DFDEE33662C', '', NULL, '865', 1,'1690 San Pablo Ave Pinole' ),     --LifeLong Pinole Health Center
				('B278DB62-DA87-46B9-A17F-7227A275D3FC', 'A44A6366-D97C-483F-BF38-2FA8849AF573 ', '', NULL, '875',1,'2 CALIFORNIA ST Rodeo, CA 94572') --LifeLong Rodeo Health Center
			
				;

	





 --DQ Routine--
 --This elminates locations that are in the masterfile that have never had an encounter.  
 --At somepoint it would be worthwhile to clean up the masterfile

        WITH    location_clean
                  AS ( SELECT  DISTINCT
                                loc.location_id ,
                                loc.location_name
                       FROM     [10.183.0.94].NGProd.dbo.patient_encounter AS enc
                                LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.location_mstr AS loc ON enc.location_id = loc.location_id
                       WHERE    ( loc.location_name <> '' )
                                AND ( enc.practice_id = '0001' )
                     )
            SELECT  IDENTITY( INT, 1, 1 )  AS location_key ,
                    loc.location_id ,
                    lm.ud_demo3_id ,
                    lm.healthpac_id ,
                    loc.location_name AS location_mstr_name ,
					--If an item exists in the mstr_lists table, it is preferred as Medical Home name
                    COALESCE(ml.mstr_list_item_desc, loc.location_name) AS location_mh_name ,
					lm.site_id,
                    COALESCE(lm.location_id_unique_flag, 1) AS location_id_unique_flag,
					lm.ecw_location_id,
					lm.location_address
            INTO    dbo.data_location
            FROM    location_clean loc
                    LEFT OUTER JOIN #Location_map lm ON lm.location_id = loc.location_id
                    LEFT JOIN [10.183.0.94].NGProd.dbo.mstr_lists ml ON lm.ud_demo3_id = ml.mstr_list_item_id;

/*
					SELECT	mstr_list_type ,
                            mstr_list_item_id ,
                            mstr_list_item_desc
                           
							
							 FROM [10.183.0.94].NGProd.dbo.mstr_lists WHERE  mstr_list_type = 'ud_demo3' ORDER BY create_timestamp
*/


/*
	Creating a site hierarchy for summarization in visit reports (multiple locations are reviewed as a single site)
*/

UPDATE dbo.data_location
SET  site_id = CASE
						WHEN location_id LIKE '62FD433C-6D26-431D-8ED7-2A7DF4A5897C' THEN '600'
					END
WHERE location_id IN (
						'62FD433C-6D26-431D-8ED7-2A7DF4A5897C')

/*
ECW clinics are loaded separately, as they use integers instead of UNIQUEIDENTIFIER for their location IDs
*/
		INSERT INTO dbo.data_location
		(location_mstr_name, location_mh_name, site_id, location_id_unique_flag,ecw_location_id, location_address)
		VALUES
		('LifeLong Brookside San Pablo','LifeLong Brookside San Pablo','890',1,19, '2023 VALE RD , STE 107 , SAN PABLO , CA , 94806-3891'),
		('LifeLong Brookside Richmond','LifeLong Brookside Richmond','880',1,4, '1030 NEVIN AVE, RICHMOND, CA , 94801-3122'),
		('LifeLong Brookside Urgent Care','LifeLong Brookside Urgent Care','894',1,23, '2023 VALE RD , STE 107 , SAN PABLO , CA , 94806-3891')--Urgent Care and San Pablo use same site code, so not unique


        ALTER TABLE dbo.data_location
        ADD CONSTRAINT location_pk PRIMARY KEY ( location_key);





        DROP TABLE #Location_map;

    END;
GO
