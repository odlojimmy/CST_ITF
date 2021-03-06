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
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_PA]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
--BEGIN TRANSACTION 

--TRUNCATE TABLE [dbo].[iV_SUM]
--TRUNCATE TABLE [dbo].[iV_CM]
--TRUNCATE TABLE [dbo].[iV_ST]
--TRUNCATE TABLE [dbo].[iV_PL]
--TRUNCATE TABLE [dbo].[iV_IN]
TRUNCATE TABLE [dbo].[iV_PA]

--COMMIT TRANSACTION


--BEGIN TRANSACTION 

 /****************************** LOAD ALL IN **********************************/


/*
--MPF 02/09/16 - Add Size Set (only DE yet)
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])		
select  'Size chart' as [AttributeName],
		--isnull('EU ' + STUFF((select RTRIM(b.grbez) + space(10-len(RTRIM(b.grbez))) from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '1' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, '') + 'ReplaceWithBR' +
		--'F  ' + STUFF((select RTRIM(b.grbez) + space(10-len(RTRIM(b.grbez))) from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '7' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, ''),'-') as [AttributeValue],
		--shows EU sizes
		isnull('<table border="2" cellspacing="10"><tr><td>EU</td><td>' + STUFF((select RTRIM(b.grbez) + 'ReplaceColumnBreakerOdlo' from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '1' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, '') + '</td></tr>' +
		--shows FR sizes (sprache remains but tpwert is 7 (for FR)
		'<tr><td>F</td><td>' + STUFF((select RTRIM(b.grbez) + 'ReplaceColumnBreakerOdlo' from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '7' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, ''),'-') + '</td></tr></table>' as [AttributeValue],
		ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber],
		ltrim(rtrim([InterneBez1])) as [ProductName],
		NULL as [AttributeNameSort],
		NULL as [AttributeValueSort],
		--for iVendix language de
		'de' as [LanguageCode],
		NULL as [ColorCode],
		NULL as [Color],
		ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey],
		getDate() as [LOAD_DATE]
	from  [IFC_Cache].[dbo].[ArtStamm] ast
	where ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
*/

--size chart FR
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])		
select  'Size chart' as [AttributeName],
		--isnull('EU ' + STUFF((select RTRIM(b.grbez) + space(10-len(RTRIM(b.grbez))) from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '1' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, '') + 'ReplaceWithBR' +
		--'F  ' + STUFF((select RTRIM(b.grbez) + space(10-len(RTRIM(b.grbez))) from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '7' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, ''),'-') as [AttributeValue],
		--shows EU sizes
		isnull('<table border="2" cellspacing="10"><tr><td>EU</td><td>' + STUFF((select RTRIM(b.grbez) + 'ReplaceColumnBreakerOdlo' from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '1' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, '') + '</td></tr>' +
		--shows FR sizes (sprache remains but tpwert is 7 (for FR)
		'<tr><td>F</td><td>' + STUFF((select RTRIM(b.grbez) + 'ReplaceColumnBreakerOdlo' from [IFC_Cache].dbo.GGaBez b, [IFC_Cache].dbo.TpText t, [IFC_Cache].dbo.GGaGr gg	where  t.tapkey=b.TapKey_GGaBezKz  and t.tapkey=b.TapKey_GGaBezKz and t.tpwert = b.GGaBezKz and b.ggankey = gg.ggankey and b.ggnr = gg.ggnr and b.gr = gg.gr and t.sprache = '01' AND t.lfd = 1 and t.tpwert = '7' and b.ggnr = ast.ggnr and t.tanr = 450 order by gg.sortkz, b.gr, b.ggabezkz FOR XML PATH('')), 1, 0, ''),'-') + '</td></tr></table>' as [AttributeValue],
		ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber],
		ltrim(rtrim([InterneBez1])) as [ProductName],
		NULL as [AttributeNameSort],
		NULL as [AttributeValueSort],
		--for iVendix language de
		'fr' as [LanguageCode],
		NULL as [ColorCode],
		NULL as [Color],
		ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey],
		getDate() as [LOAD_DATE]
	from  [IFC_Cache].[dbo].[ArtStamm] ast
	where ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--------------------------------------------------------------------------------------------------------
--Subgroup - English
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Concept' as [AttributeName]
	,CASE WHEN tpsub.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpsub.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpsub.zeile))) END as [AttributeValue] --SUBGROUP
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'en' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpsub ON (ast.ProdGroup=tpsub.tpwert AND ast.TapKey_ProdGroup=tpsub.tapkey AND tpsub.tanr=6 AND tpsub.sprache='01' AND tpsub.lfd=1)
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)

