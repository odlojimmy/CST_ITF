SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description: Load and update all interface table from INTEX.
--              here we calculate the inventory data to show the customers in iVendix the available number of 
--              items, we could offer for sale
-- Change Hist: 13.08.2017 JRU
--              Removed all Database Direct Addressing to get the Proc more transportable
--              Implemented some stuff, to reduce the load onto the INTEXSALES and SQLINTEX Linked Servers
--           -- 21.08.2017 JRU
--              Implemented the download to INTEX_RAW_*- Tables to avoid repeated access to INTEX Live db
--              and update of master data regarding the field "Wann" of each table to reduce the traffic and runtime
--              furtherwise the Ordering tables are refreshed with a merge command, so the load should generally be 
--              reduced to the SQLINTEX Linked Server
--              and at least implemented the merge onto the master data tables
-- Changed    : 31.08.2017 JRU
--              Changed the datasource from the live INTEX DB to [IFC_Cache]
--              also the INTEX_RAW_ Tables except the INTEX_RAW_ArtEAN, since there is additional data contained
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_IN]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--#region Declarations
	DECLARE @DEBUG bit = 1
	    ,   @curObject         varchar(100)
		,   @rowCount          varchar(10)

	-- Tables to do the smaller updates
	DECLARE @Start datetime = getdate() -- Datum/Zeit zum Berechnen setzen

	--#endregion Declarations
	
	TRUNCATE TABLE [dbo].[iV_IN_hlp_ean]
	TRUNCATE TABLE [dbo].[iV_IN_hlp_FeLa]
	TRUNCATE TABLE [dbo].[iV_IN_hlp_Order]
	TRUNCATE TABLE [dbo].[iV_IN_hlp_PO]
	TRUNCATE TABLE [dbo].[iV_IN]
