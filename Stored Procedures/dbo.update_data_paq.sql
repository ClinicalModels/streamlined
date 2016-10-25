SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	<Description,creates dwh table that contains all active and Sigoff PAQ >
-- =============================================

--Notes 
-- ================================================
--4/14/2016 dwh table created.**DQ** I realized that 84 of patient items do not have creation date. compare to total item data is 6280584.
-- ================================================


--Updates 
-- ================================================
--4/11/2016 HD the code updated to bring all providers active PAQ
--4/15/2016 HD added number of reassigned and rejected PAQ
--4/23/2016 HD added lab flag and description
--4/28/2016 HD added Provider Key for PAQ reassigned Provider and PAQ provider
--4/29/2016 HD added all signoff PAQ even though they are still active, add modification time for those PAQ
-- ================================================
-- =============================================
CREATE PROCEDURE [dbo].[update_data_paq]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on
	SET transaction isolation level read UNCOMMITTED
    
    IF OBJECT_ID('tempdb..#active_paq') IS NOT NULL
           DROP TABLE #active_paq;
    IF OBJECT_ID('tempdb..#lab_flag') IS NOT NULL
            DROP TABLE #lab_flag;
    IF OBJECT_ID('tempdb..#data_PAQ') IS NOT NULL
            DROP TABLE #data_PAQ;
	IF OBJECT_ID('tempdb..#temp_signoffPAQ') IS NOT NULL
		DROP TABLE #temp_signoffPAQ;
	IF OBJECT_ID('tempdb..#temp_all_signoffPAQ') IS NOT NULL
		DROP TABLE #temp_all_signoffPAQ;
	IF OBJECT_ID('tempdb..#data_PAQ_final') IS NOT NULL
		DROP TABLE #data_PAQ_final
	IF OBJECT_ID('tempdb..#labPAQ') IS NOT NULL
		DROP TABLE #labPAQ
	IF OBJECT_ID('dbo.data_paq') IS NOT NULL
		DROP TABLE dbo.data_paq



CREATE table  #active_paq  (
   [Item Type]            varchar(1)       NOT NULL, --L for lab,D for Document and S for ICS pictures
   [Item ID]            uniqueidentifier NOT NULL,     
   [provider_id]          uniqueidentifier  NULL,
   [enc_id]				  UNIQUEIDENTIFIER NULL,
   [Item Name]            varchar(255)         NULL,
   [created_by]			  INT   NOT NULL,
   [modified_by]		  INT NOT NULL,
   [CreateDate]           datetime		NULL,
   [modifyDate]           DATETIME	    NULL,  
   [person_id]            varchar(36),
   abnorm_flags				CHAR(2)  null,
   --result  char(1) NULL
 

)

CREATE TABLE #labPAQ
(
     [Item Type] VARCHAR(1) NOT null
      ,[order_num] UNIQUEIDENTIFIER NOT NULL
      ,[provider_id] UNIQUEIDENTIFIER NULL
      ,[enc_id] UNIQUEIDENTIFIER NULL
      ,[Item Name] VARCHAR(255) NULL
      ,[created_by] INT NOT NULL
      ,[modified_by] INT NOT NULL
      ,[CreateDate] DATETIME NULL
      ,[modify_timestamp] DATETIME NULL
      ,[person_id] VARCHAR(36)
      ,[abnorm_flags] CHAR(2) NULL
      ,[Range] INT
      ,[rank] INT
)
 
declare
   @pi_enterprise_id        char(5),          -- Enterprise ID
   @pi_practice_id          char(4),          -- Practice ID
   @pi_signoff_status       char(1),          -- 'P'ending / 'R'ejected
   @pi_use_documents_flag   int,              -- Use Documents: 1/0 (bit)
   @pi_use_notes_flag       int,              -- Use Notes: 1/0 (bit)
   @pi_use_images_flag      int,              -- Use Images: 1/0 (bit)
   @pi_use_ics_flag         int,              -- Use ICS: 1/0 (bit)
   @pi_use_labs_flag        int,              -- Use Labs: 1/0 (bit)
   @pi_provider_type        char(1),          -- 'E'ncounter / 'O'rdering
   @pi_userID                     int,                  -- Used for Tasks
   @pi_createdate             DATETIME
  
 
-- fixed defaults
SET @pi_enterprise_id = '00001'
SET @pi_practice_id = '0001'
SET @pi_signoff_status = 'P'
SET @pi_use_documents_flag = 1
SET @pi_use_notes_flag = 1
SET @pi_use_images_flag = 1
SET @pi_use_ics_flag = 1
SET @pi_use_labs_flag = 1
SET @pi_provider_type = 'O'  --O ordering provider E encounter




