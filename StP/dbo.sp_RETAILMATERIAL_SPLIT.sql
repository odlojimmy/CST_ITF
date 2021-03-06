SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Markus Pfyl
-- Create date: 11.04.2017
-- Description:	split retail material into separate catalogue
-- =============================================
ALTER PROCEDURE [dbo].[sp_RETAILMATERIAL_SPLIT]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--ST - Styles - Set correct catalog (season) and SupplierCatalogKEy
	UPDATE [dbo].[iV_ST] 
		SET [Catalog]				= rtrim(TempEAN.CategoryGroup) + '-' + st.[Catalog],
			[SupplierCatalogKey]	= rtrim(TempEAN.CategoryGroup) + '-' + st.[SupplierCatalogKey]
		FROM [dbo].[iV_ST] st,
		(select EANCode, ArtsKey, CategoryGroup
			from [dbo].[INTEX_RAW_ArtEAN]
			WHERE CategoryGroup = 'RETAIL') as TempEAN
		where st.ean = TempEAN.eanCode AND
			  st.SupplierCatalogKey = TempEAN.ArtsKey

	--PL - PriceList - 
	UPDATE [dbo].[iV_PL] 
		SET [SupplierCatalogKey]	= rtrim(TempEAN.CategoryGroup) + '-' + pl.[SupplierCatalogKey]
		FROM [dbo].[iV_PL] pl,
		(select EANCode, ArtsKey, CategoryGroup
			from [dbo].[INTEX_RAW_ArtEAN]
			WHERE CategoryGroup = 'RETAIL') as TempEAN
		where pl.ean = TempEAN.eanCode AND
			  pl.SupplierCatalogKey = TempEAN.ArtsKey

END
GO
