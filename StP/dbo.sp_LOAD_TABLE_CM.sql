SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************************************************/
-- Author:       Marc Ziegler
-- Create date:  21.4.2016
-- Description:	 Fill Table [dbo].[iV_CM] in Preparation of the daily export
-- Change Hist:  09.08.2017 Jimmy Rüedi
--               Mainly technical change, which uses a new scalar function to do this stuff centrally:
-- 		           old:   ,CASE 
--		               	      WHEN ltrim(rtrim(ks.[Name1])) = ''
--		                          THEN 'unknwn'
--		                          ELSE ltrim(rtrim(ks.[Name1]))
--		                      END AS [CCompanyName]
--
--               new:   ,dbo.FullTrim(ks.[Name1], 'unknwn') AS [CCompanyName]
--               
--               im weiteren musste die Lieferung von Kundenadressen ohne Versandweg unterbunden werden, was mit teils 
--               einem weiteren Join auf die Tabelle [INTEXSALES].[OdloDe].dbo.[Kuweg] bewerkstelligt werden konnte 
--               leider musste ein Distinct verwendet werden.
--            -- 01.09.2017 Jimmy Rüedi
--               Removed the fully qualified table adressing of the containing database  
--               Change from direct access to [INTEXSALES].[OdloDE] to [IFC_Cache]
/***********************************************************************************************************************/
ALTER PROCEDURE [dbo].[sp_LOAD_TABLE_CM]
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
		,dbo.FullTrim(ks.[Name1], 'unknwn') AS [CCompanyName]
		,dbo.FullTrim(ks.[Str], 'unknwn') AS [CAdress1]
		,NULL AS [CAddress2]
		,NULL AS [CAddress3]
		,dbo.FullTrim(ks.[Ort], 'unknwn') AS [CCity]
		,NULL AS [CState] --CASE WHEN ltrim(rtrim(tpbund.zeile)) = '' THEN NULL ELSE ltrim(rtrim(tpbund.zeile)) END AS [CState]
		,dbo.FullTrim(ks.[Plz], 'unknwn') AS [CZip]
		/* Begin Replace by JRU 09.08.2017
		,CASE 
			WHEN dbo.FullTrim(ks.[Land], 'unknwn') != 'unknwn'
				THEN dbo.FullTrim(tpsteland.stwert, 'unknwn')
			ELSE 'unknwn'
			END AS [CCountry]
        End Replace by JRU 09.08.2017 */
		,dbo.FullTrim(isnull(tpsteland.stwert,''), 'unknwn') AS [CCountry] -- JRU, 09.08.2017: replacement part for the logic above
		,dbo.FullTrim(ks.[Telefon], NULL) AS [CPhone]
		,dbo.FullTrim(ks.[Telefax], NULL) AS [CFax]
		,CAST(kva.KuvNr AS VARCHAR(10)) AS [StoreAccountNum] -- mz: 01.06.2016 (check also ACK export!) CAST(ks.[KusNr] AS VARCHAR(24)) + '-' + CAST(kva.KuvNr AS VARCHAR(10)) AS [StoreAccountNum]
		,LEFT(dbo.FullTrim(kva.[Name1], 'unknwn'), 36) AS [StoreName]
		,dbo.FullTrim(kva.Match, '') AS [StoreIdentification]
		,dbo.FullTrim(kva.[Str], 'unknwn') AS [StoreAddress1]
		,NULL AS [StoreAddress2]
		,NULL AS [StoreAddress3]
		,dbo.FullTrim(kva.[Ort], 'unknwn') AS [StoreCity]
		,NULL AS [StoreState] --CASE WHEN ltrim(rtrim(tpbund.zeile)) = '' THEN 'unknwn' ELSE ltrim(rtrim(tpbund.zeile)) END AS [StoreState]
		,dbo.FullTrim(kva.[Plz], 'unknwn') AS [StoreZip]
		/* Begin Replace by JRU 09.08.2017
		,CASE 
			WHEN ltrim(rtrim(kva.[Land])) = ''
				THEN 'unknwn'
			ELSE ltrim(rtrim(tpstelandkva.stwert))
			END AS [StoreCountry]
        End Replace by JRU 09.08.2017 */		
		,dbo.FullTrim(isnull(tpstelandkva.stwert,''), 'unknwn') AS [StoreCountry] -- JRU, 09.08.2017: replacement part for the logic above
		,NULL AS [StorePhone]
		,NULL AS [StoreFax]
		,LEFT(dbo.FullTrim(tpcoty.zeile, ''), 20) AS [SalesRegionCode]
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
		,dbo.FullTrim(cur.stwert, NULL) AS [Currency_cd] 
		,LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tpzbT.zeile, 'Tage', 'T.'), 'Bankeinzug', 'BE'), 'netto', 'net'), 'Netto', 'net'), 'Zahlbar', 'Zb.'), 'jours fin de mois', 'j. f.d.m.'), 20) AS [PaymentTerms]
		--mpf 02/09/16 - translate for France
		,CASE 
			WHEN ltrim(rtrim(ks.[Land])) = 'F'
				THEN replace(replace((LEFT(tpl.zeile, 35)), 'FREI HAUS', 'franco domicile'), 'UNFREI', 'frais de port')
			ELSE LEFT(tpl.zeile, 35)
			END AS [ShipMethodeKey]
		--,LEFT(tpl.zeile, 35) AS [ShipMethodeKey]
		,'COLLECTION' AS [BusinessUnit_cd]
		,dbo.FullTrim(ks.[PreisLst], NULL) AS [PriceSchedule]
		,dbo.FullTrim(ks.[LagOrt], NULL) AS [InventorySource_cd]
		,NULL AS [isCreditCardCustomer]
		,NULL AS [SourceERP]
		,getDate() AS [LOAD_DATE]
	--FROM [INTEXSALES].[OdloDE].dbo.[KuStamm] ks
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpzbT ON (
	FROM [IFC_Cache].dbo.[KuStamm] ks
	LEFT OUTER JOIN [IFC_Cache].dbo.TpText tpzbT ON (
			ks.[ZahlBed] = tpzbT.tpwert
			AND ks.[TabKey_ZahlBed] = tpzbT.tapkey
			AND tpzbT.tanr = 26
			AND tpzbT.sprache = '01'
			AND tpzbT.lfd = 1
			)
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpbund ON (
	LEFT OUTER JOIN [IFC_Cache].dbo.TpText tpbund ON (
			ks.BundesLand = tpbund.tpwert
			AND ks.TabKey_BundesLand = tpbund.tapkey
			AND tpbund.tanr = 18
			AND tpbund.sprache = '01'
			AND tpbund.lfd = 1
			)
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpl ON (
	LEFT OUTER JOIN [IFC_Cache].dbo.TpText tpl ON (
			ks.PreisSt = tpl.tpwert
			AND ks.TabKey_PreisSt = tpl.tapkey
			AND tpl.tanr = 25
			AND tpl.sprache = '01'
			AND tpl.lfd = 1
			)
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpSteu tpsteland ON (
	LEFT OUTER JOIN [IFC_Cache].dbo.TpSteu tpsteland ON (
			ks.Land = tpsteland.tpwert
			AND ks.TabKey_Land = tpsteland.tapkey
			AND tpsteland.tanr = 15
			AND tpsteland.lfd = 10
			)
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText tpcoty ON (
	LEFT OUTER JOIN [IFC_Cache].dbo.TpText tpcoty ON (
			ks.FirmenTyp = tpcoty.tpwert
			AND ks.TapKey_FirmenTyp = tpcoty.tapkey
			AND tpcoty.tanr = 95
			AND tpcoty.sprache = '01'
			AND tpcoty.lfd = 1
			)
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpText pltxt ON (
	LEFT OUTER JOIN [IFC_Cache].dbo.TpText pltxt ON (
			ks.PreisLst = pltxt.tpwert
			AND ks.TabKey_PreisLst = pltxt.tapkey
			AND pltxt.tanr = 34
			AND pltxt.sprache = '01'
			AND pltxt.lfd = 1
			)
	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].[dbo].[KuStFAString] ew ON (
	LEFT OUTER JOIN [IFC_Cache].[dbo].[KuStFAString] ew ON (
			-- E-Wholesale @KuStamm=>Freie Attribute
			ks.KusNr = ew.KusNr
			AND ks.KustKey = ew.KustKey
			AND ew.AttributIdent = 3
			)
	--JOIN [INTEXSALES].[OdloDe].dbo.[TpSteu] cur ON (
	JOIN [IFC_Cache].dbo.[TpSteu] cur ON (
			cur.[tpwert] = ks.[PreisLst]
			AND ks.[TabKey_PreisLst] = cur.[tapkey] -- nur Kunden mit PL/Währung
			AND ltrim(rtrim(cur.stwert)) <> 'RMB' -- not (yet) supported by iVendix
			AND cur.[tanr] = 34
			AND cur.lfd = 2
			)
	/* BEGIN JRU 09.08.2017 Replaced by JOIN instead of listing the tables and have the join
		,INTEXSALES.OdloDE.dbo.TpSteu cur
		,INTEXSALES.OdloDE.dbo.TpSteu mkz
		,INTEXSALES.OdloDE.dbo.KuVerAdr kva
	END JRU 09.08.2017 Replaced by JOIN instead of listing the tables and have the join*/

	-- BEGIN JRU, 09.08.2017 use of JOIN instead of listing the tables and have the join 
	--JOIN [INTEXSALES].[OdloDe].dbo.[TpSteu] mkz ON (
	JOIN [IFC_Cache].dbo.[TpSteu] mkz ON (
			mkz.[tpwert] = ks.[Mahnkenn]
			AND mkz.tanr = 71
			AND mkz.[tapkey] = '01'
			AND mkz.lfd = 2 --(Echte Sperre J/N)
			AND mkz.stwert = 'N'
			)

	--JOIN [INTEXSALES].[OdloDe].dbo.[KuVerAdr] kva ON ks.KusNr = kva.KusNr
	JOIN [IFC_Cache].dbo.[KuVerAdr] kva ON ks.KusNr = kva.KusNr
		AND ks.KustKey = kva.KustKey
	-- END JRU, 09.08.2017 use of JOIN instead of listing the tables and have the join 
	
	-- BEGIN JRU, 09.08.2017 newly implemented, since adresses with no sending path should not be listed here
	JOIN (
		-- leider lässt sich der Distinct nicht umgehen, da 
		SELECT DISTINCT kw.KusNr
			,kw.KustKey
			,kw.KuvNr
		--FROM [INTEXSALES].[OdloDe].dbo.[Kuweg] kw
		FROM [IFC_Cache].dbo.[Kuweg] kw
		) kw ON kva.KusNr = kw.KusNr
		AND kva.KustKey = kw.KustKey
		AND kva.KuvNr = kw.KuvNr
	-- END JRU, 09.08.2017 newly implemented, since adresses with no sending path should not be listed here

	--LEFT OUTER JOIN [INTEXSALES].[OdloDE].dbo.TpSteu tpstelandkva ON (
	LEFT OUTER JOIN [IFC_Cache].dbo.TpSteu tpstelandkva ON (
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
		AND ks.SelKrit6 IN (
			'2'
			,'k'
			) -- nur TP (IC Code) Kunden		
		--MPFYL 15/12/2016, added beside stock 800 the stock 0CA
		--AND ltrim(rtrim(ks.[LagOrt])) = '800' -- nur mit Lager 800
		AND ltrim(rtrim(ks.[LagOrt])) IN (
			'800'
			,'0CA'
			) -- nur mit Lager 800
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
	/* BEGIN JRU 09.08.2017 Replaced by a proper JOIN instead Listing the table and do the JOIN stuff here
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
	   END JRU 09.08.2017 Replaced by a proper JOIN instead Listing the table and do the JOIN stuff here*/
		AND ks.[VersNr] IS NOT NULL
	/* BEGIN JRU 09.08.2017 Replaced by a proper JOIN instead Listing the table and do the JOIN stuff here
		AND ks.KusNr = kva.KusNr
		AND ks.KustKey = kva.KustKey
	   END JRU 09.08.2017 Replaced by a proper JOIN instead Listing the table and do the JOIN stuff here*/

		AND ks.[Mahnkenn] IN ('0','5')
		AND ew.[FAWert] = 'J' -- E-Wholesale @KuStamm=>Freie Attribute



	COMMIT TRANSACTION
END
GO