/*
	--#region Fill the RAW Tables

	--Truncating tables, where a merge doesn't make sense
	TRUNCATE TABLE INTEX_RAW_GGaGr;
	TRUNCATE TABLE INTEX_RAW_TpSteu;
	
	-- JRU 18.08.2017 BEGIN Optimizing access to the database [SQLINTEX].[OdloDE]
	--TRUNCATE TABLE INTEX_RAW_ArtStamm;
	--TRUNCATE TABLE INTEX_RAW_ArtEAN;
	--TRUNCATE TABLE INTEX_RAW_ArtFarben;
	--TRUNCATE TABLE INTEX_RAW_ArtLieferant;
	--TRUNCATE TABLE INTEX_RAW_AufKopf;
	--TRUNCATE TABLE INTEX_RAW_AufPosi;
	--TRUNCATE TABLE INTEX_RAW_AufGroesse;


--#region TpSteu
	-- TpSteu is needed very soon:
	SET @curObject = 'TpSteu'
	INSERT INTO [dbo].[INTEX_RAW_TpSteu]
		(
			 [tanr]
			,[tpwert]
			,[tapkey]
			,[lfd]
			,[stwert]
			,[wer]
			,[wann]
		)
	SELECT
		 [tanr]
		,[tpwert]
		,[tapkey]
		,[lfd]
		,[stwert]
		,[wer]
		,[wann]
	FROM [SQLINTEX].[OdloDE].[dbo].[TpSteu] WITH(READPAST)
	WHERE (tanr=600 AND lfd=205)
		OR (tanr=41 AND lfd=14) -- Steuerung for Lager-Relevante Auftragsarten
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
--#endregion TpSteu

--#region GGaGr
	--GGaGr
	SET @curObject = 'GGaGr'
	INSERT INTO [dbo].[INTEX_RAW_GGaGr]
		(
			 [GGanKey]
			,[GGNr]
			,[Gr]
			,[SortKz]
			,[Neu]
			,[Wer]
			,[Wann]
		)
	SELECT
		 [GGanKey]
		,[GGNr]
		,[Gr]
		,[SortKz]
		,[Neu]
		,[Wer]
		,[Wann]
	FROM [SQLINTEX].[OdloDE].[dbo].[GGaGr] gg
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
--#endregion GGaGr
			PRINT 'Begin import of master data..'
--#region ArtStamm
			SET @curObject = 'ArtStamm Merge'
				MERGE [dbo].[INTEX_RAW_ArtStamm] AS TGT
				USING 
					(SELECT
							 [ArtsNr1], [ArtsNr2], [ArtsKey], [InterneBez1], [InterneBez2], [InterneBez3], [GGanKey], [GGNr], [LiefKey], [LiefNr], [TapKey_ProdLine], [ProdLine], [TapKey_ProdGroup], [ProdGroup], [TapKey_ArtGroup], [ArtGroup], [FarbKarte], [FbKKey], [TapKey_MatZus], [MatZus], [TapKey_Typ], [Typ], [Gewicht_Brutto], [Gewicht_Netto], [TapKey_Sperre], [Sperre], [TapKey_StdEtik], [StdEtik], [TapKey_Aufmach], [Aufmach], [TapKey_Lot], [Lot], [TapKey_LiefTerm], [LiefTerm], [TapKey_ZollTafNr], [ZollTafNr], [TapKey_Hangtag], [Hangtag], [TapKey_MatGrp], [MatGrp], [Pflegesymbole], [TapKey_Ursprungsland], [Ursprungsland], [MeldeBestand], [MaxBestand], [StdArt], [LiefArtNr], [TkgsKey], [TkgNr], [TapKey_ArtStatus], [ArtStatus], [VisumDesignDatum], [VisumDesignKuerzel], [VisumPrPrepDatum], [VisumPrPrepKuerzel], [TapKey_Division], [Division], [TapKey_Geschlecht], [Geschlecht], [VorgaengerArtsNr1], [VorgaengerArtsNr2], [VorgaengerArtsKey], [TapKey_FarbGang], [FarbGang], [TapKey_GrZus], [GrZus], [VisumLogistikDatum], [VisumLogistikKuerzel], [TapKey_FedasProdGr], [FedasProdGr], [TapKey_VpGruppe], [VpGruppe], [TapKey_ArtikelKlasse], [ArtikelKlasse], [TapKey_Serie], [Serie], [Volumen], [TapKey_DivNeu], [DivNeu], [TapKey_Segment], [Segment], [TapKey_Style], [Style], [TapKey_LhmTyp], [LhmTyp], [PiktoLabelTyp], [CompressivJN], [TapKey_SoArtNr], [SoArtNr], [FedasGGang], [TapKey_FedasGGang], [Zollpruefung], [TapKey_Zollpruefung], [EUQuotaKategorie], [TapKey_EUQuotaKategorie], [Neu], [Wer], [Wann], [TapKey_ProdLeadTime], [ProdLeadTime], [SetartikelJN], [ProductGroupNeu], [TapKey_ProductGroupNeu], [TCS], [TapKey_TCS], [Support], [TapKey_Support]
						FROM [SQLINTEX].[OdloDE].[dbo].[ArtStamm] ArtS WITH(READPAST)
						WHERE ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
					ON ( 
								 TGT.[ArtsNr1] = SRC.[ArtsNr1] COLLATE Latin1_General_CI_AS
							 AND TGT.[ArtsNr2] = SRC.[ArtsNr2] COLLATE Latin1_General_CI_AS
							 AND TGT.[ArtsKey] = SRC.[ArtsKey] COLLATE Latin1_General_CI_AS
						)
					WHEN MATCHED AND (TGT.Wann != SRC.Wann)
					THEN UPDATE SET 
								 TGT.[InterneBez1]             = SRC.[InterneBez1]                
								,TGT.[InterneBez2]             = SRC.[InterneBez2]                
								,TGT.[InterneBez3]             = SRC.[InterneBez3]                
								,TGT.[GGanKey]                 = SRC.[GGanKey]                    
								,TGT.[GGNr]                    = SRC.[GGNr]                       
								,TGT.[LiefKey]                 = SRC.[LiefKey]                    
								,TGT.[LiefNr]                  = SRC.[LiefNr]                     
								,TGT.[TapKey_ProdLine]         = SRC.[TapKey_ProdLine]            
								,TGT.[ProdLine]                = SRC.[ProdLine]                   
								,TGT.[TapKey_ProdGroup]        = SRC.[TapKey_ProdGroup]           
								,TGT.[ProdGroup]               = SRC.[ProdGroup]                  
								,TGT.[TapKey_ArtGroup]         = SRC.[TapKey_ArtGroup]            
								,TGT.[ArtGroup]                = SRC.[ArtGroup]                   
								,TGT.[FarbKarte]               = SRC.[FarbKarte]                  
								,TGT.[FbKKey]                  = SRC.[FbKKey]                     
								,TGT.[TapKey_MatZus]           = SRC.[TapKey_MatZus]              
								,TGT.[MatZus]                  = SRC.[MatZus]                     
								,TGT.[TapKey_Typ]              = SRC.[TapKey_Typ]                 
								,TGT.[Typ]                     = SRC.[Typ]                        
								,TGT.[Gewicht_Brutto]          = SRC.[Gewicht_Brutto]             
								,TGT.[Gewicht_Netto]           = SRC.[Gewicht_Netto]              
								,TGT.[TapKey_Sperre]           = SRC.[TapKey_Sperre]              
								,TGT.[Sperre]                  = SRC.[Sperre]                     
								,TGT.[TapKey_StdEtik]          = SRC.[TapKey_StdEtik]             
								,TGT.[StdEtik]                 = SRC.[StdEtik]                    
								,TGT.[TapKey_Aufmach]          = SRC.[TapKey_Aufmach]             
								,TGT.[Aufmach]                 = SRC.[Aufmach]                    
								,TGT.[TapKey_Lot]              = SRC.[TapKey_Lot]                 
								,TGT.[Lot]                     = SRC.[Lot]                        
								,TGT.[TapKey_LiefTerm]         = SRC.[TapKey_LiefTerm]            
								,TGT.[LiefTerm]                = SRC.[LiefTerm]                   
								,TGT.[TapKey_ZollTafNr]        = SRC.[TapKey_ZollTafNr]           
								,TGT.[ZollTafNr]               = SRC.[ZollTafNr]                  
								,TGT.[TapKey_Hangtag]          = SRC.[TapKey_Hangtag]             
								,TGT.[Hangtag]                 = SRC.[Hangtag]                    
								,TGT.[TapKey_MatGrp]           = SRC.[TapKey_MatGrp]              
								,TGT.[MatGrp]                  = SRC.[MatGrp]                     
								,TGT.[Pflegesymbole]           = SRC.[Pflegesymbole]              
								,TGT.[TapKey_Ursprungsland]    = SRC.[TapKey_Ursprungsland]       
								,TGT.[Ursprungsland]           = SRC.[Ursprungsland]              
								,TGT.[MeldeBestand]            = SRC.[MeldeBestand]               
								,TGT.[MaxBestand]              = SRC.[MaxBestand]                 
								,TGT.[StdArt]                  = SRC.[StdArt]                     
								,TGT.[LiefArtNr]               = SRC.[LiefArtNr]                  
								,TGT.[TkgsKey]                 = SRC.[TkgsKey]                    
								,TGT.[TkgNr]                   = SRC.[TkgNr]                      
								,TGT.[TapKey_ArtStatus]        = SRC.[TapKey_ArtStatus]           
								,TGT.[ArtStatus]               = SRC.[ArtStatus]                  
								,TGT.[VisumDesignDatum]        = SRC.[VisumDesignDatum]           
								,TGT.[VisumDesignKuerzel]      = SRC.[VisumDesignKuerzel]         
								,TGT.[VisumPrPrepDatum]        = SRC.[VisumPrPrepDatum]           
								,TGT.[VisumPrPrepKuerzel]      = SRC.[VisumPrPrepKuerzel]         
								,TGT.[TapKey_Division]         = SRC.[TapKey_Division]            
								,TGT.[Division]                = SRC.[Division]                   
								,TGT.[TapKey_Geschlecht]       = SRC.[TapKey_Geschlecht]          
								,TGT.[Geschlecht]              = SRC.[Geschlecht]                 
								,TGT.[VorgaengerArtsNr1]       = SRC.[VorgaengerArtsNr1]          
								,TGT.[VorgaengerArtsNr2]       = SRC.[VorgaengerArtsNr2]          
								,TGT.[VorgaengerArtsKey]       = SRC.[VorgaengerArtsKey]          
								,TGT.[TapKey_FarbGang]         = SRC.[TapKey_FarbGang]            
								,TGT.[FarbGang]                = SRC.[FarbGang]                   
								,TGT.[TapKey_GrZus]            = SRC.[TapKey_GrZus]               
								,TGT.[GrZus]                   = SRC.[GrZus]                      
								,TGT.[VisumLogistikDatum]      = SRC.[VisumLogistikDatum]         
								,TGT.[VisumLogistikKuerzel]    = SRC.[VisumLogistikKuerzel]       
								,TGT.[TapKey_FedasProdGr]      = SRC.[TapKey_FedasProdGr]         
								,TGT.[FedasProdGr]             = SRC.[FedasProdGr]                
								,TGT.[TapKey_VpGruppe]         = SRC.[TapKey_VpGruppe]            
								,TGT.[VpGruppe]                = SRC.[VpGruppe]                   
								,TGT.[TapKey_ArtikelKlasse]    = SRC.[TapKey_ArtikelKlasse]       
								,TGT.[ArtikelKlasse]           = SRC.[ArtikelKlasse]              
								,TGT.[TapKey_Serie]            = SRC.[TapKey_Serie]               
								,TGT.[Serie]                   = SRC.[Serie]                      
								,TGT.[Volumen]                 = SRC.[Volumen]                    
								,TGT.[TapKey_DivNeu]           = SRC.[TapKey_DivNeu]              
								,TGT.[DivNeu]                  = SRC.[DivNeu]                     
								,TGT.[TapKey_Segment]          = SRC.[TapKey_Segment]             
								,TGT.[Segment]                 = SRC.[Segment]                    
								,TGT.[TapKey_Style]            = SRC.[TapKey_Style]               
								,TGT.[Style]                   = SRC.[Style]                      
								,TGT.[TapKey_LhmTyp]           = SRC.[TapKey_LhmTyp]              
								,TGT.[LhmTyp]                  = SRC.[LhmTyp]                     
								,TGT.[PiktoLabelTyp]           = SRC.[PiktoLabelTyp]              
								,TGT.[CompressivJN]            = SRC.[CompressivJN]               
								,TGT.[TapKey_SoArtNr]          = SRC.[TapKey_SoArtNr]             
								,TGT.[SoArtNr]                 = SRC.[SoArtNr]                    
								,TGT.[FedasGGang]              = SRC.[FedasGGang]                 
								,TGT.[TapKey_FedasGGang]       = SRC.[TapKey_FedasGGang]          
								,TGT.[Zollpruefung]            = SRC.[Zollpruefung]               
								,TGT.[TapKey_Zollpruefung]     = SRC.[TapKey_Zollpruefung]        
								,TGT.[EUQuotaKategorie]        = SRC.[EUQuotaKategorie]           
								,TGT.[TapKey_EUQuotaKategorie] = SRC.[TapKey_EUQuotaKategorie]    
								,TGT.[Neu]                     = SRC.[Neu]                        
								,TGT.[Wer]                     = SRC.[Wer]                        
								,TGT.[Wann]                    = SRC.[Wann]                       
								,TGT.[TapKey_ProdLeadTime]     = SRC.[TapKey_ProdLeadTime]        
								,TGT.[ProdLeadTime]            = SRC.[ProdLeadTime]               
								,TGT.[SetartikelJN]            = SRC.[SetartikelJN]               
								,TGT.[ProductGroupNeu]         = SRC.[ProductGroupNeu]            
								,TGT.[TapKey_ProductGroupNeu]  = SRC.[TapKey_ProductGroupNeu]     
								,TGT.[TCS]                     = SRC.[TCS]                        
								,TGT.[TapKey_TCS]              = SRC.[TapKey_TCS]                 
								,TGT.[Support]                 = SRC.[Support]                    
								,TGT.[TapKey_Support]          = SRC.[TapKey_Support]             	
				WHEN NOT MATCHED BY TARGET THEN INSERT ( [ArtsNr1], [ArtsNr2], [ArtsKey], [InterneBez1], [InterneBez2], [InterneBez3], [GGanKey], [GGNr], [LiefKey], [LiefNr], [TapKey_ProdLine], [ProdLine], [TapKey_ProdGroup], [ProdGroup], [TapKey_ArtGroup], [ArtGroup], [FarbKarte], [FbKKey], [TapKey_MatZus], [MatZus], [TapKey_Typ], [Typ], [Gewicht_Brutto], [Gewicht_Netto], [TapKey_Sperre], [Sperre], [TapKey_StdEtik], [StdEtik], [TapKey_Aufmach], [Aufmach], [TapKey_Lot], [Lot], [TapKey_LiefTerm], [LiefTerm], [TapKey_ZollTafNr], [ZollTafNr], [TapKey_Hangtag], [Hangtag], [TapKey_MatGrp], [MatGrp], [Pflegesymbole], [TapKey_Ursprungsland], [Ursprungsland], [MeldeBestand], [MaxBestand], [StdArt], [LiefArtNr], [TkgsKey], [TkgNr], [TapKey_ArtStatus], [ArtStatus], [VisumDesignDatum], [VisumDesignKuerzel], [VisumPrPrepDatum], [VisumPrPrepKuerzel], [TapKey_Division], [Division], [TapKey_Geschlecht], [Geschlecht], [VorgaengerArtsNr1], [VorgaengerArtsNr2], [VorgaengerArtsKey], [TapKey_FarbGang], [FarbGang], [TapKey_GrZus], [GrZus], [VisumLogistikDatum], [VisumLogistikKuerzel], [TapKey_FedasProdGr], [FedasProdGr], [TapKey_VpGruppe], [VpGruppe], [TapKey_ArtikelKlasse], [ArtikelKlasse], [TapKey_Serie], [Serie], [Volumen], [TapKey_DivNeu], [DivNeu], [TapKey_Segment], [Segment], [TapKey_Style], [Style], [TapKey_LhmTyp], [LhmTyp], [PiktoLabelTyp], [CompressivJN], [TapKey_SoArtNr], [SoArtNr], [FedasGGang], [TapKey_FedasGGang], [Zollpruefung], [TapKey_Zollpruefung], [EUQuotaKategorie], [TapKey_EUQuotaKategorie], [Neu], [Wer], [Wann], [TapKey_ProdLeadTime], [ProdLeadTime], [SetartikelJN], [ProductGroupNeu], [TapKey_ProductGroupNeu], [TCS], [TapKey_TCS], [Support], [TapKey_Support] )   VALUES (  SRC.[ArtsNr1], SRC.[ArtsNr2], SRC.[ArtsKey], SRC.[InterneBez1], SRC.[InterneBez2], SRC.[InterneBez3], SRC.[GGanKey], SRC.[GGNr], SRC.[LiefKey], SRC.[LiefNr], SRC.[TapKey_ProdLine], SRC.[ProdLine], SRC.[TapKey_ProdGroup], SRC.[ProdGroup], SRC.[TapKey_ArtGroup], SRC.[ArtGroup], SRC.[FarbKarte], SRC.[FbKKey], SRC.[TapKey_MatZus], SRC.[MatZus], SRC.[TapKey_Typ], SRC.[Typ], SRC.[Gewicht_Brutto], SRC.[Gewicht_Netto], SRC.[TapKey_Sperre], SRC.[Sperre], SRC.[TapKey_StdEtik], SRC.[StdEtik], SRC.[TapKey_Aufmach], SRC.[Aufmach], SRC.[TapKey_Lot], SRC.[Lot], SRC.[TapKey_LiefTerm], SRC.[LiefTerm], SRC.[TapKey_ZollTafNr], SRC.[ZollTafNr], SRC.[TapKey_Hangtag], SRC.[Hangtag], SRC.[TapKey_MatGrp], SRC.[MatGrp], SRC.[Pflegesymbole], SRC.[TapKey_Ursprungsland], SRC.[Ursprungsland], SRC.[MeldeBestand], SRC.[MaxBestand], SRC.[StdArt], SRC.[LiefArtNr], SRC.[TkgsKey], SRC.[TkgNr], SRC.[TapKey_ArtStatus], SRC.[ArtStatus], SRC.[VisumDesignDatum], SRC.[VisumDesignKuerzel], SRC.[VisumPrPrepDatum], SRC.[VisumPrPrepKuerzel], SRC.[TapKey_Division], SRC.[Division], SRC.[TapKey_Geschlecht], SRC.[Geschlecht], SRC.[VorgaengerArtsNr1], SRC.[VorgaengerArtsNr2], SRC.[VorgaengerArtsKey], SRC.[TapKey_FarbGang], SRC.[FarbGang], SRC.[TapKey_GrZus], SRC.[GrZus], SRC.[VisumLogistikDatum], SRC.[VisumLogistikKuerzel], SRC.[TapKey_FedasProdGr], SRC.[FedasProdGr], SRC.[TapKey_VpGruppe], SRC.[VpGruppe], SRC.[TapKey_ArtikelKlasse], SRC.[ArtikelKlasse], SRC.[TapKey_Serie], SRC.[Serie], SRC.[Volumen], SRC.[TapKey_DivNeu], SRC.[DivNeu], SRC.[TapKey_Segment], SRC.[Segment], SRC.[TapKey_Style], SRC.[Style], SRC.[TapKey_LhmTyp], SRC.[LhmTyp], SRC.[PiktoLabelTyp], SRC.[CompressivJN], SRC.[TapKey_SoArtNr], SRC.[SoArtNr], SRC.[FedasGGang], SRC.[TapKey_FedasGGang], SRC.[Zollpruefung], SRC.[TapKey_Zollpruefung], SRC.[EUQuotaKategorie], SRC.[TapKey_EUQuotaKategorie], SRC.[Neu], SRC.[Wer], SRC.[Wann], SRC.[TapKey_ProdLeadTime], SRC.[ProdLeadTime], SRC.[SetartikelJN], SRC.[ProductGroupNeu], SRC.[TapKey_ProductGroupNeu], SRC.[TCS], SRC.[TapKey_TCS], SRC.[Support], SRC.[TapKey_Support] )
				WHEN NOT MATCHED BY SOURCE THEN DELETE;
			SELECT
				@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
			IF @DEBUG = 1
				BEGIN
					PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
				END
			SET @Start = getdate()
--#endregion ArtStamm
*/
--#region ArtEAN
 -- ArtEAN remains the only locally cached table since MPF has implemented additional data. let's try later to figure out how to overcome
			--ArtEAN 
			SET @curObject = 'ArtEAN Merge'
			MERGE  [dbo].[INTEX_RAW_ArtEAN] AS TGT
			USING
			(SELECT
				 ean.ArtsNr1
				,ean.ArtsNr2
				,ean.ArtsKey
				,ean.VerkFarbe
				,ean.GGanKey
				,ean.GGNr
				,ean.GR
				,ean.EANCode
				,ean.ExportiertKz
				,ean.Neu
				,ean.Wer
				,ean.Wann
				,CASE WHEN div.stwert IS NULL THEN 'UNDEFINED'
				                              ELSE div.stwert
				END CategoryGroup
			--FROM                [SQLINTEX].[OdloDE].[dbo].[ArtEAN]  ean WITH(READPAST)                                                                                
			--	,               [INTEX_RAW_ArtStamm]                 ArtS
			--	LEFT OUTER JOIN [INTEX_RAW_TpSteu]                   div 
			FROM                [IFC_Cache].[dbo].[ArtEAN]  ean WITH(READPAST)                                                                                
				,               [IFC_Cache].[dbo].[ArtStamm]                 ArtS
				LEFT OUTER JOIN [IFC_Cache].[dbo].[TpSteu]                   div 

					ON ( div.tanr = 600 -- category aka division
					AND div.lfd = 205
					AND ArtS.[TapKey_DivNeu] = div.[tapkey] COLLATE SQL_Latin1_General_CP1_CS_AS
					AND ArtS.[DivNeu] = div.tpwert COLLATE SQL_Latin1_General_CP1_CS_AS
					)
			WHERE ean.artsnr1 = arts.artsnr1 COLLATE SQL_Latin1_General_CP1_CS_AS 
			  AND ean.artsnr2 = arts.artsnr2 COLLATE SQL_Latin1_General_CP1_CS_AS 
			  AND ean.artskey = arts.artskey COLLATE SQL_Latin1_General_CP1_CS_AS
			  AND ean.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
				ON (	SRC.ArtsNr1   = TGT.ArtsNr1    COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.ArtsNr2   = TGT.ArtsNr2    COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.ArtsKey   = TGT.ArtsKey    COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.VerkFarbe = TGT.VerkFarbe  COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.GGanKey   = TGT.GGanKey    COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.GGNr      = TGT.GGNr      
					AND SRC.GR        = TGT.GR         COLLATE SQL_Latin1_General_CP1_CS_AS 
				   )
			WHEN MATCHED AND (TGT.Wann != SRC.Wann)
			THEN UPDATE SET 
					TGT.EANCode       = SRC.EANCode      
					,TGT.ExportiertKz  = SRC.ExportiertKz 
					,TGT.Neu           = SRC.Neu          
					,TGT.Wer           = SRC.Wer          
					,TGT.Wann          = SRC.Wann         
					,TGT.CategoryGroup = SRC.CategoryGroup
			WHEN NOT MATCHED BY TARGET THEN
			INSERT (ArtsNr1, ArtsNr2, ArtsKey, VerkFarbe, GGanKey, GGNr, GR, EANCode, ExportiertKz, Neu, Wer, Wann, CategoryGroup)
			VALUES (SRC.ArtsNr1, SRC.ArtsNr2, SRC.ArtsKey, SRC.VerkFarbe, SRC.GGanKey, SRC.GGNr, SRC.GR, SRC.EANCode, SRC.ExportiertKz, SRC.Neu, SRC.Wer, SRC.Wann, SRC.CategoryGroup)
			WHEN NOT MATCHED BY SOURCE THEN DELETE
			;			SELECT
				@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
			IF @DEBUG = 1
				BEGIN
					PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
				END
			SET @Start = getdate()
--#endregion ArtEAN
/*
--#region ArtFarben
			-- ArtFarben
			SET @curObject = 'ArtFarben Merge'
			MERGE  [dbo].[INTEX_RAW_ArtFarben] AS TGT
			USING
			(SELECT
				  [ArtsNr1], [ArtsNr2], [ArtsKey], [VerkFarbe], [TapKey_VerkFarbe], [VonGroesse], [BisGroesse], [TapKey_Sperre], [Sperre], [PattNr], [Version], [PattKey], [StandardJN], [TapKey_StandardJN], [UArtsKey], [EkPreisGewDM], [LieferbarAb], [VerfuegbarAb], [Neu], [Wer], [Wann], [TapKey_SMU_Kennzeichen], [SMU_Kennzeichen], [TapKey_ErsteSaisonAktiv], [ErsteSaisonAktiv], [TapKey_LetzteSaisonAktiv], [LetzteSaisonAktiv], [CoreJN], [CarryOverJN], [KeyStyleJN], [TapKey_RabattTyp], [RabattTyp], [LieferbarBis], [TapKey_SeasonType], [SeasonType], [PreSeasonJN]
				FROM [SQLINTEX].[OdloDE].[dbo].[ArtFarben] af WITH(READPAST)
				WHERE af.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
					ON (SRC.[ArtsNr1]   = TGT.[ArtsNr1]   COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.[ArtsNr2]   = TGT.[ArtsNr2]   COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.[ArtsKey]   = TGT.[ArtsKey]   COLLATE SQL_Latin1_General_CP1_CS_AS 
					AND SRC.[VerkFarbe] = TGT.[VerkFarbe] COLLATE SQL_Latin1_General_CP1_CS_AS 
					   )
				WHEN MATCHED AND (TGT.Wann != SRC.Wann)
				THEN UPDATE SET 
						 TGT.[TapKey_VerkFarbe]         = SRC.[TapKey_VerkFarbe]         
						,TGT.[VonGroesse]               = SRC.[VonGroesse]               
						,TGT.[BisGroesse]               = SRC.[BisGroesse]               
						,TGT.[TapKey_Sperre]            = SRC.[TapKey_Sperre]            
						,TGT.[Sperre]                   = SRC.[Sperre]                   
						,TGT.[PattNr]                   = SRC.[PattNr]                   
						,TGT.[Version]                  = SRC.[Version]                  
						,TGT.[PattKey]                  = SRC.[PattKey]                  
						,TGT.[StandardJN]               = SRC.[StandardJN]               
						,TGT.[TapKey_StandardJN]        = SRC.[TapKey_StandardJN]        
						,TGT.[UArtsKey]                 = SRC.[UArtsKey]                 
						,TGT.[EkPreisGewDM]             = SRC.[EkPreisGewDM]             
						,TGT.[LieferbarAb]              = SRC.[LieferbarAb]              
						,TGT.[VerfuegbarAb]             = SRC.[VerfuegbarAb]             
						,TGT.[Neu]                      = SRC.[Neu]                      
						,TGT.[Wer]                      = SRC.[Wer]                      
						,TGT.[Wann]                     = SRC.[Wann]                     
						,TGT.[TapKey_SMU_Kennzeichen]   = SRC.[TapKey_SMU_Kennzeichen]   
						,TGT.[SMU_Kennzeichen]          = SRC.[SMU_Kennzeichen]          
						,TGT.[TapKey_ErsteSaisonAktiv]  = SRC.[TapKey_ErsteSaisonAktiv]  
						,TGT.[ErsteSaisonAktiv]         = SRC.[ErsteSaisonAktiv]         
						,TGT.[TapKey_LetzteSaisonAktiv] = SRC.[TapKey_LetzteSaisonAktiv] 
						,TGT.[LetzteSaisonAktiv]        = SRC.[LetzteSaisonAktiv]        
						,TGT.[CoreJN]                   = SRC.[CoreJN]                   
						,TGT.[CarryOverJN]              = SRC.[CarryOverJN]              
						,TGT.[KeyStyleJN]               = SRC.[KeyStyleJN]               
						,TGT.[TapKey_RabattTyp]         = SRC.[TapKey_RabattTyp]         
						,TGT.[RabattTyp]                = SRC.[RabattTyp]                
						,TGT.[LieferbarBis]             = SRC.[LieferbarBis]             
						,TGT.[TapKey_SeasonType]        = SRC.[TapKey_SeasonType]        
						,TGT.[SeasonType]               = SRC.[SeasonType]               
						,TGT.[PreSeasonJN]              = SRC.[PreSeasonJN]              
				WHEN NOT MATCHED BY TARGET THEN
				INSERT ([ArtsNr1], [ArtsNr2], [ArtsKey], [VerkFarbe], [TapKey_VerkFarbe], [VonGroesse], [BisGroesse], [TapKey_Sperre], [Sperre], [PattNr], [Version], [PattKey], [StandardJN], [TapKey_StandardJN], [UArtsKey], [EkPreisGewDM], [LieferbarAb], [VerfuegbarAb], [Neu], [Wer], [Wann], [TapKey_SMU_Kennzeichen], [SMU_Kennzeichen], [TapKey_ErsteSaisonAktiv], [ErsteSaisonAktiv], [TapKey_LetzteSaisonAktiv], [LetzteSaisonAktiv], [CoreJN], [CarryOverJN], [KeyStyleJN], [TapKey_RabattTyp], [RabattTyp], [LieferbarBis], [TapKey_SeasonType], [SeasonType], [PreSeasonJN])
				VALUES (SRC.[ArtsNr1], SRC.[ArtsNr2], SRC.[ArtsKey], SRC.[VerkFarbe], SRC.[TapKey_VerkFarbe], SRC.[VonGroesse], SRC.[BisGroesse], SRC.[TapKey_Sperre], SRC.[Sperre], SRC.[PattNr], SRC.[Version], SRC.[PattKey], SRC.[StandardJN], SRC.[TapKey_StandardJN], SRC.[UArtsKey], SRC.[EkPreisGewDM], SRC.[LieferbarAb], SRC.[VerfuegbarAb], SRC.[Neu], SRC.[Wer], SRC.[Wann], SRC.[TapKey_SMU_Kennzeichen], SRC.[SMU_Kennzeichen], SRC.[TapKey_ErsteSaisonAktiv], SRC.[ErsteSaisonAktiv], SRC.[TapKey_LetzteSaisonAktiv], SRC.[LetzteSaisonAktiv], SRC.[CoreJN], SRC.[CarryOverJN], SRC.[KeyStyleJN], SRC.[TapKey_RabattTyp], SRC.[RabattTyp], SRC.[LieferbarBis], SRC.[TapKey_SeasonType], SRC.[SeasonType], SRC.[PreSeasonJN])
				WHEN NOT MATCHED BY SOURCE THEN DELETE;
			SELECT
				@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
			IF @DEBUG = 1
				BEGIN
					PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
				END
			SET @Start = getdate()
--#endregion ArtFarben

--#region ArtLieferant
			--ArtLieferant
			SET @curObject = 'ArtLieferant Merge'
			MERGE  [dbo].[INTEX_RAW_ArtLieferant] AS TGT
			USING
			(SELECT
				[ArtsNr1], [ArtsNr2] ,[ArtsKey] ,[Lfd] ,[LiefKey] ,[LiefNr] ,[TapKey_Ursprung] ,[Ursprung] ,[MehrereUrsprungslaenderJN] ,[EkPreisFW] ,[EkPreisDM] ,[TapKey_Waehrung] ,[Waehrung] ,[HauptLieferantJN] ,[Neu] ,[Wer] ,[Wann]
			FROM [SQLINTEX].[OdloDE].[dbo].[ArtLieferant] al WITH(READPAST)
			WHERE al.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
				ON (SRC.[ArtsNr1]   = TGT.[ArtsNr1]   COLLATE SQL_Latin1_General_CP1_CS_AS 
				AND SRC.[ArtsNr2]   = TGT.[ArtsNr2]   COLLATE SQL_Latin1_General_CP1_CS_AS 
				AND SRC.[ArtsKey]   = TGT.[ArtsKey]   COLLATE SQL_Latin1_General_CP1_CS_AS 
				AND SRC.[Lfd]       = TGT.[Lfd] 
				   )
			WHEN MATCHED AND (TGT.Wann != SRC.Wann)
			THEN UPDATE SET 
					 TGT.[ArtsNr1]                    = SRC.[ArtsNr1]                   
					,TGT.[ArtsNr2]                    = SRC.[ArtsNr2]                   
					,TGT.[ArtsKey]                    = SRC.[ArtsKey]                   
					,TGT.[Lfd]                        = SRC.[Lfd]                       
					,TGT.[LiefKey]                    = SRC.[LiefKey]                   
					,TGT.[LiefNr]                     = SRC.[LiefNr]                    
					,TGT.[TapKey_Ursprung]            = SRC.[TapKey_Ursprung]           
					,TGT.[Ursprung]                   = SRC.[Ursprung]                  
					,TGT.[MehrereUrsprungslaenderJN]  = SRC.[MehrereUrsprungslaenderJN] 
					,TGT.[EkPreisFW]                  = SRC.[EkPreisFW]                 
					,TGT.[EkPreisDM]                  = SRC.[EkPreisDM]                 
					,TGT.[TapKey_Waehrung]            = SRC.[TapKey_Waehrung]           
					,TGT.[Waehrung]                   = SRC.[Waehrung]                  
					,TGT.[HauptLieferantJN]           = SRC.[HauptLieferantJN]          
					,TGT.[Neu]                        = SRC.[Neu]                       
					,TGT.[Wer]                        = SRC.[Wer]                       
					,TGT.[Wann]                       = SRC.[Wann]                      
			WHEN NOT MATCHED BY TARGET THEN
			INSERT ( [ArtsNr1], [ArtsNr2] ,[ArtsKey] ,[Lfd] ,[LiefKey] ,[LiefNr] ,[TapKey_Ursprung] ,[Ursprung] ,[MehrereUrsprungslaenderJN] ,[EkPreisFW] ,[EkPreisDM] ,[TapKey_Waehrung] ,[Waehrung] ,[HauptLieferantJN] ,[Neu] ,[Wer] ,[Wann] )
			VALUES ( SRC.[ArtsNr1], SRC.[ArtsNr2] ,SRC.[ArtsKey] ,SRC.[Lfd] ,SRC.[LiefKey] ,SRC.[LiefNr] ,SRC.[TapKey_Ursprung] ,SRC.[Ursprung] ,SRC.[MehrereUrsprungslaenderJN] ,SRC.[EkPreisFW] ,SRC.[EkPreisDM] ,SRC.[TapKey_Waehrung] ,SRC.[Waehrung] ,SRC.[HauptLieferantJN] ,SRC.[Neu] ,SRC.[Wer] ,SRC.[Wann] )
			WHEN NOT MATCHED BY SOURCE THEN DELETE;
			SELECT
				@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
			IF @DEBUG = 1
				BEGIN
					PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
				END
			SET @Start = getdate()
--#endregion ArtLieferant

--#region AufKopf
	--AufKopf
	SET @curObject = 'AufKopf Merge'
	/*INSERT INTO [dbo].[INTEX_RAW_AufKopf]
		(
			 [AufkNr]
			,[AufkKey]
			,[KusNr]
			,[KustKey]
			,[KuvNr]
			,[TapKey_Art]
			,[Art]
			,[TapKey_EinArt]
			,[EinArt]
			,[KuNrRech]
			,[KuNrAB]
			,[KuADatum]
			,[Limit]
			,[TapKey_Prio]
			,[Prio]
			,[TapKey_ABDruck]
			,[ABDruck]
			,[TapKey_MwSt]
			,[MwSt]
			,[KundeAbt]
			,[KundeAnsprech]
			,[TapKey_Recycling]
			,[Recycling]
			,[KundenAufNr]
			,[TapKey_PreisLst]
			,[PreisLst]
			,[TapKey_Versicherung]
			,[Versicherung]
			,[TapKey_ZahlBed]
			,[ZahlBed]
			,[TapKey_Versandweg]
			,[Versandweg]
			,[Valutatage]
			,[TapKey_Land]
			,[Land]
			,[TapKey_Sprache]
			,[Sprache]
			,[V1_VersKey]
			,[V1_VersNr]
			,[V2_VersKey]
			,[V2_VersNr]
			,[Ersterfasser]
			,[ErsterfassungDatum]
			,[TapKey_StornoGrd]
			,[StornoGrd]
			,[TapKey_StornoTxt]
			,[StornoTxt]
			,[Stornoerfasser]
			,[StornoDatum]
			,[BonusJN]
			,[TapKey_LagerOrt]
			,[LagerOrt]
			,[TapKey_PreisSt]
			,[PreisSt]
			,[TapKey_Mahnkenn]
			,[Mahnkenn]
			,[TapKey_LiefTerm]
			,[LiefTerm]
			,[TerminVon]
			,[TerminBis]
			,[TapKey_ProdLine]
			,[ProdLine]
			,[AbGedruckt]
			,[PreisLiefSchein]
			,[Rabatt]
			,[BezugAufkNr]
			,[KomplettLieferungJN]
			,[BezugAufkKey]
			,[AbrechnungEKVJN]
			,[TapKey_SoVeTyp]
			,[SoVeTyp]
			,[TapKey_MMZ]
			,[MMZ]
			,[MMZBerechnetJN]
			,[EDIABJN]
			,[Neu]
			,[Wer]
			,[Wann]
			,[ZurueckgelegtJN]
			,[Valutadatum]
			,[WKIdent]
			,[TapKey_KuZahlungsart]
			,[KuZahlungsart]
			,[FrachtEW]
			,[FrachtFW]
			,[VorlaeufigeRetoureJN]
			,[OrderAcknldGedrucktJN]
			,[RefAufkKey]
		)
	SELECT
		 [AufkNr]
		,[AufkKey]
		,[KusNr]
		,[KustKey]
		,[KuvNr]
		,[TapKey_Art]
		,[Art]
		,[TapKey_EinArt]
		,[EinArt]
		,[KuNrRech]
		,[KuNrAB]
		,[KuADatum]
		,[Limit]
		,[TapKey_Prio]
		,[Prio]
		,[TapKey_ABDruck]
		,[ABDruck]
		,[TapKey_MwSt]
		,[MwSt]
		,[KundeAbt]
		,[KundeAnsprech]
		,[TapKey_Recycling]
		,[Recycling]
		,[KundenAufNr]
		,[TapKey_PreisLst]
		,[PreisLst]
		,[TapKey_Versicherung]
		,[Versicherung]
		,[TapKey_ZahlBed]
		,[ZahlBed]
		,[TapKey_Versandweg]
		,[Versandweg]
		,[Valutatage]
		,[TapKey_Land]
		,[Land]
		,[TapKey_Sprache]
		,[Sprache]
		,[V1_VersKey]
		,[V1_VersNr]
		,[V2_VersKey]
		,[V2_VersNr]
		,[Ersterfasser]
		,[ErsterfassungDatum]
		,[TapKey_StornoGrd]
		,[StornoGrd]
		,[TapKey_StornoTxt]
		,[StornoTxt]
		,[Stornoerfasser]
		,[StornoDatum]
		,[BonusJN]
		,[TapKey_LagerOrt]
		,[LagerOrt]
		,[TapKey_PreisSt]
		,[PreisSt]
		,[TapKey_Mahnkenn]
		,[Mahnkenn]
		,[TapKey_LiefTerm]
		,[LiefTerm]
		,[TerminVon]
		,[TerminBis]
		,[TapKey_ProdLine]
		,[ProdLine]
		,[AbGedruckt]
		,[PreisLiefSchein]
		,[Rabatt]
		,[BezugAufkNr]
		,[KomplettLieferungJN]
		,[BezugAufkKey]
		,[AbrechnungEKVJN]
		,[TapKey_SoVeTyp]
		,[SoVeTyp]
		,[TapKey_MMZ]
		,[MMZ]
		,[MMZBerechnetJN]
		,[EDIABJN]
		,[Neu]
		,[Wer]
		,[Wann]
		,[ZurueckgelegtJN]
		,[Valutadatum]
		,[WKIdent]
		,[TapKey_KuZahlungsart]
		,[KuZahlungsart]
		,[FrachtEW]
		,[FrachtFW]
		,[VorlaeufigeRetoureJN]
		,[OrderAcknldGedrucktJN]
		,[RefAufkKey]
	FROM [SQLINTEX].[OdloDE].[dbo].[AufKopf] ak WITH(READPAST)
	WHERE ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)*/
	MERGE [dbo].[INTEX_RAW_AufKopf] AS TGT
	USING 
		(SELECT
			[AufkNr], [AufkKey], [KusNr], [KustKey], [KuvNr], [TapKey_Art], [Art], [TapKey_EinArt], [EinArt], [KuNrRech], [KuNrAB], [KuADatum], [Limit], [TapKey_Prio], [Prio], [TapKey_ABDruck], [ABDruck], [TapKey_MwSt], [MwSt], [KundeAbt], [KundeAnsprech], [TapKey_Recycling], [Recycling], [KundenAufNr], [TapKey_PreisLst], [PreisLst], [TapKey_Versicherung], [Versicherung], [TapKey_ZahlBed], [ZahlBed], [TapKey_Versandweg], [Versandweg], [Valutatage], [TapKey_Land], [Land], [TapKey_Sprache], [Sprache], [V1_VersKey], [V1_VersNr], [V2_VersKey], [V2_VersNr], [Ersterfasser], [ErsterfassungDatum], [TapKey_StornoGrd], [StornoGrd], [TapKey_StornoTxt], [StornoTxt], [Stornoerfasser], [StornoDatum], [BonusJN], [TapKey_LagerOrt], [LagerOrt], [TapKey_PreisSt], [PreisSt], [TapKey_Mahnkenn], [Mahnkenn], [TapKey_LiefTerm], [LiefTerm], [TerminVon], [TerminBis], [TapKey_ProdLine], [ProdLine], [AbGedruckt], [PreisLiefSchein], [Rabatt], [BezugAufkNr], [KomplettLieferungJN], [BezugAufkKey], [AbrechnungEKVJN], [TapKey_SoVeTyp], [SoVeTyp], [TapKey_MMZ], [MMZ], [MMZBerechnetJN], [EDIABJN], [Neu], [Wer], [Wann], [ZurueckgelegtJN], [Valutadatum], [WKIdent], [TapKey_KuZahlungsart], [KuZahlungsart], [FrachtEW], [FrachtFW], [VorlaeufigeRetoureJN], [OrderAcknldGedrucktJN], [RefAufkKey]	FROM [SQLINTEX].[OdloDE].[dbo].[AufKopf] ak WITH(READPAST)
		WHERE ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
		ON ( SRC.[AufkNr] = TGT.[AufkNr] AND SRC.[AufkKey] = TGT.[AufkKey] COLLATE Latin1_General_CI_AS )
		WHEN MATCHED AND (TGT.Wann != SRC.Wann)
		THEN UPDATE SET  
			 TGT.[KusNr]                   = SRC.[KusNr]                  
			,TGT.[KustKey]                 = SRC.[KustKey]                
			,TGT.[KuvNr]                   = SRC.[KuvNr]                  
			,TGT.[TapKey_Art]              = SRC.[TapKey_Art]             
			,TGT.[Art]                     = SRC.[Art]                    
			,TGT.[TapKey_EinArt]           = SRC.[TapKey_EinArt]          
			,TGT.[EinArt]                  = SRC.[EinArt]                 
			,TGT.[KuNrRech]                = SRC.[KuNrRech]               
			,TGT.[KuNrAB]                  = SRC.[KuNrAB]                 
			,TGT.[KuADatum]                = SRC.[KuADatum]               
			,TGT.[Limit]                   = SRC.[Limit]                  
			,TGT.[TapKey_Prio]             = SRC.[TapKey_Prio]            
			,TGT.[Prio]                    = SRC.[Prio]                   
			,TGT.[TapKey_ABDruck]          = SRC.[TapKey_ABDruck]         
			,TGT.[ABDruck]                 = SRC.[ABDruck]                
			,TGT.[TapKey_MwSt]             = SRC.[TapKey_MwSt]            
			,TGT.[MwSt]                    = SRC.[MwSt]                   
			,TGT.[KundeAbt]                = SRC.[KundeAbt]               
			,TGT.[KundeAnsprech]           = SRC.[KundeAnsprech]          
			,TGT.[TapKey_Recycling]        = SRC.[TapKey_Recycling]       
			,TGT.[Recycling]               = SRC.[Recycling]              
			,TGT.[KundenAufNr]             = SRC.[KundenAufNr]            
			,TGT.[TapKey_PreisLst]         = SRC.[TapKey_PreisLst]        
			,TGT.[PreisLst]                = SRC.[PreisLst]               
			,TGT.[TapKey_Versicherung]     = SRC.[TapKey_Versicherung]    
			,TGT.[Versicherung]            = SRC.[Versicherung]           
			,TGT.[TapKey_ZahlBed]          = SRC.[TapKey_ZahlBed]         
			,TGT.[ZahlBed]                 = SRC.[ZahlBed]                
			,TGT.[TapKey_Versandweg]       = SRC.[TapKey_Versandweg]      
			,TGT.[Versandweg]              = SRC.[Versandweg]             
			,TGT.[Valutatage]              = SRC.[Valutatage]             
			,TGT.[TapKey_Land]             = SRC.[TapKey_Land]            
			,TGT.[Land]                    = SRC.[Land]                   
			,TGT.[TapKey_Sprache]          = SRC.[TapKey_Sprache]         
			,TGT.[Sprache]                 = SRC.[Sprache]                
			,TGT.[V1_VersKey]              = SRC.[V1_VersKey]             
			,TGT.[V1_VersNr]               = SRC.[V1_VersNr]              
			,TGT.[V2_VersKey]              = SRC.[V2_VersKey]             
			,TGT.[V2_VersNr]               = SRC.[V2_VersNr]              
			,TGT.[Ersterfasser]            = SRC.[Ersterfasser]           
			,TGT.[ErsterfassungDatum]      = SRC.[ErsterfassungDatum]     
			,TGT.[TapKey_StornoGrd]        = SRC.[TapKey_StornoGrd]       
			,TGT.[StornoGrd]               = SRC.[StornoGrd]              
			,TGT.[TapKey_StornoTxt]        = SRC.[TapKey_StornoTxt]       
			,TGT.[StornoTxt]               = SRC.[StornoTxt]              
			,TGT.[Stornoerfasser]          = SRC.[Stornoerfasser]         
			,TGT.[StornoDatum]             = SRC.[StornoDatum]            
			,TGT.[BonusJN]                 = SRC.[BonusJN]                
			,TGT.[TapKey_LagerOrt]         = SRC.[TapKey_LagerOrt]        
			,TGT.[LagerOrt]                = SRC.[LagerOrt]               
			,TGT.[TapKey_PreisSt]          = SRC.[TapKey_PreisSt]         
			,TGT.[PreisSt]                 = SRC.[PreisSt]                
			,TGT.[TapKey_Mahnkenn]         = SRC.[TapKey_Mahnkenn]        
			,TGT.[Mahnkenn]                = SRC.[Mahnkenn]               
			,TGT.[TapKey_LiefTerm]         = SRC.[TapKey_LiefTerm]        
			,TGT.[LiefTerm]                = SRC.[LiefTerm]               
			,TGT.[TerminVon]               = SRC.[TerminVon]              
			,TGT.[TerminBis]               = SRC.[TerminBis]              
			,TGT.[TapKey_ProdLine]         = SRC.[TapKey_ProdLine]        
			,TGT.[ProdLine]                = SRC.[ProdLine]               
			,TGT.[AbGedruckt]              = SRC.[AbGedruckt]             
			,TGT.[PreisLiefSchein]         = SRC.[PreisLiefSchein]        
			,TGT.[Rabatt]                  = SRC.[Rabatt]                 
			,TGT.[BezugAufkNr]             = SRC.[BezugAufkNr]            
			,TGT.[KomplettLieferungJN]     = SRC.[KomplettLieferungJN]    
			,TGT.[BezugAufkKey]            = SRC.[BezugAufkKey]           
			,TGT.[AbrechnungEKVJN]         = SRC.[AbrechnungEKVJN]        
			,TGT.[TapKey_SoVeTyp]          = SRC.[TapKey_SoVeTyp]         
			,TGT.[SoVeTyp]                 = SRC.[SoVeTyp]                
			,TGT.[TapKey_MMZ]              = SRC.[TapKey_MMZ]             
			,TGT.[MMZ]                     = SRC.[MMZ]                    
			,TGT.[MMZBerechnetJN]          = SRC.[MMZBerechnetJN]         
			,TGT.[EDIABJN]                 = SRC.[EDIABJN]                
			,TGT.[Neu]                     = SRC.[Neu]                    
			,TGT.[Wer]                     = SRC.[Wer]                    
			,TGT.[Wann]                    = SRC.[Wann]                   
			,TGT.[ZurueckgelegtJN]         = SRC.[ZurueckgelegtJN]        
			,TGT.[Valutadatum]             = SRC.[Valutadatum]            
			,TGT.[WKIdent]                 = SRC.[WKIdent]                
			,TGT.[TapKey_KuZahlungsart]    = SRC.[TapKey_KuZahlungsart]   
			,TGT.[KuZahlungsart]           = SRC.[KuZahlungsart]          
			,TGT.[FrachtEW]                = SRC.[FrachtEW]               
			,TGT.[FrachtFW]                = SRC.[FrachtFW]               
			,TGT.[VorlaeufigeRetoureJN]    = SRC.[VorlaeufigeRetoureJN]   
			,TGT.[OrderAcknldGedrucktJN]   = SRC.[OrderAcknldGedrucktJN]  
			,TGT.[RefAufkKey]              = SRC.[RefAufkKey]             
	WHEN NOT MATCHED BY TARGET THEN INSERT ([AufkNr], [AufkKey], [KusNr], [KustKey], [KuvNr], [TapKey_Art], [Art], [TapKey_EinArt], [EinArt], [KuNrRech], [KuNrAB], [KuADatum], [Limit], [TapKey_Prio], [Prio], [TapKey_ABDruck], [ABDruck], [TapKey_MwSt], [MwSt], [KundeAbt], [KundeAnsprech], [TapKey_Recycling], [Recycling], [KundenAufNr], [TapKey_PreisLst], [PreisLst], [TapKey_Versicherung], [Versicherung], [TapKey_ZahlBed], [ZahlBed], [TapKey_Versandweg], [Versandweg], [Valutatage], [TapKey_Land], [Land], [TapKey_Sprache], [Sprache], [V1_VersKey], [V1_VersNr], [V2_VersKey], [V2_VersNr], [Ersterfasser], [ErsterfassungDatum], [TapKey_StornoGrd], [StornoGrd], [TapKey_StornoTxt], [StornoTxt], [Stornoerfasser], [StornoDatum], [BonusJN], [TapKey_LagerOrt], [LagerOrt], [TapKey_PreisSt], [PreisSt], [TapKey_Mahnkenn], [Mahnkenn], [TapKey_LiefTerm], [LiefTerm], [TerminVon], [TerminBis], [TapKey_ProdLine], [ProdLine], [AbGedruckt], [PreisLiefSchein], [Rabatt], [BezugAufkNr], [KomplettLieferungJN], [BezugAufkKey], [AbrechnungEKVJN], [TapKey_SoVeTyp], [SoVeTyp], [TapKey_MMZ], [MMZ], [MMZBerechnetJN], [EDIABJN], [Neu], [Wer], [Wann], [ZurueckgelegtJN], [Valutadatum], [WKIdent], [TapKey_KuZahlungsart], [KuZahlungsart], [FrachtEW], [FrachtFW], [VorlaeufigeRetoureJN], [OrderAcknldGedrucktJN], [RefAufkKey])   VALUES (SRC.[AufkNr], SRC.[AufkKey], SRC.[KusNr], SRC.[KustKey], SRC.[KuvNr], SRC.[TapKey_Art], SRC.[Art], SRC.[TapKey_EinArt], SRC.[EinArt], SRC.[KuNrRech], SRC.[KuNrAB], SRC.[KuADatum], SRC.[Limit], SRC.[TapKey_Prio], SRC.[Prio], SRC.[TapKey_ABDruck], SRC.[ABDruck], SRC.[TapKey_MwSt], SRC.[MwSt], SRC.[KundeAbt], SRC.[KundeAnsprech], SRC.[TapKey_Recycling], SRC.[Recycling], SRC.[KundenAufNr], SRC.[TapKey_PreisLst], SRC.[PreisLst], SRC.[TapKey_Versicherung], SRC.[Versicherung], SRC.[TapKey_ZahlBed], SRC.[ZahlBed], SRC.[TapKey_Versandweg], SRC.[Versandweg], SRC.[Valutatage], SRC.[TapKey_Land], SRC.[Land], SRC.[TapKey_Sprache], SRC.[Sprache], SRC.[V1_VersKey], SRC.[V1_VersNr], SRC.[V2_VersKey], SRC.[V2_VersNr], SRC.[Ersterfasser], SRC.[ErsterfassungDatum], SRC.[TapKey_StornoGrd], SRC.[StornoGrd], SRC.[TapKey_StornoTxt], SRC.[StornoTxt], SRC.[Stornoerfasser], SRC.[StornoDatum], SRC.[BonusJN], SRC.[TapKey_LagerOrt], SRC.[LagerOrt], SRC.[TapKey_PreisSt], SRC.[PreisSt], SRC.[TapKey_Mahnkenn], SRC.[Mahnkenn], SRC.[TapKey_LiefTerm], SRC.[LiefTerm], SRC.[TerminVon], SRC.[TerminBis], SRC.[TapKey_ProdLine], SRC.[ProdLine], SRC.[AbGedruckt], SRC.[PreisLiefSchein], SRC.[Rabatt], SRC.[BezugAufkNr], SRC.[KomplettLieferungJN], SRC.[BezugAufkKey], SRC.[AbrechnungEKVJN], SRC.[TapKey_SoVeTyp], SRC.[SoVeTyp], SRC.[TapKey_MMZ], SRC.[MMZ], SRC.[MMZBerechnetJN], SRC.[EDIABJN], SRC.[Neu], SRC.[Wer], SRC.[Wann], SRC.[ZurueckgelegtJN], SRC.[Valutadatum], SRC.[WKIdent], SRC.[TapKey_KuZahlungsart], SRC.[KuZahlungsart], SRC.[FrachtEW], SRC.[FrachtFW], SRC.[VorlaeufigeRetoureJN], SRC.[OrderAcknldGedrucktJN], SRC.[RefAufkKey])
	WHEN NOT MATCHED BY SOURCE THEN DELETE;
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

--#endregion AufKopf

--#region AufPosi
	--AufPosi
	SET @curObject = 'AufPosi Merge'
	/*INSERT INTO [dbo].[INTEX_RAW_AufPosi]
		(
			 [AufkNr]
			,[AufkKey]
			,[OrderBlatt]
			,[AufPNr]
			,[KusNr]
			,[KustKey]
			,[ArtsNr1]
			,[ArtsNr2]
			,[ArtsKey]
			,[VerkFarbe]
			,[TapKey_Artgrp]
			,[ArtGrp]
			,[ComposeeKz]
			,[TapKey_Art]
			,[Art]
			,[Om]
			,[Sm]
			,[Em]
			,[Km]
			,[Lm]
			,[Fm]
			,[EPrFW]
			,[OPrFW]
			,[EPrDM]
			,[OPrDM]
			,[Rabatt]
			,[V1_VersNr]
			,[V1_VersKey]
			,[V2_VersNr]
			,[V2_VersKey]
			,[ProviV1]
			,[ProviV2]
			,[TapKey_PreisAbweichGrund]
			,[PreisAbweichGrund]
			,[TapKey_ProdGrp]
			,[ProdGrp]
			,[TapKey_Typ]
			,[Typ]
			,[TapKey_Groessenzuschlag]
			,[Groessenzuschlag]
			,[TapKey_LiefTerm]
			,[LiefTerm]
			,[TerminVon]
			,[TerminBis]
			,[TapKey_Lagerort]
			,[Lagerort]
			,[TapKey_Etikett]
			,[Etikett]
			,[TapKey_Aufmachung]
			,[Aufmachung]
			,[KuArtikelNr]
			,[KuFarbNr]
			,[Bemerkung]
			,[TapKey_RetourGrund]
			,[RetourGrund]
			,[TapKey_RetourText]
			,[RetourText]
			,[TapKey_StornoGrund]
			,[StornoGrund]
			,[TapKey_StornoText]
			,[StornoText]
			,[RefAufPNr]
			,[RefOrderBlatt]
			,[BezugAufkNr]
			,[BezugAufkKey]
			,[BezugOrderBlatt]
			,[BezugAufPNr]
			,[BasisAufkNr]
			,[BasisAufkKey]
			,[BasisOrderBlat]
			,[BasisAufPNr]
			,[BasisKuADatum]
			,[BasisKundenAufNr]
			,[Neu]
			,[Wer]
			,[Wann]
			,[WKLfd]
			,[ZuteilungsNr]
			,[OffenJN]
			,[Um]
			,[ConfDelDate]
			,[LastConfDelDate]
			,[AgreedChangeDate]
			,[AgreedChangeDateGTab]
			,[AgreedChangeDateGeaendertJN]
		)
	SELECT
		 [AufkNr]
		,[AufkKey]
		,[OrderBlatt]
		,[AufPNr]
		,[KusNr]
		,[KustKey]
		,[ArtsNr1]
		,[ArtsNr2]
		,[ArtsKey]
		,[VerkFarbe]
		,[TapKey_Artgrp]
		,[ArtGrp]
		,[ComposeeKz]
		,[TapKey_Art]
		,[Art]
		,[Om]
		,[Sm]
		,[Em]
		,[Km]
		,[Lm]
		,[Fm]
		,[EPrFW]
		,[OPrFW]
		,[EPrDM]
		,[OPrDM]
		,[Rabatt]
		,[V1_VersNr]
		,[V1_VersKey]
		,[V2_VersNr]
		,[V2_VersKey]
		,[ProviV1]
		,[ProviV2]
		,[TapKey_PreisAbweichGrund]
		,[PreisAbweichGrund]
		,[TapKey_ProdGrp]
		,[ProdGrp]
		,[TapKey_Typ]
		,[Typ]
		,[TapKey_Groessenzuschlag]
		,[Groessenzuschlag]
		,[TapKey_LiefTerm]
		,[LiefTerm]
		,[TerminVon]
		,[TerminBis]
		,[TapKey_Lagerort]
		,[Lagerort]
		,[TapKey_Etikett]
		,[Etikett]
		,[TapKey_Aufmachung]
		,[Aufmachung]
		,[KuArtikelNr]
		,[KuFarbNr]
		,[Bemerkung]
		,[TapKey_RetourGrund]
		,[RetourGrund]
		,[TapKey_RetourText]
		,[RetourText]
		,[TapKey_StornoGrund]
		,[StornoGrund]
		,[TapKey_StornoText]
		,[StornoText]
		,[RefAufPNr]
		,[RefOrderBlatt]
		,[BezugAufkNr]
		,[BezugAufkKey]
		,[BezugOrderBlatt]
		,[BezugAufPNr]
		,[BasisAufkNr]
		,[BasisAufkKey]
		,[BasisOrderBlat]
		,[BasisAufPNr]
		,[BasisKuADatum]
		,[BasisKundenAufNr]
		,[Neu]
		,[Wer]
		,[Wann]
		,[WKLfd]
		,[ZuteilungsNr]
		,[OffenJN]
		,[Um]
		,[ConfDelDate]
		,[LastConfDelDate]
		,[AgreedChangeDate]
		,[AgreedChangeDateGTab]
		,[AgreedChangeDateGeaendertJN]
	FROM [SQLINTEX].[OdloDE].[dbo].[AufPosi] ap WITH(READPAST)
	WHERE ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller) */
		MERGE [dbo].[INTEX_RAW_AufPosi] AS TGT
	USING 
		(	SELECT
			 [AufkNr], [AufkKey], [OrderBlatt], [AufPNr], [KusNr], [KustKey], [ArtsNr1], [ArtsNr2], [ArtsKey], [VerkFarbe], [TapKey_Artgrp], [ArtGrp], [ComposeeKz], [TapKey_Art], [Art], [Om], [Sm], [Em], [Km], [Lm], [Fm], [EPrFW], [OPrFW], [EPrDM], [OPrDM], [Rabatt], [V1_VersNr], [V1_VersKey], [V2_VersNr], [V2_VersKey], [ProviV1], [ProviV2], [TapKey_PreisAbweichGrund], [PreisAbweichGrund], [TapKey_ProdGrp], [ProdGrp], [TapKey_Typ], [Typ], [TapKey_Groessenzuschlag], [Groessenzuschlag], [TapKey_LiefTerm], [LiefTerm], [TerminVon], [TerminBis], [TapKey_Lagerort], [Lagerort], [TapKey_Etikett], [Etikett], [TapKey_Aufmachung], [Aufmachung], [KuArtikelNr], [KuFarbNr], [Bemerkung], [TapKey_RetourGrund], [RetourGrund], [TapKey_RetourText], [RetourText], [TapKey_StornoGrund], [StornoGrund], [TapKey_StornoText], [StornoText], [RefAufPNr], [RefOrderBlatt], [BezugAufkNr], [BezugAufkKey], [BezugOrderBlatt], [BezugAufPNr], [BasisAufkNr], [BasisAufkKey], [BasisOrderBlat], [BasisAufPNr], [BasisKuADatum], [BasisKundenAufNr], [Neu], [Wer], [Wann], [WKLfd], [ZuteilungsNr], [OffenJN], [Um], [ConfDelDate], [LastConfDelDate], [AgreedChangeDate], [AgreedChangeDateGTab], [AgreedChangeDateGeaendertJN]
		FROM [SQLINTEX].[OdloDE].[dbo].[AufPosi] ap WITH(READPAST)
		WHERE ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
		ON ( 
				 SRC.[AufkNr] = TGT.[AufkNr] 
			 AND SRC.[AufkKey] = TGT.[AufkKey] COLLATE Latin1_General_CI_AS 
			 AND SRC.[OrderBlatt] = TGT.[OrderBlatt]
			 AND SRC.[AufPNr] = TGT.[AufPNr]
			)
		WHEN MATCHED AND (TGT.Wann != SRC.Wann)
		THEN UPDATE SET 
			 TGT.[KusNr]                       = SRC.[KusNr]                            
			,TGT.[KustKey]                     = SRC.[KustKey]                          COLLATE Latin1_General_CI_AS
			,TGT.[ArtsNr1]                     = SRC.[ArtsNr1]                          COLLATE Latin1_General_CI_AS
			,TGT.[ArtsNr2]                     = SRC.[ArtsNr2]                          COLLATE Latin1_General_CI_AS
			,TGT.[ArtsKey]                     = SRC.[ArtsKey]                          COLLATE Latin1_General_CI_AS
			,TGT.[VerkFarbe]                   = SRC.[VerkFarbe]                        COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_Artgrp]               = SRC.[TapKey_Artgrp]                    COLLATE Latin1_General_CI_AS
			,TGT.[ArtGrp]                      = SRC.[ArtGrp]                           COLLATE Latin1_General_CI_AS
			,TGT.[ComposeeKz]                  = SRC.[ComposeeKz]                       COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_Art]                  = SRC.[TapKey_Art]                       COLLATE Latin1_General_CI_AS
			,TGT.[Art]                         = SRC.[Art]                              COLLATE Latin1_General_CI_AS
			,TGT.[Om]                          = SRC.[Om]                               
			,TGT.[Sm]                          = SRC.[Sm]                               
			,TGT.[Em]                          = SRC.[Em]                               
			,TGT.[Km]                          = SRC.[Km]                               
			,TGT.[Lm]                          = SRC.[Lm]                               
			,TGT.[Fm]                          = SRC.[Fm]                               
			,TGT.[EPrFW]                       = SRC.[EPrFW]                            
			,TGT.[OPrFW]                       = SRC.[OPrFW]                            
			,TGT.[EPrDM]                       = SRC.[EPrDM]                            
			,TGT.[OPrDM]                       = SRC.[OPrDM]                            
			,TGT.[Rabatt]                      = SRC.[Rabatt]                           
			,TGT.[V1_VersNr]                   = SRC.[V1_VersNr]                        
			,TGT.[V1_VersKey]                  = SRC.[V1_VersKey]                       
			,TGT.[V2_VersNr]                   = SRC.[V2_VersNr]                        
			,TGT.[V2_VersKey]                  = SRC.[V2_VersKey]                       
			,TGT.[ProviV1]                     = SRC.[ProviV1]                          
			,TGT.[ProviV2]                     = SRC.[ProviV2]                          
			,TGT.[TapKey_PreisAbweichGrund]    = SRC.[TapKey_PreisAbweichGrund]         COLLATE Latin1_General_CI_AS
			,TGT.[PreisAbweichGrund]           = SRC.[PreisAbweichGrund]                COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_ProdGrp]              = SRC.[TapKey_ProdGrp]                   COLLATE Latin1_General_CI_AS
			,TGT.[ProdGrp]                     = SRC.[ProdGrp]                          COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_Typ]                  = SRC.[TapKey_Typ]                       COLLATE Latin1_General_CI_AS
			,TGT.[Typ]                         = SRC.[Typ]                              COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_Groessenzuschlag]     = SRC.[TapKey_Groessenzuschlag]          COLLATE Latin1_General_CI_AS
			,TGT.[Groessenzuschlag]            = SRC.[Groessenzuschlag]                 COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_LiefTerm]             = SRC.[TapKey_LiefTerm]                  COLLATE Latin1_General_CI_AS
			,TGT.[LiefTerm]                    = SRC.[LiefTerm]                         COLLATE Latin1_General_CI_AS
			,TGT.[TerminVon]                   = SRC.[TerminVon]                        
			,TGT.[TerminBis]                   = SRC.[TerminBis]                        
			,TGT.[TapKey_Lagerort]             = SRC.[TapKey_Lagerort]                  COLLATE Latin1_General_CI_AS
			,TGT.[Lagerort]                    = SRC.[Lagerort]                         COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_Etikett]              = SRC.[TapKey_Etikett]                   COLLATE Latin1_General_CI_AS
			,TGT.[Etikett]                     = SRC.[Etikett]                          COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_Aufmachung]           = SRC.[TapKey_Aufmachung]                COLLATE Latin1_General_CI_AS
			,TGT.[Aufmachung]                  = SRC.[Aufmachung]                       COLLATE Latin1_General_CI_AS
			,TGT.[KuArtikelNr]                 = SRC.[KuArtikelNr]                      COLLATE Latin1_General_CI_AS
			,TGT.[KuFarbNr]                    = SRC.[KuFarbNr]                         COLLATE Latin1_General_CI_AS
			,TGT.[Bemerkung]                   = SRC.[Bemerkung]                        COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_RetourGrund]          = SRC.[TapKey_RetourGrund]               COLLATE Latin1_General_CI_AS
			,TGT.[RetourGrund]                 = SRC.[RetourGrund]                      COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_RetourText]           = SRC.[TapKey_RetourText]                COLLATE Latin1_General_CI_AS
			,TGT.[RetourText]                  = SRC.[RetourText]                       COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_StornoGrund]          = SRC.[TapKey_StornoGrund]               COLLATE Latin1_General_CI_AS
			,TGT.[StornoGrund]                 = SRC.[StornoGrund]                      COLLATE Latin1_General_CI_AS
			,TGT.[TapKey_StornoText]           = SRC.[TapKey_StornoText]                COLLATE Latin1_General_CI_AS
			,TGT.[StornoText]                  = SRC.[StornoText]                       COLLATE Latin1_General_CI_AS
			,TGT.[RefAufPNr]                   = SRC.[RefAufPNr]                        
			,TGT.[RefOrderBlatt]               = SRC.[RefOrderBlatt]                    
			,TGT.[BezugAufkNr]                 = SRC.[BezugAufkNr]                      
			,TGT.[BezugAufkKey]                = SRC.[BezugAufkKey]                     COLLATE Latin1_General_CI_AS
			,TGT.[BezugOrderBlatt]             = SRC.[BezugOrderBlatt]                  
			,TGT.[BezugAufPNr]                 = SRC.[BezugAufPNr]                      
			,TGT.[BasisAufkNr]                 = SRC.[BasisAufkNr]                      
			,TGT.[BasisAufkKey]                = SRC.[BasisAufkKey]                     COLLATE Latin1_General_CI_AS
			,TGT.[BasisOrderBlat]              = SRC.[BasisOrderBlat]                   
			,TGT.[BasisAufPNr]                 = SRC.[BasisAufPNr]                      
			,TGT.[BasisKuADatum]               = SRC.[BasisKuADatum]                    
			,TGT.[BasisKundenAufNr]            = SRC.[BasisKundenAufNr]                 COLLATE Latin1_General_CI_AS
			,TGT.[Neu]                         = SRC.[Neu]                              
			,TGT.[Wer]                         = SRC.[Wer]                              COLLATE Latin1_General_CI_AS
			,TGT.[Wann]                        = SRC.[Wann]                             
			,TGT.[WKLfd]                       = SRC.[WKLfd]                            
			,TGT.[ZuteilungsNr]                = SRC.[ZuteilungsNr]                     
			,TGT.[OffenJN]                     = SRC.[OffenJN]                          COLLATE Latin1_General_CI_AS
			,TGT.[Um]                          = SRC.[Um]                               
			,TGT.[ConfDelDate]                 = SRC.[ConfDelDate]                      COLLATE Latin1_General_CI_AS
			,TGT.[LastConfDelDate]             = SRC.[LastConfDelDate]                  COLLATE Latin1_General_CI_AS
			,TGT.[AgreedChangeDate]            = SRC.[AgreedChangeDate]                 
			,TGT.[AgreedChangeDateGTab]        = SRC.[AgreedChangeDateGTab]             COLLATE Latin1_General_CI_AS
			,TGT.[AgreedChangeDateGeaendertJN] = SRC.[AgreedChangeDateGeaendertJN]      COLLATE Latin1_General_CI_AS
	WHEN NOT MATCHED BY TARGET THEN INSERT ( [AufkNr], [AufkKey], [OrderBlatt], [AufPNr], [KusNr], [KustKey], [ArtsNr1], [ArtsNr2], [ArtsKey], [VerkFarbe], [TapKey_Artgrp], [ArtGrp], [ComposeeKz], [TapKey_Art], [Art], [Om], [Sm], [Em], [Km], [Lm], [Fm], [EPrFW], [OPrFW], [EPrDM], [OPrDM], [Rabatt], [V1_VersNr], [V1_VersKey], [V2_VersNr], [V2_VersKey], [ProviV1], [ProviV2], [TapKey_PreisAbweichGrund], [PreisAbweichGrund], [TapKey_ProdGrp], [ProdGrp], [TapKey_Typ], [Typ], [TapKey_Groessenzuschlag], [Groessenzuschlag], [TapKey_LiefTerm], [LiefTerm], [TerminVon], [TerminBis], [TapKey_Lagerort], [Lagerort], [TapKey_Etikett], [Etikett], [TapKey_Aufmachung], [Aufmachung], [KuArtikelNr], [KuFarbNr], [Bemerkung], [TapKey_RetourGrund], [RetourGrund], [TapKey_RetourText], [RetourText], [TapKey_StornoGrund], [StornoGrund], [TapKey_StornoText], [StornoText], [RefAufPNr], [RefOrderBlatt], [BezugAufkNr], [BezugAufkKey], [BezugOrderBlatt], [BezugAufPNr], [BasisAufkNr], [BasisAufkKey], [BasisOrderBlat], [BasisAufPNr], [BasisKuADatum], [BasisKundenAufNr], [Neu], [Wer], [Wann], [WKLfd], [ZuteilungsNr], [OffenJN], [Um], [ConfDelDate], [LastConfDelDate], [AgreedChangeDate], [AgreedChangeDateGTab], [AgreedChangeDateGeaendertJN] )   VALUES ( SRC.[AufkNr], SRC.[AufkKey], SRC.[OrderBlatt], SRC.[AufPNr], SRC.[KusNr], SRC.[KustKey], SRC.[ArtsNr1], SRC.[ArtsNr2], SRC.[ArtsKey], SRC.[VerkFarbe], SRC.[TapKey_Artgrp], SRC.[ArtGrp], SRC.[ComposeeKz], SRC.[TapKey_Art], SRC.[Art], SRC.[Om], SRC.[Sm], SRC.[Em], SRC.[Km], SRC.[Lm], SRC.[Fm], SRC.[EPrFW], SRC.[OPrFW], SRC.[EPrDM], SRC.[OPrDM], SRC.[Rabatt], SRC.[V1_VersNr], SRC.[V1_VersKey], SRC.[V2_VersNr], SRC.[V2_VersKey], SRC.[ProviV1], SRC.[ProviV2], SRC.[TapKey_PreisAbweichGrund], SRC.[PreisAbweichGrund], SRC.[TapKey_ProdGrp], SRC.[ProdGrp], SRC.[TapKey_Typ], SRC.[Typ], SRC.[TapKey_Groessenzuschlag], SRC.[Groessenzuschlag], SRC.[TapKey_LiefTerm], SRC.[LiefTerm], SRC.[TerminVon], SRC.[TerminBis], SRC.[TapKey_Lagerort], SRC.[Lagerort], SRC.[TapKey_Etikett], SRC.[Etikett], SRC.[TapKey_Aufmachung], SRC.[Aufmachung], SRC.[KuArtikelNr], SRC.[KuFarbNr], SRC.[Bemerkung], SRC.[TapKey_RetourGrund], SRC.[RetourGrund], SRC.[TapKey_RetourText], SRC.[RetourText], SRC.[TapKey_StornoGrund], SRC.[StornoGrund], SRC.[TapKey_StornoText], SRC.[StornoText], SRC.[RefAufPNr], SRC.[RefOrderBlatt], SRC.[BezugAufkNr], SRC.[BezugAufkKey], SRC.[BezugOrderBlatt], SRC.[BezugAufPNr], SRC.[BasisAufkNr], SRC.[BasisAufkKey], SRC.[BasisOrderBlat], SRC.[BasisAufPNr], SRC.[BasisKuADatum], SRC.[BasisKundenAufNr], SRC.[Neu], SRC.[Wer], SRC.[Wann], SRC.[WKLfd], SRC.[ZuteilungsNr], SRC.[OffenJN], SRC.[Um], SRC.[ConfDelDate], SRC.[LastConfDelDate], SRC.[AgreedChangeDate], SRC.[AgreedChangeDateGTab], SRC.[AgreedChangeDateGeaendertJN] )
	WHEN NOT MATCHED BY SOURCE THEN DELETE;
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
--#endregion AufPosi

