CREATE OR REPLACE PROCEDURE TRANSACTIONAL.INCREMENTAL_CLAIMS("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
    v_sqltext VARCHAR;

BEGIN
    
    v_sqltext := ''TRUNCATE TABLE IF EXISTS TRANSACTIONAL.ODS_CLAIM_MINUS_TBL'';
    EXECUTE IMMEDIATE v_sqltext;

    
    v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_CLAIM_MINUS_TBL
        SELECT 
        SET_MINUS_DIM_INC_OPERATION.C_CLAIM_NO$1 AS C_CLAIM_NO,
        claim_id
        FROM (SELECT C_CLAIM_NO AS C_CLAIM_NO$1, claim_id
              FROM (SELECT CLM_BASES.CLM_REF AS C_CLAIM_NO, claim_id 
                    FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES AS CLM_BASES
                    WHERE DATE_TRUNC(''''DAY'''', date_reported) BETWEEN 
                          DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 5 
                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                    AND clm_ref <> ''''ERROR''''
                    MINUS
                    SELECT C_CLAIM_NO AS C_CLAIM_NO, c_claim_id
                    FROM TRANSACTIONAL.ODS_CLAIM_DIM 
                    WHERE C_CLAIM_NO LIKE ''''%C%''''
              )) SET_MINUS_DIM_INC_OPERATION'';

    EXECUTE IMMEDIATE v_sqltext;

    
    v_sqltext := ''DELETE FROM TRANSACTIONAL.ODS_CLAIM_MINUS_TBL WHERE UPPER(C_CLAIM_NO) = ''''ERROR'''''';
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