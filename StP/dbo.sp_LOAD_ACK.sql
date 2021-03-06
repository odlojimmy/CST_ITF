SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- Modification: 04.08.2016/cls - Tune ACK load script by loading INTEX tables locally before major join
-- =============================================
ALTER PROCEDURE [dbo].[sp_LOAD_ACK]



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
BEGIN 


--BEGIN TRANSACTION

TRUNCATE TABLE [dbo].[iV_ACK_header];
TRUNCATE TABLE [dbo].[iV_ACK_pos];
TRUNCATE TABLE [dbo].[iV_ACK_amount];

--- 04.08.2016 cls: added INTEX-Raw tables for ACK tuning
TRUNCATE TABLE INTEX_RAW_ArtEAN;
--TRUNCATE TABLE INTEX_RAW_ArtFarben;
--TRUNCATE TABLE INTEX_RAW_ArtStamm;
--TRUNCATE TABLE INTEX_RAW_AufGroesse;
--TRUNCATE TABLE INTEX_RAW_AufKopf;
--TRUNCATE TABLE INTEX_RAW_AufPosi;
--TRUNCATE TABLE INTEX_RAW_GGaGr;
--TRUNCATE TABLE INTEX_RAW_TpSteu;

--COMMIT TRANSACTION



--- 04.08.2016 cls: load INTEX-Raw tables for ACK tuning and [INTEXSALES]- relief
--BEGIN TRANSACTION
/* -- de-activated by JRU since we implemented the IFC_Cache Database for Tuning and 
INSERT INTO INTEX_RAW_AufKopf
SELECT [AufkNr]
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
FROM	[IFC_Cache].dbo.AufKopf
WHERE	AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
AND		Art IN ('01','04','99'); --MPF 29/9/16, added OrderType 99 ('Ramsch')

INSERT INTO INTEX_RAW_AufPosi
SELECT	*
FROM	[IFC_Cache].dbo.AufPosi
WHERE	AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller);

INSERT INTO INTEX_RAW_ArtStamm
SELECT	*
FROM	[IFC_Cache].dbo.ArtStamm
WHERE	ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller);

INSERT INTO INTEX_RAW_ArtFarben
SELECT	*
FROM	[IFC_Cache].dbo.ArtFarben
WHERE	ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller);

INSERT INTO INTEX_RAW_AufGroesse
SELECT	*
FROM	[IFC_Cache].dbo.AufGroesse
WHERE	AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller);
*/

--START MPFYL 11.04.17
-- add into the raw tabel at teh end the column to identify if the style is SALES or RETAIL (or something else)
INSERT INTO INTEX_RAW_ArtEAN (ArtsNr1, ArtsNr2, ArtsKey, VerkFarbe, GGanKey, GGNr, GR, EANCode, ExportiertKz, Neu, Wer, Wann, CategoryGroup)
SELECT	ean.ArtsNr1, ean.ArtsNr2, ean.ArtsKey, ean.VerkFarbe, ean.GGanKey, ean.GGNr, ean.GR, ean.EANCode, ean.ExportiertKz, ean.Neu, ean.Wer, ean.Wann, CASE WHEN div.stwert is null THEN 'UNDEFINED' ELSE div.stwert END
FROM	[IFC_Cache].dbo.ArtEAN ean, [IFC_Cache].dbo.ArtStamm ArtS
			LEFT OUTER JOIN [IFC_Cache].[dbo].[TpSteu] div ON
				(
					div.tanr = 600 -- category aka division
					AND div.lfd = 205
					AND ArtS.[TapKey_DivNeu] = div.[tapkey]
					AND ArtS.[DivNeu] = div.tpwert
				)
WHERE	ean.artsnr1 = arts.artsnr1 and ean.artskey = arts.artskey and
		ean.ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller);

/*
INSERT INTO INTEX_RAW_ArtEAN
SELECT	*
FROM	[IFC_Cache].dbo.ArtEAN
WHERE	ArtsKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller);
*/
--END MPFYL 11.04.17

