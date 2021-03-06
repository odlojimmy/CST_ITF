SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_CM_bak_JRU_20170809]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[iV_CM]

	COMMIT TRANSACTION

	BEGIN TRANSACTION /****************************** LOAD ALL CUSTOMERS **********************************/

	INSERT INTO [dbo].[iV_CM] (
		[CAccountNum]
		,[CCompanyName]
		,[CAdress1]
		,[CAddress2]
		,[CAddress3]
		,[CCity]
		,[CState]
		,[CZip]
		,[CCountry]
		,[CPhone]
		,[CFax]
		,[StoreAccountNum]
		,[StoreName]
		,[StoreIdentification]
		,[StoreAddress1]
		,[StoreAddress2]
		,[StoreAddress3]
		,[StoreCity]
		,[StoreState]
		,[StoreZip]
		,[StoreCountry]
		,[StorePhone]
		,[StoreFax]
		,[SalesRegionCode]
		,[SR_Code]
		,[DealerGroupCode]
		,[DealerGroupName]
		,[Currency_cd]
		,[PaymentTerms]
		,[ShipMethodeKey]
		,[BusinessUnit_cd]
		,[PriceSchedule]
		,[InventorySource_cd]
		,[isCreditCardCustomer]
		,[SourceERP]
		,[LOAD_DATE]
		)