--#region AufGroesse

	--AufGroesse
	SET @curObject = 'AufGroesse Merge'
/*	INSERT INTO [dbo].[INTEX_RAW_AufGroesse]
		(
			 [AufkKey]
			,[AufkNr]
			,[OrderBlatt]
			,[AufPNr]
			,[GGanKey]
			,[GGNr]
			,[Gr]
			,[Om]
			,[Sm]
			,[Em]
			,[Km]
			,[Lm]
			,[Fm]
			,[Neu]
			,[Wer]
			,[Wann]
			,[EDIKuPosNr]
			,[Um]
		)
	SELECT
		 [AufkKey]
		,[AufkNr]
		,[OrderBlatt]
		,[AufPNr]
		,[GGanKey]
		,[GGNr]
		,[Gr]
		,[Om]
		,[Sm]
		,[Em]
		,[Km]
		,[Lm]
		,[Fm]
		,[Neu]
		,[Wer]
		,[Wann]
		,[EDIKuPosNr]
		,[Um]
	FROM [SQLINTEX].[OdloDE].[dbo].[AufGroesse] ag WITH(READPAST)
	WHERE ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)*/
		MERGE [dbo].[INTEX_RAW_AufGroesse] AS TGT
	USING 
		(SELECT
		  [AufkKey], [AufkNr], [OrderBlatt], [AufPNr], [GGanKey], [GGNr], [Gr], [Om], [Sm], [Em], [Km], [Lm], [Fm], [Neu], [Wer], [Wann], [EDIKuPosNr], [Um]
	FROM [SQLINTEX].[OdloDE].[dbo].[AufGroesse] ag WITH(READPAST)
	WHERE ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)) AS SRC
		ON ( 
					SRC.[AufkKey]    = TGT.[AufkKey]     COLLATE Latin1_General_CI_AS
				AND SRC.[AufkNr]     = TGT.[AufkNr]      
				AND SRC.[OrderBlatt] = TGT.[OrderBlatt]  
				AND SRC.[AufPNr]     = TGT.[AufPNr]      
				AND SRC.[GGanKey]    = TGT.[GGanKey]     COLLATE Latin1_General_CI_AS
				AND SRC.[GGNr]       = TGT.[GGNr]        
				AND SRC.[Gr]         = TGT.[Gr]          COLLATE Latin1_General_CI_AS
			)
		WHEN MATCHED AND (TGT.Wann != SRC.Wann)
		THEN UPDATE SET 
				 TGT.[Om]         = SRC.[Om]         
				,TGT.[Sm]         = SRC.[Sm]         
				,TGT.[Em]         = SRC.[Em]         
				,TGT.[Km]         = SRC.[Km]         
				,TGT.[Lm]         = SRC.[Lm]         
				,TGT.[Fm]         = SRC.[Fm]         
				,TGT.[Neu]        = SRC.[Neu]        
				,TGT.[Wer]        = SRC.[Wer]        
				,TGT.[Wann]       = SRC.[Wann]       
				,TGT.[EDIKuPosNr] = SRC.[EDIKuPosNr] 
				,TGT.[Um]         = SRC.[Um]         
	WHEN NOT MATCHED BY TARGET THEN INSERT ( [AufkKey], [AufkNr], [OrderBlatt], [AufPNr], [GGanKey], [GGNr], [Gr], [Om], [Sm], [Em], [Km], [Lm], [Fm], [Neu], [Wer], [Wann], [EDIKuPosNr], [Um] )   VALUES ( SRC.[AufkKey], SRC.[AufkNr], SRC.[OrderBlatt], SRC.[AufPNr], SRC.[GGanKey], SRC.[GGNr], SRC.[Gr], SRC.[Om], SRC.[Sm], SRC.[Em], SRC.[Km], SRC.[Lm], SRC.[Fm], SRC.[Neu], SRC.[Wer], SRC.[Wann], SRC.[EDIKuPosNr], SRC.[Um] )
	WHEN NOT MATCHED BY SOURCE THEN DELETE;
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
--#endregion AufGroesse


	--#endregion Fill the RAW Tables
