CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_CLOSING_REMARKS_UPDATE("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext varchar;
LOAD_DATE DATE;
L_START FLOAT;

BEGIN

SELECT CAST(MAX(DATE_TRUNC(''DAY'', MSG_DATE)) AS DATE) + 1
     INTO :LOAD_DATE
     FROM TRANSACTIONAL.WRK_CLAIM_CLOSED_REMARKS;



v_sqltext := ''INSERT /*+append*/
         INTO  TRANSACTIONAL.WRK_CLAIM_CLOSED_REMARKS
      SELECT
            B.CLM_REF,
             A.CLAIM_ID,
             VERSION_NO,
             STATUS_MSG,
             MSG_TYPE,
             DATE_TRUNC(''''DAY'''', MSG_DATE) MSG_DATE,
             USER_NAME,
             STATUS,
             DATE_OF_SURVEY,
             SUBSTR (STATUS_MSG,
                     REGEXP_INSTR (STATUS_MSG,
                            ''''Special Comments'''',
                            1,
                            1),
                     LENGTH (STATUS_MSG))
                SPECIAL_COMMENTS,
             -- CASE
             --    WHEN LOWER (STATUS_MSG) LIKE ''''%claim closing reason%''''
             --    THEN
             --       UPPER (UTILS.MY_TRIM (SUBSTR (STATUS_MSG,
             --                              REGEXP_INSTR (STATUS_MSG,
             --                                     '''':-'''',
             --                                     1,
             --                                     1)
             --                            + 2,
             --                              REGEXP_INSTR (SUBSTR (STATUS_MSG,
             --                                               REGEXP_INSTR (STATUS_MSG,
             --                                                      '''':-'''',
             --                                                      1,
             --                                                      1)
             --                                             + 2),
             --                                     ''''[.]'''',
             --                                     1,
             --                                     1)
             --                            - 1)))
             -- END
             --    C_COMMENTS,
             UPPER (
                       CASE
                          WHEN LOWER (STATUS_MSG) LIKE
                                  ''''%claim closing reason%''''
                          THEN
                             UPPER (
                                UTILS.MY_TRIM (
                                   SUBSTR (
                                      STATUS_MSG,
                                        REGEXP_INSTR (STATUS_MSG,
                                               '''':-'''',
                                               1,
                                               1)
                                      + 2,
                                        REGEXP_INSTR (SUBSTR (STATUS_MSG,
                                                         REGEXP_INSTR (STATUS_MSG,
                                                                '''':-'''',
                                                                1,
                                                                1)
                                                       + 2),
                                               ''''[.]'''',
                                               1,
                                               1)
                                      - 1)))
                          ELSE
                             STATUS_MSG
                       END)
                       C_COMMENTS,
             DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') ) LOAD_DATE,
             NULL as INC_JOB_CREATED_AT,
             NULL as INC_JOB_CREATED_BY,
             NULL as INC_JOB_UPDATED_BY,
             NULL as INC_JOB_UPDATED_AT,
             NULL as INC_JOB_ID
       FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_STATUS_REPOSITORY A,
        ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_BASES B
       WHERE     NVL (STATUS, ''''ABC'''') = ''''Claim Closed''''
             AND A.CLAIM_ID = B.CLAIM_ID
             AND DATE_TRUNC(''''DAY'''', MSG_DATE) BETWEEN TO_DATE('''''' || LOAD_DATE || '''''') AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1'';
             EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MISS_CLM_CLOSED_REMARKS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MISS_CLM_CLOSED_REMARKS
      SELECT CLM_REF,
             A.C_COMMENTS,
             B.C_COMMENTS C_COMMENTS_DWH,
             DATE_TRUNC(''''DAY'''', MSG_DATE) MSG_DATE,
             C_CLO_DATE
        FROM TRANSACTIONAL.WRK_CLAIM_CLOSED_REMARKS A,
        TRANSACTIONAL.ODS_CLAIM_DIM B
       WHERE     CLM_REF = C_CLAIM_NO
             AND VERSION_NO IN (SELECT MAX (VERSION_NO)
                                  FROM TRANSACTIONAL.WRK_CLAIM_CLOSED_REMARKS B
                                 WHERE A.CLM_REF = B.CLM_REF)
             AND A.C_COMMENTS IS NOT NULL
             AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
             AND NVL (
                    UPPER (
                       REPLACE (REPLACE (A.C_COMMENTS, ''''-'''', ''''''''), '''' '''', '''''''')),
                    ''''abc'''') <>
                    NVL (
                       UTILS.MY_TRIM (
                          REPLACE (REPLACE (B.C_COMMENTS, ''''-'''', ''''''''), '''' '''', '''''''')),
                       ''''abc'''')'';
EXECUTE IMMEDIATE v_sqltext;




v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET C_COMMENTS = UPPER (src.C_COMMENTS), ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_MISS_CLM_CLOSED_REMARKS
)as src
WHERE target.C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET C_COMMENTS = UPPER (src.C_COMMENTS)
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_MISS_CLM_CLOSED_REMARKS
)as src
WHERE target.C_CLAIM_NO = src.CLM_REF'';
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