-- Patient Documents
IF @pi_use_documents_flag = 1
BEGIN
   -- Reassigned
   INSERT INTO  #active_paq  
   SELECT 'D' As 'Item Type',d.document_id, d.paq_provider_id as provider_id,d.enc_id AS enc_id,d.document_desc As 'Item Name',d.created_by AS created_by,d.modified_by AS modified_by, d.create_timestamp as 'CreateDate',d.modify_timestamp AS modifyDate, e.person_id,NULL
     FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
     INNER JOIN [10.183.0.94].NGProd.dbo.patient_documents d 
     WITH (nolock)  ON e.enterprise_id = d.enterprise_id
      AND e.practice_id = d.practice_id 
      AND e.enc_id = d.enc_id
      AND e.enterprise_id = @pi_enterprise_id 
      AND e.practice_id = @pi_practice_id 
     -- AND d.paq_provider_id = @pi_provider_id
      AND d.signoff_status = @pi_signoff_status
	  AND d.paq_provider_id IS NOT NULL
     LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.security_items s 
     with (nolock)  ON d.document_desc = s.description 
      AND s.item_type = 'D' 
      AND s.delete_ind = 'N' 
 
   -- Use Ordering Provider
   IF @pi_provider_type = 'O' 
   BEGIN
      -- All documents attached to radiology orders for a given ordering provider
      INSERT INTO  #active_paq  
      SELECT 'D' As 'Item Type',d.document_id,lt.ordering_provider as provider_id,d.enc_id AS enc_id,d.document_desc As 'Item Name',d.created_by AS created_by,d.modified_by AS modified_by, d.create_timestamp as 'CreateDate',d.modify_timestamp AS modifyDate ,e.person_id,NULL
      FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
      INNER JOIN [10.183.0.94].NGProd.dbo.patient_documents d 
        with (nolock)  ON e.enterprise_id = d.enterprise_id 
          AND e.practice_id = d.practice_id 
          AND e.enc_id = d.enc_id 
          AND e.enterprise_id = @pi_enterprise_id 
          AND e.practice_id = @pi_practice_id 
          AND d.signoff_status = @pi_signoff_status 
          AND d.paq_provider_id IS NULL 
		    INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor lt
                   with (nolock)   ON e.enterprise_id = lt.enterprise_id 
                        AND e.practice_id = lt.practice_id 
                        AND lt.delete_ind = 'N' 
      LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.security_items s 
       with (nolock)  ON d.document_desc = s.description 
       AND s.item_type = 'D' 
       AND s.delete_ind = 'N' 
      WHERE EXISTS (SELECT 1 FROM [10.183.0.94].NGProd.dbo.lab_results_obx x 
                    INNER JOIN [10.183.0.94].NGProd.dbo.lab_results_obr_p r 
                     with (nolock)   ON x.unique_obr_num = r.unique_obr_num 
                     INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor l 
                     with (nolock)   ON e.enterprise_id = l.enterprise_id 
                        AND e.practice_id = l.practice_id 
                        AND l.delete_ind = 'N' 
                        AND l.order_num = r.ngn_order_num 
                        --AND l.ordering_provider = @pi_provider_id 
						AND l.ordering_provider IS NOT NULL
                          WHERE x.enterprise_id = e.enterprise_id 
                              AND x.practice_id = e.practice_id 
                              AND x.person_id = e.person_id 
                              AND x.obs_id = '[{Document}]' 
                              AND x.observ_value = cast(d.document_id as varchar(36)) 
                              AND x.delete_ind = 'N')
         
--      -- All documents (not attached to radiology orders) for a given rendering provider
      INSERT INTO  #active_paq  
      SELECT 'D' As 'Item Type',d.document_id ,e.rendering_provider_id as provider_id,d.enc_id AS enc_id, d.document_desc As 'Item Name',d.created_by AS created_by,d.modified_by AS modified_by, d.create_timestamp as 'CreateDate',d.modify_timestamp AS modifyDate,e.person_id,NULL
      FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
      INNER JOIN [10.183.0.94].NGProd.dbo.patient_documents d 
       with (nolock)   ON e.enterprise_id = d.enterprise_id 
          AND e.practice_id = d.practice_id 
          AND e.enc_id = d.enc_id 
          AND e.enterprise_id = @pi_enterprise_id 
          AND e.practice_id = @pi_practice_id 
         -- AND e.rendering_provider_id = @pi_provider_id 
		 AND e.rendering_provider_id IS NOT NULL
          AND d.signoff_status = @pi_signoff_status 
          AND d.paq_provider_id IS NULL 
      LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.security_items s 
       with (nolock)   ON d.document_desc = s.description 
          AND s.item_type = 'D' 
          AND s.delete_ind = 'N' 
      WHERE NOT EXISTS (SELECT 1 FROM [10.183.0.94].NGProd.dbo.lab_results_obx x 
                              WHERE x.enterprise_id = e.enterprise_id 
                                  AND x.practice_id = e.practice_id 
                                  AND x.person_id = e.person_id 
                                  AND x.obs_id = '[{Document}]' 
                                  AND x.observ_value = cast(d.document_id as varchar(36)) 
                                  AND x.delete_ind = 'N')
   END
 ELSE
   BEGIN
   -- Use Encounter Provider
      INSERT INTO  #active_paq  
      SELECT 
		'D' As 'Item Type'
		,d.document_id
		,e.rendering_provider_id as provider_id
		,d.enc_id AS enc_id
		, d.document_desc As 'Item Name'
		,d.created_by AS created_by,d.modified_by AS modified_by
		, d.create_timestamp as 'CreateDate'
		,d.modify_timestamp AS modifyDate
		,e.person_id,NULL
       FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
        INNER JOIN patient_documents d 
       with (nolock)  ON e.enterprise_id = d.enterprise_id
         AND e.practice_id = d.practice_id 
         AND e.enc_id = d.enc_id 
         AND e.enterprise_id = @pi_enterprise_id 
         AND e.practice_id = @pi_practice_id 
        -- AND e.rendering_provider_id = @pi_provider_id 
		AND e.rendering_provider_id IS NOT NULL
        AND d.signoff_status = @pi_signoff_status 
        LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.security_items s 
        with (nolock)  ON d.document_desc = s.description 
         AND s.item_type = 'D' 
         AND s.delete_ind = 'N' 
         WHERE d.paq_provider_id IS NULL
   END
END



