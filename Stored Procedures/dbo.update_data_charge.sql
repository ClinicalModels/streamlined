SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_charge]
AS
 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        IF OBJECT_ID('dbo.data_charge') IS NOT NULL
            DROP TABLE dbo.data_charge;
        IF OBJECT_ID('tempdb..#ersims') IS NOT NULL
            DROP TABLE #ersims;


--Get Self pay, FQHC, and Sliding scale fee charges
--Will need to add this to the charges information to charges table as a concatenated key



--This grabs the sevice item IDs and and also the encounter
             
                SELECT DISTINCT
                        r.encounter_rate_sim AS sim_code
				
          INTO #ersims
				FROM    [10.183.0.94].NGProd.dbo.encounter_billing_rates r
							INNER JOIN [10.183.0.94].NGProd.dbo.library_mstr l ON r.enc_rate_billing_lib_id = l.library_id
							INNER JOIN [10.183.0.94].NGProd.dbo.practice_payers pp ON r.enc_rate_billing_lib_id = pp.enc_rate_billing_lib_id
							INNER JOIN [10.183.0.94].NGProd.dbo.payer_mstr p ON pp.payer_id = p.payer_id;



     ----bringing nessary keys

        SELECT  IDENTITY( INT, 1, 1 ) AS chg_key,
		        enc.enc_id ,
                enc.enc_key ,
                chg.source_id ,
                enc.enc_bill_date ,
                chg.[begin_date_of_service] ,
                er.sim_code,
  
                CASE 
					WHEN chg.link_id IS  NULL THEN 'Non-Void Charge'
                     ELSE 'Void Charge'
                END 
					AS charge_void_status ,
                chg.status ,
                chg.charge_id ,
                chg.service_item_id AS service_item_id ,
                chg.[cpt4_code_id] ,
				--Function checks CPT for uds medical visit criteria
				dbo.uds_med_visit_eval(chg.cpt4_code_id)
					AS uds_med_visit_cpt,
                [icd9cm_code_id] ,
                [icd9cm_code_id_2] ,
                [icd9cm_code_id_3] ,
                [icd9cm_code_id_4] ,
                override_ind ,
                chg.created_by AS user_charge_created ,
                chg.closing_date AS chg_closing_date ,
                CASE WHEN chg.closing_date IS NULL THEN 'Not closed'
                     ELSE 'Charge closed'
                END AS Charge_Status ,
                chg.modify_timestamp AS chg_mod_date ,
                [zero_bal_date] ,
                [credit_date] ,
                t.Txn_closing_date ,
                t.Txn_batch_date ,
                t.Txn_override_closing_date ,
                t.Txn_post_date ,
                
				--Some issues with overides on closing date-- old closing date will be put into 
				
				days_chg_close_to_txn_close = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                        OR ISNULL(t.Txn_closing_date, 0) = 0 THEN 0
                                                   WHEN t.Txn_closing_date < chg.closing_date THEN 0
                                                   ELSE DATEDIFF(dd, CAST(chg.closing_date AS DATETIME),
                                                                 CAST(t.Txn_closing_date AS DATETIME))
                                              END ,
                days_chg_close_to_txn_post = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                       OR ISNULL(Txn_post_date, 0) = 0 THEN 0
                                                  WHEN Txn_post_date < chg.closing_date THEN 0
                                                  ELSE DATEDIFF(dd, CAST(chg.closing_date AS DATETIME),
                                                                CAST(Txn_post_date AS DATETIME))
                                             END ,
                days_chg_close_to_txn_batch = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                        OR ISNULL(t.Txn_batch_date, 0) = 0 THEN 0
                                                   WHEN t.Txn_batch_date < chg.closing_date THEN 0
                                                   ELSE DATEDIFF(dd, CAST(chg.closing_date AS DATETIME),
                                                                 CAST(t.Txn_batch_date AS DATETIME))
                                              END ,
                days_txn_batch_to_txn_post = CASE WHEN ISNULL(t.Txn_batch_date, 0) = 0
                                                       OR ISNULL(t.Txn_post_date, 0) = 0 THEN 0
                                                  WHEN t.Txn_post_date < t.Txn_batch_date THEN 0
                                                  ELSE DATEDIFF(dd, CAST(t.Txn_batch_date AS DATETIME),
                                                                CAST(t.Txn_post_date AS DATETIME))
                                             END ,
                days_enc_bill_to_chg_close = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                  OR ISNULL(enc.enc_bill_date, '') = '' THEN 0
                                             WHEN CAST(chg.closing_date AS DATE) < CAST(enc.enc_bill_date AS DATE)
                                             THEN 0
                                             ELSE DATEDIFF(dd, CAST(enc.enc_bill_date AS DATETIME),
                                                           CAST(chg.closing_date AS DATETIME))
                                        END ,
                all_void_and_non_void_charge_amt = chg.amt ,
                cob1_amt = ISNULL(chg.cob1_amt, 0.00) ,
                cob2_amt = ISNULL(chg.cob2_amt, 0.00) ,
                cob3_amt = ISNULL(chg.cob3_amt, 0.00) ,
                pat_amt = ISNULL(chg.pat_amt, 0.00) ,
                CASE WHEN chg.link_id IS  NULL THEN chg.amt
                     ELSE 0
                END AS non_void_charge_amt ,
                CASE WHEN er.sim_code IS NULL
                          AND chg.link_id IS  NULL THEN chg.amt
                END AS non_enc_rate_charge_amt ,
                CASE WHEN er.sim_code IS NULL
                          AND chg.link_id IS  NULL THEN chg.amt
                END AS enc_rate_charge_amt
        INTO    dbo.data_charge
        FROM    [10.183.0.94].NGProd.dbo.charges chg
                INNER JOIN dbo.data_encounter enc ON enc.enc_id = chg.source_id
                                                     AND enc.person_id = chg.person_id
                LEFT JOIN ( SELECT td.charge_id ,
                                    MAX(t.closing_date) AS Txn_closing_date ,
                                    MAX(t.post_date) AS Txn_post_date ,
                                    MAX(t.batch_date) AS Txn_batch_date ,
                                    MAX(t.override_closing_date) AS Txn_override_closing_date
                             FROM   [10.183.0.94].NGProd.dbo.charges chg
                                    INNER JOIN [10.183.0.94].NGProd.dbo.trans_detail td ON chg.charge_id = td.charge_id --this table keeps the detail of the charges 
                                    INNER JOIN [10.183.0.94].NGProd.dbo.transactions t ON td.trans_id = t.trans_id --this table keeps all the insurance information
                             GROUP BY td.charge_id
                           ) t ON chg.charge_id = t.charge_id
                LEFT JOIN #ersims er ON chg.service_item_id = er.sim_code;
        



		--Now build transaction table
        --include transaction code ID as a dimension -- might need to subgroup based on sliding scale and contracts and include adjustment categories and credit
		--include a dimension that has post_ind and whether join to contract to get name of contract
		--needs to be a left to join to perserve for transations to charges to account for unapplied -- may need to create a key for that and categorize as unapplied
		--unapplied and not sure how to deal with self pay -- may need direct relationship to encounter table as this would allow for encounters that have transactions but no associated charges


	
 END;
GO
