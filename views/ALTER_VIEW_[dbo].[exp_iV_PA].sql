SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[exp_iV_PA]
AS

SELECT 'AttributeName' as AttributeName
	,'AttributeValue' as AttributeValue
	,'ItemNumber' as ItemNumber
	,'ProductName' as ProductName
	,'AttributeNameSort' as AttributeNameSort
	,'AttributeValueSort' as AttributeValueSort
	,'LanguageCode' as LanguageCode
	,'ColorCode' as ColorCode
	,'Color' as Color
	,'SupplierCatalogKey' as SupplierCatalogKey

UNION ALL

SELECT [AttributeName]
	,[AttributeValue]
	,[ItemNumber]
	,[ProductName]
	,CAST([AttributeNameSort] AS VARCHAR(50))
	,CAST([AttributeValueSort] AS VARCHAR(50))
	,[LanguageCode]
	,[ColorCode]
	,[Color]
	,[dbo].[GetProcPrm]('SupplierCatalogKeyPrefix',1)+[SupplierCatalogKey] as [SupplierCatalogKey] 
FROM [CST_ITF].[dbo].[iV_PA]
GO