--Subgroup - German
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Concept' as [AttributeName]
	,CASE WHEN tpsub.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpsub.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpsub.zeile))) END as [AttributeValue] --SUBGROUP
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'de' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpsub ON (ast.ProdGroup=tpsub.tpwert AND ast.TapKey_ProdGroup=tpsub.tapkey AND tpsub.tanr=6 AND tpsub.sprache='01' AND tpsub.lfd=1)
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Subgroup - French
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Concept' as [AttributeName]
	,CASE WHEN tpsub.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpsub.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpsub.zeile))) END as [AttributeValue] --SUBGROUP
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'fr' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpsub ON (ast.ProdGroup=tpsub.tpwert AND ast.TapKey_ProdGroup=tpsub.tapkey AND tpsub.tanr=6 AND tpsub.sprache='01' AND tpsub.lfd=1)
--WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Subgroup - Italian
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Concept' as [AttributeName]
	,CASE WHEN tpsub.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpsub.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpsub.zeile))) END as [AttributeValue] --SUBGROUP
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'it' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpsub ON (ast.ProdGroup=tpsub.tpwert AND ast.TapKey_ProdGroup=tpsub.tapkey AND tpsub.tanr=6 AND tpsub.sprache='01' AND tpsub.lfd=1)
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Subgroup - Espania
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Concept' as [AttributeName]
	,CASE WHEN tpsub.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpsub.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpsub.zeile))) END as [AttributeValue] --SUBGROUP
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'es' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpsub ON (ast.ProdGroup=tpsub.tpwert AND ast.TapKey_ProdGroup=tpsub.tapkey AND tpsub.tanr=6 AND tpsub.sprache='01' AND tpsub.lfd=1)
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Subgroup - Norway
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Concept' as [AttributeName]
	,CASE WHEN tpsub.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpsub.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpsub.zeile))) END as [AttributeValue] --SUBGROUP
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'no' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpsub ON (ast.ProdGroup=tpsub.tpwert AND ast.TapKey_ProdGroup=tpsub.tapkey AND tpsub.tanr=6 AND tpsub.sprache='01' AND tpsub.lfd=1)
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)

--COMMIT TRANSACTION

--BEGIN TRANSACTION

--------------------------------------------------------------------------------------------------------
--Fit English
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Fit' as [AttributeName]
	,CASE WHEN tpseg.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpseg.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpseg.zeile))) END as [AttributeValue] --Fit (aka Segment)
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'en' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpseg ON (ast.Segment=tpseg.tpwert AND ast.TapKey_Segment=tpseg.tapkey AND tpseg.tanr=601 AND tpseg.sprache='01' AND tpseg.lfd=1)			
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)

