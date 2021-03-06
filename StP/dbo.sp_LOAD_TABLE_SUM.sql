SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- Change Hist: 01.09.2017 Jimmy Rüedi
--              Removed the fully qualified table adressing of the containing database  
--              Change from direct access to [INTEXSALES].[OdloDE] to [IFC_Cache]
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_SUM]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_SUM]

	COMMIT TRANSACTION

	BEGIN TRANSACTION /****************************** LOAD ALL SALES_REPS **********************************/

	INSERT INTO [dbo].[iV_SUM] (
		[SalesRegion]
		,[SalesRegionCode]
		,[SR_Code]
		,[FirstName]
		,[LastName]
		,[UserType]
		,[Speciality]
		,[Address1]
		,[Address2]
		,[Address3]
		,[City]
		,[State]
		,[Zip]
		,[Country]
		,[Phone]
		,[Fax]
		,[Email]
		,[CanSubmitOrders]
		,[RegionRestriction]
		,[StoreRestricted]
		,[RetailAccountNumber]
		,[ActionCode]
		,[LOAD_DATE]
		)
	SELECT [SalesRegionCode] AS [SalesRegion] --LEFT(ltrim(rtrim(zeile)), 20) --'ODLO' as [SalesRegion]
		,[SalesRegionCode] AS [SalesRegionCode]
		,[VersNr] AS [SR_Code]
		,CASE 
			WHEN ltrim(rtrim([Name2])) = ''
				THEN 'unknwn'
			WHEN ltrim(rtrim([Name2])) IS NULL
				THEN 'unknwn'
			ELSE ltrim(rtrim([Name2]))
			END AS [FirstName]
		,CASE 
			WHEN ltrim(rtrim([Name1])) = ''
				THEN 'unknwn'
			WHEN ltrim(rtrim([Name1])) IS NULL
				THEN 'unknwn'
			ELSE ltrim(rtrim([Name1]))
			END AS [LastName]
		,'SR' AS UserType
		,NULL AS Speciality
		,NULL AS [Address1]
		,NULL AS [Address2]
		,NULL AS [Address3]
		,NULL AS [City]
		,NULL AS [State]
		,NULL AS [Zip]
		,NULL AS [Country]
		,NULL AS [Phone]
		,NULL AS [Fax]
		,CASE 
			WHEN [EMailAdr] = ''
				THEN 'info@odlo.com'
			WHEN [EMailAdr] IS NULL
				THEN 'info@odlo.com'
			ELSE ltrim(rtrim(LEFT([EMailAdr], 60)))
			END AS [Email]
		,CASE 
			WHEN [AktivJN] = 'J'
				THEN 1
			ELSE 0
			END AS [CanSubmitOrders]
		,0 AS [RegionRestriction]
		,1 AS [StoreRestricted]
		,NULL AS [RetailAccountNumber]
		,CASE 
			WHEN [AktivJN] = 'J'
				THEN 'UP'
			ELSE 'DIS'
			END AS [ActionCode]
		,getDate() AS [LOAD_DATE]
	--START JRU 31.08.2017 change the datasource to IFC_Cache
	--FROM [INTEXSALES].[OdloDE].[dbo].[VerStamm]
	FROM [IFC_Cache].[dbo].[VerStamm]
	--END  JRU 31.08.2017 change the datasource to IFC_Cache
		,		
		(
			SELECT DISTINCT [SR_Code] /********************* one salesrep has customers from different companytype and needs therefore to be doubled *************/
				,[SalesRegionCode]
			FROM [dbo].[iV_CM]
			) AS csr
	WHERE [VersKey] = '01'
		AND [VersNr] = [SR_Code]
		AND [AktivJN] = 'J'

	COMMIT TRANSACTION


	BEGIN TRANSACTION

		INSERT INTO [dbo].[iV_SUM] (
		[SalesRegion]
		,[SalesRegionCode]
		,[SR_Code]
		,[FirstName]
		,[LastName]
		,[UserType]
		,[Speciality]
		,[Address1]
		,[Address2]
		,[Address3]
		,[City]
		,[State]
		,[Zip]
		,[Country]
		,[Phone]
		,[Fax]
		,[Email]
		,[CanSubmitOrders]
		,[RegionRestriction]
		,[StoreRestricted]
		,[RetailAccountNumber]
		,[ActionCode]
		,[LOAD_DATE]
		)
	SELECT 'ODLO' AS [SalesRegion] --LEFT(ltrim(rtrim(zeile)), 20) --'ODLO' as [SalesRegion]
		,'ODLO' AS [SalesRegionCode]
		,[VersNr] AS [SR_Code]
		,CASE 
			WHEN ltrim(rtrim([Name2])) = ''
				THEN 'unknwn'
			WHEN ltrim(rtrim([Name2])) IS NULL
				THEN 'unknwn'
			ELSE ltrim(rtrim([Name2]))
			END AS [FirstName]
		,CASE 
			WHEN ltrim(rtrim([Name1])) = ''
				THEN 'unknwn'
			WHEN ltrim(rtrim([Name1])) IS NULL
				THEN 'unknwn'
			ELSE ltrim(rtrim([Name1]))
			END AS [LastName]
		,'SR' AS UserType
		,NULL AS Speciality
		,NULL AS [Address1]
		,NULL AS [Address2]
		,NULL AS [Address3]
		,NULL AS [City]
		,NULL AS [State]
		,NULL AS [Zip]
		,NULL AS [Country]
		,NULL AS [Phone]
		,NULL AS [Fax]
		,CASE 
			WHEN [EMailAdr] = ''
				THEN 'info@odlo.com'
			WHEN [EMailAdr] IS NULL
				THEN 'info@odlo.com'
			ELSE ltrim(rtrim(LEFT([EMailAdr], 60)))
			END AS [Email]
		,CASE 
			WHEN [AktivJN] = 'J'
				THEN 1
			ELSE 0
			END AS [CanSubmitOrders]
		,0 AS [RegionRestriction]
		,1 AS [StoreRestricted]
		,NULL AS [RetailAccountNumber]
		,CASE 
			WHEN [AktivJN] = 'J'
				THEN 'UP'
			ELSE 'DIS'
			END AS [ActionCode]
		,getDate() AS [LOAD_DATE]
	--START JRU 31.08.2017 change the datasource to IFC_Cache
	--FROM [INTEXSALES].[OdloDE].[dbo].[VerStamm]
	FROM [IFC_Cache].[dbo].[VerStamm]
	--END  JRU 31.08.2017 change the datasource to IFC_Cache
	WHERE [VersKey] = '01'
		AND [AktivJN] = 'N'

	COMMIT TRANSACTION



END
GO
