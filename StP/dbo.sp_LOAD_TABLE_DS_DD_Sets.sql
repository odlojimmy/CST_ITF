SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_DS_DD_Sets]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




	DECLARE @MyCursorInner CURSOR;
	DECLARE @kusnr varchar(50);
	DECLARE @kusnr_Inner varchar(50);
	DECLARE @UniqueCounter int;




	--INIT DS_Set KundenRabatt table (DS_Set indicates unique global discount set
	UPDATE [dbo].[iV_D_list_KuRabatt] set ds_set = ''

	--Unique Global Discount Set Number
	Set @UniqueCounter = 0
	


	--WHILE (select count(*) from [dbo].[iV_D_list_KuRabatt] WHERE NOSJN_Customer = 'J' and DS_Set = '') > 0 
	WHILE (select count(*) from [dbo].[iV_D_list_KuRabatt] WHERE  DS_Set = '') > 0 

    BEGIN
		--SELECT Top 1 @kusnr = KusNr from [dbo].[iV_D_list_KuRabatt] WHERE NOSJN_Customer = 'J' and DS_Set = ''
		SELECT Top 1 @kusnr = KusNr from [dbo].[iV_D_list_KuRabatt] WHERE DS_Set = ''
		Set @uniqueCounter = @uniqueCounter +1

		--do - loop though all discount schedules that start with F (NOS) and identify the same Discount Details
		print 'Outer: ' + @kusnr + ' ' + CONVERT(VARCHAR(8), getdate(), 113)
		--Insert into #customerChecked VALUES (@kusnr)
		--TRUNCATE TABLE  #customerCheckedInner
		--insert into #customerCheckedInner  select KusNr from #customerChecked

		--Set unique counter
		update [dbo].[iV_D_list_KuRabatt] set ds_set = @UniqueCounter where KusNr = @kusnr
		PRINT '--Outer: -------------------------------------------------------------------------------'
		PRINT '--Outer: Update KusNr ' + @kusnr + ' with ' + convert(varchar(10),  @UniqueCounter)

		--loop though all details
		SET @MyCursorInner = CURSOR FOR
		--select distinct KusNr from [dbo].[iV_D_list_KuRabatt] where NOSJN_Customer = 'J' AND DS_Set = '' order by 1
		select distinct KusNr from [dbo].[iV_D_list_KuRabatt] where DS_Set = '' order by 1
		OPEN @MyCursorInner 
		FETCH NEXT FROM @MyCursorInner 
		INTO @kusnr_Inner
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- to discount schedules to compare with 
			--print '--- Inner: ' + @kusnr_Inner + ' ' + CONVERT(VARCHAR(8), getdate(), 14)

			IF NOT EXISTS(
				SELECT Tag, Saison, ProdLine, Division, NOSJN, ArtsNr1, Rabatt, NOSJN_customer from [dbo].[iV_D_list_KuRabatt] where KusNr = @kusnr
				EXCEPT
				SELECT Tag, Saison, ProdLine, Division, NOSJN, ArtsNr1, Rabatt, NOSJN_customer from [dbo].[iV_D_list_KuRabatt] where KusNr = @kusnr_Inner)
				--THEN DO
				BEGIN					
					--begin transaction
					--update [dbo].[iV_D_list_KuRabatt] set ds_set = @UniqueCounter where KusNr = @kusnr
					update [dbo].[iV_D_list_KuRabatt] set ds_set = @UniqueCounter where KusNr = @kusnr_Inner
					PRINT '--- Inner: ' + @kusnr_Inner + ' MATCH' + ' and update with ' + convert(varchar(10),  @UniqueCounter) + ' ' + CONVERT(VARCHAR(8), getdate(), 14)
					--commit transaction
				END
			ELSE
				BEGIN
					PRINT '--- Inner: ' + @kusnr_Inner + ' no match' + ' ' + CONVERT(VARCHAR(8), getdate(), 14)
				END
	

			
			--get next record
			FETCH NEXT FROM @MyCursorInner 
			INTO @kusnr_Inner 
		END; 
		CLOSE @MyCursorInner ;
		DEALLOCATE @MyCursorInner;
   

		--get next record
		--FETCH NEXT FROM @MyCursor 
		--INTO @kusnr 
		
    END; 

    --CLOSE @MyCursor ;
    --DEALLOCATE @MyCursor;
END;
GO
