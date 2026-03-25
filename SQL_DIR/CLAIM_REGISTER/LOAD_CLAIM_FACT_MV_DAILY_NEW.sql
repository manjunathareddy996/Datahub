CREATE OR REPLACE PROCEDURE TRANSACTIONAL.LOAD_CLAIM_FACT_MV_DAILY_NEW("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '

DECLARE
v_sqltext VARCHAR;
V_T_DATE_ID_SK NUMBER;

BEGIN


SELECT T_DATE_ID_SK INTO :V_T_DATE_ID_SK FROM PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM WHERE T_DATE_DESC = DATE_TRUNC(''DAY'', :T_DATE) - 1;

/*----------------------create coins_bases_extn table for share rate --------------------*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.VW_BJAZ_COINS_BASES_EXTN_TBL'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.VW_BJAZ_COINS_BASES_EXTN_TBL
      SELECT * FROM PROD_DWH_MIGRATED_DB.PROD.VW_BJAZ_CO_INS_BASES_EXTN'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_FACT_STG1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_FACT_STG1
      SELECT C.POLICY_REF, B.*
        FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.OCP_POLICY_VERSIONS A,
             INTERMEDIATE.VW_BJAZ_COINS_BASES_EXTN_TBL B,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.OCP_POLICY_BASES C
       WHERE     A.CONTRACT_ID = B.CONTRACT_ID
             AND B.ACTION_CODE <> ''''D''''
             AND A.VERSION_NO = B.VERSION_NO
             AND A.CONTRACT_ID = C.CONTRACT_ID
             AND A.VERSION_NO = C.VERSION_NO
             AND B.VERSION_NO =
                    (SELECT MAX (VERSION_NO)
                       FROM INTERMEDIATE.VW_BJAZ_COINS_BASES_EXTN_TBL KK
                      WHERE     KK.CONTRACT_ID = A.CONTRACT_ID
                            AND KK.VERSION_NO <= A.VERSION_NO
                            AND KK.COMPANY_CODE = B.COMPANY_CODE
                            AND KK.OBJECT_ID = B.OBJECT_ID)
             AND C.VERSION_NO =
                    (SELECT MAX (VERSION_NO)
                       FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.OCP_POLICY_BASES KK
                      WHERE     KK.CONTRACT_ID = A.CONTRACT_ID
                            AND KK.VERSION_NO <= A.VERSION_NO)
             AND EXISTS
                    (SELECT P_POLICY_NUMBER
                       FROM TRANSACTIONAL.ODS_CLAIM_FACT A, PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM B
                      WHERE     P_CURRENT_INDICATOR = 1
                            AND A.P_POLICY_NO_SK = B.P_POLICY_NO_SK
                            AND T_DATE_ID_SK = ''||V_T_DATE_ID_SK||''
                            AND P_POLICY_NUMBER = POLICY_REF)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_FACT_STG_2'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_FACT_STG_2
        SELECT POLICY_REF,
               COMPANY_CODE,
               LEADER,
               SHARE_RATE
          FROM INTERMEDIATE.WRK_CLAIM_FACT_STG1
         WHERE ACTION_CODE <> ''''D''''
      GROUP BY POLICY_REF,
               COMPANY_CODE,
               SHARE_RATE,
               LEADER'';
EXECUTE IMMEDIATE v_sqltext;

/*-------------------------no coinsuarnce ----------------------*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_MV_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_MV_1
        SELECT C.C_CLAIM_ID_SK C_CLAIM_ID_SK,
               C.P_POLICY_NO_SK P_POLICY_NO_SK,
               1 COMPANY_CODE,
               C.T_DATE_ID_SK T_DATE_ID_SK,
               C.CC_CC_CLAIMTYPE_ID_SK CC_CLAIM_TYPE_ID_SK,
               C.R_RESERVE_TYPE_ID R_RESERVE_TYPE_ID,
               SUM (PAID_CLAIM_AMOUNT) PAID_CLAIM,
               SUM (RESERVE_AMOUNT) RESERVE_AMOUNT,
               SUM (SALVAGE_AMOUNT) SALVAGE_AMOUNT,
               SUM (SERVICE_TAX) SERVICE_TAX,
               SUM (PAID_CLAIM_AMOUNT) - SUM (SERVICE_TAX) NET_PAID,
               SUM (SERVICE_TAX) S_TAX,
               SUM (RECOVERY_INITIATED) RECOVERY_INITIATED,
               SUM (RECOVERY_DONE) RECOVERY_DONE,
               SUM (RECOVERY_PENDING) RECOVERY_PENDING
          FROM TRANSACTIONAL.ODS_CLAIM_FACT C, PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D
         WHERE     C.P_POLICY_NO_SK = D.P_POLICY_NO_SK
               AND D.P_COINSURANCE_TYPE IS NULL
               AND T_DATE_ID_SK = ''||V_T_DATE_ID_SK||''
      GROUP BY C.C_CLAIM_ID_SK,
               C.P_POLICY_NO_SK,
               1,
               C.T_DATE_ID_SK,
               C.CC_CC_CLAIMTYPE_ID_SK,
               C.R_RESERVE_TYPE_ID'';
EXECUTE IMMEDIATE v_sqltext;

/*----------------------where we are Follower --------------------------*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_MV_2'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_MV_2
        SELECT DISTINCT
               C.C_CLAIM_ID_SK C_CLAIM_ID_SK,
               C.P_POLICY_NO_SK P_POLICY_NO_SK,
               DECODE (E.COMPANY_CODE,  1, 6,  6, 1,  COMPANY_CODE)
                  COMPANY_CODE,
               C.T_DATE_ID_SK T_DATE_ID_SK,
               C.CC_CC_CLAIMTYPE_ID_SK CC_CLAIM_TYPE_ID_SK,
               C.R_RESERVE_TYPE_ID R_RESERVE_TYPE_ID,
               SUM (PAID_CLAIM_AMOUNT) PAID_CLAIM,
               SUM (RESERVE_AMOUNT) RESERVE_AMOUNT,
               SUM (SALVAGE_AMOUNT) SALVAGE_AMOUNT,
               SUM (SERVICE_TAX) SERVICE_TAX,
               SUM (PAID_CLAIM_AMOUNT) - SUM (SERVICE_TAX) NET_PAID,
               SUM (SERVICE_TAX) S_TAX,
               SUM (RECOVERY_INITIATED) RECOVERY_INITIATED,
               SUM (RECOVERY_DONE) RECOVERY_DONE,
               SUM (RECOVERY_PENDING) RECOVERY_PENDING
          FROM TRANSACTIONAL.ODS_CLAIM_FACT C, PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D, INTERMEDIATE.WRK_CLAIM_FACT_STG_2 E
         WHERE     C.P_POLICY_NO_SK = D.P_POLICY_NO_SK
               AND T_DATE_ID_SK = ''||V_T_DATE_ID_SK||''
               AND E.POLICY_REF = D.P_POLICY_NUMBER
               AND P_CURRENT_INDICATOR = 1
               AND E.COMPANY_CODE = 6
               AND D.P_COINSURANCE_TYPE = ''''IN''''
      GROUP BY C.C_CLAIM_ID_SK,
               C.P_POLICY_NO_SK,
               DECODE (E.COMPANY_CODE,  1, 6,  6, 1,  COMPANY_CODE),
               C.T_DATE_ID_SK,
               C.CC_CC_CLAIMTYPE_ID_SK,
               C.R_RESERVE_TYPE_ID'';
EXECUTE IMMEDIATE v_sqltext;

/*-----------------------coinsurance where we are leader*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_MV_3'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_MV_3
      (  SELECT DISTINCT A.C_CLAIM_ID_SK,
                         A.P_POLICY_NO_SK,
                         A.COMPANY_CODE,
                         A.T_DATE_ID_SK,
                         A.CC_CLAIM_TYPE_ID_SK,
                         A.R_RESERVE_TYPE_ID,
                         CEIL (SUM (A.PAID_CLAIM)) PAID_CLAIM,
                          CEIL
                         (SUM (A.RESERVE_AMOUNT)) RESERVE_AMOUNT,
                         CEIL (SUM (A.SALVAGE_AMOUNT)) SALVAGE_AMOUNT,
                         CEIL (SUM (A.SERVICE_TAX)) SERVICE_TAX,
                         NVL (SUM (NET_PAID), 0) NET_PAID,
                         NVL (SUM (NET_SERVICE_TAX), 0) NET_TAX,
                         NVL (SUM (RECOVERY_INITIATED), 0) RECOVERY_INITIATED,
                         NVL (SUM (RECOVERY_DONE), 0) RECOVERY_DONE,
                         NVL (SUM (RECOVERY_PENDING), 0) RECOVERY_PENDING
           FROM (  SELECT C_CLAIM_ID_SK,
                          P_POLICY_NO_SK,
                          1 COMPANY_CODE,
                          T_DATE_ID_SK,
                          CC_CLAIM_TYPE_ID_SK,
                          R_RESERVE_TYPE_ID,
                          TOTAL_PAID - SUM (OTH_PAID_CLAIM) + SUM (SERVICE_TAX)
                             PAID_CLAIM,
                          TOTAL_RESERVE_AMOUNT - SUM (OTH_RESERVE_AMOUNT)
                             RESERVE_AMOUNT,
                          SUM (SALVAGE_AMOUNT) SALVAGE_AMOUNT,
                          SUM (SERVICE_TAX) SERVICE_TAX,
                          0 NET_PAID,
                          0 NET_SERVICE_TAX,
                          SUM (RECOVERY_INITIATED) RECOVERY_INITIATED,
                          SUM (RECOVERY_DONE) RECOVERY_DONE,
                          SUM (RECOVERY_PENDING) RECOVERY_PENDING
                     FROM (  SELECT
                                   C.C_CLAIM_ID_SK C_CLAIM_ID_SK,
                                    C.P_POLICY_NO_SK P_POLICY_NO_SK,
                                    DECODE (E.COMPANY_CODE,
                                            1, 6,
                                            6, 1,
                                            COMPANY_CODE)
                                       COMPANY_CODE,
                                    C.T_DATE_ID_SK T_DATE_ID_SK,
                                    C.CC_CC_CLAIMTYPE_ID_SK CC_CLAIM_TYPE_ID_SK,
                                    C.R_RESERVE_TYPE_ID R_RESERVE_TYPE_ID,
                                    SUM (
                                       CEIL (
                                          CASE
                                             WHEN COMPANY_CODE = 6
                                             THEN
                                                0
                                             ELSE
                                                  0.01
                                                * SHARE_RATE
                                                * NVL (
                                                     (  PAID_CLAIM_AMOUNT
                                                      - NVL (SERVICE_TAX, 0)),
                                                     0)
                                          END))
                                       OTH_PAID_CLAIM,
                                    SUM (
                                        CEIL
                                       (
                                          CASE
                                             WHEN COMPANY_CODE = 6
                                             THEN
                                                0
                                             ELSE
                                                (0.01 * SHARE_RATE * RESERVE_AMOUNT)
                                          END))
                                       OTH_RESERVE_AMOUNT,
                                    SUM (
                                       CEIL (
                                          CASE
                                             WHEN COMPANY_CODE = 6
                                             THEN
                                                (0.01 * SHARE_RATE * SALVAGE_AMOUNT)
                                             ELSE
                                                0
                                          END))
                                       SALVAGE_AMOUNT,
                                    SUM (
                                       CASE
                                          WHEN COMPANY_CODE = 6 THEN SERVICE_TAX
                                          ELSE 0
                                       END)
                                       SERVICE_TAX,
                                    SUM (
                                       NVL (
                                          (PAID_CLAIM_AMOUNT - NVL (SERVICE_TAX, 0)),
                                          0))
                                       TOTAL_PAID,
                                    SUM (NVL (RESERVE_AMOUNT, 0))
                                       TOTAL_RESERVE_AMOUNT,
                                       SUM (RECOVERY_INITIATED) RECOVERY_INITIATED,
                                    SUM (RECOVERY_DONE) RECOVERY_DONE,
                                    SUM (RECOVERY_PENDING) RECOVERY_PENDING
                               FROM TRANSACTIONAL.ODS_CLAIM_FACT C,
                                    PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D,
                                    INTERMEDIATE.WRK_CLAIM_FACT_STG_2 E
                              WHERE     C.P_POLICY_NO_SK = D.P_POLICY_NO_SK
                                    AND T_DATE_ID_SK = ''||V_T_DATE_ID_SK||''
                                    AND E.POLICY_REF = D.P_POLICY_NUMBER
                                    AND D.P_COINSURANCE_TYPE = ''''OUT''''
                           GROUP BY C.C_CLAIM_ID_SK,
                                    SHARE_RATE,
                                    C.P_POLICY_NO_SK,
                                    E.COMPANY_CODE,
                                    C.T_DATE_ID_SK,
                                    C.CC_CC_CLAIMTYPE_ID_SK,
                                    C.R_RESERVE_TYPE_ID)
                 GROUP BY C_CLAIM_ID_SK,
                          P_POLICY_NO_SK,
                          T_DATE_ID_SK,
                          CC_CLAIM_TYPE_ID_SK,
                          R_RESERVE_TYPE_ID,
                          TOTAL_PAID,
                          TOTAL_RESERVE_AMOUNT
                 UNION
                   SELECT
                         C.C_CLAIM_ID_SK C_CLAIM_ID_SK,
                          C.P_POLICY_NO_SK P_POLICY_NO_SK,
                          DECODE (E.COMPANY_CODE,  1, 6,  6, 1,  COMPANY_CODE)
                             COMPANY_CODE,
                          C.T_DATE_ID_SK T_DATE_ID_SK,
                          C.CC_CC_CLAIMTYPE_ID_SK CC_CLAIM_TYPE_ID_SK,
                          C.R_RESERVE_TYPE_ID R_RESERVE_TYPE_ID,
                          SUM (
                             CEIL (
                                  0.01
                                * SHARE_RATE
                                * NVL (
                                     (PAID_CLAIM_AMOUNT - NVL (SERVICE_TAX, 0)),
                                     0)))
                             PAID_CLAIM,
                          SUM (
                           CEIL
                          ( (0.01 * SHARE_RATE * RESERVE_AMOUNT)))
                             RESERVE_AMOUNT,
                          SUM (CEIL ( (0.01 * SHARE_RATE * SALVAGE_AMOUNT)))
                             SALVAGE_AMOUNT,
                          0 SERVICE_TAX,
                          0 NET_PAID,
                          0 NET_TAX,
                          SUM (RECOVERY_INITIATED) RECOVERY_INITIATED,
                          SUM (RECOVERY_DONE) RECOVERY_DONE,
                          SUM (RECOVERY_PENDING) RECOVERY_PENDING
                     FROM TRANSACTIONAL.ODS_CLAIM_FACT C,
                          PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D,
                          INTERMEDIATE.WRK_CLAIM_FACT_STG_2 E
                    WHERE     C.P_POLICY_NO_SK = D.P_POLICY_NO_SK
                          AND T_DATE_ID_SK = ''||V_T_DATE_ID_SK||''
                          AND E.POLICY_REF = D.P_POLICY_NUMBER
                          AND D.P_COINSURANCE_TYPE = ''''OUT''''
                          AND COMPANY_CODE <> 6
                 GROUP BY C.C_CLAIM_ID_SK,
                          SHARE_RATE,
                          C.P_POLICY_NO_SK,
                          E.COMPANY_CODE,
                          C.T_DATE_ID_SK,
                          C.CC_CC_CLAIMTYPE_ID_SK,
                          C.R_RESERVE_TYPE_ID) A
       GROUP BY A.C_CLAIM_ID_SK,
                A.P_POLICY_NO_SK,
                A.COMPANY_CODE,
                A.T_DATE_ID_SK,
                A.CC_CLAIM_TYPE_ID_SK,
                A.R_RESERVE_TYPE_ID)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_CLAIM_FACT_MV (C_CLAIM_ID_SK,
                                  P_POLICY_NO_SK,
                                  COMPANY_CODE,
                                  T_DATE_ID_SK,
                                  CC_CC_CLAIMTYPE_ID_SK,
                                  R_RESERVE_TYPE_ID,
                                  PAID_CLAIM,
                                  RESERVE_AMOUNT,
                                  SALVAGE_AMOUNT,
                                  SERVICE_TAX,
                                  NET_PAID,
                                  NET_TAX,
                                  RECOVERY_INITIATED,
                                  RECOVERY_DONE,
                                  RECOVERY_PENDING)
      SELECT
            * FROM INTERMEDIATE.WRK_CLAIM_MV_1
      UNION
      SELECT
            * FROM INTERMEDIATE.WRK_CLAIM_MV_2
      UNION
      SELECT
            * FROM INTERMEDIATE.WRK_CLAIM_MV_3'';
EXECUTE IMMEDIATE v_sqltext;


EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
       RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;


END;
';