/* -- de-activated by JRU since we implemented the IFC_Cache Database for Tuning and 

INSERT INTO INTEX_RAW_TpSteu
SELECT	*
FROM	[IFC_Cache].dbo.TpSteu
WHERE	tanr=600
AND		lfd=205;

INSERT INTO INTEX_RAW_GGaGr
SELECT	*
FROM	[IFC_Cache].dbo.GGaGr;
*/
--COMMIT TRANSACTION




--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_ACK_header]
           ([orderNumber]
		   ,[KdAuftrNr2]
		   ,[EinArt]
		   ,[orderNEW]
           ,[orderPosition]
		   ,[BAK01]
           ,[BAK02]
           ,[BAK03]
           ,[BAK04]
           ,[BAK05]
           ,[BAK06]
           ,[BAK07]
           ,[BAK_cr]
           ,[REF01]
           ,[REF02]
           ,[REF03]
           ,[REF04]
           ,[REF_cr]
           ,[VE01]
           ,[VE02]
           ,[VE_cr]
           ,[ITD01]
           ,[ITD02]
           ,[ITD03]
           ,[ITD04]
           ,[ITD_cr]
           ,[DTM01]
           ,[DTM02]
           ,[DTM03]
           ,[DTM04]
           ,[DTM_cr]
           ,[TD01]
           ,[TD02]
           ,[TD03]
           ,[TD_cr]
           ,[MSG01]
           ,[MSG02]
           ,[MSG_cr]
           ,[N1ST01]
           ,[N1ST02]
           ,[N1ST03]
           ,[N1ST04]
           ,[N1ST05]
           ,[N1ST06]
           ,[N1ST07]
           ,[N1ST08]
           ,[N1ST09]
           ,[N1ST10]
           ,[N1ST_cr]
           ,[LOAD_DATE])
