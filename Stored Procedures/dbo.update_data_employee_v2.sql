SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_employee_v2]
AS
    BEGIN
	--dependent on fe account table



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        IF OBJECT_ID('dwh.data_employee_v2') IS NOT NULL
            DROP TABLE dwh.data_employee_v2;

        IF OBJECT_ID('dwh.data_employee_payroll_scd') IS NOT NULL
            DROP TABLE dwh.data_employee_payroll_scd;
    
        IF OBJECT_ID('fdt.[Fact Employee Census Payroll]') IS NOT NULL
            DROP TABLE  fdt.[Fact Employee Census Payroll];
                  
        IF OBJECT_ID('fdt.[Dim Employee Cur]') IS NOT NULL
            DROP TABLE  fdt.[Dim Employee Cur];
    		
        IF OBJECT_ID('fdt.[Dim Employee Hx]') IS NOT NULL
            DROP TABLE  fdt.[Dim Employee Hx];
    		 


--Prep AD information
--A name with multiple associated e-mails will have multiple row numbers
SELECT *,
 rownum=ROW_NUMBER() OVER (PARTITION BY ad.lastName,ad.firstName ORDER BY ad.email)
 INTO #AD1
 FROM
 [Prod_Ghost].[dwh].[data_active_directory] ad

		--First, employee table is built based off information from the payroll table
        SELECT DISTINCT
                IDENTITY( INT, 1, 1 )  AS employee_key ,
                ar.[File Number] ,
                [Location] ,
                [Location Code] ,
                [Current Status] ,
                [Hire Date] ,
                [Termination Date] ,
                [Termination Reason] ,
                [Termination Reason Code] ,
                [Job Title] ,
                [Payroll First Name] ,
                [Home Cost Number - Check] ,
                [Payroll Last Name] ,
                [Payroll Name] ,
                [Birth Date] ,
                [Gender] ,
                [EEO Ethnic Code] ,
                [Zip/Postal Code] ,
                [Manager First Name] ,
                [Manager Last Name] ,
                [Manager ID] ,
                [Standard Hours] ,
                [Hourly Rate ADP 1 (Direct hourly)] ,
                [Hourly Rate 2 ADP (Direct-biweekly salary)] ,
                [Hourly Rate ADP (Based on ADP Salary or Hourly)] ,
                [Annual Salary ADP not annualized] ,
                [Annual Salary ADP annualized] ,
                [UDS Table 5 Staffing Category ] ,
                [UDS Table 5 Line Number ] ,
                [UDS Table 8 Costs Category ] ,
                [UDS Table 8 Line Number ] ,
                [cn_account_code_cur] ,
                [cn_account_code_sub_cur] ,
                [cn_site_cur] ,
                [cn_fund_cur] ,
                [cn_dir_indir_cur] ,
                [cn_category_cur] ,
                [cn_proj_grant_cur] ,
                [Data Control] ,

					
				    CASE WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 5 THEN '$1-4 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 10 THEN '$5-9 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 15 THEN '$10-14 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 20 THEN '$15-19 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 25 THEN '$20-24 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 30 THEN '$25-29 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 35 THEN '$30-34 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 40 THEN '$35-39 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 45 THEN '$40-44 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 50 THEN '$45-49 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 55 THEN '$50-54 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 60 THEN '$55-59 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 65 THEN '$60-64 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 70 THEN '$65-69 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 75 THEN '$70-74 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 80 THEN '$75-79 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 85 THEN '$80-84 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 90 THEN '$85-89 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 95 THEN '$90-94 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 100 THEN '$95-99 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 105 THEN '$100-104 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 110 THEN '$105-109 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 115 THEN '$110-114 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 120 THEN '$115-119 /hr'
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] >= 120 THEN '>=$120 /hr'
                END AS rate_range_cur ,
                CASE WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 5 THEN 1
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 10 THEN 2
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 15 THEN 3
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 20 THEN 4
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 25 THEN 5
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 30 THEN 6
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 35 THEN 7
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 40 THEN 8
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 45 THEN 9
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 50 THEN 10
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 55 THEN 11
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 60 THEN 12
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 65 THEN 13
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 70 THEN 14
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 75 THEN 15
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 80 THEN 16
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 85 THEN 17
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 90 THEN 18
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 95 THEN 19
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 100 THEN 20
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 105 THEN 21
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 110 THEN 22
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 115 THEN 23
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] < 120 THEN 24
                     WHEN [Hourly Rate ADP (Based on ADP Salary or Hourly)] >= 120 THEN 25
                END AS rate_range_cur_sort ,

                CASE WHEN [Hourly Rate ADP 1 (Direct Hourly)]< 5 THEN '$1-4 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)]< 10 THEN '$5-9 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)]< 15 THEN '$10-14 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)]< 20 THEN '$15-19 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)]< 25 THEN '$20-24 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)]< 30 THEN '$25-29 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 35 THEN '$30-34 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 40 THEN '$35-39 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 45 THEN '$40-44 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 50 THEN '$45-49 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 55 THEN '$50-54 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 60 THEN '$55-59 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 65 THEN '$60-64 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 70 THEN '$65-69 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 75 THEN '$70-74 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 80 THEN '$75-79 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 85 THEN '$80-84 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 90 THEN '$85-89 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 95 THEN '$90-94 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 100 THEN '$95-99 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 105 THEN '$100-104 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 110 THEN '$105-109 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 115 THEN '$110-114 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 120 THEN '$115-119 /hr'
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] >= 120 THEN '>=$120 /hr'
                END AS rate_direct_range_cur ,
                CASE WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 5 THEN 1
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 10 THEN 2
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 15 THEN 3
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 20 THEN 4
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 25 THEN 5
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 30 THEN 6
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 35 THEN 7
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 40 THEN 8
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 45 THEN 9
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 50 THEN 10
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 55 THEN 11
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 60 THEN 12
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 65 THEN 13
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 70 THEN 14
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 75 THEN 15
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 80 THEN 16
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 85 THEN 17
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 90 THEN 18
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 95 THEN 19
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 100 THEN 20
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 105 THEN 21
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 110 THEN 22
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 115 THEN 23
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] < 120 THEN 24
                     WHEN [Hourly Rate ADP 1 (Direct Hourly)] >= 120 THEN 25
                END AS rate_direct_range_cur_sort ,

                CASE WHEN [Annual Salary ADP annualized] < 5000 THEN '$0-4,999 /year'
                     WHEN [Annual Salary ADP annualized] < 10000 THEN '$5,000-9,000 /year'
                     WHEN [Annual Salary ADP annualized] < 20000 THEN '$10,000-19,999 /year'
                     WHEN [Annual Salary ADP annualized] < 30000 THEN '$20,000-29,999 /year'
                     WHEN [Annual Salary ADP annualized] < 40000 THEN '$30,000-39,999 /year'
                     WHEN [Annual Salary ADP annualized] < 50000 THEN '$40,000-49,999 /year'
                     WHEN [Annual Salary ADP annualized] < 60000 THEN '$50,000-59,999 /year'
                     WHEN [Annual Salary ADP annualized] < 70000 THEN '$60,000-69,999 /year'
                     WHEN [Annual Salary ADP annualized] < 80000 THEN '$70,000-79,999 /year'
                     WHEN [Annual Salary ADP annualized] < 90000 THEN '$80,000-89,999 /year'
                     WHEN [Annual Salary ADP annualized] < 100000 THEN '$90,000-99,999 /year'
                     WHEN [Annual Salary ADP annualized] < 110000 THEN '$100,000-109,999 /year'
                     WHEN [Annual Salary ADP annualized] < 120000 THEN '$110,000-119,999 /year'
                     WHEN [Annual Salary ADP annualized] < 130000 THEN '$120,000-129,999 /year'
                     WHEN [Annual Salary ADP annualized] < 140000 THEN '$130,000-139,999 /year'
                     WHEN [Annual Salary ADP annualized] < 150000 THEN '$140,000-149,999 /year'
                     WHEN [Annual Salary ADP annualized] < 160000 THEN '$150,000-159,999 /year'
                     WHEN [Annual Salary ADP annualized] < 170000 THEN '$160,000-169,999 /year'
                     WHEN [Annual Salary ADP annualized] < 180000 THEN '$170,000-179,999 /year'
                     WHEN [Annual Salary ADP annualized] < 190000 THEN '$180,000-189,999 /year'
                     WHEN [Annual Salary ADP annualized] < 200000 THEN '$190,000-199,999 /year'
                     WHEN [Annual Salary ADP annualized] < 210000 THEN '$200,000-209,999 /year'
                     WHEN [Annual Salary ADP annualized] < 220000 THEN '$210,000-219,999 /year'
                     WHEN [Annual Salary ADP annualized] < 230000 THEN '$220,000-229,999 /year'
                     WHEN [Annual Salary ADP annualized] < 240000 THEN '$230,000-239,999 /year'
                     WHEN [Annual Salary ADP annualized] < 250000 THEN '$240,000-249,999 /year'
                     WHEN [Annual Salary ADP annualized] < 260000 THEN '$250,000-259,999 /year'
                     WHEN [Annual Salary ADP annualized] < 270000 THEN '$260,000-269,999 /year'
                     WHEN [Annual Salary ADP annualized] < 280000 THEN '$270,000-279,999 /year'
                     WHEN [Annual Salary ADP annualized] < 290000 THEN '$280,000-289,999 /year'
                     WHEN [Annual Salary ADP annualized] < 300000 THEN '$290,000-299,999 /year'
                     WHEN [Annual Salary ADP annualized] < 310000 THEN '$300,000-309,999 /year'
                     WHEN [Annual Salary ADP annualized] >= 310000 THEN '>=$310,000 /year'
                END AS salary_annualized_range_cur ,
                CASE WHEN [Annual Salary ADP annualized] < 5000 THEN 1
                     WHEN [Annual Salary ADP annualized] < 10000 THEN 2
                     WHEN [Annual Salary ADP annualized] < 20000 THEN 3
                     WHEN [Annual Salary ADP annualized] < 30000 THEN 4
                     WHEN [Annual Salary ADP annualized] < 40000 THEN 5
                     WHEN [Annual Salary ADP annualized] < 50000 THEN 6
                     WHEN [Annual Salary ADP annualized] < 60000 THEN 7
                     WHEN [Annual Salary ADP annualized] < 70000 THEN 8
                     WHEN [Annual Salary ADP annualized] < 80000 THEN 9
                     WHEN [Annual Salary ADP annualized] < 90000 THEN 10
                     WHEN [Annual Salary ADP annualized] < 100000 THEN 11
                     WHEN [Annual Salary ADP annualized] < 110000 THEN 12
                     WHEN [Annual Salary ADP annualized] < 120000 THEN 13
                     WHEN [Annual Salary ADP annualized] < 130000 THEN 14
                     WHEN [Annual Salary ADP annualized] < 140000 THEN 15
                     WHEN [Annual Salary ADP annualized] < 150000 THEN 16
                     WHEN [Annual Salary ADP annualized] < 160000 THEN 17
                     WHEN [Annual Salary ADP annualized] < 170000 THEN 18
                     WHEN [Annual Salary ADP annualized] < 180000 THEN 19
                     WHEN [Annual Salary ADP annualized] < 190000 THEN 20
                     WHEN [Annual Salary ADP annualized] < 200000 THEN 21
                     WHEN [Annual Salary ADP annualized] < 210000 THEN 22
                     WHEN [Annual Salary ADP annualized] < 220000 THEN 23
                     WHEN [Annual Salary ADP annualized] < 230000 THEN 24
                     WHEN [Annual Salary ADP annualized] < 240000 THEN 25
                     WHEN [Annual Salary ADP annualized] < 250000 THEN 26
                     WHEN [Annual Salary ADP annualized] < 260000 THEN 27
                     WHEN [Annual Salary ADP annualized] < 270000 THEN 28
                     WHEN [Annual Salary ADP annualized] < 280000 THEN 29
                     WHEN [Annual Salary ADP annualized] < 290000 THEN 30
                     WHEN [Annual Salary ADP annualized] < 300000 THEN 31
                     WHEN [Annual Salary ADP annualized] < 310000 THEN 32
                     WHEN [Annual Salary ADP annualized] >= 310000 THEN 33
                END AS salary_annualized_range_cur_sort ,
                CASE WHEN [Annual Salary ADP not annualized] < 5000 THEN '$0-4,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 10000 THEN '$5,000-9,000 /year'
                     WHEN [Annual Salary ADP not annualized] < 20000 THEN '$10,000-19,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 30000 THEN '$20,000-29,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 40000 THEN '$30,000-39,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 50000 THEN '$40,000-49,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 60000 THEN '$50,000-59,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 70000 THEN '$60,000-69,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 80000 THEN '$70,000-79,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 90000 THEN '$80,000-89,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 100000 THEN '$90,000-99,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 110000 THEN '$100,000-109,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 120000 THEN '$110,000-119,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 130000 THEN '$120,000-129,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 140000 THEN '$130,000-139,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 150000 THEN '$140,000-149,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 160000 THEN '$150,000-159,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 170000 THEN '$160,000-169,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 180000 THEN '$170,000-179,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 190000 THEN '$180,000-189,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 200000 THEN '$190,000-199,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 210000 THEN '$200,000-209,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 220000 THEN '$210,000-219,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 230000 THEN '$220,000-229,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 240000 THEN '$230,000-239,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 250000 THEN '$240,000-249,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 260000 THEN '$250,000-259,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 270000 THEN '$260,000-269,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 280000 THEN '$270,000-279,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 290000 THEN '$280,000-289,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 300000 THEN '$290,000-299,999 /year'
                     WHEN [Annual Salary ADP not annualized] < 310000 THEN '$300,000-309,999 /year'
                     WHEN [Annual Salary ADP not annualized] >= 310000 THEN '>=$310,000 /year'
                END AS salary_not_annualized_range_cur ,


                CASE WHEN [Annual Salary ADP not annualized] < 5000 THEN 1
                     WHEN [Annual Salary ADP not annualized] < 10000 THEN 2
                     WHEN [Annual Salary ADP not annualized] < 20000 THEN 3
                     WHEN [Annual Salary ADP not annualized] < 30000 THEN 4
                     WHEN [Annual Salary ADP not annualized] < 40000 THEN 5
                     WHEN [Annual Salary ADP not annualized] < 50000 THEN 6
                     WHEN [Annual Salary ADP not annualized] < 60000 THEN 7
                     WHEN [Annual Salary ADP not annualized] < 70000 THEN 8
                     WHEN [Annual Salary ADP not annualized] < 80000 THEN 9
                     WHEN [Annual Salary ADP not annualized] < 90000 THEN 10
                     WHEN [Annual Salary ADP not annualized] < 100000 THEN 11
                     WHEN [Annual Salary ADP not annualized] < 110000 THEN 12
                     WHEN [Annual Salary ADP not annualized] < 120000 THEN 13
                     WHEN [Annual Salary ADP not annualized] < 130000 THEN 14
                     WHEN [Annual Salary ADP not annualized] < 140000 THEN 15
                     WHEN [Annual Salary ADP not annualized] < 150000 THEN 16
                     WHEN [Annual Salary ADP not annualized] < 160000 THEN 17
                     WHEN [Annual Salary ADP not annualized] < 170000 THEN 18
                     WHEN [Annual Salary ADP not annualized] < 180000 THEN 19
                     WHEN [Annual Salary ADP not annualized] < 190000 THEN 20
                     WHEN [Annual Salary ADP not annualized] < 200000 THEN 21
                     WHEN [Annual Salary ADP not annualized] < 210000 THEN 22
                     WHEN [Annual Salary ADP not annualized] < 220000 THEN 23
                     WHEN [Annual Salary ADP not annualized] < 230000 THEN 24
                     WHEN [Annual Salary ADP not annualized] < 240000 THEN 25
                     WHEN [Annual Salary ADP not annualized] < 250000 THEN 26
                     WHEN [Annual Salary ADP not annualized] < 260000 THEN 27
                     WHEN [Annual Salary ADP not annualized] < 270000 THEN 28
                     WHEN [Annual Salary ADP not annualized] < 280000 THEN 29
                     WHEN [Annual Salary ADP not annualized] < 290000 THEN 30
                     WHEN [Annual Salary ADP not annualized] < 300000 THEN 31
                     WHEN [Annual Salary ADP not annualized] < 310000 THEN 32
                     WHEN [Annual Salary ADP not annualized] >= 310000 THEN 33
                END AS salary_not_annualized_range_cur_sort ,
                [Age_cur] ,
                [months_since_start_cur] ,
                [FTE based on Data Control] ,
                CASE WHEN [FTE based on Data Control] <= .1 THEN '0.0-0.1 FTE'
                     WHEN [FTE based on Data Control] <= .2 THEN '0.1-0.2 FTE'
                     WHEN [FTE based on Data Control] <= .3 THEN '0.2-0.3 FTE'
                     WHEN [FTE based on Data Control] <= .4 THEN '0.3-0.4 FTE'
                     WHEN [FTE based on Data Control] <= .5 THEN '0.4-0.5 FTE'
                     WHEN [FTE based on Data Control] <= .6 THEN '0.5-0.6 FTE'
                     WHEN [FTE based on Data Control] <= .7 THEN '0.6-0.7 FTE'
                     WHEN [FTE based on Data Control] <= .8 THEN '0.7-0.8 FTE'
                     WHEN [FTE based on Data Control] <= .9 THEN '0.8-0.9 FTE'
                     WHEN [FTE based on Data Control] < .99 THEN '0.9-0.99 FTE'
                     WHEN [FTE based on Data Control] >= 1.0 THEN ' >=1.0  FTE'
                     ELSE 'Unknown'
                END AS [FTE_Range_Cur] ,
                CASE WHEN [FTE based on Data Control] <= .1 THEN 1
                     WHEN [FTE based on Data Control] <= .2 THEN 2
                     WHEN [FTE based on Data Control] <= .3 THEN 3
                     WHEN [FTE based on Data Control] <= .4 THEN 4
                     WHEN [FTE based on Data Control] <= .5 THEN 5
                     WHEN [FTE based on Data Control] <= .6 THEN 6
                     WHEN [FTE based on Data Control] <= .7 THEN 7
                     WHEN [FTE based on Data Control] <= .8 THEN 8
                     WHEN [FTE based on Data Control] <= .9 THEN 9
                     WHEN [FTE based on Data Control] < .99 THEN 10
                     WHEN [FTE based on Data Control] >= 1.0 THEN 11
                     ELSE 12
                END AS [FTE_Range_Cur_Sort] ,
                CASE WHEN Age_cur <= 18 THEN '0-18 Years'
                     WHEN Age_cur <= 29 THEN '19-29 Years'
                     WHEN Age_cur <= 39 THEN '30-39 Years'
                     WHEN Age_cur <= 49 THEN '40-49 Years'
                     WHEN Age_cur <= 59 THEN '50-59 Years'
                     WHEN Age_cur <= 64 THEN '60-64 Years'
                     WHEN Age_cur <= 74 THEN '65-74 Years'
                     WHEN Age_cur <= 79 THEN '75-79 Years'
                     WHEN Age_cur <= 89 THEN '80-89 Years'
                     WHEN Age_cur <= 99 THEN '90-99 Years'
                     WHEN Age_cur >= 100 THEN '>100 Years'
                     ELSE 'Age Unknown'
                END AS [Age_range_cur] ,
                CASE WHEN Age_cur <= 18 THEN 1
                     WHEN Age_cur <= 29 THEN 2
                     WHEN Age_cur <= 39 THEN 3
                     WHEN Age_cur <= 49 THEN 4
                     WHEN Age_cur <= 59 THEN 5
                     WHEN Age_cur <= 64 THEN 6
                     WHEN Age_cur <= 74 THEN 7
                     WHEN Age_cur <= 79 THEN 8
                     WHEN Age_cur <= 89 THEN 9
                     WHEN Age_cur <= 99 THEN 10
                     WHEN Age_cur >= 100 THEN 11
                     ELSE 12
                END AS age_range_cur_sort ,
                CASE WHEN [months_since_start_cur] <= 1 THEN '1 Month - New Employee'
                     WHEN [months_since_start_cur] <= 6 THEN '2-6 Months'
                     WHEN [months_since_start_cur] <= 12 THEN '7-12 Months - 1 Year'
                     WHEN [months_since_start_cur] <= 24 THEN '13-24 Months- 2 Years'
                     WHEN [months_since_start_cur] <= 36 THEN '25-36 Months- 3 Years'
                     WHEN [months_since_start_cur] <= 48 THEN '37-48 Months- 4 Years'
                     WHEN [months_since_start_cur] <= 60 THEN '49-60 Months- 5 Years'
                     WHEN [months_since_start_cur] <= 120 THEN '61-120 Months- 6-10 Years'
                     WHEN [months_since_start_cur] <= 180 THEN '121-180 Months- 11-15 Years'
                     WHEN [months_since_start_cur] <= 240 THEN '181-240 Months- 15-20 Years'
                     WHEN [months_since_start_cur] > 240 THEN '>240 Months- 20 Years'
                END AS [Months Since Hire Range Cur] ,
                CASE WHEN [months_since_start_cur] <= 1 THEN 1
                     WHEN [months_since_start_cur] <= 6 THEN 2
                     WHEN [months_since_start_cur] <= 12 THEN 3
                     WHEN [months_since_start_cur] <= 24 THEN 4
                     WHEN [months_since_start_cur] <= 36 THEN 5
                     WHEN [months_since_start_cur] <= 48 THEN 6
                     WHEN [months_since_start_cur] <= 60 THEN 7
                     WHEN [months_since_start_cur] <= 120 THEN 8
                     WHEN [months_since_start_cur] <= 180 THEN 9
                     WHEN [months_since_start_cur] <= 240 THEN 10
                     WHEN [months_since_start_cur] > 240 THEN 11
                END AS months_since_hire_cur_sort,
				Ad.domain,
				Ad.email
        INTO    dwh.data_employee_v2
        FROM    dwh.data_employee_payroll_v2 ar
				
                INNER JOIN ( SELECT [pr].[File Number] ,
                                    MAX([pr].[Pay Date]) AS [Pay Date]
                             FROM   dwh.data_employee_payroll_v2 pr
						
                             GROUP BY [pr].[File Number]
                           ) pp ON pp.[File Number] = ar.[File Number]
                                   AND pp.[Pay Date] = ar.[Pay Date]
                 LEFT JOIN (SELECT email,firstName,lastName,rownum,domain 
							FROM #AD1 WHERE rownum=1) ad	
 				 ON REPLACE(UPPER(LEFT(ad.firstname,10)), '''', '') = REPLACE(UPPER(LEFT(ar.[Payroll First Name],
                                                                                                        10)), '''', '')
                                                      AND REPLACE(UPPER(ad.lastname), '''', '') = REPLACE(UPPER(ar.[Payroll Last Name]),
                                                                                                        '''', '')

		
		WHERE   COALESCE([ar].[File Number], '') != ''
        ORDER BY ar.[File Number];
        
			  
			  
			

		--Going to need to add slicers for FTE_cur and FTE_hx
		--and also employee Tenure in Months

        SELECT  emp.[employee_key] ,
                ap.[employee_payroll_key] ,
                emp.[File Number] ,
                ap.[Payroll Name] [Payroll Name Hx] ,
                ac.chart_account_key ,
                ap.[Pay Date] ,
                ap.[Home Cost Number - Check] ,
                ap.[Cost Number Worked In] ,
                ap.[Hourly Rate Calculated based on Reg Earnings] ,
                ap.[Salary Calculated (Reg Earnings) Annualized] ,
                ap.[Age_hx] ,
                ap.[months_since_start_hx] ,
                ap.months_since_start_allocated_hx ,
                ap.FTE_hx ,
                ap.FTE_allocated_hx ,
                ap.[Annual Salary ADP not annualized] ,
                emp.[Age_range_cur] ,
                emp.[age_range_cur_sort] ,
                [Remaining Floating Hrs] ,
                [Remaining Holiday Hrs] ,
                [Remaining LTS Hrs] ,
                [Remaining Sick Hrs] ,
                [Remaining Vacation Hrs] ,
                CASE WHEN FTE_hx <= .1 THEN '0.0-0.1 FTE'
                     WHEN FTE_hx <= .2 THEN '0.1-0.2 FTE'
                     WHEN FTE_hx <= .3 THEN '0.2-0.3 FTE'
                     WHEN FTE_hx <= .4 THEN '0.3-0.4 FTE'
                     WHEN FTE_hx <= .5 THEN '0.4-0.5 FTE'
                     WHEN FTE_hx <= .6 THEN '0.5-0.6 FTE'
                     WHEN FTE_hx <= .7 THEN '0.6-0.7 FTE'
                     WHEN FTE_hx <= .8 THEN '0.7-0.8 FTE'
                     WHEN FTE_hx <= .9 THEN '0.8-0.9 FTE'
                     WHEN FTE_hx < .99 THEN '0.9-0.99 FTE'
                     WHEN FTE_hx >= 1.0 THEN ' >=1.0  FTE'
                     ELSE 'Unknown'
                END AS [FTE_Range_hx] ,
                CASE WHEN FTE_hx <= .1 THEN 1
                     WHEN FTE_hx <= .2 THEN 2
                     WHEN FTE_hx <= .3 THEN 3
                     WHEN FTE_hx <= .4 THEN 4
                     WHEN FTE_hx <= .5 THEN 5
                     WHEN FTE_hx <= .6 THEN 6
                     WHEN FTE_hx <= .7 THEN 7
                     WHEN FTE_hx <= .8 THEN 8
                     WHEN FTE_hx <= .9 THEN 9
                     WHEN FTE_hx < .99 THEN 10
                     WHEN FTE_hx >= 1.0 THEN 11
                     ELSE 12
                END AS [FTE_Range_hx_sort] ,
                CASE WHEN FTE_allocated_hx <= .1 THEN '0.0-0.1 FTE'
                     WHEN FTE_allocated_hx <= .2 THEN '0.1-0.2 FTE'
                     WHEN FTE_allocated_hx <= .3 THEN '0.2-0.3 FTE'
                     WHEN FTE_allocated_hx <= .4 THEN '0.3-0.4 FTE'
                     WHEN FTE_allocated_hx <= .5 THEN '0.4-0.5 FTE'
                     WHEN FTE_allocated_hx <= .6 THEN '0.5-0.6 FTE'
                     WHEN FTE_allocated_hx <= .7 THEN '0.6-0.7 FTE'
                     WHEN FTE_allocated_hx <= .8 THEN '0.7-0.8 FTE'
                     WHEN FTE_allocated_hx <= .9 THEN '0.8-0.9 FTE'
                     WHEN FTE_allocated_hx < .99 THEN '0.9-0.99 FTE'
                     WHEN FTE_allocated_hx >= 1.0 THEN ' >=1.0  FTE'
                     ELSE 'Unknown'
                END AS [FTE_Allocated_Range_hx] ,
                CASE WHEN FTE_allocated_hx <= .1 THEN 1
                     WHEN FTE_allocated_hx <= .2 THEN 2
                     WHEN FTE_allocated_hx <= .3 THEN 3
                     WHEN FTE_allocated_hx <= .4 THEN 4
                     WHEN FTE_allocated_hx <= .5 THEN 5
                     WHEN FTE_allocated_hx <= .6 THEN 6
                     WHEN FTE_allocated_hx <= .7 THEN 7
                     WHEN FTE_allocated_hx <= .8 THEN 8
                     WHEN FTE_allocated_hx <= .9 THEN 9
                     WHEN FTE_allocated_hx < .99 THEN 10
                     WHEN FTE_allocated_hx >= 1.0 THEN 11
                     ELSE 12
                END AS [FTE_Allocated_Range_hx_sort] ,
                CASE WHEN [Age_hx] <= 18 THEN '0-18 Years'
                     WHEN [Age_hx] <= 29 THEN '19-29 Years'
                     WHEN [Age_hx] <= 39 THEN '30-39 Years'
                     WHEN [Age_hx] <= 49 THEN '40-49 Years'
                     WHEN [Age_hx] <= 59 THEN '50-59 Years'
                     WHEN [Age_hx] <= 64 THEN '60-64 Years'
                     WHEN [Age_hx] <= 74 THEN '65-74 Years'
                     WHEN [Age_hx] <= 79 THEN '75-79 Years'
                     WHEN [Age_hx] <= 89 THEN '80-89 Years'
                     WHEN [Age_hx] <= 99 THEN '90-99 Years'
                     WHEN [Age_hx] >= 100 THEN '>100 Years'
                     ELSE 'Age Unknown'
                END AS [age_range_hx] ,
                CASE WHEN [Age_hx] <= 18 THEN 1
                     WHEN [Age_hx] <= 29 THEN 2
                     WHEN [Age_hx] <= 39 THEN 3
                     WHEN [Age_hx] <= 49 THEN 4
                     WHEN [Age_hx] <= 59 THEN 5
                     WHEN [Age_hx] <= 64 THEN 6
                     WHEN [Age_hx] <= 74 THEN 7
                     WHEN [Age_hx] <= 79 THEN 8
                     WHEN [Age_hx] <= 89 THEN 9
                     WHEN [Age_hx] <= 99 THEN 10
                     WHEN [Age_hx] >= 100 THEN 11
                     ELSE 12
                END AS age_range_hx_sort ,
                CASE WHEN [months_since_start_hx] <= 1 THEN '1 Month - New Employee'
                     WHEN [months_since_start_hx] <= 6 THEN '2-6 Months'
                     WHEN [months_since_start_hx] <= 12 THEN '7-12 Months - 1 Year'
                     WHEN [months_since_start_hx] <= 24 THEN '13-24 Months- 2 Years'
                     WHEN [months_since_start_hx] <= 36 THEN '25-36 Months- 3 Years'
                     WHEN [months_since_start_hx] <= 48 THEN '37-48 Months- 4 Years'
                     WHEN [months_since_start_hx] <= 60 THEN '49-60 Months- 5 Years'
                     WHEN [months_since_start_hx] <= 120 THEN '61-120 Months- 6-10 Years'
                     WHEN [months_since_start_hx] <= 180 THEN '121-180 Months- 11-15 Years'
                     WHEN [months_since_start_hx] <= 240 THEN '181-240 Months- 15-20 Years'
                     WHEN [months_since_start_hx] > 240 THEN '>240 Months- 20 Years'
                END AS [months_since_start_range_hx] ,
                CASE WHEN [months_since_start_hx] <= 1 THEN 1
                     WHEN [months_since_start_hx] <= 6 THEN 2
                     WHEN [months_since_start_hx] <= 12 THEN 3
                     WHEN [months_since_start_hx] <= 24 THEN 4
                     WHEN [months_since_start_hx] <= 36 THEN 5
                     WHEN [months_since_start_hx] <= 48 THEN 6
                     WHEN [months_since_start_hx] <= 60 THEN 7
                     WHEN [months_since_start_hx] <= 120 THEN 8
                     WHEN [months_since_start_hx] <= 180 THEN 9
                     WHEN [months_since_start_hx] <= 240 THEN 10
                     WHEN [months_since_start_hx] > 240 THEN 11
                END AS [months_since_start_range_hx_sort] ,
                CASE WHEN months_since_start_allocated_hx <= 1 THEN '1 Month'
                     WHEN months_since_start_allocated_hx <= 6 THEN '2-6 Months'
                     WHEN months_since_start_allocated_hx <= 12 THEN '7-12 Months - 1 Year'
                     WHEN months_since_start_allocated_hx <= 24 THEN '13-24 Months- 2 Years'
                     WHEN months_since_start_allocated_hx <= 36 THEN '25-36 Months- 3 Years'
                     WHEN months_since_start_allocated_hx <= 48 THEN '37-48 Months- 4 Years'
                     WHEN months_since_start_allocated_hx <= 60 THEN '49-60 Months- 5 Years'
                     WHEN months_since_start_allocated_hx <= 120 THEN '61-120 Months- 6-10 Years'
                     WHEN months_since_start_allocated_hx <= 180 THEN '121-180 Months- 11-15 Years'
                     WHEN months_since_start_allocated_hx <= 240 THEN '181-240 Months- 15-20 Years'
                     WHEN months_since_start_allocated_hx > 240 THEN '>240 Months- 20 Years'
                END AS [months_since_start_allocated_range_hx] ,
                CASE WHEN months_since_start_allocated_hx <= 1 THEN 1
                     WHEN months_since_start_allocated_hx <= 6 THEN 2
                     WHEN months_since_start_allocated_hx <= 12 THEN 3
                     WHEN months_since_start_allocated_hx <= 24 THEN 4
                     WHEN months_since_start_allocated_hx <= 36 THEN 5
                     WHEN months_since_start_allocated_hx <= 48 THEN 6
                     WHEN months_since_start_allocated_hx <= 60 THEN 7
                     WHEN months_since_start_allocated_hx <= 120 THEN 8
                     WHEN months_since_start_allocated_hx <= 180 THEN 9
                     WHEN months_since_start_allocated_hx <= 240 THEN 10
                     WHEN months_since_start_allocated_hx > 240 THEN 11
                END AS [months_since_start_allocated_range_hx_sort] ,
        

			   
			   
			   
			    CASE WHEN [Hourly Rate Calculated based on Reg Earnings] < 5 THEN '$1-4 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 10 THEN '$5-9 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 15 THEN '$10-14 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 20 THEN '$15-19 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 25 THEN '$20-24 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 30 THEN '$25-29 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 35 THEN '$30-34 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 40 THEN '$35-39 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 45 THEN '$40-44 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 50 THEN '$45-49 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 55 THEN '$50-54 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 60 THEN '$55-59 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 65 THEN '$60-64 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 70 THEN '$65-69 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 75 THEN '$70-74 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 80 THEN '$75-79 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 85 THEN '$80-84 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 90 THEN '$85-89 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 95 THEN '$90-94 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 100 THEN '$95-99 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 105 THEN '$100-104 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 110 THEN '$105-109 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 115 THEN '$110-114 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 120 THEN '$115-119 /hr'
                     WHEN [Hourly Rate Calculated based on Reg Earnings] >= 120 THEN '>=$120 /hr'
                END AS rate_range_hx ,
                CASE WHEN [Hourly Rate Calculated based on Reg Earnings] < 5 THEN 1
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 10 THEN 2
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 15 THEN 3
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 20 THEN 4
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 25 THEN 5
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 30 THEN 6
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 35 THEN 7
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 40 THEN 8
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 45 THEN 9
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 50 THEN 10
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 55 THEN 11
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 60 THEN 12
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 65 THEN 13
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 70 THEN 14
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 75 THEN 15
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 80 THEN 16
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 85 THEN 17
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 90 THEN 18
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 95 THEN 19
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 100 THEN 20
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 105 THEN 21
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 110 THEN 22
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 115 THEN 23
                     WHEN [Hourly Rate Calculated based on Reg Earnings] < 120 THEN 24
                     WHEN [Hourly Rate Calculated based on Reg Earnings] >= 120 THEN 25
                END AS rate_range_hx_sort ,
                CASE WHEN [Salary Calculated (Reg Earnings) Annualized] < 5000 THEN '$0-4,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 10000 THEN '$5,000-9,000 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 20000 THEN '$10,000-19,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 30000 THEN '$20,000-29,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 40000 THEN '$30,000-39,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 50000 THEN '$40,000-49,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 60000 THEN '$50,000-59,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 70000 THEN '$60,000-69,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 80000 THEN '$70,000-79,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 90000 THEN '$80,000-89,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 100000 THEN '$90,000-99,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 110000 THEN '$100,000-109,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 120000 THEN '$110,000-119,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 130000 THEN '$120,000-129,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 140000 THEN '$130,000-139,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 150000 THEN '$140,000-149,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 160000 THEN '$150,000-159,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 170000 THEN '$160,000-169,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 180000 THEN '$170,000-179,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 190000 THEN '$180,000-189,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 200000 THEN '$190,000-199,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 210000 THEN '$200,000-209,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 220000 THEN '$210,000-219,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 230000 THEN '$220,000-229,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 240000 THEN '$230,000-239,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 250000 THEN '$240,000-249,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 260000 THEN '$250,000-259,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 270000 THEN '$260,000-269,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 280000 THEN '$270,000-279,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 290000 THEN '$280,000-289,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 300000 THEN '$290,000-299,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 310000 THEN '$300,000-309,999 /year'
                     WHEN [Salary Calculated (Reg Earnings) Annualized] >= 310000 THEN '>=$310,000 /year'
                END AS salary_annualized_range_hx ,
                CASE WHEN [Salary Calculated (Reg Earnings) Annualized] < 5000 THEN 1
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 10000 THEN 2
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 20000 THEN 3
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 30000 THEN 4
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 40000 THEN 5
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 50000 THEN 6
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 60000 THEN 7
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 70000 THEN 8
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 80000 THEN 9
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 90000 THEN 10
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 100000 THEN 11
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 110000 THEN 12
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 120000 THEN 13
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 130000 THEN 14
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 140000 THEN 15
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 150000 THEN 16
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 160000 THEN 17
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 170000 THEN 18
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 180000 THEN 19
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 190000 THEN 20
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 200000 THEN 21
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 210000 THEN 22
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 220000 THEN 23
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 230000 THEN 24
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 240000 THEN 25
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 250000 THEN 26
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 260000 THEN 27
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 270000 THEN 28
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 280000 THEN 29
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 290000 THEN 30
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 300000 THEN 31
                     WHEN [Salary Calculated (Reg Earnings) Annualized] < 310000 THEN 32
                     WHEN [Salary Calculated (Reg Earnings) Annualized] >= 310000 THEN 33
                END AS salary_annualized_range_hx_sort ,
            

				    CASE WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 5 THEN '$1-4 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 10 THEN '$5-9 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 15 THEN '$10-14 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 20 THEN '$15-19 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 25 THEN '$20-24 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 30 THEN '$25-29 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 35 THEN '$30-34 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 40 THEN '$35-39 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 45 THEN '$40-44 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 50 THEN '$45-49 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 55 THEN '$50-54 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 60 THEN '$55-59 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 65 THEN '$60-64 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 70 THEN '$65-69 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 75 THEN '$70-74 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 80 THEN '$75-79 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 85 THEN '$80-84 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 90 THEN '$85-89 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 95 THEN '$90-94 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 100 THEN '$95-99 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 105 THEN '$100-104 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 110 THEN '$105-109 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 115 THEN '$110-114 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 120 THEN '$115-119 /hr'
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] >= 120 THEN '>=$120 /hr'
                END AS rate_range_cur ,
                CASE WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 5 THEN 1
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 10 THEN 2
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 15 THEN 3
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 20 THEN 4
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 25 THEN 5
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 30 THEN 6
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 35 THEN 7
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 40 THEN 8
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 45 THEN 9
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 50 THEN 10
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 55 THEN 11
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 60 THEN 12
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 65 THEN 13
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 70 THEN 14
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 75 THEN 15
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 80 THEN 16
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 85 THEN 17
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 90 THEN 18
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 95 THEN 19
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 100 THEN 20
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 105 THEN 21
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 110 THEN 22
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 115 THEN 23
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] < 120 THEN 24
                     WHEN ap.[Hourly Rate ADP (Based on ADP Salary or Hourly)] >= 120 THEN 25
                END AS rate_range_cur_sort ,

                CASE WHEN ap.[Hourly Rate ADP 1 (Direct Hourly)] < 5 THEN '$1-4 /hr'
                     WHEN ap.[Hourly Rate ADP 1 (Direct Hourly)] < 10 THEN '$5-9 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 15 THEN '$10-14 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 20 THEN '$15-19 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 25 THEN '$20-24 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 30 THEN '$25-29 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 35 THEN '$30-34 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 40 THEN '$35-39 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 45 THEN '$40-44 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 50 THEN '$45-49 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 55 THEN '$50-54 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 60 THEN '$55-59 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 65 THEN '$60-64 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 70 THEN '$65-69 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 75 THEN '$70-74 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 80 THEN '$75-79 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 85 THEN '$80-84 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 90 THEN '$85-89 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 95 THEN '$90-94 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 100 THEN '$95-99 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 105 THEN '$100-104 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 110 THEN '$105-109 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 115 THEN '$110-114 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 120 THEN '$115-119 /hr'
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  >= 120 THEN '>=$120 /hr'
                END AS rate_direct_range_cur ,
                CASE WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 5 THEN 1
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 10 THEN 2
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 15 THEN 3
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 20 THEN 4
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 25 THEN 5
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 30 THEN 6
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 35 THEN 7
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 40 THEN 8
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 45 THEN 9
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 50 THEN 10
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 55 THEN 11
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 60 THEN 12
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 65 THEN 13
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 70 THEN 14
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 75 THEN 15
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 80 THEN 16
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 85 THEN 17
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 90 THEN 18
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 95 THEN 19
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 100 THEN 20
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 105 THEN 21
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 110 THEN 22
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 115 THEN 23
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  < 120 THEN 24
                     WHEN  ap.[Hourly Rate ADP 1 (Direct Hourly)]  >= 120 THEN 25
                END AS rate_direct_range_cur_sort ,

                CASE WHEN ap.[Annual Salary ADP annualized] < 5000 THEN '$0-4,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 10000 THEN '$5,000-9,000 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 20000 THEN '$10,000-19,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 30000 THEN '$20,000-29,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 40000 THEN '$30,000-39,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 50000 THEN '$40,000-49,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 60000 THEN '$50,000-59,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 70000 THEN '$60,000-69,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 80000 THEN '$70,000-79,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 90000 THEN '$80,000-89,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 100000 THEN '$90,000-99,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 110000 THEN '$100,000-109,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 120000 THEN '$110,000-119,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 130000 THEN '$120,000-129,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 140000 THEN '$130,000-139,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 150000 THEN '$140,000-149,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 160000 THEN '$150,000-159,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 170000 THEN '$160,000-169,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 180000 THEN '$170,000-179,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 190000 THEN '$180,000-189,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 200000 THEN '$190,000-199,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 210000 THEN '$200,000-209,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 220000 THEN '$210,000-219,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 230000 THEN '$220,000-229,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 240000 THEN '$230,000-239,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 250000 THEN '$240,000-249,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 260000 THEN '$250,000-259,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 270000 THEN '$260,000-269,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 280000 THEN '$270,000-279,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 290000 THEN '$280,000-289,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 300000 THEN '$290,000-299,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] < 310000 THEN '$300,000-309,999 /year'
                     WHEN ap.[Annual Salary ADP annualized] >= 310000 THEN '>=$310,000 /year'
                END AS salary_annualized_range_cur ,
                CASE WHEN ap.[Annual Salary ADP annualized] < 5000 THEN 1
                     WHEN ap.[Annual Salary ADP annualized] < 10000 THEN 2
                     WHEN ap.[Annual Salary ADP annualized] < 20000 THEN 3
                     WHEN ap.[Annual Salary ADP annualized] < 30000 THEN 4
                     WHEN ap.[Annual Salary ADP annualized] < 40000 THEN 5
                     WHEN ap.[Annual Salary ADP annualized] < 50000 THEN 6
                     WHEN ap.[Annual Salary ADP annualized] < 60000 THEN 7
                     WHEN ap.[Annual Salary ADP annualized] < 70000 THEN 8
                     WHEN ap.[Annual Salary ADP annualized] < 80000 THEN 9
                     WHEN ap.[Annual Salary ADP annualized] < 90000 THEN 10
                     WHEN ap.[Annual Salary ADP annualized] < 100000 THEN 11
                     WHEN ap.[Annual Salary ADP annualized] < 110000 THEN 12
                     WHEN ap.[Annual Salary ADP annualized] < 120000 THEN 13
                     WHEN ap.[Annual Salary ADP annualized] < 130000 THEN 14
                     WHEN ap.[Annual Salary ADP annualized] < 140000 THEN 15
                     WHEN ap.[Annual Salary ADP annualized] < 150000 THEN 16
                     WHEN ap.[Annual Salary ADP annualized] < 160000 THEN 17
                     WHEN ap.[Annual Salary ADP annualized] < 170000 THEN 18
                     WHEN ap.[Annual Salary ADP annualized] < 180000 THEN 19
                     WHEN ap.[Annual Salary ADP annualized] < 190000 THEN 20
                     WHEN ap.[Annual Salary ADP annualized] < 200000 THEN 21
                     WHEN ap.[Annual Salary ADP annualized] < 210000 THEN 22
                     WHEN ap.[Annual Salary ADP annualized] < 220000 THEN 23
                     WHEN ap.[Annual Salary ADP annualized] < 230000 THEN 24
                     WHEN ap.[Annual Salary ADP annualized] < 240000 THEN 25
                     WHEN ap.[Annual Salary ADP annualized] < 250000 THEN 26
                     WHEN ap.[Annual Salary ADP annualized] < 260000 THEN 27
                     WHEN ap.[Annual Salary ADP annualized] < 270000 THEN 28
                     WHEN ap.[Annual Salary ADP annualized] < 280000 THEN 29
                     WHEN ap.[Annual Salary ADP annualized] < 290000 THEN 30
                     WHEN ap.[Annual Salary ADP annualized] < 300000 THEN 31
                     WHEN ap.[Annual Salary ADP annualized] < 310000 THEN 32
                     WHEN ap.[Annual Salary ADP annualized] >= 310000 THEN 33
                END AS salary_annualized_range_cur_sort ,
                CASE WHEN ap.[Annual Salary ADP not annualized] < 5000 THEN '$0-4,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 10000 THEN '$5,000-9,000 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 20000 THEN '$10,000-19,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 30000 THEN '$20,000-29,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 40000 THEN '$30,000-39,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 50000 THEN '$40,000-49,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 60000 THEN '$50,000-59,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 70000 THEN '$60,000-69,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 80000 THEN '$70,000-79,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 90000 THEN '$80,000-89,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 100000 THEN '$90,000-99,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 110000 THEN '$100,000-109,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 120000 THEN '$110,000-119,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 130000 THEN '$120,000-129,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 140000 THEN '$130,000-139,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 150000 THEN '$140,000-149,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 160000 THEN '$150,000-159,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 170000 THEN '$160,000-169,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 180000 THEN '$170,000-179,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 190000 THEN '$180,000-189,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 200000 THEN '$190,000-199,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 210000 THEN '$200,000-209,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 220000 THEN '$210,000-219,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 230000 THEN '$220,000-229,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 240000 THEN '$230,000-239,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 250000 THEN '$240,000-249,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 260000 THEN '$250,000-259,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 270000 THEN '$260,000-269,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 280000 THEN '$270,000-279,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 290000 THEN '$280,000-289,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 300000 THEN '$290,000-299,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] < 310000 THEN '$300,000-309,999 /year'
                     WHEN ap.[Annual Salary ADP not annualized] >= 310000 THEN '>=$310,000 /year'
                END AS salary_not_annualized_range_cur ,
                CASE WHEN ap.[Annual Salary ADP not annualized] < 5000 THEN 1
                     WHEN ap.[Annual Salary ADP not annualized] < 10000 THEN 2
                     WHEN ap.[Annual Salary ADP not annualized] < 20000 THEN 3
                     WHEN ap.[Annual Salary ADP not annualized] < 30000 THEN 4
                     WHEN ap.[Annual Salary ADP not annualized] < 40000 THEN 5
                     WHEN ap.[Annual Salary ADP not annualized] < 50000 THEN 6
                     WHEN ap.[Annual Salary ADP not annualized] < 60000 THEN 7
                     WHEN ap.[Annual Salary ADP not annualized] < 70000 THEN 8
                     WHEN ap.[Annual Salary ADP not annualized] < 80000 THEN 9
                     WHEN ap.[Annual Salary ADP not annualized] < 90000 THEN 10
                     WHEN ap.[Annual Salary ADP not annualized] < 100000 THEN 11
                     WHEN ap.[Annual Salary ADP not annualized] < 110000 THEN 12
                     WHEN ap.[Annual Salary ADP not annualized] < 120000 THEN 13
                     WHEN ap.[Annual Salary ADP not annualized] < 130000 THEN 14
                     WHEN ap.[Annual Salary ADP not annualized] < 140000 THEN 15
                     WHEN ap.[Annual Salary ADP not annualized] < 150000 THEN 16
                     WHEN ap.[Annual Salary ADP not annualized] < 160000 THEN 17
                     WHEN ap.[Annual Salary ADP not annualized] < 170000 THEN 18
                     WHEN ap.[Annual Salary ADP not annualized] < 180000 THEN 19
                     WHEN ap.[Annual Salary ADP not annualized] < 190000 THEN 20
                     WHEN ap.[Annual Salary ADP not annualized] < 200000 THEN 21
                     WHEN ap.[Annual Salary ADP not annualized] < 210000 THEN 22
                     WHEN ap.[Annual Salary ADP not annualized] < 220000 THEN 23
                     WHEN ap.[Annual Salary ADP not annualized] < 230000 THEN 24
                     WHEN ap.[Annual Salary ADP not annualized] < 240000 THEN 25
                     WHEN ap.[Annual Salary ADP not annualized] < 250000 THEN 26
                     WHEN ap.[Annual Salary ADP not annualized] < 260000 THEN 27
                     WHEN ap.[Annual Salary ADP not annualized] < 270000 THEN 28
                     WHEN ap.[Annual Salary ADP not annualized] < 280000 THEN 29
                     WHEN ap.[Annual Salary ADP not annualized] < 290000 THEN 30
                     WHEN ap.[Annual Salary ADP not annualized] < 300000 THEN 31
                     WHEN ap.[Annual Salary ADP not annualized] < 310000 THEN 32
                     WHEN ap.[Annual Salary ADP not annualized] >= 310000 THEN 33
                END AS salary_not_annualized_range_cur_sort ,
                CASE WHEN ac.[Category Number] IN ( 39, 37, 47 ) THEN '60	Physicians'
                     WHEN ac.[Category Number] IN ( 68 ) THEN '61	Physicians Assistants'
                     WHEN ac.[Category Number] IN ( 67 ) THEN '62	Family Nurse Practitioners'
                     WHEN ac.[Category Number] IN ( 69 ) THEN '63	Certified Nurse Midwives'
                     WHEN ac.[Category Number] IN ( 80 ) THEN '65	Dentists'
                     WHEN ac.[Category Number] IN ( 49 ) THEN '67	Psychiatrists'
                     WHEN ac.[Category Number] IN ( 50 ) THEN '68	Clinical Psychologists'
                     WHEN ac.[Category Number] IN ( 51, 52 ) THEN '69	Licensed Clinical Social Worker'
                     WHEN ac.[Category Number] IN ( 59, 45 ) THEN '70	Other Providers billable to Medi-Cal**'
                     WHEN ac.[Category Number] IN ( 9999 ) THEN '74	Other Certified CPSP Providers not listed above'
                     WHEN ac.[Category Number] IN ( 9999 )
                     THEN '80	Registered Dental Hygienists (not alternative practice)'
                     WHEN ac.[Category Number] IN ( 81 ) THEN '81	Registered Dental Assistants'
                     WHEN ac.[Category Number] IN ( 82 ) THEN '82	Dental Assistants - Not Licensed'
                     WHEN ac.[Category Number] IN ( 53 ) THEN '83	Marriage and Family Therapists'
                     WHEN ac.[Category Number] IN ( 73 ) THEN '84	Registered Nurses'
                     WHEN ac.[Category Number] IN ( 999 ) THEN '85	Licensed Vocational Nurses'
                     WHEN ac.[Category Number] IN ( 01 ) THEN '86	Medical Assistants - Not Licensed'
                     WHEN ac.[Category Number] IN ( 20, 55 ) THEN '87	Non-Licensed Patient Education Staff'
                     WHEN ac.[Category Number] IN ( 9999 ) THEN '88	Substance Abuse Counselors'
                     WHEN ac.[Category Number] IN ( 9999 ) THEN '89	Billing Staff'
                     WHEN ac.[Category Number] IN ( 19, 30, 29, 17, 10, 34, 90 ) THEN '90	Other Administrative Staff'
                     WHEN ac.[Category Number] IN ( 05 ) THEN '94	Other Providers not Listed Above'
                     ELSE 'Unknown'
                END AS [OSHPD Category],
				     ap.[cn_site_hx]
		

                
	
	--Need to address account numbers not mapping -- looks like there are some cost numbers that are not present in the transaction accounting.  I am curious about this
        INTO    dwh.data_employee_payroll_scd
        FROM    dwh.data_employee_payroll_v2 ap
                INNER JOIN dwh.data_employee_v2 emp ON ap.[File Number] = emp.[File Number]
                LEFT JOIN [Prod_Ghost].[dwh].data_fe_account ac ON ac.[Account Number] = SUBSTRING([Cost Number Worked In],
                                                                                                   1,
                                                                                                   CASE CHARINDEX('-',
                                                                                                        [Cost Number Worked In],
                                                                                                        14)
                                                                                                     WHEN 0
                                                                                                     THEN LEN([Cost Number Worked In])
                                                                                                        + 1
                                                                                                     ELSE CHARINDEX('-',
                                                                                                        [Cost Number Worked In],
                                                                                                        14) + 2
                                                                                                   END)
                                                                   AND ( ( COALESCE(ap.[cn_proj_grant_hx], '') = ''
                                                                           AND ac.[Project ID] = 'Unknown'

                                                                         )
                                                                         OR ac.[Project ID] = [cn_proj_grant_hx]
                                                                       );
																		   

--Build Fact and Dimension Tables

        SELECT  ap.[employee_payroll_key] ,
                ap.[File Number] ,
                ac.chart_account_key ,
                ap.[Pay Date] ,
                ap.[Payroll Name] [Payroll Name Hx] ,
                ap.[UDS Person 2015 Tenure] ,
                ap.[UDS Person 2014 Tenure] ,
                ap.[months_since_start_cur] AS [Months Since Start Cur] ,
                ap.[months_since_start_hx] AS [Months Since Start Hx] ,
                ap.[months_since_start_allocated_hx] [Months Since Start Allocated Hx] ,
                ap.[FTE_allocated_hx] AS [FTE Allocated Hx] ,
                ap.[FTE_hx] AS [FTE Hx] ,
                ap.[FTE based on Data Control] AS [FTE Current] ,
                ap.[Employee Census Month] ,
                ap.[Employee Terminated Census Month] ,
                ap.[Employee Bad Hire Census Month] ,
				
				 ap.[Employee New Hire Census Month],
                 ap.[Total All Hours New Hire],
    
	CASE WHEN ap.[Total All Hours New Hire]/8>=0 THEN   ap.[Total All Hours New Hire]/8 ELSE 0 end  AS [FTE Avg 6m New Hire],
				

                ap.[UDS Person 2015 Count] ,
                ap.[UDS Person 2014 Count] ,
                ap.[UDS Person 2013 Count] ,
                ap.[Total All Hours Terminated] ,
				ap.[FTE Terminated 6m Avg]/8 [FTE Terminated 6m Avg],
				ap.[FTE New Hire 6m Avg]/8 [FTE New Hire 6m Avg],
				ap.[FTE Transfer 6m Avg] /8 [FTE Transfer 6m Avg],
			    ap.[Employee Transfer Census Month] ,
				
				CASE WHEN ap.[Total All Hours Terminated]/8>=0 THEN   ap.[Total All Hours Terminated]/8 ELSE 0 end  AS [FTE Avg 6m Terminated],
				
				ap.[Total All Hours] ,
                ap.[Regular Hours with s/v/f/h] ,
                ap.[Regular Hours] ,
                ap.[All Other Coded Hours] ,
                ap.[Overtime Hours] ,
                ap.[Regular Earnings] ,
                ap.[Other Earnings] ,
                ap.[Overtime Earnings] ,
                ap.[Net Pay] ,
                ap.[Gross Pay] ,
                ap.[Remaining Floating Hrs] ,
                ap.[Remaining Holiday Hrs] ,
                ap.[Remaining LTS Hrs] ,
                ap.[Remaining Sick Hrs] ,
                ap.[Remaining Vacation Hrs] ,
                ap.[_Hours Coded1] AS [_Hours Coded- 0 ] ,
                ap.[_Hours Coded2] AS [_Hours Coded- 11 Penalty Code] ,
                ap.[_Hours Coded3] AS [_Hours Coded- 12 Orientation] ,
                ap.[_Hours Coded4] AS [_Hours Coded- 16 ] ,
                ap.[_Hours Coded5] AS [_Hours Coded- 20 Administrative H] ,
                ap.[_Hours Coded6] AS [_Hours Coded- 21 Committee Hrs] ,
                ap.[_Hours Coded7] AS [_Hours Coded- 25 0.25 bilingual] ,
                ap.[_Hours Coded8] AS [_Hours Coded- 30 Saturday Rate] ,
                ap.[_Hours Coded9] AS [_Hours Coded- 34 ] ,
                ap.[_Hours Coded10] AS [_Hours Coded- 4 Administrative] ,
                ap.[_Hours Coded11] AS [_Hours Coded- 44 Hospital Alta Bates] ,
                ap.[_Hours Coded12] AS [_Hours Coded- 5 Educaiton] ,
                ap.[_Hours Coded13] AS [_Hours Coded- A Hospital] ,
                ap.[_Hours Coded14] AS [_Hours Coded- B Bereavement] ,
                ap.[_Hours Coded15] AS [_Hours Coded- C CME] ,
                ap.[_Hours Coded16] AS [_Hours Coded- CON Conference] ,
                ap.[_Hours Coded17] AS [_Hours Coded- D Double Time] ,
                ap.[_Hours Coded18] AS [_Hours Coded- E Extra Pay] ,
                ap.[_Hours Coded19] AS [_Hours Coded- F Flt/p] ,
                ap.[_Hours Coded20] AS [_Hours Coded- H Holiday] ,
                ap.[_Hours Coded21] AS [_Hours Coded- J Jury] ,
                ap.[_Hours Coded22] AS [_Hours Coded- LTS Long Term Sick] ,
                ap.[_Hours Coded23] AS [_Hours Coded- M Meeting Time] ,
                ap.[_Hours Coded24] AS [_Hours Coded- P Personal Leave] ,
                ap.[_Hours Coded25] AS [_Hours Coded- R Regular] ,
                ap.[_Hours Coded26] AS [_Hours Coded- S Sick] ,
                ap.[_Hours Coded27] AS [_Hours Coded- T Retro Pay] ,
                ap.[_Hours Coded28] AS [_Hours Coded- U ] ,
                ap.[_Hours Coded29] AS [_Hours Coded- V Vacation] ,
                ap.[_Hours Coded30] AS [_Hours Coded- W ] ,
                ap.[_Hours Coded31] AS [_Hours Coded- WRO Weekend Rate OT] ,
                ap.[_Hours Coded32] AS [_Hours Coded- WRT Weekend Rate OT] ,
                ap.[_Hours Coded33] AS [_Hours Coded- 6 SNF Hours] ,
                ap.[_Earnings Coded1] AS [_Earnings Coded- 0 ] ,
                ap.[_Earnings Coded2] AS [_Earnings Coded- 1 WCME] ,
                ap.[_Earnings Coded3] AS [_Earnings Coded- 10 Clinic - On Call] ,
                ap.[_Earnings Coded4] AS [_Earnings Coded- 11 Penalty Code] ,
                ap.[_Earnings Coded5] AS [_Earnings Coded- 12 Orientation] ,
                ap.[_Earnings Coded6] AS [_Earnings Coded- 15 Special Service] ,
                ap.[_Earnings Coded7] AS [_Earnings Coded- 16 ] ,
                ap.[_Earnings Coded8] AS [_Earnings Coded- 17 Call Alta Bates] ,
                ap.[_Earnings Coded9] AS [_Earnings Coded- 18 Call CC County] ,
                ap.[_Earnings Coded10] AS [_Earnings Coded- 19 Call-EO-OS] ,
                ap.[_Earnings Coded11] AS [_Earnings Coded- 2 Call Nursery] ,
                ap.[_Earnings Coded12] AS [_Earnings Coded- 20 Admin H] ,
                ap.[_Earnings Coded13] AS [_Earnings Coded- 21 Committee Hrs] ,
                ap.[_Earnings Coded14] AS [_Earnings Coded- 25 $0.25 Bilingual] ,
                ap.[_Earnings Coded15] AS [_Earnings Coded- 3 Call CHCN] ,
                ap.[_Earnings Coded16] AS [_Earnings Coded- 30 Saturday Rate] ,
                ap.[_Earnings Coded17] AS [_Earnings Coded- 31 ] ,
                ap.[_Earnings Coded18] AS [_Earnings Coded- 32 ] ,
                ap.[_Earnings Coded19] AS [_Earnings Coded- 33 ] ,
                ap.[_Earnings Coded20] AS [_Earnings Coded- 34 ] ,
                ap.[_Earnings Coded21] AS [_Earnings Coded- 39 ] ,
                ap.[_Earnings Coded22] AS [_Earnings Coded- 4 Administrative] ,
                ap.[_Earnings Coded23] AS [_Earnings Coded- 41 ] ,
                ap.[_Earnings Coded24] AS [_Earnings Coded- 44 Hosp AB] ,
                ap.[_Earnings Coded25] AS [_Earnings Coded- 45 Call Split Adult] ,
                ap.[_Earnings Coded26] AS [_Earnings Coded- 47 Call LMC] ,
                ap.[_Earnings Coded27] AS [_Earnings Coded- 48 Call Holiday] ,
                ap.[_Earnings Coded28] AS [_Earnings Coded- 5 Education] ,
                ap.[_Earnings Coded29] AS [_Earnings Coded- A Hospital] ,
                ap.[_Earnings Coded30] AS [_Earnings Coded- B Bereavement] ,
                ap.[_Earnings Coded31] AS [_Earnings Coded- C CME] ,
                ap.[_Earnings Coded32] AS [_Earnings Coded- CON Conference] ,
                ap.[_Earnings Coded33] AS [_Earnings Coded- D Doubletime] ,
                ap.[_Earnings Coded34] AS [_Earnings Coded- F Flt/P] ,
                ap.[_Earnings Coded35] AS [_Earnings Coded- E Extra Pay] ,
                ap.[_Earnings Coded36] AS [_Earnings Coded- FU Follow up] ,
                ap.[_Earnings Coded37] AS [_Earnings Coded- H Holiday] ,
                ap.[_Earnings Coded38] AS [_Earnings Coded- I Incentive Bonus] ,
                ap.[_Earnings Coded39] AS [_Earnings Coded- J Jury] ,
                ap.[_Earnings Coded40] AS [_Earnings Coded- L Lead Pay] ,
                ap.[_Earnings Coded41] AS [_Earnings Coded- LTS Long Term Sick] ,
                ap.[_Earnings Coded42] AS [_Earnings Coded- M Meeting Time] ,
                ap.[_Earnings Coded43] AS [_Earnings Coded- N ] ,
                ap.[_Earnings Coded44] AS [_Earnings Coded- O On-Call] ,
                ap.[_Earnings Coded45] AS [_Earnings Coded- P Personal Leave] ,
                ap.[_Earnings Coded46] AS [_Earnings Coded- R Regular] ,
                ap.[_Earnings Coded47] AS [_Earnings Coded- S Sick] ,
                ap.[_Earnings Coded48] AS [_Earnings Coded- SU Super User] ,
                ap.[_Earnings Coded49] AS [_Earnings Coded- T Retro Pay] ,
                ap.[_Earnings Coded50] AS [_Earnings Coded- U **] ,
                ap.[_Earnings Coded51] AS [_Earnings Coded- V Vacation] ,
                ap.[_Earnings Coded52] AS [_Earnings Coded- W ] ,
                ap.[_Earnings Coded53] AS [_Earnings Coded- WRO Weekend Rate OT] ,
                ap.[_Earnings Coded54] AS [_Earnings Coded- WRT Weekend Rate] ,
                ap.[_Earnings Coded55] AS [_Earnings Coded- X Addl 250 Stipend] ,
                ap.[_Earnings Coded56] AS [_Earnings Coded- Y 1.25 in Lieu] ,
                ap.[_Earnings Coded57] AS [_Earnings Coded- Z 1.50 in Lieu] ,
                ap.[_Earnings Coded58] AS [_Earnings Coded- 6 SNF Hours] ,
                ap.[_Earnings Coded59] AS [_Earnings Coded- 46 Call Split Peds]
        INTO    fdt.[Fact Employee Census Payroll]
        FROM    [Prod_Ghost].[dwh].[data_employee_payroll_v2] ap
                INNER JOIN dwh.data_employee_v2 emp ON ap.[File Number] = emp.[File Number]
                LEFT JOIN [Prod_Ghost].[dwh].data_fe_account ac ON ac.[Account Number] = SUBSTRING([Cost Number Worked In],
                                                                                                   1,
                                                                                                   CASE CHARINDEX('-',
                                                                                                        [Cost Number Worked In],
                                                                                                        14)
                                                                                                     WHEN 0
                                                                                                     THEN LEN([Cost Number Worked In])
                                                                                                        + 1
                                                                                                     ELSE CHARINDEX('-',
                                                                                                        [Cost Number Worked In],
                                                                                                        14) + 2
                                                                                                   END)
                                                                   AND ( ( COALESCE(ap.[cn_proj_grant_hx], '') = ''
                                                                           AND ac.[Project ID] = 'Unknown'
																	
                                                                         )
                                                                         OR ac.[Project ID] = [cn_proj_grant_hx]
                                                                       );
																		   

  
        SELECT  [employee_key] ,
                [employee_payroll_key] ,
                [chart_account_key] ,
			---	[Payroll Name Hx], --Dropped
                [Pay Date] ,
                [Home Cost Number - Check] [Cost Number- Home] , --Modified
                [Cost Number Worked In] [Cost Number- Worked In] , --Modified
                [FTE_Range_hx] [FTE Range Hx] ,  --Consider dropping
                [FTE_Range_hx_sort] ,
                [FTE_Allocated_Range_hx] [FTE Allocated Range Hx] ,  --Consider dropping
                [FTE_Allocated_Range_hx_sort] ,
                [cn_site_hx] [Site Worked],
			--	[age_range_cur] [Age Range Cur],
            --    [age_range_cur_sort] ,
                [age_range_hx] [Age Range Hx] ,
                [age_range_hx_sort] ,
                [months_since_start_range_hx] [Months since Hire Range Hx] ,
                [months_since_start_range_hx_sort] ,
                [months_since_start_allocated_range_hx] [Months Since Hire Allocated Range Hx] ,
                [months_since_start_allocated_range_hx_sort] ,
                [rate_range_hx] [Hourly Rate Range Hx] ,
                [rate_range_hx_sort] ,
				[salary_annualized_range_hx] [Salary Annualized Range Hx] ,
                [salary_annualized_range_hx_sort] ,
               


			--    [rate_range_cur]  [Hourly Rate Range Cur],
            --    [rate_range_cur_sort] ,
             
			--    [salary_annualized_range_cur]  [Salary Annualized Range Cur],
            --    [salary_annualized_range_cur_sort] ,
               
			--    [salary_not_annualized_range_cur][Salary Not Annualized Range Cur] ,
            --    [salary_not_annualized_range_cur_sort],
                [Hourly Rate Calculated based on Reg Earnings] [Hourly Rate Hx] ,
                [Salary Calculated (Reg Earnings) Annualized] [Salary Annualized Hx] ,
                [Annual Salary ADP not annualized] [Salary Actual Hx] ,
                [Age_hx] [Age Hx] ,
                [Remaining Floating Hrs] ,
                [Remaining Holiday Hrs] ,
                [Remaining LTS Hrs] ,
                [Remaining Sick Hrs] ,
                [Remaining Vacation Hrs] ,
                [months_since_start_hx] AS [Months Since Hire Hx] , --Modified
       --         [months_since_start_allocated_hx] [Months Since Hire Allocated Hx], --Modidied
                [OSHPD Category]
        INTO    fdt.[Dim Employee Hx]
        FROM    [Prod_Ghost].[dwh].[data_employee_payroll_scd]; 
  
  				


        SELECT  [employee_key] ,
                [File Number] ,
                [Location] ,
                [Location Code] ,
                [Current Status] ,
                [Hire Date] ,
                [Termination Date] ,
                [Termination Reason] ,
                [Termination Reason Code] ,
                [Job Title] ,
                [Payroll First Name] [Name First] , --Modified
                [Payroll Last Name] [Name Last] ,    --Modified
                [Payroll Name] [Name Full] ,        --Modified
                [Birth Date] ,
                [Gender] ,
                [EEO Ethnic Code] ,
                [Zip/Postal Code] ,
                [Domain] AS [Domain Login],
				[email] AS [Work email],
				[Manager First Name] ,
                [Manager Last Name] ,
                [Manager ID] ,
                [Standard Hours] ,
                [Hourly Rate ADP 1 (Direct Hourly)] [Rate Hourly Direct Cur] ,  --Modified
				

				rate_direct_range_cur [Rate Hourly Direct Range],
				[Rate_direct_range_cur_sort],
				
				
                   --Drop in Final
		        [Hourly Rate ADP (Based on ADP Salary or Hourly)] [Rate Hourly Cur] ,
				
				[rate_range_cur] [Rate Hourly Range Cur],
				[rate_range_cur_sort],


				[Hourly Rate 2 ADP (Direct-biweekly salary)]  ,   --Drop in Final
                [Hourly Rate ADP (Based on ADP Salary or Hourly)] , --Drop in Final


                [Annual Salary ADP not annualized] [Salary Actual Cur] , --Modidied
                [Annual Salary ADP annualized] [Salary Annualized Cur] , --Modified
                [UDS Table 5 Staffing Category ] ,
                [UDS Table 5 Line Number ] ,
                [UDS Table 8 Costs Category ] ,
                [UDS Table 8 Line Number ] ,
                [Home Cost Number - Check] [Cost Number- Home] , --Modified (added)
                [cn_account_code_cur] AS [Account Cur] ,
                [cn_account_code_sub_cur] AS [Account Sub-code Cur] ,
                [cn_site_cur] AS [Site Cur] ,
                [cn_fund_cur] AS [Fund Cur] ,
                [cn_dir_indir_cur] AS [Direct or Indirect Cur] ,
                [cn_category_cur] AS [Category Cur] ,
                [cn_proj_grant_cur] AS [Grant Cur] ,
                [Data Control] ,
                [rate_range_cur] AS [Rate Range Cur] , -- Need to drop
                
                [salary_annualized_range_cur] AS [Salary Annualized Range Cur] ,
                [salary_annualized_range_cur_sort] ,
                [salary_not_annualized_range_cur] AS [Salary Not Annualized Range Cur] ,
                [salary_not_annualized_range_cur_sort] ,
                [Age_cur] [Age Cur] , --Modified
                [months_since_start_cur] AS [Months Since Hire Cur] ,
                [FTE based on Data Control] AS [FTE Cur] ,
                [FTE_Range_Cur] AS [FTE Range Cur ] ,  --Modified
                [FTE_Range_Cur_Sort] ,
                [Age_range_cur] [Age Range Cur] ,
                [age_range_cur_sort] ,
                [Months Since Hire Range Cur] ,
                months_since_hire_cur_sort
        INTO    fdt.[Dim Employee Cur]
        FROM    [Prod_Ghost].[dwh].[data_employee_v2];
            
  





    END;
GO