SELECT CASE 
			WHEN ks.[KusNr] = ''
				THEN NULL
			ELSE ks.[KusNr]
			END AS [CAccountNum]
		,CASE 
			WHEN ltrim(rtrim(ks.[Name1])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(ks.[Name1]))
			END AS [CCompanyName]
		,CASE 
			WHEN ltrim(rtrim(ks.[Str])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(ks.[Str]))
			END AS [CAdress1]
		,NULL AS [CAddress2]
		,NULL AS [CAddress3]
		,CASE 
			WHEN ltrim(rtrim(ks.[Ort])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(ks.[Ort]))
			END AS [CCity]
		,NULL AS [CState] --CASE WHEN ltrim(rtrim(tpbund.zeile)) = '' THEN NULL ELSE ltrim(rtrim(tpbund.zeile)) END AS [CState]
		,CASE 
			WHEN ltrim(rtrim(ks.[Plz])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(ks.[Plz]))
			END AS [CZip]
		,CASE 
			WHEN ltrim(rtrim(ks.[Land])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(tpsteland.stwert))
			END AS [CCountry]
		,CASE 
			WHEN ltrim(rtrim(ks.[Telefon])) = ''
				THEN NULL
			ELSE ltrim(rtrim(ks.[Telefon]))
			END AS [CPhone]
		,CASE 
			WHEN ltrim(rtrim(ks.[Telefax])) = ''
				THEN NULL
			ELSE ltrim(rtrim(ks.[Telefax]))
			END AS [CFax]
		,CAST(kva.KuvNr AS VARCHAR(10)) AS [StoreAccountNum] -- mz: 01.06.2016 (check also ACK export!) CAST(ks.[KusNr] AS VARCHAR(24)) + '-' + CAST(kva.KuvNr AS VARCHAR(10)) AS [StoreAccountNum]
		,CASE 
			WHEN LEFT(ltrim(rtrim(kva.[Name1])), 36) = ''
				THEN 'unknwn'
			ELSE LEFT(ltrim(rtrim(kva.[Name1])), 36)
			END AS [StoreName]
		,ltrim(rtrim(kva.Match)) AS [StoreIdentification]
		,CASE 
			WHEN ltrim(rtrim(kva.[Str])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(kva.[Str]))
			END AS [StoreAddress1]
		,NULL AS [StoreAddress2]
		,NULL AS [StoreAddress3]
		,CASE 
			WHEN ltrim(rtrim(kva.[Ort])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(kva.[Ort]))
			END AS [StoreCity]
		,NULL AS [StoreState] --CASE WHEN ltrim(rtrim(tpbund.zeile)) = '' THEN 'unknwn' ELSE ltrim(rtrim(tpbund.zeile)) END AS [StoreState]
		,CASE 
			WHEN ltrim(rtrim(kva.[Plz])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(kva.[Plz]))
			END AS [StoreZip]
		,CASE 
			WHEN ltrim(rtrim(kva.[Land])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(tpstelandkva.stwert))
			END AS [StoreCountry]
		,NULL AS [StorePhone]
		,NULL AS [StoreFax]
		,LEFT(ltrim(rtrim(tpcoty.zeile)), 20) AS [SalesRegionCode]
		--mpf 28/10/16: removed below case. value was 0 and it was identified as empty and then nullified - which is wrong.
		/*,CASE 
			WHEN ks.[VersNr] = ''
				THEN NULL
			ELSE ks.[VersNr]
			END AS [SR_Code]
		*/
		,ks.[VersNr] AS [SR_Code]
		,NULL AS [DealerGroupCode]
		,NULL AS [DealerGroupName]
		,CASE 
			WHEN ltrim(rtrim(cur.stwert)) = ''
				THEN NULL
			ELSE ltrim(rtrim(cur.stwert))
			END AS [Currency_cd]
		,LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tpzbT.zeile, 'Tage', 'T.'),'Bankeinzug', 'BE'), 'netto', 'net'), 'Netto', 'net'), 'Zahlbar', 'Zb.'), 'jours fin de mois', 'j. f.d.m.'),20) AS [PaymentTerms]
		--mpf 02/09/16 - translate for France
		, CASE
			WHEN ltrim(rtrim(ks.[Land])) = 'F'
				THEN replace(replace((LEFT(tpl.zeile, 35)), 'FREI HAUS', 'franco domicile'), 'UNFREI','frais de port')
			ELSE
				LEFT(tpl.zeile, 35) 
			END AS [ShipMethodeKey]
		--,LEFT(tpl.zeile, 35) AS [ShipMethodeKey]
		,'COLLECTION' AS [BusinessUnit_cd]
		,CASE 
			WHEN ltrim(rtrim(ks.[PreisLst])) = ''
				THEN NULL
			ELSE ltrim(rtrim(ks.[PreisLst]))
			END AS [PriceSchedule]
		,CASE 
			WHEN ltrim(rtrim(ks.[LagOrt])) = ''
				THEN NULL
			ELSE ltrim(rtrim(ks.[LagOrt]))
			END AS [InventorySource_cd]
		,NULL AS [isCreditCardCustomer]
		,NULL AS [SourceERP]
		,getDate() AS [LOAD_DATE]
	FROM [INTEXSALES].[OdloDE].dbo.[KuStamm] ks
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpzbT ON (
			ks.[ZahlBed] = tpzbT.tpwert
			AND ks.[TabKey_ZahlBed] = tpzbT.tapkey
			AND tpzbT.tanr = 26
			AND tpzbT.sprache = '01'
			AND tpzbT.lfd = 1
			)	
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpbund ON (
			ks.BundesLand = tpbund.tpwert
			AND ks.TabKey_BundesLand = tpbund.tapkey
			AND tpbund.tanr = 18
			AND tpbund.sprache = '01'
			AND tpbund.lfd = 1
			)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpl ON (
			ks.PreisSt = tpl.tpwert
			AND ks.TabKey_PreisSt = tpl.tapkey
			AND tpl.tanr = 25
			AND tpl.sprache = '01'
			AND tpl.lfd = 1
			)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpSteu tpsteland ON (
			ks.Land = tpsteland.tpwert
			AND ks.TabKey_Land = tpsteland.tapkey
			AND tpsteland.tanr = 15
			AND tpsteland.lfd = 10
			)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpcoty ON (
			ks.FirmenTyp = tpcoty.tpwert
			AND ks.TapKey_FirmenTyp = tpcoty.tapkey
			AND tpcoty.tanr = 95
			AND tpcoty.sprache = '01'
			AND tpcoty.lfd = 1
			)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText pltxt ON (
			ks.PreisLst = pltxt.tpwert
			AND ks.TabKey_PreisLst = pltxt.tapkey
			AND pltxt.tanr = 34
			AND pltxt.sprache = '01'
			AND pltxt.lfd = 1
			)
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].[dbo].[KuStFAString] ew ON ( -- E-Wholesale @KuStamm=>Freie Attribute
		ks.KusNr = ew.KusNr
		AND ks.KustKey = ew.KustKey
		AND ew.AttributIdent = 3
		)
		,INTEXSALES.OdloDE.dbo.TpSteu cur
		,INTEXSALES.OdloDE.dbo.TpSteu mkz
		,INTEXSALES.OdloDE.dbo.KuVerAdr kva
	LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpSteu tpstelandkva ON (
			kva.Land = tpstelandkva.tpwert
			AND kva.TabKey_Land = tpstelandkva.tapkey
			AND tpstelandkva.tanr = 15
			AND tpstelandkva.lfd = 10
			)
	WHERE ks.[AktivJN] = 'J'
		AND ks.[KustKey] = '01'
		--mpfyl 15/12/2016, added firmentype number 12 (canada) below
		AND ks.FirmenTyp IN (
			'00'
			,'01'
			,'02'
			,'03'
			,'04'
			,'05'
			,'06'
			,'07'
			,'09'
			,'12'
			)
		--MPFYL, 09/12/16: added intercompany as well ('k') due to our french colleagues
		AND ks.SelKrit6 in ('2','k') -- nur TP (IC Code) Kunden		
		--MPFYL 15/12/2016, added beside stock 800 the stock 0CA
		--AND ltrim(rtrim(ks.[LagOrt])) = '800' -- nur mit Lager 800
		AND ltrim(rtrim(ks.[LagOrt])) in ('800','0CA') -- nur mit Lager 800
		--MPF 03.04.2017 - Pricelist 309 used to be exlcuded, Sabrina requires it
		AND ltrim(rtrim(ks.[PreisLst])) NOT IN (
			'099'
			,'599'			
			,'NON'
			,'330'
			,'331'
			,'209'
			,'DE'
			,'000'
			,'199'
			,'021'
			,'340'
			,'341'
			,'350'
			,'CH'
			,'701'
			,'505'
			,'99'
			) -- manually excluded doublecheck with pricelist export
		--MPF 19/01/17: key accounts should not be exluded anymore.
		/*
		AND ks.[INFORChannel] NOT IN (
			SELECT DISTINCT [INFOR_Channel_key] COLLATE SQL_Latin1_General_CP1_CS_AS
			FROM [SPOT_SRC].[dbo].[SHLP_INFOR_CHANNEL_GROUP]
			WHERE [INFOR_CHANNEL_GROUP] = 'Key Account'
			)
		*/
		AND ltrim(rtrim(cur.stwert)) <> 'RMB' -- not (yet) supported by iVendix
		AND ks.[TabKey_PreisLst] = cur.[tapkey] -- nur Kunden mit PL/Währung
		AND cur.[tanr] = 34
		AND cur.[tpwert] = ks.[PreisLst]
		AND cur.lfd = 2
		AND mkz.tanr = 71
		AND mkz.[tapkey] = '01'
		AND mkz.lfd = 2 --(Echte Sperre J/N)
		AND mkz.[tpwert] = ks.[Mahnkenn]
		AND mkz.stwert = 'N'
		--AND ks.[VersNr] <> ''
		AND ks.[VersNr] IS NOT NULL
		AND ks.KusNr = kva.KusNr
		AND ks.KustKey = kva.KustKey

		AND ks.[Mahnkenn] IN ('0','5')
		AND ew.[FAWert] = 'J' -- E-Wholesale @KuStamm=>Freie Attribute

	COMMIT TRANSACTION
END

GO