SELECT ak.AufkNr AS [orderNumber]
	,ltrim(rtrim(kan2.FAWert)) AS [KdAuftrNr2]
	,ak.EinArt AS [EinArt]
	,CONVERT(VARCHAR(8), ak.Neu, 112)
     ,0 as [orderPosition]
	,'BAK' AS [BAK01]
	,'--' AS [BAK02]
	,'AK' AS [BAK03]
	,CASE WHEN (ak.EinArt = '05' AND kan2.FAWert IS NOT NULL) THEN ltrim(rtrim(kan2.FAWert)) ELSE 0 END AS [BAK04]
	,CONVERT(VARCHAR(8), ak.[KuADatum], 112) AS [BAK05]
	,'*' AS [BAK06]
	,LEFT(ltrim(rtrim(cur.stwert)), 5) AS [BAK07]
	,'<<<' AS [BAK_cr]
	,'REF' AS [REF01]
	,ak.AufkNr AS [REF02]
	,CAST(ak.KuvNr as varchar(10)) AS [REF03] -- mz: 01.06.2016 (check also CM export!)  CAST(ak.[KusNr] as varchar(24))+'-'+CAST(ak.KuvNr as varchar(10)) AS [REF03]
	,CASE WHEN LEFT(ltrim(rtrim(ak.KundenAufNr)), 25) IS NULL THEN '-'
		WHEN LEFT(ltrim(rtrim(ak.KundenAufNr)), 25) = '' THEN '-'
		ELSE LEFT(ltrim(rtrim(ak.KundenAufNr)), 25) END AS [REF04]
	,'<<<' AS [REF_cr]
	,'VE' AS [VE01]
	,'Odlo Int. AG' AS [VE02]
	,'<<<' AS [VE_cr]
	,'ITD' AS [ITD01]
	,0 AS [ITD02]
	,CONVERT(VARCHAR(8), getDate(), 112) AS [ITD03]
	,0 AS [ITD04]
	,'<<<' AS [ITD_cr]
	,'DTM' AS [DTM01]
	,'*' AS [DTM02]
	--mpfyl 22/07/16: adjusted requested ship date
	--,CASE WHEN ak.[LiefTerm] IN ('', '21', '22', '60', '61', 'ES') THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) WHEN ak.[LiefTerm] IS NULL THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) ELSE '20'+SUBSTRING(lterm.zeile, LEN(lterm.zeile)-1, 2)+SUBSTRING(lterm.zeile, LEN(lterm.zeile)-4, 2)+SUBSTRING(lterm.zeile, LEN(lterm.zeile)-7, 2) END AS [DTM03] --CONVERT(VARCHAR(8), ak.[KuADatum], 112) AS [DTM03]
	--,CASE WHEN ak.[LiefTerm] IN ('', '21', '22', '60', '61', 'ES') THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) WHEN ak.[LiefTerm] IS NULL THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) ELSE '20'+SUBSTRING(lterm.zeile, LEN(lterm.zeile)-1, 2)+SUBSTRING(lterm.zeile, LEN(lterm.zeile)-4, 2)+SUBSTRING(lterm.zeile, LEN(lterm.zeile)-7, 2) END AS [DTM04] --CONVERT(VARCHAR(8), ak.[KuADatum], 112) AS [DTM04]
	,CASE WHEN ak.[LiefTerm] IN ('', '21', '22', '60', '61', 'ES') THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) WHEN ak.[LiefTerm] IS NULL THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) WHEN CONVERT(VARCHAR(8), CONVERT(datetime, lterm.stwert, 104), 112) IS NULL THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) ELSE CONVERT(VARCHAR(8), CONVERT(datetime, lterm.stwert, 104), 112) END AS [DTM03_new] --update mpfyl 18/7/16
	,CASE WHEN ak.[LiefTerm] IN ('', '21', '22', '60', '61', 'ES') THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) WHEN ak.[LiefTerm] IS NULL THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) WHEN CONVERT(VARCHAR(8), CONVERT(datetime, lterm.stwert, 104), 112) IS NULL THEN CONVERT(VARCHAR(8), ak.[KuADatum], 112) ELSE CONVERT(VARCHAR(8), CONVERT(datetime, lterm.stwert, 104), 112) END AS [DTM04_new] --update mpfyl 18/7/16
	,'<<<' AS [DTM_cr]
	,'TD' AS [TD01]
	,LEFT(ltrim(rtrim(vw.zeile)), 80) AS [TD02]
	,'*' AS [TD03]
	,'<<<' AS [TD_cr]
	,'MSG' AS [MSG01]
	,'*' AS [MSG02]
	,'<<<' AS [MSG_cr]
	,'N1ST' AS [N1ST01]
	,'*' AS [N1ST02]
	,CASE WHEN ad.Name1 IS NULL THEN ltrim(rtrim(ks.Name1)) ELSE ltrim(rtrim(ad.Name1)) END AS [N1ST03]
	,CASE WHEN ad.Name1 IS NULL THEN ltrim(rtrim(ks.Name2)) ELSE ltrim(rtrim(ad.Name2)) END AS [N1ST04]
	,CASE WHEN ad.Name1 IS NULL THEN ltrim(rtrim(ks.[Str])) ELSE ltrim(rtrim(ad.Strasse)) END AS [N1ST05]
	,CASE WHEN ad.Name1 IS NULL THEN ltrim(rtrim(ks.Ort)) ELSE ltrim(rtrim(ad.Ort)) END AS [N1ST06]
	,'*' AS [N1ST07]
	,CASE WHEN ad.Name1 IS NULL THEN ltrim(rtrim(ks.Plz)) ELSE ltrim(rtrim(ad.Plz)) END AS [N1ST08]
	,CASE WHEN ad.Name1 IS NULL THEN ltrim(rtrim(ks.Land)) ELSE ltrim(rtrim(ad.Land)) END AS [N1ST09]
	,ak.KusNr AS [N1ST10]
	,'E=O=L' AS [N1ST_cr]
	,getDate() AS [LOAD_DATE]
FROM [IFC_Cache].dbo.[AufKopf] ak
	LEFT OUTER JOIN [IFC_Cache].[dbo].[EinmalAdr] ad ON (ad.AufkNr=ak.AufkNr and ad.AufkKey=ak.AufkKey)
	LEFT OUTER JOIN [IFC_Cache].[dbo].[AufKFAString] kan2 ON (ak.AufkKey = kan2.AufkKey AND ak.AufkNr = kan2.AufkNr AND kan2.AttributIdent = 2)
	LEFT OUTER JOIN [IFC_Cache].[dbo].TpSteu lterm ON (
			lterm.tanr = 30
		AND lterm.tapkey = ak.[TapKey_LiefTerm]
		AND lterm.tpwert = ak.[LiefTerm]
		AND lterm.lfd = 12
		)
	,[IFC_Cache].dbo.[KuStamm] ks
	,[IFC_Cache].dbo.TpText vw
	,[IFC_Cache].dbo.TpSteu cur

