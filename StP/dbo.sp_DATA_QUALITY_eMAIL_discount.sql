SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_DATA_QUALITY_eMAIL_discount]
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
					,[Saison] AS 'td'
					,''
					,[KusNr] AS 'td'
					,''
					,[combination] AS 'td'
					,''
					,[Rabatt] AS 'td'
				FROM (
					SELECT TOP 10 
'unsolved discount combination' as INFO
      ,[Saison]
      ,[KusNr]
      ,CASE WHEN [ProdLine] IS NULL THEN '' ELSE [ProdLine] END
		 +CASE WHEN [Division] IS NULL THEN '' ELSE [Division] END
		+CASE WHEN [NOSJN] IS NULL THEN '' ELSE [NOSJN] END
		+CASE WHEN [ArtsNr1] IS NULL THEN '' ELSE [ArtsNr1] END
		+CASE WHEN [NOSJN_customer] IS NULL THEN '' ELSE [NOSJN_customer] END AS [combination]
      ,[Rabatt]
  FROM [dbo].[iV_D_list_KuRabatt]
  WHERE [tag] = '4'
					
					
					
					
					
					) AS TEMP
				
				FOR XML PATH('tr')
					,ELEMENTS
				) AS NVARCHAR(MAX))
	SET @mbody = '<html><body><H2>check SQL code @ sp_LOAD_TABLE_DS_DD_main</H2>' + ISNULL(dbo.[GetProcPrm]('mailCSSStd',default),'') + '
				<table border = 1> 
				<tr>
				<th> INFO </th> <th> Season </th> <th> Cust# </th> <th> CODE </th> <th> discount </th></tr>'
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
		,@subject = 'iVENDIX: check discount customer'
		,@body_format = 'HTML';
	


END
GO
