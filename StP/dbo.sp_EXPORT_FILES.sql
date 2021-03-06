SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************************************/
/* Author:      Marc Ziegler                                                                         */
/* Create date: 21.4.2016                                                                            */
/* Description:	Exports the prepared data into files for further processing to iVendix               */
/* Change Hist: 17.08.2017 JRU                                                                       */
/*              - Removed all Database Direct Addressing to get the Proc more transportable          */
/*              - added ['+DB_NAME()+'] for the bcp commands since they are running in msdb database */
/*              - De-Activated Discount Calculation (must be re-activated, when actualizing the proc */
/*                on the production system, before the catalog must be re-named)                     */
/*              - Parametrization implemented                                                        */
/*****************************************************************************************************/

ALTER PROCEDURE [dbo].[sp_EXPORT_FILES]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @String varchar(2000)
--Remove the files according the parametrization
SET @String = 'Powershell.exe -command Remove-Item "'+[dbo].[GetProcPrm]('MainDataPath',1)+'*.*"'
EXEC xp_cmdshell @String

BEGIN 
-- CM
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_CM]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'CM_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'  ---k -w -t^| -T -S'
EXEC xp_cmdshell @String

--SUM
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_SUM]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'SUM_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP' -- -CACP or -COEM or -CRAW
EXEC xp_cmdshell @String

--ST
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_ST]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'ST_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

--PL
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_PL]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'PL_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

--PA
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_PA]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'PA_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

----IN (Inventory, not over this procedure but over export_file_in as it runs hourly)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_IN]" queryout d:\CST\datafiles\IN_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--RD (Product Relationship)
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_RD]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'RD_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

--ID (invoice, not used, comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_ID]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'ID_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--TPS (Top Product Supplier - not used - comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_TPS]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'TPS_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--TPR (Top Product Retailer - not used - comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_TPR]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'TPR_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--DS (Discount Schedule)
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_DS]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'DS_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

--DD (Discount Schedule Description)
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_DD]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'DD_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String



--ROSFD (Retailer Order Summyry and Forecast Data - not used - comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_ROSFD]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'ROSFD_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--SRAD (Secondary Retailer ACcount DAta - not used - comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_SRAD]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'SRAD_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--MP2RC (Product Reporting Category Mapping - not used - comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_MP2RC]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'MP2RC_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String



--CPN (Catalogue Page Numer)
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_CPN]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'CPN_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

--CSL (Color Story Loader - not used - comment out
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_CSL]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'CSL_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String

--ASR (Automated Size Run - not used - comment out)
--SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_ASR]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'ASR_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
--EXEC xp_cmdshell @String



--PT (Payment Term)
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_PT]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'PT_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String

--PD (Payment Term Description)
SET @String='bcp "SELECT * FROM ['+DB_NAME()+'].[dbo].[exp_iV_PD]" queryout '+[dbo].[GetProcPrm]('MainDataPath',1)+'PD_ODLO_'+ replace(convert(varchar(16),getdate(),112),':','') + '.txt -c -t^| -S -T -C ACP'
EXEC xp_cmdshell @String


/*
--init all table to relase space
truncate table [dbo].[INTEX_RAW_ArtEAN]
truncate table [dbo].[INTEX_RAW_ArtFarben]
truncate table [dbo].[INTEX_RAW_ArtStamm]
truncate table [dbo].[INTEX_RAW_AufGroesse]
truncate table [dbo].[INTEX_RAW_AufKopf]
truncate table [dbo].[INTEX_RAW_AufPosi]
truncate table [dbo].[INTEX_RAW_GGaGr]
truncate table [dbo].[INTEX_RAW_TpSteu]
truncate table [dbo].[iV_ACK_amount]
truncate table [dbo].[iV_ACK_header]
truncate table [dbo].[iV_ACK_pos]
truncate table [dbo].[iV_ASN_delivery]
truncate table [dbo].[iV_ASN_header]
truncate table [dbo].[iV_ASN_pos]
truncate table [dbo].[iV_ASR]
truncate table [dbo].[iV_CM]
truncate table [dbo].[iV_CPN]
truncate table [dbo].[iV_CSL]
truncate table [dbo].[iV_D_list_Item_Color]
truncate table [dbo].[iV_D_list_KuRabatt]
truncate table [dbo].[iV_D_list_KuRabatt_DS-tag]
truncate table [dbo].[iV_D_list_KuRabatt_DS-tag_temp]
truncate table [dbo].[iV_DD]
truncate table [dbo].[iV_DD_Discount_Detail]
truncate table [dbo].[iV_DS]
truncate table [dbo].[iV_DS_Discount_Header]
truncate table [dbo].[iV_DS_Discount_Header_FINAL]
truncate table [dbo].[iV_ID]
truncate table [dbo].[iV_PA]
truncate table [dbo].[iV_PD]
truncate table [dbo].[iV_PL]
truncate table [dbo].[iV_PT]
truncate table [dbo].[iV_RD]
truncate table [dbo].[iV_ROSFD]
truncate table [dbo].[iV_SRAD]
--truncate table [dbo].[iV_ST]
truncate table [dbo].[iV_SUM]
*/



END

END
