SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_DATA_VALIDATION_DS_DD]

AS
BEGIN
	SET NOCOUNT ON;


	------------------------------------------------------
	--- BEGIN CHECK - verify for duplicate data entries
	------------------------------------------------------

	DECLARE @mxml NVARCHAR(MAX)
	DECLARE @mbody NVARCHAR(MAX)


	------------------------------------------------------
	--- Check Discount Schedule (SET) data 
	------------------------------------------------------
	IF EXISTS (
			SELECT [CAccountNum], count(*)
			  FROM [dbo].[exp_iV_DS]
			  group by [CAccountNum]
			  having (count(*) > 1)

	)

	BEGIN
		SET @mxml = CAST((	
				
						SELECT	[CAccountNum] as 'td','',
								CountNum as 'td'
						FROM (
									SELECT [CAccountNum], count(*) as CountNum
									  FROM [dbo].[exp_iV_DS]
									  group by [CAccountNum]
									  having (count(*) > 1)) as Temp

		FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

		SET @mbody =	'<html><body><H2>iVendix - Duplicate DS Data</H2>
						<table border = 1> 
						<tr><th>CustomerNumber</th><th>Count</th> </tr>'    
 
		SET @mbody = @mbody + @mxml +'</table></body></html>'

		EXEC msdb.dbo.sp_send_dbmail 
			@recipients='markus.pfyl@odlo.com',
			@from_address='sql@odlo.com',
			@subject='iVendix - Duplicate DS records',
			@reply_to='markus.pfyl@odlo.com',
			---@importance='High',
			@body=@mbody,
			@body_format='HTML';


	END


	------------------------------------------------------
	--- Check Discount Schedule (DETAIL) data 
	------------------------------------------------------
	IF EXISTS (
			SELECT [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[SupplierCatalogKey], count(*)
			  FROM [dbo].[exp_iV_DD]
			  group by [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[SupplierCatalogKey]
			  having (count(*) > 1)
	)

	BEGIN
		SET @mxml = CAST((	
				
						SELECT	[DiscountSchedule] as 'td','',
								[Identifier] as 'td','',
								[UPC] as 'td','',
								[SKU] as 'td','',
								[SupplierProductKey] as 'td','',
								[EAN] as 'td','',
								[SupplierCatalogKey] as 'td','',
								CountNum as 'td'
						FROM (
									SELECT [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[SupplierCatalogKey], count(*) as CountNum
									  FROM [dbo].[exp_iV_DD]
									  group by [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[SupplierCatalogKey]
									  having (count(*) > 1)) as Temp

		FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

		SET @mbody =	'<html><body><H2>iVendix - Duplicate DD Detail Data</H2>
						<table border = 1> 
						<tr> <th>DiscountSchedule</th> <th>Identifier</th> <th>UPC</th> <th>SKU</th> <th>SupplierProductKey</th> <th>EAN</th> <th>SupplierCatalogKey</th> <th>Count</th> </tr>'    
 
		SET @mbody = @mbody + @mxml +'</table></body></html>'

		EXEC msdb.dbo.sp_send_dbmail 
			@recipients='markus.pfyl@odlo.com',
			@from_address='sql@odlo.com',
			@subject='iVendix - Duplicate DS records',
			@reply_to='markus.pfyl@odlo.com',
			---@importance='High',
			@body=@mbody,
			@body_format='HTML';


	END

END
GO
