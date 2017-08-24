SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[exp_iV_ST]
AS

SELECT 'Catalog' as [Catalog]
	,'SupplierCatalogKey' as SupplierCatalogKey
	,'ItemNumber' as ItemNumber
	,'ProductName' as ProductName
	,'ProductSort' as ProductSort
	,'BusinessUnit_cd' as BusinessUnit_cd
	,'Directory' as Directory
	,'DirectorySort' as DirectorySort
	,'NavCategory' as NavCategory
	,'NavCatSort' as NavCatSort
	,'SubCategory' as SubCategory
	,'SubCatSort' as SubCatSort
	,'ColorHeader' as ColorHeader
	,'ColorCode' as ColorCode
	,'Color' as Color
	,'ColorSort' as ColorSort
	,'HorzSizeHeader' as HorzSizeHeader
	,'Size' as Size
	,'SizeSort' as SizeSort
	,'VsizeHead' as VsizeHead
	,'Vsize' as Vsize
	,'VsizeSort' as VsizeSort
	,'UOM_cd' as UOM_cd
	,'FirstShip_dt' as FirstShip_dt
	,'UPC' as UPC
	,'SKU' as SKU
	,'SupplierProductKey' as SupplierProductKey
	,'EAN' as EAN
	,'MasterImage' as MasterImage
	,'ColorImage' as ColorImage
	,'LineItemMin' as LineItemMin
	,'LineItemMult' as LineItemMult
	,'StyleColorMin' as StyleColorMin
	,'CommonColor' as CommonColor

UNION ALL

SELECT [Catalog]
	,[dbo].[GetProcPrm]('SupplierCatalogKeyPrefix',1)+[SupplierCatalogKey] as [SupplierCatalogKey] 
	,[ItemNumber]
	,[ProductName]
	,CAST([ProductSort] AS VARCHAR(50))
	,[BusinessUnit_cd]
	,[Directory]
	,CAST([DirectorySort] AS VARCHAR(50))
	,[NavCategory]
	,CAST([NavCatSort] AS VARCHAR(50))
	,[SubCategory]
	,CAST([SubCatSort] AS VARCHAR(50))
	,[ColorHeader]
	,[ColorCode]
	,[Color]
	,CAST([ColorSort] AS VARCHAR(50))
	,[HorzSizeHeader]
	,[Size]
	,CAST([SizeSort] AS VARCHAR(50))
	,[VsizeHead]
	,[Vsize]
	,CAST([VsizeSort] AS VARCHAR(50))
	,[UOM_cd]
	,[FirstShip_dt]
	,[UPC]
	,[SKU]
	,[SupplierProductKey]
	,[EAN]
	,[MasterImage]
	,[ColorImage]
	,CAST([LineItemMin] AS VARCHAR(50))
	,CAST([LineItemMult] AS VARCHAR(50))
	,CAST([StyleColorMin] AS VARCHAR(50))
	,[CommonColor]
FROM [CST_ITF].[dbo].[iV_ST]

GO


