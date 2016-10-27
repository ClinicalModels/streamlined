SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <Create Date, ,>
-- Description:	Returns 1 if ICD code is an exclusionary dx for hedis crc scoring
-- =============================================
create FUNCTION [dbo].[pregnant_esrd_dx](@dx VARCHAR(10))  
RETURNS int   
AS   

BEGIN  
    DECLARE @ret int;  
    SELECT @ret = CASE          --Codes for Pregancy and renal failure
					WHEN @dx IN('N18.6%','N18.6%','N18.6%','N18.6%','N18.6%', 'N18.6%','N18.6%', 'N18.6%','N18.6%','N18.6%','Z34%','Z3A%') THEN 1
					ELSE 0
				  END 
    RETURN @ret;  
END;  


GO
