SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- Change Hist: 03.09.2017 Jimmy Rüedi
--              BEGIN / COMMIT TRANSACTION removed 
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_DS_DD_NOS_N]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    


--BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag_temp]
TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag]
TRUNCATE TABLE [dbo].[iV_D_list_Item_Color]

--COMMIT TRANSACTION


/**************************************************************************************************************/
/********************************* not NOS discounts **********************************************************/
/**************************************************************************************************************/
--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_D_list_Item_Color] /****************** get all season-article combinations in separate list *******/
           ([Saison]
           ,[ItemNumber]
           ,[ColorCode]
		   ,[hlp_DiscountProdLine]
		   ,[hlp_DiscountDivision]
		   ,[hlp_DiscountNOS])
SELECT distinct [SupplierCatalogKey]
      ,[ItemNumber]
     ,'1' --[ColorCode]
      ,[hlp_DiscountProdLine]
		   ,[hlp_DiscountDivision]
		   ,'00' --CASE WHEN [hlp_DiscountNOS] = '05' THEN 'J' ELSE 'N' END --'00' --
  FROM [dbo].[iV_ST]

--COMMIT TRANSACTION

--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_D_list_KuRabatt_DS-tag]
           ([DS-tag]
           ,[Saison]
           ,[KusNr]
           ,[ItemNumber]
           ,[ColorCode]
           ,[Rabatt]
		   ,[NOS])
    SELECT 'DS-'+CONVERT([VARCHAR](8), [tag])
		,k.Saison
		,[KusNr]
		,[ItemNumber]
           ,[ColorCode]
	  ,[Rabatt] 
	  ,[hlp_DiscountNOS] --'-' -- --HASHBYTES ('SHA1', k.Saison + [ItemNumber] + [ColorCode] + CONVERT([VARCHAR](25), [Rabatt]))
  FROM [dbo].[iV_D_list_KuRabatt] k,
 [dbo].[iV_D_list_Item_Color] s
  WHERE tag = '2'
  AND [NOSJN_customer] = 'N'
  AND k.Saison = s.Saison
  --AND KusNr IN (102100,107127)
  --AND k.Saison = '011171H'


--COMMIT TRANSACTION





/**************************************** load all other discount schedules (division, subgroup, NOS, articles)  ******************/
 /*************************************** append and update all discounts (DS-3 - DS-7) to DS-2  ****************/


/*****************************************************************/
/***************************** DS-3 *******************************/
/*****************************************************************/
--BEGIN TRANSACTION 

TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag_temp]

--COMMIT TRANSACTION

--BEGIN TRANSACTION 

INSERT INTO [dbo].[iV_D_list_KuRabatt_DS-tag_temp]
           ([DS-tag]
           ,[Saison]
           ,[KusNr]
           ,[ItemNumber]
           ,[ColorCode]
           ,[Rabatt]
		   ,[NOS])
    SELECT CONVERT([VARCHAR](8), [tag]) --'DS-'+CONVERT([VARCHAR](8), [tag])
		,k.Saison
		,[KusNr]
		,[ItemNumber]
           ,[ColorCode]
	  ,[Rabatt] 
	  ,[hlp_DiscountNOS] --HASHBYTES ('SHA1', k.Saison + [ItemNumber] + [ColorCode] + CONVERT([VARCHAR](25), [Rabatt]))     
  FROM [dbo].[iV_D_list_KuRabatt] k,
 [dbo].[iV_D_list_Item_Color] s
  WHERE tag = '3'
  AND k.Saison = s.Saison  
  AND [NOSJN_customer] = 'N'
  AND Division = [hlp_DiscountDivision]
  --AND KusNr = 18550

--COMMIT TRANSACTION


