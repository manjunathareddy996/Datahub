CREATE OR REPLACE PROCEDURE TRANSACTIONAL.BJAZ_AGRINXT_CR_LOAD("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '

DECLARE
v_sqltext varchar;


BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_AGRI_ODS_CLAIM_DIM'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.STG_AGRI_ODS_CLAIM_DIM
      SELECT C_CLAIM_ID_SK,
             C_CAUSE_OF_LOSS,
             C_CLAIM_NO,
             CASE WHEN  UPPER(NVL(INUBESTATUS,C_CLAIM_STATUS)) IN (''''OPEN'''',''''REOPEN'''',''''UTR FAILED'''') THEN ''''OPEN'''' ELSE ''''CLOSED'''' END  C_CLAIM_STATUS,
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
             CASE
                WHEN UPPER (C_CLAIM_TYPE) = ''''THIRD PARTY CLAIM'''' THEN ''''TP''''
                WHEN UPPER (C_CLAIM_TYPE) = ''''PERSONAL ACCIDENT'''' THEN ''''PA''''
                WHEN C_CAUSE_OF_LOSS = ''''TP'''' THEN ''''TP''''
                ELSE NULL
             END
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
             NVL (C_COURT_FLAG, ''''Normal Claim'''') C_COURT_FLAG,
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
             C_PORTAL_FLAG
        -- FROM PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_ODS_CLAIM_DIM_REPORT
        FROM BAGIC_PROD_MIRROR_DB.AGRINXT.TBL_ODS_CLAIM_DIM_REPORT
        WHERE TOPINDICATOR=''''Y'''''';
EXECUTE IMMEDIATE v_sqltext;


--BELOW NEW LOGIC ADDED ON 11-09-2025 BY RIZWAN SHAIKH

v_sqltext := ''MERGE INTO INTERMEDIATE.STG_AGRI_ODS_CLAIM_DIM X
        USING
 (  SELECT DISTINCT  c_claim_no,
MAX (
         CASE
            WHEN UPPER (NVL(INUBESTATUS,''''APPROVED'''')) IN ( ''''APPROVED'''',''''UTR GENERATED'''', '''''''')
        THEN
            CASE
                WHEN TO_CHAR(DWH_CREATED_DATE) LIKE ''''%/%/%''''
                THEN TO_DATE(TO_CHAR(DWH_CREATED_DATE), ''''DD/MM/YYYY'''')
                WHEN TO_CHAR(DWH_CREATED_DATE) LIKE ''''%-%-%''''
                THEN TO_DATE(TO_CHAR(DWH_CREATED_DATE), ''''DD-MM-YYYY'''')


                        WHEN C_CLO_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (DWH_CREATED_DATE), ''''YYYY-MM-DD'''')
                        WHEN C_CLO_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (DWH_CREATED_DATE), ''''YYYY/MM/DD'''')



                ELSE NULL
            END
    END
) close_date,


MAX (
    CASE
        WHEN UPPER (INUBESTATUS)  IN  (''''REOPEN'''',''''UTR FAILED'''')

        THEN
            CASE
                WHEN TO_CHAR(DWH_CREATED_DATE) LIKE ''''%/%/%''''
                THEN TO_DATE(TO_CHAR(DWH_CREATED_DATE), ''''DD/MM/YYYY'''')
                WHEN TO_CHAR(DWH_CREATED_DATE) LIKE ''''%-%-%''''
                THEN TO_DATE(TO_CHAR(DWH_CREATED_DATE), ''''DD-MM-YYYY'''')
                ELSE NULL
            END
    END
) REOPEN_date,
 FROM BAGIC_PROD_MIRROR_DB.AGRINXT.TBL_ODS_CLAIM_DIM_REPORT
WHERE UPPER (NVL(INUBESTATUS,''''APPROVED'''')) IN (''''REOPEN'''', ''''APPROVED'''', ''''UTR FAILED'''', ''''UTR GENERATED'''', '''''''')
               GROUP BY c_claim_no) Y
           ON (X.C_CLAIM_NO = Y.C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET
         X.C_CLO_DATE = Y.close_date,
         X.C_LAST_REOPEN_DATE = Y.REOPEN_date,
         X.C_REOPEN_FLAG =
            CASE WHEN Y.REOPEN_date IS NOT NULL THEN ''''Y'''' ELSE ''''N'''' END'';

EXECUTE IMMEDIATE v_sqltext;




v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM OCD
        USING (SELECT C_CAUSE_OF_LOSS,
                      C_CLAIM_NO,
                      C_CLAIM_STATUS,
                      C_KIND_OF_LOSS,
                      C_ACCIDENT_LOC,
                      -- TO_DATE (TO_CHAR (C_LOSS_DATE), ''''DD-MM-YYYY'''')
                      --    C_LOSS_DATE,
                      CASE
                      WHEN C_LOSS_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_LOSS_DATE), ''''DD-MM-YYYY'''')
                      WHEN C_LOSS_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_LOSS_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END C_LOSS_DATE,
                      C_LOSS_TIME,
                      -- TO_DATE (TO_CHAR (C_INTI_DATE), ''''DD-MM-YYYY'''')
                      --    C_INTI_DATE,
                      CASE
                      WHEN C_INTI_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_INTI_DATE), ''''DD-MM-YYYY'''')
                      WHEN C_INTI_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_INTI_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END C_INTI_DATE,
                      -- TO_DATE (TO_CHAR (C_REGN_DATE), ''''DD-MM-YYYY'''')
                      --    C_REGN_DATE,
                      CASE
                      WHEN C_REGN_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_REGN_DATE), ''''DD-MM-YYYY'''')
                      WHEN C_REGN_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_REGN_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END C_REGN_DATE,
                      -- TO_DATE (TO_CHAR (C_APP_DATE), ''''DD-MM-YYYY'''') C_APP_DATE,
                      CASE
                        WHEN C_APP_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_APP_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_APP_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_APP_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_APP_DATE,
                      -- TO_DATE (TO_CHAR (C_SUR_APP_DATE), ''''DD-MM-YYYY'''')
                      --   C_SUR_APP_DATE,
                      CASE
                        WHEN C_SUR_APP_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_SUR_APP_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_SUR_APP_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_SUR_APP_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_SUR_APP_DATE,
                     --  TO_DATE (TO_CHAR (C_SUR_REP_DATE), ''''DD-MM-YYYY'''')
                     --     C_SUR_REP_DATE,
                      CASE
                        WHEN C_SUR_REP_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_SUR_REP_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_SUR_REP_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_SUR_REP_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_SUR_REP_DATE,
                      -- TO_DATE(TO_CHAR(TO_DATE(C_CHQ_ISS_DATE, ''''DD-MM-YY''''), ''''YYYY-MM-DD''''))
                      --    C_CHQ_ISS_DATE,
                      CASE
                        WHEN C_CHQ_ISS_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_CHQ_ISS_DATE), ''''YYYY-MM-DD'''')
                        WHEN C_CHQ_ISS_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_CHQ_ISS_DATE), ''''YYYY-MM-DD'''')
                        ELSE NULL
                      END AS C_CHQ_ISS_DATE,
                     -- TO_DATE (TO_CHAR (C_CLO_DATE), ''''DD-MM-YYYY'''')  C_CLO_DATE,




                     -- CASE
                     --    WHEN C_CLO_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_CLO_DATE), ''''DD-MM-YYYY'''')
                     --    WHEN C_CLO_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_CLO_DATE), ''''DD/MM/YYYY'''')
                     --      WHEN C_CLO_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_CLO_DATE), ''''YYYY-MM-DD'''')
                     --    WHEN C_CLO_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_CLO_DATE), ''''YYYY/MM/DD'''')


                     --    ELSE NULL
                     --  END AS C_CLO_DATE,


COALESCE(
    TRY_TO_DATE(TO_CHAR(C_CLO_DATE), ''''DD-MM-YYYY''''),
    TRY_TO_DATE(TO_CHAR(C_CLO_DATE), ''''DD/MM/YYYY''''),
    TRY_TO_DATE(TO_CHAR(C_CLO_DATE), ''''YYYY-MM-DD''''),
    TRY_TO_DATE(TO_CHAR(C_CLO_DATE), ''''YYYY/MM/DD''''),
    TRY_TO_DATE(TO_CHAR(C_CLO_DATE), ''''MM/DD/YYYY''''),
    TRY_TO_DATE(TO_CHAR(C_CLO_DATE), ''''MM-DD-YYYY'''')
) AS C_CLO_DATE,




                      C_SUR_NAME,
                      C_SUR_LIC_NO,
                      C_REP_NAME,
                      -- C_BILL_DATE,
                      CASE
                        WHEN C_BILL_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_BILL_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_BILL_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_BILL_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_BILL_DATE,
                      C_DRI_LIC_NO,
                      TRY_TO_NUMBER(C_OFF_LOC_ID, 10, 0) C_OFF_LOC_ID,
                      TRY_TO_NUMBER(C_PARTS_CLAIMED, 10, 0) C_PARTS_CLAIMED,
                      C_NAME_OF_IN1,
                      C_NAME_OF_IN2,
                      C_NAME_OF_IN3,
                      C_NAME_OF_IN4,
                      C_NAME_OF_IN5,
                      C_ADV_NAME,
                      C_CLAIM_TYPE,
                      C_COMMENTS,
                      DECODE (C_PAID_FLAG, ''''N'''', 0, 1) C_PAID_FLAG,
                      C_POLICY_GRAIN,
                      C_CLAIM_REGD_BY,
                      -- TO_DATE (TO_CHAR (C_LAST_REOPEN_DATE), ''''DD-MM-YYYY'''')
                      --    C_LAST_REOPEN_DATE,



                      --  CASE
                      --   WHEN C_LAST_REOPEN_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_LAST_REOPEN_DATE), ''''DD-MM-YYYY'''')
                      --   WHEN C_LAST_REOPEN_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_LAST_REOPEN_DATE), ''''DD/MM/YYYY'''')
                      --   ELSE NULL
                      -- END AS C_LAST_REOPEN_DATE,



COALESCE(
    TRY_TO_DATE(TO_CHAR(C_LAST_REOPEN_DATE), ''''DD-MM-YYYY''''),
    TRY_TO_DATE(TO_CHAR(C_LAST_REOPEN_DATE), ''''DD/MM/YYYY''''),
    TRY_TO_DATE(TO_CHAR(C_LAST_REOPEN_DATE), ''''YYYY-MM-DD''''),
    TRY_TO_DATE(TO_CHAR(C_LAST_REOPEN_DATE), ''''YYYY/MM/DD''''),
    TRY_TO_DATE(TO_CHAR(C_LAST_REOPEN_DATE), ''''MM/DD/YYYY''''),
    TRY_TO_DATE(TO_CHAR(C_LAST_REOPEN_DATE), ''''MM-DD-YYYY'''')
) AS C_LAST_REOPEN_DATE,


DECODE (C_REOPEN_FLAG, ''''Y'''', 1, 0) C_REOPEN_FLAG,

                      C_CONS_FORUM_FLAG,
                      C_OMBSMAN_FLAG,
                      C_LIGITATION_FLAG,
                      -- TO_DATE (TO_CHAR (C_RECPT_PSR_DATE), ''''DD-MM-YYYY'''')
                      --    C_RECPT_PSR_DATE,
                        CASE
                        WHEN C_RECPT_PSR_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_RECPT_PSR_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_RECPT_PSR_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_RECPT_PSR_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_RECPT_PSR_DATE,
                      -- TO_DATE (TO_CHAR (C_RECPT_FSR_DATE), ''''DD-MM-YYYY'''')
                      --    C_RECPT_FSR_DATE,
                        CASE
                        WHEN C_RECPT_FSR_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_RECPT_FSR_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_RECPT_FSR_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_RECPT_FSR_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_RECPT_FSR_DATE,
                      -- TO_DATE (TO_CHAR (C_ALL_DOC_DATE), ''''DD-MM-YYYY'''')
                      --    C_ALL_DOC_DATE,
                        CASE
                        WHEN C_ALL_DOC_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_ALL_DOC_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_ALL_DOC_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_ALL_DOC_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_ALL_DOC_DATE,
                      C_COURT_FLAG,
                      C_SPECIAL_COMMENTS,
                      -- TO_DATE (TO_CHAR (C_FIRST_REOPEN_DATE), ''''DD-MM-YYYY'''')
                      --    C_FIRST_REOPEN_DATE,
                        CASE
                        WHEN C_FIRST_REOPEN_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_FIRST_REOPEN_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_FIRST_REOPEN_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_FIRST_REOPEN_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_FIRST_REOPEN_DATE,
                      C_MRN_TRANSPORTER_NAME,
                      C_INVOICE_NO,
                      C_SETTLEMNT_TYPE,
                      C_DELAY_REASON,
                      C_EMEDITEK_CLAIM_NO,
                      -- TO_DATE (TO_CHAR (C_RFA_DATE), ''''DD-MM-YYYY'''') C_RFA_DATE,
                      CASE
                        WHEN C_RFA_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_RFA_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_RFA_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_RFA_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_RFA_DATE,
                      C_EVENT_CODE,
                      C_TPA_STATUS,
                      -- TO_DATE (TO_CHAR (C_INVOICE_DATE), ''''DD-MM-YYYY'''')
                      -- C_INVOICE_DATE,
                      CASE
                        WHEN C_INVOICE_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_INVOICE_DATE), ''''DD-MM-YYYY'''')
                        WHEN C_INVOICE_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_INVOICE_DATE), ''''DD/MM/YYYY'''')
                        ELSE NULL
                      END AS C_INVOICE_DATE,
                      C_FSR_PSR_STATUS,
                      C_PLACE_OF_LOSS,
                      C_LANDMARK,
                      C_AREA,
                      C_STATE,
                      C_CITY,
                      TRY_TO_NUMBER(C_PINCODE, 6, 0) C_PINCODE,
                      C_JOURNEY_FROM,
                      C_JOURNEY_TO,
                      C_CONSIGNEE_NAME,
                      C_CONSIGNER_NAME,
                      C_SURVEY_LOCATION,
                      C_GOODS_DETAILS,
                      -- TO_DATE (TO_CHAR (C_NEXT_RVW_DATE), ''''DD-MM-YYYY'''')
                      --    C_NEXT_RVW_DATE,
                      CASE
                      WHEN C_NEXT_RVW_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_NEXT_RVW_DATE), ''''DD-MM-YYYY'''')
                      WHEN C_NEXT_RVW_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_NEXT_RVW_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END C_NEXT_RVW_DATE,
                      C_LAST_RVW_REMARKS,
                      -- TO_DATE (TO_CHAR (C_LAST_RVW_DATE), ''''DD-MM-YYYY'''')
                      --    C_LAST_RVW_DATE,
                       CASE
                      WHEN C_LAST_RVW_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_LAST_RVW_DATE), ''''DD-MM-YYYY'''')
                      WHEN C_LAST_RVW_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_LAST_RVW_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END C_LAST_RVW_DATE,
                      C_FPLM_FLAG,
                      C_REOPEN_REMARK,
                      C_REOPEN_BY,
                      BASE_SUM_INSURED,
                      TRY_TO_NUMBER(ADDL_EXCESS, 38, 10) ADDL_EXCESS,
                      TRY_TO_NUMBER(VOLUNTARY_EXCESS, 38, 10) VOLUNTARY_EXCESS,
                      TRY_TO_NUMBER(COMPULSORY_EXCESS, 38, 10) COMPULSORY_EXCESS,
                      -- TO_DATE (TO_CHAR (EXPENSE_APP_DATE), ''''DD-MM-YYYY'''')
                      --    EXPENSE_APP_DATE,
                      CASE
                      WHEN EXPENSE_APP_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (EXPENSE_APP_DATE), ''''DD-MM-YYYY'''')
                      WHEN EXPENSE_APP_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (EXPENSE_APP_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END EXPENSE_APP_DATE,
                      -- TO_DATE (TO_CHAR (LOSS_APP_DATE), ''''DD-MM-YYYY'''')
                      --    LOSS_APP_DATE,
                         CASE
                      WHEN LOSS_APP_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (LOSS_APP_DATE), ''''DD-MM-YYYY'''')
                      WHEN LOSS_APP_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (LOSS_APP_DATE), ''''DD/MM/YYYY'''')
                      ELSE NULL
                      END LOSS_APP_DATE,
                      TRY_TO_NUMBER(NET_ASSESSED_AMOUNT, 38, 10) NET_ASSESSED_AMOUNT,
                      TRY_TO_NUMBER(DEPRECIATION_AMOUNT, 38, 10) DEPRECIATION_AMOUNT,
                      C_PORTAL_FLAG
                 FROM INTERMEDIATE.STG_AGRI_ODS_CLAIM_DIM
                 QUALIFY ROW_NUMBER() OVER (PARTITION BY C_CLAIM_NO ORDER BY (CASE
     WHEN C_ACCIDENT_LOC LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (C_ACCIDENT_LOC), ''''DD-MM-YYYY'''')
       WHEN C_ACCIDENT_LOC LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (C_ACCIDENT_LOC), ''''DD/MM/YYYY'''')
    ELSE NULL END) DESC) = 1) MOCD
           ON (OCD.C_CLAIM_NO = MOCD.C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET OCD.C_CAUSE_OF_LOSS = MOCD.C_CAUSE_OF_LOSS,
                 OCD.C_CLAIM_STATUS = MOCD.C_CLAIM_STATUS,
                 OCD.C_KIND_OF_LOSS = MOCD.C_KIND_OF_LOSS,
                 OCD.C_ACCIDENT_LOC = MOCD.C_ACCIDENT_LOC,
                 OCD.C_LOSS_DATE = MOCD.C_LOSS_DATE,
                 OCD.C_LOSS_TIME = MOCD.C_LOSS_TIME,
                 OCD.C_INTI_DATE = MOCD.C_INTI_DATE,
                 OCD.C_APP_DATE = MOCD.C_APP_DATE,
                 OCD.C_SUR_APP_DATE = MOCD.C_SUR_APP_DATE,
                 OCD.C_SUR_REP_DATE = MOCD.C_SUR_REP_DATE,
                 OCD.C_CHQ_ISS_DATE = MOCD.C_CHQ_ISS_DATE,
                 OCD.C_CLO_DATE = MOCD.C_CLO_DATE,
                 OCD.C_SUR_NAME = MOCD.C_SUR_NAME,
                 OCD.C_SUR_LIC_NO = MOCD.C_SUR_LIC_NO,
                 OCD.C_REP_NAME = MOCD.C_REP_NAME,
                 OCD.C_BILL_DATE = MOCD.C_BILL_DATE,
                 OCD.C_DRI_LIC_NO = MOCD.C_DRI_LIC_NO,
                 OCD.C_OFF_LOC_ID = MOCD.C_OFF_LOC_ID,
                 OCD.C_PARTS_CLAIMED = MOCD.C_PARTS_CLAIMED,
                 OCD.C_NAME_OF_IN1 = MOCD.C_NAME_OF_IN1,
                 OCD.C_NAME_OF_IN2 = MOCD.C_NAME_OF_IN2,
                 OCD.C_NAME_OF_IN3 = MOCD.C_NAME_OF_IN3,
                 OCD.C_NAME_OF_IN4 = MOCD.C_NAME_OF_IN4,
                 OCD.C_NAME_OF_IN5 = MOCD.C_NAME_OF_IN5,
                 OCD.C_ADV_NAME = MOCD.C_ADV_NAME,
                 OCD.C_CLAIM_TYPE = MOCD.C_CLAIM_TYPE,
                 OCD.C_COMMENTS = MOCD.C_COMMENTS,
                 OCD.C_PAID_FLAG = MOCD.C_PAID_FLAG,
                 OCD.C_POLICY_GRAIN = MOCD.C_POLICY_GRAIN,
                 OCD.C_CLAIM_REGD_BY = MOCD.C_CLAIM_REGD_BY,
                 OCD.C_LAST_REOPEN_DATE = MOCD.C_LAST_REOPEN_DATE,
                 OCD.C_REOPEN_FLAG = MOCD.C_REOPEN_FLAG,
                 OCD.C_CONS_FORUM_FLAG = MOCD.C_CONS_FORUM_FLAG,
                 OCD.C_OMBSMAN_FLAG = MOCD.C_OMBSMAN_FLAG,
                 OCD.C_LIGITATION_FLAG = MOCD.C_LIGITATION_FLAG,
                 OCD.C_RECPT_PSR_DATE = MOCD.C_RECPT_PSR_DATE,
                 OCD.C_RECPT_FSR_DATE = MOCD.C_RECPT_FSR_DATE,
                 OCD.C_ALL_DOC_DATE = MOCD.C_ALL_DOC_DATE,
                 OCD.C_COURT_FLAG = MOCD.C_COURT_FLAG,
                 OCD.C_SPECIAL_COMMENTS = MOCD.C_SPECIAL_COMMENTS,
                 OCD.C_FIRST_REOPEN_DATE = MOCD.C_FIRST_REOPEN_DATE,
                 OCD.C_MRN_TRANSPORTER_NAME = MOCD.C_MRN_TRANSPORTER_NAME,
                 OCD.C_INVOICE_NO = MOCD.C_INVOICE_NO,
                 OCD.C_SETTLEMNT_TYPE = MOCD.C_SETTLEMNT_TYPE,
                 OCD.C_DELAY_REASON = MOCD.C_DELAY_REASON,
                 OCD.C_EMEDITEK_CLAIM_NO = MOCD.C_EMEDITEK_CLAIM_NO,
                 OCD.C_RFA_DATE = MOCD.C_RFA_DATE,
                 OCD.C_EVENT_CODE = MOCD.C_EVENT_CODE,
                 OCD.C_TPA_STATUS = MOCD.C_TPA_STATUS,
                 OCD.C_INVOICE_DATE = MOCD.C_INVOICE_DATE,
                 OCD.C_FSR_PSR_STATUS = MOCD.C_FSR_PSR_STATUS,
                 OCD.C_PLACE_OF_LOSS = MOCD.C_PLACE_OF_LOSS,
                 OCD.C_LANDMARK = MOCD.C_LANDMARK,
                 OCD.C_AREA = MOCD.C_AREA,
                 OCD.C_STATE = MOCD.C_STATE,
                 OCD.C_CITY = MOCD.C_CITY,
                 OCD.C_PINCODE = MOCD.C_PINCODE,
                 OCD.C_JOURNEY_FROM = MOCD.C_JOURNEY_FROM,
                 OCD.C_JOURNEY_TO = MOCD.C_JOURNEY_TO,
                 OCD.C_CONSIGNEE_NAME = MOCD.C_CONSIGNEE_NAME,
                 OCD.C_CONSIGNER_NAME = MOCD.C_CONSIGNER_NAME,
                 OCD.C_SURVEY_LOCATION = MOCD.C_SURVEY_LOCATION,
                 OCD.C_GOODS_DETAILS = MOCD.C_GOODS_DETAILS,
                 OCD.C_NEXT_RVW_DATE = MOCD.C_NEXT_RVW_DATE,
                 OCD.C_LAST_RVW_REMARKS = MOCD.C_LAST_RVW_REMARKS,
                 OCD.C_LAST_RVW_DATE = MOCD.C_LAST_RVW_DATE,
                 OCD.C_FPLM_FLAG = MOCD.C_FPLM_FLAG,
                 OCD.C_REOPEN_REMARK = MOCD.C_REOPEN_REMARK,
                 OCD.C_REOPEN_BY = MOCD.C_REOPEN_BY,
                 OCD.BASE_SUM_INSURED = MOCD.BASE_SUM_INSURED,
                 OCD.ADDL_EXCESS = MOCD.ADDL_EXCESS,
                 OCD.VOLUNTARY_EXCESS = MOCD.VOLUNTARY_EXCESS,
                 OCD.COMPULSORY_EXCESS = MOCD.COMPULSORY_EXCESS,
                 OCD.EXPENSE_APP_DATE = MOCD.EXPENSE_APP_DATE,
                 OCD.LOSS_APP_DATE = MOCD.LOSS_APP_DATE,
                 OCD.NET_ASSESSED_AMOUNT = MOCD.NET_ASSESSED_AMOUNT,
                 OCD.DEPRECIATION_AMOUNT = MOCD.DEPRECIATION_AMOUNT,
                 OCD.C_PORTAL_FLAG = MOCD.C_PORTAL_FLAG,
                 ETL_REFRESH_AT = CURRENT_TIMESTAMP()
   WHEN NOT MATCHED
   THEN
      INSERT     (C_CLAIM_ID_SK,
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
                  ETL_REFRESH_AT)
          VALUES (UTILS.CLAIM_SURROGATE_KEY.NEXTVAL,
                  MOCD.C_CAUSE_OF_LOSS,
                  MOCD.C_CLAIM_NO,
                  MOCD.C_CLAIM_STATUS,
                  MOCD.C_KIND_OF_LOSS,
                  MOCD.C_ACCIDENT_LOC,
                  MOCD.C_LOSS_DATE,
                  MOCD.C_LOSS_TIME,
                  MOCD.C_INTI_DATE,
                  MOCD.C_REGN_DATE,
                  MOCD.C_APP_DATE,
                  MOCD.C_SUR_APP_DATE,
                  MOCD.C_SUR_REP_DATE,
                  MOCD.C_CHQ_ISS_DATE,
                  MOCD.C_CLO_DATE,
                  MOCD.C_SUR_NAME,
                  MOCD.C_SUR_LIC_NO,
                  MOCD.C_REP_NAME,
                  MOCD.C_BILL_DATE,
                  MOCD.C_DRI_LIC_NO,
                  MOCD.C_OFF_LOC_ID,
                  MOCD.C_PARTS_CLAIMED,
                  MOCD.C_NAME_OF_IN1,
                  MOCD.C_NAME_OF_IN2,
                  MOCD.C_NAME_OF_IN3,
                  MOCD.C_NAME_OF_IN4,
                  MOCD.C_NAME_OF_IN5,
                  MOCD.C_ADV_NAME,
                  MOCD.C_CLAIM_TYPE,
                  MOCD.C_COMMENTS,
                  MOCD.C_PAID_FLAG,
                  MOCD.C_POLICY_GRAIN,
                  MOCD.C_CLAIM_REGD_BY,
                  MOCD.C_LAST_REOPEN_DATE,
                  MOCD.C_REOPEN_FLAG,
                  MOCD.C_CONS_FORUM_FLAG,
                  MOCD.C_OMBSMAN_FLAG,
                  MOCD.C_LIGITATION_FLAG,
                  MOCD.C_RECPT_PSR_DATE,
                  MOCD.C_RECPT_FSR_DATE,
                  MOCD.C_ALL_DOC_DATE,
                  MOCD.C_COURT_FLAG,
                  MOCD.C_SPECIAL_COMMENTS,
                  MOCD.C_FIRST_REOPEN_DATE,
                  MOCD.C_MRN_TRANSPORTER_NAME,
                  MOCD.C_INVOICE_NO,
                  MOCD.C_SETTLEMNT_TYPE,
                  MOCD.C_DELAY_REASON,
                  MOCD.C_EMEDITEK_CLAIM_NO,
                  MOCD.C_RFA_DATE,
                  MOCD.C_EVENT_CODE,
                  MOCD.C_TPA_STATUS,
                  MOCD.C_INVOICE_DATE,
                  MOCD.C_FSR_PSR_STATUS,
                  MOCD.C_PLACE_OF_LOSS,
                  MOCD.C_LANDMARK,
                  MOCD.C_AREA,
                  MOCD.C_STATE,
                  MOCD.C_CITY,
                  MOCD.C_PINCODE,
                  MOCD.C_JOURNEY_FROM,
                  MOCD.C_JOURNEY_TO,
                  MOCD.C_CONSIGNEE_NAME,
                  MOCD.C_CONSIGNER_NAME,
                  MOCD.C_SURVEY_LOCATION,
                  MOCD.C_GOODS_DETAILS,
                  MOCD.C_NEXT_RVW_DATE,
                  MOCD.C_LAST_RVW_REMARKS,
                  MOCD.C_LAST_RVW_DATE,
                  MOCD.C_FPLM_FLAG,
                  MOCD.C_REOPEN_REMARK,
                  MOCD.C_REOPEN_BY,
                  MOCD.BASE_SUM_INSURED,
                  MOCD.ADDL_EXCESS,
                  MOCD.VOLUNTARY_EXCESS,
                  MOCD.COMPULSORY_EXCESS,
                  MOCD.EXPENSE_APP_DATE,
                  MOCD.LOSS_APP_DATE,
                  MOCD.NET_ASSESSED_AMOUNT,
                  MOCD.DEPRECIATION_AMOUNT,
                  MOCD.C_PORTAL_FLAG,
                  CURRENT_TIMESTAMP())'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
      SET MAXIMUS_FLAG = ''''A'''', ETL_REFRESH_AT = CURRENT_TIMESTAMP()
    WHERE C_CLAIM_NO IN (SELECT C_CLAIM_NO FROM INTERMEDIATE.STG_AGRI_ODS_CLAIM_DIM)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_AGRI_ODS_CLAIM_FACT_MV'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.STG_AGRI_ODS_CLAIM_FACT_MV
      SELECT TRY_TO_NUMBER(C.C_CLAIM_ID_SK,10,0) C_CLAIM_ID_SK,
             TRY_TO_NUMBER(D.P_POLICY_NO_SK,20,0) P_POLICY_NO_SK,
             TRY_TO_NUMBER(COMPANY_CODE,20,0) COMPANY_CODE,
             TRY_TO_NUMBER(B.T_DATE_ID_SK,10,0) T_DATE_ID_SK,
             TRY_TO_NUMBER(CC_CC_CLAIMTYPE_ID_SK,10,0) CC_CC_CLAIMTYPE_ID_SK,
             TRY_TO_NUMBER(R_RESERVE_TYPE_ID_SK,10,0) R_RESERVE_TYPE_ID,
             NVL (TRY_TO_NUMBER(PAID_CLAIM, 15, 3), 0) PAID_CLAIM,
             NVL (TRY_TO_NUMBER(RESERVE_AMOUNT, 15, 3), 0) RESERVE_AMOUNT,
             NVL (TRY_TO_NUMBER(SALVAGE_AMOUNT, 15, 3), 0) SALVAGE_AMOUNT,
             NVL (TRY_TO_NUMBER(RECOVERY_AMOUNT, 15, 3), 0) RECOVERY_AMOUNT,
             NVL (TRY_TO_NUMBER(SERVICE_TAX, 20, 0), 0) SERVICE_TAX,
             NVL (TRY_TO_NUMBER(NET_PAID, 20, 0), 0) NET_PAID,
             NVL (TRY_TO_NUMBER(NET_TAX, 20, 0), 0) NET_TAX
        FROM BAGIC_PROD_MIRROR_DB.AGRINXT.TBL_ODS_CLAIM_FACT_MV_REPORT A,
            -- PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_ODS_CLAIM_FACT_MV_REPORT A,
             PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM B,
             TRANSACTIONAL.ODS_CLAIM_DIM C,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D,
             PROD_DWH_MIGRATED_DB.PROD.ODS_RESERVE_DIM E
       WHERE
       -- B.T_DATE_DESC = TO_DATE (TO_CHAR (A.TRANS_DATE), ''''DD-MM-YYYY'''')
       B.T_DATE_DESC =
                    (SELECT CASE
                    WHEN A.TRANS_DATE LIKE ''''%-%-%'''' THEN TO_DATE (TO_CHAR (A.TRANS_DATE), ''''DD-MM-YYYY'''')
                    WHEN A.TRANS_DATE LIKE ''''%/%/%'''' THEN TO_DATE (TO_CHAR (A.TRANS_DATE), ''''DD/MM/YYYY'''')
                    ELSE NULL
                    END)
             AND C.C_CLAIM_NO = A.C_CLAIM_NO
             AND A.P_POLICY_NUMBER = D.P_POLICY_NUMBER
             AND UPPER (NVL (A.R_RESERVE_TYPE, ''''X'''')) =
                    UPPER (NVL (E.R_RESERVE_TYPE, ''''Y''''))
             AND P_CURRENT_INDICATOR = 1
             AND B.T_DATE_DESC = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_CLAIM_FACT_MV
        SELECT C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               COMPANY_CODE,
               T_DATE_ID_SK,
               1 CC_CC_CLAIMTYPE_ID_SK,
               R_RESERVE_TYPE_ID,
               SUM (PAID_CLAIM) PAID_CLAIM,
               SUM (RESERVE_AMOUNT) RESERVE_AMOUNT,
               SUM (SALVAGE_AMOUNT) SALVAGE_AMOUNT,
               SUM (RECOVERY_AMOUNT) RECOVERY_AMOUNT,
               SUM (SERVICE_TAX) SERVICE_TAX,
               SUM (NET_PAID) NET_PAID,
               SUM (NET_TAX) NET_TAX,
               ''''A'''' MAXIMUS_FLAG,
               NULL as INC_JOB_CREATED_AT,
               NULL as INC_JOB_CREATED_BY,
               NULL as INC_JOB_UPDATED_BY,
               NULL as INC_JOB_UPDATED_AT,
               NULL as INC_JOB_ID,
               NULL as RECOVERY_INITIATED,
               NULL as RECOVERY_DONE,
               NULL as RECOVERY_PENDING
          FROM INTERMEDIATE.STG_AGRI_ODS_CLAIM_FACT_MV
      GROUP BY C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               COMPANY_CODE,
               T_DATE_ID_SK,
               CC_CC_CLAIMTYPE_ID_SK,
               R_RESERVE_TYPE_ID'';
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