*/

-- initiate the refresh of the relevant transactional data:
	SET @curObject = 'sp_LoadMoreOftenCacheData'
	EXEC [IFC_Cache].dbo.sp_LoadMoreOftenCacheData 0
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': ' + @curObject
		END
	SET @Start = getdate()
	--BEGIN TRANSACTION  
	/***************************************************************************************************/
	/************************ get all ean combinations per season **************************************/
	/***************************************************************************************************/
	SET @curObject = 'iV_IN_hlp_ean'
	INSERT INTO [dbo].[iV_IN_hlp_ean] (
			 [SupplierCatalogKey]
			,[SeasonDefault]
			,[SKU]
			,[EAN]
			,[AvailableCheck_dt]
			,[Available_dt]
			,[OriginCountry]
			,[OriginRegion]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                   AS [SupplierCatalogKey]
		,tp.[defaultjn]                                                                 AS [SeasonDefault]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                            AS [EAN]
		,CONVERT(VARCHAR(10),[VerfuegbarAb] , 112)                                      AS [AvailableCheck_dt]
		,CONVERT(VARCHAR(10),[LieferbarAb] , 112)                                       AS [Available_dt]
		,al.Ursprung                                                                    AS [OriginCountry]
		,reg.CountryRegion                                                              AS [OriginRegion]
		,getDate()                                                                      AS [LOAD_DATE]
	FROM                INTEX_RAW_ArtEAN                     ean WITH(READPAST)
		--JOIN            INTEX_RAW_ArtFarben                  af WITH(READPAST)  ON af.[ArtsKey] = ean.[ArtsKey]
		JOIN            [IFC_Cache].[dbo].[ArtFarben]                  af WITH(READPAST)  ON af.[ArtsKey] = ean.[ArtsKey]
			AND af.[ArtsNr1] = ean.[ArtsNr1]
			AND af.[ArtsNr2] = ean.[ArtsNr2]
			AND af.[VerkFarbe] = ean.[VerkFarbe]
		--JOIN            INTEX_RAW_ArtLieferant               al WITH(READPAST)  ON al.ArtsKey = ean.ArtsKey
		JOIN            [IFC_Cache].[dbo].[ArtLieferant]               al WITH(READPAST)  ON al.ArtsKey = ean.ArtsKey
			AND al.ArtsNr2 = ean.ArtsNr2
			AND al.ArtsNr1 = ean.ArtsNr1
			AND al.ArtsKey = af.ArtsKey
			AND al.ArtsNr2 = af.ArtsNr2
			AND al.ArtsNr1 = af.ArtsNr1
		--JOIN            INTEX_RAW_ArtStamm                   ArtS               ON ArtS.[ArtsKey] = af.[ArtsKey]
		JOIN            [IFC_Cache].[dbo].[ArtStamm]                   ArtS               ON ArtS.[ArtsKey] = af.[ArtsKey]
			AND ArtS.[ArtsNr1] = af.[ArtsNr1]
			AND ArtS.[ArtsNr2] = af.[ArtsNr2]
			AND ArtS.ArtsKey = ean.ArtsKey
			AND ArtS.ArtsNr2 = ean.ArtsNr2
			AND ArtS.ArtsNr1 = ean.ArtsNr1
			AND ArtS.ArtsKey = af.ArtsKey
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.[GGanKey] = ean.[GGanKey]
			AND ArtS.[GGNr] = ean.[GGNr]
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_CountryRegion]      reg                ON (reg.country COLLATE SQL_Latin1_General_CP1_CS_AS = al.Ursprung)
		--LEFT OUTER JOIN [SQLINTEX].[OdloDE].[dbo].[TaPosi] tp WITH(READPAST)  ON (tp.tanr = 3 AND tp.tapkey = '011' AND SUBSTRING(ArtS.[ArtsKey], 4, 3)  = tp.[tpwert] COLLATE SQL_Latin1_General_CP1_CS_AS)
		LEFT OUTER JOIN [IFC_Cache].[dbo].[TaPosi] tp WITH(READPAST)  ON (tp.tanr = 3 AND tp.tapkey = '011' AND SUBSTRING(ArtS.[ArtsKey], 4, 3)  = tp.[tpwert] COLLATE SQL_Latin1_General_CP1_CS_AS)
	WHERE al.HauptLieferantJN = 'J'
		--- added 04.08.2016/cls to avoid hardcoded seasons
		---AND ArtS.[ArtsKey] IN ('011161H','011162H','011171H')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION

	/***************************************************************************************************/
	/********************************** get free stock per season **************************************/
	/***************************************************************************************************/
	--one select with two warehouses
	/***************************************************************************************************/
	--BEGIN TRANSACTION
	SET @curObject = 'iV_IN_hlp_FeLa'
	INSERT INTO [dbo].[iV_IN_hlp_FeLa] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[Inventory]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(lg.[ArtsKey]))                                                     AS [SupplierCatalogKey]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                            AS [EAN]
		,lg.LagerOrt                                                                    AS [InventorySource_cd]
		,lg.[Bestand]                                                                   AS [Inventory]
		,getDate()                                                                      AS [LOAD_DATE]
