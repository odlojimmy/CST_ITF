SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- Change Hist:  01.09.2017 Jimmy Rüedi
--               Change from direct access to [INTEXSALES].[OdloDE] to [IFC_Cache]
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_ID]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_ID]

COMMIT TRANSACTION

-- =============================================
-- This file is ready and approved by iVendix, but currently not exported. 
-- To reactivate the export simply uncomment transactions below
-- mz - 16.06.2016
-- =============================================


/*

BEGIN TRANSACTION  /****************************** LOAD ALL IN **********************************/

INSERT INTO [dbo].[iV_ID]
           ([CAccountNum]
           ,[InvoiceNumber]
           ,[InvoiceDate]
           ,[InvoiceAmount]
           ,[InvoiceStatus]
           ,[Term]
           ,[DueDate]
           ,[ActionCode]
           ,[LOAD_DATE])
     SELECT rk.KusNr AS [CAccountNum]
	,rk.RNr AS [InvoiceNumber]
	,CONVERT(VARCHAR(10), rk.ReDatum, 101) AS [InvoiceDate]
	,rk.BruttoFW AS [InvoiceAmount]
	,'Open' AS [InvoiceStatus]
	,ltrim(rtrim(LEFT(lbt.zeile, 25))) AS [Term]
	,CONVERT(VARCHAR(10), (DATEADD(day, 30, rk.ReDatum)), 101) AS [DueDate]
	,'UP' AS [ActionCode]
	,getDate() AS [LOAD_DATE]
FROM [IFC_Cache].dbo.[ReKopf] rk
	,[IFC_Cache].dbo.[KuStamm] ks
	,[IFC_Cache].dbo.[TpText] lbt
WHERE (
		rk.TapKey_PreisSt = lbt.tapkey
		AND rk.PreisSt = lbt.tpwert
		AND lbt.tanr = 25
		AND lbt.sprache = ks.Sprache
		AND lbt.lfd = 1
		)
	AND (
		rk.KusNr = ks.KusNr
		AND rk.KustKey = ks.KustKey
		)
	--- AND rk.RekSaisKey IN ('011161H', '011162H', '011171H')
	--- added 04.08.2016/cls to avoid hardcoded seasons
	AND rk.RekSaisKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	AND rk.Art IN ('01', '04')
	AND (
		rk.Status1 = 3
		OR rk.Status1 = 4
		)

COMMIT TRANSACTION

BEGIN TRANSACTION

DELETE FROM [dbo].[iV_ID]
WHERE [CAccountNum] NOT IN (
	SELECT distinct [CAccountNum] FROM [dbo].[iV_CM]
	)



COMMIT TRANSACTION

*/

END
GO
