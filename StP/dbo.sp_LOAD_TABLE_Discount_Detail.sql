SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Claudio Stoeckli
-- Create date: 29.8.2016
-- Description:	Change for Discount Schedule Merge
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_Discount_Detail]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE @cust_counter int;
DECLARE @max_counter int;

DECLARE @cust_no varchar(36);
DECLARE @disc_sched varchar(50);

DECLARE @disc_sched_id int;


--- CLEAR TABLE
---DROP TABLE #customer_loop 
TRUNCATE TABLE [iV_DD_Discount_Detail];
TRUNCATE TABLE [iV_DS_Discount_Header];
TRUNCATE TABLE [iV_DS_Discount_Header_FINAL];



--- TEMP-TABLE FOR CUSTOMER LOOP
CREATE TABLE #customer_loop (
CustID int IDENTITY(1,1) NOT NULL,
CAccountNum varchar(36))

--- TEMP-TABLE FOR DISCOUNT-SCHEDULE IDs
CREATE TABLE #discsched_ids (
DiscSchedID int IDENTITY(1,1) NOT NULL,
DiscountSchedule varchar(50))

--- TEMP-TABLE FOR CUSTOMER LOOP
CREATE TABLE #customer_disc (
CAccountNum varchar(36) NOT NULL,
DiscountSchedule varchar(50),
DiscSchedID int
)


CREATE TABLE #disc_sched (
discsched varchar(10))


--- FILL CUSTOMERS INTO LOOP TABLE
INSERT INTO #customer_loop (CAccountNum)
SELECT	DISTINCT CAccountNum
FROM	[iV_DS];


--- FILL CUSTOMERS INTO LOOP TABLE
INSERT INTO #discsched_ids (DiscountSchedule)
SELECT	DISTINCT DiscountSchedule
FROM	[exp_iV_DiscountSchedule_Test];


--- Fill Discount Schedules with newly created SequenceIDs
INSERT INTO #customer_disc (CAccountNum,DiscountSchedule,DiscSchedID)
SELECT	a.CAccountNum,a.DiscountSchedule,b.DiscSchedID
FROM	exp_iV_DiscountSchedule_Test a LEFT OUTER JOIN #discsched_ids b ON (a.DiscountSchedule=b.DiscountSchedule);



--- PREPARE LOOP
SET @cust_counter=1;

SET @max_counter=(SELECT count(*) FROM #customer_loop)--- DISABLED FOR TESTING ONLY
---SET @max_counter=20; --- FOR TESTING ONLY


--- RUN LOOP
WHILE @cust_counter<=@max_counter

BEGIN --- BEGIN LOOP


--- CLEAR UNUSED TABLES

TRUNCATE TABLE [iV_DS_Discount_Header];
TRUNCATE TABLE #disc_sched;

SET @cust_no=(SELECT DISTINCT CAccountNum FROM #customer_loop WHERE CustID=@cust_counter);---DISABLED FOR TESTING
---SET @cust_no='107022' ---TESTING



--- INSERT FIRST TEST USER DISCOUNT HEADER
INSERT INTO [dbo].[iV_DS_Discount_Header]
           ([CAccountNum]
           ,[DiscountSchedule]
           ,[LOAD_DATE])
SELECT	CAccountNum,DiscSchedID,GetDate() as LOAD_DATE
FROm	#customer_disc
WHERE	CAccountNum=@cust_no---DISABLED FOR TESTING
--WHERE CAccountNum='15253'--- TESTING



SET @disc_sched=(SELECT DISTINCT DiscountSchedule FROM [iV_DS_Discount_Header]);


INSERT INTO #disc_sched
SELECT	DISTINCT DiscountSchedule
FROM	iV_DS
WHERE	CAccountNum=@cust_no ---DISABLED FOR TESTING
---WHERE CAccountNum='107022' ---TESTING


IF NOT EXISTS (SELECT * FROM [iV_DD_Discount_Detail] WHERE DiscountSchedule=@disc_sched)
	BEGIN 
		INSERT INTO [iV_DD_Discount_Detail] (DiscountSchedule,Discount,Identifier,UPC,SKU,SupplierProductKey,EAN,SupplierCatalogKey,LOAD_DATE)
		SELECT	@disc_sched,Discount,Identifier,UPC,SKU,SupplierProductKey,EAN,SupplierCatalogKey,GetDate()
		FROM	[iV_DD]
		WHERE	DiscountSchedule IN (SELECT discsched FROM #disc_sched);
		--WHERE DiscountSchedule IN ('B6220.00','B7120.00')
	END;



--- INSERT [iV_DS_Discount_Header_FINAL]
INSERT INTO iV_DS_Discount_Header_FINAL (CAccountNum,DiscountSchedule,LOAD_DATE)
SELECT CAccountNum,DiscountSchedule,GetDate() FROM [iV_DS_Discount_Header];



--- CLEAR UNUSED TABLES
--TRUNCATE TABLE [iV_DD_Discount_Detail];
TRUNCATE TABLE [iV_DS_Discount_Header];
TRUNCATE TABLE #disc_sched;



--- INCREMENT COUNTER
SET @cust_counter=@cust_counter+1;

PRINT 'Run'+CAST(@cust_counter as varchar)


END --- END LOOP


--START MPFYL 08/11/16
-- DELETE discounts within one discount schedule where there are different discounts across two seasons (possible in Intex but not possible in iVenidx
--delete header discount sets where discount is different across the season
DELETE 
	FROM [dbo].[iV_DS_Discount_Header_FINAL]
	WHERE EXISTS (
		SELECT [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[LOAD_DATE], [discount1], [discount2]
			FROM (
				SELECT [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[LOAD_DATE], min(discount) as [discount1], max(discount) as [discount2]
					FROM [dbo].[iV_DD_Discount_Detail]
					group by [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[LOAD_DATE]
					HAVING (COUNT(*) > 1)
				) tmp
			where	[dbo].[iV_DS_Discount_Header_FINAL].DiscountSchedule = tmp.DiscountSchedule AND
					tmp.[discount1] <> tmp.[discount2] )

--delete detail discount sets where discount is different across the season
DELETE 
	FROM [dbo].[iV_DD_Discount_Detail]
	WHERE EXISTS (
		SELECT [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[LOAD_DATE], [discount1], [discount2]
			FROM (
				SELECT [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[LOAD_DATE], min(discount) as [discount1], max(discount) as [discount2]
					FROM [dbo].[iV_DD_Discount_Detail]
					group by [DiscountSchedule],[Identifier],[UPC],[SKU],[SupplierProductKey],[EAN],[LOAD_DATE]
					HAVING (COUNT(*) > 1)
				) tmp
			where	[dbo].[iV_DD_Discount_Detail].DiscountSchedule = tmp.DiscountSchedule AND
					tmp.[discount1] <> tmp.[discount2] )

--END MPFYL 08/11/16


--- CLEAN UP TABLES
DROP TABLE #customer_loop
DROP TABLE #disc_sched
DROP TABLE #discsched_ids
DROP TABLE #customer_disc

TRUNCATE TABLE [iV_DS_Discount_Header];


END
GO