WHERE (
		vw.tapkey = ak.TapKey_Versandweg
		AND vw.tpwert = ak.Versandweg
		AND vw.tanr = 23
		AND vw.sprache = '01'
		AND vw.lfd = 1
		)
	AND (
		ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND ak.Art IN ('01', '04','99') --MPF 29/9/16, added OrderType 99 ('Ramsch')
		)
	AND (ks.[KustKey] = '01'
		AND ks.[KusNr] = ak.KusNr
		--mpf 05/08/16: in case filter by customer number is required
		--AND ks.[KusNr] = 102100
		)
	--mpf 05/08/16: in case filter by order number is required
	--AND (ak.AufkNr = '6579373')
	AND ak.[TapKey_PreisLst] = cur.[tapkey] -- nur mit Währung
	AND cur.[tanr] = 34
	AND cur.[tpwert] = ak.[PreisLst]
	AND cur.lfd = 2

--COMMIT TRANSACTION

--BEGIN TRANSACTION

DELETE FROM [dbo].[iV_ACK_header] --- only export ACKs for customers that get exported in customer master
WHERE [N1ST10] NOT IN (
SELECT distinct [CAccountNum]     
  FROM [dbo].[iV_CM]
  )

DELETE FROM [dbo].[iV_ACK_header] --- only exports ACKs for customers where "Kundenversandnummer" get exported
WHERE [REF03] NOT IN (
SELECT distinct [StoreAccountNum]     
  FROM [dbo].[iV_CM]
  )
  
--COMMIT TRANSACTION


