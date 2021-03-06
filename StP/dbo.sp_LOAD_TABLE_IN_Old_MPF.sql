SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_IN_Old_MPF]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_IN_hlp_ean]

	TRUNCATE TABLE [dbo].[iV_IN_hlp_FeLa]

	TRUNCATE TABLE [dbo].[iV_IN_hlp_Order]

	TRUNCATE TABLE [dbo].[iV_IN_hlp_PO]

	TRUNCATE TABLE [dbo].[iV_IN]

	COMMIT TRANSACTION

	BEGIN TRANSACTION  /********************************** get all ean combinations per season **************************************/

	INSERT INTO [dbo].[iV_IN_hlp_ean] (
		[SupplierCatalogKey]
		,[SeasonDefault]
		,[SKU]
		,[EAN]
		,[AvailableCheck_dt]
		,[Available_dt]
		,[LOAD_DATE]
		)
SELECT ltrim(rtrim(ArtS.[ArtsKey])) AS [SupplierCatalogKey]
	,tp.[defaultjn] AS [SeasonDefault]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,CONVERT(VARCHAR(10),[VerfuegbarAb] , 112) AS [AvailableCheck_dt]
		,CONVERT(VARCHAR(10),[LieferbarAb] , 112) AS [Available_dt]
		,getDate() AS [LOAD_DATE]
	FROM [INTEXSALES].[OdloDE].[dbo].[ArtEAN] ean WITH(READPAST)
		,[INTEXSALES].[OdloDE].[dbo].[ArtFarben] af WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtStamm ArtS WITH(READPAST)
		LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TaPosi tp ON (tp.tanr = 3 AND tp.tapkey = '011' AND SUBSTRING(ArtS.[ArtsKey], 4, 3) = tp.[tpwert])
	WHERE af.[ArtsKey] = ean.[ArtsKey]
		AND af.[ArtsNr1] = ean.[ArtsNr1]
		AND af.[ArtsNr2] = ean.[ArtsNr2]
		AND af.[VerkFarbe] = ean.[VerkFarbe]
		AND af.[ArtsKey] = ArtS.[ArtsKey]
		AND af.[ArtsNr1] = ArtS.[ArtsNr1]
		AND af.[ArtsNr2] = ArtS.[ArtsNr2]
		AND ArtS.[GGanKey] = ean.[GGanKey]
		AND ArtS.[GGNr] = ean.[GGNr]
		--- added 04.08.2016/cls to avoid hardcoded seasons
		---AND ArtS.[ArtsKey] IN ('011161H','011162H','011171H')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)

	COMMIT TRANSACTION

	BEGIN TRANSACTION /********************************** get free stock per season **************************************/

	INSERT INTO [dbo].[iV_IN_hlp_FeLa] (
		[SupplierCatalogKey]
		,[SKU]
		,[EAN]
		,[InventorySource_cd]
		,[Inventory]
		,[LOAD_DATE]
		)
	SELECT ltrim(rtrim(lg.[ArtsKey])) AS [SupplierCatalogKey]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,lg.LagerOrt as [InventorySource_cd]
		,lg.[Bestand] AS [Inventory]
		,getDate() AS [LOAD_DATE]
	FROM [INTEXSALES].[OdloDE].[dbo].[FeLager] lg WITH(READPAST)
		,[INTEXSALES].[OdloDE].[dbo].[ArtEAN] ean WITH(READPAST)
	WHERE lg.[ArtsKey] = ean.[ArtsKey]
		AND lg.[ArtsNr1] = ean.[ArtsNr1]
		AND lg.[ArtsNr2] = ean.[ArtsNr2]
		AND lg.[VerkFarbe] = ean.[VerkFarbe]
		AND lg.[GGanKey] = ean.[GGanKey]
		AND lg.[GGNr] = ean.[GGNr]
		AND lg.[Gr] = ean.[Gr]
		AND lg.LagKey = '01'
		AND lg.LagerOrt in ('800','0CA')
		AND lg.Bestand > 0
		AND lg.[Etikett] = '000'
		---AND lg.[ArtsKey] IN ('011161H','011162H','011171H')
		---AND ean.[ArtsKey] IN ('011161H','011162H','011171H') -- add season restriction to each table due to performance reasons!!!
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND lg.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)

	COMMIT TRANSACTION

	BEGIN TRANSACTION	/********************************** get all open orders per season **************************************/
						/**********************************           REAS SEASON          *************************************/
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
		[SupplierCatalogKey]
		,[SKU]
		,[EAN]
		,[InventorySource_cd]
		,[open_order_QTY]
		,[LOAD_DATE]
		)
	SELECT ltrim(rtrim(ArtS.[ArtsKey])) AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,ap.LagerOrt as [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km) AS [open_order_QTY]
		,getDate() AS [LOAD_DATE]
	FROM [INTEXSALES].[OdloDE].dbo.AufGroesse ag WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.AufKopf ak WITH(READPAST)
	LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] art ON (
			art.tanr = 41
			AND art.lfd = 14 -- Steuerung for Lager-Relevante Auftragsarten
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		,[INTEXSALES].[OdloDE].dbo.AufPosi ap WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtFarben af WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtStamm ArtS WITH(READPAST)
	LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] div ON (
			div.tanr = 600
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
		,[INTEXSALES].[OdloDE].dbo.ArtEAN ean WITH(READPAST)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.GGaGr gg ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE (
			ak.AufkNr = ap.AufkNr
			AND ak.AufkKey = ap.AufkKey
			)
		AND (
			ap.AufkNr = ag.AufkNr
			AND ap.AufkKey = ag.AufkKey
			AND ap.OrderBlatt = ag.OrderBlatt
			AND ap.AufPNr = ag.AufPNr
			)		
		AND (
			ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		AND (
			ean.ArtsNr1 = af.ArtsNr1
			AND ean.ArtsNr2 = af.ArtsNr2
			AND ean.ArtsKey = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr] = ArtS.[GGNr]
			)
		AND ap.ArtsNr1 = ean.ArtsNr1
		AND ap.VerkFarbe = ean.VerkFarbe
		AND ag.Gr = ean.Gr
		AND ean.ArtsKey = ak.AufkKey
		AND div.stwert = 'SALES'
		AND art.[stwert] = 'J' -- Steuerung for Lager-Relevante Auftragsarten
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt in ('800')
		---AND ak.AufkKey IN ('011161H') -- add season restriction to each table due to performance reasons!!!
		---AND ap.AufkKey IN ('011161H')
		---AND ag.AufkKey IN ('011161H')
		---AND ean.[ArtsKey] IN ('011161H')
		---AND af.[ArtsKey] IN ('011161H')
		---AND ArtS.[ArtsKey] IN ('011161H')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
	GROUP BY ArtS.[ArtsKey]
		,ap.ArtsNr1
		,ap.VerkFarbe
		,ag.Gr
		,ean.EANCode
		,ap.LagerOrt
	


	COMMIT TRANSACTION



	BEGIN TRANSACTION	/********************************** get all open orders per season **************************************/
						/**********************************           PREO 1 SEASON         *************************************/
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
		[SupplierCatalogKey]
		,[SKU]
		,[EAN]
		,[InventorySource_cd]
		,[open_order_QTY]
		,[LOAD_DATE]
		)
	SELECT ltrim(rtrim(ArtS.[ArtsKey])) AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,ap.LagerOrt as [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km) AS [open_order_QTY]
		,getDate() AS [LOAD_DATE]
	FROM [INTEXSALES].[OdloDE].dbo.AufGroesse ag WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.AufKopf ak WITH(READPAST)
	LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] art ON (
			art.tanr = 41
			AND art.lfd = 14
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		,[INTEXSALES].[OdloDE].dbo.AufPosi ap WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtFarben af WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtStamm ArtS WITH(READPAST)
	LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] div ON (
			div.tanr = 600
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
		,[INTEXSALES].[OdloDE].dbo.ArtEAN ean WITH(READPAST)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.GGaGr gg ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE (
			ak.AufkNr = ap.AufkNr
			AND ak.AufkKey = ap.AufkKey
			)
		AND (
			ap.AufkNr = ag.AufkNr
			AND ap.AufkKey = ag.AufkKey
			AND ap.OrderBlatt = ag.OrderBlatt
			AND ap.AufPNr = ag.AufPNr
			)		
		AND (
			ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		AND (
			ean.ArtsNr1 = af.ArtsNr1
			AND ean.ArtsNr2 = af.ArtsNr2
			AND ean.ArtsKey = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr] = ArtS.[GGNr]
			)
		AND ap.ArtsNr1 = ean.ArtsNr1
		AND ap.VerkFarbe = ean.VerkFarbe
		AND ag.Gr = ean.Gr
		AND ean.ArtsKey = ak.AufkKey
		AND div.stwert = 'SALES'
		AND art.[stwert] = 'J'
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt in ('800')
		---AND ak.AufkKey IN ('011162H') -- add season restriction to each table due to performance reasons!!!
		---AND ap.AufkKey IN ('011162H')
		---AND ag.AufkKey IN ('011162H')
		---AND ean.[ArtsKey] IN ('011162H')
		---AND af.[ArtsKey] IN ('011162H')
		---AND ArtS.[ArtsKey] IN ('011162H')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
	GROUP BY ArtS.[ArtsKey]
		,ap.ArtsNr1
		,ap.VerkFarbe
		,ag.Gr
		,ean.EANCode
		,ap.LagerOrt
	


	COMMIT TRANSACTION

	BEGIN TRANSACTION	/********************************** get all open orders per season **************************************/
						/**********************************           PREO 2 SEASON         *************************************/
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
		[SupplierCatalogKey]
		,[SKU]
		,[EAN]
		,[InventorySource_cd]
		,[open_order_QTY]
		,[LOAD_DATE]
		)
	SELECT ltrim(rtrim(ArtS.[ArtsKey])) AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,ap.LagerOrt as [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km) AS [open_order_QTY]
		,getDate() AS [LOAD_DATE]
	FROM [INTEXSALES].[OdloDE].dbo.AufGroesse ag WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.AufKopf ak WITH(READPAST)
	LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] art ON (
			art.tanr = 41
			AND art.lfd = 14
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		,[INTEXSALES].[OdloDE].dbo.AufPosi ap WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtFarben af WITH(READPAST)
		,[INTEXSALES].[OdloDE].dbo.ArtStamm ArtS WITH(READPAST)
	LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] div ON (
			div.tanr = 600
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
		,[INTEXSALES].[OdloDE].dbo.ArtEAN ean WITH(READPAST)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.GGaGr gg ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE (
			ak.AufkNr = ap.AufkNr
			AND ak.AufkKey = ap.AufkKey
			)
		AND (
			ap.AufkNr = ag.AufkNr
			AND ap.AufkKey = ag.AufkKey
			AND ap.OrderBlatt = ag.OrderBlatt
			AND ap.AufPNr = ag.AufPNr
			)		
		AND (
			ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		AND (
			ean.ArtsNr1 = af.ArtsNr1
			AND ean.ArtsNr2 = af.ArtsNr2
			AND ean.ArtsKey = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr] = ArtS.[GGNr]
			)
		AND ap.ArtsNr1 = ean.ArtsNr1
		AND ap.VerkFarbe = ean.VerkFarbe
		AND ag.Gr = ean.Gr
		AND ean.ArtsKey = ak.AufkKey
		AND div.stwert = 'SALES'
		AND art.[stwert] = 'J'
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt in ('800')
		---AND ak.AufkKey IN ('011171H') -- add season restriction to each table due to performance reasons!!!
		---AND ap.AufkKey IN ('011171H')
		---AND ag.AufkKey IN ('011171H')
		---AND ean.[ArtsKey] IN ('011171H')
		---AND af.[ArtsKey] IN ('011171H')
		---AND ArtS.[ArtsKey] IN ('011171H')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
	GROUP BY ArtS.[ArtsKey]
		,ap.ArtsNr1
		,ap.VerkFarbe
		,ag.Gr
		,ean.EANCode
		,ap.LagerOrt
	


	COMMIT TRANSACTION

	BEGIN TRANSACTION /********************************** get all open POs per season **************************************/

	INSERT INTO [dbo].[iV_IN_hlp_PO] (
		[SupplierCatalogKey]
		,[SKU]
		,[EAN]
		,[InventorySource_cd]
		,[open_QTY]
		,[LOAD_DATE]
		)
	SELECT ltrim(rtrim(pok.PakKey)) AS [SupplierCatalogKey]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,pok.LagerOrt as [InventorySource_cd]
		,sum(pog.Ip - pog.Sm - pog.Pr - pog.Af) AS [open_QTY]
		,getDate() AS [LOAD_DATE]
	FROM INTEXSALES.OdloDE.dbo.PaPosi pop WITH(READPAST)
		,INTEXSALES.OdloDE.dbo.PaKopf pok WITH(READPAST)
		,INTEXSALES.OdloDE.dbo.PaGroesse pog WITH(READPAST)
		,[INTEXSALES].[OdloDE].[dbo].[ArtEAN] ean WITH(READPAST)
	WHERE pok.LagerOrt in ('800')
		AND rtrim(pok.LiefNr) <> '71304'
		AND rtrim(pop.PakNr) <> '3600'
		AND rtrim(pok.Art) NOT IN ('07','99') --- SMS / Dummy
		AND (
			pok.PakNr = pop.PakNr
			AND pok.PakKey = pop.PakKey
			)
		AND (
			pop.PakNr = pog.PakNr
			AND pop.PakKey = pog.PakKey
			AND pop.PaPNr = pog.PaPNr
			)
		AND (
			pop.[ArtsKey] = ean.[ArtsKey]
			AND pop.[ArtsNr1] = ean.[ArtsNr1]
			AND pop.[ArtsNr2] = ean.[ArtsNr2]
			AND pop.[VerkFarbe] = ean.[VerkFarbe]
			)
		AND (
			pog.[GGanKey] = ean.[GGanKey]
			AND pog.[GGNr] = ean.[GGNr]
			AND pog.[Gr] = ean.[Gr]
			)
		AND pog.Ip - pog.Sm - pog.Pr - pog.Af > 0
		---AND pog.PakKey IN ('011161H','011162H','011171H')  -- add season restriction to each table due to performance reasons!!!
		---AND ean.ArtsKey IN ('011161H','011162H','011171H')
		---AND pok.PakKey IN ('011161H','011162H','011171H')
		---AND pop.PakKey IN ('011161H','011162H','011171H')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND pog.PakKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller) 
		AND ean.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND pok.PakKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND pop.PakKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	GROUP BY pok.PakKey 
		,ean.ArtsNr1
		,ean.VerkFarbe
		,ean.Gr
		,ean.EANCode
		,pok.LagerOrt
	

	COMMIT TRANSACTION


	BEGIN TRANSACTION /********************************** ignore negative (überlieferung) and 0 (delivered and already on stock) values in POs **************************************/

	DELETE FROM [dbo].[iV_IN_hlp_PO]
	WHERE [open_QTY] < 1

	COMMIT TRANSACTION


	BEGIN TRANSACTION /********************************** ignore delivered orders (0)  **************************************/

	DELETE FROM [dbo].[iV_IN_hlp_Order]
	WHERE [open_order_QTY] < 1

	COMMIT TRANSACTION

	
	BEGIN TRANSACTION /********************************** PREORDER SEASONS (season default = N) + [AvailableCheck_dt] > today **************************************/
    --stock 800 - preorder season and future availability check
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
	SELECT [EAN] AS [UPC]	
      ,[SKU]
	  ,[SKU] AS [SupplierProductKey]
      ,[EAN]
	  ,99999
      ,[Available_dt]
	  ,[SupplierCatalogKey]
	  ,'800' AS [InventorySource_cd]
      ,[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean]
  WHERE [SeasonDefault] = 'N'
  AND [AvailableCheck_dt] > CONVERT(VARCHAR(10), getDate(), 112)

  /*
    --stock 0CA - preorder season and future availability check
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
	SELECT [EAN] AS [UPC]	
      ,[SKU]
	  ,[SKU] AS [SupplierProductKey]
      ,[EAN]
	  ,99999
      ,[Available_dt]
	  ,[SupplierCatalogKey]
	  ,'0CA' AS [InventorySource_cd]
      ,[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean]
  WHERE [SeasonDefault] = 'N'
  AND [AvailableCheck_dt] > CONVERT(VARCHAR(10), getDate(), 112)
  */

  COMMIT TRANSACTION

  BEGIN TRANSACTION /********************************** PREORDER SEASONS (season default = N) + [AvailableCheck_dt] <= today **************************************/
  --stock 800 - preorder season and availability check in the past - get stock quantity
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
SELECT ean.[EAN] AS [UPC]	
      ,ean.[SKU]
	  ,ean.[SKU] AS [SupplierProductKey]
      ,ean.[EAN]
	  ,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END +CASE WHEN [open_QTY] IS NULL THEN 0 ELSE [open_QTY] END - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END 
	  --,[Inventory]
	  --,[open_QTY]
	  --,[open_order_QTY]
      ,[Available_dt]
	  ,ean.[SupplierCatalogKey]
	  ,'800' AS [InventorySource_cd]
      ,ean.[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean] ean
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] and la.[InventorySource_cd] = '800')
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO] po ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN] and po.[InventorySource_cd] = '800')
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] and ord.[InventorySource_cd] = '800')
  WHERE [SeasonDefault] = 'N'
  AND [AvailableCheck_dt] <= CONVERT(VARCHAR(10), getDate(), 112)

  /*
  --stock 0CA - preorder season and availability check in the past - get stock quantity
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
SELECT ean.[EAN] AS [UPC]	
      ,ean.[SKU]
	  ,ean.[SKU] AS [SupplierProductKey]
      ,ean.[EAN]
	  ,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END +CASE WHEN [open_QTY] IS NULL THEN 0 ELSE [open_QTY] END - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END 
	  --,[Inventory]
	  --,[open_QTY]
	  --,[open_order_QTY]
      ,[Available_dt]
	  ,ean.[SupplierCatalogKey]
	  ,'0CA' AS [InventorySource_cd]
      ,ean.[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean] ean
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] and la.[InventorySource_cd] = '0CA')
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO] po ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN] and po.[InventorySource_cd] = '0CA')
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] and ord.[InventorySource_cd] = '0CA')
  WHERE [SeasonDefault] = 'N'
  AND [AvailableCheck_dt] <= CONVERT(VARCHAR(10), getDate(), 112)
  */

  COMMIT TRANSACTION

  BEGIN TRANSACTION /********************************** REORDER SEASONS (season default = J) + (FeLager) Inventory <= 0 **************************************/
  --stock 800 - reorder
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
	SELECT ean.[EAN] AS [UPC]	
      ,ean.[SKU]
	  ,ean.[SKU] AS [SupplierProductKey]
      ,ean.[EAN]
	  ,0
      ,NULL AS [Available_dt]
	  ,ean.[SupplierCatalogKey]
	  ,'800' AS [InventorySource_cd]
      ,ean.[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean] ean
  LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] and la.[InventorySource_cd] = '800')
  WHERE [SeasonDefault] = 'J'
  AND [Inventory] <= 0

    /*
	--stock 0CA - reorder
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
	SELECT ean.[EAN] AS [UPC]	
      ,ean.[SKU]
	  ,ean.[SKU] AS [SupplierProductKey]
      ,ean.[EAN]
	  ,0
      ,NULL AS [Available_dt]
	  ,ean.[SupplierCatalogKey]
	  ,'0CA' AS [InventorySource_cd]
      ,ean.[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean] ean
  LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] and la.[InventorySource_cd] = '0CA')
  WHERE [SeasonDefault] = 'J'
  AND [Inventory] <= 0
  */

  COMMIT TRANSACTION

  BEGIN TRANSACTION /********************************** REORDER SEASONS (season default = J) + (FeLager) Inventory > 0 **************************************/
  --stock 800 - rerder
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
SELECT ean.[EAN] AS [UPC]	
      ,ean.[SKU]
	  ,ean.[SKU] AS [SupplierProductKey]
      ,ean.[EAN]
	  ,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END  - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END 
	  --,[Inventory]
	  --,[open_QTY]
	  --,[open_order_QTY]
      ,[Available_dt]
	  ,ean.[SupplierCatalogKey]
	  ,'800' AS [InventorySource_cd]
      ,ean.[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean] ean
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] and la.[InventorySource_cd] = '800')
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] and ord.[InventorySource_cd] = '800')
  WHERE [SeasonDefault] = 'J'
  AND [Inventory] > 0

  /*
  --stock 0CA - rerder
	INSERT INTO [dbo].[iV_IN]
           ([UPC]
		   ,[SKU]
		   ,[SupplierProductKey]
		   ,[EAN]
           ,[Inventory]
           ,[Available_dt]
           ,[SupplierCatalogKey]
           ,[InventorySource_cd]
           ,[LOAD_DATE])
SELECT ean.[EAN] AS [UPC]	
      ,ean.[SKU]
	  ,ean.[SKU] AS [SupplierProductKey]
      ,ean.[EAN]
	  ,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END  - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END 
	  --,[Inventory]
	  --,[open_QTY]
	  --,[open_order_QTY]
      ,[Available_dt]
	  ,ean.[SupplierCatalogKey]
	  ,'0CA' AS [InventorySource_cd]
      ,ean.[LOAD_DATE] 
  FROM [dbo].[iV_IN_hlp_ean] ean
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] and la.[InventorySource_cd] = '0CA')
	LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] and ord.[InventorySource_cd] = '0CA')
  WHERE [SeasonDefault] = 'J'
  AND [Inventory] > 0
  */


  COMMIT TRANSACTION












	--BEGIN TRANSACTION /********************************** add all ean per season where VerfügbarAb (ArtFarb) > today with quantity 99999 **************************************/

	--INSERT INTO [dbo].[iV_IN]
 --          ([UPC]
	--	   ,[SKU]
	--	   ,[SupplierProductKey]
	--	   ,[EAN]
 --          ,[Inventory]
 --          ,[Available_dt]
 --          ,[SupplierCatalogKey]
 --          ,[InventorySource_cd]
 --          ,[LOAD_DATE])
	--SELECT [EAN] AS [UPC]	
 --     ,[SKU]
	--  ,[SKU] AS [SupplierProductKey]
 --     ,[EAN]
	--  ,99999
 --     ,[Available_dt]
	--  ,[SupplierCatalogKey]
	--  ,'800' AS [InventorySource_cd]
 --     ,[LOAD_DATE] 
 -- FROM [dbo].[iV_IN_hlp_ean]
 -- WHERE [Available_dt] > CONVERT(VARCHAR(10), getDate(), 112)

 -- COMMIT TRANSACTION


 -- BEGIN TRANSACTION /********************************** add all ean per season where VerfügbarAb (ArtFarb) <= today with quantity ([Inventory]+[open_QTY]-[open_order_QTY]) **************************************/

 -- 	INSERT INTO [dbo].[iV_IN]
 --          ([UPC]
	--	   ,[SKU]
	--	   ,[SupplierProductKey]
	--	   ,[EAN]
 --          ,[Inventory]
 --          ,[Available_dt]
 --          ,[SupplierCatalogKey]
 --          ,[InventorySource_cd]
 --          ,[LOAD_DATE])
	--SELECT ean.[EAN] AS [UPC]	
 --     ,ean.[SKU]
	--  ,ean.[SKU] AS [SupplierProductKey]
 --     ,ean.[EAN]
	--  ,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END +CASE WHEN [open_QTY] IS NULL THEN 0 ELSE [open_QTY] END - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END 
	--  --,[Inventory]
	--  --,[open_QTY]
	--  --,[open_order_QTY]
 --     ,NULL AS [Available_dt]
	--  ,ean.[SupplierCatalogKey]
	--  ,'800' AS [InventorySource_cd]
 --     ,ean.[LOAD_DATE] 
 -- FROM [dbo].[iV_IN_hlp_ean] ean
	--LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN])
	--LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO] po ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN])
	--LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN])
 -- WHERE [Available_dt] <= CONVERT(VARCHAR(10), getDate(), 112)



 -- COMMIT TRANSACTION

  BEGIN TRANSACTION /********************************** remove negative stock  **************************************/

  UPDATE [dbo].[iV_IN]
  SET [Inventory] = 0
  WHERE [Inventory] < 0

  COMMIT TRANSACTION

  BEGIN TRANSACTION /********************************** change date formataccording to iVendix   **************************************/

  UPDATE [dbo].[iV_IN]
  SET [Available_dt] = SUBSTRING([Available_dt], 5, 2)+'/'+SUBSTRING([Available_dt], 7, 2)+'/'+SUBSTRING([Available_dt], 1, 4)
  WHERE [Available_dt] IS NOT NULL

  COMMIT TRANSACTION

  	BEGIN TRANSACTION /*************************** assign LIQ styles to LIQ SEASON ************************/

	UPDATE [dbo].[iV_IN]
	SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_IN] t
	,[dbo].[iV_ST] st
	--mpfyl 05/12/2016: adjust liq not new and old but only old
	--WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
	AND REPLACE(St.[SupplierCatalogKey], 'L', 'H') = t.[SupplierCatalogKey]
	AND st.EAN = t.EAN
	
	COMMIT TRANSACTION



   BEGIN TRANSACTION /********************************** remove ean not in iV_ST  **************************************/

DELETE FROM [dbo].[iV_IN]  /************** delete all articles (EAN) pricelist not found in style file ************************/
WHERE NOT EXISTS (
SELECT DISTINCT [SupplierCatalogKey], [EAN]
		FROM [dbo].[iV_ST]
		WHERE  [dbo].[iV_ST].[EAN] = [dbo].[iV_IN].[EAN]
		AND [dbo].[iV_ST].[SupplierCatalogKey] = [dbo].[iV_IN].[SupplierCatalogKey]
)

  COMMIT TRANSACTION
END

GO
