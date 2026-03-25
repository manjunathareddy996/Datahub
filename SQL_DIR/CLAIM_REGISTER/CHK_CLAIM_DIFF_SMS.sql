CREATE OR REPLACE PROCEDURE INTERMEDIATE.CHK_CLAIM_DIFF_SMS("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
    v_Date_id_sk INTEGER := 0;
    v_cnt_fact   INTEGER  := 0;
    v_cnt_fact_mv INTEGER  := 0;
    v_res_fact_amt INTEGER  := 0;
    v_res_fact_mv_amt INTEGER  := 0;
    v_opus_paid INTEGER  := 0;
    v_opus_res INTEGER := 0;
    v_paid_fact_amt INTEGER := 0;
    v_paid_fact_mv_amt INTEGER := 0;
    v_paid_diff_amt INTEGER := 0;
    v_sms_msg_paid VARCHAR;
    v_opus_diff_res INTEGER := 0;
    v_opus_diff_paid INTEGER := 0;
    v_res_diff_amt INTEGER := 0;
    v_sms_msg_res VARCHAR;
    v_sqltext VARCHAR;
BEGIN


SELECT t_date_id_sk INTO v_Date_id_sk
FROM PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM
    WHERE t_Date_desc = DATE_TRUNC(''DAY'', CURRENT_DATE) - 1;


SELECT COUNT(*) AS claim_count
INTO v_cnt_fact
FROM TRANSACTIONAL.ODS_CLAIM_FACT a
JOIN PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
ON a.T_DATE_ID_SK = b.T_DATE_ID_SK
WHERE b.T_DATE_DESC = DATE_TRUNC(''DAY'', CURRENT_DATE) - 1;



SELECT COUNT (*) AS CLAIM_AMOUNT
INTO v_cnt_fact_mv
     FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
    WHERE     a.t_date_id_sk = b.t_date_id_sk
          AND t_date_Desc = DATE_TRUNC(''DAY'', CURRENT_DATE) - 1;



SELECT SUM (reserve_amount)
INTO v_res_fact_amt
     FROM TRANSACTIONAL.ODS_CLAIM_FACT
    WHERE t_date_id_sk = :v_Date_id_sk;

SELECT SUM (reserve_amount)
     INTO v_res_fact_mv_amt
      FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV
      where
      NVL (MAXIMUS_FLAG, ''N'') = ''N''
   and t_date_id_sk = :v_Date_id_sk;

SELECT  SUM( CASE WHEN PAY_STATUS LIKE ''DEL%''
                    THEN -1*(trans_amt)
                  WHEN PAY_STATUS = ''APP_DEL''
                    THEN 0 else TRANS_AMT END ) srcpaid
into v_opus_paid
 FROM BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL
where  DATE_TRUNC(''DAY'', trans_date) = DATE_TRUNC(''DAY'', CURRENT_DATE)-1;

--res
SELECT SUM (trans_amt) srcpaid
INTO v_opus_res
FROM BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.CLM_BASES a, BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.CLM_TRANS b
WHERE     a.claim_id = b.claim_id
AND b.CLM_STATUS IN (''AUTHOR'')
AND DATE_TRUNC(''DAY'', trans_date) = DATE_TRUNC(''DAY'', CURRENT_DATE) - 1;

/*----------------for paid amount--------------------------------------*/

SELECT SUM (paid_claim_amount)
     INTO v_paid_fact_amt
     FROM TRANSACTIONAL.ODS_CLAIM_FACT
    WHERE t_date_id_sk = :v_Date_id_sk;

SELECT SUM (paid_claim)
INTO v_paid_fact_mv_amt
FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a
where  NVL (MAXIMUS_FLAG, ''N'') = ''N''
and t_date_id_sk = :v_Date_id_sk;

v_paid_diff_amt := NVL(v_paid_fact_amt,0) - NVL(v_paid_fact_mv_amt,0);


v_sms_msg_paid := ''Claim Paid diff amt : '' || v_paid_diff_amt;

v_opus_diff_res := NVL(v_opus_res,0) - NVL(v_res_fact_amt,0);

v_opus_diff_paid := NVL(v_opus_paid,0)-NVL(v_paid_fact_amt,0);

v_res_diff_amt := NVL(v_res_fact_amt,0) - NVL(v_res_fact_mv_amt,0);

v_sms_msg_res := ''Reserve diff amt : '' || v_res_diff_amt;

INSERT INTO INTERMEDIATE.BJAZ_SMS_REPOSITORY (sms_id,
                                    sms_to,
                                    sms_from,
                                    sms_message,
                                    datetime_queued,
                                    sms_status)
                VALUES (
                  UTILS.SMS_SEQ.NEXTVAL,
                  ''8379865547'',
                  ''BAGIC'',
                     ''DWH LOAD''
                  || '' ''
                  || :v_sms_msg_res
                  || '' ''
                  || :v_sms_msg_paid
                  || '' ''
                  || '' fact cnt ''
                  || :v_cnt_fact
                  || '' ''
                  || '' mv cnt ''
                  || :v_cnt_fact_mv
                  || '' paid diff opus ''
                  || :v_opus_diff_paid
                  || '' res diff opus ''
                  || :v_opus_diff_res,
                  TO_CHAR (CURRENT_DATE, ''DD-MM-YYYY hh24:mi:ss''),
                  ''QUEUED'');

    EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\\\\\n'' || ''SQL: '' || ''\\\\\\\\n'' || v_sqltext;


END;
';