CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_CLAIM_REG_BY_UPDATE("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '

DECLARE
v_sqltext varchar;
l_start FLOAT;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_USER_NAME_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_USER_NAME_UPDATE
      SELECT DISTINCT clm_ref, a.claim_id
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES a, TRANSACTIONAL.ODS_CLAIM_DIM, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_TRANS c
       WHERE a.clm_ref = c_claim_no
       and a.claim_id=c.claim_id
       AND c_claim_regd_by IS NULL
       AND DATE_TRUNC(''''DAY'''', c.trans_date) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
       UNION
      SELECT CLM_REF, A.CLAIM_ID
        FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
       WHERE     A.CLAIM_ID = b.CLAIM_ID
             AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_REG_BY'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY
      SELECT
            clm_ref, USER_NAME
        FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY  a, INTERMEDIATE.WRK_USER_NAME_UPDATE b
       WHERE     version_no = 1
             AND a.claim_id = b.claim_id
             AND USER_NAME IS NOT NULL'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_REG_BY_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY_1
      SELECT clm_ref, updated_by
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLAIM_TRACKER a, INTERMEDIATE.WRK_USER_NAME_UPDATE b
       WHERE     a.claim_id = b.claim_id
             AND version_no = 1
             AND updated_by IS NOT NULL
             AND NOT EXISTS
                    (SELECT *
                       FROM INTERMEDIATE.WRK_CLAIM_REG_BY
                      WHERE clm_ref = b.clm_ref)'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY
      SELECT * FROM INTERMEDIATE.WRK_CLAIM_REG_BY_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_REG_BY_1'';

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY_1
      SELECT clm_ref, updated_by
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_ORPHAN_REG a, INTERMEDIATE.WRK_USER_NAME_UPDATE b
       WHERE     a.claim_id = b.claim_id
             AND updated_by IS NOT NULL
             AND NOT EXISTS
                    (SELECT *
                       FROM INTERMEDIATE.WRK_CLAIM_REG_BY
                      WHERE clm_ref = b.clm_ref)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY
      SELECT * FROM INTERMEDIATE.WRK_CLAIM_REG_BY_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_REG_BY_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY_1
      SELECT clm_ref, updated_by
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLM_AUTO_ALLOCATION a,  INTERMEDIATE.WRK_USER_NAME_UPDATE b
       WHERE     version_no = 1
             AND a.claim_id = b.claim_id
             AND updated_by IS NOT NULL
             AND NOT EXISTS
                    (SELECT *
                       FROM INTERMEDIATE.WRK_CLAIM_REG_BY
                      WHERE clm_ref = b.clm_ref)'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLAIM_REG_BY
      SELECT * FROM INTERMEDIATE.WRK_CLAIM_REG_BY_1'';
EXECUTE IMMEDIATE v_sqltext;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET c_claim_regd_by = src.USER_NAME, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT clm_ref,max(user_name) USER_NAME FROM INTERMEDIATE.WRK_CLAIM_REG_BY group by clm_ref) AS src
WHERE target.c_claim_no = src.clm_ref'';
EXECUTE IMMEDIATE v_sqltext;

END;



EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;
END;
';