SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <Create Date, ,>
-- Description:	Returns 1 if ICD code is an exclusionary dx for hedis crc scoring
-- =============================================
create FUNCTION [dbo].[unilateral_mastectomy_dx](@dx VARCHAR(10))  
RETURNS int   
AS   

BEGIN  
    DECLARE @ret int;  
    SELECT @ret = CASE          --Codes for bilateral mastectomoy. As unilateral is calculated separately
					WHEN @dx IN('85.41','85.43','85.45','85.47') 
								THEN 1
					ELSE 0
				  END 
    RETURN @ret;  
END;  


GO
