SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_TPS]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_TPS]

COMMIT TRANSACTION

-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================


/*
BEGIN TRANSACTION  /****************************** LOAD ALL IN **********************************/

INSERT INTO [dbo].[iV_TPS]
           ([ItemNumber]
           ,[ProductName]
           ,[Volume]
           ,[ActionCode]
           ,[LOAD_DATE])
SELECT an as [ItemNumber]
	,'placeholder' as [ProductName]
	,CONVERT([int], (100*Units/(sum(Units) OVER (PARTITION BY 1)))) as [Volume]
	,'UP' as [ActionCode]
	,getDate() as [LOAD_DATE]
FROM (
	SELECT an
		,Units
		,ROW_NUMBER() OVER (ORDER BY Units DESC) AS rn
	FROM (
		SELECT SPOT_APL.dbo.DART_ARTICLE.DART_ARTICLE_NUMBER AS an
			,sum(SPOT_APL.dbo.FORD_ORDERS.FORD_QUANTITY) AS Units
		FROM SPOT_APL.dbo.DSEA_SEASON
		LEFT OUTER JOIN SPOT_APL.dbo.FORD_ORDERS ON (SPOT_APL.dbo.FORD_ORDERS.DSEA_SID = SPOT_APL.dbo.DSEA_SEASON.DSEA_SID)
		RIGHT OUTER JOIN SPOT_APL.dbo.DART_ARTICLE ON (SPOT_APL.dbo.FORD_ORDERS.DART_SID = SPOT_APL.dbo.DART_ARTICLE.DART_SID)
		RIGHT OUTER JOIN SPOT_APL.dbo.DCUS_CUSTOMER_ACT ON (SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_SID = SPOT_APL.dbo.FORD_ORDERS.DCUS_SHIPPING_ACT_SID)
		RIGHT OUTER JOIN SPOT_APL.dbo.DCUR_CURRENCY ON (SPOT_APL.dbo.DCUR_CURRENCY.DCUR_SID = SPOT_APL.dbo.FORD_ORDERS.DCUR_CST_SID)
		RIGHT OUTER JOIN SPOT_APL.dbo.DORT_ORDER_TYPE ON (SPOT_APL.dbo.DORT_ORDER_TYPE.DORT_SID = SPOT_APL.dbo.FORD_ORDERS.DORT_SID)
		WHERE (
				SPOT_APL.dbo.DORT_ORDER_TYPE.DORT_NUMBER IN (
					'H01'
					,'H04'
					)
				--AND SPOT_APL.dbo.DSEA_SEASON.DSEA_KEY IN ('011161H')
				--- added 04.08.2016/cls to avoid hardcoded seasons
				AND SPOT_APL.dbo.DSEA_SEASON.DSEA_KEY IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
				)
			AND SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_CUSTOMER_NUMBER IN (
				SELECT DISTINCT [CAccountNum]
				FROM [dbo].[iV_CM]
				)
			AND SPOT_APL.dbo.DART_ARTICLE.DART_ARTICLE_NUMBER IN (
				SELECT DISTINCT [ItemNumber]
				FROM [dbo].[iV_ST]
				)
			AND SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_CUSTOMER_NUMBER IN (
				'350020'
				,'100343'
				)
		GROUP BY SPOT_APL.dbo.DART_ARTICLE.DART_ARTICLE_NUMBER
		HAVING sum(SPOT_APL.dbo.FORD_ORDERS.FORD_QUANTITY) > 0
		) AS T1
	) AS T2
WHERE rn <= 50

COMMIT TRANSACTION


BEGIN TRANSACTION

UPDATE [dbo].[iV_TPS]
   SET [ProductName] = st.[ProductName]
 FROM  [dbo].[iV_TPS] tp, 
	(SELECT distinct [ItemNumber],[ProductName] FROM [dbo].[iV_ST] WHERE [SupplierCatalogKey] = (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
	) as st
 WHERE tp.[ItemNumber] = st.[ItemNumber]

COMMIT TRANSACTION

*/

END
GO
