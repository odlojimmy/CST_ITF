SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_SRAD]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_SRAD]

	COMMIT TRANSACTION

	BEGIN TRANSACTION /****************************** LOAD ALL IN **********************************/

	
INSERT INTO [dbo].[iV_SRAD]
           ([CAccountNum]
           ,[ShipAccountNum]
           ,[StoreAccountNum]
           ,[FieldName]
           ,[FieldValue]
           ,[ActionCode]
           ,[LOAD_DATE])
	

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO (Schweiz) AG$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode = 'Odlo CH')
GROUP BY [Customer No_]

UNION ALL

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO International AG$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode IN ('Odlo OI', 'Odlo UK'))
GROUP BY [Customer No_]

UNION ALL

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO Österreich GmbH$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode = 'Odlo AT')
GROUP BY [Customer No_]

UNION ALL

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO Sportswear SA BE$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode = 'Odlo BE')
GROUP BY [Customer No_]

UNION ALL

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO Sports GmbH$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode = 'Odlo DE')
GROUP BY [Customer No_]

UNION ALL

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO France SAS$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode = 'Odlo FR')
GROUP BY [Customer No_]

UNION ALL

SELECT [Customer No_], NULL, NULL, 'CurrentBalance'
	,CAST(sum([Amount]) AS [decimal](19,2)) AS amount
	,'UP',getDate()
FROM NAVPROD.[NAVPROD].[dbo].[ODLO Sportswear SA NL$Detailed Cust_ Ledg_ Entry]
WHERE [Customer No_] IN (SELECT distinct [CAccountNum] FROM [dbo].[iV_CM] WHERE SalesRegionCode = 'Odlo NL')
GROUP BY [Customer No_]


	COMMIT TRANSACTION


	BEGIN TRANSACTION

	UPDATE [dbo].[iV_SRAD]
	SET [FieldValue] = 'success~'+[FieldValue]
	WHERE [FieldValue] <= '0.00'

	COMMIT TRANSACTION

	BEGIN TRANSACTION

	UPDATE [dbo].[iV_SRAD]
	SET [FieldValue] = 'warning~'+[FieldValue]
	WHERE [FieldValue] > '0.00'
	AND [FieldValue] NOT LIKE ('%~%')

	COMMIT TRANSACTION



END
GO