-- Patient Notes
IF @pi_use_notes_flag = 1
BEGIN
-- Reassigned
INSERT INTO  #active_paq 
 SELECT 
	'N' As 'Item Type'
	,n.note_id,n.paq_provider_id as provider_id
	,n.enc_id, RTRIM(n.table_name) + '.' + RTRIM(n.field_name) As 'Item Name'
	,n.created_by AS created_by,n.modified_by AS modified_by
	,n.create_timestamp as 'CreateDate'
	,n.modify_timestamp AS modifyDate
	,e.person_id,NULL
FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
 INNER JOIN  [10.183.0.94].NGProd.dbo.patient_notes n 
  with (nolock)  ON e.enterprise_id = n.enterprise_id
   AND e.practice_id = n.practice_id 
   AND e.enc_id = n.enc_id 
   AND e.enterprise_id = @pi_enterprise_id 
   AND e.practice_id = @pi_practice_id 
   AND n.paq_provider_id IS NOT NULL  --add
  -- AND n.paq_provider_id = @pi_provider_id
   AND n.signoff_status = @pi_signoff_status
    LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.templates t 
 with (nolock)   ON substring(n.table_name,1,len(n.table_name)-1) = t.template_name
 
INSERT INTO  #active_paq  
SELECT 
	'N' As 'Item Type'
	,n.note_id
	,e.rendering_provider_id as provider_id
	,n.enc_id
	,RTRIM(n.table_name) + '.' + RTRIM(n.field_name) As 'Item Name'
	,n.created_by AS created_by
	,n.modified_by AS modified_by
	,n.create_timestamp as 'CreateDate'
	,n.modify_timestamp AS modifyDate
	,e.person_id,NULL  
FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
INNER JOIN [10.183.0.94].NGProd.dbo.patient_notes n 
with (nolock)  ON e.enterprise_id = n.enterprise_id
   AND e.practice_id = n.practice_id 
   AND e.enc_id = n.enc_id
   AND e.enterprise_id = @pi_enterprise_id 
   AND e.practice_id = @pi_practice_id
   AND e.rendering_provider_id IS NOT NULL --add
  -- AND e.rendering_provider_id = @pi_provider_id 
   AND n.signoff_status = @pi_signoff_status
   LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.templates t 
 with (nolock)  ON substring(n.table_name,1,len(n.table_name)-1) = t.template_name
  WHERE  n.paq_provider_id IS NULL
END



-- Patient Images
IF @pi_use_images_flag = 1
BEGIN
   -- Reassigned
   INSERT INTO  #active_paq  
   SELECT 'I' As 'Item Type',i.image_id, i.paq_provider_id as provider_id,e.enc_id, i.image_desc As 'Item Name', i.created_by AS created_by,i.modified_by AS modified_by, i.create_timestamp as 'CreateDate',i.modify_timestamp AS modifyDate, i.person_id,NULL
   FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
    INNER JOIN [10.183.0.94].NGProd.dbo.patient_images i 
    with (nolock)   ON e.enterprise_id = i.enterprise_id
      AND e.practice_id = i.practice_id 
      AND e.enc_id = i.enc_id 
      AND e.enterprise_id = @pi_enterprise_id 
      AND e.practice_id = @pi_practice_id 
     -- AND i.paq_provider_id = @pi_provider_id
	 AND i.paq_provider_id IS NOT NULL --add
      AND i.signoff_status = @pi_signoff_status
      
   -- Use Ordering Provider
IF @pi_provider_type = 'O' 
BEGIN
      -- All images attached to radiology orders for a given ordering provider
      INSERT INTO  #active_paq  
       SELECT 'I' As 'Item Type' ,i.image_id, lt.ordering_provider as provider_id,e.enc_id, i.image_desc As 'Item Name', i.created_by AS created_by,i.modified_by AS modified_by, i.create_timestamp as 'CreateDate',i.modify_timestamp AS modifyDate, i.person_id,NULL
      FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
      INNER JOIN [10.183.0.94].NGProd.dbo.patient_images i 
       with (nolock)  ON e.enterprise_id = i.enterprise_id
          AND e.practice_id = i.practice_id 
          AND e.enc_id = i.enc_id 
          AND e.enterprise_id = @pi_enterprise_id 
          AND e.practice_id = @pi_practice_id  
          AND i.signoff_status = @pi_signoff_status 
          AND i.paq_provider_id IS NULL
		     INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor lt --add
                     with (nolock)   ON e.enterprise_id = lt.enterprise_id 
                        AND e.practice_id = lt.practice_id 
                        AND lt.delete_ind = 'N' 
       WHERE EXISTS (SELECT 1 FROM [10.183.0.94].NGProd.dbo.lab_results_obx x 
                     INNER JOIN [10.183.0.94].NGProd.dbo.lab_results_obr_p r 
                     with (nolock)    ON x.unique_obr_num = r.unique_obr_num 
                     INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor l 
                      with (nolock)   ON e.enterprise_id = l.enterprise_id 
                         AND e.practice_id = l.practice_id 
                         AND l.delete_ind = 'N' 
                         AND l.order_num = r.ngn_order_num 
                       --  AND l.ordering_provider = @pi_provider_id 
					       AND l.ordering_provider IS NOT NULL --add
                           WHERE x.enterprise_id = e.enterprise_id 
                               AND x.practice_id = e.practice_id 
                               AND x.person_id = e.person_id 
                               AND x.obs_id = '[{Image}]' 
                               AND x.observ_value = cast(i.image_id as varchar(36)) 
                               AND x.delete_ind = 'N')
         
      -- All images (not attached to radiology orders) for a given rendering provider
      INSERT INTO  #active_paq  
     SELECT 'I' As 'Item Type',i.image_id, e.rendering_provider_id as provider_id,e.enc_id, i.image_desc As 'Item Name', i.created_by AS created_by,i.modified_by AS modified_by, i.create_timestamp as 'CreateDate',i.modify_timestamp AS modifyDate, i.person_id,NULL
      FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
      INNER JOIN [10.183.0.94].NGProd.dbo.patient_images i 
        with (nolock)  ON e.enterprise_id = i.enterprise_id
          AND e.practice_id = i.practice_id 
          AND e.enc_id = i.enc_id 
          AND e.enterprise_id = @pi_enterprise_id 
          AND e.practice_id = @pi_practice_id  
        --  AND e.rendering_provider_id = @pi_provider_id 
		AND e.rendering_provider_id IS NOT NULL --add
          AND i.signoff_status = @pi_signoff_status 
          AND i.paq_provider_id IS NULL
      WHERE NOT EXISTS (SELECT 1 FROM [10.183.0.94].NGProd.dbo.lab_results_obx x 
                              WHERE x.enterprise_id = e.enterprise_id 
                                  AND x.practice_id = e.practice_id 
                                  AND x.person_id = e.person_id 
                                  AND x.obs_id = '[{Image}]' 
                                  AND x.observ_value = cast(i.image_id as varchar(36)) 
                                  AND x.delete_ind = 'N')
 END
   
