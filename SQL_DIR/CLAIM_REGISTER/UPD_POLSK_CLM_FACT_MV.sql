CREATE OR REPLACE PROCEDURE TRANSACTIONAL.UPD_POLSK_CLM_FACT_MV("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
Declare
ICNT number DEFAULT 0;
v_sqltext VARCHAR;
BEGIN


v_sqltext := ''INSERT INTO
TRANSACTIONAL.ODS_CLAIM_FACT_MV_24DEC
  WITH cte AS
   (SELECT p_policy_no_sk, p_policy_number, p_current_indicator,
          MAX(p_policy_no_sk) OVER(PARTITION BY p_policy_number) AS mx
   FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
   WHERE p_policy_number IN (
       SELECT p_policy_number
       FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
       JOIN
TRANSACTIONAL.ODS_CLAIM_DIM ON c_claim_id_sk = ods_claim_dim.c_claim_id_sk
       JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM ON ods_product_dim.p_product_id = ods_policy_dim.p_product_id
       JOIN
TRANSACTIONAL.ODS_CLAIM_FACT_MV a ON a.p_policy_no_sk = ods_policy_dim.p_policy_no_sk
       JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b ON a.t_date_id_sk = b.t_date_id_sk
       WHERE t_date_desc = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
       GROUP BY p_policy_number
       HAVING COUNT(DISTINCT ods_product_dim.p_product_id) > 1
   ))
  SELECT
  a.C_CLAIM_ID_SK, a.P_POLICY_NO_SK, a.COMPANY_CODE, a.T_DATE_ID_SK,
      a.CC_CC_CLAIMTYPE_ID_SK, a.R_RESERVE_TYPE_ID, a.PAID_CLAIM, a.RESERVE_AMOUNT,
      a.SALVAGE_AMOUNT, a.RECOVERY_AMOUNT, a.SERVICE_TAX
FROM
TRANSACTIONAL.ODS_CLAIM_FACT_MV AS a
JOIN cte p ON a.p_policy_no_sk = p.p_policy_no_sk'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO
TRANSACTIONAL.ODS_CLAIM_FACT_2APR
WITH cte AS (
   SELECT p_policy_no_sk, p_policy_number, p_current_indicator,
          MAX(p_policy_no_sk) OVER(PARTITION BY p_policy_number) AS mx
   FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
   WHERE p_policy_number IN (
       SELECT p_policy_number
       FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
       JOIN
TRANSACTIONAL.ODS_CLAIM_DIM ON c_claim_id_sk = ods_claim_dim.c_claim_id_sk
       JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM ON ods_product_dim.p_product_id = ods_policy_dim.p_product_id
       JOIN
TRANSACTIONAL.ODS_CLAIM_FACT_MV a ON a.p_policy_no_sk = ods_policy_dim.p_policy_no_sk
       JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b ON a.t_date_id_sk = b.t_date_id_sk
       WHERE t_date_desc = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
       GROUP BY p_policy_number
       HAVING COUNT(DISTINCT ods_product_dim.p_product_id) > 1
   )
)
SELECT a.C_CLAIM_ID_SK,
	a.p_policy_no_sk,
	a.T_DATE_ID_SK,
	a.R_RESERVE_TYPE_ID,
	a.RESERVE_AMOUNT,
	a.PAID_CLAIM_AMOUNT,
	a.SALVAGE_AMOUNT,
	a.CC_CC_CLAIMTYPE_ID_SK,
	a.C_PAY_APP_NO,
	a.RECOVERY_AMOUNT,
	a.SERVICE_TAX,
    DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) -1 as INSERT_DATE
FROM
TRANSACTIONAL.ODS_CLAIM_FACT a
JOIN cte p ON a.p_policy_no_sk = p.p_policy_no_sk'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext :=''UPDATE
TRANSACTIONAL.ODS_CLAIM_FACT_MV AS target
SET target.p_policy_no_sk = src.mx
FROM (
    SELECT p_policy_no_sk, p_policy_number, p_current_indicator,
           MAX(p_policy_no_sk) OVER(PARTITION BY p_policy_number) AS mx
    FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
    WHERE p_policy_number IN (
        SELECT p_policy_number
        FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
        JOIN
TRANSACTIONAL.ODS_CLAIM_DIM ON c_claim_id_sk = ods_claim_dim.c_claim_id_sk
        JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM ON ods_product_dim.p_product_id = ods_policy_dim.p_product_id
        JOIN
TRANSACTIONAL.ODS_CLAIM_FACT_MV a ON a.p_policy_no_sk = ods_policy_dim.p_policy_no_sk
        JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b ON a.t_date_id_sk = b.t_date_id_sk
        WHERE t_date_desc = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
        GROUP BY p_policy_number
        HAVING COUNT(DISTINCT ods_product_dim.p_product_id) > 1
    )
) AS src
WHERE target.p_policy_no_sk = src.p_policy_no_sk'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE
TRANSACTIONAL.ODS_CLAIM_FACT AS target
SET target.p_policy_no_sk = src.mx
FROM (
    SELECT p_policy_no_sk, p_policy_number, p_current_indicator,
           MAX(p_policy_no_sk) OVER(PARTITION BY p_policy_number) AS mx
    FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
    WHERE p_policy_number IN (
        SELECT p_policy_number
        FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
        JOIN
TRANSACTIONAL.ODS_CLAIM_DIM ON c_claim_id_sk = ods_claim_dim.c_claim_id_sk
        JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM ON ods_product_dim.p_product_id = ods_policy_dim.p_product_id
        JOIN
TRANSACTIONAL.ODS_CLAIM_FACT_MV a ON a.p_policy_no_sk = ods_policy_dim.p_policy_no_sk
        JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b ON a.t_date_id_sk = b.t_date_id_sk
        WHERE t_date_desc = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
        GROUP BY p_policy_number
        HAVING COUNT(DISTINCT ods_product_dim.p_product_id) > 1
    )
) AS src
WHERE target.p_policy_no_sk = src.p_policy_no_sk'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''with cte1 as (SELECT p_policy_number,ods_product_dim.p_product_id  p_product_id
        FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM ods_policy_dim
        JOIN
TRANSACTIONAL.ODS_CLAIM_DIM ON c_claim_id_sk = ods_claim_dim.c_claim_id_sk
        JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM ods_product_dim ON ods_product_dim.p_product_id = ods_policy_dim.p_product_id
        JOIN TRANSACTIONAL.ODS_CLAIM_FACT_MV a ON a.p_policy_no_sk = ods_policy_dim.p_policy_no_sk
        JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b ON a.t_date_id_sk = b.t_date_id_sk
        WHERE t_date_desc = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
        GROUP BY p_policy_number,ods_product_dim.p_product_id)
        ,
     cte2 AS (
    SELECT p_policy_no_sk, p_policy_number, p_current_indicator,
           MAX(p_policy_no_sk) OVER(PARTITION BY p_policy_number) AS mx
    FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM
    WHERE p_policy_number IN (
        select p_policy_number from cte1
        GROUP BY p_policy_number
        HAVING COUNT(DISTINCT p_product_id) > 1
    )
)
SELECT count(*) || ''|| ICNT ||'' from cte2'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO
TRANSACTIONAL.WRK_OWB_COUNT(t_date,
comment1, count1)
    VALUES (TO_DATE('''''' || T_DATE || ''''''), ''''count of max polsk upd'''', ''|| icnt ||'')'';
EXECUTE IMMEDIATE v_sqltext;


EXECUTE IMMEDIATE ''COMMIT'';
RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: \\n'' || v_sqltext;

END;
';