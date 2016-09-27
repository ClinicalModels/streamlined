SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_category_event]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        IF OBJECT_ID('dbo.data_category_event') IS NOT NULL
            DROP TABLE dbo.data_category_event;


        SELECT  IDENTITY( INT, 1, 1 ) AS cat_event_key ,
                cm.event_id ,
                cat.category_id ,
                cat.category AS category_description ,

				cat.prevent_appts_ind as prevent_appt,

                ( SELECT TOP 1
                            event
                  FROM      [10.183.0.94].NGProd.dbo.events e
                  WHERE     e.event_id = cm.event_id
                ) AS event_description
        INTO    dbo.data_category_event
        FROM    [10.183.0.94].NGProd.dbo.[categories] cat LEFT join
		       [10.183.0.94].NGProd.dbo.[category_members] cm ON cm.category_id = cat.category_id 





END

GO