--	FROM     [SQLINTEX].[OdloDE].[dbo].[FeLager] lg  WITH(READPAST) 
	FROM     [IFC_Cache].[dbo].[FeLager] lg  WITH(READPAST) 
		JOIN INTEX_RAW_ArtEAN                    ean WITH(READPAST) ON ean.[ArtsKey] = lg.[ArtsKey] COLLATE SQL_Latin1_General_CP1_CS_AS
			AND ean.[ArtsNr1] = lg.[ArtsNr1] COLLATE SQL_Latin1_General_CP1_CS_AS
			AND ean.[ArtsNr2] = lg.[ArtsNr2] COLLATE SQL_Latin1_General_CP1_CS_AS
			AND ean.[VerkFarbe] = lg.[VerkFarbe] COLLATE SQL_Latin1_General_CP1_CS_AS
			AND ean.[GGanKey] = lg.[GGanKey] COLLATE SQL_Latin1_General_CP1_CS_AS
			AND ean.[GGNr] = lg.[GGNr]
			AND ean.[Gr] = lg.[Gr] COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE lg.LagKey = '01'
		AND lg.LagerOrt IN ('800','0CA')
		AND lg.Bestand > 0
		AND lg.[Etikett] = '000'
		---AND lg.[ArtsKey] IN ('011161H','011162H','011171H')
		---AND ean.[ArtsKey] IN ('011161H','011162H','011171H') -- add season restriction to each table due to performance reasons!!!
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND lg.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION

	/***************************************************************************************************/
	/***************************** get all open orders per season **************************************/
	/***************************************************************************************************/
	--first insert reorder for stock 800
	--second insert reorder for stock 0ca
	--third insert preorder1 for stock 800
	--fourth insert preorder1 for stock 0ca
	--fifth insert preorder2 for stock 800
	--sixth insert preorder2 for stock 0ca
	--doing it complex, stock location by stock location due to performance issues
	--> Change JRU 23.08.2017 
	--> Due to the change by using local cache tables we can do it at once with no additional impact to the live INTEX DB
	/***************************************************************************************************/
	--BEGIN TRANSACTION
	--Reorder
	--stock 800 - reorder - orders
	SET @curObject = 'iV_IN_hlp_Order stock 800 & 0CA - reorder - orders'
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_order_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                         AS [EAN]
		,ap.LagerOrt                                                                 AS [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km)                                          AS [open_order_QTY]
		,getDate()                                                                   AS [LOAD_DATE]
	--FROM                INTEX_RAW_AufKopf    ak  
		--JOIN            INTEX_RAW_AufPosi    ap  ON (
	FROM                 [IFC_Cache].[dbo].[AufKopf]    ak  
		JOIN             [IFC_Cache].[dbo].[AufPosi]    ap  ON (
				ak.AufkNr = ap.AufkNr
			AND ak.AufkKey = ap.AufkKey
			)
		--JOIN            INTEX_RAW_AufGroesse ag   ON(
		JOIN             [IFC_Cache].[dbo].[AufGroesse] ag   ON(
				ag.AufkNr     = ak.AufkNr
			AND ag.AufkKey    = ak.AufkKey
			AND ag.AufkNr     = ap.AufkNr
			AND ag.AufkKey    = ap.AufkKey
			AND ag.OrderBlatt = ap.OrderBlatt
			AND ag.AufPNr     = ap.AufPNr
			)
		--LEFT OUTER JOIN INTEX_RAW_TpSteu     art ON (
		LEFT OUTER JOIN  [IFC_Cache].[dbo].[TpSteu]     art ON (
				art.tanr     = 41
			AND art.lfd      = 14 -- Steuerung for Lager-Relevante Auftragsarten
			AND art.[tapkey] = ak.[TapKey_Art]
			AND art.[tpwert] = ak.Art
			)
		--JOIN            INTEX_RAW_ArtFarben  af   ON (
		JOIN             [IFC_Cache].[dbo].[ArtFarben]  af   ON (
				af.ArtsNr1   = ap.ArtsNr1
			AND af.ArtsNr2   = ap.ArtsNr2
			AND af.ArtsKey   = ap.ArtsKey
			AND af.VerkFarbe = ap.VerkFarbe
			)
		--JOIN            INTEX_RAW_ArtStamm   ArtS ON (
		JOIN             [IFC_Cache].[dbo].[ArtStamm]   ArtS ON (
				ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		--LEFT OUTER JOIN INTEX_RAW_TpSteu     div  ON (
		LEFT OUTER JOIN  [IFC_Cache].[dbo].[TpSteu]     div  ON (
			div.tanr                 = 600
			AND div.lfd              = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu]        = div.tpwert
			)
		JOIN            INTEX_RAW_ArtEAN     ean  ON (
				ean.ArtsNr1   = af.ArtsNr1
			AND ean.ArtsNr2   = af.ArtsNr2
			AND ean.ArtsKey   = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.VerkFarbe = ap.VerkFarbe 
			AND ean.ArtsNr1   = ap.ArtsNr1
			AND ean.ArtsNr2   = ap.ArtsNr2
			AND ean.ArtsKey   = ap.ArtsKey
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr]    = ArtS.[GGNr]
			AND ean.ArtsKey   = ak.AufkKey
			AND ean.Gr        = ag.Gr
			) 
		--LEFT OUTER JOIN INTEX_RAW_GGaGr      gg   ON (
		LEFT OUTER JOIN  [IFC_Cache].[dbo].[GGaGr]      gg   ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE   div.stwert = 'SALES'
		AND art.[stwert] = 'J' -- Steuerung for Lager-Relevante Auftragsarten
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt IN ('800', '0CA')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)-- WHERE SeasonType='REAS')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)-- WHERE SeasonType='REAS')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)-- WHERE SeasonType='REAS')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)-- WHERE SeasonType='REAS')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)-- WHERE SeasonType='REAS')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)-- WHERE SeasonType='REAS')
	GROUP BY ArtS.[ArtsKey]
	,        ap.ArtsNr1
	,        ap.VerkFarbe
	,        ag.Gr
	,        ean.EANCode
	,        ap.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

