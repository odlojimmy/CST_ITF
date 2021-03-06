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
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_RD]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_RD]

COMMIT TRANSACTION



BEGIN TRANSACTION  /****************************** LOAD ALL PRODUCTS **********************************/

INSERT INTO [dbo].[iV_RD]
           ([ProductKey]
           ,[SecondaryProductKey]
           ,[DetailLevel]
           ,[RelationshipCode]
           ,[SalesRegionCode]
           ,[ActionCode]
           ,[LOAD_DATE])
	SELECT distinct ltrim(rtrim(ArtS.ArtsNr1)) AS [ItemNumber]
	,ltrim(rtrim(ArtS.[VorgaengerArtsNr1]))
	,'I' as [DetailLevel]
	,'S' as [RelationshipCode]
	,NULL as [SalesRegionCode]
	,NULL as [ActionCode]
	,getDate() AS [LOAD_DATE]
FROM [IFC_Cache].dbo.ArtStamm ArtS
LEFT OUTER JOIN [IFC_Cache].[dbo].[TpSteu] div ON (
		div.tanr = 600
		AND div.lfd = 205
		AND ArtS.[TapKey_DivNeu] = div.[tapkey]
		AND ArtS.[DivNeu] = div.tpwert
		)

---WHERE	ArtS.ArtsKey IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE	ArtS.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	AND div.stwert = 'SALES'
	AND ArtS.[VorgaengerArtsKey] = 'Child'
	AND ltrim(rtrim(ArtS.[VorgaengerArtsNr1])) <> ''
	AND ltrim(rtrim(ArtS.[VorgaengerArtsNr1])) IS NOT NULL


COMMIT TRANSACTION

BEGIN TRANSACTION

DELETE FROM [dbo].[iV_RD]
WHERE [ProductKey] NOT IN (
	SELECT distinct [ItemNumber] FROM [dbo].[iV_ST]
	)

COMMIT TRANSACTION

BEGIN TRANSACTION

DELETE FROM [dbo].[iV_RD]
WHERE [SecondaryProductKey] NOT IN (
	SELECT distinct [ItemNumber] FROM [dbo].[iV_ST]
	)

COMMIT TRANSACTION

END
GO
