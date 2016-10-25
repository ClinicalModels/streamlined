SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create FUNCTION [dbo].[diabetes_dx](@dx VARCHAR(10))

RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @return int 
	
  
	SET @return =	CASE 
					WHEN @dx IN (
					--ICD 10 for diabetes based on UDS 2016 standards
					 '250.%',  '648.0x%','E10.10', 'E10.11',
					 'E10.29', 'E10.311','E10.319', 'E10.36',
					 'E10.39', 'E10.39','E10.40', 'E10.51',
					 'E10.618', 'E10.620','E10.621', 'E10.622',
					 'E10.628', 'E10.30','E10.638', 'E10.641',
					 'E10.649', 'E10.65','E10.69',  'E10.8',
					 'E10.9', 'E11.00','E11.01', 'E11.29',
					 'E11.311', 'E11.319','E11.36', 'E11.39',
					 'E11.40',  'E11.51','E11.618', 'E11.620',
					 'E11.621', 'E11.622', 'E11.628', 'E11.630',
					 'E11.638', 'E11.641','E11.649', 'E11.65',
					 'E11.69', 'E11.8','E11.9','E13.10')



					THEN 1
					ELSE 0
				END 

	
	RETURN @return
END

GO
