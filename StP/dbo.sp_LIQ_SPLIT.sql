SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	split season between regular and liq articles
-- =============================================
ALTER PROCEDURE [dbo].[sp_LIQ_SPLIT]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--MPFYL, 05/12/2016, START: Adjust the liq approach. In the past, liq definition was old and new liq. now it seems that only old liq qualifies as liq. the new liq data will still be kept in the regular seasonal catalogue.


	BEGIN TRANSACTION

	UPDATE [dbo].[iV_PL]
	SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_PL] t
	,[dbo].[iV_ST] st
	--old liq logic --WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
	AND st.[SupplierCatalogKey] = t.[SupplierCatalogKey]
	AND st.EAN = t.EAN
	
	COMMIT TRANSACTION

	BEGIN TRANSACTION

	UPDATE [dbo].[iV_IN]
	SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_IN] t
	,[dbo].[iV_ST] st
	--old liq logic --WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
	AND st.[SupplierCatalogKey] = t.[SupplierCatalogKey]
	AND st.EAN = t.EAN
	
	COMMIT TRANSACTION

	BEGIN TRANSACTION

	UPDATE [dbo].[iV_DD]
	SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_DD] t
	,[dbo].[iV_ST] st
	--old liq logic --WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
	AND st.[SupplierCatalogKey] = t.[SupplierCatalogKey]
	AND st.EAN = t.EAN
	
	COMMIT TRANSACTION

	--mpf 31/08/16: braucht es das wirklich? - ist ja oben schon???
	BEGIN TRANSACTION

	UPDATE [dbo].[iV_DD]
	SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_DD] t
	,[dbo].[iV_ST] st
	--old liq logic --WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
	AND st.[SupplierCatalogKey] = t.[SupplierCatalogKey]
	AND st.EAN = t.EAN
	
	COMMIT TRANSACTION



	--mpf 31/08/16: new as discount is calculated differently
	BEGIN TRANSACTION

	UPDATE [dbo].[iV_DD_Discount_Detail]
	SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_DD_Discount_Detail] t
	,[dbo].[iV_ST] st
	--old liq logic --WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
	AND st.[SupplierCatalogKey] = t.[SupplierCatalogKey]
	AND st.EAN = t.EAN
	
	COMMIT TRANSACTION




	--MPF 09/08/216: Update to include Terms for Liquidation as well
	BEGIN TRANSACTION /***** add PA for LIQ articles **********/

		INSERT INTO [dbo].[iV_PT]
			   ([CAccountNum]
			   ,[MappingCode]
			   ,[TermsCode]
			   ,[LOAD_DATE])
		SELECT [CAccountNum]
			   ,REPLACE(pt.[MappingCode], 'H', 'L')
			   ,[TermsCode]
			   ,getDate()
	  FROM [dbo].[iV_PT] pt
	  ,(
	  SELECT distinct [SupplierCatalogKey]
			FROM [dbo].[iV_ST]
				--WHERE [hlp_DiscountNOS] IN ('50','80')
				WHERE [hlp_DiscountNOS] IN ('80')
			) tmp
		WHERE pt.[MappingCode] = tmp.[SupplierCatalogKey]

	COMMIT TRANSACTION




	/*****************************************************************/
	/*  CSL and CPN should NOT have any LIQ Articles                 */
	/*****************************************************************/


	
	BEGIN TRANSACTION /***** add PA for LIQ articles **********/

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
	SELECT [AttributeName]
      ,[AttributeValue]
      ,pa.[ItemNumber]
      ,[ProductName]
      ,[AttributeNameSort]
      ,[AttributeValueSort]
      ,[LanguageCode]
      ,[ColorCode]
      ,[Color]
      ,REPLACE(pa.[SupplierCatalogKey], 'H', 'L')
      ,getDate()
  FROM [dbo].[iV_PA] pa
  ,(
  SELECT distinct [SupplierCatalogKey]
		,[ItemNumber]
	FROM [dbo].[iV_ST]
	--WHERE [hlp_DiscountNOS] IN ('50', '80')
	WHERE [hlp_DiscountNOS] IN ('80')
	) tmp
	WHERE pa.[SupplierCatalogKey] = tmp.[SupplierCatalogKey]
	AND pa.[ItemNumber] = tmp.[ItemNumber]

	COMMIT TRANSACTION

	
	BEGIN TRANSACTION /************** keep this update at the end ***************************/

	UPDATE [dbo].[iV_ST]
	SET [Catalog] = [Catalog]+'-LIQ'
	,[SupplierCatalogKey] = REPLACE([SupplierCatalogKey], 'H', 'L')
	--WHERE [hlp_DiscountNOS] IN ('50', '80')
	WHERE [hlp_DiscountNOS] IN ('80')
	
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

END
GO
