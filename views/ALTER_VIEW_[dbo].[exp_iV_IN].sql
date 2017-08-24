SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[exp_iV_IN]
AS

SELECT 'UPC' as UPC
	,'SKU' as SKU
	,'SupplierProductKey' as SupplierProductKey
	,'EAN' as EAN
	,'Inventory' as Inventory
	,'Available_dt' as Available_dt
	,'SupplierCatalogKey' as SupplierCatalogKey
	,'InventorySource_cd' as InventorySource_cd

UNION ALL

SELECT [UPC]
	,[SKU]
	,[SupplierProductKey]
	,[EAN]
	,CAST([Inventory] AS VARCHAR(50))
	,[Available_dt]
	,[dbo].[GetProcPrm]('SupplierCatalogKeyPrefix',1)+[SupplierCatalogKey] as [SupplierCatalogKey] 
	,[InventorySource_cd]
FROM [CST_ITF].[dbo].[iV_IN]
GO