/*  JRU 23.08.2017: Decativated, since we do it all at once 
	--stock 0CA - reorder - orders
	SET @curObject = 'iV_IN_hlp_Order stock 0CA - reorder - orders'
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_order_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                         AS [EAN]
		,ap.LagerOrt                                                                 AS [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km)                                          AS [open_order_QTY]
		,getDate()                                                                   AS [LOAD_DATE]
	FROM                INTEX_RAW_AufKopf             ak --WITH(READPAST)
		JOIN            INTEX_RAW_AufPosi             ap   ON  (
				ak.AufkNr       = ap.AufkNr
			AND ak.AufkKey      = ap.AufkKey
			) 
		JOIN            INTEX_RAW_AufGroesse          ag   ON (
				ap.AufkNr       = ag.AufkNr
			AND ap.AufkKey      = ag.AufkKey
			AND ap.OrderBlatt   = ag.OrderBlatt
			AND ap.AufPNr       = ag.AufPNr
			)
		JOIN            INTEX_RAW_ArtStamm            ArtS  ON (
				ArtS.ArtsNr1  = ap.ArtsNr1
			AND ArtS.ArtsNr2  = ap.ArtsNr2
			AND ArtS.ArtsKey  = ap.ArtsKey
			)
		JOIN            INTEX_RAW_ArtEAN              ean  ON (
				ean.ArtsNr1   = ap.ArtsNr1
			AND ean.ArtsNr2   = ap.ArtsNr2
			AND ean.ArtsKey   = ap.ArtsKey
			AND ean.VerkFarbe = ap.VerkFarbe
			AND ean.ArtsNr1   = ArtS.ArtsNr1
			AND ean.ArtsNr2   = ArtS.ArtsNr2
			AND ean.ArtsKey   = ArtS.ArtsKey
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr]    = ArtS.[GGNr]
			AND ean.Gr        = ag.Gr
			)		
		LEFT OUTER JOIN INTEX_RAW_TpSteu              art  ON (
				art.tanr        = 41
			AND art.lfd         = 14 -- Steuerung for Lager-Relevante Auftragsarten
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art          = art.[tpwert]
			)
		JOIN            INTEX_RAW_ArtFarben           af   ON (
			    af.ArtsNr1      = ap.ArtsNr1
			AND af.ArtsNr2      = ap.ArtsNr2
			AND af.ArtsKey      = ap.ArtsKey
			AND af.VerkFarbe    = ap.VerkFarbe

			AND af.ArtsNr1      = ArtS.ArtsNr1
			AND af.ArtsNr2      = ArtS.ArtsNr2
			AND af.ArtsKey      = ArtS.ArtsKey

			AND af.ArtsNr1      = ean.ArtsNr1
			AND af.ArtsNr2      = ean.ArtsNr2
			AND af.ArtsKey      = ean.ArtsKey
			AND af.VerkFarbe    = ean.VerkFarbe
			)
		LEFT OUTER JOIN INTEX_RAW_TpSteu              div  ON (
				div.tanr        = 600
			AND div.lfd         = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu]   = div.tpwert
			)
		LEFT OUTER JOIN INTEX_RAW_GGaGr               gg   ON (
				gg.GGanKey      = ean.GGanKey
			AND gg.GGNr         = ean.GGNr
			AND gg.Gr           = ean.Gr
			)
	WHERE   div.stwert   = 'SALES'
		AND art.[stwert] = 'J' -- Steuerung for Lager-Relevante Auftragsarten
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt = ('0CA')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='REAS')
	GROUP BY ArtS.[ArtsKey]
	,        ap.ArtsNr1
	,        ap.VerkFarbe
	,        ag.Gr
	,        ean.EANCode
	,        ap.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--COMMIT TRANSACTION
*/
/*  JRU 23.08.2017: Decativated, since we do it all at once
	--BEGIN TRANSACTION
	--PREO 1 SEASON
	--stock 800 - preorder 1 - orders
	SET @curObject = 'iV_IN_hlp_Order PREO 1 SEASON stock 800 - preorder 1 - orders'
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_order_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                         AS [EAN]
		,ap.LagerOrt                                                                 AS [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km)                                          AS [open_order_QTY]
		,getDate()                                                                   AS [LOAD_DATE]
	FROM                INTEX_RAW_AufKopf    ak  
		JOIN            INTEX_RAW_AufPosi    ap  ON (
				ak.AufkNr = ap.AufkNr
			AND ak.AufkKey = ap.AufkKey
			)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     art ON (
			art.tanr = 41
			AND art.lfd = 14 -- Steuerung for Lager-Relevante Auftragsarten
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		JOIN            INTEX_RAW_AufGroesse ag   ON(
				ap.AufkNr = ag.AufkNr
			AND ap.AufkKey = ag.AufkKey
			AND ap.OrderBlatt = ag.OrderBlatt
			AND ap.AufPNr = ag.AufPNr
			)
		JOIN            INTEX_RAW_ArtFarben  af   ON (
				af.ArtsNr1 = ap.ArtsNr1
			AND af.ArtsNr2 = ap.ArtsNr2
			AND af.ArtsKey = ap.ArtsKey
			)
		JOIN            INTEX_RAW_ArtStamm   ArtS ON (
				ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     div  ON (
			div.tanr                 = 600
			AND div.lfd              = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu]        = div.tpwert
			)
		JOIN            INTEX_RAW_ArtEAN     ean  ON (
				ean.ArtsNr1   = af.ArtsNr1
			AND ean.ArtsNr2   = af.ArtsNr2
			AND ean.ArtsKey   = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.VerkFarbe = ap.VerkFarbe 
			AND ean.ArtsNr1   = ap.ArtsNr1
			AND ean.ArtsNr2   = ap.ArtsNr2
			AND ean.ArtsKey   = ap.ArtsKey
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr]    = ArtS.[GGNr]
			AND ean.ArtsKey   = ak.AufkKey
			AND ean.Gr        = ag.Gr
			) 
		LEFT OUTER JOIN INTEX_RAW_GGaGr      gg   ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE   div.stwert = 'SALES'
		AND art.[stwert] = 'J' -- Steuerung for Lager-Relevante Auftragsarten
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt IN ('800', '0CA')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
	GROUP BY ArtS.[ArtsKey]
	,        ap.ArtsNr1
	,        ap.VerkFarbe
	,        ag.Gr
	,        ean.EANCode
	,        ap.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
*/