--Fit German
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Fit' as [AttributeName]
	,CASE WHEN tpseg.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpseg.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpseg.zeile))) END as [AttributeValue] --Fit (aka Segment)
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'de' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpseg ON (ast.Segment=tpseg.tpwert AND ast.TapKey_Segment=tpseg.tapkey AND tpseg.tanr=601 AND tpseg.sprache='01' AND tpseg.lfd=1)			
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Fit French
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Fit' as [AttributeName]
	,CASE WHEN tpseg.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpseg.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpseg.zeile))) END as [AttributeValue] --Fit (aka Segment)
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'fr' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpseg ON (ast.Segment=tpseg.tpwert AND ast.TapKey_Segment=tpseg.tapkey AND tpseg.tanr=601 AND tpseg.sprache='01' AND tpseg.lfd=1)			
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Fit Italien
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Fit' as [AttributeName]
	,CASE WHEN tpseg.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpseg.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpseg.zeile))) END as [AttributeValue] --Fit (aka Segment)
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'it' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpseg ON (ast.Segment=tpseg.tpwert AND ast.TapKey_Segment=tpseg.tapkey AND tpseg.tanr=601 AND tpseg.sprache='01' AND tpseg.lfd=1)			
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--Fit Espania
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Fit' as [AttributeName]
	,CASE WHEN tpseg.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpseg.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpseg.zeile))) END as [AttributeValue] --Fit (aka Segment)
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'es' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpseg ON (ast.Segment=tpseg.tpwert AND ast.TapKey_Segment=tpseg.tapkey AND tpseg.tanr=601 AND tpseg.sprache='01' AND tpseg.lfd=1)			
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)



--Fit Norway
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])
		
	SELECT 'Fit' as [AttributeName]
	,CASE WHEN tpseg.zeile IS NULL THEN 'UNDEFINED' WHEN ltrim(rtrim(tpseg.zeile)) = '' THEN 'UNDEFINED' ELSE upper(ltrim(rtrim(tpseg.zeile))) END as [AttributeValue] --Fit (aka Segment)
, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
,ltrim(rtrim([InterneBez1])) as [ProductName]
,NULL as [AttributeNameSort]
,NULL as [AttributeValueSort]
,'no' as [LanguageCode]
,NULL as [ColorCode]
,NULL as [Color]
,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
,getDate() as [LOAD_DATE]
  FROM [IFC_Cache].[dbo].[ArtStamm] ast
LEFT OUTER JOIN [IFC_Cache].[dbo].TpText tpseg ON (ast.Segment=tpseg.tpwert AND ast.TapKey_Segment=tpseg.tapkey AND tpseg.tanr=601 AND tpseg.sprache='01' AND tpseg.lfd=1)			
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)


--COMMIT TRANSACTION

--------------------------------------------------------------------------------------------------------
--Update 15/7/16 - MPF, Added USP from Intex, Article Text Table
--Update 26/7/16 - MPF, Added Language support
--BEGIN TRANSACTION
--English
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])

		   SELECT distinct 'USP' as [AttributeName]
	,STUFF((SELECT RTRIM(Text) + 'ReplaceWithBR' FROM [IFC_Cache].[dbo].ArtText tStuff where [tStuff].ArtsNr1 = [tMain].ArtsNr1 and [tStuff].[ArtsKey] = [tMain].[ArtsKey] and [tStuff].[Sprache] = tMain.[Sprache] and [tStuff].[ArtTA] = [tMain].[ArtTA] FOR XML PATH('')), 1, 0, '') as [AttributeValue]
	, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
	,ltrim(rtrim([InterneBez1])) as [ProductName]
	,NULL as [AttributeNameSort]
	,NULL as [AttributeValueSort]
	,'en' as [LanguageCode]
	,NULL as [ColorCode]
	,NULL as [Color]
	,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
	,getDate() as [LOAD_DATE]

FROM [IFC_Cache].[dbo].[ArtStamm] ast
	JOIN [IFC_Cache].[dbo].ArtText tMain ON (ast.[ArtsNr1] = tMain.[ArtsNr1] AND ast.[ArtsKey] = tMain.[ArtsKey])
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
and tMain.[Sprache] = '02' and tMain.[ArtTA] = '01' and tMain.[Text] not in ('00','10','12')

