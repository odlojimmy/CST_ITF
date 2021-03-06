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
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_ST]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_ST]

	COMMIT TRANSACTION

	/*
	-- Diese Indizes wird vom Execution Plan empfohlen (hat aber keinen wirklichen Performance Increase eingebracht:
	CREATE NONCLUSTERED INDEX [SIXH_ARTSTAMM_SoArtNr]
	ON [SPOT_SRC].[dbo].[SIXH_ARTSTAMM] ([SoArtNr])
	INCLUDE ([ArtsNr1],[ArtsNr2],[ArtsKey],[InterneBez1],[GGanKey],[GGNr],[ProdLine],[TapKey_ProdGroup],[ProdGroup],[TapKey_Geschlecht],[Geschlecht],[TapKey_DivNeu],[DivNeu],[ProductGroupNeu],[TapKey_ProductGroupNeu])

	CREATE NONCLUSTERED INDEX [SIXH_ARTEAN_ArtsNr1_ArtsNr2_ArtsKey_GGanKey_GGNr] 
	ON [SPOT_SRC].[dbo].[SIXH_ARTEAN] ([ArtsNr1],[ArtsNr2],[ArtsKey],[GGanKey],[GGNr])
	INCLUDE ([VerkFarbe],[Gr],[EANCode])

	-- vlt die zugehörigen Statistiken noch explizit erstellen?
	CREATE STATISTICS stats_SIXH_ARTEAN   
	 ON [SPOT_SRC].[dbo].[SIXH_ARTEAN] ([ArtsNr1],[ArtsNr2],[ArtsKey],[GGanKey],[GGNr]) WITH FULLSCAN ; 
	CREATE STATISTICS stats_SIXH_ARTSTAMM_SoArtNr
	 ON [SPOT_SRC].[dbo].[SIXH_ARTSTAMM] ([SoArtNr]) WITH FULLSCAN;
	*/


	BEGIN TRANSACTION /****************************** LOAD ALL PRODUCTS **********************************/

	INSERT INTO [dbo].[iV_ST] (
		[Catalog]
		,[SupplierCatalogKey]
		,[ItemNumber]
		,[ProductName]
		,[ProductSort]
		,[BusinessUnit_cd]
		,[Directory]
		,[DirectorySort]
		,[NavCategory]
		,[NavCatSort]
		,[SubCategory]
		,[SubCatSort]
		,[ColorHeader]
		,[ColorCode]
		,[Color]
		,[ColorSort]
		,[HorzSizeHeader]
		,[Size]
		,[SizeSort]
		,[VsizeHead]
		,[Vsize]
		,[VsizeSort]
		,[UOM_cd]
		,[FirstShip_dt]
		,[UPC]
		,[SKU]
		,[SupplierProductKey]
		,[EAN]
		,[MasterImage]
		,[ColorImage]
		,[LineItemMin]
		,[LineItemMult]
		,[StyleColorMin]
		,[CommonColor]
		,[hlp_ReportingCategory]
		,[hlp_DiscountProdLine]
		,[hlp_DiscountDivision]
		,[hlp_DiscountNOS]
		,[LOAD_DATE]
		)
	SELECT LEFT(ltrim(rtrim(saison.zeile)), 50) AS [Catalog]
		,ltrim(rtrim(ean.ArtsKey)) AS [SupplierCatalogKey]
		,ltrim(rtrim(ean.ArtsNr1)) AS [ItemNumber]
		,REPLACE(ltrim(rtrim(ArtS.InterneBez1)), '½', '1/2') AS [ProductName]
		,NULL AS [ProductSort]
		,'COLLECTION' AS [BusinessUnit_cd]
		,CASE 
			WHEN ltrim(rtrim(LEFT(DivneuTXT.zeile, 50))) = ''
				THEN 'UNKNOWN'
			WHEN ltrim(rtrim(LEFT(DivneuTXT.zeile, 50))) IS NULL
				THEN 'UNKNOWN'
			ELSE ltrim(rtrim(LEFT(DivneuTXT.zeile, 50)))
			END AS [Directory]
		,NULL AS [DirectorySort]
		,CASE 
			WHEN gndr.zeile IS NULL
				THEN 'UNDEFINED'
			WHEN ltrim(rtrim(UPPER(gndr.zeile))) = ''
				THEN 'UNDEFINED'
			ELSE ltrim(rtrim(UPPER(gndr.zeile)))
			END AS [NavCategory] -- gender
		,NULL AS [NavCatSort]
		,CASE 
			WHEN pgr.zeile IS NULL
				THEN 'UNDEFINED'
			WHEN ltrim(rtrim(pgr.zeile)) = ''
				THEN 'UNDEFINED'
			ELSE ltrim(rtrim(pgr.zeile))
			END AS [SubCategory] -- product group
		,NULL AS [SubCatSort]
		,'COLOR' AS [ColorHeader]
		,ltrim(rtrim(ean.VerkFarbe)) AS [ColorCode]
		,CASE 
			WHEN ltrim(rtrim(LEFT(Farbe.zeile, 50))) = ''
				THEN 'unknwn'
			WHEN Farbe.zeile IS NULL
				THEN 'unknwn'
			ELSE ltrim(rtrim(LEFT(Farbe.zeile, 50)))
			END AS [Color]
		,NULL AS [ColorSort]
		,NULL AS [HorzSizeHeader]
		,ltrim(rtrim(ean.Gr)) AS [Size]
		,gg.[SortKz] AS [SizeSort]
		,NULL AS [VsizeHead]
		,NULL AS [Vsize]
		,NULL AS [VsizeSort]
		,NULL AS [UOM_cd]
		,CONVERT(VARCHAR(10), af.[LieferbarAb], 101) AS [FirstShip_dt]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [UPC]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SupplierProductKey]
		,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
		,ltrim(rtrim(ean.ArtsNr1)) + '_A_' + ltrim(rtrim(ean.VerkFarbe)) + '.png' AS [MasterImage]
		,ltrim(rtrim(ean.ArtsNr1)) + '_A_' + ltrim(rtrim(ean.VerkFarbe)) + '.png' AS [ColorImage]
		,1 AS [LineItemMin]
		,1 AS [LineItemMult]
		,1 AS [StyleColorMin]
		,ltrim(rtrim(LEFT(comc.zeile, 50))) AS [CommonColor]
		,CASE 
			WHEN sub.zeile IS NULL
				THEN 'UNDEFINED~'
			WHEN ltrim(rtrim(sub.zeile)) = ''
				THEN 'UNDEFINED~'
			ELSE ltrim(RTRIM(sub.zeile)) + '~'
			END + CASE 
			WHEN gndr.zeile IS NULL
				THEN 'UNDEFINED'
			WHEN ltrim(rtrim(UPPER(gndr.zeile))) = ''
				THEN 'UNDEFINED'
			ELSE ltrim(rtrim(UPPER(gndr.zeile)))
			END AS [hlp_ReportingCategory]
		,ltrim(rtrim(ArtS.[ProdLine])) AS [hlp_DiscountProdLine]
		,ltrim(rtrim(ArtS.[DivNeu])) AS [hlp_DiscountDivision]
		,ltrim(rtrim(af.StandardJN)) AS [hlp_DiscountNOS]
		,getDate() AS [LOAD_DATE]
	--FROM      [SQLINTEX].[OdloDE].dbo.ArtStamm ArtS
	--JOIN      [SQLINTEX].[OdloDE].dbo.ArtFarben af ON (
	FROM      [IFC_Cache].dbo.ArtStamm ArtS
	JOIN      [IFC_Cache].dbo.ArtFarben af ON (
			    ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.TpText DivneuTXT ON (
	JOIN      [IFC_Cache].dbo.TpText DivneuTXT ON (
			    DivneuTXT.tapkey = ArtS.TapKey_DivNeu
			AND DivneuTXT.tpwert = ArtS.DivNeu
			AND DivneuTXT.tanr = 600
			AND DivneuTXT.sprache = '01'
			AND DivneuTXT.lfd = 1

			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.GGaGr ggVon ON (
	JOIN      [IFC_Cache].dbo.GGaGr ggVon ON (
			    ggVon.ggankey = arts.ggankey
			and ggVon.ggnr = arts.ggnr
			and ggVon.gr = af.vongroesse
			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.GGaGr ggBis ON (
	JOIN      [IFC_Cache].dbo.GGaGr ggBis ON (
			    ggBis.ggankey = arts.ggankey
			and ggBis.ggnr = arts.ggnr
			and ggBis.gr = af.bisgroesse 
			)
	--LEFT JOIN [SQLINTEX].[OdloDE].[dbo].[TpSteu] div ON (
	LEFT JOIN [IFC_Cache].[dbo].[TpSteu] div ON (
			    div.tanr = 600 -- category aka division
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
	--LEFT JOIN [SQLINTEX].[OdloDE].[dbo].[TpText] gndr ON (
	LEFT JOIN [IFC_Cache].[dbo].[TpText] gndr ON (
			    gndr.tanr = 9 -- gender
			AND gndr.sprache = '01'
			AND ArtS.[TapKey_Geschlecht] = gndr.[tapkey]
			AND ArtS.[Geschlecht] = gndr.tpwert
			)
	--LEFT JOIN [SQLINTEX].[OdloDE].[dbo].[TpText] pgr ON (
	LEFT JOIN [IFC_Cache].[dbo].[TpText] pgr ON (
			    pgr.tanr = 608 -- product group
			AND pgr.sprache = '01'
			AND ArtS.[TapKey_ProductGroupNeu] = pgr.[tapkey]
			AND ArtS.[ProductGroupNeu] = pgr.tpwert
			)
	--LEFT JOIN [SQLINTEX].[OdloDE].[dbo].[TpText] sub ON (
	LEFT JOIN [IFC_Cache].[dbo].[TpText] sub ON (
			    ArtS.ProdGroup = sub.tpwert
			AND ArtS.TapKey_ProdGroup = sub.tapkey
			AND sub.tanr = 6
			AND sub.sprache = '01'
			AND sub.lfd = 1
			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.TpText Farbe ON (
	JOIN      [IFC_Cache].dbo.TpText Farbe ON (
			    Farbe.tapkey = af.TapKey_VerkFarbe
			AND Farbe.tpwert = af.VerkFarbe
			AND Farbe.tanr = 77
			AND Farbe.sprache = '01'
			AND Farbe.lfd = 1
			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.TpSteu Farbe2 ON (
	JOIN      [IFC_Cache].dbo.TpSteu Farbe2 ON (
			    Farbe2.tapkey = af.TapKey_VerkFarbe
			AND Farbe2.tpwert = af.VerkFarbe
			AND Farbe2.tanr = 77
			AND Farbe2.lfd = 2

			)
	--LEFT JOIN [SQLINTEX].[OdloDE].dbo.TpText comc ON (
	LEFT JOIN [IFC_Cache].dbo.TpText comc ON (
			comc.tanr = 78
			AND comc.tapkey = '01'
			AND comc.sprache = '01'
			AND comc.lfd = 1
			AND Farbe2.stwert = comc.tpwert
			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.ArtEAN ean ON (
	JOIN      [IFC_Cache].dbo.ArtEAN ean ON (
				ean.ArtsNr1 = af.ArtsNr1
			AND ean.ArtsNr2 = af.ArtsNr2
			AND ean.ArtsKey = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr] = ArtS.[GGNr]
			)
	--JOIN      [SQLINTEX].[OdloDE].dbo.TpText saison ON (
	JOIN      [IFC_Cache].dbo.TpText saison ON (
			    saison.tpwert = SUBSTRING(ean.ArtsKey, 4, 3)
			AND saison.tanr = 3
			AND saison.sprache = '01'
			AND saison.lfd = 1
			AND saison.tapkey = '011'

				)
	--LEFT JOIN [SQLINTEX].[OdloDE].dbo.GGaGr gg ON (
	LEFT JOIN [IFC_Cache].dbo.GGaGr gg ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE  ean.EANCode > 7610000000000
		---AND ean.ArtsKey IN ('011161H','011162H','011171H')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ean.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		--MPF 11.04.17 - added retail to get exported as well
		AND div.stwert IN ('SALES','RETAIL')
		AND af.Sperre <> '10' -- do not export "wird nicht produziert" colorways
		AND ean.ArtsNr1 NOT LIKE '%K%' --ignore Musterteile dummy artikel
		and gg.sortkz >= ggVon.sortkz
		and gg.sortkz <= ggBis.sortkz
		and arts.SoArtNr not in ('9','8','12','11','14','10','15','17')
		--SoArtNr is the colection: 9=Special, 8=SMU, 12=Tender, 11=Sponsoring Team, 14=Cusotmer, 10=SponsoringEvent, 15=Exhibition, 17=proactiveSpecials

	COMMIT TRANSACTION

	BEGIN TRANSACTION

	DELETE FROM [dbo].[iV_ST]
		WHERE [SupplierCatalogKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType<>'REAS')
		AND [hlp_DiscountNOS] NOT IN ('0','00', '05', '20')  -- ...only colourways with Standardkennzeichen KEIN, NOS, ESSENTIAL	
	COMMIT TRANSACTION

	BEGIN TRANSACTION
	--MPF 10-FEB-17: delete styles which need to be exlcuded (again the french folks!!!)
	DELETE FROM [dbo].[iV_ST] 
		WHERE  EXISTS (
		SELECT DISTINCT [SupplierCatalogKey], [ItemNumber]
			FROM [dbo].[iV_ST_ToBeExcluded]
			WHERE  [dbo].[iV_ST].[ItemNumber] = [dbo].[iV_ST_ToBeExcluded].[ItemNumber]
			AND [dbo].[iV_ST].[SupplierCatalogKey] = [dbo].[iV_ST_ToBeExcluded].[SupplierCatalogKey])
	COMMIT TRANSACTION

	--MPFYL 23-FEB-17, Start
	--UPDATE - remove the availabilty date for all reorder styles - as that's not properly maintained
	UPDATE [dbo].[iV_ST] 
		SET FirstShip_dt = NULL
		WHERE [SupplierCatalogKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType = 'REAS') 		
	--MPFYL 23-FEB-17, end

	/*
	--Droppen der vom Execution Plan vorgeschlagenen Indizes (Allerdings konnte keine Performance Steigerung gemessen werden (Statistik?...)
	DROP INDEX [SIXH_ARTEAN_ArtsNr1_ArtsNr2_ArtsKey_GGanKey_GGNr] ON [SPOT_SRC].[dbo].[SIXH_ARTEAN]
	DROP INDEX [SIXH_ARTSTAMM_SoArtNr] ON [SPOT_SRC].[dbo].[SIXH_ARTSTAMM] 
	
	*/
END