ELSE
   
   BEGIN
   -- Use Encounter Provider
       SELECT 
			'I' As 'Item Type'
			,i.image_id
			, e.rendering_provider_id as provider_id
			,e.enc_id
			, i.image_desc As 'Item Name'
			, i.created_by AS created_by
			,i.modified_by AS modified_by
			, i.create_timestamp as 'CreateDate'
			,i.modify_timestamp AS modifyDate
			, i.person_id
			,NULL
       FROM patient_encounter e 
       INNER JOIN [10.183.0.94].NGProd.dbo.patient_images i 
       with (nolock)   ON e.enterprise_id = i.enterprise_id
       AND e.practice_id = i.practice_id 
       AND e.enc_id = i.enc_id 
       AND e.enterprise_id = @pi_enterprise_id 
       AND e.practice_id = @pi_practice_id 
        -- AND e.rendering_provider_id = @pi_provider_id 
		AND e.rendering_provider_id IS NOT NULL --add
        AND i.signoff_status = @pi_signoff_status 
        AND i.paq_provider_id IS NULL
   END
END
 


-- ICS Images
IF @pi_use_ics_flag = 1 
BEGIN
-- Reassigned
	INSERT INTO  #active_paq 
	SELECT 'S' As 'Item Type',i.ics_image_id, i.provider_id as provider_id,i.enc_id,
        CASE 
           WHEN d.description = ''    THEN t.description
           WHEN d.description IS NULL THEN t.description
           ELSE d.description
        END As 'Item Name', i.created_by AS created_by,i.modified_by AS modified_by, i.create_timestamp as 'CreateDate',i.modify_timestamp AS modifyDate, i.person_id,NULL
  FROM [10.183.0.94].NGProd.dbo.patient_ics_images i 
  INNER JOIN [10.183.0.94].NGProd.dbo.document d 
  WITH (nolock)  ON d.document_id = i.document_id
	AND d.practice_id = i.practice_id
	and d.enterprise_id = i.enterprise_id 
	AND i.signoff_status = @pi_signoff_status
	AND i.enterprise_id = @pi_enterprise_id
	AND i.practice_id = @pi_practice_id
   -- AND i.provider_id = @pi_provider_id 
	AND i.provider_id IS NOT NULL --add
	AND d.delete_ind = 'N' 
  INNER JOIN [10.183.0.94].NGProd.dbo.doc_type_mstr t 
	with (nolock)  ON t.doc_type_id = d.doc_type_id 
    AND t.delete_ind = 'N' 
  INNER JOIN [10.183.0.94].NGProd.dbo.page g 
   with (nolock)  ON g.document_id = d.document_id 
    AND g.sequence_nbr = 1 
  INNER JOIN [10.183.0.94].NGProd.dbo.person p 
   with (nolock)  ON p.person_id = i.person_id
   LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.patient_encounter e 
   with (nolock)  ON e.enc_id = i.enc_id and e.practice_id = i.practice_id
 
INSERT INTO  #active_paq 
SELECT 
	'S' As 'Item Type'
	,i.ics_image_id
	,e.rendering_provider_id as provider_id
	,i.enc_id,
        CASE 
           WHEN d.description = ''    THEN t.description
           WHEN d.description IS NULL THEN t.description
           ELSE d.description
        END As 'Item Name', i.created_by AS created_by,i.modified_by AS modified_by, i.create_timestamp as 'CreateDate',i.modify_timestamp AS modifyDate, i.person_id,NULL
   FROM [10.183.0.94].NGProd.dbo.patient_ics_images i 
   INNER JOIN [10.183.0.94].NGProd.dbo.document d 
   with (nolock)  ON d.document_id = i.document_id
    AND d.practice_id = i.practice_id
    and d.enterprise_id = i.enterprise_id 
    AND i.signoff_status = @pi_signoff_status
    AND i.enterprise_id = @pi_enterprise_id
    AND i.practice_id = @pi_practice_id
    AND d.delete_ind = 'N' 
  INNER JOIN [10.183.0.94].NGProd.dbo.doc_type_mstr t 
    with (nolock) ON t.doc_type_id = d.doc_type_id 
    AND t.delete_ind = 'N' 
  INNER JOIN [10.183.0.94].NGProd.dbo.page g 
   with (nolock)  ON g.document_id = d.document_id 
    AND g.sequence_nbr = 1 
  INNER JOIN [10.183.0.94].NGProd.dbo.person p 
   WITH (nolock)   ON p.person_id = i.person_id
   LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.patient_encounter e 
    with (nolock) ON e.enc_id = i.enc_id 
     AND e.practice_id = i.practice_id
  WHERE i.provider_id IS NULL
    -- AND e.rendering_provider_id = @pi_provider_id 
	AND e.rendering_provider_id IS NOT NULL --add

