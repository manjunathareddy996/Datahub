CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_MV_CR_BULK_UPDATE("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
V_CNT NUMBER;
V_CNT1 NUMBER;
L_START NUMBER;
v_sqltext VARCHAR;
BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLM_BULK_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLM_BULK_UPDATE
 SELECT
                 C_CLAIM_ID_SK,
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
        C_SUR_APP_DATE,
        C_SUR_REP_DATE,
        C_CHQ_ISS_DATE,
        C_CLO_DATE,
        C_SUR_NAME,
        C_SUR_LIC_NO,
        C_REP_NAME,
        C_BILL_DATE,
        C_DRI_LIC_NO,
        C_OFF_LOC_ID,
        C_PARTS_CLAIMED,
        C_NAME_OF_IN1,
        C_NAME_OF_IN2,
        C_NAME_OF_IN3,
        C_NAME_OF_IN4,
        C_NAME_OF_IN5,
        C_ADV_NAME,
        C_CLAIM_TYPE,
        C_COMMENTS,
        C_PAID_FLAG,
        C_POLICY_GRAIN,
        C_CLAIM_REGD_BY,
        C_LAST_REOPEN_DATE,
        C_REOPEN_FLAG,
        C_CONS_FORUM_FLAG,
        C_OMBSMAN_FLAG,
        C_LIGITATION_FLAG,
        C_RECPT_PSR_DATE,
        C_RECPT_FSR_DATE,
        C_ALL_DOC_DATE,
        C_COURT_FLAG,
        C_SPECIAL_COMMENTS,
        C_FIRST_REOPEN_DATE,
        C_MRN_TRANSPORTER_NAME,
        C_INVOICE_NO,
        C_SETTLEMNT_TYPE,
        C_DELAY_REASON,
        C_EMEDITEK_CLAIM_NO,
        C_RFA_DATE,
        C_EVENT_CODE,
        C_TPA_STATUS,
        C_INVOICE_DATE,
        C_FSR_PSR_STATUS,
        C_PLACE_OF_LOSS,
        C_LANDMARK,
        C_AREA,
        C_STATE,
        C_CITY,
        C_PINCODE,
        C_JOURNEY_FROM,
        C_JOURNEY_TO,
        C_CONSIGNEE_NAME,
        C_CONSIGNER_NAME,
        C_SURVEY_LOCATION,
        C_GOODS_DETAILS,
        C_NEXT_RVW_DATE,
        C_LAST_RVW_REMARKS,
        C_LAST_RVW_DATE,
        C_FPLM_FLAG,
        C_CLAIM_ID,
        C_REOPEN_REMARK,
        C_REOPEN_BY,
        BASE_SUM_INSURED,
        ADDL_EXCESS,
        VOLUNTARY_EXCESS,
        COMPULSORY_EXCESS,
        EXPENSE_APP_DATE,
        LOSS_APP_DATE,
        NET_ASSESSED_AMOUNT,
        DEPRECIATION_AMOUNT,
        C_PORTAL_FLAG,
        C_MLT_YEAR,
        MAXIMUS_FLAG,
        null as INC_JOB_CREATED_AT,
        null as INC_JOB_CREATED_BY,
        null as INC_JOB_UPDATED_BY,
        null as INC_JOB_UPDATED_AT,
        null as INC_JOB_ID,
        c_od_type_of_loss,
        c_hhid,
        c_net_tax_labour,
        c_net_tax_parts
        FROM TRANSACTIONAL.ODS_CLAIM_DIM A
       WHERE DATE_TRUNC(''''DAY'''',A.ETL_REFRESH_AT) = DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || ''''''))'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
            SET HO_ID = src.HO_ID,
                NEXT_COURT_H_DATE = src.NEXT_COURT_H_DATE,
                CASE_TITLE = src.CASE_TITLE,
                CASE_PREFIX = src.CASE_PREFIX,
                COURT_STAGE = src.COURT_STAGE,
                TP_COMPRO_DEFENSE = src.TP_COMPRO_DEFENSE,
                STATUS_OF_INVESTIGATION_REPORT = src.STATUS_OF_INVESTIGATION_REPORT,
                DECISION_ON_AWARD = src.DECISION_ON_AWARD,
                DETAILS_OF_FOLLOWUP = src.DETAILS_OF_FOLLOWUP,
                INVESTIGATION_APPOINTMENTDATE = src.INVESTIGATION_APPOINTMENTDATE,
                TP_COURT_REMARKS = src.TP_COURT_REMARKS,
                INVEST_REPORT_RECEIVINGDATE = src.INVEST_REPORT_RECEIVINGDATE,
                REMARKS_OFLEGAL_OFFICER = src.REMARKS_OFLEGAL_OFFICER,
                TP_RESP_PERSON = src.TP_CASE_RESP_PERSON,
                TP_CLM_HANDLING_LOC = src.TP_CASE_CLAIM_LOCATION,
                CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''')
FROM
(
        SELECT CLAIM_NO,
               HO_ID,
               NEXT_COURT_H_DATE,
               CASE_TITLE,
               CASE_PREFIX,
               COURT_STAGE,
               TP_COMPRO_DEFENSE,
               STATUS_OF_INVESTIGATION_REPORT,
               DECISION_ON_AWARD,
               DETAILS_OF_FOLLOWUP,
               INVESTIGATION_APPOINTMENTDATE,
               TP_COURT_REMARKS,
               INVEST_REPORT_RECEIVINGDATE,
               REMARKS_OFLEGAL_OFFICER,
               TP_CASE_RESP_PERSON,
               TP_CASE_CLAIM_LOCATION
        FROM PROD_DWH_MIGRATED_DB.PROD.ODS_TP_CLM_DTLS A
        --JOIN INTERMEDIATE.BJAZ_STG_TPCLM B ON A.CLAIM_ID = B.CLAIM_ID
) AS src
WHERE C_CLAIM_NO = src.CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;


/*CALL LOGTRACE (
      ''''LOG'''',
      10001,
         ''''mv_claim_register CLM_BULK_UPDATE update 2-- time taken in mins : ''''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--BEGIN
--    SELECT COUNT(1)
--    INTO src.CNT
--    FROM INFORMATION_SCHEMA.TABLES
--    WHERE TABLE_NAME = ''''CONSUMPTION_DB.CLAIM_REGISTER.wrk_miss_clm_bulk_update'''';
--
--IF (V_CNT > 0)
--THEN


v_sqltext := ''DROP TABLE IF EXISTS INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

--   END IF;
--END;

v_sqltext := ''CREATE OR REPLACE TABLE INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE
AS
SELECT B.*
  FROM TRANSACTIONAL.MV_CLAIM_REGISTER A, INTERMEDIATE.WRK_CLM_BULK_UPDATE B
 WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
       AND (   NVL (A.C_CAUSE_OF_LOSS, ''''abc'''') <>
                  NVL (B.C_CAUSE_OF_LOSS, ''''abc'''')
            OR NVL (A.CLM_STATUS, ''''abc'''') <>
                  DECODE (B.C_CLAIM_STATUS, ''''CLOSED'''', ''''CLOSED'''', ''''OPEN'''')
            OR NVL (A.C_INTI_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_INTI_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_APP_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_APP_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_SUR_APP_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_SUR_APP_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_SUR_REP_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_SUR_REP_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_CLO_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_CLO_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_SUR_NAME, ''''abc'''') <> NVL (B.C_SUR_NAME, ''''abc'''')
            OR NVL (A.C_REP_NAME, ''''abc'''') <> NVL (B.C_REP_NAME, ''''abc'''')
            OR NVL (A.C_NAME_OF_IN1, ''''abc'''') <> NVL (B.C_NAME_OF_IN1, ''''abc'''')
            OR NVL (A.C_ADV_NAME, ''''abc'''') <> NVL (B.C_ADV_NAME, ''''abc'''')
            OR NVL (A.C_CLAIM_TYPE, ''''abc'''') <> NVL (B.C_CLAIM_TYPE, ''''abc'''')
            OR NVL (A.C_COMMENTS, ''''abc'''') <> NVL (B.C_COMMENTS, ''''abc'''')
            OR NVL (A.C_PAID_FLAG, 000) <> NVL (B.C_PAID_FLAG, 000)
            OR NVL (A.C_POLICY_GRAIN, ''''abc'''') <> NVL (B.C_POLICY_GRAIN, ''''abc'''')
            OR NVL (A.C_CLAIM_REGD_BY, ''''abc'''') <> B.C_CLAIM_REGD_BY
            OR NVL (A.C_LAST_REOPEN_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_LAST_REOPEN_DATE, ''''26-sep-1992'''')
            OR NVL (A.REOPEN_FLAG, ''''abc'''') <>
                  DECODE (B.C_REOPEN_FLAG, 1, ''''Y'''', ''''N'''')
            OR NVL (A.CONSUMER_FORUM_FLAG, ''''abc'''') <>
                  NVL (B.C_CONS_FORUM_FLAG, ''''abc'''')
            OR NVL (A.C_OMBSMAN_FLAG, ''''abc'''') <> NVL (B.C_OMBSMAN_FLAG, ''''abc'''')
            OR NVL (A.C_LIGITATION_FLAG, ''''abc'''') <>
                  NVL (B.C_LIGITATION_FLAG, ''''abc'''')
            OR NVL (A.C_RECPT_PSR_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_RECPT_PSR_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_RECPT_FSR_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_RECPT_FSR_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_ALL_DOC_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_ALL_DOC_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_COURT_FLAG, ''''abc'''') <> NVL (B.C_COURT_FLAG, ''''abc'''')
            OR NVL (A.C_SPECIAL_COMMENTS, ''''abc'''') <>
                  NVL (B.C_SPECIAL_COMMENTS, ''''abc'''')
            OR NVL (A.C_MRN_TRANSPORTER_NAME, ''''abc'''') <>
                  NVL (B.C_MRN_TRANSPORTER_NAME, ''''abc'''')
            OR NVL (A.C_INVOICE_NO, ''''abc'''') <> NVL (B.C_INVOICE_NO, ''''abc'''')
            OR NVL (A.C_SETTLEMNT_TYPE, ''''abc'''') <>
                  NVL (B.C_SETTLEMNT_TYPE, ''''abc'''')
            OR NVL (A.C_DELAY_REASON, ''''abc'''') <> NVL (B.C_DELAY_REASON, ''''abc'''')
            OR NVL (A.C_EMEDITEK_CLAIM_NO, ''''abc'''') <>
                  NVL (B.C_EMEDITEK_CLAIM_NO, ''''abc'''')
            OR NVL (A.C_RFA_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_RFA_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_EVENT_CODE, ''''abc'''') <> NVL (B.C_EVENT_CODE, ''''abc'''')
            OR NVL (A.C_TPA_STATUS, ''''abc'''') <> NVL (B.C_TPA_STATUS, ''''abc'''')
            OR NVL (A.C_INVOICE_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_INVOICE_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_FSR_PSR_STATUS, ''''abc'''') <>
                  NVL (B.C_FSR_PSR_STATUS, ''''abc'''')
            OR NVL (A.C_PLACE_OF_LOSS, ''''abc'''') <>
                  NVL (B.C_PLACE_OF_LOSS, ''''abc'''')
            OR NVL (A.C_LANDMARK, ''''abc'''') <> NVL (B.C_LANDMARK, ''''abc'''')
            OR NVL (A.C_AREA, ''''abc'''') <> NVL (B.C_AREA, ''''abc'''')
            OR NVL (A.C_STATE, ''''abc'''') <> NVL (B.C_STATE, ''''abc'''')
            OR NVL (A.C_CITY, ''''abc'''') <> NVL (B.C_CITY, ''''abc'''')
            OR NVL (A.C_PINCODE, 0000) <> NVL (B.C_PINCODE, 0000)
            OR NVL (A.C_JOURNEY_FROM, ''''abc'''') <> NVL (B.C_JOURNEY_FROM, ''''abc'''')
            OR NVL (A.C_JOURNEY_TO, ''''abc'''') <> NVL (B.C_JOURNEY_TO, ''''abc'''')
            OR NVL (A.C_CONSIGNEE_NAME, ''''abc'''') <>
                  NVL (B.C_CONSIGNEE_NAME, ''''abc'''')
            OR NVL (A.C_CONSIGNER_NAME, ''''abc'''') <>
                  NVL (B.C_CONSIGNER_NAME, ''''abc'''')
            OR NVL (A.C_SURVEY_LOCATION, ''''abc'''') <>
                  NVL (B.C_SURVEY_LOCATION, ''''abc'''')
            OR NVL (A.C_GOODS_DETAILS, ''''abc'''') <>
                  NVL (B.C_GOODS_DETAILS, ''''abc'''')
            OR NVL (A.C_NEXT_RVW_DATE, ''''26-sep-1992'''') <>
                  NVL (B.C_NEXT_RVW_DATE, ''''26-sep-1992'''')
            OR NVL (A.C_LAST_RVW_REMARKS, ''''abc'''') <>
                  NVL (B.C_LAST_RVW_REMARKS, ''''abc'''')
            OR NVL (A.C_FPLM_FLAG, ''''abc'''') <> NVL (B.C_FPLM_FLAG, ''''abc'''')
            OR NVL (A.C_REOPEN_REMARK, ''''abc'''') <>
                  NVL (B.C_REOPEN_REMARK, ''''abc'''')
            OR NVL (A.C_REOPEN_BY, ''''abc'''') <> NVL (B.C_REOPEN_BY, ''''abc'''')
            OR NVL (A.BASE_SUM_INSURED, 0) <> NVL (B.BASE_SUM_INSURED, 0)
            OR NVL (A.C_MLT_YEAR, 0) <> NVL (B.C_MLT_YEAR, 0)
            OR NVL(A.NET_ASSESSED_AMOUNT,0)<>NVL(B.NET_ASSESSED_AMOUNT,0)
            OR NVL(A.DEPRECIATION_AMOUNT,0)<>NVL(B.DEPRECIATION_AMOUNT,0)
            OR NVL(A.c_od_type_of_loss,''''ABC'''')<>NVL(B.c_od_type_of_loss,''''ABC'''')
            OR NVL(A.c_hhid,''''ABC'''')<>NVL(B.c_hhid,''''ABC'''')
            OR NVL(A.c_net_tax_labour,0)<>NVL(B.c_net_tax_labour,0)
            OR NVL(A.c_net_tax_parts,0)<>NVL(B.c_net_tax_parts,0)
            OR NVL (A.C_PORTAL_FLAG,''''NEW'''') <> NVL (B.C_PORTAL_FLAG,''''NEW'''')  --ADDED BY ASHISH ON 14NOV 25 SUGGESTED BY RM
               OR NVL (A.C_LOSS_DATE, ''''26-sep-1992'''') <>
                     NVL (B.C_LOSS_DATE, ''''26-sep-1992'''')

            )'';
EXECUTE IMMEDIATE v_sqltext;


-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''mv_claim_register CONSUMPTION_DB.CLAIM_REGISTER.wrk_miss_clm_bulk_update CREATED -- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

--SELECT COUNT (1)
--     INTO src.CNT1
--     FROM INFORMATION_SCHEMA.TABLES
--    WHERE TABLE_NAME = ''''CONSUMPTION_DB.CLAIM_REGISTER.wrk_miss_clm_bulk_update_s'''';


--IF (V_CNT1 > 0)
--THEN
v_sqltext := ''DROP TABLE IF EXISTS INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE_S'';
EXECUTE IMMEDIATE v_sqltext;

--END IF;

v_sqltext := ''CREATE OR REPLACE TABLE INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE_S
            AS
            SELECT DISTINCT * FROM INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE_F'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO  INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE_F
(
C_CLAIM_ID_SK,
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
C_SUR_APP_DATE,
C_SUR_REP_DATE,
C_CHQ_ISS_DATE,
C_CLO_DATE,
C_SUR_NAME,
C_SUR_LIC_NO,
C_REP_NAME,
C_BILL_DATE,
C_DRI_LIC_NO,
C_OFF_LOC_ID,
C_PARTS_CLAIMED,
C_NAME_OF_IN1,
C_NAME_OF_IN2,
C_NAME_OF_IN3,
C_NAME_OF_IN4,
C_NAME_OF_IN5,
C_ADV_NAME,
C_CLAIM_TYPE,
C_COMMENTS,
C_PAID_FLAG,
C_POLICY_GRAIN,
C_CLAIM_REGD_BY,
C_LAST_REOPEN_DATE,
C_REOPEN_FLAG,
C_CONS_FORUM_FLAG,
C_OMBSMAN_FLAG,
C_LIGITATION_FLAG,
C_RECPT_PSR_DATE,
C_RECPT_FSR_DATE,
C_ALL_DOC_DATE,
C_COURT_FLAG,
C_SPECIAL_COMMENTS,
C_FIRST_REOPEN_DATE,
C_MRN_TRANSPORTER_NAME,
C_INVOICE_NO,
C_SETTLEMNT_TYPE,
C_DELAY_REASON,
C_EMEDITEK_CLAIM_NO,
C_RFA_DATE,
C_EVENT_CODE,
C_TPA_STATUS,
C_INVOICE_DATE,
C_FSR_PSR_STATUS,
C_PLACE_OF_LOSS,
C_LANDMARK,
C_AREA,
C_STATE,
C_CITY,
C_PINCODE,
C_JOURNEY_FROM,
C_JOURNEY_TO,
C_CONSIGNEE_NAME,
C_CONSIGNER_NAME,
C_SURVEY_LOCATION,
C_GOODS_DETAILS,
C_NEXT_RVW_DATE,
C_LAST_RVW_REMARKS,
C_LAST_RVW_DATE,
C_FPLM_FLAG,
C_CLAIM_ID,
C_REOPEN_REMARK,
C_REOPEN_BY,
BASE_SUM_INSURED,
ADDL_EXCESS,
VOLUNTARY_EXCESS,
COMPULSORY_EXCESS,
EXPENSE_APP_DATE,
LOSS_APP_DATE,
NET_ASSESSED_AMOUNT,
DEPRECIATION_AMOUNT,
C_PORTAL_FLAG,
C_MLT_YEAR,
MAXIMUS_FLAG,
c_od_type_of_loss,
c_hhid,
c_net_tax_labour,
c_net_tax_parts
)

SELECT

C_CLAIM_ID_SK,
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
C_SUR_APP_DATE,
C_SUR_REP_DATE,
C_CHQ_ISS_DATE,
C_CLO_DATE,
C_SUR_NAME,
C_SUR_LIC_NO,
C_REP_NAME,
C_BILL_DATE,
C_DRI_LIC_NO,
C_OFF_LOC_ID,
C_PARTS_CLAIMED,
C_NAME_OF_IN1,
C_NAME_OF_IN2,
C_NAME_OF_IN3,
C_NAME_OF_IN4,
C_NAME_OF_IN5,
C_ADV_NAME,
C_CLAIM_TYPE,
C_COMMENTS,
C_PAID_FLAG,
C_POLICY_GRAIN,
C_CLAIM_REGD_BY,
C_LAST_REOPEN_DATE,
C_REOPEN_FLAG,
C_CONS_FORUM_FLAG,
C_OMBSMAN_FLAG,
C_LIGITATION_FLAG,
C_RECPT_PSR_DATE,
C_RECPT_FSR_DATE,
C_ALL_DOC_DATE,
C_COURT_FLAG,
C_SPECIAL_COMMENTS,
C_FIRST_REOPEN_DATE,
C_MRN_TRANSPORTER_NAME,
C_INVOICE_NO,
C_SETTLEMNT_TYPE,
C_DELAY_REASON,
C_EMEDITEK_CLAIM_NO,
C_RFA_DATE,
C_EVENT_CODE,
C_TPA_STATUS,
C_INVOICE_DATE,
C_FSR_PSR_STATUS,
C_PLACE_OF_LOSS,
C_LANDMARK,
C_AREA,
C_STATE,
C_CITY,
C_PINCODE,
C_JOURNEY_FROM,
C_JOURNEY_TO,
C_CONSIGNEE_NAME,
C_CONSIGNER_NAME,
C_SURVEY_LOCATION,
C_GOODS_DETAILS,
C_NEXT_RVW_DATE,
C_LAST_RVW_REMARKS,
C_LAST_RVW_DATE,
C_FPLM_FLAG,
C_CLAIM_ID,
C_REOPEN_REMARK,
C_REOPEN_BY,
BASE_SUM_INSURED,
ADDL_EXCESS,
VOLUNTARY_EXCESS,
COMPULSORY_EXCESS,
EXPENSE_APP_DATE,
LOSS_APP_DATE,
NET_ASSESSED_AMOUNT,
DEPRECIATION_AMOUNT,
C_PORTAL_FLAG,
C_MLT_YEAR,
MAXIMUS_FLAG,
c_od_type_of_loss,
c_hhid,
c_net_tax_labour,
c_net_tax_parts
            FROM INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE_S'';
EXECUTE IMMEDIATE v_sqltext;

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''mv_claim_register CONSUMPTION_DB.CLAIM_REGISTER.wrk_miss_clm_bulk_update_f Inserted -- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


v_sqltext := ''MERGE INTO TRANSACTIONAL.MV_CLAIM_REGISTER A
        USING (SELECT
                     * FROM INTERMEDIATE.WRK_MISS_CLM_BULK_UPDATE_F) B
           ON (A.C_CLAIM_NO = B.C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET
         C_CAUSE_OF_LOSS = B.C_CAUSE_OF_LOSS,
         CLM_STATUS = DECODE (B.C_CLAIM_STATUS, ''''CLOSED'''', ''''CLOSED'''', ''''OPEN''''),
         C_INTI_DATE = B.C_INTI_DATE,
         C_APP_DATE = B.C_APP_DATE,
         C_SUR_APP_DATE = B.C_SUR_APP_DATE,
         C_SUR_REP_DATE = B.C_SUR_REP_DATE,
         C_CLO_DATE = B.C_CLO_DATE,
         C_SUR_NAME = B.C_SUR_NAME,
         C_REP_NAME = B.C_REP_NAME,
         C_NAME_OF_IN1 = B.C_NAME_OF_IN1,
         C_ADV_NAME = B.C_ADV_NAME,
         C_CLAIM_TYPE = B.C_CLAIM_TYPE,
         C_COMMENTS = B.C_COMMENTS,
         C_PAID_FLAG = B.C_PAID_FLAG,
         C_POLICY_GRAIN = B.C_POLICY_GRAIN,
         C_CLAIM_REGD_BY = B.C_CLAIM_REGD_BY,
         C_LAST_REOPEN_DATE = B.C_LAST_REOPEN_DATE,
         REOPEN_FLAG = DECODE (B.C_REOPEN_FLAG, 1, ''''Y'''', ''''N''''),
         CONSUMER_FORUM_FLAG = B.C_CONS_FORUM_FLAG,
         C_OMBSMAN_FLAG = B.C_OMBSMAN_FLAG,
         C_LIGITATION_FLAG = B.C_LIGITATION_FLAG,
         C_RECPT_PSR_DATE = B.C_RECPT_PSR_DATE,
         C_RECPT_FSR_DATE = B.C_RECPT_FSR_DATE,
         C_ALL_DOC_DATE = B.C_ALL_DOC_DATE,
         C_COURT_FLAG = B.C_COURT_FLAG,
         C_SPECIAL_COMMENTS = B.C_SPECIAL_COMMENTS,
         C_MRN_TRANSPORTER_NAME = B.C_MRN_TRANSPORTER_NAME,
         C_INVOICE_NO = B.C_INVOICE_NO,
         C_SETTLEMNT_TYPE = B.C_SETTLEMNT_TYPE,
         C_DELAY_REASON = B.C_DELAY_REASON,
         C_EMEDITEK_CLAIM_NO = B.C_EMEDITEK_CLAIM_NO,
         C_RFA_DATE = B.C_RFA_DATE,
         C_EVENT_CODE = B.C_EVENT_CODE,
         C_TPA_STATUS = B.C_TPA_STATUS,
         C_INVOICE_DATE = B.C_INVOICE_DATE,
         C_FSR_PSR_STATUS = B.C_FSR_PSR_STATUS,
         C_PLACE_OF_LOSS = B.C_PLACE_OF_LOSS,
         C_LANDMARK = B.C_LANDMARK,
         C_AREA = B.C_AREA,
         C_STATE = B.C_STATE,
         C_CITY = B.C_CITY,
         C_PINCODE = B.C_PINCODE,
         C_JOURNEY_FROM = B.C_JOURNEY_FROM,
         C_JOURNEY_TO = B.C_JOURNEY_TO,
         C_CONSIGNEE_NAME = B.C_CONSIGNEE_NAME,
         C_CONSIGNER_NAME = B.C_CONSIGNER_NAME,
         C_SURVEY_LOCATION = B.C_SURVEY_LOCATION,
         C_GOODS_DETAILS = B.C_GOODS_DETAILS,
         C_NEXT_RVW_DATE = B.C_NEXT_RVW_DATE,
         C_LAST_RVW_REMARKS = B.C_LAST_RVW_REMARKS,
         C_FPLM_FLAG = B.C_FPLM_FLAG,
         C_REOPEN_REMARK = B.C_REOPEN_REMARK,
         C_REOPEN_BY = B.C_REOPEN_BY,
         BASE_SUM_INSURED = B.BASE_SUM_INSURED,
         C_MLT_YEAR = B.C_MLT_YEAR,
         NET_ASSESSED_AMOUNT=B.NET_ASSESSED_AMOUNT,
         DEPRECIATION_AMOUNT=B.DEPRECIATION_AMOUNT,
         CHANGE_DATE = CURRENT_DATE,
         TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')),
         c_od_type_of_loss = B.c_od_type_of_loss,
         c_hhid = B.c_hhid,
         c_net_tax_labour = B.c_net_tax_labour,
         c_net_tax_parts = B.c_net_tax_parts,
          C_PORTAL_FLAG=b.C_PORTAL_FLAG,
         C_LOSS_DATE=b.C_LOSS_DATE
         '';
EXECUTE IMMEDIATE v_sqltext;

EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\\\\\n'' || ''SQL: '' || ''\\\\\\\\n'' || v_sqltext;

END;
';