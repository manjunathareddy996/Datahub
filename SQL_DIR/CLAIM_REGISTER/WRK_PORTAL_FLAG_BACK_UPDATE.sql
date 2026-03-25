CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_PORTAL_FLAG_BACK_UPDATE("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE

V_CNT NUMBER;
l_start NUMBER;
v_sqltext VARCHAR;
BEGIN
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
-- /*DBMS_MVIEW.REFRESH (''STAGE.BJAZ_WS_KIA_CLAIM_DTLS_MV'');*/
-- /* EXCEPTION */
-- /* WHEN OTHERS
--       THEN */
-- /*CALL LOGTRACE (''ERR'',
--                    10001,
--                    ''ERROR IN MV LOAD: BJAZ_WS_KIA_CLAIM_DTLS_MV'' || SQLERRM,
--                    ''bjaz_refresh_mv_claim'');*/

v_sqltext:= ''CREATE OR REPLACE TABLE INTERMEDIATE.WRK_PORTAL_FLAG_ISSUE
AS
      SELECT C_CLAIM_NO
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 5
       AND P_DEPARTMENT_DESC=''''MOTOR''''
      UNION
      SELECT
            CLM_REF
        FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_HUB_CLM_TRANS_DTLS
       WHERE DATE_TRUNC(''''DAY'''', RECORD_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 5'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_OD_CLAIM_DETAILS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_OD_CLAIM_DETAILS SELECT * FROM INTERMEDIATE.WRK_PORTAL_FLAG_ISSUE'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET NET_ASSESSED_AMOUNT = src.NET_ASSESSED_AMOUNT,
    CHANGE_DATE = TO_DATE(''''''|| T_DATE || '''''')
FROM (SELECT C_CLAIM_NO,
                      A.NET_ASSESSED_AMOUNT,
                      NET_ASSES_AMT_PARTS_LABOUR,
                      DEP_AMT
                 FROM TRANSACTIONAL.MV_CLAIM_REGISTER A, '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_SURVEYOR_ASS_DTLS X
                WHERE     A.C_CLAIM_ID = X.CLAIM_ID
                      AND NVL (NET_ASSES_AMT_PARTS_LABOUR, 0) <>
                             NVL (NET_ASSESSED_AMOUNT, 0)
                      AND C_CLAIM_NO IN (SELECT * FROM INTERMEDIATE.WRK_OD_CLAIM_DETAILS)
             GROUP BY C_CLAIM_NO,
                      A.NET_ASSESSED_AMOUNT,
                      NET_ASSES_AMT_PARTS_LABOUR,
                      DEP_AMT) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM AS target
SET NET_ASSESSED_AMOUNT = src.NET_ASSESSED_AMOUNT, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT C_CLAIM_NO,
                      A.NET_ASSESSED_AMOUNT,
                      NET_ASSES_AMT_PARTS_LABOUR,
                      DEP_AMT
                 FROM TRANSACTIONAL.MV_CLAIM_REGISTER A, '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_SURVEYOR_ASS_DTLS X
                WHERE     A.C_CLAIM_ID = X.CLAIM_ID
                      AND NVL (NET_ASSES_AMT_PARTS_LABOUR, 0) <>
                             NVL (NET_ASSESSED_AMOUNT, 0)
                      AND C_CLAIM_NO IN (SELECT * FROM INTERMEDIATE.WRK_OD_CLAIM_DETAILS)
             GROUP BY C_CLAIM_NO,
                      A.NET_ASSESSED_AMOUNT,
                      NET_ASSES_AMT_PARTS_LABOUR,
                      DEP_AMT) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MISSING_PORTAL_FLAG'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''
    INSERT INTO INTERMEDIATE.WRK_MISSING_PORTAL_FLAG
    WITH CTE AS (
        SELECT
        CLM_REF,
        COUNT (1) CNT
        FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_DETAILS WHERE CLM_REF
        IN (SELECT CLM_REF
        FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES
        LEFT JOIN TRANSACTIONAL.ODS_CLAIM_DIM AS X
        WHERE CLAIM_ID = X.C_CLAIM_ID)
        AND TOP_INDICATOR = ''''Y''''
        GROUP BY CLM_REF
        )
      SELECT *
        FROM (  SELECT
                      X.C_CLAIM_NO,
                       MAX (
                          CASE

                            WHEN MODULE_FLAG = ''''HYUNDAI_NEW''''
                             THEN
                                ''''HYUNDAI_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''CUST''''
                             THEN
                                ''''CUSTOMER_PORTAL''''

                            WHEN MODULE_FLAG = ''''EEZEETAB''''
                             THEN
                                ''''EEZEETAB''''

                            when C_CLAIM_REGD_BY =''''AEM_CLAIM''''

                                THEN  ''''WEBSITE''''
                                WHEN MODULE_FLAG = ''''HERO''''
                             THEN
                               ''''HERO WEBSERVICE''''
                                 WHEN MODULE_FLAG = ''''WindShield''''
                             THEN
                                ''''WINDSHIELD WEBSERVICE''''

                             WHEN    MODULE_FLAG = ''''REP''''
                                  OR USERNAME LIKE ''''%rep@repairer%''''
                                  OR USERNAME LIKE ''''%rep01@repairer%''''
                             THEN
                                ''''REPAIRER_PORTAL''''

                             WHEN    C_CLAIM_REGD_BY LIKE ''''%rep@repairer%''''
                                  OR C_CLAIM_REGD_BY LIKE ''''%rep01@repairer%''''
                             THEN
                                ''''REPAIRER_PORTAL''''
                             WHEN USERNAME =
                                     ''''ald.automotive@onlineclaimsportal.com''''
                             THEN
                                ''''ALD_PORTAL''''
                             WHEN USERNAME =
                                     ''''maruticlaims.ws@bajajallianz.co.in''''
                             THEN
                                ''''MIDS_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''INSURANCE WALLET''''
                             THEN
                                ''''INSURANCE_WALLET''''
                             WHEN MODULE_FLAG = ''''IMD''''
                             THEN
                                ''''IMD_PORTAL''''

                             WHEN MODULE_FLAG = ''''AEM_CLAIM''''
                             THEN
                                ''''WEBSITE''''

                             WHEN (   MODULE_FLAG = ''''OLA''''
                                   OR MODULE_FLAG = ''''OLA_NEW'''')
                             THEN
                                ''''OLA_WEBSERVICE''''
                             WHEN MODULE_FLAG IN (''''CHATPORT'''', ''''CHATBOT'''')
                             THEN
                                ''''CHATBOT''''

                             WHEN MODULE_FLAG = ''''HONDA''''
                             THEN
                                ''''HONDA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''FORD''''
                             THEN
                                ''''FORD_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''DFS''''
                             THEN
                                ''''DFS_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''BMW''''
                             THEN
                                ''''BMW_WEBSERVICE''''

                             WHEN     MODULE_FLAG = ''''HYUNDAI''''
                                  AND C_CLAIM_REGD_BY =
                                         ''''HIIB.WS@BAJAJALLIANZ.CO.IN''''
                             THEN
                                ''''HIIB_WEBSERVICE''''
                             WHEN     MODULE_FLAG = ''''HYUNDAI''''
                                  AND C_CLAIM_REGD_BY <>
                                         ''''HIIB.WS@BAJAJALLIANZ.CO.IN''''
                             THEN
                                ''''HYUNDAI_ABIBL_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''TOYOTA''''
                             THEN
                                ''''TOYOTA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''MAHINDRA''''
                             THEN
                                '''' MAHINDRA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''CITROEN''''
                             THEN
                                ''''CITROEN_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''MG''''
                             THEN
                                ''''MG_WEBSERVICE''''

                             WHEN (   USERNAME =
                                         ''''maruticlaims.ws@bajajallianz.co.in''''
                                   OR C_CLAIM_REGD_BY =
                                         ''''maruticlaims.ws@bajajallianz.co.in'''')
                             THEN
                                ''''MIDS_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''TATA''''
                             THEN
                                ''''TATA_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''KIA''''

                             THEN

                               ''''KIA_WEBSERVICE''''

                             WHEN M.CLM_REF IS NOT NULL

                             THEN

                               ''''KIA_WEBSERVICE''''

                            WHEN

                           USERNAME like ''''kiaclaims.ws%''''
                           THEN ''''KIA_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''JIP''''
                             THEN
                                ''''JIP_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''VOLVO''''
                             THEN
                                ''''VOLVO_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''YAMAHA''''
                             THEN
                                ''''YAMAHA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''AL''''
                             THEN
                                ''''ASHOK_LEYLAND_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''PB_NEW''''
                             THEN
                                ''''PB_NEW_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''RE''''
                             THEN
                                ''''ROYAL_ENFIELD_WEBSERVICE''''
                            WHEN MODULE_FLAG = ''''JL''''
                             THEN
                                ''''JCB_WEBSERVICE''''
							WHEN UPPER(MODULE_FLAG) = ''''AUDI''''
                             THEN
                                ''''AUDI_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''VOLKSWAGEN''''
                             THEN
                                ''''VOLKSWAGEN_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''SKODA''''
                             THEN
                                ''''SKODA_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''AUDI''''
                             THEN
                                ''''AUDI_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''LEXUS''''
                             THEN
                                ''''LEXUS_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''SML ISUZU''''
                             THEN
                                ''''SML ISUZU_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''BOOM''''
                             THEN
                                ''''BOOM_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''PURE EV''''
                             THEN
                                ''''PURE EV_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''HERO ELECTRIC''''
                             THEN
                                ''''HERO ELECTRIC_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''WEB''''
                             THEN
                                ''''WEB''''
                            WHEN MODULE_FLAG = ''''REPAIRER WALLET''''
                             THEN
                                ''''REPAIRER_PORTAL''''

                            WHEN MODULE_FLAG = ''''INSURANCE%20WALLET''''
                             THEN
                                ''''INSURANCE_WALLET''''
                            WHEN MODULE_FLAG = ''''VOICEBOT''''
                             THEN
                                ''''VOICEBOT''''

                            WHEN (CTE.CNT) > 0
                             THEN
                                ''''MIDS_WEBSERVICE''''

                             ELSE
                                ''''CALL_CENTER''''
                          END)
                          MODULE_FLAGGS,
                       C_PORTAL_FLAG
                  FROM TRANSACTIONAL.ODS_CLAIM_DIM X,
                       '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_ONLINE_CLAIM_DTLS A,
                       PROD_DWH_MIGRATED_DB.STAGE.GEN_CLM_USERID_MV B,
                       '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C,
                       '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT D,
                       '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_WS_KIA_CLAIM_DTLS M,
                       INTERMEDIATE.WRK_OD_CLAIM_DETAILS N,
                       CTE
                 WHERE     X.C_CLAIM_ID = A.CLAIM_ID(+)
                       AND X.C_CLAIM_NO = B.CLM_REF(+)
                       AND X.C_CLAIM_ID = C.CLAIM_ID(+)
                       AND X.C_CLAIM_ID = D.CLAIM_ID(+)
                       AND X.C_CLAIM_NO = M.CLM_REF(+)
                       AND X.C_CLAIM_NO = N.C_CLAIM_NO
                       AND X.C_CLAIM_NO = CTE.CLM_REF(+)
              GROUP BY X.C_CLAIM_NO, C_PORTAL_FLAG)
       WHERE NVL (MODULE_FLAGGS, ''''chandu'''') <> NVL (C_PORTAL_FLAG, ''''chandu'''')'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET C_PORTAL_FLAG = src.MODULE_FLAGGS,
		change_date = TO_DATE(''''''|| T_DATE || ''''''),
		TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
FROM (SELECT A.C_CLAIM_NO,
                      MODULE_FLAGGS,
                      A.C_PORTAL_FLAG,
                      B.C_PORTAL_FLAG C_PORTAL_FLAG_1
                 FROM INTERMEDIATE.WRK_MISSING_PORTAL_FLAG A,
				      TRANSACTIONAL.MV_CLAIM_REGISTER B
                WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
                      AND NVL (A.MODULE_FLAGGS, ''''CHANDU'''') <>
                             NVL (B.C_PORTAL_FLAG, ''''CHANDU'''')
                      AND P_DEPARTMENT_DESC = ''''MOTOR''''
             GROUP BY A.C_CLAIM_NO,
                      MODULE_FLAGGS,
                      A.C_PORTAL_FLAG,
                      B.C_PORTAL_FLAG) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM AS target
SET C_PORTAL_FLAG = src.MODULE_FLAGGS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.C_CLAIM_NO,
                      MODULE_FLAGGS,
                      A.C_PORTAL_FLAG,
                      B.C_PORTAL_FLAG C_PORTAL_FLAG_1
                 FROM INTERMEDIATE.WRK_MISSING_PORTAL_FLAG A,
				      TRANSACTIONAL.MV_CLAIM_REGISTER B
                WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
                      AND NVL (A.MODULE_FLAGGS, ''''CHANDU'''') <>
                             NVL (B.C_PORTAL_FLAG, ''''CHANDU'''')
                      AND P_DEPARTMENT_DESC = ''''MOTOR''''
             GROUP BY A.C_CLAIM_NO,
                      MODULE_FLAGGS,
                      A.C_PORTAL_FLAG,
                      B.C_PORTAL_FLAG) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET C_PORTAL_FLAG = src.C_PORTAL_FLAG,
		change_date = TO_DATE(''''''|| T_DATE || ''''''),
		TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
FROM (SELECT A.C_CLAIM_NO,
                      A.C_PORTAL_FLAG,
                      B.C_PORTAL_FLAG C_PORTAL_FLAG_1
                 FROM TRANSACTIONAL.ODS_CLAIM_DIM A,
					  TRANSACTIONAL.MV_CLAIM_REGISTER B
                WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
                      AND NVL (A.C_PORTAL_FLAG, ''''CHANDU'''') <>
                             NVL (B.C_PORTAL_FLAG, ''''CHANDU'''')
                      AND A.C_CLAIM_NO IN
                             (SELECT C_CLAIM_NO FROM INTERMEDIATE.WRK_OD_CLAIM_DETAILS)
                      AND P_DEPARTMENT_DESC = ''''MOTOR''''
             GROUP BY A.C_CLAIM_NO, A.C_PORTAL_FLAG, B.C_PORTAL_FLAG) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;


/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''portal_flag updation complte  in BJAZ_REFRESH_MV_CLAIM''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''BJAZ_REFRESH_MV_CLAIM'');*/
/* EXCEPTION */
/* WHEN OTHERS
   THEN */
/*CALL LOGTRACE (
         ''ERR'',
         10001,
            ''Error in WRK_PORTAL_FLAG_BACK_UPDATE claim load: ''
         || DBMS_UTILITY.format_error_backtrace ()
         || SQLCODE
         || SQLERRM,
         ''bjaz_refresh_mv_claim'');*/
/*send_sms_proc (
            ''DWH LOAD Error in WRK_PORTAL_FLAG_BACK_UPDATE  load @ ''
         || CURRENT_DATE
         || '' - ''
         || SQLERRM
         || '' caringly yours, Bajaj Allianz General Insurance Co Ltd.'',
         ''8379865547'',
         ''D'');*/


EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\\\\\n'' || ''SQL: '' || ''\\\\\\\\n'' || v_sqltext;
END;
';