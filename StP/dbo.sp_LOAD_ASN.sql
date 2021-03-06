SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************************************************/
-- Author:		Marc Ziegler
-- Create date: 21.4.2016
-- Description:	Load and update all interface table from INTEX.
-- Change Hist:  05.09.2017 Jimmy Rüedi
--               Change from direct access to [INTEXSALES].[OdloDE] to [IFC_Cache]
/***********************************************************************************************************************/
ALTER PROCEDURE [dbo].[sp_LOAD_ASN]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @String VARCHAR(2000)

	BEGIN
		--BEGIN TRANSACTION

		TRUNCATE TABLE [dbo].[iV_ASN_header]

		TRUNCATE TABLE [dbo].[iV_ASN_delivery]

		TRUNCATE TABLE [dbo].[iV_ASN_pos]

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION

		INSERT INTO [dbo].[iV_ASN_header] (
			[orderNumber]
			,[delivNumber]
			,[delivJahr]
			,[delivRekKey]
			,[parcelNumber]
			,[delivPosition]
			,[CI01]
			,[CI02]
			,[CI03]
			,[CI04]
			,[CI05]
			,[CI06]
			,[CI07]
			,[CI_cr]
			,[VE01]
			,[VE02]
			,[VE_cr]
			,[SHIPADDR01]
			,[SHIPADDR02]
			,[SHIPADDR03]
			,[SHIPADDR04]
			,[SHIPADDR05]
			,[SHIPADDR06]
			,[SHIPADDR07]
			,[SHIPADDR08]
			,[SHIPADDR09]
			,[SHIPADDR_cr]
			,[ORD01]
			,[ORD02]
			,[ORD03]
			,[ORD_cr]
			,[LOAD_DATE]
			)
		SELECT DISTINCT ack.[orderNumber] AS [orderNumber]
			,rko.LNr AS [delivNumber]
			,rko.Jahr as [delivJahr]
			,rko.RekKey as [delivRekKey]
			,0 AS [parcelNumber]
			,0 AS [delivPosition]
			,'CI' AS [CI01]
			,'*' AS [CI02]
			,'*' AS [CI03]
			,CONVERT(VARCHAR(8), rko.AuslieferDatum, 112) AS [CI04]
			,rko.LNr AS [CI05]
			,'2' AS [CI06]
			,'*' AS [CI07]
			,'<<<' AS [CI_cr]
			,[VE01] AS [VE01]
			,[VE02] AS [VE02]
			,[VE_cr] AS [VE_cr]
			,'SHIPADDR' AS [SHIPADDR01]
			,[N1ST02] AS [SHIPADDR02]
			,[N1ST04] AS [SHIPADDR03]
			,[N1ST05] AS [SHIPADDR04]
			,[N1ST06] AS [SHIPADDR05]
			,[N1ST07] AS [SHIPADDR06]
			,[N1ST08] AS [SHIPADDR07]
			,[N1ST09] AS [SHIPADDR08]
			,'*' AS [SHIPADDR09]
			,'<<<' AS [SHIPADDR_cr]
			,'ORD' AS [ORD01]
			,CASE WHEN (ack.[EinArt] = '05' AND ack.[KdAuftrNr2] IS NOT NULL) THEN CONVERT([int],ack.[KdAuftrNr2]) ELSE 0 END AS [ORD02]
			,CASE WHEN (ack.[EinArt] = '05' AND ack.[KdAuftrNr2] IS NOT NULL) THEN '*' ELSE CONVERT(varchar(80),ack.[orderNumber]) END AS [ORD03]
			,'E=O=L' AS [ORD_cr]
			,getDate() AS [LOAD_DATE]
		FROM [IFC_Cache].[dbo].[ReKopf] rko
			,[IFC_Cache].dbo.RePosi rpo
			,[dbo].[iV_ACK_header] ack  --- send only ShippingNotice for existing orders/aknowledgements
		WHERE (
				rko.[LNr] = rpo.LNr
				AND rko.Jahr = rpo.Jahr
				AND rko.RekKey = rpo.RekKey
				)
			AND (ack.orderNumber = rpo.AufkNr)
			AND rko.[ExportiertKz] = 'U' /********** an Spedition übergeben ******************/
			AND rko.[Vers2Gedruckt] <> 'J' /************ ASN not sent to iVendix *************/ --- Flag in INTEX to identify if already sent or not (update happens below)

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION

		INSERT INTO [dbo].[iV_ASN_delivery] (
			[orderNumber]
			,[delivNumber]
			,[parcelNumber]
			,[delivPosition]
			,[PI01]
			,[PI02]
			,[PI03]
			,[PI04]
			,[PI05]
			,[PI_cr]
			,[LOAD_DATE]
			)
		SELECT asn.[orderNumber] AS [orderNumber]
			,rko.LNr AS [delivNumber]
			,rpa.PaketNr AS [parcelNumber]
			,0 AS [delivPosition]
			,'PI' AS [PI01]
			,'Pack_code' AS [PI02]
			,rpa.BruttoGewicht AS [PI03]
			,'kg' AS [PD04]
			,rpa.PaketIdentNr AS [PI05]
			,'E=O=L' AS [PI_cr]
			,getDate() AS [LOAD_DATE]
		FROM [IFC_Cache].dbo.RePaket rpa
			,[IFC_Cache].[dbo].[ReKopf] rko
			,[dbo].[iV_ASN_header] asn
		WHERE (
				rpa.LNr = rko.LNr
				AND rpa.Jahr = rko.Jahr
				AND rpa.RekKey = rko.RekKey
				)
			AND rko.LNr = asn.[delivNumber]
			AND rko.[ExportiertKz] = 'U' /********** an Spedition übergeben ******************/
			 AND rko.[Vers2Gedruckt] <> 'J' /************ ASN not sent to iVendix *************/

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION

		INSERT INTO [dbo].[iV_ASN_pos] (
			[orderNumber]
			,[delivNumber]
			,[parcelNumber]
			,[delivPosition]
			,[PD01]
			,[PD02]
			,[PD03]
			,[PD04]
			,[PD05]
			,[PD06]
			,[PD07]
			,[PD_cr]
			,[LOAD_DATE]
			)
		SELECT rpo.AufkNr AS [orderNumber]
			,rpo.LNr AS [delivNumber]
			,rpa.PaketNr AS [parcelNumber]
			,rpo.RePNr AS [delivPosition]
			,'PD' AS [PD01]
			,rpi.Teile AS [PD02]
			,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [PD03]
			,ltrim(rtrim(LEFT(ean.EANCode, 20))) AS [PD04]
			,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [PD05]
			,ltrim(rtrim(ean.ArtsNr1)) + ltrim(rtrim(ean.VerkFarbe)) + ltrim(rtrim(ean.Gr)) AS [PD06]
			,'*' AS [PD07]
			,'E=O=L' AS [PD_cr]
			,getDate() AS [LOAD_DATE]
		FROM [IFC_Cache].dbo.RePosi rpo
			,[IFC_Cache].dbo.RePaket rpa
		LEFT OUTER JOIN [IFC_Cache].dbo.ReKopf rko ON rpa.LNr = rko.LNr
			AND rpa.Jahr = rko.Jahr
			AND rpa.RekKey = rko.RekKey
			AND rpa.RNr = rko.RNr
			AND rpa.RekSaisKey = rko.RekSaisKey
			,[IFC_Cache].dbo.ReGroesse rgr
			,[IFC_Cache].dbo.RePakInhalt rpi
			,[IFC_Cache].[dbo].[ArtEAN] ean 
			,[dbo].[iV_ASN_delivery] asn       
			--(SELECT orderNumber, delivNumber, parcelNumber, delivPosition, PI01, PI02, PI03, PI04, PI05, PI_cr FROM [dbo].[iV_ASN_delivery] asn)
		WHERE (
				rpo.LNr = rko.LNr
				AND rpo.Jahr = rko.Jahr
				AND rpo.RekKey = rko.RekKey
				)
			AND (
				rpo.LNr = rgr.LNr
				AND rpo.Jahr = rgr.Jahr
				AND rpo.RekKey = rgr.RekKey
				AND rpo.RePNr = rgr.RePNr
				)
			AND (
				rpi.LNr = rgr.LNr
				AND rpi.[Jahr] = rgr.[Jahr]
				AND rpi.[RekKey] = rgr.[RekKey]
				AND rpi.[Lfd] = rpa.[Lfd]
				AND rpi.[RePNr] = rgr.[RePNr]
				AND rpi.[GGanKey] = rgr.[GGanKey]
				AND rpi.[GGNr] = rgr.[GGNr]
				AND rpi.[Gr] = rgr.[Gr]
				)
			AND (
				ean.[ArtsNr1] = rpo.[ArtsNr1]
				AND ean.[ArtsNr2] = rpo.[ArtsNr2]
				AND ean.[ArtsKey] = rpo.[ArtsKey]
				AND ean.[VerkFarbe] = rpo.[VerkFarbe]
				AND ean.[GGanKey] = rgr.[GGanKey]
				AND ean.[GGNr] = rgr.[GGNr]
				AND ean.[Gr] = rgr.[Gr]
				)
			AND (
				asn.[orderNumber] = rpo.AufkNr
				AND asn.[delivNumber] = rpo.LNr
				AND asn.[parcelNumber] = rpa.PaketNr
				)
			AND rko.[ExportiertKz] = 'U' /********** an Spedition übergeben ******************/
			AND rko.[Vers2Gedruckt] <> 'J' /************ ASN not sent to iVendix *************/

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION

		DELETE
		FROM [dbo].[iV_ASN_delivery]
		WHERE [delivNumber] NOT IN (
				SELECT DISTINCT [delivNumber]
				FROM [dbo].[iV_ASN_pos]
				)

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION

		DELETE
		FROM [dbo].[iV_ASN_header]
		WHERE [orderNumber] NOT IN (
				SELECT DISTINCT [orderNumber]
				FROM [dbo].[iV_ASN_delivery]
				)

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION

		SET @String = 'bcp "SELECT [CI01],[CI02],[CI03],[CI04],[CI05],[CI06],[CI07],[CI_cr],[VE01],[VE02],[VE_cr],[SHIPADDR01],[SHIPADDR02],[SHIPADDR03],[SHIPADDR04],[SHIPADDR05],[SHIPADDR06],[SHIPADDR07],[SHIPADDR08],[SHIPADDR09],[SHIPADDR_cr],[ORD01],[ORD02],[ORD03],[ORD_cr]  FROM ['+DB_NAME()+'].[dbo].[exp_iV_ASN] ORDER BY [orderNumber],[delivNumber],[parcelNumber],[delivPosition]" queryout '+[dbo].[GetProcPrm]('ACK_ASNPath',1)+'iV_ASN.txt -c -t^| -S -T -C ACP' ---k -w -t^| -T -S'

		EXEC xp_cmdshell @String

		--COMMIT TRANSACTION

		--BEGIN TRANSACTION /************************* mark deliveries in INTEX (ReKopf.Vers2Gedruckt) which have been exported to iVendix ****************/

		UPDATE [INTEXSALES].[OdloDE].dbo.ReKopf
		SET [Vers2Gedruckt] = 'J'
		--> JRU, 05.2017 Shouldn't the update be completely transparent?
		--, Wann = GETDATE()        --> JRU: shouldn't this be set?
		--, Wer = 'sentToiVendix'   --> JRU: shouldn't this be set?
		FROM [INTEXSALES].[OdloDE].dbo.ReKopf rk,
		(
		SELECT distinct [delivNumber], [delivJahr], [delivRekKey] FROM [dbo].[iV_ASN_header]
		) as temptt
		WHERE [LNr] = [delivNumber]
		AND [Jahr] = [delivJahr]
		AND [RekKey] = [delivRekKey] COLLATE SQL_Latin1_General_CP1_CS_AS

		--COMMIT TRANSACTION




	END
END
GO
