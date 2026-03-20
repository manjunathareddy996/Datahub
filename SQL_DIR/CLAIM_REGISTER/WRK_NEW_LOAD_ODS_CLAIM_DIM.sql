CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_NEW_LOAD_ODS_CLAIM_DIM("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext VARCHAR;

BEGIN
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*--Created by chandrakant*/
/*-----------------------------------------------------------------------------------------------------------------------------------------*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM (C_CLAIM_ID_SK,
                                      C_CAUSE_OF_LOSS,
                                      C_CLAIM_NO,
                                      C_CLAIM_STATUS,
                                      C_LOSS_DATE,
                                      C_REGN_DATE,
                                      C_APP_DATE,
                                      C_CLAIM_ID,
                                      C_BILL_DATE,
                                      C_OFF_LOC_ID,
                                      C_PARTS_CLAIMED,
                                      C_PAID_FLAG,
                                      C_POLICY_GRAIN)
      SELECT NULL C_CLAIM_ID_SK,
             upper(DESCRIPTION) C_CAUSE_OF_LOSS,
             CLM_REF C_CLAIM_NO,
             CLM_STATUS C_CLAIM_STATUS,
             DATE_OF_LOSS C_LOSS_DATE,
             DATE_REPORTED C_REGN_DATE,
             (SELECT MAX (TRANS_DATE)
                FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL M
               WHERE PAY_STATUS != ''''DELETED'''' 
               AND M.CLAIM_ID = CLMID)  C_APP_DATE,
             A.CLAIM_ID,
             NULL C_BILL_DATE,
             LOC_CODE,
             NULL C_PARTS_CLAIMED,
             0 C_PAID_FLAG,
             NULL C_POLICY_GRAIN
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A, TRANSACTIONAL.ODS_CLAIM_MINUS_TBL C, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CC_V_CAUSE_OF_LOSSES B 
       WHERE     A.CLAIM_ID = CLMID
             AND NVL (A.COL_CODE, ''''1000'''') = B.COL_CODE(+)
             AND SULA_ORA_NLS_CODE(+) = ''''US''''
           -- LOG ERRORS INTO ERR$_WRK_STG_ODS_CLAIM_DIM (''''insert example'''')'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''UPDATE INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM
as target
            SET C_SUR_REP_DATE = src.C_SUR_REP_DATE, 
         C_COMMENTS = src.C_COMMENTS
FROM 
(SELECT CLAIM_ID,
                 C_SUR_REP_DATE,
                 SUBSTR (C_COMMENTS, 100) C_COMMENTS
            FROM (  SELECT CLAIM_ID,
                           MAX (REPORT_SUBMITION_DATE) C_SUR_REP_DATE,
                           MIN (SURVEYOR_COMMENTS) C_COMMENTS
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_BASES A, TRANSACTIONAL.ODS_CLAIM_MINUS_TBL B
                     WHERE A.CLAIM_ID = CLMID AND SURVEY_STAGE = ''''F''''
                  GROUP BY CLAIM_ID)) AS src
WHERE C_CLAIM_ID = src.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM 
as target
            SET C_CHQ_ISS_DATE = src.C_CHQ_ISS_DATE
FROM 
(SELECT CLM_REF, MAX (B.TRANS_DATE) C_CHQ_ISS_DATE
              FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL A,
                   ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_ACC_PAY_DETL B,
                   TRANSACTIONAL.ODS_CLAIM_MINUS_TBL C
             WHERE PAY_APP_NO = ACC_PAY_REF AND CLM_REF = C_CLAIM_NO
          GROUP BY CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM
as target
            SET C_SUR_NAME = src.C_SUR_NAME,
             C_REP_NAME = src.C_REP_NAME,
             C_ADV_NAME = src.C_ADV_NAME
FROM 
(SELECT *
            FROM (  SELECT CLAIM_ID,
                           upper(UTILS.MY_TRIM (
                              MIN (
                                 CASE
                                    WHEN IP_TYPE IN (''''SUR'''', ''''INH_SUR'''')
                                    THEN
                                          B.FIRST_NAME
                                       || '''' ''''
                                       || B.MIDDLE_NAME
                                       || '''' ''''
                                       || B.SURNAME
                                       || '''' ''''
                                       || B.INSTITUTION_NAME
                                 END)))
                              C_SUR_NAME,
                           upper(UTILS.MY_TRIM (
                              MAX (
                                 CASE
                                    WHEN A.IP_TYPE IN (''''REP'''', ''''TIEUPREP'''')
                                    THEN
                                          B.FIRST_NAME
                                       || '''' ''''
                                       || B.MIDDLE_NAME
                                       || '''' ''''
                                       || B.SURNAME
                                       || '''' ''''
                                       || B.INSTITUTION_NAME
                                 END)))
                              C_REP_NAME,
                           upper(UTILS.MY_TRIM (
                              MIN (
                                 CASE
                                    WHEN A.IP_TYPE IN (''''LAW'''', ''''ADV'''')
                                    THEN
                                          B.FIRST_NAME
                                       || '''' ''''
                                       || B.MIDDLE_NAME
                                       || '''' ''''
                                       || B.SURNAME
                                       || '''' ''''
                                       || B.INSTITUTION_NAME
                                 END)))
                              C_ADV_NAME
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES A,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CP_PARTNERS B,
                           TRANSACTIONAL.ODS_CLAIM_MINUS_TBL C
                     WHERE     A.CLAIM_ID = C.CLMID
                           AND A.PART_ID = B.PART_ID(+)
                           AND A.IP_TYPE IN
                                  (''''LAW'''',
                                   ''''ADV'''',
                                   ''''REP'''',
                                   ''''TIEUPREP'''',
                                   ''''SUR'''',
                                   ''''INH_SUR'''')
                  GROUP BY A.CLAIM_ID)
           WHERE (   C_SUR_NAME IS NOT NULL
                  OR C_REP_NAME IS NOT NULL
                  OR C_ADV_NAME IS NOT NULL)) AS src
WHERE C_CLAIM_ID = src.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM
as target
            SET C_LAST_REOPEN_DATE = src.MSG_DATE
FROM 
(  SELECT CLAIM_ID, MIN (DATE_TRUNC(''''DAY'''', MSG_DATE)) MSG_DATE
              FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A, TRANSACTIONAL.ODS_CLAIM_MINUS_TBL B 
             WHERE     A.CLAIM_ID = B.CLMID
                   AND (   UPPER (STATUS_MSG) LIKE UPPER (UTILS.MY_TRIM (''''%REOPENED%''''))
                        OR MSG_TYPE LIKE UPPER (UTILS.MY_TRIM (''''%REOPEN%'''')))
          GROUP BY CLAIM_ID) AS src
WHERE C_CLAIM_ID = src.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM 
as target
            SET C_KIND_OF_LOSS = src.CLM_TYPE,
                C_ACCIDENT_LOC = src.CITY,
                C_LOSS_TIME = src.TIME_OF_LOSS,
                C_INTI_DATE = src.NOTIFICATION_DATE,
                C_CLAIM_TYPE = src.CLM_TYPE,
                C_CLAIM_REGD_BY = src.ASSIGNEE
FROM 
(  SELECT CLAIM_ID,
                         MAX (TIME_OF_LOSS) TIME_OF_LOSS,
                         MAX (CITY) CITY,
                         MAX (UPPER(ASSIGNEE)) ASSIGNEE,
                         MAX (NOTIFICATION_DATE) NOTIFICATION_DATE,
                         MAX (CLM_TYPE) CLM_TYPE
                    FROM (SELECT CLAIM_ID,
                                 TIME_OF_LOSS,
                                 CITY,
                                 ASSIGNEE,
                                 DATE_TRUNC(''''DAY'''', NOTIFICATION_DATE)NOTIFICATION_DATE,
                                 CLM_TYPE
                            FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
                                 TRANSACTIONAL.ODS_CLAIM_MINUS_TBL B
                           WHERE A.CLAIM_ID = CLMID  --AND CLAIM_ID = 24207987
                          UNION
                          SELECT CLAIM_ID,
                                 TIME_OF_LOSS,
                                 CITY,
                                 ASSIGNEE,
                                 DATE_TRUNC(''''DAY'''', NOTIFICATION_DATE)NOTIFICATION_DATE,
                                 CLM_TYPE
                            FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
                                  TRANSACTIONAL.ODS_CLAIM_MINUS_TBL B
                           WHERE A.CLAIM_ID = CLMID  --AND CLAIM_ID = 24207987
                                                   )
                GROUP BY CLAIM_ID) AS src
WHERE C_CLAIM_ID = src.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;




v_sqltext := ''UPDATE INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM
as target
            SET C_CAUSE_OF_LOSS = src.COL_CODE
FROM 
(SELECT CLM_REF, UPPER (COL_CODE) COL_CODE
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES
              WHERE     CLM_REF IN (SELECT C_CLAIM_NO
                                      FROM INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM
                                     WHERE C_CAUSE_OF_LOSS IS NULL)
                    AND COL_CODE NOT IN (SELECT COL_CODE
                                           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CC_V_CAUSE_OF_LOSSES 
                                          WHERE SULA_ORA_NLS_CODE = ''''US'''')) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_CLAIM_DIM (C_CLAIM_ID_SK,
                                         C_CAUSE_OF_LOSS,
                                         C_CLAIM_NO,
                                         C_CLAIM_STATUS,
                                         C_KIND_OF_LOSS,
                                         C_ACCIDENT_LOC,
                                         C_LOSS_DATE,
                                         C_LOSS_TIME,
                                         C_INTI_DATE,
                                         C_REGN_DATE,
                                         C_APP_DATE,
                                         C_SUR_REP_DATE,
                                         C_CHQ_ISS_DATE,
                                         C_SUR_NAME,
                                         C_REP_NAME,
                                         C_BILL_DATE,
                                         C_OFF_LOC_ID,
                                         C_PARTS_CLAIMED,
                                         C_ADV_NAME,
                                         C_CLAIM_TYPE,
                                         C_COMMENTS,
                                         C_PAID_FLAG,
                                         C_POLICY_GRAIN,
                                         C_CLAIM_REGD_BY,
                                         C_LAST_REOPEN_DATE,
                                         C_CLAIM_ID,
                                         ETL_Refresh_At)
   (SELECT UTILS.CLAIM_SURROGATE_KEY.NEXTVAL,
           C_CAUSE_OF_LOSS,
           C_CLAIM_NO,
           C_CLAIM_STATUS,
           C_KIND_OF_LOSS,
           C_ACCIDENT_LOC,
           C_LOSS_DATE,
           C_LOSS_TIME,
           C_INTI_DATE,
           C_REGN_DATE,
           C_APP_DATE,
           C_SUR_REP_DATE,
           C_CHQ_ISS_DATE,
           C_SUR_NAME,
           C_REP_NAME,
           C_BILL_DATE,
           C_OFF_LOC_ID,
           C_PARTS_CLAIMED,
           C_ADV_NAME,
           C_CLAIM_TYPE,
           C_COMMENTS,
           C_PAID_FLAG,
           C_POLICY_GRAIN,
           C_CLAIM_REGD_BY,
           C_LAST_REOPEN_DATE,
           C_CLAIM_ID,
           CURRENT_TIMESTAMP()
      FROM INTERMEDIATE.WRK_STG_ODS_CLAIM_DIM)'';
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