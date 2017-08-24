SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[exp_iV_PL]
AS

SELECT 'Currency_cd' as Currency_cd
	,'UPC' as UPC
	,'SKU' as SKU
	,'SupplierProductKey' as SupplierProductKey
	,'EAN' as EAN
	,'Price' as Price
	,'MAP' as MAP
	,'Units' as Units
	,'PriceSchedule' as PriceSchedule
	,'Retail' as Retail
	,'SupplierCatalogKey' as SupplierCatalogKey
	,'SalePrice' as SalePrice
	,'SaleDiscount' as SaleDiscount

UNION ALL

SELECT [Currency_cd]
	,[UPC]
	,[SKU]
	,[SupplierProductKey]
	,[EAN]
	,CAST([Price] AS VARCHAR(50))
	,CAST([MAP] AS VARCHAR(50))	
	,CAST([Units] AS VARCHAR(50))
	,[PriceSchedule]
	,CAST([Retail] AS VARCHAR(50))
	,[dbo].[GetProcPrm]('SupplierCatalogKeyPrefix',1)+[SupplierCatalogKey] as [SupplierCatalogKey] 
	,CAST([SalePrice] AS VARCHAR(50))
	,CAST([SaleDiscount] AS VARCHAR(50))
FROM [CST_ITF].[dbo].[iV_PL]
GO


