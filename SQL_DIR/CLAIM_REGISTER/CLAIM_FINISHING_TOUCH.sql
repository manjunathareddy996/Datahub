CREATE OR REPLACE PROCEDURE TRANSACTIONAL.CLAIM_FINISHING_TOUCH("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext VARCHAR;
max_reg_date DATE;
max_clm_trans NUMBER;
max_prem_fact NUMBER;
max_pol_prem_fact NUMBER;
max_fire_prem_fact NUMBER;
max_comm_fact NUMBER;
currdate DATE;
currdateidsk NUMBER;
l_start NUMBER;
d_date date;

BEGIN
/*l_start := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

select t_date_id_sk
        into :currdateidsk
        from PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM
       where t_date_desc = DATE_TRUNC(''DAY'', TO_DATE(:T_DATE));


select max(c_regn_date)
        into :max_reg_date
        from TRANSACTIONAL.ODS_CLAIM_DIM;


select max(t_date_id_sk)
        into :max_clm_trans
        from TRANSACTIONAL.ODS_CLAIM_FACT;

d_date := DATE_TRUNC(''DAY'', :T_DATE);
IF (max_reg_date >= d_date)
THEN
   delete from TRANSACTIONAL.ODS_CLAIM_DIM
               where c_regn_date >= d_date;
END IF;


IF (max_clm_trans >= :currdateidsk)
THEN
   delete from TRANSACTIONAL.ODS_CLAIM_FACT
               where t_date_id_sk >= :currdateidsk;

   delete from TRANSACTIONAL.ods_claim_fact_mv
               where t_date_id_sk >= :currdateidsk;
END IF;


delete from TRANSACTIONAL.ODS_CLAIM_FACT where t_date_id_sk = :currdateidsk - 1;

delete from TRANSACTIONAL.ODS_CLAIM_FACT_MV where t_date_id_sk = :currdateidsk - 1;



EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;
END;
';