/*  JRU 23.08.2017: Decativated, since we do it all at once
	--stock 0CA - preorder 1 - orders
	SET @curObject = 'iV_IN_hlp_Order PREO 1 SEASON stock 0CA - reorder - orders'
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_order_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                         AS [EAN]
		,ap.LagerOrt                                                                 AS [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km)                                          AS [open_order_QTY]
		,getDate()                                                                   AS [LOAD_DATE]
	FROM                INTEX_RAW_AufGroesse ag WITH(READPAST)  
		,               INTEX_RAW_AufKopf    ak WITH(READPAST)  
		LEFT OUTER JOIN INTEX_RAW_TpSteu     art                 ON (
			art.tanr = 41
			AND art.lfd = 14
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		,               INTEX_RAW_AufPosi    ap WITH(READPAST)  
		,               INTEX_RAW_ArtFarben  af WITH(READPAST)  
		,               INTEX_RAW_ArtStamm   ArtS WITH(READPAST)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     div                 ON (
			div.tanr = 600
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
		,               INTEX_RAW_ArtEAN     ean WITH(READPAST) 
		LEFT OUTER JOIN INTEX_RAW_GGaGr      gg                  ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE (
		ak.AufkNr = ap.AufkNr
		AND ak.AufkKey = ap.AufkKey
		)
		AND (
		ap.AufkNr = ag.AufkNr
		AND ap.AufkKey = ag.AufkKey
		AND ap.OrderBlatt = ag.OrderBlatt
		AND ap.AufPNr = ag.AufPNr
		)
		AND (
		ArtS.ArtsNr1 = af.ArtsNr1
		AND ArtS.ArtsNr2 = af.ArtsNr2
		AND ArtS.ArtsKey = af.ArtsKey
		)
		AND (
		ean.ArtsNr1 = af.ArtsNr1
		AND ean.ArtsNr2 = af.ArtsNr2
		AND ean.ArtsKey = af.ArtsKey
		AND ean.VerkFarbe = af.VerkFarbe
		AND ean.[GGanKey] = ArtS.[GGanKey]
		AND ean.[GGNr] = ArtS.[GGNr]
		)
		AND ap.ArtsNr1 = ean.ArtsNr1
		AND ap.VerkFarbe = ean.VerkFarbe
		AND ag.Gr = ean.Gr
		AND ean.ArtsKey = ak.AufkKey
		AND div.stwert = 'SALES'
		AND art.[stwert] = 'J'
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt = ('0CA')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO1')
	GROUP BY ArtS.[ArtsKey]
	,        ap.ArtsNr1
	,        ap.VerkFarbe
	,        ag.Gr
	,        ean.EANCode
	,        ap.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
	--COMMIT TRANSACTION
*/

/*  JRU 23.08.2017: Decativated, since we do it all at once
	--BEGIN TRANSACTION
	-- PREO 2 SEASON
	--stock 800 - preorder 2 - orders
	SET @curObject = 'iV_IN_hlp_Order PREO 2 SEASON stock 800 - reorder - orders'
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_order_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                         AS [EAN]
		,ap.LagerOrt                                                                 AS [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km)                                          AS [open_order_QTY]
		,getDate()                                                                   AS [LOAD_DATE]
	FROM                INTEX_RAW_AufKopf    ak  
		JOIN            INTEX_RAW_AufPosi    ap  ON (
				ak.AufkNr = ap.AufkNr
			AND ak.AufkKey = ap.AufkKey
			)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     art ON (
			art.tanr = 41
			AND art.lfd = 14 -- Steuerung for Lager-Relevante Auftragsarten
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		JOIN            INTEX_RAW_AufGroesse ag   ON(
				ap.AufkNr = ag.AufkNr
			AND ap.AufkKey = ag.AufkKey
			AND ap.OrderBlatt = ag.OrderBlatt
			AND ap.AufPNr = ag.AufPNr
			)
		JOIN            INTEX_RAW_ArtFarben  af   ON (
				af.ArtsNr1 = ap.ArtsNr1
			AND af.ArtsNr2 = ap.ArtsNr2
			AND af.ArtsKey = ap.ArtsKey
			)
		JOIN            INTEX_RAW_ArtStamm   ArtS ON (
				ArtS.ArtsNr1 = af.ArtsNr1
			AND ArtS.ArtsNr2 = af.ArtsNr2
			AND ArtS.ArtsKey = af.ArtsKey
			)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     div  ON (
			div.tanr                 = 600
			AND div.lfd              = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu]        = div.tpwert
			)
		JOIN            INTEX_RAW_ArtEAN     ean  ON (
				ean.ArtsNr1   = af.ArtsNr1
			AND ean.ArtsNr2   = af.ArtsNr2
			AND ean.ArtsKey   = af.ArtsKey
			AND ean.VerkFarbe = af.VerkFarbe
			AND ean.VerkFarbe = ap.VerkFarbe 
			AND ean.ArtsNr1   = ap.ArtsNr1
			AND ean.ArtsNr2   = ap.ArtsNr2
			AND ean.ArtsKey   = ap.ArtsKey
			AND ean.[GGanKey] = ArtS.[GGanKey]
			AND ean.[GGNr]    = ArtS.[GGNr]
			AND ean.ArtsKey   = ak.AufkKey
			AND ean.Gr        = ag.Gr
			) 
		LEFT OUTER JOIN INTEX_RAW_GGaGr      gg   ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE   div.stwert = 'SALES'
		AND art.[stwert] = 'J' -- Steuerung for Lager-Relevante Auftragsarten
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt IN ('800', '0CA')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
	GROUP BY ArtS.[ArtsKey]
	,        ap.ArtsNr1
	,        ap.VerkFarbe
	,        ag.Gr
	,        ean.EANCode
	,        ap.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
*/