--START MPFYL 05/11/16: TEST. Seems some customer discounts are captured twice. Thsi should remove duplicates.
/*
--BEGIN TRANSACTION 

	DELETE
	FROM [dbo].[iV_D_list_KuRabatt_DS-tag_temp] 
	WHERE  EXISTS (
			SELECT  [DS-tag],
					[Saison],
					[KusNr],
					[ItemNumber],
					[ColorCode]
					[Rabatt]
			FROM (
				SELECT  [DS-tag],
						[Saison],
						[KusNr],
						[ItemNumber],
						[ColorCode],
						 min(rabatt) AS rabatt 
				FROM [dbo].[iV_D_list_KuRabatt_DS-tag_temp] 
				GROUP BY	[DS-tag],saison, kusnr, itemnumber, colorcode
				HAVING      (COUNT(*) > 1)
				) temt
			WHERE	[dbo].[iV_D_list_KuRabatt_DS-tag_temp] .[DS-tag] = temt.[DS-tag]
				AND	[dbo].[iV_D_list_KuRabatt_DS-tag_temp] .[Saison] = temt.Saison
				AND [dbo].[iV_D_list_KuRabatt_DS-tag_temp] .[KusNr] = temt.KusNr
				AND [dbo].[iV_D_list_KuRabatt_DS-tag_temp] .[ItemNumber] = temt.ItemNumber
				AND [dbo].[iV_D_list_KuRabatt_DS-tag_temp] .[ColorCode] = temt.ColorCode
				AND [dbo].[iV_D_list_KuRabatt_DS-tag_temp] .[Rabatt] = temt.Rabatt
			)

--COMMIT TRANSACTION
--END MPFYL 05/11/16
*/




--BEGIN TRANSACTION 

MERGE [dbo].[iV_D_list_KuRabatt_DS-tag] AS T
USING [dbo].[iV_D_list_KuRabatt_DS-tag_temp] AS S
 ON (T.[Saison] = S.[Saison]
 AND T.[KusNr] = S.[KusNr]
 AND T.[ItemNumber] = S.[ItemNumber]
 AND T.[ColorCode] = S.[ColorCode] 
 )
WHEN MATCHED
 THEN
  UPDATE
  SET T.[Rabatt] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN S.[Rabatt] ELSE T.[Rabatt] END
  ,T.[DS-tag] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN T.[DS-tag]+'-'+S.[DS-tag] ELSE T.[DS-tag] END
WHEN NOT MATCHED BY TARGET
 THEN
  INSERT (
   [DS-tag]
   ,[Saison]
   ,[KusNr]
   ,[ItemNumber]
   ,[ColorCode]
   ,[Rabatt]
   ,[NOS]
   )
  VALUES (
   'DS-'+S.[DS-tag]
   ,S.[Saison]
   ,S.[KusNr]
   ,S.[ItemNumber]
   ,S.[ColorCode]
   ,S.[Rabatt]
   ,S.[NOS]
   );

--COMMIT TRANSACTION
--BEGIN TRANSACTION

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-3'
FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
WHERE EXISTS (
		SELECT [Saison]
			,[KusNr]
		FROM (
			SELECT distinct [Saison]
				,[KusNr]
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[DS-tag] IN ('DS-2-3')
			) temt
		WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[Saison] = temt.Saison
			AND [dbo].[iV_D_list_KuRabatt_DS-tag].[KusNr] = temt.KusNr
		)

--COMMIT TRANSACTION





/*****************************************************************/
/***************************** DS-4 *******************************/
/*****************************************************************/
--BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag_temp]

--COMMIT TRANSACTION
--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_D_list_KuRabatt_DS-tag_temp]
           ([DS-tag]
           ,[Saison]
           ,[KusNr]
           ,[ItemNumber]
           ,[ColorCode]
           ,[Rabatt]
		   ,[NOS])
    SELECT CONVERT([VARCHAR](8), [tag]) --'DS-'+CONVERT([VARCHAR](8), [tag])
		,k.Saison
		,[KusNr]
		,[ItemNumber]
           ,[ColorCode]
	  ,[Rabatt] 
	  ,[hlp_DiscountNOS] --HASHBYTES ('SHA1', k.Saison + [ItemNumber] + [ColorCode] + CONVERT([VARCHAR](25), [Rabatt]))     
  FROM [dbo].[iV_D_list_KuRabatt] k,
 [dbo].[iV_D_list_Item_Color] s
  WHERE tag = '4'
  AND k.Saison = s.Saison 
  AND [NOSJN_customer] = 'N'
  AND [ProdLine] = [hlp_DiscountProdLine]
  --AND KusNr = 18550

--COMMIT TRANSACTION
--BEGIN TRANSACTION  

