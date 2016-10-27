SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <Create Date, ,>
-- Description:	Returns 1 if ICD code is an exclusionary dx for hedis crc scoring
-- =============================================
CREATE FUNCTION [dbo].[bilateral_mastectomy_dx](@dx VARCHAR(10))  
RETURNS int   
AS   

BEGIN  
    DECLARE @ret int;  
    SELECT @ret = CASE          --Codes for bilateral mastectomoy. As unilateral is calculated separately
					WHEN @dx IN('85.42','85.44','85.46','85.48') 
								THEN 1
					ELSE 0
				  END 
    RETURN @ret;  
END;  


GO
