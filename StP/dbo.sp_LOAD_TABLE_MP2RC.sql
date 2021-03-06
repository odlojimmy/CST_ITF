SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_MP2RC]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_MP2RC]

	COMMIT TRANSACTION

-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================


/*
	BEGIN TRANSACTION /****************************** LOAD ALL IN **********************************/

	INSERT INTO [dbo].[iV_MP2RC]
           ([ItemNumber]
           ,[ProductName]
           ,[ReportingCategory]
           ,[ActionCode]
           ,[LOAD_DATE])
		SELECT [ItemNumber],[ProductName]
,[hlp_ReportingCategory] AS [ReportingCategory],'UP' AS [ActionCode], getDate() as [LOAD_DATE]
FROM (
SELECT [ItemNumber],[ProductName]
,[hlp_ReportingCategory]
,max([SupplierCatalogKey])  as seasonMAX   
  FROM [dbo].[iV_ST]
  WHERE [hlp_ReportingCategory] IN (
	SELECT distinct [ReportingCategory] FROM [dbo].[iV_ROSFD]
	)
  GROUP BY [ItemNumber],[ProductName]
,[hlp_ReportingCategory]
) as hsel

	COMMIT TRANSACTION

*/

END

GO