MERGE [dbo].[iV_D_list_KuRabatt_DS-tag] AS T
USING [dbo].[iV_D_list_KuRabatt_DS-tag_temp] AS S
 ON (T.[Saison] = S.[Saison]
 AND T.[KusNr] = S.[KusNr]
 AND T.[ItemNumber] = S.[ItemNumber]
 AND T.[ColorCode] = S.[ColorCode]
 )
WHEN MATCHED
 THEN
  UPDATE
  SET T.[Rabatt] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN S.[Rabatt] ELSE T.[Rabatt] END
  ,T.[DS-tag] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN T.[DS-tag]+'-'+S.[DS-tag] ELSE T.[DS-tag] END
WHEN NOT MATCHED BY TARGET
 THEN
  INSERT (
   [DS-tag]
   ,[Saison]
   ,[KusNr]
   ,[ItemNumber]
   ,[ColorCode]
   ,[Rabatt]
   ,[NOS]
   )
  VALUES (
   'DS-'+S.[DS-tag]
   ,S.[Saison]
   ,S.[KusNr]
   ,S.[ItemNumber]
   ,S.[ColorCode]
   ,S.[Rabatt]
   ,S.[NOS]
   );

--COMMIT TRANSACTION
--BEGIN TRANSACTION 

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-4'
FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
WHERE EXISTS (
		SELECT [Saison]
			,[KusNr]
		FROM (
			SELECT distinct [Saison]
				,[KusNr]
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[DS-tag] IN ('DS-2-4', 'DS-3-4')
			) temt
		WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[Saison] = temt.Saison
			AND [dbo].[iV_D_list_KuRabatt_DS-tag].[KusNr] = temt.KusNr
		)

--COMMIT TRANSACTION
--BEGIN TRANSACTION

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-4'
WHERE [DS-tag] = 'DS-3'

--COMMIT TRANSACTION



/*****************************************************************/
/***************************** DS-5 *******************************/
/*****************************************************************/
--BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag_temp]

--COMMIT TRANSACTION
--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_D_list_KuRabatt_DS-tag_temp]
           ([DS-tag]
           ,[Saison]
           ,[KusNr]
           ,[ItemNumber]
           ,[ColorCode]
           ,[Rabatt]
		   ,[NOS])
    SELECT CONVERT([VARCHAR](8), [tag]) --'DS-'+CONVERT([VARCHAR](8), [tag])
		,k.Saison
		,[KusNr]
		,[ItemNumber]
           ,[ColorCode]
	  ,[Rabatt] 
	  ,[hlp_DiscountNOS] --HASHBYTES ('SHA1', k.Saison + [ItemNumber] + [ColorCode] + CONVERT([VARCHAR](25), [Rabatt]))     
  FROM [dbo].[iV_D_list_KuRabatt] k,
 [dbo].[iV_D_list_Item_Color] s
  WHERE tag = '5'
  AND k.Saison = s.Saison 
  AND [NOSJN_customer] = 'N'
  AND Division = [hlp_DiscountDivision]
    AND [ProdLine] = [hlp_DiscountProdLine]
	--AND KusNr = 18550

--COMMIT TRANSACTION
--BEGIN TRANSACTION  

MERGE [dbo].[iV_D_list_KuRabatt_DS-tag] AS T
USING [dbo].[iV_D_list_KuRabatt_DS-tag_temp] AS S
 ON (T.[Saison] = S.[Saison]
 AND T.[KusNr] = S.[KusNr]
 AND T.[ItemNumber] = S.[ItemNumber]
 AND T.[ColorCode] = S.[ColorCode]
 )
WHEN MATCHED
 THEN
  UPDATE
  SET T.[Rabatt] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN S.[Rabatt] ELSE T.[Rabatt] END
  ,T.[DS-tag] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN T.[DS-tag]+'-'+S.[DS-tag] ELSE T.[DS-tag] END
WHEN NOT MATCHED BY TARGET
 THEN
  INSERT (
   [DS-tag]
   ,[Saison]
   ,[KusNr]
   ,[ItemNumber]
   ,[ColorCode]
   ,[Rabatt]
   ,[NOS]
   )
  VALUES (
   'DS-'+S.[DS-tag]
   ,S.[Saison]
   ,S.[KusNr]
   ,S.[ItemNumber]
   ,S.[ColorCode]
   ,S.[Rabatt]
   ,S.[NOS]
   );

