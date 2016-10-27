SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_keys]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	

	UPDATE dx
		SET
			dx.enc_appt_key=app.enc_appt_key
	FROM dbo.data_dx dx
	LEFT JOIN dbo.data_appointment app ON app.enc_id=dx.enc_id


END
GO
