SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Validate data according to iVendix specifications
-- =============================================
ALTER PROCEDURE [dbo].[sp_DATA_VALIDATION]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




	BEGIN TRANSACTION

	  DELETE FROM [dbo].[iV_CM] /******** delete customers without sales rep *************/
  WHERE [SR_Code] NOT IN (
	SELECT distinct [SR_Code] FROM [dbo].[iV_SUM]
	)
	
	COMMIT TRANSACTION

	BEGIN TRANSACTION

	  DELETE FROM [dbo].[iV_SUM]  /******** delete sales rep without customers *************/
  WHERE [SR_Code] NOT IN (
	SELECT distinct [SR_Code] FROM [dbo].[iV_CM]
	)

	COMMIT TRANSACTION

	


	BEGIN TRANSACTION

	 DELETE FROM [dbo].[iV_CM]  /******** delete customers without currency/pricelist *************/
 WHERE NOT EXISTS (
	SELECT DISTINCT [Currency_cd], [PriceSchedule] FROM [dbo].[iV_PL]
	WHERE [dbo].[iV_PL].[Currency_cd] = [dbo].[iV_CM].[Currency_cd]
	AND [dbo].[iV_PL].[PriceSchedule] = [dbo].[iV_CM].[PriceSchedule]
)


  COMMIT TRANSACTION



  BEGIN TRANSACTION

  DELETE FROM [dbo].[iV_ST]  /************** delete all articles (EAN) in stylefile not found in pricelist ************************/
WHERE NOT EXISTS (
SELECT DISTINCT [SupplierCatalogKey], [EAN]
		FROM [dbo].[iV_PL]
		WHERE  [dbo].[iV_PL].[EAN] = [dbo].[iV_ST].[EAN]
		AND [dbo].[iV_PL].[SupplierCatalogKey] = [dbo].[iV_ST].[SupplierCatalogKey]
)

COMMIT TRANSACTION

BEGIN TRANSACTION

DELETE FROM [dbo].[iV_PL]  /************** delete all articles (EAN) pricelist not found in style file ************************/
WHERE NOT EXISTS (
SELECT DISTINCT [SupplierCatalogKey], [EAN]
		FROM [dbo].[iV_ST]
		WHERE  [dbo].[iV_ST].[EAN] = [dbo].[iV_PL].[EAN]
		AND [dbo].[iV_ST].[SupplierCatalogKey] = [dbo].[iV_PL].[SupplierCatalogKey]
)

COMMIT TRANSACTION


BEGIN TRANSACTION

DELETE FROM [dbo].[iV_PA]  /************** delete all articles item-number in PA file not found in style file ************************/
WHERE NOT EXISTS (
SELECT DISTINCT [SupplierCatalogKey], [ItemNumber]
		FROM [dbo].[iV_ST]
		WHERE  [dbo].[iV_ST].[ItemNumber] = [dbo].[iV_PA].[ItemNumber]
		AND [dbo].[iV_ST].[SupplierCatalogKey] = [dbo].[iV_PA].[SupplierCatalogKey]
)

COMMIT TRANSACTION




/************************************************************ clean out special characters ******************************************/
BEGIN TRANSACTION

UPDATE [dbo].[iV_ST]
SET [ProductName] = REPLACE([ProductName], '½', '1/2')

COMMIT TRANSACTION

BEGIN TRANSACTION

UPDATE [dbo].[iV_ST]
SET [ProductName] = REPLACE([ProductName], '¾', '3/4')

COMMIT TRANSACTION

BEGIN TRANSACTION

UPDATE [dbo].[iV_ST]
SET [ProductName] = REPLACE([ProductName], '®', '')

COMMIT TRANSACTION

BEGIN TRANSACTION

UPDATE [dbo].[iV_ST]
SET [ProductName] = REPLACE([ProductName], 'Å', 'A')

COMMIT TRANSACTION

BEGIN TRANSACTION

UPDATE [dbo].[iV_ST]
SET [ProductName] = REPLACE([ProductName], 'À', 'A')

COMMIT TRANSACTION


/************************************************************ reassign product name in PA table from ST ******************************************/
BEGIN TRANSACTION

UPDATE [dbo].[iV_PA]
SET [ProductName] = st.[ProductName]
FROM (
SELECT distinct [SupplierCatalogKey], [ItemNumber], [ProductName] FROM [dbo].[iV_ST]
) as st,
[dbo].[iV_PA] pa
WHERE pa.[SupplierCatalogKey] = st.[SupplierCatalogKey]
AND pa.[ItemNumber] = st.[ItemNumber]

COMMIT TRANSACTION




END
GO
