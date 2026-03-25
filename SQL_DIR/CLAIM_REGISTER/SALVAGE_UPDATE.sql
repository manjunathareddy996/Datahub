CREATE OR REPLACE PROCEDURE TRANSACTIONAL.SALVAGE_UPDATE("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext VARCHAR;
X NUMBER;
MAX_DATE_SK NUMBER;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS TRANSACTIONAL.bjaz_salvage_load'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO TRANSACTIONAL.BJAZ_SALVAGE_LOAD
      SELECT A.RECEIPT_NO,
             C_CLAIM_ID_SK,
             P_POLICY_NO_SK,
             T_DATE_ID_SK,
             C_CLAIM_NO,
             9001 CC_CLM_ID,
             NVL (A.BASE_AMT, 0) * -1 TRANS_AMOUNT,
             T_DATE_DESC
        FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS_EXTN A,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS B,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES C,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_BASES D,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM E,
             PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM F,
             TRANSACTIONAL.ODS_CLAIM_DIM G
       WHERE     A.RECEIPT_NO = B.RECEIPT_NO
             AND A.CLAIM_REF IS NOT NULL
             AND A.CLAIM_REF = D.CLM_REF
             AND D.CLAIM_ID = C.CLAIM_ID
             AND C.POLICY_REF = E.P_POLICY_NUMBER
             AND D.CLM_REF = C_CLAIM_NO
             AND DATE_TRUNC(''''DAY'''', RECD_DATE) = F.T_DATE_DESC
             AND DATE_TRUNC(''''DAY'''', RECD_DATE) BETWEEN DATE_TRUNC ( ''''MONTH'''', TO_DATE('''''' || F_DATE || '''''')-1)
                                         AND DATE_TRUNC(''''DAY'''',  TO_DATE('''''' || T_DATE || '''''')) - 1
             AND E.P_CURRENT_INDICATOR = 1
      UNION
      SELECT A.RECEIPT_NO,
             C_CLAIM_ID_SK,
             P_POLICY_NO_SK,
             T_DATE_ID_SK,
             C_CLAIM_NO,
             9001 CC_CLM_ID,
             NVL (A.BASE_AMT, B.TRANS_AMOUNT) TRANS_AMT,
             T_DATE_DESC                                           --,''''CHQDIS''''
        FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS_EXTN A,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS B,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES C,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_BASES D,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM E,
             PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM F,
             TRANSACTIONAL.ODS_CLAIM_DIM G,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_64VB_COLL_STAGE H
       WHERE     A.RECEIPT_NO = B.RECEIPT_NO
             AND A.RECEIPT_NO = H.RECEIPT_NO
             AND A.CLAIM_REF IS NOT NULL
             AND A.CLAIM_REF = D.CLM_REF
             AND D.CLAIM_ID = C.CLAIM_ID
             AND C.POLICY_REF = E.P_POLICY_NUMBER
             AND D.CLM_REF = C_CLAIM_NO
             AND DATE_TRUNC(''''DAY'''', H.ENTRY_DATE) = F.T_DATE_DESC
             AND E.P_CURRENT_INDICATOR = 1
             AND DATE_TRUNC(''''DAY'''', H.ENTRY_DATE) BETWEEN DATE_TRUNC (''''MONTH'''', TO_DATE('''''' || F_DATE || '''''')-1)
                                         AND DATE_TRUNC(''''DAY'''',  TO_DATE('''''' || T_DATE || '''''')) - 1
             AND H.TOP_IND = ''''Y''''
             AND H.CHEQUE_STATUS = ''''B''''
             AND H.CLEAR_TYPE LIKE ''''%P''''
      UNION
      SELECT A.RECEIPT_NO,
             C_CLAIM_ID_SK,
             P_POLICY_NO_SK,
             T_DATE_ID_SK,
             C_CLAIM_NO,
             9001 CC_CLM_ID,
             NVL (A.BASE_AMT, B.TRANS_AMOUNT) TRANS_AMOUNT,
             T_DATE_DESC                                   --,''''RECD cancelled''''
        FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS_EXTN A,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS B,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES C,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_BASES D,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM E,
             PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM F,
             TRANSACTIONAL.ODS_CLAIM_DIM G,
             ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CANCEL_RCPT_HISTORY H
       WHERE     A.RECEIPT_NO = B.RECEIPT_NO
             AND A.RECEIPT_NO = H.RECEIPT_NO
             AND A.CLAIM_REF IS NOT NULL
             AND RECEIPT_REQ_ID IS NOT NULL              -- receipt  cancelled
             AND A.CLAIM_REF = D.CLM_REF
             AND D.CLAIM_ID = C.CLAIM_ID
             AND C.POLICY_REF = E.P_POLICY_NUMBER
             AND D.CLM_REF = C_CLAIM_NO
             AND DATE_TRUNC(''''DAY'''', CANCEL_DATE) = F.T_DATE_DESC
             AND DATE_TRUNC(''''DAY'''', CANCEL_DATE) BETWEEN DATE_TRUNC (''''MONTH'''', TO_DATE('''''' || F_DATE || '''''')-1)
                                         AND DATE_TRUNC(''''DAY'''',  TO_DATE('''''' || T_DATE || '''''')) - 1
             AND E.P_CURRENT_INDICATOR = 1'';
EXECUTE IMMEDIATE v_sqltext;


/*--------merge into ods_claim_fact ---------*/

v_sqltext := ''MERGE
           INTO  TRANSACTIONAL.ODS_CLAIM_FACT
           USING (  SELECT C_CLAIM_ID_SK,
                           P_POLICY_NO_SK,
                           T_DATE_ID_SK,
                           SUM (TRANS_AMOUNT) TRANS_AMOUNT
                      FROM TRANSACTIONAL.BJAZ_SALVAGE_LOAD
                  GROUP BY C_CLAIM_ID_SK, P_POLICY_NO_SK, T_DATE_ID_SK) A
              ON (    ODS_CLAIM_FACT.C_CLAIM_ID_SK = A.C_CLAIM_ID_SK
                  AND ODS_CLAIM_FACT.P_POLICY_NO_SK = A.P_POLICY_NO_SK
                  AND ODS_CLAIM_FACT.T_DATE_ID_SK = A.T_DATE_ID_SK
                  AND ODS_CLAIM_FACT.R_RESERVE_TYPE_ID = 9001)
      WHEN MATCHED
      THEN
         UPDATE SET          -- ods_claim_fact.c_claim_id_sk=a.c_claim_id_sk ,
                    --ods_claim_fact.p_policy_no_sk =a.p_policy_no_sk,
                    ---ods_claim_fact.t_date_id_sk =a.t_date_id_sk,
                    --- ods_claim_fact.r_reserve_type_id =9001,
                    ODS_CLAIM_FACT.SALVAGE_AMOUNT = A.TRANS_AMOUNT
      --ods_claim_fact.cc_cc_claimtype_id_sk =1
      WHEN NOT MATCHED
      THEN
         INSERT     (C_CLAIM_ID_SK,
                     P_POLICY_NO_SK,
                     T_DATE_ID_SK,
                     R_RESERVE_TYPE_ID,
                     RESERVE_AMOUNT,
                     PAID_CLAIM_AMOUNT,
                     SALVAGE_AMOUNT,
                     CC_CC_CLAIMTYPE_ID_SK,
                     RECOVERY_AMOUNT,
                     SERVICE_TAX)
             VALUES (A.C_CLAIM_ID_SK,
                     A.P_POLICY_NO_SK,
                     A.T_DATE_ID_SK,
                     9001,
                     0,
                     0,
                     A.TRANS_AMOUNT,
                     1,
                     0,
                     0)'';
EXECUTE IMMEDIATE v_sqltext;

CALL BAGIC_PROD_CURATED_DB.TRANSACTIONAL.WRK_PMJAY_RECOVERY_PRC(''BAGIC_PROD_MIRROR_DB'');

EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;

END;
';