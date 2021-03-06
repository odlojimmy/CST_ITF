SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- Change Hist:  01.09.2017 Jimmy Rüedi
--               Change from direct access to [INTEXSALES].[OdloDE] to [IFC_Cache]
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_DS_DD_main]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag_temp]

	TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag]

	TRUNCATE TABLE [dbo].[iV_D_list_Item_Color]

	TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt]

	TRUNCATE TABLE [dbo].[iV_DS]

	TRUNCATE TABLE [dbo].[iV_DD] 

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/****************************** list all season independent discounts (Saison IS NULL) **********************************/
	-------------------------------------------------------------------------------------------------
	--MPF - Fill in all generic customer discounts - without a linkage to a season - for Reorders
	-------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[iV_D_list_KuRabatt] (
		[tag]
		,[Saison]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,[NOSJN_customer]
		)
	SELECT '-' AS tag
		---,'011161H' AS [Saison] /************************ REAS Saison !! update when season changes !! **************************/
		--- added 04.08.2016/cls to avoid hardcoded seasons
		,(SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS') as [Season]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,'N' AS [NOSJN_customer]
	FROM [IFC_Cache].[dbo].[KuRabatt]
	WHERE [KustKey] = '01'
		AND Saison IS NULL

	-------------------------------------------------------------------------------------------------
	--MPF - Fill in all generic customer discounts - without a linkage to a season - for Preorder Season 1
	--(INACTIVE - NOT IMPLEMENTED - JUST TESTED AND PREPARED)
	--MPFYL 11/11/16 - Decision because of iVEnidx incapabilities to submit only discounts for reorder seasons
	--so below two inserts are commented out
	-------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[iV_D_list_KuRabatt] (
		[tag]
		,[Saison]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,[NOSJN_customer]
		)
	SELECT '-' AS tag
		---,'011162H' AS [Saison] /************************ PREORDER Saison !! update when season changes !! **************************/
		--- added 04.08.2016/cls to avoid hardcoded seasons
		,(SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1') as [Season]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,'N' AS [NOSJN_customer]
	FROM [IFC_Cache].[dbo].[KuRabatt]
	WHERE [KustKey] = '01'
		AND Saison IS NULL

	-------------------------------------------------------------------------------------------------
	--MPF - Fill in all generic customer discounts - without a linkage to a season - for Preorder Season 2
	-------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[iV_D_list_KuRabatt] (
		[tag]
		,[Saison]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,[NOSJN_customer]
		)
	SELECT '-' AS tag
		---,'011171H' AS [Saison] /************************ PREORDER Saison !! update when season changes !! **************************/
		--- added 04.08.2016/cls to avoid hardcoded seasons
		,(SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2') as [Season]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,'N' AS [NOSJN_customer]
	FROM [IFC_Cache].[dbo].[KuRabatt]
	WHERE [KustKey] = '01'
		AND Saison IS NULL


	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/****************************** list all strictly season dependent discounts **********************************/

	-------------------------------------------------------------------------------------------------
	--MPF - Fill in all season dependent discounts - fill in all three seasons
	-------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[iV_D_list_KuRabatt] (
		[tag]
		,[Saison]
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,[NOSJN_customer]
		)
	SELECT '-' AS tag
		,[Saison] 
		,[KusNr]
		,[ProdLine]
		,[Division]
		,[NOSJN]
		,[ArtsNr1]
		,[Rabatt]
		,'N' AS [NOSJN_customer]
	FROM [IFC_Cache].[dbo].[KuRabatt]
	WHERE [KustKey] = '01'
		--MPFYL 11/11/16: Decision because of iVenidx incapabilities to submit only discounts for reorder seasons
		--therefore the below season restriction is adjusted on REORDER only 
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND Saison IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		--MPFYL 11/11/16 (INACTIVE - NOT IMPLEMENTED - JUST TESTED AND PREPARED)
		--AND Saison IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		
	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/* delete non-B2B customers*/

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE KusNr NOT IN (
			SELECT DISTINCT [CAccountNum]
			FROM [dbo].[iV_CM]
			)

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/* delete where discount is 0 ***/

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE Rabatt = 0

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/* remove double entries */

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE AUTOID NOT IN (
			SELECT MIN(AUTOID)
			FROM [dbo].[iV_D_list_KuRabatt]
			GROUP BY [tag]
				,[Saison]
				,[KusNr]
				,[ProdLine]
				,[Division]
				,[NOSJN]
				,[ArtsNr1]
				,[Rabatt]
			)

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	UPDATE [dbo].[iV_D_list_KuRabatt] /*** no restrictions - all articles ***/
	SET tag = '2'
	WHERE NOSJN = 'N'
		AND ArtsNr1 IS NULL
		AND ProdLine IS NULL
		AND Division IS NULL
		AND tag = '-';

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	UPDATE [dbo].[iV_D_list_KuRabatt]
	SET tag = '3'
	WHERE NOSJN = 'N'
		AND ArtsNr1 IS NULL
		AND ProdLine IS NULL
		AND Division IS NOT NULL /*** only division ***/
		AND tag = '-';

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	UPDATE [dbo].[iV_D_list_KuRabatt]
	SET tag = '4'
	WHERE NOSJN = 'N'
		AND ArtsNr1 IS NULL
		AND ProdLine IS NOT NULL /*** only subgroup ***/
		AND Division IS NULL
		AND tag = '-';

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	UPDATE [dbo].[iV_D_list_KuRabatt]
	SET tag = '5'
	WHERE NOSJN = 'N'
		AND ArtsNr1 IS NULL
		AND ProdLine IS NOT NULL /*** subgroup and division combined ***/
		AND Division IS NOT NULL
		AND tag = '-';

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	UPDATE [dbo].[iV_D_list_KuRabatt]
	SET tag = '6'
	WHERE NOSJN = 'N'
		AND ArtsNr1 IS NOT NULL /*** List of Articles ***/
		AND ProdLine IS NULL
		AND Division IS NULL
		AND tag = '-';

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	UPDATE [dbo].[iV_D_list_KuRabatt]
	SET tag = '7'
	WHERE NOSJN = 'J' /*** NOS = J ***/
		AND ArtsNr1 IS NULL
		AND ProdLine IS NULL
		AND Division IS NULL
		AND tag = '-';

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/***************************** clean out redundant discounts *************************/

	/***************************** ********************************************** *************************/
	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE [dbo].[iV_D_list_KuRabatt].[tag] = 3 /*** delete all divisonal discounts lower or equal ************/
		AND EXISTS (
			SELECT [Saison]
				,[KusNr]
				,[Rabatt]
			FROM (
				SELECT [Saison]
					,[KusNr]
					,[Rabatt]
				FROM [dbo].[iV_D_list_KuRabatt]
				WHERE [tag] = 2
				) temt
			WHERE [dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
				AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
				AND [dbo].[iV_D_list_KuRabatt].[Rabatt] <= temt.Rabatt
			)

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE [dbo].[iV_D_list_KuRabatt].[tag] = 4 /*** delete all subgroup discounts lower or equal ************/
		AND EXISTS (
			SELECT [Saison]
				,[KusNr]
				,[Rabatt]
			FROM (
				SELECT [Saison]
					,[KusNr]
					,[Rabatt]
				FROM [dbo].[iV_D_list_KuRabatt]
				WHERE [tag] = 2
				) temt
			WHERE [dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
				AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
				AND [dbo].[iV_D_list_KuRabatt].[Rabatt] <= temt.Rabatt
			)

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE [dbo].[iV_D_list_KuRabatt].[tag] = 5 /*** delete all divisional-subgroup discounts lower or equal ************/
		AND EXISTS (
			SELECT [Saison]
				,[KusNr]
				,[Rabatt]
			FROM (
				SELECT [Saison]
					,[KusNr]
					,[Rabatt]
				FROM [dbo].[iV_D_list_KuRabatt]
				WHERE [tag] = 2
				) temt
			WHERE [dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
				AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
				AND [dbo].[iV_D_list_KuRabatt].[Rabatt] <= temt.Rabatt
			)

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE [dbo].[iV_D_list_KuRabatt].[tag] = 6 /*** delete all specific article discounts lower or equal ************/
		AND EXISTS (
			SELECT [Saison]
				,[KusNr]
				,[Rabatt]
			FROM (
				SELECT [Saison]
					,[KusNr]
					,[Rabatt]
				FROM [dbo].[iV_D_list_KuRabatt]
				WHERE [tag] = 2
				) temt
			WHERE [dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
				AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
				AND [dbo].[iV_D_list_KuRabatt].[Rabatt] <= temt.Rabatt
			)

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt]
	WHERE [dbo].[iV_D_list_KuRabatt].[tag] = 7 /*** delete all NOS discounts lower or equal ************/
		AND EXISTS (
			SELECT [Saison]
				,[KusNr]
				,[Rabatt]
			FROM (
				SELECT [Saison]
					,[KusNr]
					,[Rabatt]
				FROM [dbo].[iV_D_list_KuRabatt]
				WHERE [tag] = 2
				) temt
			WHERE [dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
				AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
				AND [dbo].[iV_D_list_KuRabatt].[Rabatt] <= temt.Rabatt
			)

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION 
	/******************************* split NOS discount customers from non-NOS customers **********************/

	UPDATE [dbo].[iV_D_list_KuRabatt]
	SET [NOSJN_customer] = 'J'
	FROM [dbo].[iV_D_list_KuRabatt] k
		,(
			SELECT [Saison]
				,[KusNr]
			FROM [dbo].[iV_D_list_KuRabatt]
			WHERE [tag] = 7
			) AS temt
	WHERE k.[Saison] = temt.[Saison]
		AND k.[KusNr] = temt.[KusNr]

	--COMMIT TRANSACTION

	/**************************************************************************************************************/
	--START MPFYL 06/11/16
	--due to weired discounts in Intex, certain disocunts needs to be delete (two scenarios below)
	/**************************************************************************************************************/
	--Delete dublicate TAG2 records
	-- TAG2 means, discounts on saison level. It can happen that customer service specifies dicounts without a season and discounts based on a season.
	-- so iVendix might have two different discounts. the lower disocunt gets removed
	DELETE
		FROM [dbo].[iV_D_list_KuRabatt]
		WHERE tag = '2' and EXISTS (
				SELECT  [tag],[Saison],[KusNr],[ProdLine],[Division],[NOSJN],[ArtsNr1],[NOSJN_customer], [rabatt]
				FROM (
					SELECT  [tag],[Saison],[KusNr],[ProdLine],[Division],[NOSJN],[ArtsNr1],[NOSJN_customer], min(rabatt) as [rabatt]
					FROM [dbo].[iV_D_list_KuRabatt]
					GROUP BY [tag],[Saison],[KusNr],[ProdLine],[Division],[NOSJN],[ArtsNr1],[NOSJN_customer]
					HAVING (COUNT(*) > 1)
					) temt
				WHERE	[dbo].[iV_D_list_KuRabatt].[tag] = temt.[tag]
					AND	[dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
					AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
					--AND [dbo].[iV_D_list_KuRabatt].[ProdLine] = temt.ProdLine
					--AND [dbo].[iV_D_list_KuRabatt].[Division] = temt.Division
					AND [dbo].[iV_D_list_KuRabatt].[NOSJN] = temt.NOSJN
					--AND [dbo].[iV_D_list_KuRabatt].[ArtsNr1] = temt.ArtsNr1
					AND [dbo].[iV_D_list_KuRabatt].[NOSJN_customer] = temt.NOSJN_customer
					AND [dbo].[iV_D_list_KuRabatt].[Rabatt] = temt.Rabatt
				)

	--Delete dublicate TAG3 records
	-- TAG3 means, discounts on categorey level. It can happen that customer service specifies dicounts without a season on category level and discounts based on a season on category level.
	-- so iVendix might have two different discounts. the lower disocunt gets removed
	DELETE
		FROM [dbo].[iV_D_list_KuRabatt]
		WHERE tag = '3' and EXISTS (
				SELECT  [tag],[Saison],[KusNr],[ProdLine],[Division],[NOSJN],[ArtsNr1],[NOSJN_customer], [rabatt]
				FROM (
					SELECT  [tag],[Saison],[KusNr],[ProdLine],[Division],[NOSJN],[ArtsNr1],[NOSJN_customer], min(rabatt) as [rabatt]
					FROM [dbo].[iV_D_list_KuRabatt]
					GROUP BY [tag],[Saison],[KusNr],[ProdLine],[Division],[NOSJN],[ArtsNr1],[NOSJN_customer]
					HAVING (COUNT(*) > 1)
					) temt
				WHERE	[dbo].[iV_D_list_KuRabatt].[tag] = temt.[tag]
					AND	[dbo].[iV_D_list_KuRabatt].[Saison] = temt.Saison
					AND [dbo].[iV_D_list_KuRabatt].[KusNr] = temt.KusNr
					--AND [dbo].[iV_D_list_KuRabatt].[ProdLine] = temt.ProdLine
					AND [dbo].[iV_D_list_KuRabatt].[Division] = temt.Division
					AND [dbo].[iV_D_list_KuRabatt].[NOSJN] = temt.NOSJN
					--AND [dbo].[iV_D_list_KuRabatt].[ArtsNr1] = temt.ArtsNr1
					AND [dbo].[iV_D_list_KuRabatt].[NOSJN_customer] = temt.NOSJN_customer
					AND [dbo].[iV_D_list_KuRabatt].[Rabatt] = temt.Rabatt
				)

	--END MPFYL 06/11/16

	--START MPFYL 07/11/16
	--WORKAROUND (to remove different discounts per season) - needs a better workaround than that
	--NEW workaround in proc - discountDetail - remove at the end
	--DELETE [dbo].[iV_D_list_KuRabatt] WHERE KusNr in ('7007027','700002','700003','700011','7007156','7007233','730006','730041','730101','730133','730227','730437','730591')
	--END MPFYL 07/11/16


		--START MPFYL 08/11/16
	--Fills into the customer discount table a unique discount set
	--one discountset can belong to one or multiple customers
	--this discountset are used further down to keep the export files as small as possible
	EXEC [dbo].[sp_LOAD_TABLE_DS_DD_Sets] 
	--END MPFYL 08/11/16
	

	/**************************************************************************************************************/
	/********************************* not NOS discounts **********************************************************/
	/**************************************************************************************************************/
	--BEGIN TRANSACTION

	EXEC [dbo].[sp_LOAD_TABLE_DS_DD_NOS_N] /*********** prepare all dicount combinations *************/

	--COMMIT TRANSACTION

	--START MPFYL 08/11/16
	--Use the unique disocunt sets from customer discounts and update the customer discount ds tag table	
	--the below insert statemetns are newly based on the unique discount set and not on customer number or discount value
	--BEGIN TRANSACTION	
	UPDATE  AAA
		SET AAA.[ds-exp] = BBB.[ds_set]
		FROM [dbo].[iV_D_list_KuRabatt_DS-tag] as AAA
			INNER JOIN [dbo].[iV_D_list_KuRabatt] as BBB ON AAA.kusNr = BBB.kusNr
	--COMMIT TRANSACTION
	--END MPFYL 08/11/16	


	--BEGIN TRANSACTION

	/******************************* DS-2 ***************************************/
	INSERT INTO [dbo].[iV_DS] (
		[CAccountNum]
		,[DiscountSchedule]
		,[LOAD_DATE]
		)
	SELECT DISTINCT [KusNr]
		--,'B' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + LEFT(CONVERT(VARCHAR(80), [Rabatt]), (DATALENGTH(CONVERT(VARCHAR(80), [Rabatt])) - 2))
		--MPFYL 08/11/16
		,'B' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + '-' + [ds-exp]
		,getDate() AS [LOAD_DATE]
	FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
	WHERE [DS-tag] = 'DS-2'

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	INSERT INTO [dbo].[iV_DD] (
		[DiscountSchedule]
		,[Discount]
		,[Identifier]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[SupplierCatalogKey]
		,[LOAD_DATE]
		)
	SELECT tempt.[DS] AS [DiscountSchedule]
		,tempt.Rabatt AS [Discount]
		,'1' AS [Identifier]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[SupplierCatalogKey]
		,getDate() AS [LOAD_DATE]
	FROM [dbo].[iV_ST] s
		,(
			--SELECT DISTINCT 'B' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + LEFT(CONVERT(VARCHAR(80), [Rabatt]), (DATALENGTH(CONVERT(VARCHAR(80), [Rabatt])) - 2)) AS [DS]
			--MPFYL 08/11/16
			SELECT DISTINCT 'B' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + '-' + [ds-exp] AS [DS]
				,Saison
				,ItemNumber
				,Rabatt
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [DS-tag] = 'DS-2'
			) tempt
	WHERE s.[SupplierCatalogKey] = tempt.[Saison]
		AND s.[ItemNumber] = tempt.[ItemNumber]

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	/******************************* DS-6 ****************************************/
	INSERT INTO [dbo].[iV_DS] (
		[CAccountNum]
		,[DiscountSchedule]
		,[LOAD_DATE]
		)
	SELECT DISTINCT [KusNr]
		--,'F' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + CONVERT(VARCHAR(80), [KusNr])
		--MPFYL 08/11/16
		,'F' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + '-' + [ds-exp]
		,getDate() AS [LOAD_DATE]
	FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
	WHERE [DS-tag] = 'DS-6'

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	INSERT INTO [dbo].[iV_DD] (
		[DiscountSchedule]
		,[Discount]
		,[Identifier]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[SupplierCatalogKey]
		,[LOAD_DATE]
		)
	SELECT tempt.[DS] AS [DiscountSchedule]
		,tempt.Rabatt AS [Discount]
		,'1' AS [Identifier]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[SupplierCatalogKey]
		,getDate() AS [LOAD_DATE]
	FROM [dbo].[iV_ST] s
		,(
			--SELECT DISTINCT 'F' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + CONVERT(VARCHAR(80), [KusNr]) AS [DS]
			--MPFYL 08/11/16
			SELECT DISTINCT 'F' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + '-' + [ds-exp] AS [DS]
				,Saison
				,ItemNumber
				,Rabatt
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [DS-tag] = 'DS-6'
			) tempt
	WHERE s.[SupplierCatalogKey] = tempt.[Saison]
		AND s.[ItemNumber] = tempt.[ItemNumber]

	--COMMIT TRANSACTION

	/**************************************************************************************************************/
	/********************************* with NOS discounts **********************************************************/
	/**************************************************************************************************************/
	--BEGIN TRANSACTION

	EXEC [dbo].[sp_LOAD_TABLE_DS_DD_NOS_J] /*********** prepare all dicount combinations *************/

	--COMMIT TRANSACTION


		------------------PART II--------------------***************************
	--START MPFYL 08/11/16
	--TEST with newly set DS SETS
	--update fill in the kurabatt_Ds_tag the ds_exp flag with the unique DS set number
	--BEGIN TRANSACTION	
	UPDATE  AAA
		SET AAA.[ds-exp] = BBB.[ds_set]
		FROM [dbo].[iV_D_list_KuRabatt_DS-tag] as AAA
			INNER JOIN [dbo].[iV_D_list_KuRabatt] as BBB ON AAA.kusNr = BBB.kusNr
	--COMMIT TRANSACTION
	--END MPFYL 08/11/16
	------------------PART II--------------------***************************



	/******************************* DS-7 ****************************************/
	--BEGIN TRANSACTION

	INSERT INTO [dbo].[iV_DS] (
		[CAccountNum]
		,[DiscountSchedule]
		,[LOAD_DATE]
		)
	SELECT DISTINCT [KusNr]
		--,'G' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + CONVERT(VARCHAR(80), [KusNr])
		--MPFYL 08/11/16
		,'G' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + '-' + [ds-exp]
		,getDate() AS [LOAD_DATE]
	FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
	WHERE [DS-tag] = 'DS-7'

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION

	INSERT INTO [dbo].[iV_DD] (
		[DiscountSchedule]
		,[Discount]
		,[Identifier]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[SupplierCatalogKey]
		,[LOAD_DATE]
		)
	SELECT tempt.[DS] AS [DiscountSchedule]
		,tempt.Rabatt AS [Discount]
		,'1' AS [Identifier]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[SupplierCatalogKey]
		,getDate() AS [LOAD_DATE]
	FROM [dbo].[iV_ST] s
		,(
			--SELECT DISTINCT 'G' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + CONVERT(VARCHAR(80), [KusNr]) AS [DS]
			--MPFYL 08/11/16
			SELECT DISTINCT 'G' + SUBSTRING(CONVERT(VARCHAR(80), [Saison]), 5, 2) + '-' + [ds-exp] AS [DS]
				,Saison
				,ItemNumber
				,[ColorCode]
				,Rabatt
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [DS-tag] = 'DS-7'
			) tempt
	WHERE s.[SupplierCatalogKey] = tempt.[Saison]
		AND s.[ItemNumber] = tempt.[ItemNumber]
		AND s.[ColorCode] = tempt.[ColorCode]

	--COMMIT TRANSACTION


	--START MPFYL 08/11/16
	--Workaround, remove different discounts for on the same EAN for two different seasons as iVendix can not handle that. SImply remove full disocunt set


	--END MPFYL 08/11/16




END

GO
