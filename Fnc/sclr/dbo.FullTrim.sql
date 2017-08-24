USE CST_ITF

DROP FUNCTION dbo.FullTrim
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************/
-- Author:		 Jimmy Rüedi
-- Create date:  09.08.2017
-- Description:	 Trims a value left and right and give a replacement value, when the string remains 
--               empty
-- Change Hist:  
/***************************************************************************************************/
CREATE FUNCTION dbo.FullTrim
(
	 @trimString nvarchar(2048) -- Wert, der Getrimmt werden soll
	,@replacementString nvarchar(2048) -- Wert der zurückgegeben wird, wenn nach dem Trimmen der String leer ist
)
RETURNS nvarchar(2048)
AS
BEGIN
	DECLARE @Result nvarchar(2048)

	SELECT @Result =
	CASE 
			WHEN ltrim(rtrim(@trimString)) = ''
				THEN @replacementString
			ELSE ltrim(rtrim(@trimString))
			END 

	RETURN @Result

END
GO

