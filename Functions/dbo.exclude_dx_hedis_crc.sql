SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <Create Date, ,>
-- Description:	Returns 1 if ICD code is an exclusionary dx for hedis crc scoring
-- =============================================
CREATE FUNCTION [dbo].[exclude_dx_hedis_crc](@dx VARCHAR(10))  
RETURNS int   
AS   

BEGIN  
    DECLARE @ret int;  
    SELECT @ret = CASE          --Codes for colon cancer
					WHEN @dx IN('C18.%','C19.%','C20.%','C21.8','Z85.038','Z85.048',
								--Codes for Colectomy --V45.89, Z98.89
								'Z90.49') 
								THEN 1
					ELSE 0
				  END 
    RETURN @ret;  
END;  


GO
