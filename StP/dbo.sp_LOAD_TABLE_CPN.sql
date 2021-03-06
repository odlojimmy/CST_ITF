SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_CPN]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_CPN]

	COMMIT TRANSACTION


-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================




	BEGIN TRANSACTION /****************************** LOAD ALL cpn **********************************/


INSERT INTO [dbo].[iV_CPN]
           ([SupplierCatalogKey]
           ,[ItemNumber]
           ,[ProductName]
           ,[ProductSort]
           ,[PageNumber]
           ,[PageSort]
           ,[WorkbookName]
           ,[WorkbookSort]
           ,[ActionCode]
           ,[LOAD_DATE])
SELECT distinct 
st.[SupplierCatalogKey]
,[ItemNumber]
,[ProductName]
,NULL AS [ProductSort]
,pageid AS [PageNumber]
,NULL as [PageSort]
,[Catalog] AS [WorkbookName]
,NULL as [WorkbookSort]
,'UP' AS [ActionCode]
,getDate() AS [LOAD_DATE]
FROM [dbo].[iV_ST] st,
(
SELECT 
[SupplierCatalogKey]
,[Directory] -- category/division
	,[NavCategory] -- gender
	,ROW_NUMBER() OVER(PARTITION BY [SupplierCatalogKey] ORDER BY [Directory],[NavCategory]) as pageid -- katalogseite sortiert und gruppiert nach division und gender
FROM [dbo].[iV_ST] srt
GROUP BY [SupplierCatalogKey],[Directory]
	,[NavCategory]
) temp ------------------------ sortierung der katalogseiten 
WHERE temp.[SupplierCatalogKey] = st.[SupplierCatalogKey]
AND temp.[Directory] = st.[Directory]
AND temp.[NavCategory] = st.[NavCategory]


	COMMIT TRANSACTION



END

GO
