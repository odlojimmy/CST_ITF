SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_ROSFD]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_ROSFD]

	COMMIT TRANSACTION

-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================

/*
	BEGIN TRANSACTION /****************************** LOAD ALL IN **********************************/

	INSERT INTO [dbo].[iV_ROSFD] (
		[CAccountNum]
		,[ShipAccountNum]
		,[LineTypeCode]
		,[Amount]
		,[Units]
		,[ReportYear]
		,[ReportMonth]
		,[ReportingCategory]
		,[ActionCode]
		,[LOAD_DATE]
		)
	SELECT SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_CUSTOMER_NUMBER AS [CAccountNum]
		,NULL AS [ShipAccountNum]
		,'Order' AS [LineTypeCode]
		,sum(SPOT_APL.dbo.FORD_ORDERS.FORD_CST_NET) AS [Amount]
		,sum(SPOT_APL.dbo.FORD_ORDERS.FORD_QUANTITY) AS [Units]
		,SPOT_APL.dbo.DDAT_DATE.DDAT_CALENDAR_YEAR_NUMBER AS [ReportYear]
		,SPOT_APL.dbo.DDAT_DATE.DDAT_CALENDAR_MONTH_NUMBER AS [ReportMonth]
		,SPOT_APL.dbo.DART_ARTICLE.DART_SUBGROUP_DESC + '~' + UPPER(SPOT_APL.dbo.DART_ARTICLE.DART_GENDER_DESC) AS [ReportingCategory]
		,'UP' AS [ActionCode]
		,getDate() AS [LOAD_DATE]
	FROM SPOT_APL.dbo.DART_ARTICLE
	LEFT OUTER JOIN SPOT_APL.dbo.FORD_ORDERS ON (SPOT_APL.dbo.FORD_ORDERS.DART_SID = SPOT_APL.dbo.DART_ARTICLE.DART_SID)
	RIGHT OUTER JOIN SPOT_APL.dbo.DDAT_DATE ON (SPOT_APL.dbo.FORD_ORDERS.DDAT_ORDER_DATE_SID = SPOT_APL.dbo.DDAT_DATE.DDAT_SID)
	RIGHT OUTER JOIN SPOT_APL.dbo.DCUS_CUSTOMER_ACT ON (SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_SID = SPOT_APL.dbo.FORD_ORDERS.DCUS_SHIPPING_ACT_SID)
	RIGHT OUTER JOIN SPOT_APL.dbo.DORT_ORDER_TYPE ON (SPOT_APL.dbo.DORT_ORDER_TYPE.DORT_SID = SPOT_APL.dbo.FORD_ORDERS.DORT_SID)
	WHERE (
			SPOT_APL.dbo.DORT_ORDER_TYPE.DORT_REP_ORDER_VIEW_GROUP IN ('IN')
			AND SPOT_APL.dbo.DART_ARTICLE.DART_CATEGORY_GROUP IN ('COLLECTION')
			AND SPOT_APL.dbo.DDAT_DATE.[DDAT_RELATIVE_ODLO_BUSINESS_YEAR] IN (
				0
				,- 1
				,- 2
				)
			AND SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_CUSTOMER_NUMBER IN (
				SELECT DISTINCT [CAccountNum]
				FROM [dbo].[iV_CM]
				)
			)
	GROUP BY SPOT_APL.dbo.DCUS_CUSTOMER_ACT.DCUS_CUSTOMER_NUMBER
		,SPOT_APL.dbo.DDAT_DATE.DDAT_CALENDAR_MONTH_NUMBER
		,SPOT_APL.dbo.DDAT_DATE.DDAT_CALENDAR_YEAR_NUMBER
		,SPOT_APL.dbo.DART_ARTICLE.DART_SUBGROUP_DESC
		,SPOT_APL.dbo.DART_ARTICLE.DART_GENDER_DESC

	COMMIT TRANSACTION


	BEGIN TRANSACTION

	DELETE FROM [dbo].[iV_ROSFD]
	WHERE [Units] = 0

	COMMIT TRANSACTION

	*/

END
GO