--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_ACK_pos]
           ([orderNumber]
		   ,[orderNEW]
           ,[orderPosition]
		   ,[orderPositionUPDATE]
           ,[PO101]
           ,[PO102]
           ,[PO103]
           ,[PO104]
           ,[PO105]
           ,[PO106]
           ,[PO107]
           ,[PO108]
           ,[PO109]
           ,[PO110]
           ,[PO1_cr]
           ,[PO301]
           ,[PO302]
           ,[PO303]
           ,[PO3_cr]
           ,[PID01]
           ,[PID02]
		   ,[PID_cr]
           ,[PO101_C2]
           ,[PO102_C2]
           ,[PO103_C2]
           ,[PO104_C2]
           ,[PO105_C2]
           ,[PO106_C2]
           ,[PO107_C2]
           ,[PO108_C2]
           ,[PO109_C2]
           ,[PO110_C2]
           ,[PO1_cr_C2]
           ,[PO301_C2]
           ,[PO302_C2]
           ,[PO303_C2]
           ,[PO3_cr_C2]
		   ,[PID01_C2]
		   ,[PID02_C2]
		   ,[PID_cr_C2]
           ,[PO101_ZZ]
           ,[PO102_ZZ]
           ,[PO103_ZZ]
           ,[PO104_ZZ]
           ,[PO105_ZZ]
           ,[PO106_ZZ]
           ,[PO107_ZZ]
           ,[PO108_ZZ]
           ,[PO109_ZZ]
           ,[PO110_ZZ]
           ,[PO1_cr_ZZ]
           ,[PO301_ZZ]
           ,[PO302_ZZ]
           ,[PO303_ZZ]
           ,[PO3_cr_ZZ]
		   ,[PID01_ZZ]
		   ,[PID02_ZZ]
		   ,[PID_cr_ZZ]
           ,[LOAD_DATE])
 SELECT ak.AufkNr AS orderNumber
	,CONVERT(VARCHAR(8), ak.Neu, 112)
	,ap.AufPNr AS orderPosition
	,CONVERT(VARCHAR(8), ap.Wann, 112)
	/******************************* CONFIRMED **************************/
	,'PO1' AS [PO101]
	,ag.Om - ag.Sm AS [PO102]
	,'ea' AS [PO103]
	,CAST(ap.EPrFW * (
			1 - (
				CASE 
					WHEN ap.Rabatt IS NULL
						THEN 0.00
					ELSE ap.Rabatt
					END / 100
				)
			) AS NUMERIC(14, 2)) AS [PO104]
	,'*' AS [PO105]
	,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [UPC]
	,ltrim(rtrim(ap.ArtsNr1)) AS [PO107]
	,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN]
	,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU]
	,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SupplierProductKey]
	,'<<<' AS [PO1_cr]
	,'PO3' AS [PO301]
	,'*' AS [PO302]
	,CONVERT(VARCHAR(8), getDate(), 112) AS [PO303]
	,'<<<' AS [PO3_cr]
	,'PID' AS [PID01]
	,REPLACE(REPLACE(ltrim(rtrim(ArtS.InterneBez1)), '½', '1/2'), '¾', '3/4') AS [PID02]
	,'<<<' AS [PID_cr]
	/******************************* ********* **************************/
	/******************************* CANCELLED **************************/
	/******************************* ********* **************************/
	,'PO1' AS [PO101_C2]
	--START MPF 29/9/16, cancelled styles. Need to verify with ursprungsmenge. If ursprungsmenge is set then it's an import order which behalfs a bit different
	,(CASE 
		WHEN ag.um IS NULL
			Then
				--regular captured Intex order (not from EDI)
				ag.Sm
			Else
				--EDI captured Intex Order (EDI regular or iVendix
				ag.Um-ag.om+ag.Sm
	END) AS [PO102_C2]	
	-- Comment out below, old code where as above is new
	--,ag.Sm AS [PO102_C2]
	--END MPF
	,'ea' AS [PO103_C2]
	,CAST(ap.EPrFW * (
			1 - (
				CASE 
					WHEN ap.Rabatt IS NULL
						THEN 0.00
					ELSE ap.Rabatt
					END / 100
				)
			) AS NUMERIC(14, 2)) AS [PO104_C2]
	,'*' AS [PO105_C2]
	,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [UPC_C2]
	,ltrim(rtrim(ap.ArtsNr1)) AS [PO107_C2]
	,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN_C2]
	,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU_C2]
	,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SupplierProductKey_C2]
	,'<<<' AS [PO1_cr_C2]
	,'PO3' AS [PO301_C2]
	,'C2' AS [PO302_C2]
	,CONVERT(VARCHAR(8), getDate(), 112) AS [PO303_C2]
	,'<<<' AS [PO3_cr_C2]
	,'PID' AS [PID01_C2]
	,REPLACE(REPLACE(ltrim(rtrim(ArtS.InterneBez1)), '½', '1/2'), '¾', '3/4') AS [PID02_C2]
	,'<<<' AS [PID_cr_C2]
	/******************************* OUTSTANDING **************************/
	,'PO1' AS [PO101_ZZ]
	,ag.Om - ag.Sm - ag.Lm AS [PO102_ZZ]
	,'ea' AS [PO103_ZZ]
	,CAST(ap.EPrFW * (
			1 - (
				CASE 
					WHEN ap.Rabatt IS NULL
						THEN 0.00
					ELSE ap.Rabatt
					END / 100
				)
			) AS NUMERIC(14, 2)) AS [PO104_ZZ]
	,'*' AS [PO105_ZZ]
	,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [UPC_ZZ]
	,ltrim(rtrim(ap.ArtsNr1)) AS [PO107_ZZ]
	,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [EAN_ZZ]
	,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SKU_ZZ]
	,ltrim(rtrim(ap.ArtsNr1)) + ltrim(rtrim(ap.VerkFarbe)) + ltrim(rtrim(ag.Gr)) AS [SupplierProductKey_ZZ]
	,'<<<' AS [PO1_cr_ZZ]
	,'PO3' AS [PO301_ZZ]
	,'ZZ' AS [PO302_ZZ]
	,CONVERT(VARCHAR(8), getDate(), 112) AS [PO303_ZZ]
	,'<<<' AS [PO3_cr_ZZ]
	,'PID' AS [PID01_ZZ]
	,REPLACE(REPLACE(ltrim(rtrim(ArtS.InterneBez1)), '½', '1/2'), '¾', '3/4') AS [PID02_ZZ]
	,'E=O=L' AS [PID_cr_ZZ]
	,getDate() AS [LOAD_DATE]
