CREATE OR REPLACE PROCEDURE TRANSACTIONAL.BJAZ_REFRESH_MV_CLAIM("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
L_START NUMBER;
LAST_REOPEN_DATE DATE;
TP_SETTLED_LOADDATE DATE;
v_CNT NUMBER;
v_sqltext VARCHAR;
v_today_day CHAR(2);
BEGIN

/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
/*----------------------------insert working table for yesterday data  -------------*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MV_CLAIM'';

EXECUTE IMMEDIATE v_sqltext;

-- v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CLAIM
--         SELECT
--               ODS_CLAIM_DIM.C_CLAIM_NO,
--                ODS_CLAIM_DIM.C_CLAIM_ID_SK,
--                C_ACCIDENT_LOC,
--                C_LOSS_TIME,
--                DECODE (ODS_CLAIM_DIM.C_CLAIM_STATUS,
--                        ''''CLOSED'''', ''''CLOSED'''',
--                        ''''OPEN'''')
--                   CLM_STATUS,
--                --dense_rank() over ( partition by c_claim_no order by rownum, cp_company_id_sk desc nulls last ) dr,
--                 -- DECODE (
--                --    DENSE_RANK ()
--                --    OVER (PARTITION BY C_CLAIM_NO
--                --          ORDER BY CP_COMPANY_ID_SK, ROWNUM DESC NULLS LAST),
--                --    1, ''''Y'''',
--                --    ''''N'''')
--                --    TOP_INDICATOR,
--                   DECODE(
--     DENSE_RANK() OVER (PARTITION BY C_CLAIM_NO ORDER BY CP_COMPANY_ID_SK DESC NULLS LAST),
--     1, ''''Y'''',''''N'''') AS TOP_INDICATOR,

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
--                -- DECODE (i_imd_desc,''''DIRECT'''', NVL (DECODE (p_subimd_channel, ''''DIRECT'''', NULL, NULL),i_imd_new_channel),i_imd_new_channel) imd_channel,
--                --               DECODE (I_IMD_DESC,
--                --                  ''''DIRECT'''', NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL),
--                --                  ''''10035203'''', NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL),
--                --                  I_IMD_NEW_CHANNEL)
--                --             IMD_CHANNEL,                    --as discuss with vishal sir
--                CASE
--                   WHEN IMDSUB_IMD_CHANNEL.IMD_LIST IS NOT NULL
--                   THEN
--                      NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL)
--                   ELSE
--                      I_IMD_NEW_CHANNEL
--                END
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
--                        AND ODS_POLICY_DIM.P_POLICY_ISSUE_DATE >= ''''01-apr-2007''''
--                        AND B.P_POLICY_NUMBER IS NOT NULL
--                   ---- and  NVL(ods_motor_od_tp_prem_new.tp_prem,0) <> 0
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
--                NVL (ODS_CLAIM_DIM.C_COURT_FLAG, ''''Normal Claim'''') C_COURT_FLAG,
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
--                SUM (NVL (ODS_CLAIM_FACT_MV.RESERVE_AMOUNT, 0)) RESERVE_AMOUNT,
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
--                PARTNER_DIM_POLICY.PT_PARTNER_PRIVE_FLAG
--           FROM TRANSACTIONAL.ODS_CLAIM_DIM,
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
--                PROD_DWH_MIGRATED_DB.PROD.WRK_RI_SHARE RI_SHARE,
--                INTERMEDIATE.IMDSUB_IMD_CHANNEL
--          WHERE     ODS_POLICY_DIM.P_POLICY_NUMBER = B.P_POLICY_NUMBER(+)
--                AND (ODS_POLICY_DIM.P_POLICY_NO_SK =
--                        ODS_CLAIM_FACT_MV.P_POLICY_NO_SK)
--                AND (ODS_CLAIM_FACT_MV.T_DATE_ID_SK = ODS_TIME_DIM.T_DATE_ID_SK)
--                AND (COMPANY_CODE = CP_COMPANY_ID_SK)
--                AND (ODS_CLAIM_FACT_MV.R_RESERVE_TYPE_ID =
--                        ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK)
--                AND (ODS_POLICY_DIM.P_IMD_ID_SK = ODS_IMD_DIM.I_IMD_ID_SK(+))
--                AND ODS_IMD_DIM.I_IMD_DESC = IMDSUB_IMD_CHANNEL.IMD_LIST(+)
--                AND (ODS_POLICY_DIM.P_PRODUCT_ID = ODS_PRODUCT_DIM.P_PRODUCT_ID)
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
--                AND ODS_TIME_DIM.T_DATE_DESC = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
--                AND ODS_MAKE_DIM.V_VEHICLE_TYPE_CODE =
--                       ODS_VEHICLE_TYPE_DIM.V_VEHICLE_TYPE_CODE(+)
--                AND ODS_POLICY_DIM.P_POLICY_NUMBER = EXTN.POLICY_REF(+)
--       --         and c_claim_no like ''''oc-09-1002-8402-00002336''''
--       --  and  ( ods_time_dim.t_date_desc  >= TO_DATE(''''31-mar-2008''''))
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
--                --ROWNUM,
--                ODS_CLAIM_DIM.C_APP_DATE,
--                ODS_TIME_DIM.T_DATE_DESC,
--                CASE
--                   WHEN IMDSUB_IMD_CHANNEL.IMD_LIST IS NOT NULL
--                   THEN
--                      NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL)
--                   ELSE
--                      I_IMD_NEW_CHANNEL
--                END                        --               DECODE (I_IMD_DESC,
--                   --                  ''''DIRECT'''', NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL),
--                   --                  ''''10035203'''', NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL),
--                   --                  I_IMD_NEW_CHANNEL)
--                , ----changes done by chandrakant(As instructed by vishal patil and priyank sir)
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
--                NVL (ODS_CLAIM_DIM.C_COURT_FLAG, ''''Normal Claim''''),
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

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''Insert into wrk_mv_claim check over - time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*-------------updation on sub-channel code-------------*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--
--
--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''Insert into wrk_mv_claim check over - time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*-------------updation on sub-channel code-------------*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CLAIM
        SELECT
              ODS_CLAIM_DIM.C_CLAIM_NO,
               ODS_CLAIM_DIM.C_CLAIM_ID_SK,
               C_ACCIDENT_LOC,
               C_LOSS_TIME,
               DECODE (ODS_CLAIM_DIM.C_CLAIM_STATUS,
                       ''''CLOSED'''', ''''CLOSED'''',
                       ''''OPEN'''')
                  CLM_STATUS,
               --dense_rank() over ( partition by c_claim_no order by rownum, cp_company_id_sk desc nulls last ) dr,
                -- DECODE (
               --    DENSE_RANK ()
               --    OVER (PARTITION BY C_CLAIM_NO
               --          ORDER BY CP_COMPANY_ID_SK, ROWNUM DESC NULLS LAST),
               --    1, ''''Y'''',
               --    ''''N'''')
               --    TOP_INDICATOR,
    --               DECODE(
    -- DENSE_RANK() OVER (PARTITION BY C_CLAIM_NO ORDER BY CP_COMPANY_ID_SK DESC NULLS LAST),
    -- 1, ''''Y'''',''''N'''') AS TOP_INDICATOR,
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
               -- DECODE (i_imd_desc,''''DIRECT'''', NVL (DECODE (p_subimd_channel, ''''DIRECT'''', NULL, NULL),i_imd_new_channel),i_imd_new_channel) imd_channel,
               --               DECODE (I_IMD_DESC,
               --                  ''''DIRECT'''', NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL),
               --                  ''''10035203'''', NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL),
               --                  I_IMD_NEW_CHANNEL)
               --             IMD_CHANNEL,                    --as discuss with vishal sir
               CASE
                  WHEN IMDSUB_IMD_CHANNEL.IMD_LIST IS NOT NULL
                  THEN
                     NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL)
                  ELSE
                     I_IMD_NEW_CHANNEL
               END
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
                       AND ODS_POLICY_DIM.P_POLICY_ISSUE_DATE >= ''''01-apr-2007''''
                       AND B.P_POLICY_NUMBER IS NOT NULL
                  ---- and  NVL(ods_motor_od_tp_prem_new.tp_prem,0) <> 0
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
               NVL (ODS_CLAIM_DIM.C_COURT_FLAG, ''''Normal Claim'''') C_COURT_FLAG,
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
          FROM TRANSACTIONAL.ODS_CLAIM_DIM,
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
               PROD_DWH_MIGRATED_DB.PROD.WRK_RI_SHARE RI_SHARE,
               PROD_DWH_MIGRATED_DB.PROD.IMDSUB_IMD_CHANNEL
         WHERE     ODS_POLICY_DIM.P_POLICY_NUMBER = B.P_POLICY_NUMBER(+)
               AND (ODS_POLICY_DIM.P_POLICY_NO_SK =
                       ODS_CLAIM_FACT_MV.P_POLICY_NO_SK)
               AND (ODS_CLAIM_FACT_MV.T_DATE_ID_SK = ODS_TIME_DIM.T_DATE_ID_SK)
               AND (COMPANY_CODE = CP_COMPANY_ID_SK)
               AND (ODS_CLAIM_FACT_MV.R_RESERVE_TYPE_ID =
                       ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK)
               AND (ODS_POLICY_DIM.P_IMD_ID_SK = ODS_IMD_DIM.I_IMD_ID_SK(+))
               AND ODS_IMD_DIM.I_IMD_DESC = IMDSUB_IMD_CHANNEL.IMD_LIST(+)
               AND (ODS_POLICY_DIM.P_PRODUCT_ID = ODS_PRODUCT_DIM.P_PRODUCT_ID)
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
                    AND TO_VARCHAR(ODS_MODEL_DIM.M_VEHICLE_SUBTYPE_CODE(+)) =
                           ODS_POLICY_DIM.P_VEHICLE_SUB_TYPE
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
               AND ODS_TIME_DIM.T_DATE_DESC = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
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
               CASE
                  WHEN IMDSUB_IMD_CHANNEL.IMD_LIST IS NOT NULL
                  THEN
                     NVL (P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL)
                  ELSE
                     I_IMD_NEW_CHANNEL
               END,
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
               NVL (ODS_CLAIM_DIM.C_COURT_FLAG, ''''Normal Claim''''),
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
               M_VEHICLE_SUBTYPE'';
      --         and c_claim_no like ''''oc-09-1002-8402-00002336''''
      --  and  ( ods_time_dim.t_date_desc  >= TO_DATE(''''31-mar-2008''''))'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_clm_pol_channel_update'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLM_POL_CHANNEL_UPDATE
         SELECT
               A.P_POLICY_NUMBER, B.P_SUB_CHANNEL_CODE
           FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
		   PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM B
          WHERE     A.P_POLICY_NUMBER = B.P_POLICY_NUMBER
                AND P_CURRENT_INDICATOR = 1
                AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
                AND NVL (A.P_SUB_CHANNEL_CODE, ''''X'''') <>
                       NVL (B.P_SUB_CHANNEL_CODE, ''''X'''')
                -- AND t_date_desc = ''''26-apr-2018''''
                AND TOP_INDICATOR = ''''Y'''''';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
			SET P_SUB_CHANNEL_CODE = src.P_SUB_CHANNEL_CODE,
                CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
				TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(SELECT * FROM INTERMEDIATE.WRK_CLM_POL_CHANNEL_UPDATE) AS src
WHERE target.P_POLICY_NUMBER = src.P_POLICY_NUMBER'';

EXECUTE IMMEDIATE v_sqltext;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''P_SUB_CHANNEL_CODE updation - time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--
--/*------------------update all cases where claim exits in mv_claim_register*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
			SET TOP_INDICATOR = ''''N'''',
            CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(SELECT * FROM INTERMEDIATE.WRK_MV_CLAIM WHERE TOP_INDICATOR = ''''Y'''') AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''Update into mv_claim_register- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


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
             NVL (C_COURT_FLAG, ''''Normal Claim'''') C_COURT_FLAG,
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
             SUM (PAID_CLAIM) PAID_CLAIM,
             SUM (RESERVE_AMOUNT) RESERVE_AMOUNT,
             SUM (OS_AMT) OS_AMT,
             SUM (SALVAGE_AMT) SALVAGE_AMT,
             SUM (SERVICE_TAX) SERVICE_TAX,
             SUM (POOL_SALVAGE_AMT) POOL_SALVAGE_AMT,
             SUM (POOL_PAID_BEFORE_SALVAGE) POOL_PAID_BEFORE_SALVAGE,
             SUM (POOL_PAID_AFTER_SALVAGE) POOL_PAID_AFTER_SALVAGE,
             SUM (NET_PAID) NET_PAID,
             SUM (NET_TAX) NET_TAX,
             --PAID_CLAIM,
             --RESERVE_AMOUNT,
             --OS_AMT,
             --SALVAGE_AMT,
             --SERVICE_TAX,
             --POOL_SALVAGE_AMT,
             --POOL_PAID_BEFORE_SALVAGE,
             --POOL_PAID_AFTER_SALVAGE,
             --NET_PAID,
             --NET_TAX,
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
             --CASE WHEN CESSION_PERC IS NOT NULL THEN ROUND ((  (NVL (PAID_CLAIM, 0) - NVL (SERVICE_TAX, 0)) * NVL ((CESSION_PERC / 100), 1)), 2) ELSE 0 END RI_RETENTION_PAID_AMOUNT,
             --CASE WHEN CESSION_PERC IS NOT NULL THEN ROUND (( (NVL (OS_AMT, 0)) * NVL ( (CESSION_PERC / 100), 1)), 2) ELSE 0 END RI_RETENTION_OS_AMOUNT,
             SUM (CASE WHEN CESSION_PERC IS NOT NULL THEN ROUND ((  (NVL (PAID_CLAIM, 0) - NVL (SERVICE_TAX, 0)) * NVL ((CESSION_PERC / 100), 1)), 2) ELSE 0 END) RI_RETENTION_PAID_AMOUNT,
             SUM (CASE WHEN CESSION_PERC IS NOT NULL THEN ROUND (( (NVL (OS_AMT, 0)) * NVL ( (CESSION_PERC / 100), 1)), 2) ELSE 0 END) RI_RETENTION_OS_AMOUNT,
             NULL,
             TO_DATE('''''' || T_DATE || ''''''),
             PT_PARTNER_PRIVE_FLAG,
             NULL TRANS_TYPE,
			 DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')),
             NULL AS    INC_JOB_CREATED_AT,
             NULL AS 	INC_JOB_CREATED_BY ,
			 NULL AS 	INC_JOB_UPDATED_BY,
             NULL AS 	INC_JOB_UPDATED_AT ,
             NULL AS 	INC_JOB_ID,
             SUM (NVL (RECOVERY_INITIATED, 0)) RECOVERY_INITIATED,
             SUM (NVL (RECOVERY_DONE, 0)) RECOVERY_DONE,
               SUM (NVL (RECOVERY_PENDING, 0)) RECOVERY_PENDING,
               C_OD_TYPE_OF_LOSS,
               C_HHID,
               C_NET_TAX_LABOUR,
               C_NET_TAX_PARTS,
               CR_VEHICLE_SUBTYPE

        FROM INTERMEDIATE.WRK_MV_CLAIM A
        group by C_CLAIM_NO,
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
             NVL (C_COURT_FLAG, ''''Normal Claim''''),
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
             PT_PARTY_CODE,
             CESSION_PERC,
             RI_RETENTION_PERCENTAGE,
             TO_DATE('''''' || T_DATE || ''''''),
             PT_PARTNER_PRIVE_FLAG,
			 DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')),
             C_OD_TYPE_OF_LOSS,
             C_HHID,
             C_NET_TAX_LABOUR,
             C_NET_TAX_PARTS,
             CR_VEHICLE_SUBTYPE
             '';

EXECUTE IMMEDIATE v_sqltext;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''Insert into mv_claim_register- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
            SET CLM_STATUS = src.CLM_STATUS,
                CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
                TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(SELECT
                A.C_CLAIM_NO,
                DECODE(C_CLAIM_STATUS, ''''CLOSED'''', ''''CLOSED'''', ''''OPEN'''') AS CLM_STATUS
           FROM TRANSACTIONAL.ODS_CLAIM_DIM A
           JOIN  TRANSACTIONAL.MV_CLAIM_REGISTER B
           ON A.C_CLAIM_NO = B.C_CLAIM_NO
           WHERE TOP_INDICATOR = ''''Y''''
             AND DECODE(C_CLAIM_STATUS, ''''CLOSED'''', ''''CLOSED'''', ''''OPEN'''') <> B.CLM_STATUS) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER as target
            SET C_CLAIM_TYPE = src.C_CLAIM_TYPE,
                C_CAUSE_OF_LOSS = src.CAUSE_OF_LOSS,
                CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
                TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(SELECT CLAIM_NUMBER, CAUSE_OF_LOSS, ''''TP'''' as C_CLAIM_TYPE FROM
           INTERMEDIATE.WRK_TP_CLP_CLAIMS) AS src
WHERE target.C_CLAIM_NO = src.CLAIM_NUMBER
              AND EXISTS (
                  SELECT 1
                  FROM  INTERMEDIATE.WRK_TP_CLP_CLAIMS
                  WHERE CLAIM_NUMBER = src.CLAIM_NUMBER)'';

EXECUTE IMMEDIATE v_sqltext;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''Insert into mv_claim_register status update- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*--------------------*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

-- commneted due to ETL_REFRESH_AT column added in ODS_CLAIM_DIM
-- v_sqltext := ''DELETE
--          FROM  TRANSACTIONAL.ODS_CLAIM_DIM_HIST A
--          WHERE DATE_TRUNC(''''DAY'''', T_CHANGE_DT) <= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)'';

-- EXECUTE IMMEDIATE v_sqltext;

-- -- let vtext5 := ''''DELETE FROM TRANSACTIONAL.ODS_CLAIM_DIM_HIST
-- --          WHERE ROWID IN (SELECT RID
-- --                            FROM (SELECT ROWID RID,
-- --                                         ROW_NUMBER ()
-- --                                         OVER (PARTITION BY C_CLAIM_NO
-- --                                               ORDER BY C_CLAIM_NO)
-- --                                            RN
-- --                                    FROM TRANSACTIONAL.ODS_CLAIM_DIM_HIST)
-- --                           WHERE RN > 1)'''';
-- -- EXECUTE IMMEDIATE vtext5;

-- v_sqltext := ''INSERT INTO TRANSACTIONAL.DL_ODS_CLAIM_DIM_HIST
--       SELECT *
--         FROM TRANSACTIONAL.ODS_CLAIM_DIM_HIST A'';

-- EXECUTE IMMEDIATE v_sqltext;

-- v_sqltext := ''DELETE
--          FROM  TRANSACTIONAL.DL_ODS_CLAIM_DIM_HIST
--          WHERE DATE_TRUNC (''''DAY'''',T_CHANGE_DT) < DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 7'';

-- EXECUTE IMMEDIATE v_sqltext;

-- --/*CALL LOGTRACE (
-- --      ''''LOG'''',
-- --      10001,
-- --         ''''delete ods_claim_dim_hist- time taken in mins : ''''
-- --      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
-- --      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- --/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


CALL TRANSACTIONAL.WRK_MV_CR_BULK_UPDATE(''BAGIC_PROD_MIRROR_DB'');

--/*CALL LOGTRACE (
--      ''''LOG'''',--
--      10001,
--         ''''mv_claim_register WRK_MV_CR_BULK_UPDATE update 2-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

v_sqltext := ''MERGE INTO TRANSACTIONAL.MV_CLAIM_REGISTER T
        USING (  SELECT
                       CLAIM_NO,
                        COURT_STAGE,
                        HO_ID,
                        MAX (NEXT_COURT_H_DATE) NEXT_COURT_H_DATE
                   FROM PROD_DWH_MIGRATED_DB.PROD.ODS_TP_CLM_DTLS
               --where  claim_id = 1666517
               GROUP BY CLAIM_NO, COURT_STAGE, HO_ID) A
           ON (CLAIM_NO = C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET T.NEXT_COURT_H_DATE = A.NEXT_COURT_H_DATE,
                 T.COURT_STAGE = A.COURT_STAGE,
                 T.HO_ID = A.HO_ID,
                 CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
                 TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))'';

EXECUTE IMMEDIATE v_sqltext;

--/*---------------ADDED BY CHANDRAKANT------------------*/
--
--/*   BEGIN*/
--/*      MERGE INTO MV_CLAIM_REGISTER T*/
--/*           USING (SELECT PT_PARTNER_ID, PT_MAXI_PID, PT_PARTNER_PRIVE_FLAG*/
--/*                    FROM ODS_PARTNER_DIM*/
--/*                   WHERE     PT_PARTNER_PRIVE_FLAG IS NOT NULL*/
--/*                         AND PT_CURRENT_INDICATOR(+) = 1*/
--/*                         AND DATE_TRUNC(''''DAY'''', PT_PARTNER_CHANGE_DATE) >=*/
--/*                                DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1) A*/
--/*              ON (PT_PARTY_CODE = PT_MAXI_PID AND T_DATE_DESC >= ''''1-APR-2024'''')*/
--/*      WHEN MATCHED*/
--/*      THEN*/
--/*         UPDATE SET*/
--/*            T.PT_PARTNER_PRIVE_FLAG = A.PT_PARTNER_PRIVE_FLAG,*/
--/*            CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),*/
--/*            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''));*/
--/**/
--/*      */
--/*   END;*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--/*   ----added by chandrakant 23-may-2020----*/
--/*   DECLARE*/
--/*      CURSOR C*/
--/*      IS*/
--/*           SELECT C_CLAIM_NO, SUM (TOTAL_PARTS_LABOURS) TOTAL_PARTS_LABOURS*/
--/*             FROM BJAZ_CLM_SUPP_BASES_MV, MV_CLAIM_REGISTER*/
--/*            WHERE     CLAIM_ID = C_CLAIM_ID*/
--/*                  AND TOP_INDICATOR = ''''Y''''*/
--/*                  AND T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)*/
--/*                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)*/
--/*         GROUP BY C_CLAIM_NO*/
--/*           HAVING SUM (TOTAL_PARTS_LABOURS) IS NOT NULL;*/
--/**/
--/*      TYPE TAB IS TABLE OF C%ROWTYPE;*/
--/**/
--/*      V_TAB   TAB;*/
--/*   BEGIN*/
--/*      OPEN C;*/
--/**/
--/*      LOOP*/
--/*         FETCH C*/
--/*         BULK COLLECT INTO V_TAB*/
--/*         LIMIT 10000;*/
--/**/
--/*         FORALL I IN V_TAB.FIRST .. V_TAB.LAST*/
--/*            UPDATE MV_CLAIM_REGISTER A*/
--/*               SET NET_ASSESSED_AMOUNT = V_TAB (I).TOTAL_PARTS_LABOURS,*/
--/*                   CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''')*/
--/*             WHERE A.C_CLAIM_NO = V_TAB (I).C_CLAIM_NO;*/
--/**/
--/*         */
--/*         EXIT WHEN C%NOTFOUND;*/
--/*      END_LOOP;*/
--/**/
--/*      CLOSE C;*/
--/*   END;*/
--/**/
--/*   DECLARE*/
--/*      CURSOR C*/
--/*      IS*/
--/*           SELECT */
--/*                 C_CLAIM_NO, SUM (DEPRECIATION_AMT) DEPRECIATION_AMT*/
--/*             FROM STAGE.BJAZ_CLM_SUPP_BILL_PARTS_MV X, MV_CLAIM_REGISTER Z*/
--/*            WHERE     X.CLAIM_ID = Z.C_CLAIM_ID*/
--/*                  AND T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)*/
--/*                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)*/
--/*                  AND TOP_INDICATOR = ''''Y''''*/
--/*         GROUP BY C_CLAIM_NO;*/
--/**/
--/*      TYPE TAB IS TABLE OF C%ROWTYPE;*/
--/**/
--/*      V_TAB   TAB;*/
--/*   BEGIN*/
--/*      OPEN C;*/
--/**/
--/*      LOOP*/
--/*         FETCH C*/
--/*         BULK COLLECT INTO V_TAB*/
--/*         LIMIT 10000;*/
--/**/
--/*         FORALL I IN V_TAB.FIRST .. V_TAB.LAST*/
--/*            UPDATE MV_CLAIM_REGISTER A*/
--/*               SET DEPRECIATION_AMOUNT = V_TAB (I).DEPRECIATION_AMT,*/
--/*                   CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''')*/
--/*             WHERE A.C_CLAIM_NO = V_TAB (I).C_CLAIM_NO;*/
--/**/
--/*         */
--/*         EXIT WHEN C%NOTFOUND;*/
--/*      END_LOOP;*/
--/**/
--/*      CLOSE C;*/
--/*   END;*/
--/**/
--/*   */
--/**/
--/*   BEGIN*/
--/*      MERGE INTO MV_CLAIM_REGISTER A*/
--/*           USING (SELECT C_CLAIM_NO CLM_REF,*/
--/*                         NET_ASSES_AMT_PARTS_LABOUR,*/
--/*                         DEP_AMT*/
--/*                    FROM BJAZ_SURVEYOR_ASS_DTLS X, MV_CLAIM_REGISTER Y*/
--/*                   WHERE     Y.C_CLAIM_ID = X.CLAIM_ID*/
--/*                         AND TOP_INDICATOR = ''''Y''''*/
--/*                         AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3) B*/
--/*              ON (A.C_CLAIM_NO = B.CLM_REF)*/
--/*      WHEN MATCHED*/
--/*      THEN*/
--/*         UPDATE SET*/
--/*            A.NET_ASSESSED_AMOUNT = TO_NUMBER (B.NET_ASSES_AMT_PARTS_LABOUR),*/
--/*            A.DEPRECIATION_AMOUNT = TO_NUMBER (B.DEP_AMT),*/
--/*            CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''');*/
--/**/
--/*      */
--/*   END;*/
--/**/
--/*   ----------------------added chandrakant (14-nov-2019) -------------------------------------*/
--/**/
--/*   BEGIN*/
--/*      FOR I*/
--/*         IN (SELECT DISTINCT*/
--/*                    C_CLAIM_NO, NET_ASSESSED_AMOUNT, DEPRECIATION_AMOUNT*/
--/*               FROM MV_CLAIM_REGISTER*/
--/*              WHERE     T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)*/
--/*                                        AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)*/
--/*                    AND TOP_INDICATOR = ''''Y''''*/
--/*                    AND (   NET_ASSESSED_AMOUNT IS NOT NULL*/
--/*                         OR DEPRECIATION_AMOUNT IS NOT NULL))*/
--/*      LOOP*/
--/*         UPDATE ODS_CLAIM_DIM*/
--/*            SET NET_ASSESSED_AMOUNT = I.NET_ASSESSED_AMOUNT,*/
--/*                DEPRECIATION_AMOUNT = I.DEPRECIATION_AMOUNT*/
--/*          WHERE C_CLAIM_NO = I.C_CLAIM_NO;*/
--/**/
--/*         */
--/*      END_LOOP;*/
--/*   END;*/
--
--/*---------------ADDED BY CHANDRAKANT------------------*/
--/*   BEGIN*/
--/*      MERGE INTO MV_CLAIM_REGISTER T*/
--/*           USING (SELECT PT_PARTNER_ID, PT_MAXI_PID, PT_PARTNER_PRIVE_FLAG*/
--/*                    FROM ODS_PARTNER_DIM*/
--/*                   WHERE     PT_PARTNER_PRIVE_FLAG IS NOT NULL*/
--/*                         AND PT_CURRENT_INDICATOR(+) = 1*/
--/*                         AND DATE_TRUNC(''''DAY'''', PT_PARTNER_CHANGE_DATE) >=*/
--/*                                DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1) A*/
--/*              ON (PT_PARTY_CODE = PT_MAXI_PID AND T_DATE_DESC >= ''''1-APR-2024'''')*/
--/*      WHEN MATCHED*/
--/*      THEN*/
--/*         UPDATE SET*/
--/*            T.PT_PARTNER_PRIVE_FLAG = A.PT_PARTNER_PRIVE_FLAG,*/
--/*            CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),*/
--/*            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''));*/
--/**/
--/*      */
--/*   END;*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--/*   ----added by chandrakant 23-may-2020----*/
--/*   DECLARE*/
--/*      CURSOR C*/
--/*      IS*/
--/*           SELECT C_CLAIM_NO, SUM (TOTAL_PARTS_LABOURS) TOTAL_PARTS_LABOURS*/
--/*             FROM BJAZ_CLM_SUPP_BASES_MV, MV_CLAIM_REGISTER*/
--/*            WHERE     CLAIM_ID = C_CLAIM_ID*/
--/*                  AND TOP_INDICATOR = ''''Y''''*/
--/*                  AND T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)*/
--/*                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)*/
--/*         GROUP BY C_CLAIM_NO*/
--/*           HAVING SUM (TOTAL_PARTS_LABOURS) IS NOT NULL;*/
--/**/
--/*      TYPE TAB IS TABLE OF C%ROWTYPE;*/
--/**/
--/*      V_TAB   TAB;*/
--/*   BEGIN*/
--/*      OPEN C;*/
--/**/
--/*      LOOP*/
--/*         FETCH C*/
--/*         BULK COLLECT INTO V_TAB*/
--/*         LIMIT 10000;*/
--/**/
--/*         FORALL I IN V_TAB.FIRST .. V_TAB.LAST*/
--/*            UPDATE MV_CLAIM_REGISTER A*/
--/*               SET NET_ASSESSED_AMOUNT = V_TAB (I).TOTAL_PARTS_LABOURS,*/
--/*                   CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''')*/
--/*             WHERE A.C_CLAIM_NO = V_TAB (I).C_CLAIM_NO;*/
--/**/
--/*         */
--/*         EXIT WHEN C%NOTFOUND;*/
--/*      END_LOOP;*/
--/**/
--/*      CLOSE C;*/
--/*   END;*/
--/**/
--/*   DECLARE*/
--/*      CURSOR C*/
--/*      IS*/
--/*           SELECT */
--/*                 C_CLAIM_NO, SUM (DEPRECIATION_AMT) DEPRECIATION_AMT*/
--/*             FROM STAGE.BJAZ_CLM_SUPP_BILL_PARTS_MV X, MV_CLAIM_REGISTER Z*/
--/*            WHERE     X.CLAIM_ID = Z.C_CLAIM_ID*/
--/*                  AND T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)*/
--/*                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)*/
--/*                  AND TOP_INDICATOR = ''''Y''''*/
--/*         GROUP BY C_CLAIM_NO;*/
--/**/
--/*      TYPE TAB IS TABLE OF C%ROWTYPE;*/
--/**/
--/*      V_TAB   TAB;*/
--/*   BEGIN*/
--/*      OPEN C;*/
--/**/
--/*      LOOP*/
--/*         FETCH C*/
--/*         BULK COLLECT INTO V_TAB*/
--/*         LIMIT 10000;*/
--/**/
--/*         FORALL I IN V_TAB.FIRST .. V_TAB.LAST*/
--/*            UPDATE MV_CLAIM_REGISTER A*/
--/*               SET DEPRECIATION_AMOUNT = V_TAB (I).DEPRECIATION_AMT,*/
--/*                   CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''')*/
--/*             WHERE A.C_CLAIM_NO = V_TAB (I).C_CLAIM_NO;*/
--/**/
--/*         */
--/*         EXIT WHEN C%NOTFOUND;*/
--/*      END_LOOP;*/
--/**/
--/*      CLOSE C;*/
--/*   END;*/
--/**/
--/*   */
--/**/
--/*   BEGIN*/
--/*      MERGE INTO MV_CLAIM_REGISTER A*/
--/*           USING (SELECT C_CLAIM_NO CLM_REF,*/
--/*                         NET_ASSES_AMT_PARTS_LABOUR,*/
--/*                         DEP_AMT*/
--/*                    FROM BJAZ_SURVEYOR_ASS_DTLS X, MV_CLAIM_REGISTER Y*/
--/*                   WHERE     Y.C_CLAIM_ID = X.CLAIM_ID*/
--/*                         AND TOP_INDICATOR = ''''Y''''*/
--/*                         AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3) B*/
--/*              ON (A.C_CLAIM_NO = B.CLM_REF)*/
--/*      WHEN MATCHED*/
--/*      THEN*/
--/*         UPDATE SET*/
--/*            A.NET_ASSESSED_AMOUNT = TO_NUMBER (B.NET_ASSES_AMT_PARTS_LABOUR),*/
--/*            A.DEPRECIATION_AMOUNT = TO_NUMBER (B.DEP_AMT),*/
--/*            CHANGE_DATE = TO_DATE('''''' || T_DATE || '''''');*/
--/**/
--/*      */
--/*   END;*/
--/**/
--/*   ----------------------added chandrakant (14-nov-2019) -------------------------------------*/
--/**/
--/*   BEGIN*/
--/*      FOR I*/
--/*         IN (SELECT DISTINCT*/
--/*                    C_CLAIM_NO, NET_ASSESSED_AMOUNT, DEPRECIATION_AMOUNT*/
--/*               FROM TRANSACTIONAL.MV_CLAIM_REGISTER*/
--/*              WHERE     T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)*/
--/*                                        AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)*/
--/*                    AND TOP_INDICATOR = ''''Y''''*/
--/*                    AND (   NET_ASSESSED_AMOUNT IS NOT NULL*/
--/*                         OR DEPRECIATION_AMOUNT IS NOT NULL))*/
--/*      LOOP*/
--/*         UPDATE ODS_CLAIM_DIM*/
--/*            SET NET_ASSESSED_AMOUNT = I.NET_ASSESSED_AMOUNT,*/
--/*                DEPRECIATION_AMOUNT = I.DEPRECIATION_AMOUNT*/
--/*          WHERE C_CLAIM_NO = I.C_CLAIM_NO;*/
--/**/
--/*         */
--/*      END_LOOP;*/
--/*   END;*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_UPDATE_POLICY_STATUS'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_UPDATE_POLICY_STATUS
           SELECT
                 P_POLICY_NUMBER
             FROM TRANSACTIONAL.MV_CLAIM_REGISTER A
            WHERE P_POLICY_NUMBER IN
                     (SELECT DISTINCT P_POLICY_NUMBER
                        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
                       WHERE     T_DATE_DESC = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                             AND TOP_INDICATOR = ''''Y'''')
         GROUP BY P_POLICY_NUMBER
           HAVING COUNT (DISTINCT P_POLICY_STATUS) > 1'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
        SET P_POLICY_STATUS = src.P_POLICY_STATUS,
            CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(SELECT A.P_POLICY_NUMBER, P_POLICY_STATUS
        FROM  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM A
        JOIN INTERMEDIATE.WRK_UPDATE_POLICY_STATUS B ON A.P_POLICY_NUMBER = B.P_POLICY_NUMBER) as src
WHERE target.P_POLICY_NUMBER = src.P_POLICY_NUMBER'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_clm_type'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLM_TYPE
      SELECT
            C_CLAIM_NO, CLM_TYPE, C_CLAIM_TYPE
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
		TRANSACTIONAL.MV_CLAIM_REGISTER C
       WHERE     A.CLAIM_ID = C.C_CLAIM_ID
             AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
             AND TOP_INDICATOR = ''''Y''''
             AND NVL (CLM_TYPE, ''''OD'''') <> NVL (C_CLAIM_TYPE, ''''OD'''')
             AND CLM_TYPE IN (''''OD'''', ''''TP'''')'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLM_TYPE
        SELECT CLM_REF, CLAIM_TYPE, C_CLAIM_TYPE
          FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HUB_CLM_TRANS_DTLS A,
		  TRANSACTIONAL.ODS_CLAIM_DIM B
         WHERE     CLM_REF = C_CLAIM_NO
               AND DATE_TRUNC(''''DAY'''', RECORD_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
               AND NVL (CLAIM_TYPE, ''''ABC'''') <> NVL (C_CLAIM_TYPE, ''''ABC'''')
      GROUP BY CLM_REF, CLAIM_TYPE, C_CLAIM_TYPE'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
		SET C_CLAIM_TYPE = src.CLM_TYPE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(SELECT * FROM INTERMEDIATE.WRK_CLM_TYPE) as src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET C_CLAIM_TYPE = src.CLM_TYPE,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM (SELECT * FROM INTERMEDIATE.WRK_CLM_TYPE) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''net_access_amt and depreciation update 2.2-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--/*-added by chandrakant on 15th jul 2020*/


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_inv_name_update_stg'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_INV_NAME_UPDATE_STG
         SELECT CLM_REF, B.CLAIM_ID
           FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B, TRANSACTIONAL.ODS_CLAIM_DIM C
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND CLM_REF = C_CLAIM_NO
                AND STATUS_MSG LIKE ''''Investigator Deputed%''''
                AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
                AND C_NAME_OF_IN1 IS NULL
         UNION
         SELECT CLM_REF, B.CLAIM_ID
           FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                TRANSACTIONAL.MV_CLAIM_REGISTER C
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND CLM_REF = C_CLAIM_NO
                AND STATUS_MSG LIKE ''''Investigator Deputed%''''
                AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
                AND C_NAME_OF_IN1 IS NULL'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_inv_name_update'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_INV_NAME_UPDATE
         SELECT CLM_REF,
                CASE
                   WHEN PARTNER_TYPE = ''''I'''' THEN INSTITUTION_NAME
                   ----ELSE FIRST_NAME || '''' '''' || MIDDLE_NAME || '''' '''' || SURNAME
                   ELSE COALESCE(FIRST_NAME, '''''''') || '''' '''' || COALESCE(MIDDLE_NAME, '''''''') || '''' '''' || COALESCE(SURNAME, '''''''')
                END
                   PARTNER_NAME
           FROM INTERMEDIATE.WRK_INV_NAME_UPDATE_STG A,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES B,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CP_PARTNERS D
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND B.PART_ID = D.PART_ID
                AND IP_TYPE LIKE ''''INV%''''
                AND IP_NO IN
                       (SELECT MAX (IP_NO)
                          FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES X
                         WHERE     A.CLAIM_ID = X.CLAIM_ID
                               AND IP_TYPE LIKE ''''INV%'''')'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM AS target
SET C_NAME_OF_IN1 = src.PARTNER_NAME, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT * FROM INTERMEDIATE.WRK_INV_NAME_UPDATE) AS src
WHERE target.C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET C_NAME_OF_IN1 = src.PARTNER_NAME,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM (SELECT * FROM INTERMEDIATE.WRK_INV_NAME_UPDATE) AS src
WHERE target.C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_INV_NAME_UPDATE_1'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_INV_NAME_UPDATE_1
         SELECT CLM_REF,
                CASE
                   WHEN PARTNER_TYPE = ''''I'''' THEN INSTITUTION_NAME
                   -- ELSE FIRST_NAME || '''' '''' || MIDDLE_NAME || '''' '''' || SURNAME
                   ELSE COALESCE(FIRST_NAME, '''''''') || '''' '''' || COALESCE(MIDDLE_NAME, '''''''') || '''' '''' || COALESCE(SURNAME, '''''''')
                END
                   PAARTNER_NAME
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES A,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                TRANSACTIONAL.MV_CLAIM_REGISTER C,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CP_PARTNERS D
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND CLM_REF = C_CLAIM_NO
                AND A.PART_ID = D.PART_ID
                AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
                AND TOP_INDICATOR = ''''Y''''
                AND IP_TYPE LIKE ''''INV%''''
                AND IP_NO IN
                       (SELECT MAX (IP_NO)
                          FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES X
                         WHERE     A.CLAIM_ID = X.CLAIM_ID
                               AND IP_TYPE LIKE ''''INV%'''')
                AND C_NAME_OF_IN1 IS NULL'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM AS target
SET C_NAME_OF_IN1 = src.PARTNER_NAME, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT * FROM INTERMEDIATE.WRK_INV_NAME_UPDATE_1) AS src
WHERE target.C_CLAIM_NO = src.CLM_REF'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET C_NAME_OF_IN1 = src.PARTNER_NAME,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM (SELECT * FROM INTERMEDIATE.WRK_INV_NAME_UPDATE_1) AS src
WHERE target.C_CLAIM_NO = src.CLM_REF'';

EXECUTE IMMEDIATE v_sqltext;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''c_name_of_in1 update 2.2-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*ADDED BY CHANDRAKANT AS PER ASAWARI MAIL 29-DEC-2020*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--
--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''c_name_of_in1 update 2.2-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*ADDED BY CHANDRAKANT AS PER ASAWARI MAIL 29-DEC-2020*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET P_REGN_NO = src.VEHICLE_REG_NUMBER,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM (
 SELECT
			   D.C_CLAIM_NO,
				D.P_REGN_NO,
				CASE
				   WHEN NVL (A.REGISTRATION_NO, ''''NEW'''') = ''''NEW''''
				   THEN
					  NVL (V.VEHICLE_REG_NO, ''''NEW'''')
				   ELSE
					  NVL (A.REGISTRATION_NO, ''''NEW'''')
				END
				   VEHICLE_REG_NUMBER
		   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_DTLS A,
				''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_EXTN V,
				''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES B,
				''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C,
				TRANSACTIONAL.MV_CLAIM_REGISTER D
		  WHERE     A.VEHICLE_ID(+) = V.VEHICLE_ID
				AND V.CONTRACT_ID = B.CONTRACT_ID
				AND B.CLAIM_ID = C.CLAIM_ID
				AND A.VEHICLE_VERSION(+) = V.VEHICLE_VERSION
				AND V.TOP_INDICATOR = ''''Y''''
				AND D.TOP_INDICATOR = ''''Y''''
				AND C.CLM_REF = D.C_CLAIM_NO
				AND D.P_REGN_NO <>
					   CASE
						  WHEN NVL (A.REGISTRATION_NO, ''''NEW'''') = ''''NEW''''
						  THEN
							 NVL (V.VEHICLE_REG_NO, ''''NEW'''')
						  ELSE
							 NVL (A.REGISTRATION_NO, ''''NEW'''')
					   END
				AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLP_HANDLING_LOC'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLP_HANDLING_LOC
SELECT TO_CHAR(CLAIM_NUMBER) AS CLAIM_NUMBER,
SUBSTR(BRANCH_ID, 1, 4) AS BRANCH_ID
FROM BAGIC_PROD_MIRROR_DB.CLP.CLAIM_DETAILS --CHANGES DONE BY RIZWAN ON 09TH SEPT 2025
WHERE NOT SUBSTR(BRANCH_ID, 1, 4) IS NULL'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER AS target
SET TP_CLM_HANDLING_LOC = src.BRANCH_ID,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM (SELECT * FROM  INTERMEDIATE.WRK_CLP_HANDLING_LOC) AS src
WHERE target.C_CLAIM_NO = src.CLAIM_NUMBER'';

EXECUTE IMMEDIATE v_sqltext;

--/* EXCEPTION
--      WHEN OTHERS
--      THEN */
--/*CALL LOGTRACE (
--            ''''ERR'''',
--            10001,
--               ''''Error in TP_CLM_HANDLING_LOC: ''''
--            || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE ()
--            || SQLCODE
--            || SQLERRM,
--            ''''JOB_RUN_CLAIM'''');*/
--
--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''P_REGN_NO-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/



CALL TRANSACTIONAL.WRK_MISSING_SUR_REP_TYPE(''BAGIC_PROD_MIRROR_DB'');


--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         '''' MISSING_SUR_REP_TYPE-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--
--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         '''' MISSING_SUR_REP_TYPE-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_SETTLEMNT_TYPE_UPDATE'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT /*+append*/
            INTO  INTERMEDIATE.WRK_SETTLEMNT_TYPE_UPDATE
         SELECT
               C_CLAIM_NO, C_SETTLEMNT_TYPE, SETTLEMENT_TYPE
           FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C
          WHERE     A.C_CLAIM_NO = CLM_REF
                AND B.CLAIM_ID = C.CLAIM_ID
                AND NVL (C_SETTLEMNT_TYPE, ''''ABC'''') <>
                       NVL (SETTLEMENT_TYPE, ''''ABC'''')
                AND A.TOP_INDICATOR = ''''Y''''
                AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 10
                AND P_DEPARTMENT_DESC = ''''MOTOR''''
                AND NVL (C_CLAIM_TYPE, ''''OD'''') IN (''''OD'''', ''''PA'''', ''''LT'''')'';


EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET C_SETTLEMNT_TYPE = src.SETTLEMENT_TYPE,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_SETTLEMNT_TYPE_UPDATE
) as src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--
--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''C_SETTLEMNT_TYPE-- time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/

 BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.MV_CLAIM_REGISTER A
           USING (SELECT DISTINCT C_CLAIM_NO, C_RECPT_PSR_DATE, C_RECPT_FSR_DATE
                    FROM TRANSACTIONAL.ODS_CLAIM_DIM
                   WHERE     (   C_RECPT_PSR_DATE IS NOT NULL
                              OR C_RECPT_FSR_DATE IS NOT NULL)
                         AND C_CLO_DATE BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) B
              ON (A.C_CLAIM_NO = B.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET A.C_RECPT_PSR_DATE = B.C_RECPT_PSR_DATE,
                    A.C_RECPT_FSR_DATE = B.C_RECPT_FSR_DATE,
                    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
                    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))'';
EXECUTE IMMEDIATE v_sqltext;
END;

-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''C_SETTLEMNT_TYPE-- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/

BEGIN
v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_SUM_INSURED_UPDATE'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_SUM_INSURED_UPDATE
           SELECT C_CLAIM_NO, P_POLICY_NUMBER, SUM_INSURED
             FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
             ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_POLICY_SUMMARY B
            WHERE     P_POLICY_NUMBER = POLICY_REF
                  AND NVL (BASE_SUM_INSURED, 0) = 0
                  AND NVL (SUM_INSURED, 0) <> 0
                  AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
         GROUP BY P_POLICY_NUMBER, C_CLAIM_NO, SUM_INSURED'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET BASE_SUM_INSURED = src.SUM_INSURED,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_SUM_INSURED_UPDATE
) as src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET BASE_SUM_INSURED = src.SUM_INSURED, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_SUM_INSURED_UPDATE
) as src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_SUM_INSURED_UPDATE'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_SUM_INSURED_UPDATE
           SELECT C_CLAIM_NO, X.P_POLICY_NUMBER, SUM_INSURED
             FROM TRANSACTIONAL.MV_CLAIM_REGISTER X,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM A,
                  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_PREMIUM_FACT B
            WHERE     X.P_POLICY_NUMBER = A.P_POLICY_NUMBER
                  AND A.P_POLICY_NO_SK = B.P_POLICY_NO_SK
                  AND VERSION NOT LIKE ''''E%''''
                  AND CP_COMPANY_ID_SK = 1
                  AND A.P_CURRENT_INDICATOR = 1
                  AND BASE_SUM_INSURED IS NULL
                  AND X.T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                  AND NVL (SUM_INSURED, 0) <> 0
         GROUP BY X.P_POLICY_NUMBER, SUM_INSURED, C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET BASE_SUM_INSURED = src.SUM_INSURED,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_SUM_INSURED_UPDATE
) as src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET BASE_SUM_INSURED = src.SUM_INSURED, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_SUM_INSURED_UPDATE
) as src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;


END;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_NM_PORTAL_FLAG'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NM_PORTAL_FLAG
         SELECT CLM_REF,
                CASE
                   WHEN UPPER (USER_NAME) = ''''BAGIC_WEBSITE''''
                   THEN
                      ''''BAGIC_WEBSITE''''
                   WHEN UPPER (USER_NAME) = ''''BAGIC_NMCMRN_PORTAL''''
                   THEN
                      ''''BAGIC_NMCMRN_PORTAL''''
                   WHEN UPPER (USER_NAME) = ''''CARINGLY YOURS''''
                   THEN
                      ''''CARINGLY_YOURS''''
                   WHEN UPPER (USER_NAME) = ''''ONLINE''''
                   THEN
                      ''''ONLINE''''
                   WHEN UPPER (USER_NAME) LIKE ''''REINSURANCE%''''
                   THEN
                      ''''BAGIC_REINSURANCE_DEPT''''
                   WHEN UPPER (USER_NAME) = ''''BAL_MARINE''''
                   THEN
                      ''''BAL_MARINE''''
                   WHEN UPPER (STATUS_MSG) LIKE ''''%LOADER%''''
                   THEN
                      ''''NM_CLAIMS_ LOADER''''
                   WHEN UPPER (STATUS_MSG) LIKE ''''%RCS%''''
                   THEN
                      ''''UDYAMSEVA_BAJAJALLIANZ''''
                   WHEN UPPER (USER_NAME) = ''''BAGIC_FLIPKART''''
                   THEN
                      ''''BAGIC_FLIPKART''''
                   WHEN UPPER (USER_NAME) = ''''BAGIC_AUTO_MRNP''''
                   THEN
                      ''''BAGIC_AUTO_MRNP''''
                   WHEN UPPER (USER_NAME) = ''''BAGIC_WEB_API_RE''''
                   THEN
                      ''''BAGIC_WEB_API_RE''''
                   WHEN UPPER (USER_NAME) = ''''BAGIC_LOADER_OPUS''''
                   THEN
                      ''''BAGIC_LOADER_OPUS''''
                   WHEN UPPER (USER_NAME) = ''''BAGIC_MANUAL_OPUS''''
                   THEN
                      ''''BAGIC_MANUAL_OPUS''''
                   WHEN UPPER (USER_NAME) = ''''YELLOW VOICE BOT''''
                   THEN
                      ''''YELLOW VOICE BOT''''
                END
                   PORTAL_FLAG
           FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                TRANSACTIONAL.MV_CLAIM_REGISTER C,
                INTERMEDIATE.WRK_NM_PRODUCT_LIST D
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND CLM_REF = C_CLAIM_NO
                AND TOP_INDICATOR = ''''Y''''
                AND (   UPPER (USER_NAME) IN
                           (''''BAGIC_WEBSITE'''',
                            ''''BAGIC_NMCMRN_PORTAL'''',
                            ''''CARINGLY YOURS'''',
                            ''''ONLINE'''',
                            ''''BAL_MARINE'''',
                            ''''BAGIC_FLIPKART'''',
                            ''''BAGIC_AUTO_MRNP'''',
                            ''''BAGIC_WEB_API_RE'''',
                            ''''BAGIC_LOADER_OPUS'''',
                            ''''BAGIC_MANUAL_OPUS'''',
                            ''''YELLOW VOICE BOT'''')
                     OR UPPER (USER_NAME) LIKE ''''REINSURANCE%''''
                     OR UPPER (STATUS_MSG) LIKE ''''%LOADER%''''
                     OR UPPER (STATUS_MSG) LIKE ''''%RCS%'''')
                AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 7
                AND VERSION_NO = 1
                AND CASE
                       WHEN UPPER (USER_NAME) = ''''BAGIC_WEBSITE''''
                       THEN
                          ''''BAGIC_WEBSITE''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_NMCMRN_PORTAL''''
                       THEN
                          ''''BAGIC_NMCMRN_PORTAL''''
                       WHEN UPPER (USER_NAME) = ''''CARINGLY YOURS''''
                       THEN
                          ''''CARINGLY_YOURS''''
                       WHEN UPPER (USER_NAME) = ''''ONLINE''''
                       THEN
                          ''''ONLINE''''
                       WHEN UPPER (USER_NAME) LIKE ''''REINSURANCE%''''
                       THEN
                          ''''BAGIC_REINSURANCE_DEPT''''
                       WHEN UPPER (USER_NAME) = ''''BAL_MARINE''''
                       THEN
                          ''''BAL_MARINE''''
                       WHEN UPPER (STATUS_MSG) LIKE ''''%LOADER%''''
                       THEN
                          ''''NM_CLAIMS_ LOADER''''
                       WHEN UPPER (STATUS_MSG) LIKE ''''%RCS%''''
                       THEN
                          ''''UDYAMSEVA_BAJAJALLIANZ''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_FLIPKART''''
                       THEN
                          ''''BAGIC_FLIPKART''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_AUTO_MRNP''''
                       THEN
                          ''''BAGIC_AUTO_MRNP''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_WEB_API_RE''''
                       THEN
                          ''''BAGIC_WEB_API_RE''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_LOADER_OPUS''''
                       THEN
                          ''''BAGIC_LOADER_OPUS''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_MANUAL_OPUS''''
                       THEN
                          ''''BAGIC_MANUAL_OPUS''''
                       WHEN UPPER (USER_NAME) = ''''YELLOW VOICE BOT''''
                       THEN
                          ''''YELLOW VOICE BOT''''
                    END <> NVL (C_PORTAL_FLAG, ''''NEW'''')
                AND C.P_PRODUCT_ID = D.P_PRODUCT_ID'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET C_PORTAL_FLAG = src.PORTAL_FLAG,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_NM_PORTAL_FLAG
) as src
WHERE target.C_CLAIM_NO = src.CLM_REF'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET C_PORTAL_FLAG = src.PORTAL_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_NM_PORTAL_FLAG
) as src
WHERE target.C_CLAIM_NO = src.CLM_REF'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_NM_PORTAL_FLAG1'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NM_PORTAL_FLAG1
         SELECT B.CLM_REF,
                CASE
                   WHEN ASSIGNEE LIKE ''''%@royalenfield.com%''''
                   THEN
                      ''''WEB_API_ROYALENFILED''''
                   WHEN ASSIGNEE LIKE ''''%@chetak-india.com%''''
                   THEN
                      ''''WEB_API_CHETAK-INDIA''''
                   WHEN ASSIGNEE LIKE ''''%@bajajauto.co.in%''''
                   THEN
                      ''''WEB_API_BAJAJAUTO''''
                   WHEN ASSIGNEE LIKE ''''%@baldealer.com%''''
                   THEN
                      ''''WEB_API_BALDEALER''''
                   ELSE
                      ''''WEB_API''''
                END
                   PORTAL_FLAG
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
           TRANSACTIONAL.MV_CLAIM_REGISTER C
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND B.CLM_REF = C_CLAIM_NO
                AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                AND CASE
                       WHEN ASSIGNEE LIKE ''''%@royalenfield.com%''''
                       THEN
                          ''''WEB_API_ROYALENFILED''''
                       WHEN ASSIGNEE LIKE ''''%@chetak-india.com%''''
                       THEN
                          ''''WEB_API_CHETAK-INDIA''''
                       WHEN ASSIGNEE LIKE ''''%@bajajauto.co.in%''''
                       THEN
                          ''''WEB_API_BAJAJAUTO''''
                       WHEN ASSIGNEE LIKE ''''%@baldealer.com%''''
                       THEN
                          ''''WEB_API_BALDEALER''''
                       ELSE
                          ''''WEB_API''''
                    END <> C_PORTAL_FLAG
                AND TOP_INDICATOR = ''''Y''''
                AND EXISTS
                       (SELECT 1
                          FROM PROD_DWH_MIGRATED_DB.STAGE.BJAZ_CLM_MRN_BAL_WS_MV D
                         WHERE CLM_REF IS NOT NULL AND B.CLM_REF = D.CLM_REF)'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET C_PORTAL_FLAG = src.PORTAL_FLAG,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_NM_PORTAL_FLAG1
) as src
WHERE target.C_CLAIM_NO = src.CLM_REF'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET C_PORTAL_FLAG = src.PORTAL_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_NM_PORTAL_FLAG1
) as src
WHERE target.C_CLAIM_NO = src.CLM_REF'';

EXECUTE IMMEDIATE v_sqltext;


-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''Total Time  base sum insured Updation- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP);*/





CALL TRANSACTIONAL.WRK_PORTAL_FLAG_BACK_UPDATE(''BAGIC_PROD_MIRROR_DB'');




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''motor portal flag  Updation- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/






CALL TRANSACTIONAL.WRK_UPDATE_DUPLICATE_DETAIL(''BAGIC_PROD_MIRROR_DB'');




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''update duplicate policy detail-- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/





CALL TRANSACTIONAL.WRK_UPDATE_CAUSE_OF_LOSS_CODE(''BAGIC_PROD_MIRROR_DB'');

CALL TRANSACTIONAL.WRK_RFA_DETAIL_UPDATE(''BAGIC_PROD_MIRROR_DB'');




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''update cause of loss code for nm product code-- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/




CALL TRANSACTIONAL.WRK_PAYMENT_STATUS_UPDATE(''BAGIC_PROD_MIRROR_DB'');



-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''update payment status -- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/

-- /*DBMS_SCHEDULER.RUN_JOB (''''ILM_CLAIM_JOB'''', FALSE);*/

-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


--below table need to ingest and then will use the below block(BJAZ_NM_RCS_CLAIM_STATUS_MV)

   -- UPDATE  MV_CLAIM_REGISTER
   --       SET MAXIMUS_FLAG=''''RCS''''
   --       WHERE EXISTS (
   --       SELECT 1 FROM BJAZ_NM_RCS_CLAIM_STATUS_MV
   --       WHERE
   --       --- TRUNC(UPDATED_ON)>=TRUNC(SYSDATE)-1
   --        C_CLAIM_NO=CLAIM_NUMBER
   --       AND STATUS = ''''Y'''');
   --       COMMIT;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
         SET MAXIMUS_FLAG=''''RCS''''
         WHERE EXISTS (
         SELECT 1 FROM BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_NM_RCS_CLAIM_STATUS
         WHERE
         --- TRUNC(UPDATED_ON)>=TRUNC(SYSDATE)-1
          C_CLAIM_NO=CLAIM_NUMBER
         AND STATUS = ''''Y'''')'';
EXECUTE IMMEDIATE v_sqltext;

 BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS TRANSACTIONAL.MV_CLAIM_REGISTER_OS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO TRANSACTIONAL.MV_CLAIM_REGISTER_OS
select
               c_claim_no,
                c_claim_id_sk,
                c_accident_loc,
                c_loss_time,
                clm_status,
                top_indicator,
                c_off_loc_id,
                p_policy_number,
                policy_location_id,
                p_product_id,
                p_risk_inc_date,
                p_risk_expiry_date,
                i_imd_desc,
                p_sub_imd,
                imd_channel,
                v_vehicle_make,
                p_year_of_manu,
                m_vehicle_model,
                p_regn_no,
                pt_partner_id,
                pt_partner_desc,
                pt_partner_city,
                c_comments,
                c_claim_type,
                c_cause_of_loss,
                c_rep_name,
                c_name_of_in1,
                c_regn_date,
                c_clo_date,
                c_loss_date,
                c_inti_date,
                c_sur_name,
                c_app_date,
                c_policy_grain,
                c_claim_regd_by,
                c_last_reopen_date,
                c_paid_flag,
                consumer_forum_flag,
                c_ombsman_flag,
                c_ligitation_flag,
                p_department_desc,
                reopen_flag,
                ren_roll_nb_flag,
                tp_pool_flag,
                pool_paid_flag,
                p_master_policy_no,
                p_ren_indicator,
                c_court_flag,
                c_sur_rep_date,
                p_policy_issue_date,
                p_coinsurance_type,
                t_date_desc,
                cp_company_name,
                r_reserve_group_desc,
                r_reserve_desc,
                p_geographic_scope,
                p_gc_plan,
                p_engine_number,
                p_chassis_number,
                c_settlemnt_type,
                c_all_doc_date,
                c_special_comments,
                c_mrn_transporter_name,
                c_invoice_no,
                runner_name,
                runner_code,
                branch_resp,
                cse_code,
                pt_house_hold_id,
                pt_cluster_id,
                a.case_year,
                a.ho_id,
                a.next_court_h_date,
                a.case_title,
                a.case_prefix,
                a.court_stage,
                a.tp_compro_defense,
                a.status_of_investigation_report,
                a.decision_on_award,
                a.details_of_followup,
                a.investigation_appointmentdate,
                a.tp_court_remarks,
                a.invest_report_receivingdate,
                c_adv_name,
                p_ncb_percent,
                p_ncb_amount,
                p_cover_note_no,
                p_policy_status,
                c_recpt_psr_date,
                c_recpt_fsr_date,
                c_sur_app_date,
                c_delay_reason,
                c_emeditek_claim_no,
                a.remarks_oflegal_officer,
                pt_partner_type,
                c_rfa_date,
                c_event_code,
                c_tpa_status,
                pt_partner_region,
                pt_partner_region_stnd,
                c_invoice_date,
                c_fsr_psr_status,
                p_fuel_type,
                policy_age,
                vehicle_reg_date,
                tp_compromise,
                partner_pin_code,
                partner_city,
                old_policy_no,
                paid_claim,
                reserve_amount,
                os_amt,
                salvage_amt,
                service_tax,
                pool_salvage_amt,
                pool_paid_before_salvage,
                pool_paid_after_salvage,
                net_paid,
                net_tax,
                c_place_of_loss,
                c_landmark,
                c_area,
                c_state,
                c_city,
                c_pincode,
                c_journey_from,
                c_journey_to,
                c_consignee_name,
                c_consigner_name,
                c_survey_location,
                c_goods_details,
                p_covernote_date,
                v_vehicle_type,
                i_imd_name,
                c_next_rvw_date,
                c_last_rvw_remarks,
                p_old_pol_exp_date,
                tp_clm_handling_loc,
                tp_resp_person,
                pt_partner_telephone,
                pt_partner_address,
                c_fplm_flag,
                c_claim_id,
                c_reopen_remark,
                c_reopen_by,
                base_sum_insured,
                pol_global_flag,
                p_emp_code,
                addl_excess,
                voluntary_excess,
                compulsory_excess,
                expense_app_date,
                loss_app_date,
                net_assessed_amount,
                depreciation_amount, p_sub_channel_code,
                 case
                when DATEDIFF(''''DAY'''', DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')), c_regn_date) between  0 and 15 then ''''0-15''''
                when DATEDIFF(''''DAY'''', DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')), c_regn_date) between 16 and 30 then ''''16-30''''
                when DATEDIFF(''''DAY'''', DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')), c_regn_date) between 31 and 60 then ''''31-60''''
                when DATEDIFF(''''DAY'''', DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')), c_regn_date) between 61 and  90 then ''''61-90''''
                when DATEDIFF(''''DAY'''', DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')), c_regn_date) between 91 and  180 then ''''91-180''''
                when DATEDIFF(''''DAY'''', DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')), c_regn_date) between 181 and  165 then ''''181-365''''
                else ''''Above 365''''
                end os_band,
             c_portal_flag,
             C_MLT_YEAR,
             MAXIMUS_FLAG,
             PT_PARTY_CODE,
             CESSION_PERC,
             RI_RETENTION_OS_AMOUNT,
             NULL as ILM_FLAG,
             null,
             null,
             null,
             null,
             null,
             null,
             RECOVERY_INITIATED,
             RECOVERY_DONE,
             RECOVERY_PENDING
           from TRANSACTIONAL.MV_CLAIM_REGISTER a
          where clm_status = ''''OPEN'''''';

EXECUTE IMMEDIATE v_sqltext;

-- v_sqltext := ''SELECT COUNT(*)   || ''|| v_CNT ||''
--     FROM INFORMATION_SCHEMA.TABLES
--     WHERE TABLE_NAME  = ''''INTERMEDIATE.WRK_CLAIM_REGISTER_OS'''''';

-- EXECUTE IMMEDIATE v_sqltext;

--     IF (|| ''|| v_CNT ||'' >= 1) THEN
--         EXECUTE IMMEDIATE ''''DROP TABLE IF EXISTS INTERMEDIATE.WRK_CLAIM_REGISTER_OS'''';
--     END IF;

-- EXECUTE IMMEDIATE v_sqltext;

-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

-- v_sqltext := ''INSERT INTO TRANSACTIONAL.MV_CLAIM_REGISTER_OS
-- (
-- C_CLAIM_NO ,
-- 	C_CLAIM_ID_SK ,
-- 	C_ACCIDENT_LOC ,
-- 	C_LOSS_TIME ,
-- 	CLM_STATUS ,
-- 	TOP_INDICATOR ,
-- 	C_OFF_LOC_ID ,
-- 	P_POLICY_NUMBER ,
-- 	POLICY_LOCATION_ID ,
-- 	P_PRODUCT_ID ,
-- 	P_RISK_INC_DATE ,
-- 	P_RISK_EXPIRY_DATE ,
-- 	I_IMD_DESC ,
-- 	P_SUB_IMD ,
-- 	IMD_CHANNEL ,
-- 	V_VEHICLE_MAKE ,
-- 	P_YEAR_OF_MANU,
-- 	M_VEHICLE_MODEL ,
-- 	P_REGN_NO ,
-- 	PT_PARTNER_ID ,
-- 	PT_PARTNER_DESC ,
-- 	PT_PARTNER_CITY ,
-- 	C_COMMENTS ,
-- 	C_CLAIM_TYPE ,
-- 	C_CAUSE_OF_LOSS ,
-- 	C_REP_NAME ,
-- 	C_NAME_OF_IN1 ,
-- 	C_REGN_DATE ,
-- 	C_CLO_DATE ,
-- 	C_LOSS_DATE ,
-- 	C_INTI_DATE ,
-- 	C_SUR_NAME ,
-- 	C_APP_DATE ,
-- 	C_POLICY_GRAIN ,
-- 	C_CLAIM_REGD_BY ,
-- 	C_LAST_REOPEN_DATE ,
-- 	C_PAID_FLAG ,
-- 	CONSUMER_FORUM_FLAG ,
-- 	C_OMBSMAN_FLAG ,
-- 	C_LIGITATION_FLAG ,
-- 	P_DEPARTMENT_DESC ,
-- 	REOPEN_FLAG ,
-- 	REN_ROLL_NB_FLAG ,
-- 	TP_POOL_FLAG ,
-- 	POOL_PAID_FLAG ,
-- 	P_MASTER_POLICY_NO ,
-- 	P_REN_INDICATOR,
-- 	C_COURT_FLAG ,
-- 	C_SUR_REP_DATE ,
-- 	P_POLICY_ISSUE_DATE ,
-- 	P_COINSURANCE_TYPE ,
-- 	T_DATE_DESC ,
-- 	CP_COMPANY_NAME ,
-- 	R_RESERVE_GROUP_DESC ,
-- 	R_RESERVE_DESC ,
-- 	P_GEOGRAPHIC_SCOPE ,
-- 	P_GC_PLAN ,
-- 	P_ENGINE_NUMBER ,
-- 	P_CHASSIS_NUMBER ,
-- 	C_SETTLEMNT_TYPE ,
-- 	C_ALL_DOC_DATE ,
-- 	C_SPECIAL_COMMENTS ,
-- 	C_MRN_TRANSPORTER_NAME ,
-- 	C_INVOICE_NO ,
-- 	RUNNER_NAME ,
-- 	RUNNER_CODE ,
-- 	BRANCH_RESP ,
-- 	CSE_CODE ,
-- 	PT_HOUSE_HOLD_ID ,
-- 	PT_CLUSTER_ID ,
-- 	CASE_YEAR ,
-- 	HO_ID ,
-- 	NEXT_COURT_H_DATE ,
-- 	CASE_TITLE ,
-- 	CASE_PREFIX ,
-- 	COURT_STAGE ,
-- 	TP_COMPRO_DEFENSE ,
-- 	STATUS_OF_INVESTIGATION_REPORT ,
-- 	DECISION_ON_AWARD ,
-- 	DETAILS_OF_FOLLOWUP ,
-- 	INVESTIGATION_APPOINTMENTDATE ,
-- 	TP_COURT_REMARKS ,
-- 	INVEST_REPORT_RECEIVINGDATE ,
-- 	C_ADV_NAME ,
-- 	P_NCB_PERCENT ,
-- 	P_NCB_AMOUNT ,
-- 	P_COVER_NOTE_NO ,
-- 	P_POLICY_STATUS ,
-- 	C_RECPT_PSR_DATE ,
-- 	C_RECPT_FSR_DATE ,
-- 	C_SUR_APP_DATE ,
-- 	C_DELAY_REASON ,
-- 	C_EMEDITEK_CLAIM_NO ,
-- 	REMARKS_OFLEGAL_OFFICER ,
-- 	PT_PARTNER_TYPE ,
-- 	C_RFA_DATE ,
-- 	C_EVENT_CODE ,
-- 	C_TPA_STATUS ,
-- 	PT_PARTNER_REGION ,
-- 	PT_PARTNER_REGION_STND ,
-- 	C_INVOICE_DATE ,
-- 	C_FSR_PSR_STATUS ,
-- 	P_FUEL_TYPE ,
-- 	POLICY_AGE ,
-- 	VEHICLE_REG_DATE ,
-- 	TP_COMPROMISE ,
-- 	PARTNER_PIN_CODE ,
-- 	PARTNER_CITY ,
-- 	OLD_POLICY_NO ,
-- 	PAID_CLAIM ,
-- 	RESERVE_AMOUNT ,
-- 	OS_AMT ,
-- 	SALVAGE_AMT ,
-- 	SERVICE_TAX ,
-- 	POOL_SALVAGE_AMT ,
-- 	POOL_PAID_BEFORE_SALVAGE ,
-- 	POOL_PAID_AFTER_SALVAGE ,
-- 	NET_PAID ,
-- 	NET_TAX ,
-- 	C_PLACE_OF_LOSS ,
-- 	C_LANDMARK ,
-- 	C_AREA ,
-- 	C_STATE ,
-- 	C_CITY ,
-- 	C_PINCODE ,
-- 	C_JOURNEY_FROM ,
-- 	C_JOURNEY_TO ,
-- 	C_CONSIGNEE_NAME ,
-- 	C_CONSIGNER_NAME ,
-- 	C_SURVEY_LOCATION ,
-- 	C_GOODS_DETAILS ,
-- 	P_COVERNOTE_DATE ,
-- 	V_VEHICLE_TYPE ,
-- 	I_IMD_NAME ,
-- 	C_NEXT_RVW_DATE ,
-- 	C_LAST_RVW_REMARKS ,
-- 	P_OLD_POL_EXP_DATE ,
-- 	TP_CASE_CLAIM_LOCATION ,
-- 	TP_CASE_RESP_PERSON ,
-- 	PT_PARTNER_TELEPHONE ,
-- 	PT_PARTNER_ADDRESS ,
-- 	C_FPLM_FLAG ,
-- 	C_CLAIM_ID ,
-- 	C_REOPEN_REMARK ,
-- 	C_REOPEN_BY ,
-- 	BASE_SUM_INSURED ,
-- 	POL_GLOBAL_FLAG ,
-- 	P_EMP_CODE ,
-- 	ADDL_EXCESS ,
-- 	VOLUNTARY_EXCESS ,
-- 	COMPULSORY_EXCESS ,
-- 	EXPENSE_APP_DATE ,
-- 	LOSS_APP_DATE ,
-- 	NET_ASSESSED_AMOUNT ,
-- 	DEPRECIATION_AMOUNT ,
-- 	P_SUB_CHANNEL_CODE ,
-- 	OS_BAND ,
-- 	C_PORTAL_FLAG ,
-- 	C_MLT_YEAR ,
-- 	MAXIMUS_FLAG ,
-- 	PT_PARTY_CODE ,
-- 	CESSION_PERC ,
-- 	RI_RETENTION_OS_AMOUNT,
--     NULL,
--     RECOVERY_INITIATED,
--     RECOVERY_DONE,
--     RECOVERY_PENDING
-- )
-- SELECT * FROM INTERMEDIATE.WRK_CLAIM_REGISTER_OS'';

-- EXECUTE IMMEDIATE v_sqltext;

END;


-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''mv_claim_register_os inserted -- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
-- /*send_sms_proc (
--          ''''DWH LOAD MV_CLAIM_REGISTER ''''
--       || TO_DATE('''''' || T_DATE || '''''')
--       || '''' - ''''
--       || SQLERRM
--       || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--       ''''7722043323'''',
--       ''''D'''');*/
-- /*send_sms_proc (
--          ''''DWH LOAD MV_CLAIM_REGISTER ''''
--       || TO_DATE('''''' || T_DATE || '''''')
--       || '''' - ''''
--       || SQLERRM
--       || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--       ''''9823432608'''',
--       ''''D'''');*/
-- /*send_sms_proc (
--          ''''DWH LOAD MV_CLAIM_REGISTER ''''
--       || TO_DATE('''''' || T_DATE || '''''')
--       || '''' - ''''
--       || SQLERRM
--       || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--       ''''8379865547'''',
--       ''''D'''');*/
-- /*send_sms_proc (
--          ''''DWH LOAD MV_CLAIM_REGISTER ''''
--       || TO_DATE('''''' || T_DATE || '''''')
--       || '''' - ''''
--       || SQLERRM
--       || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--       ''''9960637763'''',
--       ''''D'''');*/
-- /*7709509460*/
-- /*send_sms_proc (
--          ''''DWH LOAD MV_CLAIM_REGISTER ''''
--       || TO_DATE('''''' || T_DATE || '''''')
--       || '''' - ''''
--       || SQLERRM
--       || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--       ''''8125315451'''',
--       ''''D'''');*/
-- /*madhu(CRMNXT)*/
-- /*send_sms_proc (
--          ''''DWH LOAD MV_CLAIM_REGISTER ''''
--       || TO_DATE('''''' || T_DATE || '''''')
--       || '''' - ''''
--       || SQLERRM
--       || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--       ''''9321080808'''',
--       ''''D'''');*/

Declare
SMS_MSG     VARCHAR;
CLM_CNT NUMBER DEFAULT 0;
CLOSE_CNT NUMBER DEFAULT 0;
OSTD_CNT NUMBER DEFAULT 0;

BEGIN

v_sqltext := ''SELECT COUNT (C_CLAIM_NO)
        || ''|| CLM_CNT ||''
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE     C_REGN_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
             AND NVL (C_CLAIM_TYPE, ''''OD'''') <> ''''TP''''
             AND P_PRODUCT_ID LIKE ''''18%''''
             AND P_PRODUCT_ID <> ''''1817''''
             AND P_DEPARTMENT_DESC = ''''MOTOR''''
             AND TOP_INDICATOR = ''''Y'''''';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''SELECT COUNT (DISTINCT C_CLAIM_NO)
          || ''|| CLOSE_CNT ||''
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE     DATE_TRUNC(''''DAY'''', C_CLO_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
             AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 10)
             AND NVL (C_CLAIM_TYPE, ''''OD'''') <> ''''TP''''
             AND P_PRODUCT_ID LIKE ''''18%''''
             AND P_PRODUCT_ID <> ''''1817''''
             AND P_DEPARTMENT_DESC = ''''MOTOR''''
             AND CLM_STATUS = ''''CLOSED''''
             AND TOP_INDICATOR = ''''Y'''''';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''SELECT COUNT (DISTINCT C_CLAIM_NO)
        || ''|| OSTD_CNT ||''
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER_OS
       WHERE     NVL (C_CLAIM_TYPE, ''''OD'''') <> ''''TP''''
             AND P_PRODUCT_ID LIKE ''''18%''''
             AND P_PRODUCT_ID <> ''''1817''''
             AND P_DEPARTMENT_DESC = ''''MOTOR''''
             AND CLM_STATUS = ''''OPEN''''
             AND TOP_INDICATOR = ''''Y'''''';
EXECUTE IMMEDIATE v_sqltext;

SMS_MSG := ''''''Good Morning! MIS as on day,OD claim registered count:''''
|| ''''''|| CLM_CNT ||''''''
|| '''' and  OD claim settled count:''''
|| ''''''|| CLOSE_CNT ||''''''
|| '''' and od claim ostd:''''
|| ''''''|| OSTD_CNT ||''''''
|| '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''''';

v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_SMS_REPOSITORY (SMS_ID,
                                       SMS_TO,
                                       SMS_FROM,
                                       SMS_MESSAGE,
                                       DATETIME_QUEUED,
                                       SMS_STATUS)
           VALUES (UTILS.SMS_SEQ.NEXTVAL,
                   ''''8379865547'''',
                   ''''BAGIC'''',
                   ''''DWH LOAD'''' || '''' '''' || ''|| SMS_MSG ||'',
                   TO_CHAR (CURRENT_DATE(), ''''DD-MM-YYYY hh24:mi:ss''''),
                   ''''QUEUED'''')'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_SMS_REPOSITORY (SMS_ID,
                                       SMS_TO,
                                       SMS_FROM,
                                       SMS_MESSAGE,
                                       DATETIME_QUEUED,
                                       SMS_STATUS)
           VALUES (UTILS.SMS_SEQ.NEXTVAL,
                   ''''8600657776'''',
                   ''''BAGIC'''',
                   ''''DWH LOAD'''' || '''' '''' || ''|| SMS_MSG ||'',
                   TO_CHAR (CURRENT_DATE(), ''''DD-MM-YYYY hh24:mi:ss''''),
                   ''''QUEUED'''')'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_SMS_REPOSITORY (SMS_ID,
                                       SMS_TO,
                                       SMS_FROM,
                                       SMS_MESSAGE,
                                       DATETIME_QUEUED,
                                       SMS_STATUS)
           VALUES (UTILS.SMS_SEQ.NEXTVAL,
                   ''''9518903934'''',
                   ''''BAGIC'''',
                   ''''DWH LOAD'''' || '''' '''' || ''|| SMS_MSG ||'',
                   TO_CHAR (CURRENT_DATE(), ''''DD-MM-YYYY hh24:mi:ss''''),
                   ''''QUEUED'''')'';

EXECUTE IMMEDIATE v_sqltext;

END;


--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/




CALL INTERMEDIATE.WRK_MAXIMUS_MISSING_DATA_LOAD(''BAGIC_PROD_MIRROR_DB'');




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''WRK_MAXIMUS_MISSING_DATA_LOAD - time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''JOB_RUN_CLAIM'''');*/

