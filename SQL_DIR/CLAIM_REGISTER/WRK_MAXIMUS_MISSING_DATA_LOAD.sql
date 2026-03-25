CREATE OR REPLACE PROCEDURE INTERMEDIATE.WRK_MAXIMUS_MISSING_DATA_LOAD("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
V_CNT number;
v_sqltext VARCHAR;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_BANCA_PS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT
         INTO  INTERMEDIATE.WRK_BANCA_PS
      SELECT C.C_CLAIM_ID_SK,
             D.P_POLICY_NO_SK,
             COMPANY_CODE,
             B.T_DATE_ID_SK,
             T_DATE_DESC,
             CC_CC_CLAIMTYPE_ID_SK,
             R_RESERVE_TYPE_ID_SK R_RESERVE_TYPE_ID,
             PAID_CLAIM,
             RESERVE_AMOUNT,
             SALVAGE_AMOUNT,
             RECOVERY_AMOUNT,
             SERVICE_TAX,
             NET_PAID,
             NET_TAX
        FROM
             -- PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_ODS_CLAIM_FACT_MV A,
             TRANSACTIONAL.ODI_ODS_CLAIM_FACT_MV A,
             PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM B,
             TRANSACTIONAL.ODS_CLAIM_DIM C,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D,
             TRANSACTIONAL.ODS_RESERVE_DIM E
       WHERE     B.T_DATE_DESC = A.TRANS_DATE
             AND C.C_CLAIM_NO = A.C_CLAIM_NO
             AND A.P_POLICY_NUMBER = D.P_POLICY_NUMBER
             AND UPPER (NVL (A.R_RESERVE_TYPE, ''''X'''')) =
                    UPPER (NVL (E.R_RESERVE_TYPE, ''''Y''''))
             AND P_CURRENT_INDICATOR = 1
             AND TRANS_DATE  BETWEEN  DATE_TRUNC(''''MONTH'''', TO_DATE(''''''|| F_DATE|| ''''''))
	      AND DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - 1'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_BANCA_CC'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT
         INTO  INTERMEDIATE.WRK_BANCA_CC
        SELECT C_CLAIM_NO,
               A.C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               COMPANY_CODE,
               T_DATE_ID_SK,
               T_DATE_DESC,
               CC_CC_CLAIMTYPE_ID_SK,
               R_RESERVE_TYPE_ID,
               SUM (PAID_CLAIM) PAID_CLAIM,
               SUM (RESERVE_AMOUNT) RESERVE_AMOUNT,
               SUM (SALVAGE_AMOUNT) SALVAGE_AMOUNT,
               SUM (RECOVERY_AMOUNT) RECOVERY_AMOUNT,
               SUM (SERVICE_TAX) SERVICE_TAX,
               SUM (NET_PAID) NET_PAID,
               SUM (NET_TAX) NET_TAX
          FROM INTERMEDIATE.WRK_BANCA_PS A, TRANSACTIONAL.ODS_CLAIM_DIM B
         WHERE A.C_CLAIM_ID_SK = B.C_CLAIM_ID_SK
      GROUP BY C_CLAIM_NO,
               A.C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               COMPANY_CODE,
               T_DATE_ID_SK,
               T_DATE_DESC,
               CC_CC_CLAIMTYPE_ID_SK,
               R_RESERVE_TYPE_ID
      MINUS
        SELECT C_CLAIM_NO,
               A.C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               COMPANY_CODE,
               A.T_DATE_ID_SK,
               T_DATE_DESC,
               CC_CC_CLAIMTYPE_ID_SK,
               R_RESERVE_TYPE_ID,
               SUM (PAID_CLAIM) PAID_CLAIM,
               SUM (RESERVE_AMOUNT) RESERVE_AMOUNT,
               SUM (SALVAGE_AMOUNT) SALVAGE_AMOUNT,
               SUM (RECOVERY_AMOUNT) RECOVERY_AMOUNT,
               SUM (SERVICE_TAX) SERVICE_TAX,
               SUM (NET_PAID) NET_PAID,
               SUM (NET_TAX) NET_TAX
          FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV A, TRANSACTIONAL.ODS_CLAIM_DIM B, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM C
         WHERE     A.C_CLAIM_ID_SK = B.C_CLAIM_ID_SK
               AND EXISTS
                      (SELECT 1
                         FROM INTERMEDIATE.WRK_BANCA_PS AA
                        WHERE AA.C_CLAIM_ID_SK = B.C_CLAIM_ID_SK)
               AND A.T_DATE_ID_SK = C.T_DATE_ID_SK
      GROUP BY C_CLAIM_NO,
               A.C_CLAIM_ID_SK,
               P_POLICY_NO_SK,
               COMPANY_CODE,
               A.T_DATE_ID_SK,
               T_DATE_DESC,
               CC_CC_CLAIMTYPE_ID_SK,
               R_RESERVE_TYPE_ID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_BANCA_CC_F'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT
         INTO  INTERMEDIATE.WRK_BANCA_CC_F
      SELECT *
        FROM INTERMEDIATE.WRK_BANCA_CC
       WHERE T_DATE_DESC BETWEEN  DATE_TRUNC(''''MONTH'''', TO_DATE(''''''|| F_DATE|| ''''''))  AND DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - 1'';
EXECUTE IMMEDIATE v_sqltext;


SELECT COUNT (*) INTO :V_CNT FROM INTERMEDIATE.WRK_BANCA_CC_F;

IF (V_CNT > 0)
THEN
   v_sqltext:= ''MERGE
           INTO  TRANSACTIONAL.ODS_CLAIM_FACT_MV X
           USING (SELECT C_CLAIM_ID_SK,
                         P_POLICY_NO_SK,
                         COMPANY_CODE,
                         T_DATE_ID_SK,
                         CC_CC_CLAIMTYPE_ID_SK,
                         R_RESERVE_TYPE_ID,
                         NVL (PAID_CLAIM, 0) + NVL (SERVICE_TAX, 0)
                            PAID_CLAIM,
                         RESERVE_AMOUNT,
                         SALVAGE_AMOUNT,
                         RECOVERY_AMOUNT,
                         SERVICE_TAX,
                         NET_PAID,
                         NET_TAX,
                         ''''Y'''' MAXIMUS_FLAG,
						 NULL AS RECOVERY_INITIATED ,
						 NULL AS RECOVERY_DONE,
						 NULL AS RECOVERY_PENDING,
                            null as INC_JOB_CREATED_AT,
                            null as INC_JOB_CREATED_BY,
                            null as INC_JOB_UPDATED_BY,
                            null as INC_JOB_UPDATED_AT,
                            null as INC_JOB_ID
                    FROM INTERMEDIATE.WRK_BANCA_CC_F) Y
              ON (    X.C_CLAIM_ID_SK = Y.C_CLAIM_ID_SK
                  AND X.P_POLICY_NO_SK = Y.P_POLICY_NO_SK
                  AND X.COMPANY_CODE = Y.COMPANY_CODE
                  AND X.T_DATE_ID_SK = Y.T_DATE_ID_SK
                  AND X.CC_CC_CLAIMTYPE_ID_SK = Y.CC_CC_CLAIMTYPE_ID_SK
                  AND X.R_RESERVE_TYPE_ID = Y.R_RESERVE_TYPE_ID)
      WHEN MATCHED
      THEN
         UPDATE SET X.PAID_CLAIM = Y.PAID_CLAIM,
                    X.RESERVE_AMOUNT = Y.RESERVE_AMOUNT,
                    X.SALVAGE_AMOUNT = Y.SALVAGE_AMOUNT,
                    X.RECOVERY_AMOUNT = Y.RECOVERY_AMOUNT,
                    X.SERVICE_TAX = Y.SERVICE_TAX,
                    X.NET_PAID = Y.NET_PAID,
                    X.NET_TAX = Y.NET_TAX,
                    X.MAXIMUS_FLAG = Y.MAXIMUS_FLAG
      WHEN NOT MATCHED
      THEN
         INSERT     VALUES (Y.C_CLAIM_ID_SK,
                            Y.P_POLICY_NO_SK,
                            Y.COMPANY_CODE,
                            Y.T_DATE_ID_SK,
                            Y.CC_CC_CLAIMTYPE_ID_SK,
                            Y.R_RESERVE_TYPE_ID,
                            Y.PAID_CLAIM,
                            Y.RESERVE_AMOUNT,
                            Y.SALVAGE_AMOUNT,
                            Y.RECOVERY_AMOUNT,
                            Y.SERVICE_TAX,
                            Y.NET_PAID,
                            Y.NET_TAX,
                            Y.MAXIMUS_FLAG,
							Y.RECOVERY_INITIATED ,
						    Y.RECOVERY_DONE,
						    Y.RECOVERY_PENDING,
                            Y.INC_JOB_CREATED_AT,
                            Y.INC_JOB_CREATED_BY,
                            Y.INC_JOB_UPDATED_BY,
                            Y.INC_JOB_UPDATED_AT,
                            Y.INC_JOB_ID)'';
   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext :=  ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_ODS_CLAIM_DIM'';

   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_ODS_CLAIM_DIM
         SELECT
             C_CLAIM_ID_SK
            ,C_CAUSE_OF_LOSS
            ,C_CLAIM_NO
            ,C_CLAIM_STATUS
            ,C_KIND_OF_LOSS
            ,C_ACCIDENT_LOC
            ,C_LOSS_DATE
            ,C_LOSS_TIME
            ,C_INTI_DATE
            ,C_REGN_DATE
            ,C_APP_DATE
            ,C_SUR_APP_DATE
            ,C_SUR_REP_DATE
            ,C_CHQ_ISS_DATE
            ,C_CLO_DATE
            ,C_SUR_NAME
            ,C_SUR_LIC_NO
            ,C_REP_NAME
            ,C_BILL_DATE
            ,C_DRI_LIC_NO
            ,C_OFF_LOC_ID
            ,C_PARTS_CLAIMED
            ,C_NAME_OF_IN1
            ,C_NAME_OF_IN2
            ,C_NAME_OF_IN3
            ,C_NAME_OF_IN4
            ,C_NAME_OF_IN5
            ,C_ADV_NAME
            ,C_CLAIM_TYPE
            ,C_COMMENTS
            ,C_PAID_FLAG
            ,C_POLICY_GRAIN
            ,C_CLAIM_REGD_BY
            ,C_LAST_REOPEN_DATE
            ,C_REOPEN_FLAG
            ,C_CONS_FORUM_FLAG
            ,C_OMBSMAN_FLAG
            ,C_LIGITATION_FLAG
            ,C_RECPT_PSR_DATE
            ,C_RECPT_FSR_DATE
            ,C_ALL_DOC_DATE
            ,C_COURT_FLAG
            ,C_SPECIAL_COMMENTS
            ,C_FIRST_REOPEN_DATE
            ,C_MRN_TRANSPORTER_NAME
            ,C_INVOICE_NO
            ,C_SETTLEMNT_TYPE
            ,C_DELAY_REASON
            ,C_EMEDITEK_CLAIM_NO
            ,C_RFA_DATE
            ,C_EVENT_CODE
            ,C_TPA_STATUS
            ,C_INVOICE_DATE
            ,C_FSR_PSR_STATUS
            ,C_PLACE_OF_LOSS
            ,C_LANDMARK
            ,C_AREA
            ,C_STATE
            ,C_CITY
            ,C_PINCODE
            ,C_JOURNEY_FROM
            ,C_JOURNEY_TO
            ,C_CONSIGNEE_NAME
            ,C_CONSIGNER_NAME
            ,C_SURVEY_LOCATION
            ,C_GOODS_DETAILS
            ,C_NEXT_RVW_DATE
            ,C_LAST_RVW_REMARKS
            ,C_LAST_RVW_DATE
            ,C_FPLM_FLAG
            ,C_CLAIM_ID
            ,C_REOPEN_REMARK
            ,C_REOPEN_BY
            ,BASE_SUM_INSURED
            ,ADDL_EXCESS
            ,VOLUNTARY_EXCESS
            ,COMPULSORY_EXCESS
            ,EXPENSE_APP_DATE
            ,LOSS_APP_DATE
            ,NET_ASSESSED_AMOUNT
            ,DEPRECIATION_AMOUNT
            ,C_PORTAL_FLAG
            ,C_MLT_YEAR
            ,MAXIMUS_FLAG
            ,null as INC_JOB_CREATED_AT
            ,null as INC_JOB_CREATED_BY
            ,null as INC_JOB_UPDATED_BY
            ,null as INC_JOB_UPDATED_AT
            ,null as INC_JOB_ID
            ,C_OD_TYPE_OF_LOSS
	        ,C_HHID VARCHAR
	        ,C_NET_TAX_LABOUR
	        ,C_NET_TAX_PARTS
           FROM TRANSACTIONAL.ODS_CLAIM_DIM
          WHERE C_CLAIM_NO IN
                   (SELECT DISTINCT C_CLAIM_NO FROM INTERMEDIATE.WRK_BANCA_CC_F)'';
   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MV_CLAIM_DATA'';
   EXECUTE IMMEDIATE v_sqltext;

   -- v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CLAIM_DATA
   --         SELECT ODS_CLAIM_DIM.C_CLAIM_NO,
   --                ODS_CLAIM_DIM.C_CLAIM_ID_SK,
   --                C_ACCIDENT_LOC,
   --                C_LOSS_TIME,
   --                DECODE (ODS_CLAIM_DIM.C_CLAIM_STATUS,
   --                        ''''CLOSED'''', ''''CLOSED'''',
   --                        ''''OPEN'''')
   --                   CLM_STATUS,
   --                DECODE (
   --                   DENSE_RANK ()
   --                   OVER (PARTITION BY C_CLAIM_NO
   --                         ORDER BY CP_COMPANY_ID_SK, ROWNUM DESC NULLS LAST),
   --                   1, ''''Y'''',
   --                   ''''N'''')
   --                   TOP_INDICATOR,
   --                DECODE (ODS_CLAIM_DIM.C_OFF_LOC_ID,
   --                        0, ODS_POLICY_DIM.P_OFFICE_LOC_ID,
   --                        ODS_CLAIM_DIM.C_OFF_LOC_ID)
   --                   C_OFF_LOC_ID,
   --                ODS_POLICY_DIM.P_POLICY_NUMBER,
   --                ODS_POLICY_DIM.P_OFFICE_LOC_ID POLICY_LOCATION_ID,
   --                ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                ODS_POLICY_DIM.P_RISK_INC_DATE,
   --                ODS_POLICY_DIM.P_RISK_EXPIRY_DATE,
   --                ODS_IMD_DIM.I_IMD_DESC,
   --                ODS_POLICY_DIM.P_SUB_IMD,
   --                DECODE (
   --                   I_IMD_DESC,
   --                   ''''DIRECT'''', NVL (
   --                                DECODE (P_SUBIMD_CHANNEL,
   --                                        ''''DIRECT'''', NULL,
   --                                        P_SUBIMD_CHANNEL),
   --                                I_IMD_NEW_CHANNEL),
   --                   I_IMD_NEW_CHANNEL)
   --                   IMD_CHANNEL,
   --                DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                        6609, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
   --                        6610, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
   --                        ODS_MAKE_DIM.V_VEHICLE_MAKE)
   --                   V_VEHICLE_MAKE,
   --                ODS_POLICY_DIM.P_YEAR_OF_MANU,
   --                DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                        6609, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
   --                        6610, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
   --                        ODS_MODEL_DIM.M_VEHICLE_MODEL)
   --                   M_VEHICLE_MODEL,
   --                ODS_POLICY_DIM.P_REGN_NO,
   --                PT_PARTNER_ID,
   --                PARTNER_DIM_POLICY.PT_PARTNER_DESC,
   --                PARTNER_DIM_POLICY.PT_PARTNER_CITY,
   --                ODS_CLAIM_DIM.C_COMMENTS,
   --                ODS_CLAIM_DIM.C_CLAIM_TYPE,
   --                ODS_CLAIM_DIM.C_CAUSE_OF_LOSS,
   --                ODS_CLAIM_DIM.C_REP_NAME,
   --                ODS_CLAIM_DIM.C_NAME_OF_IN1,
   --                ODS_CLAIM_DIM.C_REGN_DATE,
   --                ODS_CLAIM_DIM.C_CLO_DATE,
   --                ODS_CLAIM_DIM.C_LOSS_DATE,
   --                ODS_CLAIM_DIM.C_INTI_DATE,
   --                ODS_CLAIM_DIM.C_SUR_NAME,
   --                ODS_CLAIM_DIM.C_APP_DATE,
   --                C_POLICY_GRAIN,
   --                C_CLAIM_REGD_BY,
   --                C_LAST_REOPEN_DATE,
   --                C_PAID_FLAG,
   --                C_CONS_FORUM_FLAG CONSUMER_FORUM_FLAG,
   --                C_OMBSMAN_FLAG,
   --                C_LIGITATION_FLAG,
   --                P_DEPARTMENT_DESC,
   --                DECODE (ODS_CLAIM_DIM.C_REOPEN_FLAG, 1, ''''Y'''', ''''N'''') REOPEN_FLAG,
   --                CASE
   --                   WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 1 THEN ''''RENEWAL''''
   --                   WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 2 THEN ''''ROllOVER''''
   --                   ELSE ''''NEW BUSINESS''''
   --                END
   --                   REN_ROLL_NB_FLAG,
   --                CASE
   --                   WHEN     ODS_PRODUCT_DIM.P_PRODUCT_ID IN
   --                               (1803,
   --                                1807,
   --                                1810,
   --                                1811,
   --                                1812,
   --                                1852,
   --                                1853,
   --                                1854,
   --                                5001)
   --                        AND ODS_CLAIM_DIM.C_CLAIM_TYPE = ''''TP''''
   --                        AND ODS_POLICY_DIM.P_RISK_INC_DATE BETWEEN ''''01-apr-2007''''
   --                                                               AND ''''31-mar-2012''''
   --                        AND ODS_POLICY_DIM.P_POLICY_ISSUE_DATE >=
   --                               ''''01-apr-2007''''
   --                        AND B.P_POLICY_NUMBER IS NOT NULL
   --                   THEN
   --                      ''''Y''''
   --                   ELSE
   --                      ''''N''''
   --                END
   --                   TP_POOL_FLAG,
   --                  SUM (ODS_CLAIM_FACT_MV.PAID_CLAIM)
   --                - SUM (
   --                     CASE
   --                        WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-OCT-2009''''
   --                        THEN
   --                           NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)
   --                        ELSE
   --                           0
   --                     END)
   --                   POOL_PAID_FLAG,
   --                ODS_POLICY_DIM.P_MASTER_POLICY_NO,
   --                ODS_POLICY_DIM.P_REN_INDICATOR,
   --                ODS_CLAIM_DIM.C_COURT_FLAG,
   --                ODS_CLAIM_DIM.C_SUR_REP_DATE,
   --                ODS_POLICY_DIM.P_POLICY_ISSUE_DATE,
   --                ODS_POLICY_DIM.P_COINSURANCE_TYPE,
   --                ODS_TIME_DIM.T_DATE_DESC,
   --                CP_COMPANY_NAME,
   --                ODS_RESERVE_DIM.R_RESERVE_GROUP_DESC,
   --                R_RESERVE_DESC,
   --                P_GEOGRAPHIC_SCOPE,
   --                P_GC_PLAN,
   --                P_ENGINE_NUMBER,
   --                P_CHASSIS_NUMBER,
   --                C_SETTLEMNT_TYPE,
   --                C_ALL_DOC_DATE,
   --                C_SPECIAL_COMMENTS,
   --                C_MRN_TRANSPORTER_NAME,
   --                C_INVOICE_NO,
   --                RUNNER_NAME,
   --                RUNNER_CODE,
   --                BRANCH_RESP,
   --                CSE_CODE,
   --                PT_INIT_CLUSTER_ID PT_HOUSE_HOLD_ID,
   --                PT_CLUSTER_ID,
   --                CASE_YEAR,
   --                HO_ID,
   --                NEXT_COURT_H_DATE,
   --                CASE_TITLE,
   --                CASE_PREFIX,
   --                COURT_STAGE,
   --                TP_COMPRO_DEFENSE,
   --                STATUS_OF_INVESTIGATION_REPORT,
   --                DECISION_ON_AWARD,
   --                DETAILS_OF_FOLLOWUP,
   --                INVESTIGATION_APPOINTMENTDATE,
   --                TP_COURT_REMARKS,
   --                INVEST_REPORT_RECEIVINGDATE,
   --                ODS_CLAIM_DIM.C_ADV_NAME,
   --                P_NCB_PERCENT,
   --                P_NCB_AMOUNT,
   --                ODS_POLICY_DIM.P_COVER_NOTE_NO,
   --                ODS_POLICY_DIM.P_POLICY_STATUS,
   --                C_RECPT_PSR_DATE,
   --                C_RECPT_FSR_DATE,
   --                C_SUR_APP_DATE,
   --                C_DELAY_REASON,
   --                C_EMEDITEK_CLAIM_NO,
   --                REMARKS_OFLEGAL_OFFICER,
   --                PT_PARTNER_TYPE,
   --                C_RFA_DATE,
   --                C_EVENT_CODE,
   --                C_TPA_STATUS,
   --                PT_PARTNER_REGION,
   --                PT_PARTNER_REGION_STND,
   --                C_INVOICE_DATE,
   --                C_FSR_PSR_STATUS,
   --                P_FUEL_TYPE,
   --                P_POLICY_AGE POLICY_AGE,
   --                P_VEHICLE_REG_DATE VEHICLE_REG_DATE,
   --                COMPROMISE TP_COMPROMISE,
   --                PT_PARTNER_PIN_CODE PARTNER_PIN_CODE,
   --                PT_PARTNER_CITY PARTNER_CITY,
   --                P_OLD_POLICY_NO OLD_POLICY_NO,
   --                SUM (NVL (ODS_CLAIM_FACT_MV.PAID_CLAIM, 0)) PAID_CLAIM,
   --                SUM (NVL (ODS_CLAIM_FACT_MV.RESERVE_AMOUNT, 0))
   --                   RESERVE_AMOUNT,
   --                  SUM (NVL (ODS_CLAIM_FACT_MV.RESERVE_AMOUNT, 0))
   --                - SUM (NVL (ODS_CLAIM_FACT_MV.PAID_CLAIM, 0))
   --                   OS_AMT,
   --                SUM (NVL (ODS_CLAIM_FACT_MV.SALVAGE_AMOUNT, 0)) SALVAGE_AMT,
   --                SUM (NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)) SERVICE_TAX,
   --                SUM (
   --                   CASE
   --                      WHEN ODS_TIME_DIM.T_DATE_DESC < ''''01-Apr-2011'''' THEN 0
   --                      ELSE (NVL (ODS_CLAIM_FACT_MV.SALVAGE_AMOUNT, 0))
   --                   END)
   --                   POOL_SALVAGE_AMT,
   --                (  SUM (ODS_CLAIM_FACT_MV.PAID_CLAIM)
   --                 - SUM (
   --                      CASE
   --                         WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-OCT-2009''''
   --                         THEN
   --                            NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)
   --                         ELSE
   --                            0
   --                      END))
   --                   POOL_PAID_BEFORE_SALVAGE,
   --                (  SUM (ODS_CLAIM_FACT_MV.PAID_CLAIM)
   --                 - SUM (
   --                      CASE
   --                         WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-OCT-2009''''
   --                         THEN
   --                            NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)
   --                         ELSE
   --                            0
   --                      END)
   --                 + SUM (
   --                      CASE
   --                         WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-Apr-2011''''
   --                         THEN
   --                            NVL (ODS_CLAIM_FACT_MV.SALVAGE_AMOUNT, 0)
   --                         ELSE
   --                            0
   --                      END))
   --                   POOL_PAID_AFTER_SALVAGE,
   --                SUM (NVL (ODS_CLAIM_FACT_MV.NET_PAID, 0)) NET_PAID,
   --                SUM (NVL (ODS_CLAIM_FACT_MV.NET_TAX, 0)) NET_TAX,
   --                C_PLACE_OF_LOSS,
   --                C_LANDMARK,
   --                C_AREA,
   --                C_STATE,
   --                C_CITY,
   --                C_PINCODE,
   --                C_JOURNEY_FROM,
   --                C_JOURNEY_TO,
   --                C_CONSIGNEE_NAME,
   --                C_CONSIGNER_NAME,
   --                C_SURVEY_LOCATION,
   --                C_GOODS_DETAILS,
   --                P_COVERNOTE_DATE,
   --                DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                        6609, EXTN.ASSET_CATEGORY,
   --                        6610, EXTN.ASSET_CATEGORY,
   --                        V_VEHICLE_TYPE)
   --                   V_VEHICLE_TYPE,
   --                I_IMD_NAME,
   --                C_NEXT_RVW_DATE,
   --                C_LAST_RVW_REMARKS,
   --                ODS_POLICY_DIM.P_OPUS_UPLOAD_DATE P_OLD_POL_EXP_DATE,
   --                PARTNER_DIM_POLICY.PT_PARTNER_TELEPHONE,
   --                TP_CASE_RESP_PERSON,
   --                TP_CASE_CLAIM_LOCATION,
   --                PARTNER_DIM_POLICY.PT_PARTNER_ADDRESS,
   --                C_FPLM_FLAG,
   --                C_CLAIM_ID,
   --                C_REOPEN_REMARK,
   --                C_REOPEN_BY,
   --                BASE_SUM_INSURED,
   --                GLOBAL_FLAG,
   --                ODS_POLICY_DIM.P_EMP_CODE,
   --                ODS_CLAIM_DIM.ADDL_EXCESS,
   --                ODS_CLAIM_DIM.VOLUNTARY_EXCESS,
   --                ODS_CLAIM_DIM.COMPULSORY_EXCESS,
   --                ODS_CLAIM_DIM.EXPENSE_APP_DATE,
   --                ODS_CLAIM_DIM.LOSS_APP_DATE,
   --                ODS_CLAIM_DIM.NET_ASSESSED_AMOUNT,
   --                ODS_CLAIM_DIM.DEPRECIATION_AMOUNT,
   --                P_SUB_CHANNEL_CODE,
   --                ODS_POLICY_DIM.P_FIRE_LOC_NAME,
   --                ODS_POLICY_DIM.P_FIRE_LOC_TYPE,
   --                ODS_POLICY_DIM.P_FIRE_OCCUPANCY,
   --                ODS_POLICY_DIM.P_FIRE_RISK_TYPE,
   --                ODS_POLICY_DIM.P_VEHICLE_GVW,
   --                ODS_MODEL_DIM.M_VEHICLE_SEGMENT,
   --                ODS_CLAIM_DIM.C_PORTAL_FLAG,
   --                C_MLT_YEAR,
   --                ODS_CLAIM_FACT_MV.MAXIMUS_FLAG,
   --                PARTNER_DIM_POLICY.PT_MAXI_PID,
   --                CESSION_PERC,
   --                CASE
   --                   WHEN CESSION_PERC IS NOT NULL THEN 100 - CESSION_PERC
   --                   ELSE NULL
   --                END
   --                   RI_RETENTION_PERCENTAGE,
   --                   PARTNER_DIM_POLICY.PT_PARTNER_PRIVE_FLAG
   --           FROM INTERMEDIATE.WRK_ODS_CLAIM_DIM ODS_CLAIM_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_PARTNER_DIM PARTNER_DIM_POLICY,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_IMD_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_MAKE_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_MODEL_DIM,
   --                TRANSACTIONAL.ODS_RESERVE_DIM,
   --                TRANSACTIONAL.ODS_CLAIM_FACT_MV,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_LOCATION_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_COMPANY_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_DM_DATA A,
   --                PROD_DWH_MIGRATED_DB.PROD.RECO_TBL_27_AUG_09_MV B,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_TP_CLM_DTLS TP,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_VEHICLE_TYPE_DIM,
   --                PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM_EXTN EXTN,
   --                PROD_DWH_MIGRATED_DB.PROD.WRK_RI_SHARE RI_SHARE
   --          WHERE     ODS_POLICY_DIM.P_POLICY_NUMBER = B.P_POLICY_NUMBER(+)
   --                AND (ODS_POLICY_DIM.P_POLICY_NO_SK =
   --                        ODS_CLAIM_FACT_MV.P_POLICY_NO_SK)
   --                AND (ODS_CLAIM_FACT_MV.T_DATE_ID_SK =
   --                        ODS_TIME_DIM.T_DATE_ID_SK)
   --                AND (COMPANY_CODE = CP_COMPANY_ID_SK)
   --                AND (ODS_CLAIM_FACT_MV.R_RESERVE_TYPE_ID =
   --                        ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK)
   --                AND (ODS_POLICY_DIM.P_IMD_ID_SK = ODS_IMD_DIM.I_IMD_ID_SK(+))
   --                AND (ODS_POLICY_DIM.P_PRODUCT_ID =
   --                        ODS_PRODUCT_DIM.P_PRODUCT_ID)
   --                AND (    ODS_MAKE_DIM.V_VEHICLE_MAKE_CODE(+) =
   --                            ODS_POLICY_DIM.P_VEHICLE_MAKE
   --                     AND ODS_MAKE_DIM.V_VEHICLE_TYPE_CODE(+) =
   --                            ODS_POLICY_DIM.P_VEHICLE_TYPE)
   --                AND (PARTNER_DIM_POLICY.PT_PARTNER_ID_SK =
   --                        ODS_POLICY_DIM.P_PARTNER_ID_SK)
   --                AND (    ODS_MODEL_DIM.M_VEHICLE_MAKE_CODE(+) =
   --                            ODS_POLICY_DIM.P_VEHICLE_MAKE
   --                     AND ODS_MODEL_DIM.M_VEHICLE_MODEL_CODE(+) =
   --                            ODS_POLICY_DIM.P_VEHICLE_MODEL
   --                     AND ODS_MODEL_DIM.M_VEHICLE_SUBTYPE_CODE(+) =
   --                            ODS_POLICY_DIM.P_VEHICLE_SUB_TYPE
   --                     AND ODS_MODEL_DIM.M_VEHICLE_TYPE_CODE(+) =
   --                            ODS_POLICY_DIM.P_VEHICLE_TYPE)
   --                AND (ODS_CLAIM_FACT_MV.C_CLAIM_ID_SK =
   --                        ODS_CLAIM_DIM.C_CLAIM_ID_SK)
   --                AND (ODS_CLAIM_DIM.C_OFF_LOC_ID =
   --                        ODS_LOCATION_DIM.OFFICE_LOCATION_ID(+))
   --                AND ODS_POLICY_DIM.P_POLICY_NUMBER = A.POLICY_REF(+)
   --                AND ODS_POLICY_DIM.P_POLICY_NUMBER = RI_SHARE.POLICY_REF(+)
   --                AND POLICY_YEAR(+) = 1
   --                AND C_CLAIM_NO = TP.CLAIM_NO(+)
   --                AND C_CLAIM_NO IN (SELECT C_CLAIM_NO FROM WRK_ODS_CLAIM_DIM)
   --                AND ODS_TIME_DIM.T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| F_DATE|| '''''')) - 2
   --                                                 AND DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - 1
   --                AND ODS_MAKE_DIM.V_VEHICLE_TYPE_CODE =
   --                       ODS_VEHICLE_TYPE_DIM.V_VEHICLE_TYPE_CODE(+)
   --                AND ODS_POLICY_DIM.P_POLICY_NUMBER = EXTN.POLICY_REF(+)
   --       GROUP BY ODS_CLAIM_DIM.C_OFF_LOC_ID,
   --                ODS_CLAIM_DIM.C_CLAIM_NO,
   --                DECODE (ODS_CLAIM_DIM.C_CLAIM_STATUS,
   --                        ''''CLOSED'''', ''''CLOSED'''',
   --                        ''''OPEN''''),
   --                C_CONS_FORUM_FLAG,
   --                C_OMBSMAN_FLAG,
   --                C_LIGITATION_FLAG,
   --                CP_COMPANY_NAME,
   --                ODS_CLAIM_DIM.C_COMMENTS,
   --                ODS_CLAIM_DIM.C_CLAIM_TYPE,
   --                ODS_CLAIM_DIM.C_CAUSE_OF_LOSS,
   --                ODS_POLICY_DIM.P_POLICY_NUMBER,
   --                ODS_POLICY_DIM.P_OFFICE_LOC_ID,
   --                ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                PT_PARTNER_ID,
   --                PARTNER_DIM_POLICY.PT_PARTNER_DESC,
   --                PARTNER_DIM_POLICY.PT_PARTNER_CITY,
   --                ODS_POLICY_DIM.P_RISK_INC_DATE,
   --                ODS_POLICY_DIM.P_RISK_EXPIRY_DATE,
   --                ODS_IMD_DIM.I_IMD_DESC,
   --                ODS_POLICY_DIM.P_SUB_IMD,
   --                DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                        6609, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
   --                        6610, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
   --                        ODS_MAKE_DIM.V_VEHICLE_MAKE),
   --                ODS_POLICY_DIM.P_YEAR_OF_MANU,
   --                DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                        6609, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
   --                        6610, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
   --                        ODS_MODEL_DIM.M_VEHICLE_MODEL),
   --                ODS_POLICY_DIM.P_REGN_NO,
   --                ODS_CLAIM_DIM.C_REGN_DATE,
   --                ODS_CLAIM_DIM.C_REP_NAME,
   --                ODS_CLAIM_DIM.C_NAME_OF_IN1,
   --                C_POLICY_GRAIN,
   --                C_CLAIM_REGD_BY,
   --                C_LAST_REOPEN_DATE,
   --                C_PAID_FLAG,
   --                ODS_CLAIM_DIM.C_CLO_DATE,
   --                ODS_CLAIM_DIM.C_LOSS_DATE,
   --                ODS_CLAIM_DIM.C_INTI_DATE,
   --                ODS_CLAIM_DIM.C_SUR_NAME,
   --                ODS_RESERVE_DIM.R_RESERVE_GROUP_DESC,
   --                CP_COMPANY_ID_SK,
   --                ROWNUM,
   --                ODS_CLAIM_DIM.C_APP_DATE,
   --                ODS_TIME_DIM.T_DATE_DESC,
   --                DECODE (
   --                   I_IMD_DESC,
   --                   ''''DIRECT'''', NVL (
   --                                DECODE (P_SUBIMD_CHANNEL,
   --                                        ''''DIRECT'''', NULL,
   --                                        P_SUBIMD_CHANNEL),
   --                                I_IMD_NEW_CHANNEL),
   --                   I_IMD_NEW_CHANNEL), ----changes done by chandrakant(As instructed by vishal patil and priyank sir)
   --                CASE
   --                   WHEN     ODS_PRODUCT_DIM.P_PRODUCT_ID IN
   --                               (1803,
   --                                1807,
   --                                1810,
   --                                1811,
   --                                1812,
   --                                1852,
   --                                1853,
   --                                1854,
   --                                5001)
   --                        AND ODS_CLAIM_DIM.C_CLAIM_TYPE = ''''TP''''
   --                        AND ODS_POLICY_DIM.P_RISK_INC_DATE BETWEEN ''''01-apr-2007''''
   --                                                               AND ''''31-mar-2012''''
   --                        AND ODS_POLICY_DIM.P_POLICY_ISSUE_DATE >=
   --                               ''''01-apr-2007''''
   --                        AND B.P_POLICY_NUMBER IS NOT NULL
   --                   ---- and  NVL(ods_motor_od_tp_prem_new.tp_prem,0) <> 0
   --                   THEN
   --                      ''''Y''''
   --                   ELSE
   --                      ''''N''''
   --                END,
   --                DECODE (ODS_CLAIM_DIM.C_REOPEN_FLAG, 1, ''''Y'''', ''''N''''),
   --                ODS_POLICY_DIM.P_MASTER_POLICY_NO,
   --                ODS_POLICY_DIM.P_REN_INDICATOR,
   --                ODS_CLAIM_DIM.C_COURT_FLAG,
   --                ODS_CLAIM_DIM.C_SUR_REP_DATE,
   --                ODS_POLICY_DIM.P_POLICY_ISSUE_DATE,
   --                ODS_POLICY_DIM.P_COINSURANCE_TYPE,
   --                R_RESERVE_DESC,
   --                P_GEOGRAPHIC_SCOPE,
   --                P_GC_PLAN,
   --                P_ENGINE_NUMBER,
   --                P_CHASSIS_NUMBER,
   --                C_SETTLEMNT_TYPE,
   --                P_DEPARTMENT_DESC,
   --                ODS_CLAIM_DIM.C_CLAIM_ID_SK,
   --                C_ACCIDENT_LOC,
   --                C_LOSS_TIME,
   --                CASE
   --                   WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 1 THEN ''''RENEWAL''''
   --                   WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 2 THEN ''''ROllOVER''''
   --                   ELSE ''''NEW BUSINESS''''
   --                END,
   --                C_ALL_DOC_DATE,
   --                C_SPECIAL_COMMENTS,
   --                C_MRN_TRANSPORTER_NAME,
   --                C_INVOICE_NO,
   --                P_GC_PLAN,
   --                RUNNER_NAME,
   --                RUNNER_CODE,
   --                BRANCH_RESP,
   --                CSE_CODE,
   --                PT_INIT_CLUSTER_ID,
   --                PT_CLUSTER_ID,
   --                CASE_YEAR,
   --                HO_ID,
   --                NEXT_COURT_H_DATE,
   --                CASE_TITLE,
   --                CASE_PREFIX,
   --                COURT_STAGE,
   --                TP_COMPRO_DEFENSE,
   --                STATUS_OF_INVESTIGATION_REPORT,
   --                DECISION_ON_AWARD,
   --                DETAILS_OF_FOLLOWUP,
   --                INVESTIGATION_APPOINTMENTDATE,
   --                TP_COURT_REMARKS,
   --                INVEST_REPORT_RECEIVINGDATE,
   --                ODS_CLAIM_DIM.C_ADV_NAME,
   --                P_NCB_PERCENT,
   --                P_NCB_AMOUNT,
   --                ODS_POLICY_DIM.P_COVER_NOTE_NO,
   --                ODS_POLICY_DIM.P_POLICY_STATUS,
   --                C_RECPT_PSR_DATE,
   --                C_RECPT_FSR_DATE,
   --                C_SUR_APP_DATE,
   --                C_DELAY_REASON,
   --                C_EMEDITEK_CLAIM_NO,
   --                REMARKS_OFLEGAL_OFFICER,
   --                PT_PARTNER_TYPE,
   --                C_RFA_DATE,
   --                C_EVENT_CODE,
   --                C_TPA_STATUS,
   --                PT_PARTNER_REGION,
   --                PT_PARTNER_REGION_STND,
   --                C_INVOICE_DATE,
   --                C_FSR_PSR_STATUS,
   --                P_FUEL_TYPE,
   --                P_POLICY_AGE,
   --                P_VEHICLE_REG_DATE,
   --                COMPROMISE,
   --                PT_PARTNER_PIN_CODE,
   --                PT_PARTNER_CITY,
   --                P_OLD_POLICY_NO,
   --                C_PLACE_OF_LOSS,
   --                C_LANDMARK,
   --                C_AREA,
   --                C_STATE,
   --                C_CITY,
   --                C_PINCODE,
   --                C_JOURNEY_FROM,
   --                C_JOURNEY_TO,
   --                C_CONSIGNEE_NAME,
   --                C_CONSIGNER_NAME,
   --                C_SURVEY_LOCATION,
   --                C_GOODS_DETAILS,
   --                P_COVERNOTE_DATE,
   --                DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
   --                        6609, EXTN.ASSET_CATEGORY,
   --                        6610, EXTN.ASSET_CATEGORY,
   --                        V_VEHICLE_TYPE),
   --                I_IMD_NAME,
   --                C_NEXT_RVW_DATE,
   --                C_LAST_RVW_REMARKS,
   --                ODS_POLICY_DIM.P_OPUS_UPLOAD_DATE,
   --                PARTNER_DIM_POLICY.PT_PARTNER_TELEPHONE,
   --                TP_CASE_RESP_PERSON,
   --                TP_CASE_CLAIM_LOCATION,
   --                PARTNER_DIM_POLICY.PT_PARTNER_ADDRESS,
   --                C_FPLM_FLAG,
   --                C_CLAIM_ID,
   --                C_REOPEN_REMARK,
   --                C_REOPEN_BY,
   --                BASE_SUM_INSURED,
   --                GLOBAL_FLAG,
   --                ODS_POLICY_DIM.P_EMP_CODE,
   --                ODS_CLAIM_DIM.ADDL_EXCESS,
   --                ODS_CLAIM_DIM.VOLUNTARY_EXCESS,
   --                ODS_CLAIM_DIM.COMPULSORY_EXCESS,
   --                ODS_CLAIM_DIM.EXPENSE_APP_DATE,
   --                ODS_CLAIM_DIM.LOSS_APP_DATE,
   --                ODS_CLAIM_DIM.NET_ASSESSED_AMOUNT,
   --                ODS_CLAIM_DIM.DEPRECIATION_AMOUNT,
   --                ODS_POLICY_DIM.P_SUB_CHANNEL_CODE,
   --                ODS_POLICY_DIM.P_FIRE_LOC_NAME,
   --                ODS_POLICY_DIM.P_FIRE_LOC_TYPE,
   --                ODS_POLICY_DIM.P_FIRE_OCCUPANCY,
   --                ODS_POLICY_DIM.P_FIRE_RISK_TYPE,
   --                ODS_POLICY_DIM.P_VEHICLE_GVW,
   --                ODS_MODEL_DIM.M_VEHICLE_SEGMENT,
   --                C_PORTAL_FLAG,
   --                C_MLT_YEAR,
   --                ODS_CLAIM_FACT_MV.MAXIMUS_FLAG,
   --                PARTNER_DIM_POLICY.PT_MAXI_PID,
   --                CESSION_PERC,
   --                PARTNER_DIM_POLICY.PT_PARTNER_PRIVE_FLAG'';
   -- EXECUTE IMMEDIATE v_sqltext;


  v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CLAIM_DATA
           SELECT ODS_CLAIM_DIM.C_CLAIM_NO,
                  ODS_CLAIM_DIM.C_CLAIM_ID_SK,
                  C_ACCIDENT_LOC,
                  C_LOSS_TIME,
                  DECODE (ODS_CLAIM_DIM.C_CLAIM_STATUS,
                          ''''CLOSED'''', ''''CLOSED'''',
                          ''''OPEN'''')
                     CLM_STATUS,
                  --DECODE (DENSE_RANK () OVER (PARTITION BY C_CLAIM_NO ORDER BY CP_COMPANY_ID_SK, ROWNUM DESC NULLS LAST),1, ''''Y'''',''''N'''') TOP_INDICATOR,
					 DECODE(
    ROW_NUMBER() OVER (PARTITION BY C_CLAIM_NO ORDER BY CP_COMPANY_ID_SK, ODS_TIME_DIM.T_DATE_DESC DESC NULLS LAST),
    1, ''''Y'''',''''N'''') AS TOP_INDICATOR,
                  DECODE (ODS_CLAIM_DIM.C_OFF_LOC_ID,
                          0, ODS_POLICY_DIM.P_OFFICE_LOC_ID,
                          ODS_CLAIM_DIM.C_OFF_LOC_ID)
                     C_OFF_LOC_ID,
                  ODS_POLICY_DIM.P_POLICY_NUMBER,
                  ODS_POLICY_DIM.P_OFFICE_LOC_ID POLICY_LOCATION_ID,
                  ODS_PRODUCT_DIM.P_PRODUCT_ID,
                  ODS_POLICY_DIM.P_RISK_INC_DATE,
                  ODS_POLICY_DIM.P_RISK_EXPIRY_DATE,
                  ODS_IMD_DIM.I_IMD_DESC,
                  ODS_POLICY_DIM.P_SUB_IMD,
                  DECODE (
                     I_IMD_DESC,
                     ''''DIRECT'''', NVL (
                                  DECODE (P_SUBIMD_CHANNEL,
                                          ''''DIRECT'''', NULL,
                                          P_SUBIMD_CHANNEL),
                                  I_IMD_NEW_CHANNEL),
                     I_IMD_NEW_CHANNEL)
                     IMD_CHANNEL,
                  DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
                          6609, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
                          6610, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
                          ODS_MAKE_DIM.V_VEHICLE_MAKE)
                     V_VEHICLE_MAKE,
                  ODS_POLICY_DIM.P_YEAR_OF_MANU,
                  DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
                          6609, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
                          6610, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
                          ODS_MODEL_DIM.M_VEHICLE_MODEL)
                     M_VEHICLE_MODEL,
                  ODS_POLICY_DIM.P_REGN_NO,
                  PT_PARTNER_ID,
                  PARTNER_DIM_POLICY.PT_PARTNER_DESC,
                  PARTNER_DIM_POLICY.PT_PARTNER_CITY,
                  ODS_CLAIM_DIM.C_COMMENTS,
                  ODS_CLAIM_DIM.C_CLAIM_TYPE,
                  ODS_CLAIM_DIM.C_CAUSE_OF_LOSS,
                  ODS_CLAIM_DIM.C_REP_NAME,
                  ODS_CLAIM_DIM.C_NAME_OF_IN1,
                  ODS_CLAIM_DIM.C_REGN_DATE,
                  ODS_CLAIM_DIM.C_CLO_DATE,
                  ODS_CLAIM_DIM.C_LOSS_DATE,
                  ODS_CLAIM_DIM.C_INTI_DATE,
                  ODS_CLAIM_DIM.C_SUR_NAME,
                  ODS_CLAIM_DIM.C_APP_DATE,
                  C_POLICY_GRAIN,
                  C_CLAIM_REGD_BY,
                  C_LAST_REOPEN_DATE,
                  C_PAID_FLAG,
                  C_CONS_FORUM_FLAG CONSUMER_FORUM_FLAG,
                  C_OMBSMAN_FLAG,
                  C_LIGITATION_FLAG,
                  P_DEPARTMENT_DESC,
                  DECODE (ODS_CLAIM_DIM.C_REOPEN_FLAG, 1, ''''Y'''', ''''N'''') REOPEN_FLAG,
                  CASE
                     WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 1 THEN ''''RENEWAL''''
                     WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 2 THEN ''''ROllOVER''''
                     ELSE ''''NEW BUSINESS''''
                  END
                     REN_ROLL_NB_FLAG,
                  CASE
                     WHEN     ODS_PRODUCT_DIM.P_PRODUCT_ID IN
                                 (1803,
                                  1807,
                                  1810,
                                  1811,
                                  1812,
                                  1852,
                                  1853,
                                  1854,
                                  5001)
                          AND ODS_CLAIM_DIM.C_CLAIM_TYPE = ''''TP''''
                          AND ODS_POLICY_DIM.P_RISK_INC_DATE BETWEEN ''''01-apr-2007''''
                                                                 AND ''''31-mar-2012''''
                          AND ODS_POLICY_DIM.P_POLICY_ISSUE_DATE >=
                                 ''''01-apr-2007''''
                          AND B.P_POLICY_NUMBER IS NOT NULL
                     THEN
                        ''''Y''''
                     ELSE
                        ''''N''''
                  END
                     TP_POOL_FLAG,
                    SUM(ODS_CLAIM_FACT_MV.PAID_CLAIM)
               -SUM (
                    CASE
                       WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-OCT-2009''''
                       THEN
                          NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)
                       ELSE
                          0
                    END)
                  POOL_PAID_FLAG,
                  ODS_POLICY_DIM.P_MASTER_POLICY_NO,
                  ODS_POLICY_DIM.P_REN_INDICATOR,
                  ODS_CLAIM_DIM.C_COURT_FLAG,
                  ODS_CLAIM_DIM.C_SUR_REP_DATE,
                  ODS_POLICY_DIM.P_POLICY_ISSUE_DATE,
                  ODS_POLICY_DIM.P_COINSURANCE_TYPE,
                  ODS_TIME_DIM.T_DATE_DESC,
                  CP_COMPANY_NAME,
                  ODS_RESERVE_DIM.R_RESERVE_GROUP_DESC,
                  R_RESERVE_DESC,
                  P_GEOGRAPHIC_SCOPE,
                  P_GC_PLAN,
                  P_ENGINE_NUMBER,
                  P_CHASSIS_NUMBER,
                  C_SETTLEMNT_TYPE,
                  C_ALL_DOC_DATE,
                  C_SPECIAL_COMMENTS,
                  C_MRN_TRANSPORTER_NAME,
                  C_INVOICE_NO,
                  RUNNER_NAME,
                  RUNNER_CODE,
                  BRANCH_RESP,
                  CSE_CODE,
                  PT_INIT_CLUSTER_ID PT_HOUSE_HOLD_ID,
                  PT_CLUSTER_ID,
                  CASE_YEAR,
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
                  ODS_CLAIM_DIM.C_ADV_NAME,
                  P_NCB_PERCENT,
                  P_NCB_AMOUNT,
                  ODS_POLICY_DIM.P_COVER_NOTE_NO,
                  ODS_POLICY_DIM.P_POLICY_STATUS,
                  C_RECPT_PSR_DATE,
                  C_RECPT_FSR_DATE,
                  C_SUR_APP_DATE,
                  C_DELAY_REASON,
                  C_EMEDITEK_CLAIM_NO,
                  REMARKS_OFLEGAL_OFFICER,
                  PT_PARTNER_TYPE,
                  C_RFA_DATE,
                  C_EVENT_CODE,
                  C_TPA_STATUS,
                  PT_PARTNER_REGION,
                  PT_PARTNER_REGION_STND,
                  C_INVOICE_DATE,
                  C_FSR_PSR_STATUS,
                  P_FUEL_TYPE,
                  P_POLICY_AGE POLICY_AGE,
                  P_VEHICLE_REG_DATE VEHICLE_REG_DATE,
                  COMPROMISE TP_COMPROMISE,
                  PT_PARTNER_PIN_CODE PARTNER_PIN_CODE,
                  PT_PARTNER_CITY PARTNER_CITY,
                  P_OLD_POLICY_NO OLD_POLICY_NO,
                  SUM(NVL (ODS_CLAIM_FACT_MV.PAID_CLAIM, 0)) PAID_CLAIM,
              SUM(NVL (ODS_CLAIM_FACT_MV.RESERVE_AMOUNT, 0)) RESERVE_AMOUNT,
                SUM( NVL (ODS_CLAIM_FACT_MV.RESERVE_AMOUNT, 0))
               - SUM(NVL (ODS_CLAIM_FACT_MV.PAID_CLAIM, 0))
                  OS_AMT,
               SUM(NVL (ODS_CLAIM_FACT_MV.SALVAGE_AMOUNT, 0)) SALVAGE_AMT,
               SUM(NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)) SERVICE_TAX,
                  SUM(
                  CASE
                     WHEN ODS_TIME_DIM.T_DATE_DESC < ''''01-Apr-2011'''' THEN 0
                     ELSE (NVL (ODS_CLAIM_FACT_MV.SALVAGE_AMOUNT, 0))
                  END)
                  POOL_SALVAGE_AMT,
               (SUM(  ODS_CLAIM_FACT_MV.PAID_CLAIM)
                - SUM(
                     CASE
                        WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-OCT-2009''''
                        THEN
                           NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)
                        ELSE
                           0
                     END))
                  POOL_PAID_BEFORE_SALVAGE,
               (  SUM(ODS_CLAIM_FACT_MV.PAID_CLAIM)
                -
                    SUM( CASE
                        WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-OCT-2009''''
                        THEN
                           NVL (ODS_CLAIM_FACT_MV.SERVICE_TAX, 0)
                        ELSE
                           0
                     END)
                +
                     SUM(CASE
                        WHEN ODS_TIME_DIM.T_DATE_DESC >= ''''01-Apr-2011''''
                        THEN
                           NVL (ODS_CLAIM_FACT_MV.SALVAGE_AMOUNT, 0)
                        ELSE
                           0
                     END))
                  POOL_PAID_AFTER_SALVAGE,
               SUM(NVL (ODS_CLAIM_FACT_MV.NET_PAID, 0)) NET_PAID,
               SUM(NVL (ODS_CLAIM_FACT_MV.NET_TAX, 0)) NET_TAX,
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
                  P_COVERNOTE_DATE,
                  DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
                          6609, EXTN.ASSET_CATEGORY,
                          6610, EXTN.ASSET_CATEGORY,
                          V_VEHICLE_TYPE)
                     V_VEHICLE_TYPE,
                  I_IMD_NAME,
                  C_NEXT_RVW_DATE,
                  C_LAST_RVW_REMARKS,
                  ODS_POLICY_DIM.P_OPUS_UPLOAD_DATE P_OLD_POL_EXP_DATE,
                  PARTNER_DIM_POLICY.PT_PARTNER_TELEPHONE,
                  TP_CASE_RESP_PERSON,
                  TP_CASE_CLAIM_LOCATION,
                  PARTNER_DIM_POLICY.PT_PARTNER_ADDRESS,
                  C_FPLM_FLAG,
                  C_CLAIM_ID,
                  C_REOPEN_REMARK,
                  C_REOPEN_BY,
                  BASE_SUM_INSURED,
                  GLOBAL_FLAG,
                  ODS_POLICY_DIM.P_EMP_CODE,
                  ODS_CLAIM_DIM.ADDL_EXCESS,
                  ODS_CLAIM_DIM.VOLUNTARY_EXCESS,
                  ODS_CLAIM_DIM.COMPULSORY_EXCESS,
                  ODS_CLAIM_DIM.EXPENSE_APP_DATE,
                  ODS_CLAIM_DIM.LOSS_APP_DATE,
                  ODS_CLAIM_DIM.NET_ASSESSED_AMOUNT,
                  ODS_CLAIM_DIM.DEPRECIATION_AMOUNT,
                  P_SUB_CHANNEL_CODE,
                  ODS_POLICY_DIM.P_FIRE_LOC_NAME,
                  ODS_POLICY_DIM.P_FIRE_LOC_TYPE,
                  ODS_POLICY_DIM.P_FIRE_OCCUPANCY,
                  ODS_POLICY_DIM.P_FIRE_RISK_TYPE,
                  ODS_POLICY_DIM.P_VEHICLE_GVW,
                  ODS_MODEL_DIM.M_VEHICLE_SEGMENT,
                  ODS_CLAIM_DIM.C_PORTAL_FLAG,
                  C_MLT_YEAR,
                  ODS_CLAIM_FACT_MV.MAXIMUS_FLAG,
                  PARTNER_DIM_POLICY.PT_MAXI_PID,
                  CESSION_PERC,
                  CASE
                     WHEN CESSION_PERC IS NOT NULL THEN 100 - CESSION_PERC
                     ELSE NULL
                  END
                     RI_RETENTION_PERCENTAGE,
                     PARTNER_DIM_POLICY.PT_PARTNER_PRIVE_FLAG,
                     SUM (NVL (RECOVERY_INITIATED, 0)) RECOVERY_INITIATED,
                     SUM (NVL (RECOVERY_DONE, 0)) RECOVERY_DONE,
                    SUM (NVL (RECOVERY_PENDING, 0)) RECOVERY_PENDING,
                     ODS_CLAIM_DIM.C_OD_TYPE_OF_LOSS,
                     ODS_CLAIM_DIM.C_HHID,
                     ODS_CLAIM_DIM.C_NET_TAX_LABOUR,
                     ODS_CLAIM_DIM.C_NET_TAX_PARTS,
                     M_VEHICLE_SUBTYPE
             FROM INTERMEDIATE.WRK_ODS_CLAIM_DIM ODS_CLAIM_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_PARTNER_DIM PARTNER_DIM_POLICY,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_IMD_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_MAKE_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_MODEL_DIM,
                  TRANSACTIONAL.ODS_RESERVE_DIM,
                  TRANSACTIONAL.ODS_CLAIM_FACT_MV,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_LOCATION_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_COMPANY_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_DM_DATA A,
                  PROD_DWH_MIGRATED_DB.PROD.RECO_TBL_27_AUG_09_MV B,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_TP_CLM_DTLS TP,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_VEHICLE_TYPE_DIM,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM_EXTN EXTN,
                  PROD_DWH_MIGRATED_DB.PROD.WRK_RI_SHARE RI_SHARE
            WHERE     ODS_POLICY_DIM.P_POLICY_NUMBER = B.P_POLICY_NUMBER(+)
                  AND (ODS_POLICY_DIM.P_POLICY_NO_SK =
                          ODS_CLAIM_FACT_MV.P_POLICY_NO_SK)
                  AND (ODS_CLAIM_FACT_MV.T_DATE_ID_SK =
                          ODS_TIME_DIM.T_DATE_ID_SK)
                  AND (COMPANY_CODE = CP_COMPANY_ID_SK)
                  AND (ODS_CLAIM_FACT_MV.R_RESERVE_TYPE_ID =
                          ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK)
                  AND (ODS_POLICY_DIM.P_IMD_ID_SK = ODS_IMD_DIM.I_IMD_ID_SK(+))
                  AND (ODS_POLICY_DIM.P_PRODUCT_ID =
                          ODS_PRODUCT_DIM.P_PRODUCT_ID)
                  AND (    ODS_MAKE_DIM.V_VEHICLE_MAKE_CODE(+) =
                              ODS_POLICY_DIM.P_VEHICLE_MAKE
                       AND ODS_MAKE_DIM.V_VEHICLE_TYPE_CODE(+) =
                              ODS_POLICY_DIM.P_VEHICLE_TYPE)
                  AND (PARTNER_DIM_POLICY.PT_PARTNER_ID_SK =
                          ODS_POLICY_DIM.P_PARTNER_ID_SK)
                  AND (    ODS_MODEL_DIM.M_VEHICLE_MAKE_CODE(+) =
                              ODS_POLICY_DIM.P_VEHICLE_MAKE
                       AND ODS_MODEL_DIM.M_VEHICLE_MODEL_CODE(+) =
                              ODS_POLICY_DIM.P_VEHICLE_MODEL
                       AND ODS_MODEL_DIM.M_VEHICLE_SUBTYPE_CODE(+) =
                              NVL(NULLIF(ODS_POLICY_DIM.P_VEHICLE_SUB_TYPE, ''''''''), NULL)
                       AND ODS_MODEL_DIM.M_VEHICLE_TYPE_CODE(+) =
                              ODS_POLICY_DIM.P_VEHICLE_TYPE)
                  AND (ODS_CLAIM_FACT_MV.C_CLAIM_ID_SK =
                          ODS_CLAIM_DIM.C_CLAIM_ID_SK)
                  AND (ODS_CLAIM_DIM.C_OFF_LOC_ID =
                          ODS_LOCATION_DIM.OFFICE_LOCATION_ID(+))
                  AND ODS_POLICY_DIM.P_POLICY_NUMBER = A.POLICY_REF(+)
                  AND ODS_POLICY_DIM.P_POLICY_NUMBER = RI_SHARE.POLICY_REF(+)
                  AND POLICY_YEAR(+) = 1
                  AND C_CLAIM_NO = TP.CLAIM_NO(+)
                  AND C_CLAIM_NO IN (SELECT C_CLAIM_NO FROM INTERMEDIATE.WRK_ODS_CLAIM_DIM)
                  AND ODS_TIME_DIM.T_DATE_DESC BETWEEN DATE_TRUNC(''''MONTH'''',  TO_DATE(''''''|| F_DATE|| ''''''))
                                                   AND DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - 1
                  AND ODS_MAKE_DIM.V_VEHICLE_TYPE_CODE =
                         ODS_VEHICLE_TYPE_DIM.V_VEHICLE_TYPE_CODE(+)
                  AND ODS_POLICY_DIM.P_POLICY_NUMBER = EXTN.POLICY_REF(+)
                  GROUP BY ODS_CLAIM_DIM.C_OFF_LOC_ID,
               ODS_CLAIM_DIM.C_CLAIM_NO,
               DECODE (ODS_CLAIM_DIM.C_CLAIM_STATUS,
                       ''''CLOSED'''', ''''CLOSED'''',
                       ''''OPEN''''),
               C_CONS_FORUM_FLAG,
               C_OMBSMAN_FLAG,
               C_LIGITATION_FLAG,
               CP_COMPANY_NAME,
               ODS_CLAIM_DIM.C_COMMENTS,
               ODS_CLAIM_DIM.C_CLAIM_TYPE,
               ODS_CLAIM_DIM.C_CAUSE_OF_LOSS,
               ODS_POLICY_DIM.P_POLICY_NUMBER,
               ODS_POLICY_DIM.P_OFFICE_LOC_ID,
               ODS_PRODUCT_DIM.P_PRODUCT_ID,
               PT_PARTNER_ID,
               PARTNER_DIM_POLICY.PT_PARTNER_DESC,
               PARTNER_DIM_POLICY.PT_PARTNER_CITY,
               ODS_POLICY_DIM.P_RISK_INC_DATE,
               ODS_POLICY_DIM.P_RISK_EXPIRY_DATE,
               ODS_IMD_DIM.I_IMD_DESC,
               ODS_POLICY_DIM.P_SUB_IMD,
               DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
                       6609, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
                       6610, SUBSTR (EXTN.ASSET_MANUFACTURER, 1, 100),
                       ODS_MAKE_DIM.V_VEHICLE_MAKE),
               ODS_POLICY_DIM.P_YEAR_OF_MANU,
               DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
                       6609, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
                       6610, SUBSTR (EXTN.ASSET_MODEL_NO, 1, 1000),
                       ODS_MODEL_DIM.M_VEHICLE_MODEL),
               ODS_POLICY_DIM.P_REGN_NO,
               ODS_CLAIM_DIM.C_REGN_DATE,
               ODS_CLAIM_DIM.C_REP_NAME,
               ODS_CLAIM_DIM.C_NAME_OF_IN1,
               C_POLICY_GRAIN,
               C_CLAIM_REGD_BY,
               C_LAST_REOPEN_DATE,
               C_PAID_FLAG,
               ODS_CLAIM_DIM.C_CLO_DATE,
               ODS_CLAIM_DIM.C_LOSS_DATE,
               ODS_CLAIM_DIM.C_INTI_DATE,
               ODS_CLAIM_DIM.C_SUR_NAME,
               ODS_RESERVE_DIM.R_RESERVE_GROUP_DESC,
               CP_COMPANY_ID_SK,
               ODS_CLAIM_DIM.C_APP_DATE,
               ODS_TIME_DIM.T_DATE_DESC,
               DECODE (
                     I_IMD_DESC,
                     ''''DIRECT'''', NVL (
                                  DECODE (P_SUBIMD_CHANNEL,
                                          ''''DIRECT'''', NULL,
                                          P_SUBIMD_CHANNEL),
                                  I_IMD_NEW_CHANNEL),
                     I_IMD_NEW_CHANNEL),
               CASE
            	  WHEN     ODS_PRODUCT_DIM.P_PRODUCT_ID IN
            				  (1803,
            				   1807,
            				   1810,
            				   1811,
            				   1812,
            				   1852,
            				   1853,
            				   1854,
            				   5001)
            		   AND ODS_CLAIM_DIM.C_CLAIM_TYPE = ''''TP''''
            		   AND ODS_POLICY_DIM.P_RISK_INC_DATE BETWEEN ''''01-apr-2007''''
            												  AND ''''31-mar-2012''''
            		   AND ODS_POLICY_DIM.P_POLICY_ISSUE_DATE >=
            				  ''''01-apr-2007''''
            		   AND B.P_POLICY_NUMBER IS NOT NULL
            	  THEN
            		 ''''Y''''
            	  ELSE
            		 ''''N''''
               END,
               DECODE (ODS_CLAIM_DIM.C_REOPEN_FLAG, 1, ''''Y'''', ''''N''''),
               ODS_POLICY_DIM.P_MASTER_POLICY_NO,
               ODS_POLICY_DIM.P_REN_INDICATOR,
               ODS_CLAIM_DIM.C_COURT_FLAG,
               ODS_CLAIM_DIM.C_SUR_REP_DATE,
               ODS_POLICY_DIM.P_POLICY_ISSUE_DATE,
               ODS_POLICY_DIM.P_COINSURANCE_TYPE,
               R_RESERVE_DESC,
               P_GEOGRAPHIC_SCOPE,
               P_GC_PLAN,
               P_ENGINE_NUMBER,
               P_CHASSIS_NUMBER,
               C_SETTLEMNT_TYPE,
               P_DEPARTMENT_DESC,
               ODS_CLAIM_DIM.C_CLAIM_ID_SK,
               C_ACCIDENT_LOC,
               C_LOSS_TIME,
               CASE
                  WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 1 THEN ''''RENEWAL''''
                  WHEN ODS_POLICY_DIM.P_REN_INDICATOR = 2 THEN ''''ROllOVER''''
                  ELSE ''''NEW BUSINESS''''
                END,
               C_ALL_DOC_DATE,
               C_SPECIAL_COMMENTS,
               C_MRN_TRANSPORTER_NAME,
               C_INVOICE_NO,
               P_GC_PLAN,
               RUNNER_NAME,
               RUNNER_CODE,
               BRANCH_RESP,
               CSE_CODE,
               PT_INIT_CLUSTER_ID,
               PT_CLUSTER_ID,
               CASE_YEAR,
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
               ODS_CLAIM_DIM.C_ADV_NAME,
               P_NCB_PERCENT,
               P_NCB_AMOUNT,
               ODS_POLICY_DIM.P_COVER_NOTE_NO,
               ODS_POLICY_DIM.P_POLICY_STATUS,
               C_RECPT_PSR_DATE,
               C_RECPT_FSR_DATE,
               C_SUR_APP_DATE,
               C_DELAY_REASON,
               C_EMEDITEK_CLAIM_NO,
               REMARKS_OFLEGAL_OFFICER,
               PT_PARTNER_TYPE,
               C_RFA_DATE,
               C_EVENT_CODE,
               C_TPA_STATUS,
               PT_PARTNER_REGION,
               PT_PARTNER_REGION_STND,
               C_INVOICE_DATE,
               C_FSR_PSR_STATUS,
               P_FUEL_TYPE,
               P_POLICY_AGE,
               P_VEHICLE_REG_DATE,
               COMPROMISE,
               PT_PARTNER_PIN_CODE,
               PT_PARTNER_CITY,
               P_OLD_POLICY_NO,
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
               P_COVERNOTE_DATE,
               DECODE (ODS_PRODUCT_DIM.P_PRODUCT_ID,
                       6609, EXTN.ASSET_CATEGORY,
                       6610, EXTN.ASSET_CATEGORY,
                       V_VEHICLE_TYPE),
               I_IMD_NAME,
               C_NEXT_RVW_DATE,
               C_LAST_RVW_REMARKS,
               ODS_POLICY_DIM.P_OPUS_UPLOAD_DATE,
               PARTNER_DIM_POLICY.PT_PARTNER_TELEPHONE,
               TP_CASE_RESP_PERSON,
               TP_CASE_CLAIM_LOCATION,
               PARTNER_DIM_POLICY.PT_PARTNER_ADDRESS,
               C_FPLM_FLAG,
               C_CLAIM_ID,
               C_REOPEN_REMARK,
               C_REOPEN_BY,
               BASE_SUM_INSURED,
               GLOBAL_FLAG,
               ODS_POLICY_DIM.P_EMP_CODE,
               ODS_CLAIM_DIM.ADDL_EXCESS,
               ODS_CLAIM_DIM.VOLUNTARY_EXCESS,
               ODS_CLAIM_DIM.COMPULSORY_EXCESS,
               ODS_CLAIM_DIM.EXPENSE_APP_DATE,
               ODS_CLAIM_DIM.LOSS_APP_DATE,
               ODS_CLAIM_DIM.NET_ASSESSED_AMOUNT,
               ODS_CLAIM_DIM.DEPRECIATION_AMOUNT,
               ODS_POLICY_DIM.P_SUB_CHANNEL_CODE,
               ODS_POLICY_DIM.P_FIRE_LOC_NAME,
               ODS_POLICY_DIM.P_FIRE_LOC_TYPE,
               ODS_POLICY_DIM.P_FIRE_OCCUPANCY,
               ODS_POLICY_DIM.P_FIRE_RISK_TYPE,
               ODS_POLICY_DIM.P_VEHICLE_GVW,
               ODS_MODEL_DIM.M_VEHICLE_SEGMENT,
               C_PORTAL_FLAG,
               C_MLT_YEAR,
               ODS_CLAIM_FACT_MV.MAXIMUS_FLAG,
               PARTNER_DIM_POLICY.PT_MAXI_PID,
               CESSION_PERC,
               PARTNER_DIM_POLICY.PT_PARTNER_PRIVE_FLAG,
               ODS_CLAIM_DIM.C_OD_TYPE_OF_LOSS,
               ODS_CLAIM_DIM.C_HHID,
               ODS_CLAIM_DIM.C_NET_TAX_LABOUR,
               ODS_CLAIM_DIM.C_NET_TAX_PARTS,
               M_VEHICLE_SUBTYPE
         '';
   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext := ''DELETE FROM TRANSACTIONAL.MV_CLAIM_REGISTER
            WHERE     C_CLAIM_NO IN
                         (SELECT C_CLAIM_NO FROM INTERMEDIATE.WRK_ODS_CLAIM_DIM)
                  AND T_DATE_DESC BETWEEN DATE_TRUNC(''''MONTH'''',  TO_DATE(''''''|| F_DATE|| ''''''))
                                      AND DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - 1'';
   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext := ''INSERT INTO TRANSACTIONAL.MV_CLAIM_REGISTER
         SELECT C_CLAIM_NO,
                C_CLAIM_ID_SK,
                C_ACCIDENT_LOC,
                C_LOSS_TIME,
                CLM_STATUS,
                TOP_INDICATOR,
                C_OFF_LOC_ID,
                P_POLICY_NUMBER,
                POLICY_LOCATION_ID,
                P_PRODUCT_ID,
                P_RISK_INC_DATE,
                P_RISK_EXPIRY_DATE,
                I_IMD_DESC,
                P_SUB_IMD,
                IMD_CHANNEL,
                V_VEHICLE_MAKE,
                P_YEAR_OF_MANU,
                M_VEHICLE_MODEL,
                P_REGN_NO,
                PT_PARTNER_ID,
                PT_PARTNER_DESC,
                PT_PARTNER_CITY,
                C_COMMENTS,
                C_CLAIM_TYPE,
                C_CAUSE_OF_LOSS,
                C_REP_NAME,
                C_NAME_OF_IN1,
                C_REGN_DATE,
                C_CLO_DATE,
                C_LOSS_DATE,
                C_INTI_DATE,
                C_SUR_NAME,
                C_APP_DATE,
                C_POLICY_GRAIN,
                C_CLAIM_REGD_BY,
                C_LAST_REOPEN_DATE,
                C_PAID_FLAG,
                CONSUMER_FORUM_FLAG,
                C_OMBSMAN_FLAG,
                C_LIGITATION_FLAG,
                P_DEPARTMENT_DESC,
                REOPEN_FLAG,
                REN_ROLL_NB_FLAG,
                TP_POOL_FLAG,
                POOL_PAID_FLAG,
                P_MASTER_POLICY_NO,
                P_REN_INDICATOR,
                C_COURT_FLAG,
                C_SUR_REP_DATE,
                P_POLICY_ISSUE_DATE,
                P_COINSURANCE_TYPE,
                T_DATE_DESC,
                CP_COMPANY_NAME,
                R_RESERVE_GROUP_DESC,
                R_RESERVE_DESC,
                P_GEOGRAPHIC_SCOPE,
                P_GC_PLAN,
                P_ENGINE_NUMBER,
                P_CHASSIS_NUMBER,
                C_SETTLEMNT_TYPE,
                C_ALL_DOC_DATE,
                C_SPECIAL_COMMENTS,
                C_MRN_TRANSPORTER_NAME,
                C_INVOICE_NO,
                RUNNER_NAME,
                RUNNER_CODE,
                BRANCH_RESP,
                CSE_CODE,
                PT_HOUSE_HOLD_ID,
                PT_CLUSTER_ID,
                CASE_YEAR,
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
                C_ADV_NAME,
                P_NCB_PERCENT,
                P_NCB_AMOUNT,
                P_COVER_NOTE_NO,
                P_POLICY_STATUS,
                C_RECPT_PSR_DATE,
                C_RECPT_FSR_DATE,
                C_SUR_APP_DATE,
                C_DELAY_REASON,
                C_EMEDITEK_CLAIM_NO,
                REMARKS_OFLEGAL_OFFICER,
                PT_PARTNER_TYPE,
                C_RFA_DATE,
                C_EVENT_CODE,
                C_TPA_STATUS,
                PT_PARTNER_REGION,
                PT_PARTNER_REGION_STND,
                C_INVOICE_DATE,
                C_FSR_PSR_STATUS,
                P_FUEL_TYPE,
                POLICY_AGE,
                VEHICLE_REG_DATE,
                TP_COMPROMISE,
                PARTNER_PIN_CODE,
                PARTNER_CITY,
                OLD_POLICY_NO,
                PAID_CLAIM,
                RESERVE_AMOUNT,
                OS_AMT,
                SALVAGE_AMT,
                SERVICE_TAX,
                POOL_SALVAGE_AMT,
                POOL_PAID_BEFORE_SALVAGE,
                POOL_PAID_AFTER_SALVAGE,
                NET_PAID,
                NET_TAX,
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
                COVERNOTE_DATE,
                VEHICLE_TYPE,
                IMD_NAME,
                C_NEXT_RVW_DATE,
                C_LAST_RVW_REMARKS,
                P_OLD_POL_EXP_DATE,
                PT_PARTNER_TELEPHONE,
                TP_RESP_PERSON,
                TP_CLM_HANDLING_LOC,
                PT_PARTNER_ADDRESS,
                C_FPLM_FLAG,
                C_CLAIM_ID,
                C_REOPEN_REMARK,
                C_REOPEN_BY,
                BASE_SUM_INSURED,
                POL_GLOBAL_FLAG,
                P_EMP_CODE,
                ADDL_EXCESS,
                VOLUNTARY_EXCESS,
                COMPULSORY_EXCESS,
                EXPENSE_APP_DATE,
                LOSS_APP_DATE,
                NET_ASSESSED_AMOUNT,
                DEPRECIATION_AMOUNT,
                P_SUB_CHANNEL_CODE,
                P_FIRE_LOC_NAME,
                P_FIRE_LOC_TYPE,
                P_FIRE_OCCUPANCY,
                P_FIRE_RISK_TYPE,
                P_VEHICLE_GVW,
                M_VEHICLE_SEGMENT,
                C_PORTAL_FLAG,
                C_MLT_YEAR,
                MAXIMUS_FLAG,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                PT_PARTY_CODE,
                CESSION_PERC,
                RI_RETENTION_PERCENTAGE,
                CASE
                   WHEN CESSION_PERC IS NOT NULL
                   THEN
                      ROUND (
                         (  (NVL (PAID_CLAIM, 0) - NVL (SERVICE_TAX, 0))
                          * NVL ( (CESSION_PERC / 100), 1)),
                         2)
                   ELSE
                      0
                END
                   RI_RETENTION_PAID_AMOUNT,
                CASE
                   WHEN CESSION_PERC IS NOT NULL
                   THEN
                      ROUND (
                         ( (NVL (OS_AMT, 0)) * NVL ( (CESSION_PERC / 100), 1)),
                         2)
                   ELSE
                      0
                END
                   RI_RETENTION_OS_AMOUNT,
                     NULL,
                 TO_DATE(''''''|| T_DATE|| ''''''),
                PT_PARTNER_PRIVE_FLAG,
                null as TRANS_TYPE,
                DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')),
                null as INC_JOB_CREATED_AT,
                null as INC_JOB_CREATED_BY,
                null as INC_JOB_UPDATED_BY,
                null as INC_JOB_UPDATED_AT,
                null as INC_JOB_ID,
                RECOVERY_INITIATED,
                RECOVERY_DONE,
                RECOVERY_PENDING,
                C_OD_TYPE_OF_LOSS,
                C_HHID,
                C_NET_TAX_LABOUR,
                C_NET_TAX_PARTS,
                CR_VEHICLE_SUBTYPE

           FROM INTERMEDIATE.WRK_MV_CLAIM_DATA A'';
   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext := ''DELETE FROM TRANSACTIONAL.MV_CLAIM_REGISTER_OS
            WHERE C_CLAIM_NO IN (SELECT C_CLAIM_NO FROM INTERMEDIATE.WRK_MV_CLAIM_DATA)'';
   EXECUTE IMMEDIATE v_sqltext;

   v_sqltext := ''INSERT INTO TRANSACTIONAL.MV_CLAIM_REGISTER_OS
         SELECT
               C_CLAIM_NO,
                C_CLAIM_ID_SK,
                C_ACCIDENT_LOC,
                C_LOSS_TIME,
                CLM_STATUS,
                TOP_INDICATOR,
                C_OFF_LOC_ID,
                P_POLICY_NUMBER,
                POLICY_LOCATION_ID,
                P_PRODUCT_ID,
                P_RISK_INC_DATE,
                P_RISK_EXPIRY_DATE,
                I_IMD_DESC,
                P_SUB_IMD,
                IMD_CHANNEL,
                V_VEHICLE_MAKE,
                P_YEAR_OF_MANU,
                M_VEHICLE_MODEL,
                P_REGN_NO,
                PT_PARTNER_ID,
                PT_PARTNER_DESC,
                PT_PARTNER_CITY,
                C_COMMENTS,
                C_CLAIM_TYPE,
                C_CAUSE_OF_LOSS,
                C_REP_NAME,
                C_NAME_OF_IN1,
                C_REGN_DATE,
                C_CLO_DATE,
                C_LOSS_DATE,
                C_INTI_DATE,
                C_SUR_NAME,
                C_APP_DATE,
                C_POLICY_GRAIN,
                C_CLAIM_REGD_BY,
                C_LAST_REOPEN_DATE,
                C_PAID_FLAG,
                CONSUMER_FORUM_FLAG,
                C_OMBSMAN_FLAG,
                C_LIGITATION_FLAG,
                P_DEPARTMENT_DESC,
                REOPEN_FLAG,
                REN_ROLL_NB_FLAG,
                TP_POOL_FLAG,
                POOL_PAID_FLAG,
                P_MASTER_POLICY_NO,
                P_REN_INDICATOR,
                C_COURT_FLAG,
                C_SUR_REP_DATE,
                P_POLICY_ISSUE_DATE,
                P_COINSURANCE_TYPE,
                T_DATE_DESC,
                CP_COMPANY_NAME,
                R_RESERVE_GROUP_DESC,
                R_RESERVE_DESC,
                P_GEOGRAPHIC_SCOPE,
                P_GC_PLAN,
                P_ENGINE_NUMBER,
                P_CHASSIS_NUMBER,
                C_SETTLEMNT_TYPE,
                C_ALL_DOC_DATE,
                C_SPECIAL_COMMENTS,
                C_MRN_TRANSPORTER_NAME,
                C_INVOICE_NO,
                RUNNER_NAME,
                RUNNER_CODE,
                BRANCH_RESP,
                CSE_CODE,
                PT_HOUSE_HOLD_ID,
                PT_CLUSTER_ID,
                A.CASE_YEAR,
                A.HO_ID,
                A.NEXT_COURT_H_DATE,
                A.CASE_TITLE,
                A.CASE_PREFIX,
                A.COURT_STAGE,
                A.TP_COMPRO_DEFENSE,
                A.STATUS_OF_INVESTIGATION_REPORT,
                A.DECISION_ON_AWARD,
                A.DETAILS_OF_FOLLOWUP,
                A.INVESTIGATION_APPOINTMENTDATE,
                A.TP_COURT_REMARKS,
                A.INVEST_REPORT_RECEIVINGDATE,
                C_ADV_NAME,
                P_NCB_PERCENT,
                P_NCB_AMOUNT,
                P_COVER_NOTE_NO,
                P_POLICY_STATUS,
                C_RECPT_PSR_DATE,
                C_RECPT_FSR_DATE,
                C_SUR_APP_DATE,
                C_DELAY_REASON,
                C_EMEDITEK_CLAIM_NO,
                A.REMARKS_OFLEGAL_OFFICER,
                PT_PARTNER_TYPE,
                C_RFA_DATE,
                C_EVENT_CODE,
                C_TPA_STATUS,
                PT_PARTNER_REGION,
                PT_PARTNER_REGION_STND,
                C_INVOICE_DATE,
                C_FSR_PSR_STATUS,
                P_FUEL_TYPE,
                POLICY_AGE,
                VEHICLE_REG_DATE,
                TP_COMPROMISE,
                PARTNER_PIN_CODE,
                PARTNER_CITY,
                OLD_POLICY_NO,
                PAID_CLAIM,
                RESERVE_AMOUNT,
                OS_AMT,
                SALVAGE_AMT,
                SERVICE_TAX,
                POOL_SALVAGE_AMT,
                POOL_PAID_BEFORE_SALVAGE,
                POOL_PAID_AFTER_SALVAGE,
                NET_PAID,
                NET_TAX,
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
                P_COVERNOTE_DATE,
                V_VEHICLE_TYPE,
                I_IMD_NAME,
                C_NEXT_RVW_DATE,
                C_LAST_RVW_REMARKS,
                P_OLD_POL_EXP_DATE,
                TP_CLM_HANDLING_LOC,
                TP_RESP_PERSON,
                PT_PARTNER_TELEPHONE,
                PT_PARTNER_ADDRESS,
                C_FPLM_FLAG,
                C_CLAIM_ID,
                C_REOPEN_REMARK,
                C_REOPEN_BY,
                BASE_SUM_INSURED,
                POL_GLOBAL_FLAG,
                P_EMP_CODE,
                ADDL_EXCESS,
                VOLUNTARY_EXCESS,
                COMPULSORY_EXCESS,
                EXPENSE_APP_DATE,
                LOSS_APP_DATE,
                NET_ASSESSED_AMOUNT,
                DEPRECIATION_AMOUNT,
                P_SUB_CHANNEL_CODE,
                CASE
                   WHEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - TO_DATE(C_REGN_DATE) BETWEEN 0 AND 15
                   THEN
                      ''''0-15''''
                   WHEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - TO_DATE(C_REGN_DATE) BETWEEN 16 AND 30
                   THEN
                      ''''16-30''''
                   WHEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - TO_DATE(C_REGN_DATE) BETWEEN 31 AND 60
                   THEN
                      ''''31-60''''
                   WHEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - TO_DATE(C_REGN_DATE) BETWEEN 61 AND 90
                   THEN
                      ''''61-90''''
                   WHEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - TO_DATE(C_REGN_DATE) BETWEEN 91 AND 180
                   THEN
                      ''''91-180''''
                   WHEN DATE_TRUNC(''''DAY'''',  TO_DATE(''''''|| T_DATE|| '''''')) - TO_DATE(C_REGN_DATE) BETWEEN 181 AND 165
                   THEN
                      ''''181-365''''
                   ELSE
                      ''''Above 365''''
                END
                   OS_BAND,
                C_PORTAL_FLAG,
                C_MLT_YEAR,
                MAXIMUS_FLAG,
                PT_PARTY_CODE,
                CESSION_PERC,
                RI_RETENTION_OS_AMOUNT,
                null as ILM_FLAG,
                null as INC_JOB_PRECOMBINE_FIELD,
	            null as INC_JOB_CREATED_AT,
                null as INC_JOB_CREATED_BY,
                null as INC_JOB_UPDATED_BY,
                null as INC_JOB_UPDATED_AT,
                null as INC_JOB_ID,
                RECOVERY_INITIATED,
                RECOVERY_DONE,
                RECOVERY_PENDING
           FROM TRANSACTIONAL.MV_CLAIM_REGISTER A
          WHERE     CLM_STATUS = ''''OPEN''''
                AND C_CLAIM_NO IN (SELECT C_CLAIM_NO FROM INTERMEDIATE.WRK_ODS_CLAIM_DIM)'';
   EXECUTE IMMEDIATE v_sqltext;


END IF;


EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\\\\\n'' || ''SQL: '' || ''\\\\\\\\n'' || v_sqltext;

END;
';