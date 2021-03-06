SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_CSL]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_CSL]

	COMMIT TRANSACTION

-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================



/*
	BEGIN TRANSACTION /****************************** LOAD ALL csl **********************************/

INSERT INTO [dbo].[iV_CSL]
           ([SupplierCatalogKey]
           ,[ColorStoryName]
           ,[Color]
           ,[ColorCode]
           ,[ActionCode]
           ,[LOAD_DATE])
     SELECT distinct [SupplierCatalogKey]
,'Swiss-Stuff' AS [ColorStoryName]
      
      ,[Color]
      ,[ColorCode]
	  ,'UP' AS [ActionCode]
      ,getDate() AS [LOAD_DATE]
  FROM [dbo].[iV_ST]
   WHERE [Color] LIKE ('Swiss%')


	COMMIT TRANSACTION
*/

END

GO
