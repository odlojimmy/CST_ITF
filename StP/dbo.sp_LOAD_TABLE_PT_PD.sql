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
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_PT_PD]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	
	TRUNCATE TABLE [dbo].[iV_PT]
	TRUNCATE TABLE [dbo].[iV_PD]

	COMMIT TRANSACTION

	BEGIN TRANSACTION /****************************** LOAD ALL PTs **********************************/

INSERT INTO [dbo].[iV_PT] (
	[CAccountNum]
	,[MappingCode]
	,[TermsCode]
	,[LOAD_DATE]
	)
SELECT ks.[KusNr] AS [CAccountNum]
,[SupplierCatalogKey] AS [MappingCode] 
	,'PT' + ltrim(rtrim(ks.[ZahlBed])) AS [TermsCode]
	,getDate() AS [LOAD_DATE]
FROM [IFC_Cache].dbo.[KuStamm] ks
,(SELECT distinct [SupplierCatalogKey] FROM [dbo].[iV_PL]) AS sck -- for each season ([SupplierCatalogKey])
WHERE ks.[KusNr] IN (
		SELECT DISTINCT [CAccountNum]
		FROM [dbo].[iV_CM]
		)

	COMMIT TRANSACTION

	BEGIN TRANSACTION

	INSERT INTO [dbo].[iV_PD]
           ([TermsCode]
           ,[Discount]
           ,[DaysorDate]
           ,[Description]
           ,[LOAD_DATE])
	SELECT 'PT'+ltrim(rtrim(tx.tpwert)) AS [TermsCode]
	,0 AS [Discount] --tsp.stwert AS [Discount]
	,ltrim(rtrim(tsd.stwert)) as [DaysorDate]
	,ltrim(rtrim(tx.zeile)) AS [Description]
	,getDate() AS [LOAD_DATE]
FROM [IFC_Cache].dbo.TpText tx 
	LEFT OUTER JOIN [IFC_Cache].dbo.TpSteu tsd ON (tx.tanr=tsd.tanr AND tx.tpwert = tsd.tpwert AND tsd.lfd = 2)
	LEFT OUTER JOIN [IFC_Cache].dbo.TpSteu tsp ON (tx.tanr=tsp.tanr AND tx.tpwert = tsp.tpwert AND tsp.lfd = 3)
WHERE tx.tanr = 26
AND sprache = '01'
AND tx.lfd = 1
AND ('PT'+tx.tpwert) COLLATE SQL_Latin1_General_CP1_CS_AS IN (
	SELECT distinct [TermsCode] FROM [dbo].[iV_PT]
		) 


	COMMIT TRANSACTION

END
GO
