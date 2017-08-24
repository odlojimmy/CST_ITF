SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[exp_iV_CPN]
AS

SELECT 'SupplierCatalogKey' as SupplierCatalogKey
	,'ItemNumber' as ItemNumber
	,'ProductName' as ProductName
	,'ProductSort' as ProductSort
	,'PageNumber' as PageNumber
	,'PageSort' as PageSort
	,'WorkbookName' as WorkbookName
	,'WorkbookSort' as WorkbookSort
	,'ActionCode' as ActionCode

UNION ALL

SELECT 
--> Fix to get the possibility, to export a different catalog key to iVendix (e.g. for parallel installation)
       [dbo].[GetProcPrm]('SupplierCatalogKeyPrefix',1)+[SupplierCatalogKey] as [SupplierCatalogKey] 
      ,[ItemNumber]
      ,[ProductName]
      ,CAST([ProductSort] AS VARCHAR(50))
      ,[PageNumber]
      ,CAST([PageSort] AS VARCHAR(50))
      ,[WorkbookName]
      ,CAST([WorkbookSort] AS VARCHAR(50))
      ,[ActionCode]
  FROM [dbo].[iV_CPN]
GO


