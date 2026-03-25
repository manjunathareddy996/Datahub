CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_PMJAY_RECOVERY_PRC("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
  DAY_VALUE INTEGER;
  v_sqltext VARCHAR;
BEGIN
  -- Truncate the work table
v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_OTHER_CLM_RECOVERY'';
EXECUTE IMMEDIATE v_sqltext;

  -- Insert data into the work table
v_sqltext := ''insert into INTERMEDIATE.WRK_OTHER_CLM_RECOVERY
    SELECT C_CLAIM_NO,
           P_POLICY_NUMBER,
           T_DATE_DESC,
           A.PAY_APP_NO,
           RECEIVE_AMOUNT AS RECOVERY_INITIATED,
           CAST(NULL AS FLOAT) AS RECOVERY_DONE,
           RECEIVE_AMOUNT AS RECOVERY_PENDING,
           C_CLAIM_ID_SK,
           P_POLICY_NO_SK,
           T_DATE_ID_SK,
           10208 AS R_RESERVE_TYPE_ID,
           1 AS CC_CC_CLAIMTYPE_ID_SK
      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_NCB_ACC_RECOVERY_DTLS A,
           TRANSACTIONAL.ODS_CLAIM_DIM B,
           -- TRANSACTIONAL.ODS_POLICY_DIM C, -- Pointed  to view on 22nd Sept, 2025
           PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM C,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL D,
           PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM E
     WHERE A.CLM_REF = B.C_CLAIM_NO
       AND A.POLICY_REF = C.P_POLICY_NUMBER
       AND COALESCE(P_CURRENT_INDICATOR, 0) = 1
       AND A.CLM_REF = D.CLM_REF
       AND A.PAY_APP_NO = D.PAY_APP_NO
       AND DATE_TRUNC(''''DAY'''', A.SYSTEM_DATE) = T_DATE_DESC
       AND T_DATE_DESC BETWEEN DATE_TRUNC(''''MM'''', TO_DATE('''''' || F_DATE || '''''') - 1)
                           AND TO_DATE('''''' || T_DATE || '''''') - 1
    UNION ALL
    SELECT C_CLAIM_NO,
           P_POLICY_NUMBER,
           T_DATE_DESC,
           A.PAY_APP_NO,
           CAST(NULL AS FLOAT) AS RECOVERY_INITIATED,
           SETTLE_AMT AS RECOVERY_DONE,
           SETTLE_AMT * -1 AS RECOVERY_PENDING,
           C_CLAIM_ID_SK,
           P_POLICY_NO_SK,
           T_DATE_ID_SK,
           10208 AS R_RESERVE_TYPE_ID,
           1 AS CC_CC_CLAIMTYPE_ID_SK
      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_NCB_ACC_RECOVERY_DTLS A,
           TRANSACTIONAL.ODS_CLAIM_DIM B,
           -- TRANSACTIONAL.ODS_POLICY_DIM C, -- Pointed  to view on 22nd Sept, 2025
           PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM C,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL D,
           PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM E
     WHERE A.CLM_REF = B.C_CLAIM_NO
       AND A.POLICY_REF = C.P_POLICY_NUMBER
       AND COALESCE(P_CURRENT_INDICATOR, 0) = 1
       AND A.CLM_REF = D.CLM_REF
       AND A.PAY_APP_NO = D.PAY_APP_NO
       AND DATE_TRUNC(''''DAY'''', A.RECV_DATE) = T_DATE_DESC
       AND T_DATE_DESC BETWEEN DATE_TRUNC(''''MM'''', TO_DATE('''''' || F_DATE || '''''') - 1)
                           AND TO_DATE('''''' || T_DATE || '''''') - 1
    UNION ALL
    SELECT C_CLAIM_NO,
           P_POLICY_NUMBER,
           T_DATE_DESC,
           A.PAY_APP_NO,
           CAST(NULL AS FLOAT) AS RECOVERY_INITIATED,
           SETTLE_AMT * -1 AS RECOVERY_DONE,
           SETTLE_AMT AS RECOVERY_PENDING,
           C_CLAIM_ID_SK,
           P_POLICY_NO_SK,
           T_DATE_ID_SK,
           10208 AS R_RESERVE_TYPE_ID,
           1 AS CC_CC_CLAIMTYPE_ID_SK
      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_NCB_ACC_RECOVERY_DTLS A,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_RECOVERY_RCPT_DTLS X,
           TRANSACTIONAL.ODS_CLAIM_DIM B,
           -- TRANSACTIONAL.ODS_POLICY_DIM C,  -- Pointed  to view on 22nd Sept, 2025
           PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM C,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL D,
           PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM E
     WHERE A.CLM_REF = X.CLM_REF
       AND A.PAY_APP_NO = X.PAY_APP_NO
       and A.CLM_REF = B.C_CLAIM_NO
       AND A.POLICY_REF = C.P_POLICY_NUMBER
       AND COALESCE(P_CURRENT_INDICATOR, 0) = 1
       AND A.CLM_REF = D.CLM_REF
       AND A.PAY_APP_NO = D.PAY_APP_NO
       AND DATE_TRUNC(''''DAY'''', X.RECEIPT_CANCEL_DATE) = T_DATE_DESC
       AND T_DATE_DESC BETWEEN DATE_TRUNC(''''MM'''', TO_DATE('''''' || F_DATE || '''''') - 1)
                           AND TO_DATE('''''' || T_DATE || '''''') - 1'';
EXECUTE IMMEDIATE v_sqltext;

--Merge data into ODS_CLAIM_FACT
v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_FACT X
    USING (SELECT C_CLAIM_ID_SK,
                  P_POLICY_NO_SK,
                  T_DATE_ID_SK,
                  R_RESERVE_TYPE_ID,
                  CC_CC_CLAIMTYPE_ID_SK,
                  PAY_APP_NO,
                  SUM(RECOVERY_INITIATED) AS RECOVERY_INITIATED,
                  SUM(RECOVERY_DONE) AS RECOVERY_DONE,
                  SUM(RECOVERY_PENDING) AS RECOVERY_PENDING
             FROM INTERMEDIATE.WRK_OTHER_CLM_RECOVERY
         GROUP BY C_CLAIM_ID_SK,
                  P_POLICY_NO_SK,
                  T_DATE_ID_SK,
                  R_RESERVE_TYPE_ID,
                  CC_CC_CLAIMTYPE_ID_SK,
                  PAY_APP_NO) A
      ON X.C_CLAIM_ID_SK = A.C_CLAIM_ID_SK
         AND X.P_POLICY_NO_SK = A.P_POLICY_NO_SK
         AND X.T_DATE_ID_SK = A.T_DATE_ID_SK
         AND X.C_PAY_APP_NO = A.PAY_APP_NO
         AND X.R_RESERVE_TYPE_ID = 10208
    WHEN MATCHED THEN
       UPDATE SET
          X.RECOVERY_INITIATED = A.RECOVERY_INITIATED,
          X.RECOVERY_DONE = A.RECOVERY_DONE,
          X.RECOVERY_PENDING = A.RECOVERY_PENDING
    WHEN NOT MATCHED THEN
       INSERT (C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               T_DATE_ID_SK,
               R_RESERVE_TYPE_ID,
               RESERVE_AMOUNT,
               PAID_CLAIM_AMOUNT,
               SALVAGE_AMOUNT,
               CC_CC_CLAIMTYPE_ID_SK,
               RECOVERY_AMOUNT,
               SERVICE_TAX,
               c_PAY_APP_NO,
               RECOVERY_INITIATED,
               RECOVERY_DONE,
               RECOVERY_PENDING)
       VALUES (A.C_CLAIM_ID_SK,
               A.P_POLICY_NO_SK,
               A.T_DATE_ID_SK,
               A.R_RESERVE_TYPE_ID,
               0,
               0,
               0,
               1,
               0,
               0,
               a.pay_app_no,
               A.RECOVERY_INITIATED,
               A.RECOVERY_DONE,
               A.RECOVERY_PENDING)'';
EXECUTE IMMEDIATE v_sqltext;

  -- Check if it''s the first day of the month using an integer variable
    DAY_VALUE := DAY(CURRENT_DATE());

    IF (DAY_VALUE = 01) THEN
        INSERT INTO INTERMEDIATE.WRK_OTHER_CLM_RECOVERY_bkp
        SELECT A.*, CURRENT_TIMESTAMP()
        FROM INTERMEDIATE.WRK_OTHER_CLM_RECOVERY A;
    END IF;

EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
  WHEN OTHER THEN
    RETURN ''Error executing procedure: '' || SQLSTATE || '' - '' || SQLERRM || ''\\\\n'' || ''SQL: '' || ''\\\\n'' || v_sqltext;;
END;
';