--German
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])

		   SELECT distinct 'USP' as [AttributeName]
	,STUFF((SELECT RTRIM(Text) + 'ReplaceWithBR' FROM [IFC_Cache].[dbo].ArtText tStuff where [tStuff].ArtsNr1 = [tMain].ArtsNr1 and [tStuff].[ArtsKey] = [tMain].[ArtsKey] and [tStuff].[Sprache] = tMain.[Sprache] and [tStuff].[ArtTA] = [tMain].[ArtTA] FOR XML PATH('')), 1, 0, '') as [AttributeValue]
	, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
	,ltrim(rtrim([InterneBez1])) as [ProductName]
	,NULL as [AttributeNameSort]
	,NULL as [AttributeValueSort]
	,'de' as [LanguageCode]
	,NULL as [ColorCode]
	,NULL as [Color]
	,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
	,getDate() as [LOAD_DATE]

FROM [IFC_Cache].[dbo].[ArtStamm] ast
	JOIN [IFC_Cache].[dbo].ArtText tMain ON (ast.[ArtsNr1] = tMain.[ArtsNr1] AND ast.[ArtsKey] = tMain.[ArtsKey])
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
and tMain.[Sprache] = '02' and tMain.[ArtTA] = '01' and tMain.[Text] not in ('00','10','12')


--French
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])

		   SELECT distinct 'USP' as [AttributeName]
	,STUFF((SELECT RTRIM(Text) + 'ReplaceWithBR' FROM [IFC_Cache].[dbo].ArtText tStuff where [tStuff].ArtsNr1 = [tMain].ArtsNr1 and [tStuff].[ArtsKey] = [tMain].[ArtsKey] and [tStuff].[Sprache] = tMain.[Sprache] and [tStuff].[ArtTA] = [tMain].[ArtTA] FOR XML PATH('')), 1, 0, '') as [AttributeValue]
	, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
	,ltrim(rtrim([InterneBez1])) as [ProductName]
	,NULL as [AttributeNameSort]
	,NULL as [AttributeValueSort]
	,'fr' as [LanguageCode]
	,NULL as [ColorCode]
	,NULL as [Color]
	,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
	,getDate() as [LOAD_DATE]

FROM [IFC_Cache].[dbo].[ArtStamm] ast
	JOIN [IFC_Cache].[dbo].ArtText tMain ON (ast.[ArtsNr1] = tMain.[ArtsNr1] AND ast.[ArtsKey] = tMain.[ArtsKey])
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
and tMain.[Sprache] = '02' and tMain.[ArtTA] = '01' and tMain.[Text] not in ('00','10','12')


--Italien
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])

		   SELECT distinct 'USP' as [AttributeName]
	,STUFF((SELECT RTRIM(Text) + 'ReplaceWithBR' FROM [IFC_Cache].[dbo].ArtText tStuff where [tStuff].ArtsNr1 = [tMain].ArtsNr1 and [tStuff].[ArtsKey] = [tMain].[ArtsKey] and [tStuff].[Sprache] = tMain.[Sprache] and [tStuff].[ArtTA] = [tMain].[ArtTA] FOR XML PATH('')), 1, 0, '') as [AttributeValue]
	, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
	,ltrim(rtrim([InterneBez1])) as [ProductName]
	,NULL as [AttributeNameSort]
	,NULL as [AttributeValueSort]
	,'it' as [LanguageCode]
	,NULL as [ColorCode]
	,NULL as [Color]
	,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
	,getDate() as [LOAD_DATE]

FROM [IFC_Cache].[dbo].[ArtStamm] ast
	JOIN [IFC_Cache].[dbo].ArtText tMain ON (ast.[ArtsNr1] = tMain.[ArtsNr1] AND ast.[ArtsKey] = tMain.[ArtsKey])
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
and tMain.[Sprache] = '02' and tMain.[ArtTA] = '01' and tMain.[Text] not in ('00','10','12')


