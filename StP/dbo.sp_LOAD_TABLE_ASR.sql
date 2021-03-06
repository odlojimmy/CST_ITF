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
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_ASR]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_ASR]

	COMMIT TRANSACTION

-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================

/*

	BEGIN TRANSACTION /****************************** LOAD ALL PRODUCTS **********************************/

	INSERT INTO [dbo].[iV_ASR]
           ([SizeRunName]
           ,[ItemNumber]
           ,[ProductName]
           ,[SizeCode]
           ,[Size]
           ,[UOM_cd]
           ,[Quantity]
           ,[ActionCode]
           ,[LOAD_DATE])

	SELECT distinct 'A_dozen' AS [SizeRunName]
           ,ltrim(rtrim(ean.ArtsNr1)) AS [ItemNumber]
           ,REPLACE(ltrim(rtrim(ArtS.InterneBez1)), '½', '1/2') AS [ProductName]
           ,NULL AS [SizeCode]
           ,ltrim(rtrim(ean.Gr)) AS [Size]
           ,NULL as [UOM_cd]
           ,3 AS [Quantity]
           ,'UP' AS [ActionCode]
           ,getDate() AS [LOAD_DATE]
	
	
FROM [IFC_Cache].dbo.ArtFarben af
		,[IFC_Cache].dbo.TpText DivneuTXT
		,[IFC_Cache].dbo.ArtStamm ArtS
	LEFT OUTER JOIN [IFC_Cache].[dbo].[TpSteu] div ON (
			div.tanr = 600 -- category aka division
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
	LEFT OUTER JOIN [IFC_Cache].[dbo].[TpText] gndr ON (
			gndr.tanr = 9 -- gender
			AND gndr.sprache = '01'
			AND ArtS.[TapKey_Geschlecht] = gndr.[tapkey]
			AND ArtS.[Geschlecht] = gndr.tpwert
			)
	LEFT OUTER JOIN [IFC_Cache].[dbo].[TpText] pgr ON (
			pgr.tanr = 608 -- product group
			AND pgr.sprache = '01'
			AND ArtS.[TapKey_ProductGroupNeu] = pgr.[tapkey]
			AND ArtS.[ProductGroupNeu] = pgr.tpwert
			)
	LEFT OUTER JOIN [IFC_Cache].[dbo].[TpText] sub ON (
			ArtS.ProdGroup = sub.tpwert
			AND ArtS.TapKey_ProdGroup = sub.tapkey
			AND sub.tanr = 6
			AND sub.sprache = '01'
			AND sub.lfd = 1
			)
		,[IFC_Cache].dbo.TpText saison
		,[IFC_Cache].dbo.TpText Farbe
		,[IFC_Cache].dbo.TpSteu Farbe2
	LEFT OUTER JOIN [IFC_Cache].dbo.TpText comc ON (
			comc.tanr = 78
			AND comc.tapkey = '01'
			AND comc.sprache = '01'
			AND comc.lfd = 1
			AND Farbe2.stwert = comc.tpwert
			)
		,[IFC_Cache].dbo.ArtEAN ean
	LEFT OUTER JOIN [IFC_Cache].dbo.GGaGr gg ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE (
			ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		AND (
			DivneuTXT.tapkey = ArtS.TapKey_DivNeu
			AND DivneuTXT.tpwert = ArtS.DivNeu
			AND DivneuTXT.tanr = 600
			AND DivneuTXT.sprache = '01'
			AND DivneuTXT.lfd = 1
			)
		AND (
			Farbe.tapkey = af.TapKey_VerkFarbe
			AND Farbe.tpwert = af.VerkFarbe
			AND Farbe.tanr = 77
			AND Farbe.sprache = '01'
			AND Farbe.lfd = 1
			)
		AND (
			Farbe2.tapkey = af.TapKey_VerkFarbe
			AND Farbe2.tpwert = af.VerkFarbe
			AND Farbe2.tanr = 77
			AND Farbe2.lfd = 2
			)
		AND ean.ArtsNr1 = af.ArtsNr1
		AND ean.ArtsNr2 = af.ArtsNr2
		AND ean.ArtsKey = af.ArtsKey
		AND ean.VerkFarbe = af.VerkFarbe
		AND ean.[GGanKey] = ArtS.[GGanKey]
		AND ean.[GGNr] = ArtS.[GGNr]
		AND (
			saison.tanr = 3
			AND saison.sprache = '01'
			AND saison.lfd = 1
			AND saison.tapkey = '011'
			AND saison.tpwert = SUBSTRING(ean.ArtsKey, 4, 3) --'161' --saison.tapkey+saison.tpwert+'H'
			)
		AND ean.ArtsKey IN (
			---'011161H'
			--- added 04.08.2016/cls to avoid hardcoded seasons
			SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS'
			)
		AND div.stwert = 'SALES'
		AND ean.ArtsNr1 IN ('221791', '221792')

	COMMIT TRANSACTION


	*/
END

GO
