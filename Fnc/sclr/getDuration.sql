SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jimmy Rüedi
-- Create date: 18.08.2017
-- Description:	berechnet aus zwei Zeiten die Differenz und gibt diese als String aus
-- =============================================
CREATE FUNCTION getDuration (
	@Start DATETIME
	,@End DATETIME
	)
RETURNS VARCHAR(128)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Duration VARCHAR(1024)
		,@DurationText VARCHAR(128)
		,@Earlier DATETIME
		,@Later DATETIME
		,@Neg varchar(1) = ''
	if @Start < @End 
	BEGIN 
		SELECT @Earlier = @Start, @Later = @End, @Neg = ''
	END ELSE
	BEGIN 
		SELECT @Later = @Start, @Earlier = @End, @Neg = '-'
		
	END

	SET @Duration = Datediff(second, @Earlier, @Later)

	SELECT @DurationText = @Neg +
		CASE 
			WHEN @Duration > (24 * 3600)
				THEN cast(@Duration / (24 * 3600) AS VARCHAR) + ' days ' + right('0' + cast(@Duration % (24 * 3600) / 3600 AS VARCHAR), 2) + ':' + right('0' + cast((@Duration % 3600) / 60 AS VARCHAR), 2) + ':' + right('0' + cast(@Duration % 60 AS VARCHAR), 2)
			ELSE right('0' + cast(@Duration % (24 * 3600) / 3600 AS VARCHAR), 2) + ':' + right('0' + cast((@Duration % 3600) / 60 AS VARCHAR), 2) + ':' + right('0' + cast(@Duration % 60 AS VARCHAR), 2)
			END;

	RETURN @DurationText
END
GO