--Spanish
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])

		   SELECT distinct 'USP' as [AttributeName]
	,STUFF((SELECT RTRIM(Text) + 'ReplaceWithBR' FROM [IFC_Cache].[dbo].ArtText tStuff where [tStuff].ArtsNr1 = [tMain].ArtsNr1 and [tStuff].[ArtsKey] = [tMain].[ArtsKey] and [tStuff].[Sprache] = tMain.[Sprache] and [tStuff].[ArtTA] = [tMain].[ArtTA] FOR XML PATH('')), 1, 0, '') as [AttributeValue]
	, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
	,ltrim(rtrim([InterneBez1])) as [ProductName]
	,NULL as [AttributeNameSort]
	,NULL as [AttributeValueSort]
	,'es' as [LanguageCode]
	,NULL as [ColorCode]
	,NULL as [Color]
	,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
	,getDate() as [LOAD_DATE]

FROM [IFC_Cache].[dbo].[ArtStamm] ast
	JOIN [IFC_Cache].[dbo].ArtText tMain ON (ast.[ArtsNr1] = tMain.[ArtsNr1] AND ast.[ArtsKey] = tMain.[ArtsKey])
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
and tMain.[Sprache] = '02' and tMain.[ArtTA] = '01' and tMain.[Text] not in ('00','10','12')


--Norwegian
INSERT INTO [dbo].[iV_PA]
           ([AttributeName]
           ,[AttributeValue]
           ,[ItemNumber]
           ,[ProductName]
           ,[AttributeNameSort]
           ,[AttributeValueSort]
           ,[LanguageCode]
           ,[ColorCode]
           ,[Color]
           ,[SupplierCatalogKey]
           ,[LOAD_DATE])

		   SELECT distinct 'USP' as [AttributeName]
	,STUFF((SELECT RTRIM(Text) + 'ReplaceWithBR' FROM [IFC_Cache].[dbo].ArtText tStuff where [tStuff].ArtsNr1 = [tMain].ArtsNr1 and [tStuff].[ArtsKey] = [tMain].[ArtsKey] and [tStuff].[Sprache] = tMain.[Sprache] and [tStuff].[ArtTA] = [tMain].[ArtTA] FOR XML PATH('')), 1, 0, '') as [AttributeValue]
	, ltrim(rtrim(ast.[ArtsNr1])) as [ItemNumber]
	,ltrim(rtrim([InterneBez1])) as [ProductName]
	,NULL as [AttributeNameSort]
	,NULL as [AttributeValueSort]
	,'no' as [LanguageCode]
	,NULL as [ColorCode]
	,NULL as [Color]
	,ltrim(rtrim(ast.[ArtsKey])) as [SupplierCatalogKey]
	,getDate() as [LOAD_DATE]

FROM [IFC_Cache].[dbo].[ArtStamm] ast
	JOIN [IFC_Cache].[dbo].ArtText tMain ON (ast.[ArtsNr1] = tMain.[ArtsNr1] AND ast.[ArtsKey] = tMain.[ArtsKey])
---WHERE ast.[ArtsKey]  IN ('011161H', '011162H', '011171H')
--- added 04.08.2016/cls to avoid hardcoded seasons
WHERE ast.[ArtsKey]  IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
and tMain.[Sprache] = '02' and tMain.[ArtTA] = '01' and tMain.[Text] not in ('00','10','12')




--Update 15/7/16 - MPF, replace text ReplaceWithBR with <BR> (somehow the STUFF with XLM in above insert does not like < (
UPDATE [dbo].[iV_PA]
SET    [AttributeValue] = replace(replace([AttributeValue], 'ReplaceWithBR', '<br>'), 'ReplaceColumnBreakerOdlo','</td><td>')
--WHERE  [AttributeName] = 'USP' and [AttributeValue] LIKE '%ReplaceWithBR%';



--COMMIT TRANSACTION

END

GO
