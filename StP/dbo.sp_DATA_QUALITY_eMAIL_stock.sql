SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************************************************************/
-- Change Hist: 03.09.2017 Jimmy Rüedi
--              Parametrization implemented 
/**********************************************************************************************************************/

ALTER PROCEDURE [dbo].[sp_DATA_QUALITY_eMAIL_stock]
AS
BEGIN
	SET NOCOUNT ON;

	---------------------------------------
	--- CHECK eMAIL ArtStamm INTEX ---
	---------------------------------------
	DECLARE @mxml NVARCHAR(MAX)
	DECLARE @mbody NVARCHAR(MAX)


	SET @mxml = CAST((
				SELECT INFO AS 'td'
					,''
					,[SupplierCatalogKey] AS 'td'
					,''
					,[Inventory] AS 'td'
					,''
					,[Available_dt] AS 'td'
					,''
					,counted_EAN AS 'td'
				FROM (
					SELECT 'PREO: QTY>0 and LieferbarAb<Today' AS INFO
						,[SupplierCatalogKey]
						,sum([Inventory]) AS [Inventory]
						,SUBSTRING([Available_dt], 4, 2) + '-' + SUBSTRING([Available_dt], 1, 2) + '-' + RIGHT([Available_dt], 4) AS [Available_dt]
						,count(DISTINCT [EAN]) counted_EAN
					FROM [dbo].[iV_IN]
					---WHERE [SupplierCatalogKey] IN ('011162H','011171H','011162L','011171L')
					--- added 04.08.2016/cls to avoid hardcoded seasons
					WHERE [SupplierCatalogKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType<>'REAS' UNION ALL SELECT DISTINCT REPLACE(SeasonKey,'H','L') COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType<>'REAS')
						AND Inventory <> 0
						AND RIGHT([Available_dt], 4) + SUBSTRING([Available_dt], 1, 2) + SUBSTRING([Available_dt], 4, 2) < CONVERT(VARCHAR(8), getDate(), 112) --'20170115' 
					GROUP BY [SupplierCatalogKey]
						,[Available_dt]
					
					UNION ALL
					
					SELECT 'REAS: QTY>0 and LieferbarAb>Today' AS INFO
						,[SupplierCatalogKey]
						,sum([Inventory]) AS [Inventory]
						,SUBSTRING([Available_dt], 4, 2) + '-' + SUBSTRING([Available_dt], 1, 2) + '-' + RIGHT([Available_dt], 4) AS [Available_dt]
						,count(DISTINCT [EAN]) counted_EAN
					FROM [dbo].[iV_IN]
					---WHERE [SupplierCatalogKey] IN ('011161H','011161L')
					--- added 04.08.2016/cls to avoid hardcoded seasons
					WHERE [SupplierCatalogKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS' UNION ALL SELECT DISTINCT REPLACE(SeasonKey,'H','L') COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
						AND Inventory <> 0
						AND RIGHT([Available_dt], 4) + SUBSTRING([Available_dt], 1, 2) + SUBSTRING([Available_dt], 4, 2) > CONVERT(VARCHAR(8), getDate(), 112) --'20170115' 
					GROUP BY [SupplierCatalogKey]
						,[Available_dt]
					) AS TEMP
				ORDER BY [SupplierCatalogKey]
					,[Available_dt]
				FOR XML PATH('tr')
					,ELEMENTS
				) AS NVARCHAR(MAX))
	SET @mbody = '<html><body><H2>please verify LieferbarAb @ ArtFarben</H2>' + ISNULL(dbo.[GetProcPrm]('mailCSSStd',default),'') + '
				<table border = 1> 
				<tr>
				<th> INFO </th> <th> Season </th> <th> QTY </th> <th> LieferbarAb </th> <th> counted_EANs </th></tr>'
	SET @mbody = @mbody + @mxml + '</table></body></html>'
	
	DECLARE @iVendixAdmin varchar(200), @from varchar(200), @replyTo varchar(200)
	SELECT @iVendixAdmin = ISNULL(dbo.[GetProcPrm]('iVendixAdminMailTo',default),'iVendixAdmin@odlo.com')
	SELECT @from = ISNULL(dbo.[GetProcPrm]('stdFromAddress',default),'sql@odlo.com')
	SELECT @replyTo = ISNULL(dbo.[GetProcPrm]('stdReplyTo',default),'jimmy.rueedi@odlo.com')

	EXEC msdb.dbo.sp_send_dbmail @recipients = @ivendixAdmin 
		,@from_address = @from
		,@reply_to = @replyTo 		
		---,@importance='High'
		,@body = @mbody
		,@subject = 'iVENDIX: check INTEX Artikel-Stamm'
		,@body_format = 'HTML';


END
GO
