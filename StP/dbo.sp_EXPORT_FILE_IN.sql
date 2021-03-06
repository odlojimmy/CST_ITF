SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************************************/
/* Author:      Marc Ziegler                                                                         */
/* Create date: 21.4.2016                                                                            */
/* Description:	Exports the prepared inventory data into files for further processing to iVendix     */
/* Change Hist: 17.08.2017 JRU                                                                       */
/*              - Removed all Database Direct Addressing to get the Proc more transportable          */
/*              - added ['+DB_NAME()+'] for the bcp commands since they are running in msdb database */
/*              - De-Activated Discount Calculation (must be re-activated, when actualizing the proc */
/*                on the production system, before the catalog must be re-named)                     */
/*****************************************************************************************************/

ALTER PROCEDURE [dbo].[sp_EXPORT_FILE_IN]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @String varchar(2000)
--Remove the files according the parametrization
SET @String = 'Powershell.exe -command Remove-Item "'+[dbo].[GetProcPrm]('InventoryPath',1)+'*.*"'
EXEC xp_cmdshell @String

BEGIN 
BEGIN TRANSACTION

--IN
-- writing the file according the parametrization
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_IN]" queryout '+[dbo].[GetProcPrm]('InventoryPath',1)+'IN_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

COMMIT TRANSACTION

END

END

GO
