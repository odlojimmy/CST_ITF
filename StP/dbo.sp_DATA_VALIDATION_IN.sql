SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Validate data according to iVendix specifications
-- =============================================
ALTER PROCEDURE [dbo].[sp_DATA_VALIDATION_IN]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




BEGIN TRANSACTION

DELETE FROM [dbo].[iV_IN]  /************** delete all articles (EAN) in inventory file not found in style file ************************/
WHERE NOT EXISTS (
SELECT DISTINCT [SupplierCatalogKey], [EAN]
		FROM [dbo].[iV_ST]
		WHERE  [dbo].[iV_ST].[EAN] = [dbo].[iV_IN].[EAN]
		AND [dbo].[iV_ST].[SupplierCatalogKey] = [dbo].[iV_IN].[SupplierCatalogKey]
)

COMMIT TRANSACTION


END

GO
