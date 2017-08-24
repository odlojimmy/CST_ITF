SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[exp_iV_DD]
AS

SELECT 'DiscountSchedule' as [DiscountSchedule]
      ,'Discount' as [Discount]
      ,'Identifier' as [Identifier]
      ,'UPC' as [UPC]
      ,'SKU' as [SKU]
      ,'SupplierProductKey' as [SupplierProductKey]
      ,'EAN' as [EAN]
      ,'SupplierCatalogKey' as [SupplierCatalogKey]
UNION ALL

--original table is ds - which has multiple ds per customer - which iVendix does not like
--claudio updated and created based on ds table a new ds_discount_header table which is not used
--old
/*
SELECT [DiscountSchedule]
      ,CAST([Discount] AS VARCHAR(50))
      ,CAST([Identifier] AS VARCHAR(50))
      ,[UPC]
      ,[SKU]
      ,[SupplierProductKey]
      ,[EAN]
      ,[SupplierCatalogKey]
  FROM [dbo].[iV_DD]
*/

SELECT [DiscountSchedule]
      ,CAST([Discount] AS VARCHAR(50))
      ,CAST([Identifier] AS VARCHAR(50))
      ,[UPC]
      ,[SKU]
      ,[SupplierProductKey]
      ,[EAN]
	  --> Fix to get the possibility, to export a different catalog key to iVendix (e.g. for parallel installation)
       ,[dbo].[GetProcPrm]('SupplierCatalogKeyPrefix',1)+[SupplierCatalogKey] as [SupplierCatalogKey] 
  FROM [dbo].[iV_DD_Discount_Detail]

GO