END

  
-- Patient Lab Results
IF @pi_signoff_status = 'R'
   SELECT @pi_use_labs_flag = 0
 
IF @pi_use_labs_flag = 1 
BEGIN 
 
   -- Create and Populate @lab_flag table variable so don't have to do function call
   CREATE table #lab_flag 
   (abnorm_flags char(2) not null, result char(1) not null)
 
   insert into #lab_flag values ('HH' , 5 )
   insert into #lab_flag values ( '>'  , 5 )
   insert into #lab_flag values ( 'H'  , 4 )
   insert into #lab_flag values ( 'LL' , 3 )
   insert into #lab_flag values ( 'L'  , 3 )
   insert into #lab_flag values ( '<'  , 3 )
   insert into #lab_flag values ( 'AA' , 2 )
   insert into #lab_flag values ( 'A'  , 2 )
   insert into #lab_flag values ( 'I'  , 2 )
   insert into #lab_flag values ( 'U'  , 2 )
   insert into #lab_flag values ( 'D'  , 2 )
   insert into #lab_flag values ( 'B'  , 2 )
   insert into #lab_flag values ( 'W'  , 2 )
   insert into #lab_flag values ( 'R'  , 2 )
   insert into #lab_flag values ( 'N'  , 1 )
 


   -- Reassigned
  -- INSERT INTO  #active_paq 
  ;WITH labDublicate AS(
   SELECT 'L' As 'Item Type',l.order_num, l.paq_provider_id as provider_id, e.enc_id,l.test_desc as 'Item Name',l.created_by,l.modified_by , l.create_timestamp as 'CreateDate',l.modify_timestamp, e.person_id
   ,	 x.abnorm_flags,
	 (SELECT  
		 CASE  ISNULL(x.abnorm_flags,'NULL')
			  WHEN '>' THEN 1
			  WHEN 'HH' THEN 2
			  WHEN 'H'  THEN 3 
			  WHEN '<' THEN 4
			  WHEN 'LL' THEN 5
			  WHEN 'L' THEN 6
			  WHEN 'AA' THEN 7
			  WHEN 'A' THEN 8
			  WHEN 'W' THEN 9
			  WHEN 'U' THEN 10
			  WHEN 'D' THEN 11
			  WHEN 'R' THEN 12
			  WHEN 'I' THEN 13
			  WHEN 'B' THEN 14
			  WHEN  'NULL' THEN 16
			  ELSE 15 
		 END) 
			AS [Range]
     FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
     INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor l 
      with (nolock) ON  e.enc_id = l.enc_id
       AND e.practice_id = l.practice_id
       AND e.enterprise_id= l.enterprise_id
       AND e.practice_id = @PI_practice_id 
       AND e.enterprise_id = @PI_enterprise_id 
     --  AND l.paq_provider_id = @PI_provider_id 
	 AND l.paq_provider_id IS NOT NULL --add
       AND l.ngn_status = 'Assigned' 
       AND l.order_type = 'L' 
       AND l.delete_ind = 'N'
     LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obr_p r 
      with (nolock) ON l.order_num = r.ngn_order_num 
     LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obx x 
     with (nolock)  ON r.unique_obr_num = x.unique_obr_num 
     LEFT OUTER JOIN #lab_flag lt 
       ON x.abnorm_flags = lt.abnorm_flags  
      GROUP BY e.person_id, e.enc_id, 
          e.enc_timestamp, l.order_num,
          l.test_desc,
          l.created_by, l.create_timestamp, 
          l.modified_by, l.modify_timestamp,
          l.create_timestamp_tz, l.modify_timestamp_tz,
          e.enc_timestamp_tz,l.paq_provider_id,x.abnorm_flags
		   ) 
		   INSERT INTO #labPAQ
		SELECT l.*, ROW_NUMBER() OVER (PARTITION BY l.order_num ORDER BY l.Range ASC) AS rank  FROM labDublicate l
 
   -- Use Ordering Provider
   IF @pi_provider_type = 'O' 
   BEGIN
     -- INSERT INTO  #active_paq 
	 ;WITH labDublicate AS(
    SELECT 'L' As 'Item Type',l.order_num, l.ordering_provider as provider_id, e.enc_id,l.test_desc as 'Item Name',l.created_by,l.modified_by , l.create_timestamp as 'CreateDate',l.modify_timestamp, e.person_id
	 ,	 x.abnorm_flags,
	 (SELECT  CASE  ISNULL(x.abnorm_flags,'NULL')
	  WHEN '>' THEN 1
	  WHEN 'HH' THEN 2
	  WHEN 'H'  THEN 3 
	  WHEN '<' THEN 4
	  WHEN 'LL' THEN 5
	  WHEN 'L' THEN 6
	  WHEN 'AA' THEN 7
	  WHEN 'A' THEN 8
	  WHEN 'W' THEN 9
	  WHEN 'U' THEN 10
	  WHEN 'D' THEN 11
	  WHEN 'R' THEN 12
	  WHEN 'I' THEN 13
      WHEN 'B' THEN 14
	  WHEN  'NULL' THEN 16
	 ELSE 15 END) as [Range]
        FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
       INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor l 
          ON e.enc_id = l.enc_id
          and e.practice_id = l.practice_id
          and e.enterprise_id= l.enterprise_id
         AND e.practice_id = @PI_practice_id 
         and e.enterprise_id = @PI_enterprise_id 
        -- AND l.ordering_provider = @pi_provider_id 
		AND l.ordering_provider IS NOT NULL --add
         AND l.ngn_status = 'Assigned' 
         AND l.order_type = 'L' 
         AND l.delete_ind = 'N'
         LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obr_p r 
        with (nolock)  ON l.order_num = r.ngn_order_num 
        LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obx x 
        with (nolock)  ON r.unique_obr_num = x.unique_obr_num 
        LEFT OUTER JOIN #lab_flag lt 
        with (nolock)  ON x.abnorm_flags = lt.abnorm_flags
     WHERE l.paq_provider_id IS NULL 
        GROUP BY e.person_id, e.enc_id, 
             e.enc_timestamp, l.order_num,
             l.test_desc,
             l.created_by, l.create_timestamp, 
             l.modified_by, l.modify_timestamp,
             l.create_timestamp_tz, l.modify_timestamp_tz,
             e.enc_timestamp_tz,l.ordering_provider,x.abnorm_flags
			   ) 
			INSERT INTO #labPAQ
		SELECT l.*, ROW_NUMBER() OVER (PARTITION BY l.order_num ORDER BY l.Range ASC) AS rank  FROM labDublicate l
   END
   ELSE
   BEGIN
   -- Use Encounter Provider
     -- INSERT INTO  #active_paq 
	 ;WITH labDublicate AS(
   SELECT 'L' As 'Item Type',l.order_num, e.rendering_provider_id as provider_id, e.enc_id,l.test_desc as 'Item Name',l.created_by,l.modified_by , l.create_timestamp as 'CreateDate',l.modify_timestamp, e.person_id
    ,	 x.abnorm_flags,
	 (SELECT  CASE  ISNULL(x.abnorm_flags,'NULL')
	  WHEN '>' THEN 1
	  WHEN 'HH' THEN 2
	  WHEN 'H'  THEN 3 
	  WHEN '<' THEN 4
	  WHEN 'LL' THEN 5
	  WHEN 'L' THEN 6
	  WHEN 'AA' THEN 7
	  WHEN 'A' THEN 8
	  WHEN 'W' THEN 9
	  WHEN 'U' THEN 10
	  WHEN 'D' THEN 11
	  WHEN 'R' THEN 12
	  WHEN 'I' THEN 13
      WHEN 'B' THEN 14
	  WHEN  'NULL' THEN 16
	 ELSE 15 END) as [Range]
        FROM [10.183.0.94].NGProd.dbo.patient_encounter e 
       INNER JOIN [10.183.0.94].NGProd.dbo.lab_nor l 
        with (nolock)  ON e.enc_id = l.enc_id
          and e.practice_id = l.practice_id
          and e.enterprise_id= l.enterprise_id 
         and  e.enterprise_id = @pi_enterprise_id 
         AND e.practice_id = @pi_practice_id 
       --  AND e.rendering_provider_id = @pi_provider_id 
	   AND e.rendering_provider_id IS NOT NULL --add
           AND l.ngn_status = 'Assigned' 
           AND l.order_type = 'L' 
         AND l.delete_ind = 'N'
        LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obr_p r 
        with (nolock)  ON l.order_num = r.ngn_order_num 
        LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obx x 
        with (nolock)  ON r.unique_obr_num = x.unique_obr_num 
       LEFT OUTER JOIN #lab_flag lt 
       with (nolock)   ON x.abnorm_flags = lt.abnorm_flags
     WHERE l.paq_provider_id IS NULL 
         GROUP BY e.person_id, e.enc_id, 
             e.enc_timestamp, l.order_num,
             l.test_desc,
             l.created_by, l.create_timestamp, 
             l.modified_by, l.modify_timestamp,
             l.create_timestamp_tz, l.modify_timestamp_tz,
             e.enc_timestamp_tz,e.rendering_provider_id,x.abnorm_flags
			   ) 
		INSERT INTO #labPAQ
		SELECT l.*, ROW_NUMBER() OVER (PARTITION BY l.order_num ORDER BY l.Range ASC) AS rank   FROM labDublicate l
   END
