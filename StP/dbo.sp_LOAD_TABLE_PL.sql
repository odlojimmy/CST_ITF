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
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_PL]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRANSACTION

	--TRUNCATE TABLE [dbo].[iV_SUM]
	--TRUNCATE TABLE [dbo].[iV_CM]
	--TRUNCATE TABLE [dbo].[iV_ST]
	TRUNCATE TABLE [dbo].[iV_PL]
	--TRUNCATE TABLE [dbo].[iV_IN]
	--TRUNCATE TABLE [dbo].[iV_PA]

	COMMIT TRANSACTION


	BEGIN TRANSACTION /****************************** LOAD ALL PL **********************************/

	INSERT INTO [dbo].[iV_PL]
		(
			 [Currency_cd]
			,[UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Price]
			,[MAP]
			,[Units]
			,[PriceSchedule]
			,[Retail]
			,[SupplierCatalogKey]
			,[SalePrice]
			,[SaleDiscount]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(cur.stwert))                                                   AS [Currency_cd]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                        AS [UPC]
		,ltrim(rtrim(ean.ArtsNr1))+ltrim(rtrim(ean.VerkFarbe))+ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(ean.ArtsNr1))+ltrim(rtrim(ean.VerkFarbe))+ltrim(rtrim(ean.Gr)) AS [SupplierProductKey]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                        AS [EAN]
		,pl.EkPreis                                                                 AS [Price]
		,NULL                                                                       AS [MAP]
		,1                                                                          AS [Units]
		,ltrim(rtrim(pl.PreisListe))                                                AS [PriceSchedule]
		,pl.VkPreis                                                                 AS [Retail]
		,ltrim(rtrim(pl.ArtsKey))                                                   AS [SupplierCatalogKey]
		,NULL                                                                       AS [SalePrice]
		,NULL                                                                       AS [SaleDiscount]
		,getDate()                                                                  AS [LOAD_DATE]
	--,ArPreisLst.ArtsNr1
	--,PrListTXT.zeile
	FROM                [IFC_Cache].dbo.ArPreisLst pl  
		,               [IFC_Cache].dbo.TpSteu     cur 
		,               [IFC_Cache].dbo.ArtEAN     ean 
		,               [IFC_Cache].dbo.[TaPosi]   tp  

		,               [IFC_Cache].dbo.ArtStamm   ArtS
		LEFT OUTER JOIN [IFC_Cache].[dbo].[TpSteu] div  ON (
			div.tanr = 600 -- category aka division
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)

	--LEFT OUTER JOIN [IFC_Cache].dbo.TpText PrListTXT ON ArPreisLst.TapKey_PreisListe = PrListTXT.tapkey
	--	AND PrListTXT.tpwert = ArPreisLst.PreisListe
	--	AND PrListTXT.tanr = 34
	--	AND PrListTXT.sprache = '01'
	--	AND PrListTXT.lfd = 1
	WHERE ean.[ArtsNr1] = pl.[ArtsNr1]
		AND ean.[VerkFarbe] = pl.[VerkFarbe]
		AND ean.[ArtsKey] = pl.[ArtsKey]
		AND pl.EkPreis <> 0
		AND pl.[TapKey_PreisListe] = cur.[tapkey] -- nur Preislisten mit Währung
		AND cur.[tanr] = 34
		AND cur.[tpwert] = pl.PreisListe
		AND cur.lfd = 2
		AND tp.tanr = 34 -- nur aktive Preislisten
		AND tp.tapkey = pl.[TapKey_PreisListe]
		AND tp.[tpwert] = pl.[PreisListe]
		AND tp.[aktivjn] = 'J'

		AND (
		ArtS.[ArtsNr1] = ean.[ArtsNr1]
		AND ArtS.[ArtsNr2] = ean.[ArtsNr2]
		AND ArtS.[ArtsKey] = ean.[ArtsKey]
		AND ArtS.[GGanKey] = ean.[GGanKey]
		AND ArtS.[GGNr] = ean.[GGNr]
		)
		--mpf 11.04.17 - added retail materials
		AND div.stwert IN ('SALES','RETAIL')

		---AND pl.ArtsKey IN ('011161H', '011162H', '011171H')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND pl.ArtsKey IN (SELECT
			DISTINCT
			SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS
		FROM ODLO_Season_Controller)

		--ORDER BY pl.ArtsKey
		--	,pl.ArtsNr1
		--AND ean.ArtsNr1 IN ('10419', '110101')
		--AND pl.PreisListe IN ('100','51', '54')
		--mpf 03.04.2017 - pricelist 309 is required, do not exlcude any longer(SAbrina)
		AND ltrim(rtrim(pl.PreisListe)) NOT IN ('099','599','NON','330','331','209','DE','000','199','021','340','341','350','CH','701','505','99') -- manually excluded doublecheck with customer export
		AND ltrim(rtrim(pl.PreisListe)) IN ( -- nur Preislisten die auch im Kundenstamm verwendet werden
		SELECT
			DISTINCT
			[PriceSchedule] COLLATE SQL_Latin1_General_CP1_CS_AS
		FROM CST_ITF.[dbo].[iV_CM]
		)

	COMMIT TRANSACTION

END
GO
