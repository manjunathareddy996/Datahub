CREATE OR REPLACE PROCEDURE TRANSACTIONAL.BJAZ_DAILY_DEL_CLM_FIX("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_date_id_sk number;
v_sqltext VARCHAR;

BEGIN

select max(t_date_id_sk) into :v_date_id_sk  from TRANSACTIONAL.ODS_CLAIM_FACT;

v_sqltext := ''insert into TRANSACTIONAL.ODS_CLAIM_FACT(
        C_CLAIM_ID_SK,
        P_POLICY_NO_SK,
        T_DATE_ID_SK,
        R_RESERVE_TYPE_ID,
        RESERVE_AMOUNT,
        PAID_CLAIM_AMOUNT,
        SALVAGE_AMOUNT,
        CC_CC_CLAIMTYPE_ID_SK,
        C_PAY_APP_NO,
        RECOVERY_AMOUNT,
        SERVICE_TAX
    )
select  DISTINCT
c.C_CLAIM_ID_SK,
P_POLICY_NO_SK,
''|| v_date_id_sk ||'',
R_RESERVE_TYPE_ID,
RESERVE_AMOUNT,
-1*TRANS_AMT,
SALVAGE_AMOUNT,
CC_CC_CLAIMTYPE_ID_SK,
C_PAY_APP_NO,
RECOVERY_AMOUNT,
-1*c.SERVICE_TAX
from ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL a,
TRANSACTIONAL.ODS_CLAIM_DIM b,
TRANSACTIONAL.ODS_CLAIM_FACT c
where  a.clm_ref = b.c_Claim_no
and b.c_claim_id_sk = c.c_claim_id_sk
and PAY_APP_NO = C_PAY_APP_NO
and a.pay_status = ''''DELETED''''
AND R_RESERVE_TYPE_ID <> 10208
and DATE_TRUNC(''''DAY'''', a.trans_date)=DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')-1)'';
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