-- /*   DBMS_SCHEDULER.RUN_JOB (''''WRK_PORTAL_FLAG_BACK_JOB'''', FALSE);*/
-- /*----------------Agri job------------------------*/


-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


-- /*DBMS_SCHEDULER.RUN_JOB (''''WRK_HO_REFER_OPEN_CLM_JOB'''', FALSE);*/
-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''wrk_ho_refer_open_clm_report in BJAZ_REFRESH_MV_CLAIM''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*DBMS_SCHEDULER.RUN_JOB (''''JOB_RPT_AGRI_CLAIM_FTP_LOAD'''', FALSE);*//*--- NEED TO ADD CLAIM PART*/


-- IF TO_CHAR (DATE_TRUNC(''''''''DAY'''''''', TO_DATE('''''' || T_DATE || '''''')), ''''DD'''') IN (''''01'''') --commented need to discuss with sarvesh
-- THEN
   -- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
   -- /*DBMS_SCHEDULER.RUN_JOB (''''MONTHLY_FINANCE_CLAIM_JOB'''', FALSE);*/
   -- /*CALL LOGTRACE (
   --       ''''LOG'''',
   --       10001,
   --          ''''MONTHLY_FINANCE_CLAIM_JOB - time taken in mins : ''''
   --       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
   --       ''''JOB_RUN_CLAIM'''');*/

-- END IF;
-- /*DBMS_SCHEDULER.RUN_JOB (''''WRK_CDA_DAILY_RECO_JOB'''', FALSE);*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

SELECT
DATEADD(DAY, 1, MAX(DATE_TRUNC(''DAY'', REOPEN_DATE)))
         INTO  :LAST_REOPEN_DATE
        FROM TRANSACTIONAL.WRK_REOPEN_CLAIM_REGISTER;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_REOPEN_CLM_REG_A'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_REOPEN_CLM_REG_A
         SELECT
               A.CLAIM_ID,
                CLM_REF,
                DATE_REPORTED C_REGN_DATE,
                LUA_VALUE_1 C_CLO_DATE,
                DATE_OF_LOSS C_LOSS_DATE,
                MSG_DATE REOPEN_DATE,
                STATUS_MSG,
                STATUS,
                USER_NAME
           FROM PROD_DWH_MIGRATED_DB.STAGE.BJAZ_CLM_STATUS_REPOSITORY A,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND (   UPPER (STATUS) LIKE ''''%REOPEN%''''
                     OR UPPER (STATUS_MSG) LIKE ''''%REOPEN%'''')
                AND DATE_TRUNC(''''DAY'''', MSG_DATE) BETWEEN TO_DATE(''''''|| LAST_REOPEN_DATE ||'''''')
                                         AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)'';


EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLM_TRANS_STG'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLM_TRANS_STG
         SELECT CLAIM_ID,
         SF_NO ,
	TRANS_NO ,
	MOVEMENT_ID ,
	ASSIGNEE ,
	AUTHORISED ,
	SF_TOTAL_TYPE ,
	TRANS_TYPE ,
	TRANS_DATE ,
	CLM_STATUS ,
	TRANS_AMT ,
	TRANS_AMT_SWF ,
	TAX_AMOUNT ,
	RSV_AMT ,
	INT_REF ,
	REF_TEXT ,
	SUPP_ID ,
	IP_NO ,
	CONTRA_TRANS_NO ,
	SPLIT_TRANS ,
	OAR_NO ,
	COVER_NO ,
	TRANS_BASE_AMT ,
	EXT_REFERENCE ,
	PLAN_ID ,
	EXT_USER
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_TRANS
          WHERE     CLAIM_ID IN (SELECT CLAIM_ID FROM INTERMEDIATE.WRK_REOPEN_CLM_REG_A)
                AND CLM_STATUS = ''''AUTHOR'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_REOPEN_CLM_REG_B'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_REOPEN_CLM_REG_B
 SELECT A.CLAIM_ID, TRANS_DATE, SUM (TRANS_AMT) RESERVE_AMT
 FROM INTERMEDIATE.WRK_REOPEN_CLM_REG_A A,
 INTERMEDIATE.WRK_CLM_TRANS_STG X
 WHERE X.CLAIM_ID = A.CLAIM_ID AND TRANS_DATE = DATE_TRUNC(''''DAY'''', REOPEN_DATE)
        --AND CLM_STATUS = ''''AUTHOR''''
GROUP BY A.CLAIM_ID, TRANS_DATE'';

EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''INSERT INTO TRANSACTIONAL.WRK_REOPEN_CLAIM_REGISTER
         SELECT DISTINCT A.*,
         RESERVE_AMT,
         NULL as INC_JOB_CREATED_AT,
         NULL as INC_JOB_CREATED_BY,
         NULL as INC_JOB_UPDATED_BY,
         NULL as INC_JOB_UPDATED_AT,
         NULL as INC_JOB_ID
           FROM INTERMEDIATE.WRK_REOPEN_CLM_REG_A A,
           INTERMEDIATE.WRK_REOPEN_CLM_REG_B B
          WHERE     A.CLAIM_ID = B.CLAIM_ID(+)
                AND DATE_TRUNC(''''DAY'''', REOPEN_DATE) = B.TRANS_DATE(+)'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''MERGE INTO TRANSACTIONAL.MV_CLAIM_REGISTER A
           USING (  SELECT DISTINCT CLM_REF, MAX (DATE_TRUNC(''''DAY'''', REOPEN_DATE)) REOPEN_DATE
                      FROM TRANSACTIONAL.WRK_REOPEN_CLAIM_REGISTER
                     WHERE DATE_TRUNC(''''DAY'''', REOPEN_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)
                                                   AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                  GROUP BY CLM_REF) C
              ON (A.C_CLAIM_NO = C.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET
            C_LAST_REOPEN_DATE = REOPEN_DATE,
            CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (  SELECT DISTINCT CLM_REF, MAX (DATE_TRUNC(''''DAY'''', REOPEN_DATE)) REOPEN_DATE
                      FROM TRANSACTIONAL.WRK_REOPEN_CLAIM_REGISTER
                     WHERE DATE_TRUNC(''''DAY'''', REOPEN_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 3)
                                                   AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                  GROUP BY CLM_REF) C
              ON (A.C_CLAIM_NO = C.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET C_LAST_REOPEN_DATE = REOPEN_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';

EXECUTE IMMEDIATE v_sqltext;


-- /*CALL LOGTRACE (
--          ''''LOG'''',
--          10001,
--             ''''Total Time  Re-open register load - time taken in mins : ''''
--          || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--          ''''BJAZ_REFRESH_MV_CLAIM'''');*/

-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/





-- CALL INTERMEDIATE.WRK_MOTOR_CLM_SETTLEMENT_SUMM(''BAGIC_PROD_MIRROR_DB''); ----------- used in CR Consumption




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''WRK_MOTOR_CLM_SETTLEMENT_SUMM in BJAZ_REFRESH_MV_CLAIM''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.MV_CLAIM_REGISTER A
           USING (SELECT
                        DISTINCT C_CLAIM_NO,
                                 A.P_POLICY_NUMBER,
                                 ASSET_MANUFACTURER,
                                 ASSET_MODEL_NO
                    FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
                    PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM_EXTN B
                   WHERE     A.P_PRODUCT_ID IN (''''6609'''', ''''6610'''')
                         AND P_POLICY_NUMBER = POLICY_REF
                         AND (   NVL (ASSET_MANUFACTURER, ''''A'''') <>
                                    NVL (V_VEHICLE_MAKE, ''''A'''')
                              OR NVL (M_VEHICLE_MODEL, ''''A'''') <>
                                    NVL (ASSET_MODEL_NO, ''''A''''))
                         AND T_DATE_DESC BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)
                                             AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) C
              ON (A.C_CLAIM_NO = C.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET V_VEHICLE_MAKE = ASSET_MANUFACTURER,
                    M_VEHICLE_MODEL = ASSET_MODEL_NO,
                    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
                    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))'';

EXECUTE IMMEDIATE v_sqltext;
END;

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''Total Time for 6609-6610 asset make model update - time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


BEGIN
v_sqltext := ''MERGE INTO TRANSACTIONAL.MV_CLAIM_REGISTER A
           USING (SELECT DISTINCT C_CLAIM_NO, A.FRAUD_FLAG, A.FRAUD_DETAILS
                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
                    TRANSACTIONAL.ODS_CLAIM_DIM C
                   WHERE     A.CLAIM_ID = C.C_CLAIM_ID
                         AND DATE_TRUNC(''''DAY'''', C_CLO_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3
                         AND NVL (A.FRAUD_FLAG, ''''N'''') = ''''Y'''') C
              ON (A.C_CLAIM_NO = C.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET FRAUD_FLAG = C.FRAUD_FLAG,
                    FRAUD_DETAILS = C.FRAUD_DETAILS,
                    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
                    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))'';

EXECUTE IMMEDIATE v_sqltext;
  END;

--/*CALL LOGTRACE (
--      ''''LOG'''',
--      10001,
--         ''''FRAUD_FLAG update - time taken in mins : ''''
--      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
--/*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
--
--/*--added by chandrakant 14-sep-2021----*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_PLACE_OF_REGISTRATION'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_PLACE_OF_REGISTRATION
      SELECT A.P_POLICY_NUMBER, P_CITY_OF_REGN
        FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM A,
             (  SELECT P_POLICY_NUMBER
                  FROM TRANSACTIONAL.MV_CLAIM_REGISTER
                 WHERE     T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3
                       AND PLACE_OF_REGISTRATION IS NULL
              GROUP BY P_POLICY_NUMBER) X
       WHERE     A.P_POLICY_NUMBER = X.P_POLICY_NUMBER
             AND P_CITY_OF_REGN IS NOT NULL
             AND P_CURRENT_INDICATOR = 1'';

EXECUTE IMMEDIATE v_sqltext;

BEGIN
v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET PLACE_OF_REGISTRATION = src.CITY,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_PLACE_OF_REGISTRATION
) as src
WHERE target.P_POLICY_NUMBER = src.POLICY_REF'';

EXECUTE IMMEDIATE v_sqltext;
END;

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''PLACE_OF_REGISTRATION update - time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/





-- CALL INTERMEDIATE.WRK_CLM_CDC_PROC(''BAGIC_PROD_MIRROR_DB''); commented because used in CR Consumption



-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''Total Time  WRK_CLM_CDC_PROC- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_WC_PA_SALVAGE_TRANS'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_WC_PA_SALVAGE_TRANS
         (  SELECT C_CLAIM_ID,
                   A.P_POLICY_NUMBER,
                   POLICY_LOCATION_ID,
                   P_POLICY_ISSUE_DATE,
                   C_CLAIM_NO,
                   A.T_DATE_DESC,
                   A.P_RISK_INC_DATE,
                   A.P_RISK_EXPIRY_DATE,
                   CLM_STATUS,
                   C_LOSS_DATE DATE_OF_LOSS,
                   C_REGN_DATE DATE_REPORTED,
                   IMD_CHANNEL,
                   SUM (SALVAGE_AMT) SALVAGE_AMT,
                   A.P_SUB_CHANNEL_CODE
              FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
              PROD_DWH_MIGRATED_DB.PROD.RECO_TBL_27_AUG_09_MV B
             WHERE     A.P_PRODUCT_ID IN
                          (1803, 1807, 1810, 1811, 1812, 1852, 1853, 1854, 5001)
                   AND A.T_DATE_DESC = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                   --and c_claim_no =''''OC-12-2202-1812-00000024''''
                   AND A.P_POLICY_NUMBER = B.P_POLICY_NUMBER
          GROUP BY POLICY_LOCATION_ID,
                   C_CLAIM_ID,
                   C_CLAIM_NO,
                   P_POLICY_ISSUE_DATE,
                   A.P_POLICY_NUMBER,
                   A.T_DATE_DESC,
                   C_LOSS_DATE,
                   C_REGN_DATE,
                   CLM_STATUS,
                   A.P_RISK_INC_DATE,
                   A.P_RISK_EXPIRY_DATE,
                   IMD_CHANNEL,
                   A.P_SUB_CHANNEL_CODE
            HAVING SUM (SALVAGE_AMT) <> 0)'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO TRANSACTIONAL.WRK_WC_PA_SALVAGE
         SELECT DISTINCT T_YEAR_ID,
                         POLICY_LOCATION_ID POL_LOC,
                         IMD_CHANNEL CHANNEL,
                         TRANS.CLM_STATUS CLAIM_STATUS,
                         C_CLAIM_NO CLM_REF,
                         P_PRODUCT_ID PRODUCT_CODE,
                         TRANS.P_POLICY_NUMBER POLICY_REF,
                         DATE_REPORTED REGN_DATE,
                         TRANS.DATE_OF_LOSS LOSS_DATE,
                         TRANS.P_RISK_INC_DATE RID,
                         TRANS.P_RISK_EXPIRY_DATE RED,
                         0 RES_AMT,
                         SALVAGE_AMT PAID_AMT,
                         0 S_TAX,
                         ODS_TIME_DIM.T_DATE_DESC,
                         P_POLICY_ISSUE_DATE,
                         TRANS.P_SUB_CHANNEL_CODE,
                         NULL AS INC_JOB_CREATED_AT,
                         NULL AS INC_JOB_CREATED_BY,
                         NULL AS INC_JOB_UPDATED_BY,
                         NULL AS INC_JOB_UPDATED_AT,
                         NULL AS INC_JOB_ID

           FROM                                                -- clm_bases b,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_SUBFILES C,
                -- clm_pol_bases e,
                --ods_policy_dim,
                (INTERMEDIATE.WRK_WC_PA_SALVAGE_TRANS) TRANS,
                --   ods_imd_dim,
                PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM,
                PROD_DWH_MIGRATED_DB.PROD.RECO_TBL_27_AUG_09_MV K
          WHERE     C.SF_DESC NOT LIKE ''''Own%''''
                AND DATE_TRUNC(''''DAY'''', TRANS.T_DATE_DESC) = (ODS_TIME_DIM.T_DATE_DESC)
                AND TRANS.P_POLICY_NUMBER = K.P_POLICY_NUMBER
                -- AND b.claim_id = trans.c_claim_id
                -- and e.policy_ref = ods_policy_dim.p_policy_number
                --and ods_policy_dim.p_imd_id_sk = ods_imd_dim.i_imd_id_sk(+)
                AND C_CLAIM_ID = C.CLAIM_ID
                --and c_claim_id = e.claim_id
                --and trans.p_policy_number=ods_policy_dim.p_policy_number
                AND EXISTS
                       (SELECT ''''X''''
                          FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_SUBFILES K
                         WHERE     K.CLAIM_ID = TRANS.C_CLAIM_ID
                               AND K.SF_TYPE IN (''''03'''', ''''04''''))
                --and e.term_start_date between ''''01-apr-2007'''' and ''''31-mar-2012''''
                AND P_PRODUCT_ID IN
                       (1803, 1807, 1810, 1811, 1812, 1852, 1853, 1854, 5001)'';

EXECUTE IMMEDIATE v_sqltext;

END;

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''Total Time  kamal sir salvage issue - time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/






CALL TRANSACTIONAL.WRK_DOCUMENT_LIST_PRC(''BAGIC_PROD_MIRROR_DB'');




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''wrk_document_list_prc in BJAZ_REFRESH_MV_CLAIM''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/

-- /*DBMS_SCHEDULER.RUN_JOB (''''JOB_WHITE_GOODS_CLM_REGISTER'''', FALSE);*/

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''JOB_WHITE_GOODS_CLM_REGISTER in BJAZ_REFRESH_MV_CLAIM''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/






-- CALL INTERMEDIATE.BJAZ_CLM_CLOSED_PER(''BAGIC_PROD_MIRROR_DB'');
-- commented out cuz it already runs in CR Consumption




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''BJAZ_CLM_CLOSED_PER inserted -- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/






-- CALL INTERMEDIATE.RPT_IIB_DAILY_OD_CLM(''BAGIC_PROD_MIRROR_DB'');
-- commented out because RPT_IIB_DAILY_OD_CLM is being called from CR Consumption process




-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''RPT_IIB_DAILY_OD_CLM inserted -- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/


v_sqltext := ''INSERT INTO TRANSACTIONAL.WRK_CLM_CALLER
      SELECT POLICY_LOCATION_ID,
             CASE
                WHEN UPPER (D.P_GC_PLAN) LIKE ''''%DRIVE%'''' THEN ''''Y''''
                ELSE ''''N''''
             END
                DRIVE_SMART_FLAG,
             A.P_DEPARTMENT_DESC LOB,
             P_ACC_LOB ACC_LOB,
             ZONE_DESC,
             A.PT_PARTNER_DESC,
             A.P_POLICY_NUMBER,
             C_CLO_DATE,
             IMD_CHANNEL,
             REN_ROLL_NB_FLAG,
             DECODE (SEGMENT,
                     1, ''''1_MASS'''',
                     2, ''''2_LM'''',
                     3, ''''3_UM'''',
                     4, ''''4_MA'''',
                     5, ''''5_AFFLUENT'''',
                     6, ''''6_LSA'''',
                     7, ''''7_USA'''',
                     8, ''''8_HNI'''',
                     9, ''''9_SHNI'''',
                     10, ''''10_UHNI'''')
                PARTNER_SEGMENT,
             CONTRACT_ID,
             NULL AS INC_JOB_CREATED_AT,
             NULL AS INC_JOB_CREATED_BY,
             NULL AS INC_JOB_UPDATED_BY,
             NULL AS INC_JOB_UPDATED_AT,
             NULL AS INC_JOB_ID
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
             PROD_DWH_MIGRATED_DB.PROD.ODS_LOCATION_DIM B,
             PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM C,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM D,
             PROD_DWH_MIGRATED_DB.PROD.ODS_CLUSTER_DIM E,
             PROD_DWH_MIGRATED_DB.PROD.ODS_SEGMENT_DIM F,
             ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES G
       -- ods_partner_dim partner_dim_policy
       WHERE     TOP_INDICATOR = ''''Y''''
             AND OFFICE_LOCATION_ID = POLICY_LOCATION_ID
             AND A.P_PRODUCT_ID = C.P_PRODUCT_ID
             AND A.P_POLICY_NUMBER = D.P_POLICY_NUMBER
             AND P_CURRENT_INDICATOR = 1
             --          AND a.pt_partner_id = partner_dim_policy.pt_partner_id
             --          AND pt_current_indicator = 1
             AND A.PT_PARTNER_ID = E.CID(+)
             AND E.UCID = F.UCID(+)
             AND A.P_POLICY_NUMBER = G.POLICY_REF(+)
             AND A.C_CLAIM_ID = G.CLAIM_ID(+)
             AND C_CLAIM_NO IN
                    (SELECT DISTINCT CLM_REF
                       FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL
                      WHERE     IP_TYPE IN (''''PHI'''', ''''REP'''', ''''TIEUPREP'''', ''''BAPW'''')
                            -- Addition of REP by Alekh for Issue 1395472 -- addition  for call no 39447427
                            AND TRANS_TYPE = ''''30''''
                            AND PAY_STATUS <> ''''DELETED''''
                            AND PRODUCT_CODE LIKE ''''18%''''
                            AND DATE_TRUNC(''''DAY'''', TRANS_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1)'';

EXECUTE IMMEDIATE v_sqltext;


----------------- Part of CR Consumption (gets called together from the proc PROD_MOT_CLAIM_SUMM_DAILY_COMBINED daily except first of the month) ------------------------
-- BEGIN
--     v_today_day := TO_CHAR(DATE_TRUNC(''DAY'', CURRENT_DATE()), ''DD'');

--     IF (v_today_day NOT IN (''01'')) THEN

--     CALL INTERMEDIATE.PROD_MOT_CLAIM_SUMM(''BAGIC_PROD_MIRROR_DB'');

--     CALL INTERMEDIATE.PROD_MOT_OD_CLAIM_SUMM(''BAGIC_PROD_MIRROR_DB'');

--     END IF;
-- END;
-------------------- Part of CR Consumption (gets called together from the proc PROD_MOT_CLAIM_SUMM_DAILY_COMBINED daily except first of the month) ------------------------






BEGIN
v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_TP_COURT_FLAG'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_TP_COURT_FLAG
         SELECT
               CLM_REF,
                NEXT_STAGE,
                NEXT_COURT_DATE,
                STEPS_TAKEN,
                DATE_TRUNC(''''DAY'''', INSERT_ON) AS INSERT_ON

           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_HEARING_DTLS A,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                TRANSACTIONAL.MV_CLAIM_REGISTER C
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND CLM_REF = C_CLAIM_NO
                AND NVL (C_CLAIM_TYPE, ''''OD'''') = ''''TP''''
                AND NVL (A.DELETE_YN, ''''N'''') = ''''N''''
                AND C.TOP_INDICATOR = ''''Y''''
                AND SR_NO =
                       (SELECT MAX (SR_NO)
                          FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_HEARING_DTLS K
                         WHERE     K.CLAIM_ID = A.CLAIM_ID
                               AND NVL (K.DELETE_YN, ''''N'''') = ''''N'''')'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.WRK_TP_COURT_FLAG
            WHERE     NEXT_COURT_DATE IS NULL
                  AND NEXT_STAGE IS NULL
                  AND STEPS_TAKEN IS NULL'';


EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER_OS
as target
    SET COURT_STAGE = src.NEXT_STAGE,
    NEXT_COURT_H_DATE = src.NEXT_COURT_DATE
FROM
(
  SELECT * FROM INTERMEDIATE.WRK_TP_COURT_FLAG
) as src
WHERE target.C_CLAIM_NO = src.CLM_REF AND
NVL (target.C_CLAIM_TYPE, ''''OD'''') = ''''TP'''''';



EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER_OS as target
         SET ILM_FLAG = ''''Y''''
       WHERE EXISTS
                (SELECT 1
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_ILM_INVESTIGATION_DTLS
                  WHERE CLAIM_REF = C_CLAIM_NO)'';

EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_bagic_active_emp'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_BAGIC_ACTIVE_EMP
SELECT
EMP_CODE,
OFFICIAL_EMAIL,
FUNCTIONN,
DEPARTMENT,
SUB_DEPARTMENT,
RA,
RA_MAIL_ID,
RM,
RM_MAIL_ID,
EMP_STATUS
FROM PROD_DWH_MIGRATED_DB.PROD.VW_DEPARTMENT_ACTIVE_EMP'';

EXECUTE IMMEDIATE v_sqltext;

END;

--/*DBMS_SCHEDULER.RUN_JOB (''''WRK_RFA_DETAIL_UPDATE_JOB'''', FALSE);*/


 --   L_START := DBMS_UTILITY.GET_TIME;
   --
   --   DELETE FROM DL_DWH_AWS.MV_CLAIM_REGISTER_7DAYS;
   --
   --
   --
   --   INSERT INTO DL_DWH_AWS.MV_CLAIM_REGISTER_7DAYS
   --      SELECT C_CLAIM_NO,
   --             C_CLAIM_ID_SK,
   --             C_ACCIDENT_LOC,
   --             C_LOSS_TIME,
   --             CLM_STATUS,
   --             TOP_INDICATOR,
   --             C_OFF_LOC_ID,
   --             P_POLICY_NUMBER,
   --             POLICY_LOCATION_ID,
   --             P_PRODUCT_ID,
   --             P_RISK_INC_DATE,
   --             P_RISK_EXPIRY_DATE,
   --             I_IMD_DESC,
   --             P_SUB_IMD,
   --             IMD_CHANNEL,
   --             V_VEHICLE_MAKE,
   --             P_YEAR_OF_MANU,
   --             M_VEHICLE_MODEL,
   --             P_REGN_NO,
   --             PT_PARTNER_ID,
   --             PT_PARTNER_DESC,
   --             PT_PARTNER_CITY,
   --             C_COMMENTS,
   --             C_CLAIM_TYPE,
   --             C_CAUSE_OF_LOSS,
   --             C_REP_NAME,
   --             C_NAME_OF_IN1,
   --             C_REGN_DATE,
   --             C_CLO_DATE,
   --             C_LOSS_DATE,
   --             C_INTI_DATE,
   --             C_SUR_NAME,
   --             C_APP_DATE,
   --             C_POLICY_GRAIN,
   --             C_CLAIM_REGD_BY,
   --             C_LAST_REOPEN_DATE,
   --             C_PAID_FLAG,
   --             CONSUMER_FORUM_FLAG,
   --             C_OMBSMAN_FLAG,
   --             C_LIGITATION_FLAG,
   --             P_DEPARTMENT_DESC,
   --             REOPEN_FLAG,
   --             REN_ROLL_NB_FLAG,
   --             TP_POOL_FLAG,
   --             POOL_PAID_FLAG,
   --             P_MASTER_POLICY_NO,
   --             P_REN_INDICATOR,
   --             C_COURT_FLAG,
   --             C_SUR_REP_DATE,
   --             P_POLICY_ISSUE_DATE,
   --             P_COINSURANCE_TYPE,
   --             T_DATE_DESC,
   --             CP_COMPANY_NAME,
   --             R_RESERVE_GROUP_DESC,
   --             R_RESERVE_DESC,
   --             P_GEOGRAPHIC_SCOPE,
   --             P_GC_PLAN,
   --             P_ENGINE_NUMBER,
   --             P_CHASSIS_NUMBER,
   --             C_SETTLEMNT_TYPE,
   --             C_ALL_DOC_DATE,
   --             C_SPECIAL_COMMENTS,
   --             C_MRN_TRANSPORTER_NAME,
   --             C_INVOICE_NO,
   --             RUNNER_NAME,
   --             RUNNER_CODE,
   --             BRANCH_RESP,
   --             CSE_CODE,
   --             PT_HOUSE_HOLD_ID,
   --             PT_CLUSTER_ID,
   --             CASE_YEAR,
   --             HO_ID,
   --             NEXT_COURT_H_DATE,
   --             CASE_TITLE,
   --             CASE_PREFIX,
   --             COURT_STAGE,
   --             TP_COMPRO_DEFENSE,
   --             STATUS_OF_INVESTIGATION_REPORT,
   --             DECISION_ON_AWARD,
   --             DETAILS_OF_FOLLOWUP,
   --             INVESTIGATION_APPOINTMENTDATE,
   --             TP_COURT_REMARKS,
   --             INVEST_REPORT_RECEIVINGDATE,
   --             C_ADV_NAME,
   --             P_NCB_PERCENT,
   --             P_NCB_AMOUNT,
   --             P_COVER_NOTE_NO,
   --             P_POLICY_STATUS,
   --             C_RECPT_PSR_DATE,
   --             C_RECPT_FSR_DATE,
   --             C_SUR_APP_DATE,
   --             C_DELAY_REASON,
   --             C_EMEDITEK_CLAIM_NO,
   --             REMARKS_OFLEGAL_OFFICER,
   --             PT_PARTNER_TYPE,
   --             C_RFA_DATE,
   --             C_EVENT_CODE,
   --             C_TPA_STATUS,
   --             PT_PARTNER_REGION,
   --             PT_PARTNER_REGION_STND,
   --             C_INVOICE_DATE,
   --             C_FSR_PSR_STATUS,
   --             P_FUEL_TYPE,
   --             POLICY_AGE,
   --             VEHICLE_REG_DATE,
   --             TP_COMPROMISE,
   --             PARTNER_PIN_CODE,
   --             PARTNER_CITY,
   --             OLD_POLICY_NO,
   --             PAID_CLAIM,
   --             RESERVE_AMOUNT,
   --             OS_AMT,
   --             SALVAGE_AMT,
   --             SERVICE_TAX,
   --             POOL_SALVAGE_AMT,
   --             POOL_PAID_BEFORE_SALVAGE,
   --             POOL_PAID_AFTER_SALVAGE,
   --             NET_PAID,
   --             NET_TAX,
   --             C_PLACE_OF_LOSS,
   --             C_LANDMARK,
   --             C_AREA,
   --             C_STATE,
   --             C_CITY,
   --             C_PINCODE,
   --             C_JOURNEY_FROM,
   --             C_JOURNEY_TO,
   --             C_CONSIGNEE_NAME,
   --             C_CONSIGNER_NAME,
   --             C_SURVEY_LOCATION,
   --             C_GOODS_DETAILS,
   --             P_COVERNOTE_DATE,
   --             V_VEHICLE_TYPE,
   --             I_IMD_NAME,
   --             C_NEXT_RVW_DATE,
   --             C_LAST_RVW_REMARKS,
   --             P_OLD_POL_EXP_DATE,
   --             PT_PARTNER_TELEPHONE,
   --             TP_RESP_PERSON,
   --             TP_CLM_HANDLING_LOC,
   --             PT_PARTNER_ADDRESS,
   --             C_FPLM_FLAG,
   --             C_CLAIM_ID,
   --             C_REOPEN_REMARK,
   --             C_REOPEN_BY,
   --             BASE_SUM_INSURED,
   --             POL_GLOBAL_FLAG,
   --             P_EMP_CODE,
   --             ADDL_EXCESS,
   --             VOLUNTARY_EXCESS,
   --             COMPULSORY_EXCESS,
   --             EXPENSE_APP_DATE,
   --             LOSS_APP_DATE,
   --             NET_ASSESSED_AMOUNT,
   --             DEPRECIATION_AMOUNT,
   --             P_SUB_CHANNEL_CODE,
   --             P_FIRE_LOC_NAME,
   --             P_FIRE_LOC_TYPE,
   --             P_FIRE_OCCUPANCY,
   --             P_FIRE_RISK_TYPE,
   --             P_VEHICLE_GVW,
   --             M_VEHICLE_SEGMENT,
   --             C_PORTAL_FLAG,
   --             C_MLT_YEAR,
   --             MAXIMUS_FLAG,
   --             MIN_RFA_DATE,
   --             MAX_RFA_DATE,
   --             RFA_RAISED_BY,
   --             RFA_APPROVED_BY,
   --             ASSIGNED_OWNER_NAME,
   --             DOC_UPLOAD_FLAG,
   --             FRAUD_FLAG,
   --             FRAUD_DETAILS,
   --             PLACE_OF_REGISTRATION,
   --             PT_PARTY_CODE,
   --             CESSION_PERC,
   --             RI_RETENTION_PERCENTAGE,
   --             RI_RETENTION_PAID_AMOUNT,
   --             RI_RETENTION_OS_AMOUNT,
   --             NULL,
   --             SYSDATE
   --        FROM MV_CLAIM_REGISTER
   --       WHERE C_CLAIM_NO IN
   --                (SELECT C_CLAIM_NO
   --                   FROM MV_CLAIM_REGISTER
   --                  WHERE T_DATE_DESC > TRUNC (SYSDATE) - 6
   --                 UNION
   --                 SELECT C_CLAIM_NO FROM PROD.DL_ODS_CLAIM_DIM_HIST);
   --
   --
   --
   --   LOGTRACE (
   --      ''''LOG'''',
   --      10001,
   --         ''''AWS mv_claim_register inserted -- time taken in mins : ''''
   --      || TO_CHAR ( (DBMS_UTILITY.GET_TIME - L_START) / 100 / 60),
   --      ''''BJAZ_REFRESH_MV_CLAIM'''');


BEGIN
  v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.mv_claim_reg_closed'';

 EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT /*+APPEND*/
            INTO  INTERMEDIATE.MV_CLAIM_REG_CLOSED
                  (	C_CLAIM_NO,
	C_CLAIM_ID_SK ,
	C_ACCIDENT_LOC ,
	C_LOSS_TIME ,
	CLM_STATUS,
	TOP_INDICATOR,
	C_OFF_LOC_ID ,
	P_POLICY_NUMBER,
	POLICY_LOCATION_ID ,
	P_PRODUCT_ID ,
	P_RISK_INC_DATE ,
	P_RISK_EXPIRY_DATE ,
	I_IMD_DESC,
	P_SUB_IMD ,
	IMD_CHANNEL ,
	V_VEHICLE_MAKE ,
	P_YEAR_OF_MANU ,
	M_VEHICLE_MODEL ,
	P_REGN_NO ,
	PT_PARTNER_ID ,
	PT_PARTNER_DESC,
	PT_PARTNER_CITY ,
	C_COMMENTS ,
	C_CLAIM_TYPE ,
	C_CAUSE_OF_LOSS ,
	C_REP_NAME ,
	C_NAME_OF_IN1,
	C_REGN_DATE ,
	C_CLO_DATE ,
	C_LOSS_DATE ,
	C_INTI_DATE ,
	C_SUR_NAME ,
	C_APP_DATE ,
	C_POLICY_GRAIN ,
	C_CLAIM_REGD_BY ,
	C_LAST_REOPEN_DATE ,
	C_PAID_FLAG ,
	CONSUMER_FORUM_FLAG,
	C_OMBSMAN_FLAG ,
	C_LIGITATION_FLAG ,
	P_DEPARTMENT_DESC,
	REOPEN_FLAG,
	REN_ROLL_NB_FLAG,
	TP_POOL_FLAG,
	POOL_PAID_FLAG ,
	P_MASTER_POLICY_NO,
	P_REN_INDICATOR,
	C_COURT_FLAG ,
	C_SUR_REP_DATE ,
	P_POLICY_ISSUE_DATE ,
	P_COINSURANCE_TYPE,
	T_DATE_DESC ,
	CP_COMPANY_NAME ,
	R_RESERVE_GROUP_DESC ,
	R_RESERVE_DESC ,
	P_GEOGRAPHIC_SCOPE ,
	P_GC_PLAN ,
	P_ENGINE_NUMBER ,
	P_CHASSIS_NUMBER ,
	C_SETTLEMNT_TYPE ,
	C_ALL_DOC_DATE ,
	C_SPECIAL_COMMENTS ,
	C_MRN_TRANSPORTER_NAME ,
	C_INVOICE_NO ,
	RUNNER_NAME,
	RUNNER_CODE,
	BRANCH_RESP ,
	CSE_CODE ,
	PT_HOUSE_HOLD_ID,
	PT_CLUSTER_ID ,
	CASE_YEAR,
	HO_ID ,
	NEXT_COURT_H_DATE ,
	CASE_TITLE,
	CASE_PREFIX ,
	COURT_STAGE ,
	TP_COMPRO_DEFENSE ,
	STATUS_OF_INVESTIGATION_REPORT ,
	DECISION_ON_AWARD ,
	DETAILS_OF_FOLLOWUP,
	INVESTIGATION_APPOINTMENTDATE,
	TP_COURT_REMARKS ,
	INVEST_REPORT_RECEIVINGDATE,
	C_ADV_NAME ,
	P_NCB_PERCENT,
	P_NCB_AMOUNT ,
	P_COVER_NOTE_NO,
	P_POLICY_STATUS ,
	C_RECPT_PSR_DATE,
	C_RECPT_FSR_DATE ,
	C_SUR_APP_DATE ,
	C_DELAY_REASON ,
	C_EMEDITEK_CLAIM_NO ,
	REMARKS_OFLEGAL_OFFICER,
	PT_PARTNER_TYPE ,
	C_RFA_DATE ,
	C_EVENT_CODE ,
	C_TPA_STATUS ,
	PT_PARTNER_REGION,
	PT_PARTNER_REGION_STND ,
	C_INVOICE_DATE ,
	C_FSR_PSR_STATUS ,
	P_FUEL_TYPE ,
	POLICY_AGE ,
	VEHICLE_REG_DATE ,
	TP_COMPROMISE ,
	PARTNER_PIN_CODE ,
	PARTNER_CITY ,
	OLD_POLICY_NO ,
	PAID_CLAIM ,
	RESERVE_AMOUNT ,
	OS_AMT ,
	SALVAGE_AMT ,
	SERVICE_TAX ,
	POOL_SALVAGE_AMT ,
	POOL_PAID_BEFORE_SALVAGE ,
	POOL_PAID_AFTER_SALVAGE ,
	NET_PAID ,
	NET_TAX ,
	C_PLACE_OF_LOSS ,
	C_LANDMARK ,
	C_AREA ,
	C_STATE ,
	C_CITY ,
	C_PINCODE,
	C_JOURNEY_FROM ,
	C_JOURNEY_TO ,
	C_CONSIGNEE_NAME ,
	C_CONSIGNER_NAME ,
	C_SURVEY_LOCATION ,
	C_GOODS_DETAILS ,
	P_COVERNOTE_DATE ,
	V_VEHICLE_TYPE ,
	I_IMD_NAME,
	C_NEXT_RVW_DATE ,
	C_LAST_RVW_REMARKS ,
	P_OLD_POL_EXP_DATE ,
	PT_PARTNER_TELEPHONE ,
	TP_RESP_PERSON ,
	TP_CLM_HANDLING_LOC ,
	PT_PARTNER_ADDRESS,
	C_FPLM_FLAG ,
	C_CLAIM_ID ,
	C_REOPEN_REMARK ,
	C_REOPEN_BY ,
	BASE_SUM_INSURED,
	POL_GLOBAL_FLAG ,
	P_EMP_CODE ,
	ADDL_EXCESS ,
	VOLUNTARY_EXCESS ,
	COMPULSORY_EXCESS ,
	EXPENSE_APP_DATE ,
	LOSS_APP_DATE ,
	NET_ASSESSED_AMOUNT ,
	DEPRECIATION_AMOUNT ,
	P_SUB_CHANNEL_CODE ,
	P_FIRE_LOC_NAME ,
	P_FIRE_LOC_TYPE ,
	P_FIRE_OCCUPANCY ,
	P_FIRE_RISK_TYPE ,
	P_VEHICLE_GVW ,
	M_VEHICLE_SEGMENT ,
	C_PORTAL_FLAG ,
	C_MLT_YEAR ,
	MAXIMUS_FLAG ,
	MIN_RFA_DATE ,
	MAX_RFA_DATE ,
	RFA_RAISED_BY ,
	RFA_APPROVED_BY ,
	ASSIGNED_OWNER_NAME ,
	DOC_UPLOAD_FLAG ,
	FRAUD_FLAG ,
	FRAUD_DETAILS ,
	PLACE_OF_REGISTRATION ,
	PT_PARTY_CODE ,
	CESSION_PERC ,
	RI_RETENTION_PERCENTAGE ,
	RI_RETENTION_PAID_AMOUNT,
	RI_RETENTION_OS_AMOUNT ,
	DWH_REMARK ,
	CHANGE_DATE ,
	PT_PARTNER_PRIVE_FLAG ,
	TRANS_TYPE ,
	TRUNC_CHANGE_DATE)
         SELECT
        C_CLAIM_NO,
	C_CLAIM_ID_SK ,
	C_ACCIDENT_LOC ,
	C_LOSS_TIME ,
	CLM_STATUS,
	TOP_INDICATOR,
	C_OFF_LOC_ID ,
	P_POLICY_NUMBER,
	POLICY_LOCATION_ID ,
	P_PRODUCT_ID ,
	P_RISK_INC_DATE ,
	P_RISK_EXPIRY_DATE ,
	I_IMD_DESC,
	P_SUB_IMD ,
	IMD_CHANNEL ,
	V_VEHICLE_MAKE ,
	P_YEAR_OF_MANU ,
	M_VEHICLE_MODEL ,
	P_REGN_NO ,
	PT_PARTNER_ID ,
	PT_PARTNER_DESC,
	PT_PARTNER_CITY ,
	C_COMMENTS ,
	C_CLAIM_TYPE ,
	C_CAUSE_OF_LOSS ,
	C_REP_NAME ,
	C_NAME_OF_IN1,
	C_REGN_DATE ,
	C_CLO_DATE ,
	C_LOSS_DATE ,
	C_INTI_DATE ,
	C_SUR_NAME ,
	C_APP_DATE ,
	C_POLICY_GRAIN ,
	C_CLAIM_REGD_BY ,
	C_LAST_REOPEN_DATE ,
	C_PAID_FLAG ,
	CONSUMER_FORUM_FLAG,
	C_OMBSMAN_FLAG ,
	C_LIGITATION_FLAG ,
	P_DEPARTMENT_DESC,
	REOPEN_FLAG,
	REN_ROLL_NB_FLAG,
	TP_POOL_FLAG,
	POOL_PAID_FLAG ,
	P_MASTER_POLICY_NO,
	P_REN_INDICATOR,
	C_COURT_FLAG ,
	C_SUR_REP_DATE ,
	P_POLICY_ISSUE_DATE ,
	P_COINSURANCE_TYPE,
	T_DATE_DESC ,
	CP_COMPANY_NAME ,
	R_RESERVE_GROUP_DESC ,
	R_RESERVE_DESC ,
	P_GEOGRAPHIC_SCOPE ,
	P_GC_PLAN ,
	P_ENGINE_NUMBER ,
	P_CHASSIS_NUMBER ,
	C_SETTLEMNT_TYPE ,
	C_ALL_DOC_DATE ,
	C_SPECIAL_COMMENTS ,
	C_MRN_TRANSPORTER_NAME ,
	C_INVOICE_NO ,
	RUNNER_NAME,
	RUNNER_CODE,
	BRANCH_RESP ,
	CSE_CODE ,
	PT_HOUSE_HOLD_ID,
	PT_CLUSTER_ID ,
	CASE_YEAR,
	HO_ID ,
	NEXT_COURT_H_DATE ,
	CASE_TITLE,
	CASE_PREFIX ,
	COURT_STAGE ,
	TP_COMPRO_DEFENSE ,
	STATUS_OF_INVESTIGATION_REPORT ,
	DECISION_ON_AWARD ,
	DETAILS_OF_FOLLOWUP,
	INVESTIGATION_APPOINTMENTDATE,
	TP_COURT_REMARKS ,
	INVEST_REPORT_RECEIVINGDATE,
	C_ADV_NAME ,
	P_NCB_PERCENT,
	P_NCB_AMOUNT ,
	P_COVER_NOTE_NO,
	P_POLICY_STATUS ,
	C_RECPT_PSR_DATE,
	C_RECPT_FSR_DATE ,
	C_SUR_APP_DATE ,
	C_DELAY_REASON ,
	C_EMEDITEK_CLAIM_NO ,
	REMARKS_OFLEGAL_OFFICER,
	PT_PARTNER_TYPE ,
	C_RFA_DATE ,
	C_EVENT_CODE ,
	C_TPA_STATUS ,
	PT_PARTNER_REGION,
	PT_PARTNER_REGION_STND ,
	C_INVOICE_DATE ,
	C_FSR_PSR_STATUS ,
	P_FUEL_TYPE ,
	POLICY_AGE ,
	VEHICLE_REG_DATE ,
	TP_COMPROMISE ,
	PARTNER_PIN_CODE ,
	PARTNER_CITY ,
	OLD_POLICY_NO ,
	PAID_CLAIM ,
	RESERVE_AMOUNT ,
	OS_AMT ,
	SALVAGE_AMT ,
	SERVICE_TAX ,
	POOL_SALVAGE_AMT ,
	POOL_PAID_BEFORE_SALVAGE ,
	POOL_PAID_AFTER_SALVAGE ,
	NET_PAID ,
	NET_TAX ,
	C_PLACE_OF_LOSS ,
	C_LANDMARK ,
	C_AREA ,
	C_STATE ,
	C_CITY ,
	C_PINCODE,
	C_JOURNEY_FROM ,
	C_JOURNEY_TO ,
	C_CONSIGNEE_NAME ,
	C_CONSIGNER_NAME ,
	C_SURVEY_LOCATION ,
	C_GOODS_DETAILS ,
	P_COVERNOTE_DATE ,
	V_VEHICLE_TYPE ,
	I_IMD_NAME,
	C_NEXT_RVW_DATE ,
	C_LAST_RVW_REMARKS ,
	P_OLD_POL_EXP_DATE ,
	PT_PARTNER_TELEPHONE ,
	TP_RESP_PERSON ,
	TP_CLM_HANDLING_LOC ,
	PT_PARTNER_ADDRESS,
	C_FPLM_FLAG ,
	C_CLAIM_ID ,
	C_REOPEN_REMARK ,
	C_REOPEN_BY ,
	BASE_SUM_INSURED,
	POL_GLOBAL_FLAG ,
	P_EMP_CODE ,
	ADDL_EXCESS ,
	VOLUNTARY_EXCESS ,
	COMPULSORY_EXCESS ,
	EXPENSE_APP_DATE ,
	LOSS_APP_DATE ,
	NET_ASSESSED_AMOUNT ,
	DEPRECIATION_AMOUNT ,
	P_SUB_CHANNEL_CODE ,
	P_FIRE_LOC_NAME ,
	P_FIRE_LOC_TYPE ,
	P_FIRE_OCCUPANCY ,
	P_FIRE_RISK_TYPE ,
	P_VEHICLE_GVW ,
	M_VEHICLE_SEGMENT ,
	C_PORTAL_FLAG ,
	C_MLT_YEAR ,
	MAXIMUS_FLAG ,
	MIN_RFA_DATE ,
	MAX_RFA_DATE ,
	RFA_RAISED_BY ,
	RFA_APPROVED_BY ,
	ASSIGNED_OWNER_NAME ,
	DOC_UPLOAD_FLAG ,
	FRAUD_FLAG ,
	FRAUD_DETAILS ,
	PLACE_OF_REGISTRATION ,
	PT_PARTY_CODE ,
	CESSION_PERC ,
	RI_RETENTION_PERCENTAGE ,
	RI_RETENTION_PAID_AMOUNT,
	RI_RETENTION_OS_AMOUNT ,
	DWH_REMARK ,
	CHANGE_DATE ,
	PT_PARTNER_PRIVE_FLAG ,
	TRANS_TYPE ,
	TRUNC_CHANGE_DATE
           FROM TRANSACTIONAL.MV_CLAIM_REGISTER
          WHERE CLM_STATUS = ''''CLOSED'''' AND NVL (C_CLAIM_TYPE, ''''OD'''') = ''''TP'''''';

		  EXECUTE IMMEDIATE v_sqltext;

   END;


-- /*CALL    LOGTRACE (*/
-- /*      ''''LOG'''',*/
-- /*      10001,*/
-- /*         ''''AWS mv_claim_register inserted -- time taken in mins : ''''*/
-- /*      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),*/
-- /*      ''''BJAZ_REFRESH_MV_CLAIM'''');*/
-- /*L_START := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


BEGIN
v_sqltext := ''DELETE
            FROM  TRANSACTIONAL.BJAZ_SETTLED_TP_CLAIM_MV
            WHERE CLAIM_NO IN
                     (SELECT C_CLAIM_NO
                        FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
                             PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY B
                       WHERE     C_CLAIM_TYPE = ''''TP''''
                             AND UPPER (STATUS) = ''''REOPENED''''
                             AND TOP_INDICATOR = ''''Y''''
                             AND A.C_CLAIM_ID = B.CLAIM_ID
                             AND DATE_TRUNC(''''DAY'''', MSG_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                             AND T_DATE_DESC = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1)'';

EXECUTE IMMEDIATE v_sqltext;

SELECT DATEADD(DAY, 1, MAX (DATE_TRUNC(''DAY'', CLAIM_CLOSURE_DATE)))
        INTO :TP_SETTLED_LOADDATE
      FROM TRANSACTIONAL.BJAZ_SETTLED_TP_CLAIM_MV;

--EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO TRANSACTIONAL.BJAZ_SETTLED_TP_CLAIM_MV
         SELECT
               CB.LOC_CODE CLAIM_OFFICE_LOCATION,
                CD.HO_ID HO_ID,
                CD.HO_ID NEW_HO_ID,
                B.CONN_COUNT,
                   CD.CASE_NUMBER
                || ''''/''''
                || NVL (SUBSTR (CD.CASE_YEAR, 3, 4), ''''na'''')
                   CASE_YEAR,
                CD.COURT_LOCATION COURT_LOCATION,
                NVL (SD.NAME_OF_JUDGE, ''''na'''') NAME_OF_JUDGE,
                CB.CLM_REF CLAIM_NO,
                TO_DATE (SUBSTR (CB.LUA_VALUE_1, 1, 10), ''''dd-mm-yyyy'''')
                   CLAIM_CLOSURE_DATE,
                CD.EXTRA_FIELD1 CAUSE_OFLOSS_TPPD_TPBI_DEATH,
                IDD.OCCUPATION OCCUPATION_OF_VICTIM,
                NVL (SD.INCOME_BY_COURT_OF_VICTIM, 0)
                   INCOME_CONSIDERCOURT_OF_VICTIM,
                NVL (INDD.INCOME_CLAIMED, 0) INCOME_DEPOSED_IN_PETITION,
                NVL (SD.ACTUAL_INCOME_ORAL, 0) ACT_INCOME_DOCUMENTARYPROOF,
                NVL (SD.ACTUAL_INCOME_DOC, 0) ACT_INCOME_ORAL_PROOF,
                SD.DISMISSED  "DEW",
                NVL (SD.EXTENT_OF_LIABLITY, 0) AMT_AWARDED_IN_CASE_OFDEW,
                TO_CHAR (SD.DATE_OF_FINAL_ORDER, ''''DD-MM-YYYY'''')
                   DATE_FINL_ORDER_JUDGNT_AWARD,
                TO_CHAR (CD.DATE_OF_CASE_FILING, ''''DD-MM-YYYY'''')
                   DATE_FILING_CASE,
                DATEDIFF(''''DAY'''',SD.DATE_OF_FINAL_ORDER,CD.DATE_OF_CASE_FILING)
                DIFFERENCE_INNO_DAYS,
                SD.COMPROMISED COMPROMISE,
                SD.COMPROMISED JUDGEMENT_ON_MERIT,
                --max( case when gen_clm.trans_amt is not null and gen_clm.ip_type =''''tp''''    then ''''y'''' else ''''n''''
                --end)
                ''''na'''' INTRIM_FLAG,
                ''''na'''' INTRIM_PAYEMET,
                ''''na'''' FINAL_PAYMENT_AMT,
                ''''na'''' NOOF_DAYEINT_PAID,
                SD.AMT_COMPROMISED AMOUNT_COMPROMISED_AWARDED,
                SD.BIFURCATION_AMOUNT BIFURCATION_AMT_AGNST_CLAIMANT,
                ''''na'''' INTERESTAMOUNT_PAID,
                PD.INTEREST_PER_AWARDED RATE_OF_INTEREST,
                PD.COST_AWARDED COST_EXPENSES_PAID,
                (SELECT SUM (NVL (A.TRANS_AMT, 0))
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL A
                  WHERE     A.IP_TYPE IN (''''ADV'''', ''''LAW'''')
                        AND A.CLM_REF = CB.CLM_REF)
                   ADVOCATE_FEES,
                (SELECT SUM (NVL (A.TRANS_AMT, 0))
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL A
                  WHERE A.IP_TYPE = ''''INV'''' AND A.CLM_REF = CB.CLM_REF)
                   INVESTIGATE_FEES,
                (SELECT SUM (NVL (A.TRANS_AMT, 0))
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL A
                  WHERE A.IP_TYPE = ''''SUR'''' AND A.CLM_REF = CB.CLM_REF)
                   SURV_FEES,
                (SELECT SUM (NVL (A.TRANS_AMT, 0))
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL A
                  WHERE A.PAY_STATUS != ''''DELETED'''' AND A.CLM_REF = CB.CLM_REF)
                   TOTAL_PAYEMENT,
                C_ADV_NAME,
                --max (case when adv.represents = ''''BAGIC'''' then NVL (adv.name, null) end) name_ofour_advcoate,
                --adv.name "name of our advcoate",
                IDD.AGE AGE_OFINJURED_ORDECEASED,
                SD.LESS_SIMPLE_INJURY LESS_THN_5_SIMPLE_INJURIES,
                SD.MORE_SIMPLE_INJURY MORE_THN_5_SIMPLE_INJURIES,
                SD.GRIEVOUS_HEAD_INJURY GRIEVOUS_HEAD_INJURY,
                SD.GRIEVOUS_FRACT_INJURY GRIEVOUS_FRACTURES_INJURY,
                IDD.SKELETON_INJURY_DTL DTL_FRACTURE_INJ_GREVIOUS_INJ,
                TID.DIS_PER_PANEL_DOC DISABILITY_PERCENTAGE,
                SD.AMT_MEDICAL_EXPENS AMT_OF_MEDICALBILLSON_RECORD,
                SUBSTR (CB.CLM_REF, 12, 4) PRODUCT_CODE,
                VDD.MAKE_CODE VEHICLE_MAKEL,
                VDD.MODEL_CODE VEHICLE_MODEL,
                VD.VEHICLE_TYPE TYPE_OFOTHER_VEHICLE,
                SD.POSITION_OF_INJURED POSITION_OF_INJURED,
                BGDRIVER.NAME NAME_OF_OURDRIVER,
                BGDRIVER.AGE AGE_OF_OURDRIVER,
                   BGDRIVER.CURRENT_LICENSE_NO
                || ''''/''''
                || DU.VEHICLE_DESC
                || ''''/''''
                || BGDRIVER.CURR_LIC_VALID_FROM_TRANS
                || ''''/''''
                || BGDRIVER.CURR_LIC_VALID_UPTO_TRANS
                || ''''/''''
                || BGDRIVER.CURR_LIC_VALID_FROM_NT
                || ''''/''''
                || BGDRIVER.CURR_LIC_VALID_UPTO_NT
                || ''''/''''
                || BGDRIVER.OLD_LICENSE_VALID_FROM
                || ''''/''''
                || BGDRIVER.OLD_LICENSE_VALID_UPTO
                || ''''/''''
                || BGDRIVER.ENDORSEMENT_VALID_FROM
                || ''''/''''
                || BGDRIVER.ENDORSEMENT_VALID_UPTO
                || ''''/''''
                || BGDRIVER.ENDORSEMENT_DTLS
                   DL_NO_AUTH_DRIVE_VALID_PERIOD,
                BGDRIVER.CURRENT_RTO_AUTH NAME_OF_DL_ISSUING_RTO_LA,
                AD.ACCIDENT_PLACE PALCE_OF_ACCIDENT,
                P_POLICY_NUMBER,
                -- cpb.policy_ref policy_ref,
                POLICY_LOCATION_ID "policy_location",
                   TO_CHAR (DATE_TRUNC(''''DAY'''', P_RISK_INC_DATE), ''''yyyy'''')
                || ''''-''''
                || TO_CHAR (DATE_TRUNC(''''DAY'''', P_RISK_EXPIRY_DATE), ''''yy'''')
                   "policy_issu_year",
                CASE WHEN VD.VEHICLE_TYPE IS NULL THEN ''''1'''' ELSE ''''2'''' END
                   "howmanyv_in_acc",
                AD.ACCIDENT_DATE "Date of Accident",
                TID.SPOT_DEATH || '''''''' || TID.DEATH_DATE
                   "spotDate_of_Death_ifoccurred",
                 FD.FIR_DATE "Date_of_FIR",
                FD.FIR_DELAY "NO_days_deleyed_lodging_FIR",
                SD.AMT_DISABILITY "amount_awarded_for_disability",
                SD.AMT_PAIN_SUFFER "amount_pain_suffering",
                SD.AMT_FRACTURES "amount_awarded_fractures",
                SD.AMT_SPECIAL_DIET "amount_awardedspecial_diet",
                NVL (SD.AMT_MEDICAL_EXPENS, 0)
                   "Amt_awarded_Medical_Exp_incur",
                NVL (SD.AMT_FUTURE_MEDICAL_EXPENS, 0)
                   "Amt_awarded_future_medical_exp",
                SD.LOSS_OF_AMINITIES "amount_loss_amen_enjoy_life",
                NVL (SD.AMT_FOR_INCOME, 0) "amt_awd_income_sal_period",
                NVL (SD.FUTURE_LOSS_INCOME, 0)
                   "amt_award_future_income_salary",
                NVL (SD.AMT_SPECIAL_HEAD, 0) "Amt_awarded_other_special_head",
                NVL (SD.AMT_FOR_TRANSPORT, 0)
                   "amt_award_transport_conveyance",
                TO_CHAR (INV.APPOINTMENT_DATE, ''''DD-MM-YYYY'''')
                   "Investigation_appointmentdate",
                TO_CHAR (INV.REPORT_RECEIVING_DATE, ''''DD-MM-YYYY'''')
                   "Invest_report_receivingdate",
                -- (INV.REPORT_RECEIVING_DATE) - (INV.APPOINTMENT_DATE)
                --    "NO_ofdaystaken_IN",
				DATEDIFF(DAY, INV.REPORT_RECEIVING_DATE, INV.APPOINTMENT_DATE) AS "NO_ofdaystaken_IN",

                TCD.EXTRA_FIELD1 "Casescited_bythe_Applicant",
                TCD.CASE_LAWS_REFERRED "Casescited_by-BAGIC",
                TCD.EXTRA_FIELD2 "Case_lookedintoby_Court",
                AD.ACCIDENT_DESC_ELAB BRIEF_DETAILS_OFTHE_ACCIDENT,
                SD.REMARKS "Remarks",
                CASE
                   WHEN SD.DISMISSED_REASON != ''''Others''''
                   THEN
                      SD.DISMISSED_REASON
                   ELSE
                      SD.OTHER_DISMISSED_REASON
                END
                   DEFENCE_REASON_DTL_FOR_EWD,
                SD.DEW_AMOUNT APROXIMATE_AMT_SAVED_DEWCASES,
                ''''na'''' MANNER_OF_INTIMATION,
                ''''na'''' INTIMATION_RECEIPT_DATE,
                ''''na'''' INTIMATION_ID,
                C_COMMENTS CLOSURE_REMARKS,
                C_SPECIAL_COMMENTS,
             NULL AS INC_JOB_CREATED_AT,
             NULL AS INC_JOB_CREATED_BY,
             NULL AS INC_JOB_UPDATED_BY,
             NULL AS INC_JOB_UPDATED_AT,
             NULL AS INC_JOB_ID

           FROM (  SELECT LISTAGG(VEHICLE_DESC,'''','''') VEHICLE_DESC, CLAIM_ID
                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_BAGIC_DRIV_AUTH
                 GROUP BY CLAIM_ID) DU,
                (  SELECT COUNT (DISTINCT A.CLAIM_ID) - 1 CONN_COUNT,
                          A.POLICY_REF
                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES A,
                     ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT B
                    WHERE          --a.policy_ref = ''''OC-07-1804-1803-00000033''''
                          ---and
                          A.CLAIM_ID = B.CLAIM_ID AND B.CLM_TYPE = ''''TP''''
                 GROUP BY A.POLICY_REF) B,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CB,
                --- clm_pol_bases cpb,
                ----clm_trans ct,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_OTHER_VEH_DTL VD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_VEHICLE_DTL VDD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_CASE_DTL CD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_SETTLED_DATA SD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_INJ_DEATH_DTL IDD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_PAYMENT_DTL PD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_INJURY_DTL IND,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_INJ_DEATH_DTL INDD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_ACCIDENT_DTL AD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_BAGIC_DRIVER BGDRIVER,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_FIR_DTL FD,
                ----bjaz_gen_clm_approval gen_clm,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_INVESTIGATOR INV,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_TPPD_DTL TDD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_COURT_DTL TCD,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_TPPI_DTL TID,
                INTERMEDIATE.MV_CLAIM_REG_CLOSED
          WHERE     MV_CLAIM_REG_CLOSED.C_CLAIM_NO = CB.CLM_REF
                AND C_CLAIM_ID = CB.CLAIM_ID
                AND MV_CLAIM_REG_CLOSED.TOP_INDICATOR = ''''Y''''
                AND C_CLO_DATE BETWEEN   TO_DATE(''''''|| TP_SETTLED_LOADDATE ||'''''')
                                  AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                AND T_DATE_DESC >= TO_DATE(''''''|| TP_SETTLED_LOADDATE ||'''''')
                AND P_POLICY_NUMBER = POLICY_REF(+)
                AND CB.CLAIM_ID = VDD.CLAIM_ID(+)
                AND CB.CLAIM_ID = CD.CLAIM_ID
                AND CD.CLAIM_ID = DU.CLAIM_ID(+)
                AND CD.CLAIM_ID = SD.CLAIM_ID(+)
                AND CD.CLAIM_ID = PD.CLAIM_ID(+)
                AND CD.CLAIM_ID = IDD.CLAIM_ID(+)
                AND CD.CLAIM_ID = IND.CLAIM_ID(+)
                AND CD.CLAIM_ID = VD.CLAIM_ID(+)
                AND CD.CLAIM_ID = INDD.CLAIM_ID(+)
                AND CD.CLAIM_ID = AD.CLAIM_ID(+)
                AND CD.CLAIM_ID = BGDRIVER.CLAIM_ID(+)
                AND CD.CLAIM_ID = FD.CLAIM_ID(+)
                AND CD.CLAIM_ID = INV.CLAIM_ID(+)
                AND CD.CLAIM_ID = TDD.CLAIM_ID(+)
                AND CD.CLAIM_ID = TCD.CLAIM_ID(+)
                AND CD.CLAIM_ID = TID.CLAIM_ID(+)'';

EXECUTE IMMEDIATE v_sqltext;

END;

-- /*CALL LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''Total Time  BJAZ_TP_SETTLED_CLAIM_MV- time taken in mins : ''''
--       || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');*/

-- /*--added by chandrakant(26-feb-2020)---*/

BEGIN
v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET C_ALL_DOC_DATE = src.INSERTED_ON, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
  SELECT * FROM (  SELECT CLM_INTIM_ID, MAX (INSERTED_ON) INSERTED_ON
                            FROM (SELECT CLM_INTIM_ID,
                                         DATE_TRUNC (''''DAY'''',
                                            CASE
                                               WHEN B.STATUS_ID IN (2, 13)
                                               THEN
                                                  B.INSERTED_ON
                                            END)
                                            INSERTED_ON
                                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_FK_CLM_REGISTRATION_MV A,
                                         PROD_DWH_MIGRATED_DB.STAGE.BJAZ_FK_CLM_STATUS_DTLS_MV B,
                                         TRANSACTIONAL.MV_CLAIM_REGISTER C
                                   WHERE     A.CLAIM_CL_ID = B.CLAIM_CL_ID
                                         AND CLM_INTIM_ID = C_CLAIM_NO
                                         AND P_PRODUCT_ID IN
                                                (''''6615'''', ''''6616'''', ''''9936'''')
                                         AND TOP_INDICATOR = ''''Y''''
                                         AND T_DATE_DESC >= DATE_TRUNC (''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 5)
                        )
                 WHERE INSERTED_ON IS NOT NULL
GROUP BY CLM_INTIM_ID)

) as src
WHERE target.C_CLAIM_NO = src.CLM_INTIM_ID'';

EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
    SET C_ALL_DOC_DATE = src.INSERTED_ON,
    CHANGE_DATE = TO_DATE('''''' || T_DATE || ''''''),
    TRUNC_CHANGE_DATE = DATE_TRUNC (''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
FROM
(
  SELECT * FROM (  SELECT CLM_INTIM_ID, MAX (INSERTED_ON) INSERTED_ON
                            FROM (SELECT CLM_INTIM_ID,
                                         DATE_TRUNC (''''DAY'''',
                                            CASE
                                               WHEN B.STATUS_ID IN (2, 13)
                                               THEN
                                                  B.INSERTED_ON
                                            END)
                                            INSERTED_ON
                                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_FK_CLM_REGISTRATION_MV A,
                                         PROD_DWH_MIGRATED_DB.STAGE.BJAZ_FK_CLM_STATUS_DTLS_MV B,
                                         TRANSACTIONAL.MV_CLAIM_REGISTER C
                                   WHERE     A.CLAIM_CL_ID = B.CLAIM_CL_ID
                                         AND CLM_INTIM_ID = C_CLAIM_NO
                                         AND P_PRODUCT_ID IN
                                                (''''6615'''', ''''6616'''', ''''9936'''')
                                         AND TOP_INDICATOR = ''''Y''''
                                         AND T_DATE_DESC >= DATE_TRUNC (''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 5)
                        )
                 WHERE INSERTED_ON IS NOT NULL
GROUP BY CLM_INTIM_ID)

) as src
WHERE target.C_CLAIM_NO = src.CLM_INTIM_ID'';

EXECUTE IMMEDIATE v_sqltext;

END;

-- SEND_SMS_PROC (
--             ''''DWH LOAD MV_CLAIM_REGISTER TP ''''
--          || SYSDATE
--          || '''' - ''''
--          || SQLERRM
--          || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--          ''''8379865547'''',
--          ''''D'''');
--    END;

--    LOGTRACE (
--       ''''LOG'''',
--       10001,
--          ''''Comeplete time in BJAZ_REFRESH_MV_CLAIM''''
--       || TO_CHAR ( (DBMS_UTILITY.GET_TIME - L_START) / 100 / 60),
--       ''''BJAZ_REFRESH_MV_CLAIM'''');
-- EXCEPTION
--    WHEN OTHERS
--    THEN
--       LOGTRACE (
--          ''''ERR'''',
--          10001,
--             ''''Error in bjaz_refresh_mv_claim claim load: ''''
--          || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE ()
--          || SQLCODE
--          || SQLERRM,
--          ''''bjaz_refresh_mv_claim'''');
--       SEND_SMS_PROC (
--             ''''DWH LOAD Error in bjaz_refresh_mv_claim  load @ ''''
--          || SYSDATE
--          || '''' - ''''
--          || SQLERRM
--          || '''' caringly yours, Bajaj Allianz General Insurance Co Ltd.'''',
--          ''''8379865547'''',
--          ''''D'''');

EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\\\n'' || ''SQL: '' || ''\\\\n'' || v_sqltext;


END;
';