FROM [IFC_Cache].dbo.[AufGroesse] ag
	,[IFC_Cache].dbo.[AufKopf] ak
	,[IFC_Cache].dbo.[AufPosi] ap
	,[IFC_Cache].dbo.[ArtFarben] af
	,[IFC_Cache].dbo.[ArtStamm] ArtS
LEFT OUTER JOIN [IFC_Cache].dbo.[TpSteu] div ON (
		div.tanr = 600
		AND div.lfd = 205
		AND ArtS.[TapKey_DivNeu] = div.[tapkey]
		AND ArtS.[DivNeu] = div.tpwert
		)
	,INTEX_RAW_ArtEAN ean
LEFT OUTER JOIN [IFC_Cache].dbo.[GGaGr] gg ON (
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
		ak.AufkKey IN (SELECT DISTINCT SeasonKey COLLATE SQL_Latin1_General_CP1_CS_AS FROM ODLO_Season_Controller)
		AND ak.Art IN ('01', '04','99') --MPF 29/9/16, added OrderType 99 ('Ramsch')
		--mpf 05/08/16: in case filter by order number is required
		--AND ak.AufkNr IN  (6418715)
		--mpf 05/08/16: in case filter by customer number is required
		--AND ak.[KusNr] = 102100
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

--COMMIT TRANSACTION


--BEGIN TRANSACTION

DELETE FROM [dbo].[iV_ACK_header]
WHERE [orderNumber] NOT IN (
	SELECT distinct [orderNumber] FROM [dbo].[iV_ACK_pos]
	)

--COMMIT TRANSACTION


--BEGIN TRANSACTION

DELETE FROM [dbo].[iV_ACK_pos]
WHERE [orderNumber] NOT IN (
	SELECT distinct [orderNumber] FROM [dbo].[iV_ACK_header]
	)

--COMMIT TRANSACTION

--BEGIN TRANSACTION

INSERT INTO [dbo].[iV_ACK_amount]
           ([orderNumber]
           ,[orderPosition]
           ,[AMT01]
           ,[AMT02]
           ,[AMT_cr]
           ,[LOAD_DATE])
SELECT [orderNumber]
,max([orderPosition])+1 AS [orderPosition]
,'AMT' AS [AMT01]
      ,sum([PO102]*[PO104]) as AMT02
	  ,'E=O=L' AS [AMT_cr]
      ,getDate() AS [LOAD_DATE]
  FROM [dbo].[iV_ACK_pos]
  GROUP BY [orderNumber]

--COMMIT TRANSACTION



/*********************************************************************************************/
/***************************** label new ACK and updates *************************************/
/*********************************************************************************************/
--BEGIN TRANSACTION /***************** label as new document (00) when order was created one day ago ********************/

UPDATE [dbo].[iV_ACK_header]
SET [BAK02] = '00'
  --mpf 05/08/16: in case certain ACK need to be submitted, filter by date possible
  WHERE [orderNEW] = CONVERT(VARCHAR(8), DATEADD(day, -1, getDate()), 112) 
  --  WHERE [orderNEW] between '20131231' and '20160807'
AND [BAK02] = '--'

--COMMIT TRANSACTION


--mpf 10/08/16: unclear why the removal of 0 quantity is in here. if an order position gets imported into Intex with 0 quantity, we want to see the 0 quantity reflected back to iVendix
--hence, markus commented below delete statement out
/*
--BEGIN TRANSACTION -- remove positions with OM-SM = 0 AND new ACK

DELETE FROM [dbo].[iV_ACK_pos]
WHERE [orderNumber] IN (
	SELECT distinct [orderNumber] FROM [dbo].[iV_ACK_header] WHERE [BAK02] = '00'
	)
AND [PO102] = 0

--COMMIT TRANSACTION
*/


--BEGIN TRANSACTION /***************** label as replace document (05) when order was created more than one day ago AND order position was updated one day ago ********************/

UPDATE [dbo].[iV_ACK_header]
SET [BAK02] = '05'
FROM [dbo].[iV_ACK_header] h, 
(
SELECT distinct [orderNumber]      
  FROM [dbo].[iV_ACK_pos]
  WHERE [orderNEW] < CONVERT(VARCHAR(8), DATEADD(day, -1, getDate()), 112)  /****** order is older than yesterday **********/
  AND [orderPositionUPDATE] = CONVERT(VARCHAR(8), DATEADD(day, -1, getDate()), 112) /****** update happened yesterday **************/
  ) as tempt
WHERE h.[orderNumber] = tempt.[orderNumber]
AND h.[BAK02] <> '00'

--COMMIT TRANSACTION




--BEGIN TRANSACTION /*********************** create main file iV_ACK_app.txt **********************/

DECLARE @String varchar(2000)
SET @String='bcp "SELECT [BAK01],[BAK02],[BAK03],[BAK04],[BAK05],[BAK06],[BAK07],[BAK_cr],[REF01],[REF02],[REF03],[REF04],[REF_cr],[VE01],[VE02],[VE_cr],[ITD01],[ITD02],[ITD03],[ITD04],[ITD_cr],[DTM01],[DTM02],[DTM03],[DTM04],[DTM_cr],[TD01],[TD02],[TD03],[TD_cr],[MSG01],[MSG02],[MSG_cr],[N1ST01],[N1ST02],[N1ST03],[N1ST04],[N1ST05],[N1ST06],[N1ST07],[N1ST08],[N1ST09],[N1ST10],[N1ST_cr],[PO109_ZZ],[PO110_ZZ],[PO1_cr_ZZ],[PO301_ZZ],[PO302_ZZ],[PO303_ZZ],[PO3_cr_ZZ],[PID01_ZZ],[PID02_ZZ],[PID_cr_ZZ] FROM ['+DB_NAME()+'].[dbo].[exp_iV_ACK] ORDER BY [orderNumber],[orderPosition]" queryout '+[dbo].[GetProcPrm]('ACK_ASNPath',1)+'iV_ACK.txt -c -t^| -S -T -C ACP'  ---k -w -t^| -T -S'
EXEC xp_cmdshell @String

--COMMIT TRANSACTION





/********************************* Append all initial orders (00) as an update (05) ************************************/
--BEGIN TRANSACTION /************* do not resend 05 update orders *********************/

UPDATE [dbo].[iV_ACK_header]
SET [BAK02] = 'X5'
WHERE [BAK02] = '05'

--COMMIT TRANSACTION

--BEGIN TRANSACTION /************* relabel all new orders 00 with 05 *********************/

UPDATE [dbo].[iV_ACK_header]
SET [BAK02] = '05'
WHERE [BAK02] = '00'

--COMMIT TRANSACTION


--BEGIN TRANSACTION /****************** export the new 05 orders into second txt-file iV_ACK_app.txt *********************************/

DECLARE @String2 varchar(2000)
SET @String2='bcp "SELECT [BAK01],[BAK02],[BAK03],[BAK04],[BAK05],[BAK06],[BAK07],[BAK_cr],[REF01],[REF02],[REF03],[REF04],[REF_cr],[VE01],[VE02],[VE_cr],[ITD01],[ITD02],[ITD03],[ITD04],[ITD_cr],[DTM01],[DTM02],[DTM03],[DTM04],[DTM_cr],[TD01],[TD02],[TD03],[TD_cr],[MSG01],[MSG02],[MSG_cr],[N1ST01],[N1ST02],[N1ST03],[N1ST04],[N1ST05],[N1ST06],[N1ST07],[N1ST08],[N1ST09],[N1ST10],[N1ST_cr],[PO109_ZZ],[PO110_ZZ],[PO1_cr_ZZ],[PO301_ZZ],[PO302_ZZ],[PO303_ZZ],[PO3_cr_ZZ],[PID01_ZZ],[PID02_ZZ],[PID_cr_ZZ] FROM ['+DB_NAME()+'].[dbo].[exp_iV_ACK] ORDER BY [orderNumber],[orderPosition]" queryout '+[dbo].[GetProcPrm]('ACK_ASNPath',1)+'iV_ACK_app.txt -c -t^| -S -T -C ACP'  ---k -w -t^| -T -S'
EXEC xp_cmdshell @String2

--COMMIT TRANSACTION

END

END
GO
