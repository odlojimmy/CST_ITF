SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_Load_ODLO_Season_Controller]

AS
BEGIN
	SET NOCOUNT ON;

	--only purpose is to update the season in the table RetailPro_Config
	
	DECLARE @Season_REAS varchar(8);
	DECLARE @Season_PREO1 varchar(8);
	DECLARE @Season_PREO2 varchar(8);

	--get the season from the season master table
	set @Season_REAS = (Select DSEA_KEY from [GENERAL_CHECK_Reports].[dbo].[SYSTEM_SEASON_RANGES] where JOB = 'CST_REAS')
	set @Season_PREO1 = (Select DSEA_KEY from [GENERAL_CHECK_Reports].[dbo].[SYSTEM_SEASON_RANGES] where JOB = 'CST_PREO1')
	set @Season_PREO2 = (Select DSEA_KEY from [GENERAL_CHECK_Reports].[dbo].[SYSTEM_SEASON_RANGES] where JOB = 'CST_PREO2')
	--verify content
	print @Season_REAS
	print @Season_PREO1
	print @Season_PREO2
	--update retail pro interface with the right season
	Update [ODLO_Season_Controller] set [SeasonKey] = @Season_REAS, [Season]  = @Season_REAS where [SeasonType] = 'REAS'
	Update [ODLO_Season_Controller] set [SeasonKey] = @Season_PREO1, [Season] = @Season_PREO1 where [SeasonType] = 'PREO1'
	Update [ODLO_Season_Controller] set [SeasonKey] = @Season_PREO2, [Season] = @Season_PREO2 where [SeasonType] = 'PREO2'



END 
GO
