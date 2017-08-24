SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************/
-- Author:		 Jimmy Rüedi
-- Create date:  11.08.2017
-- Description:	 Gets the value to a key stored in the table iV_PROC_Parameters 
--
-- Change Hist:  
/***************************************************************************************************/
CREATE FUNCTION [dbo].[GetProcPrm]
(
	 @prmID  varchar(50) -- Schlüssel, zu dem der Wert
	,@Active bit = 1       -- um notfalls auch inaktive anzeigen zu können (falls das mal notwendig sein sollte)
)
RETURNS varchar(2048)
AS
BEGIN
	DECLARE @Result varchar(2048)

	SELECT @Result = isnull(prmValue,'') from iV_PROC_Parameters WHERE prmID = @prmID and prmActive = 1

	RETURN @Result

END
GO