--COMMIT TRANSACTION
--BEGIN TRANSACTION 

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-5'
FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
WHERE EXISTS (                                          --[dbo].[iV_D_list_KuRabatt_DS-tag].[DS-tag] IN ('DS-2','DS-3','DS-4', 'DS-2-5', 'DS-3-5', 'DS-3-5'
		SELECT [Saison]
			,[KusNr]
		FROM (
			SELECT distinct [Saison]
				,[KusNr]
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[DS-tag] IN ('DS-2-5', 'DS-3-5', 'DS-4-5')
			) temt
		WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[Saison] = temt.Saison
			AND [dbo].[iV_D_list_KuRabatt_DS-tag].[KusNr] = temt.KusNr
		)

--COMMIT TRANSACTION
--BEGIN TRANSACTION

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-5'
WHERE [DS-tag] = 'DS-4'

--COMMIT TRANSACTION




/*****************************************************************/
/***************************** DS-6 *******************************/
/*****************************************************************/
--BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_D_list_KuRabatt_DS-tag_temp]

--COMMIT TRANSACTION
--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_D_list_KuRabatt_DS-tag_temp]
           ([DS-tag]
           ,[Saison]
           ,[KusNr]
           ,[ItemNumber]
           ,[ColorCode]
           ,[Rabatt]
		   ,[NOS])
    SELECT CONVERT([VARCHAR](8), [tag]) --'DS-'+CONVERT([VARCHAR](8), [tag])
		,k.Saison
		,[KusNr]
		,[ItemNumber]
           ,[ColorCode]
	  ,[Rabatt] 
	  ,[hlp_DiscountNOS] --HASHBYTES ('SHA1', k.Saison + [ItemNumber] + [ColorCode] + CONVERT([VARCHAR](25), [Rabatt]))     
  FROM [dbo].[iV_D_list_KuRabatt] k,
 [dbo].[iV_D_list_Item_Color] s
  WHERE tag = '6'
  AND k.Saison = s.Saison 
  AND [NOSJN_customer] = 'N'
  AND [ArtsNr1] = [ItemNumber]

--COMMIT TRANSACTION
--BEGIN TRANSACTION  

MERGE [dbo].[iV_D_list_KuRabatt_DS-tag] AS T
USING [dbo].[iV_D_list_KuRabatt_DS-tag_temp] AS S
 ON (T.[Saison] = S.[Saison]
 AND T.[KusNr] = S.[KusNr]
 AND T.[ItemNumber] = S.[ItemNumber]
 AND T.[ColorCode] = S.[ColorCode]
 )
WHEN MATCHED
 THEN
  UPDATE
  SET T.[Rabatt] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN S.[Rabatt] ELSE T.[Rabatt] END
  ,T.[DS-tag] = CASE WHEN T.[Rabatt] < S.[Rabatt] THEN T.[DS-tag]+'-'+S.[DS-tag] ELSE T.[DS-tag] END
WHEN NOT MATCHED BY TARGET
 THEN
  INSERT (
   [DS-tag]
   ,[Saison]
   ,[KusNr]
   ,[ItemNumber]
   ,[ColorCode]
   ,[Rabatt]
   ,[NOS]
   )
  VALUES (
   'DS-'+S.[DS-tag]
   ,S.[Saison]
   ,S.[KusNr]
   ,S.[ItemNumber]
   ,S.[ColorCode]
   ,S.[Rabatt]
   ,S.[NOS]
   );

--COMMIT TRANSACTION
--BEGIN TRANSACTION 

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-6'
FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
WHERE EXISTS (
		SELECT [Saison]
			,[KusNr]
		FROM (
			SELECT distinct [Saison]
				,[KusNr]
			FROM [dbo].[iV_D_list_KuRabatt_DS-tag]
			WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[DS-tag] IN ('DS-2-6', 'DS-3-6', 'DS-4-6', 'DS-5-6')
			) temt
		WHERE [dbo].[iV_D_list_KuRabatt_DS-tag].[Saison] = temt.Saison
			AND [dbo].[iV_D_list_KuRabatt_DS-tag].[KusNr] = temt.KusNr
		)

--COMMIT TRANSACTION
--BEGIN TRANSACTION

UPDATE [dbo].[iV_D_list_KuRabatt_DS-tag]
SET [DS-tag] = 'DS-6'
WHERE [DS-tag] = 'DS-5'

--COMMIT TRANSACTION

END
GO