END -- Labs
 
 --insert into active PAQ lab
  INSERT INTO  #active_paq 
	  SELECT 
	   [Item Type]
      ,[order_num]
      ,[provider_id]
      ,[enc_id]
      ,[Item Name]
      ,[created_by]
      ,[modified_by]
      ,[CreateDate]
      ,[modify_timestamp]
      ,[person_id]
      ,[abnorm_flags]
      FROM #labPAQ WHERE rank=1



--copy all signoffPAQ  to temp table
SELECT * INTO #temp_signoffPAQ FROM [10.183.0.94].NGProd.dbo.paq_signoff_history   h
--WHERE  h.item_id NOT IN(SELECT DISTINCT p.[Item ID]  FROM #active_paq p) --bring all the signoff PAQ even if they are still active


--bring all signoff PAQ creation ,modification date 
;WITH   signOffPAQ AS(
SELECT h.*,
d.create_timestamp AS d_create_time,
--d.modify_timestamp AS d_modify_time,
--n.create_timestamp AS n_create_time,n.modify_timestamp AS n_modify_time,
ics.create_timestamp AS ics_create_time,
--ics.modify_timestamp AS ics_modify_time,
l.create_timestamp AS l_create_time,
--l.modify_timestamp AS l_modify_time,lt.abnorm_flags,lt.result
     x.abnorm_flags,
	  (SELECT  CASE  ISNULL(x.abnorm_flags,'NULL')
	  WHEN '>' THEN 1
	  WHEN 'HH' THEN 2
	  WHEN 'H'  THEN 3 
	  WHEN '<' THEN 4
	  WHEN 'LL' THEN 5
	  WHEN 'L' THEN 6
	  WHEN 'AA' THEN 7
	  WHEN 'A' THEN 8
	  WHEN 'W' THEN 9
	  WHEN 'U' THEN 10
	  WHEN 'D' THEN 11
	  WHEN 'R' THEN 12
	  WHEN 'I' THEN 13
      WHEN 'B' THEN 14
	  WHEN  'NULL' THEN 16
	 ELSE 15 END) as [Range]
 FROM #temp_signoffPAQ h 
LEFT OUTER JOIN  [10.183.0.94].NGProd.dbo.patient_documents d with (nolock) ON h.item_id=d.document_id
--LEFT JOIN  [10.183.0.94].NGProd.dbo.patient_notes n ON h.item_id=n.note_id
--LEFT JOIN  [10.183.0.94].NGProd.dbo.patient_images i ON h.item_id=i.image_id
LEFT OUTER JOIN  [10.183.0.94].NGProd.dbo.patient_ics_images ics with (nolock) ON h.item_id=ics.document_id
LEFT OUTER  JOIN [10.183.0.94].NGProd.dbo.lab_nor l with (nolock) ON  h.item_id=l.order_num
  LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obr_p r   with (nolock)  ON l.order_num = r.ngn_order_num 
        LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.lab_results_obx x   with (nolock)  ON r.unique_obr_num = x.unique_obr_num 

)SELECT q.*, ROW_NUMBER() OVER (PARTITION BY q.item_id ORDER BY q.Range ASC) AS rank INTO #temp_all_signoffPAQ  FROM signOffPAQ q



--union all active PAQ and SignOff PAQ
SELECT x.*  INTO #data_PAQ
  FROM (select    
               [item_type]
			  ,[item_id]
			  ,[provider_id]
			  ,[person_id]
			  ,[enc_id]
			  ,[item_name]
			  ,[created_by]
			  ,[modified_by]
			  ,[signoff_user_id]
			  ,[signoff_action]
			  ,[signoff_desc]
			  ,[reassigned_provider_id]
			  ,[create_timestamp] 
			  ,[modify_timestamp] 
              ,0 AS [active]
			  ,d_create_time
			  ,ics_create_time
			  ,l_create_time
			  ,abnorm_flags
	   FROM #temp_all_signoffPAQ WHERE rank=1 AND item_type='L'
	    UNION  ALL
		select    
               [item_type]
			  ,[item_id]
			  ,[provider_id]
			  ,[person_id]
			  ,[enc_id]
			  ,[item_name]
			  ,[created_by]
			  ,[modified_by]
			  ,[signoff_user_id]
			  ,[signoff_action]
			  ,[signoff_desc]
			  ,[reassigned_provider_id]
			  ,[create_timestamp] 
			  ,[modify_timestamp] 
              ,0 AS [active]
			  ,d_create_time
			  ,ics_create_time
			  ,l_create_time
			  ,abnorm_flags
	   FROM #temp_all_signoffPAQ WHERE (item_type!='L')
		UNION ALL 
		 SELECT  [Item Type]
		  ,[Item ID]
		  ,[provider_id]
		   ,[person_id]
		  ,[enc_id]
		  ,[Item Name]
		  ,[created_by] 
		  ,[modified_by]
		  ,NULL
		  ,NULL
		  ,NULL
		  ,NULL
		  ,[CreateDate]
		  ,[modifyDate]
		  ,1 AS active
		  ,NULL
		  ,NULL
		  ,NULL
		  ,abnorm_flags
	  FROM #active_paq
	  ) x  ORDER BY x.[create_timestamp]
		
		--**DQ** Was taking up lots of memory by failing to drop lg temp tables
		DROP TABLE  #active_paq
		DROP TABLE  #temp_all_signoffPAQ

---modify PAQ table
select q.[item_type]
      ,q.[item_id]
      ,q.[provider_id]
      ,q.[person_id]
      ,q.[enc_id]
      ,q.[item_name]
      ,q.[created_by]
      ,q.[modified_by]
      ,q.[signoff_user_id]
      ,q.[signoff_action]
      ,q.[signoff_desc]
      ,q.[reassigned_provider_id]
      ,q.[modify_timestamp]
	  ,CASE ISNULL(q.abnorm_flags,'NULL')
		  WHEN 'HH' THEN 'Above upper panic level'  
		  WHEN 'H'  THEN 'Above high normal' 
		  WHEN '<' THEN 'Below absolute low, off low scale on instrumen'
		  WHEN 'LL' THEN 'Below lower panic limits'
		  WHEN 'L' THEN ' Below low normal'
		  WHEN 'AA' THEN 'Very abnormal'
		  WHEN 'A' THEN 'Abnormal  - for non-numeric results'
		  WHEN 'W' THEN 'Worse'
		  WHEN 'U' THEN 'Significant change up'
		  WHEN 'D' THEN ' Significant change down'
		  WHEN 'R' THEN 'Resistant'
		  WHEN 'I' THEN 'Intermediate'
		  WHEN 'B' THEN 'Better'
		  WHEN 'NULL' THEN 'No Lab Flag Description'
		  ELSE q.abnorm_flags
       END AS [Lab Flag Description]
	   ,q.abnorm_flags
	  ,CASE when q.active=0 THEN  CAST(q.[create_timestamp] AS DATE) END AS [signoffdate]
	  ,CASE when q.active=0 THEN  CAST(q.[create_timestamp] AS DATE) END AS [signoff_timestamp]
	  ,CASE 
			WHEN q.active=1 THEN q.[create_timestamp] 
		    WHEN q.active=1 AND EXISTS(SELECT TOP 1 x.item_id FROM  #data_PAQ x WHERE x.item_id=q.item_id AND q.signoff_action='A')  THEN q.modify_timestamp
			ELSE
            case
				WHEN ISDATE(q.[d_create_time])=1  THEN q.[d_create_time]
				WHEN ISDATE(q.[ics_create_time])=1 THEN  q.[ics_create_time]
				WHEN ISDATE(q.[l_create_time])=1 THEN q.[l_create_time]
			end
       END AS [Item Creation Date]
	   ,CASE 
			WHEN q.active=1 AND ISDATE(q.[create_timestamp])=1 THEN (CAST(CONVERT(CHAR(6),q.[create_timestamp] , 112) + '01' AS DATE))
			WHEN q.active=1 AND  EXISTS(SELECT TOP 1 x.item_id FROM  #data_PAQ x WHERE x.item_id=q.item_id AND q.signoff_action='A')  THEN (CAST(CONVERT(CHAR(6),q.modify_timestamp , 112) + '01' AS DATE))
			ELSE
            case
				WHEN ISDATE(q.[d_create_time])=1  THEN  (CAST(CONVERT(CHAR(6),q.[d_create_time], 112) + '01' AS DATE))
				WHEN ISDATE(q.[ics_create_time])=1 THEN  (CAST(CONVERT(CHAR(6),q.[ics_create_time] , 112) + '01' AS DATE))
				WHEN ISDATE(q.[l_create_time])=1 THEN  (CAST(CONVERT(CHAR(6),q.[l_create_time] , 112) + '01' AS DATE))
			end
       END AS paq_first_mon_date
	  ,q.[active]
	  ,CASE WHEN q.active=0 AND q.signoff_action='R' THEN 1  ELSE 0 END AS nbr_PAQ_Rejected
	  ,CASE WHEN q.active=0  AND q.signoff_action='E' THEN 1 ELSE 0 END AS nbr_PAQ_Reassigned
	 ,case WHEN q.active=0 AND  um.provider_id = q.provider_id then  1 else 0 end as nbr_PAQ_by_Provider
     ,case WHEN q.active=0 AND  um.provider_id != q.provider_id then  1 else 0 end as nbr_PAQ_by_Covering_Provider
	 ,case when enc_id is not null then 1 else 0 end as nbr_Realted_to_encounter_flg
	 ,case when q.active=0 and reassigned_provider_id is not null then 1 else 0 end as nbr_PAQ_Reassigned_to_dif_Provider_flg
	INTO #data_PAQ_final
	FROM  #data_PAQ q 
	left join  [10.183.0.94].NGProd.dbo.user_mstr um  with (nolock)  ON q.created_by = um.user_id 
   

  DROP TABLE #data_PAQ

--create DWH PAQ  table
 SELECT q.[item_type]
      ,q.[item_id]
	  ,person_nd.med_rec_nbr 
      ,provider.provider_key
      ,person_nd.per_mon_id
	  ,person_nd.[first_mon_date]
      ,data_appointment.enc_appt_key
	  ,paq_provider.provider_key AS [PAQ_provider_key]
	  ,reassigned_paq_provider.provider_key AS [PAQ_reassigned_provider_key]
	  ,u.user_key 
      ,q.[item_name]
      ,q.[created_by]
      ,q.[modified_by]
      ,q.[signoff_user_id]
      ,q.signoff_action
      ,q.[signoff_desc]
      ,q.[reassigned_provider_id]
      ,q.[modify_timestamp]
      ,q.[signoffdate]
      ,q.[signoff_timestamp]
      ,q.[Item Creation Date]
      ,CAST(DATEDIFF(MINUTE, q.[Item Creation Date],q.modify_timestamp) AS decimal )/(60) AS HourstoCompeletion
	  ,CAST(DATEDIFF(MINUTE,q.[Item Creation Date],q.modify_timestamp) AS decimal)/(24*60)  AS DaystoCompeletion
      ,q.[active]
      ,q.[nbr_PAQ_by_Provider]
      ,q.[nbr_PAQ_by_Covering_Provider]
      ,q.[nbr_Realted_to_encounter_flg]
      ,q.[nbr_PAQ_Reassigned_to_dif_Provider_flg]
	  ,q.nbr_PAQ_Rejected
	  ,q.nbr_PAQ_Reassigned
	  ,q.[Lab Flag Description]
	  ,q.abnorm_flags AS [Lab Flag]
	  INTO dbo.data_paq
	  FROM #data_PAQ_final q
	  LEFT OUTER JOIN  dbo.[data_person_nd_month] person_nd with (nolock) ON (person_nd.person_id = q.person_id  AND q.paq_first_mon_date=person_nd.[first_mon_date])
	  LEFT OUTER JOIN  dbo.[data_appointment] data_appointment  with (nolock) ON  data_appointment.[enc_id]=q.[enc_id]
	  LEFT OUTER JOIN dbo.[data_provider] provider with (nolock) ON provider.provider_id = q.provider_id
	  LEFT OUTER JOIN dbo.data_user_v2 u WITH(nolock) ON u.user_id=q.signoff_user_id
      LEFT OUTER JOIN dbo.data_provider paq_provider WITH(NOLOCK) ON paq_provider.provider_id = q.provider_id
	  LEFT OUTER JOIN dbo.data_provider reassigned_paq_provider  WITH(NOLOCK) ON reassigned_paq_provider.provider_id = q.reassigned_provider_id

	  drop TABLE #data_PAQ_final

END
GO