/*  JRU 23.08.2017: Decativated, since we do it all at once
	--stock 0CA - preorder 2 - orders
	SET @curObject = 'iV_IN_hlp_Order PREO 2 SEASON stock 0CA - reorder - orders'
	INSERT INTO [dbo].[iV_IN_hlp_Order] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_order_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(ArtS.[ArtsKey]))                                                AS [SupplierCatalogKey]
		,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                         AS [EAN]
		,ap.LagerOrt                                                                 AS [InventorySource_cd]
		,sum(ag.Om - ag.Sm - ag.Em - ag.Km)                                          AS [open_order_QTY]
		,getDate()                                                                   AS [LOAD_DATE]
	FROM                INTEX_RAW_AufGroesse ag --WITH(READPAST)
		,               INTEX_RAW_AufKopf    ak --WITH(READPAST)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     art                 ON (
			art.tanr = 41
			AND art.lfd = 14
			AND ak.[TapKey_Art] = art.[tapkey]
			AND ak.Art = art.[tpwert]
			)
		,               INTEX_RAW_AufPosi    ap WITH(READPAST)  
		,               INTEX_RAW_ArtFarben  af WITH(READPAST)  
		,               INTEX_RAW_ArtStamm   ArtS WITH(READPAST)
		LEFT OUTER JOIN INTEX_RAW_TpSteu     div                 ON (
			div.tanr = 600
			AND div.lfd = 205
			AND ArtS.[TapKey_DivNeu] = div.[tapkey]
			AND ArtS.[DivNeu] = div.tpwert
			)
		,               INTEX_RAW_ArtEAN     ean WITH(READPAST) 
		LEFT OUTER JOIN INTEX_RAW_GGaGr      gg                  ON (
			gg.GGanKey = ean.GGanKey
			AND gg.GGNr = ean.GGNr
			AND gg.Gr = ean.Gr
			)
	WHERE (
		ak.AufkNr = ap.AufkNr
		AND ak.AufkKey = ap.AufkKey
		)
		AND (
		ap.AufkNr = ag.AufkNr
		AND ap.AufkKey = ag.AufkKey
		AND ap.OrderBlatt = ag.OrderBlatt
		AND ap.AufPNr = ag.AufPNr
		)
		AND (
		ArtS.ArtsNr1 = af.ArtsNr1
		AND ArtS.ArtsNr2 = af.ArtsNr2
		AND ArtS.ArtsKey = af.ArtsKey
		)
		AND (
		ean.ArtsNr1 = af.ArtsNr1
		AND ean.ArtsNr2 = af.ArtsNr2
		AND ean.ArtsKey = af.ArtsKey
		AND ean.VerkFarbe = af.VerkFarbe
		AND ean.[GGanKey] = ArtS.[GGanKey]
		AND ean.[GGNr] = ArtS.[GGNr]
		)
		AND ap.ArtsNr1 = ean.ArtsNr1
		AND ap.VerkFarbe = ean.VerkFarbe
		AND ag.Gr = ean.Gr
		AND ean.ArtsKey = ak.AufkKey
		AND div.stwert = 'SALES'
		AND art.[stwert] = 'J'
		AND ag.Om - ag.Sm - ag.Em - ag.Km > 0
		AND ap.LagerOrt = ('0CA')
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ap.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ag.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ean.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND af.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
		AND ArtS.[ArtsKey] IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller WHERE SeasonType='PREO2')
	GROUP BY ArtS.[ArtsKey]
	,        ap.ArtsNr1
	,        ap.VerkFarbe
	,        ag.Gr
	,        ean.EANCode
	,        ap.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()
*/

	--COMMIT TRANSACTION


	--======================================================================================================================
	--********************************** get all open POs per season **************************************
	--one select with two warehouses
	--======================================================================================================================
	--BEGIN TRANSACTION

	SET @curObject = 'iV_IN_hlp_PO'
	INSERT INTO [dbo].[iV_IN_hlp_PO] (
			 [SupplierCatalogKey]
			,[SKU]
			,[EAN]
			,[InventorySource_cd]
			,[open_QTY]
			,[LOAD_DATE]
		)
	SELECT
		 ltrim(rtrim(pok.PakKey))                                                       AS [SupplierCatalogKey]
		,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [SKU]
		,ltrim(rtrim(LEFT(ean.EANCode, 20)))                                            AS [EAN]
		,pok.LagerOrt                                                                   AS [InventorySource_cd]
		,sum(pog.Ip - pog.Sm - pog.Pr - pog.Af)                                         AS [open_QTY]
		,getDate()                                                                      AS [LOAD_DATE]
	--FROM [SQLINTEX].[OdloDE].[dbo].[PaPosi]    pop WITH(READPAST)
	--	,[SQLINTEX].[OdloDE].[dbo].[PaKopf]    pok WITH(READPAST)
	--	,[SQLINTEX].[OdloDE].[dbo].[PaGroesse] pog WITH(READPAST)
	FROM [IFC_Cache].[dbo].[PaPosi]    pop WITH(READPAST)
		,[IFC_Cache].[dbo].[PaKopf]    pok WITH(READPAST)
		,[IFC_Cache].[dbo].[PaGroesse] pog WITH(READPAST)
		,INTEX_RAW_ArtEAN                        ean --WITH(READPAST)
	WHERE pok.LagerOrt IN ('800','0CA')
		----MPFYL 21-FEB-17 - Commented out the below LiefNr
		--AND rtrim(pok.LiefNr) <> '71304'
		AND rtrim(pop.PakNr) <> '3600'
		--MPFYL 21-FEB-17 - Start
		--Only exlucde SMS orders but inlcude Dummy orders
		AND rtrim(pok.Art) NOT IN ('07') --- SMS / Dummy
		--AND rtrim(pok.Art) NOT IN ('07','99') --- SMS / Dummy
		AND (
		pok.PakNr = pop.PakNr
		AND pok.PakKey = pop.PakKey
		)
		AND (
		pop.PakNr = pog.PakNr
		AND pop.PakKey = pog.PakKey
		AND pop.PaPNr = pog.PaPNr
		)
		AND (
		pop.[ArtsKey] = ean.ArtsKey COLLATE SQL_Latin1_General_CP1_CS_AS
		AND pop.[ArtsNr1] = ean.ArtsNr1 COLLATE SQL_Latin1_General_CP1_CS_AS
		AND pop.[ArtsNr2] = ean.ArtsNr2 COLLATE SQL_Latin1_General_CP1_CS_AS
		AND pop.[VerkFarbe] = ean.VerkFarbe COLLATE SQL_Latin1_General_CP1_CS_AS
		)
		AND (
		pog.[GGanKey] = ean.GGanKey COLLATE SQL_Latin1_General_CP1_CS_AS
		AND pog.[GGNr] = ean.GGNr
		AND pog.[Gr] = ean.Gr COLLATE SQL_Latin1_General_CP1_CS_AS
		)
		AND pog.Ip - pog.Sm - pog.Pr - pog.Af > 0
		--- added 04.08.2016/cls to avoid hardcoded seasons
		AND pog.PakKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND ean.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND pok.PakKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND pop.PakKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
	GROUP BY pok.PakKey
	,        ean.ArtsNr1
	,        ean.VerkFarbe
	,        ean.Gr
	,        ean.EANCode
	,        pok.LagerOrt
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()



	--COMMIT TRANSACTION


	--BEGIN TRANSACTION /********************************** ignore negative (überlieferung) and 0 (delivered and already on stock) values in POs **************************************/

	SET @curObject = 'ignore negative (überlieferung) and 0 (delivered and already on stock) values in POs'
	DELETE FROM [dbo].[iV_IN_hlp_PO]
	WHERE [open_QTY] < 1
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--COMMIT TRANSACTION


	--BEGIN TRANSACTION /********************************** ignore delivered orders (0)  **************************************/

	SET @curObject = 'ignore delivered orders (0)'
	DELETE FROM [dbo].[iV_IN_hlp_Order]
	WHERE [open_order_QTY] < 1
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION



	/*********************************************************************************************************************************************/
	/********************************** PREORDER SEASONS (season default = N) + [AvailableCheck_dt] > today **************************************/
	/*********************************************************************************************************************************************/
	--BEGIN TRANSACTION
	--stock 800 - preorder season and future availability check
	SET @curObject = 'stock 800 - preorder season and future availability check'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 [EAN]                AS [UPC]
		,[SKU]               
		,[SKU]                AS [SupplierProductKey]
		,[EAN]               
		,99999               
		,[Available_dt]      
		,[SupplierCatalogKey]
		,'800'                AS [InventorySource_cd]
		,[LOAD_DATE]         
	FROM [dbo].[iV_IN_hlp_ean]
	WHERE [SeasonDefault] = 'N'
		AND [AvailableCheck_dt] > CONVERT(VARCHAR(10), getDate(), 112)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--mpfyl 24/01/17: enhance stock 0CA with different availability dates (0CA is for Canada, so add a couple of days depending if it's EU or 'another continent')
	--stock 0CA - preorder season and future availability check
	SET @curObject = 'stock 0CA - preorder season and future availability check'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 [EAN]                AS [UPC]
		,[SKU]               
		,[SKU]                AS [SupplierProductKey]
		,[EAN]               
		,99999                AS stockQty
		--,[Available_dt]
		,CASE WHEN [OriginRegion] = 'Europe' THEN CONVERT(varchar, dateadd(week,0, CONVERT(date, Available_dt,112)),112)
		                                     ELSE CONVERT(varchar, dateadd(week,0, CONVERT(date, Available_dt,112)),112)
		END                   AS Availability_dt
		,[SupplierCatalogKey]
		,'0CA'                AS [InventorySource_cd]
		,[LOAD_DATE]         
	FROM [dbo].[iV_IN_hlp_ean]
	WHERE [SeasonDefault] = 'N'
		AND [AvailableCheck_dt] > CONVERT(VARCHAR(10), getDate(), 112)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION


	--======================================================================================================================
	/********************************** PREORDER SEASONS (season default = N) + [AvailableCheck_dt] <= today **************************************/
	--======================================================================================================================
	--BEGIN TRANSACTION
	--stock 800 - preorder season and availability check in the past - get stock quantity
	SET @curObject = 'stock 800 - preorder season and availability check in the past - get stock quantity'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 ean.[EAN]                AS [UPC]
		,ean.[SKU]               
		,ean.[SKU]                AS [SupplierProductKey]
		,ean.[EAN]               
		,CASE WHEN [Inventory] IS NULL THEN 0
		                               ELSE [Inventory]
		END +CASE WHEN [open_QTY] IS NULL THEN 0
		                                  ELSE [open_QTY]
		END - CASE WHEN [open_order_QTY] IS NULL THEN 0
		                                         ELSE [open_order_QTY]
		END                      
		,[Available_dt]          
		,ean.[SupplierCatalogKey]
		,'800'                    AS [InventorySource_cd]
		,ean.[LOAD_DATE]         
	FROM                [dbo].[iV_IN_hlp_ean]   ean
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa]  la  ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] AND la.[InventorySource_cd] = '800')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO]    po  ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN] AND po.[InventorySource_cd] = '800')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] AND ord.[InventorySource_cd] = '800')
	WHERE [SeasonDefault] = 'N'
		AND [AvailableCheck_dt] <= CONVERT(VARCHAR(10), getDate(), 112)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()



	--mpfyl 24/01/17: enhance stock 0CA with different availability dates (0CA is for Canada, so add a couple of days depending if it's EU or 'another continent')
	--stock 0CA - preorder season and availability check in the past - get stock quantity
	SET @curObject = 'stock 0CA - preorder season and availability check in the past - get stock quantity'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 ean.[EAN]                AS [UPC]
		,ean.[SKU]               
		,ean.[SKU]                AS [SupplierProductKey]
		,ean.[EAN]               
		,CASE WHEN [Inventory] IS NULL THEN 0
		                               ELSE [Inventory]
		END +CASE WHEN [open_QTY] IS NULL THEN 0
		                                  ELSE [open_QTY]
		END - CASE WHEN [open_order_QTY] IS NULL THEN 0
		                                         ELSE [open_order_QTY]
		END                      
		,CASE WHEN [OriginRegion] = 'Europe' THEN CONVERT(varchar, dateadd(week,0, CONVERT(date, Available_dt,112)),112)
		                                     ELSE CONVERT(varchar, dateadd(week,0, CONVERT(date, Available_dt,112)),112)
		END                       AS Availability_dt
		,ean.[SupplierCatalogKey]
		,'0CA'                    AS [InventorySource_cd]
		,ean.[LOAD_DATE]         
	FROM                [dbo].[iV_IN_hlp_ean]   ean
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa]  la  ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] AND la.[InventorySource_cd] = '0CA')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO]    po  ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN] AND po.[InventorySource_cd] = '0CA')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] AND ord.[InventorySource_cd] = '0CA')
	WHERE [SeasonDefault] = 'N'
		AND [AvailableCheck_dt] <= CONVERT(VARCHAR(10), getDate(), 112)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--COMMIT TRANSACTION


	--======================================================================================================================
	/********************************** REORDER SEASONS (season default = J) + (FeLager) Inventory <= 0 **************************************/
	--======================================================================================================================
	--BEGIN TRANSACTION
	--stock 800 - reorder
	SET @curObject = 'stock 800 - reorder (season default = J) + (FeLager) Inventory <= 0'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 ean.[EAN]                AS [UPC]
		,ean.[SKU]               
		,ean.[SKU]                AS [SupplierProductKey]
		,ean.[EAN]               
		,0                       
		,NULL                     AS [Available_dt]
		,ean.[SupplierCatalogKey]
		,'800'                    AS [InventorySource_cd]
		,ean.[LOAD_DATE]         
	FROM                [dbo].[iV_IN_hlp_ean]  ean
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la  ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] AND la.[InventorySource_cd] = '800')
	WHERE [SeasonDefault] = 'J'
		AND [Inventory] <= 0
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--stock 0CA - reorder
	SET @curObject = 'stock 0CA - reorder (season default = J) + (FeLager) Inventory <= 0'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 ean.[EAN]                AS [UPC]
		,ean.[SKU]               
		,ean.[SKU]                AS [SupplierProductKey]
		,ean.[EAN]               
		,0                       
		,NULL                     AS [Available_dt]
		,ean.[SupplierCatalogKey]
		,'0CA'                    AS [InventorySource_cd]
		,ean.[LOAD_DATE]         
	FROM                [dbo].[iV_IN_hlp_ean]  ean
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa] la  ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] AND la.[InventorySource_cd] = '0CA')
	WHERE [SeasonDefault] = 'J'
		AND [Inventory] <= 0
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION


	--======================================================================================================================
	/********************************** REORDER SEASONS (season default = J) + (FeLager) Inventory > 0 **************************************/
	--======================================================================================================================
	--BEGIN TRANSACTION
	--stock 800 - reorder
	SET @curObject = 'stock 800 - reorder (season default = J) + (FeLager) Inventory > 0'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 ean.[EAN]                AS [UPC]
		,ean.[SKU]               
		,ean.[SKU]                AS [SupplierProductKey]
		,ean.[EAN]               
		--MPFYL Start 21-FEB-17:
		--check free availability, if higher then 0, show stock quantity or free availabilty, whatever is less
		,CASE WHEN (CASE WHEN [Inventory] IS NULL THEN 0
		                                          ELSE [Inventory]
		END +CASE WHEN [open_QTY] IS NULL THEN 0
		                                  ELSE [open_QTY]
		END - CASE WHEN [open_order_QTY] IS NULL THEN 0
		                                         ELSE [open_order_QTY]
		END) > [Inventory] THEN [Inventory] --inventory is less, so show inventory
		                   ELSE (CASE WHEN [Inventory] IS NULL THEN 0
		                                                       ELSE [Inventory]
		END +CASE WHEN [open_QTY] IS NULL THEN 0
		                                  ELSE [open_QTY]
		END - CASE WHEN [open_order_QTY] IS NULL THEN 0
		                                         ELSE [open_order_QTY]
		END) --availability is less, show availability
		END                      
		AS                           TEST
		--alt2,CASE WHEN CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END +CASE WHEN [open_QTY] IS NULL THEN 0 ELSE [open_QTY] END - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END > 0 THEN [Inventory] ELSE 0 END as TEST
		--alt1,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END  - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END
		--MPFYL End 21-FEB-17
		--,[Available_dt]
		,NULL                     AS [Available_dt]
		,ean.[SupplierCatalogKey]
		,'800'                    AS [InventorySource_cd]
		,ean.[LOAD_DATE]         
	FROM                [dbo].[iV_IN_hlp_ean]   ean
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa]  la  ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] AND la.[InventorySource_cd] = '800')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] AND ord.[InventorySource_cd] = '800')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO]    po  ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN] AND po.[InventorySource_cd] = '800')
	WHERE [SeasonDefault] = 'J'
		AND [Inventory] > 0
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--stock 0CA - rerder
	SET @curObject = 'stock 0CA - reorder (season default = J) + (FeLager) Inventory > 0'
	INSERT INTO [dbo].[iV_IN]
		(
			 [UPC]
			,[SKU]
			,[SupplierProductKey]
			,[EAN]
			,[Inventory]
			,[Available_dt]
			,[SupplierCatalogKey]
			,[InventorySource_cd]
			,[LOAD_DATE]
		)
	SELECT
		 ean.[EAN]                AS [UPC]
		,ean.[SKU]               
		,ean.[SKU]                AS [SupplierProductKey]
		,ean.[EAN]               
		--MPFYL Start 21-FEB-17:
		--check free availability, if higher then 0, show stock quantity or free availabilty, whatever is less
		,CASE WHEN (CASE WHEN [Inventory] IS NULL THEN 0
		                                          ELSE [Inventory]
		END +CASE WHEN [open_QTY] IS NULL THEN 0
		                                  ELSE [open_QTY]
		END - CASE WHEN [open_order_QTY] IS NULL THEN 0
		                                         ELSE [open_order_QTY]
		END) > [Inventory] THEN [Inventory] --inventory is less, so show inventory
		                   ELSE (CASE WHEN [Inventory] IS NULL THEN 0
		                                                       ELSE [Inventory]
		END +CASE WHEN [open_QTY] IS NULL THEN 0
		                                  ELSE [open_QTY]
		END - CASE WHEN [open_order_QTY] IS NULL THEN 0
		                                         ELSE [open_order_QTY]
		END) --availability is less, show availability
		END                      
		AS                           TEST
		--alt2,CASE WHEN CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END +CASE WHEN [open_QTY] IS NULL THEN 0 ELSE [open_QTY] END - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END > 0 THEN [Inventory] ELSE 0 END as TEST
		--alt1,CASE WHEN [Inventory] IS NULL THEN 0 ELSE [Inventory] END  - CASE WHEN [open_order_QTY] IS NULL THEN 0 ELSE [open_order_QTY] END
		--MPFYL End 21-FEB-17
		--,[Available_dt]
		,NULL                     AS [Available_dt]
		,ean.[SupplierCatalogKey]
		,'0CA'                    AS [InventorySource_cd]
		,ean.[LOAD_DATE]         
	FROM                [dbo].[iV_IN_hlp_ean]   ean
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_FeLa]  la  ON (ean.[SupplierCatalogKey] = la.[SupplierCatalogKey] AND ean.[EAN] = la.[EAN] AND la.[InventorySource_cd] = '0CA')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_Order] ord ON (ean.[SupplierCatalogKey] = ord.[SupplierCatalogKey] AND ean.[EAN] = ord.[EAN] AND ord.[InventorySource_cd] = '0CA')
		LEFT OUTER JOIN [dbo].[iV_IN_hlp_PO]    po  ON (ean.[SupplierCatalogKey] = po.[SupplierCatalogKey] AND ean.[EAN] = po.[EAN] AND po.[InventorySource_cd] = '0CA')
	WHERE [SeasonDefault] = 'J'
		AND [Inventory] > 0
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()



	--COMMIT TRANSACTION




	--BEGIN TRANSACTION /********************************** remove negative stock  **************************************/

	SET @curObject = 'remove negative stock (set to 0)'
	UPDATE [dbo].[iV_IN]
		SET [Inventory] = 0
	WHERE [Inventory] < 0
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--COMMIT TRANSACTION

	--BEGIN TRANSACTION /********************************** change date format according to iVendix   **************************************/

	SET @curObject = 'change date format according to iVendix'
	UPDATE [dbo].[iV_IN]
		SET [Available_dt] = SUBSTRING([Available_dt], 5, 2)+'/'+SUBSTRING([Available_dt], 7, 2)+'/'+SUBSTRING([Available_dt], 1, 4)
	WHERE [Available_dt] IS NOT NULL
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION

	--BEGIN TRANSACTION /*************************** assign LIQ styles to LIQ SEASON ************************/

	SET @curObject = 'assign LIQ styles to LIQ SEASON'
	UPDATE [dbo].[iV_IN]
		SET [SupplierCatalogKey] = REPLACE(t.[SupplierCatalogKey], 'H', 'L')
	FROM [dbo].[iV_IN] t
		,[dbo].[iV_ST] st
	--mpfyl 05/12/2016: adjust liq not new and old but only old
	--WHERE st.[hlp_DiscountNOS] IN ('50', '80')
	WHERE st.[hlp_DiscountNOS] IN ('80')
		AND REPLACE(St.[SupplierCatalogKey], 'L', 'H') = t.[SupplierCatalogKey]
		AND st.EAN = t.EAN
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()


	--COMMIT TRANSACTION



	--BEGIN TRANSACTION /********************************** remove ean not in iV_ST  **************************************/

	SET @curObject = 'delete all articles (EAN) pricelist not found in style file'
	DELETE FROM [dbo].[iV_IN] /************** delete all articles (EAN) pricelist not found in style file ************************/
	WHERE NOT EXISTS (
		SELECT
			 DISTINCT
			 [SupplierCatalogKey]
			,[EAN]
		FROM [dbo].[iV_ST]
		WHERE [dbo].[iV_ST].[EAN] = [dbo].[iV_IN].[EAN]
			AND [dbo].[iV_ST].[SupplierCatalogKey] = [dbo].[iV_IN].[SupplierCatalogKey]
		)
	SELECT
		@rowCount = RIGHT(replicate(' ',10) +cast(@@ROWCOUNT AS varchar),10)
	IF @DEBUG = 1
		BEGIN
			PRINT dbo.getDuration(@Start, GETDATE()) + ': '+ @rowcount + ', '+ @curObject
		END
	SET @Start = getdate()

	--COMMIT TRANSACTION



END
GO
