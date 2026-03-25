CREATE OR REPLACE PROCEDURE TRANSACTIONAL.BJAZ_MAXIMUS_CR_LOAD("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '

DECLARE
v_sqltext VARCHAR;

begin

/* Formatted on 24/01/2025 15:27:34 (QP5 v5.215.12089.38647) */

v_sqltext := ''TRUNCATE TABLE IF EXISTS TRANSACTIONAL.ODI_ODS_CLAIM_DIM_BNC'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO TRANSACTIONAL.ODI_ODS_CLAIM_DIM_BNC
      SELECT UTILS.SEQ_ODS_CLAIM_TYPE_DIM_SK_NEXTVAL.NEXTVAL,
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
             NULL NET_ASSESSED_AMOUNT,
             NULL DEPRECIATION_AMOUNT,
             C_CLAIM_MODE AS C_PORTAL_FLAG,
             CASE
                WHEN UPPER (C_CLAIM_STATUS) = ''''OPEN''''
                THEN
                   ''''Open''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''CLOSE''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''CLOSED WITH PAYMENT''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''CLOSED WITHOUT PAYMENT''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''REJECTED''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) =
                        ''''CLOSED WITH ONLY EXPENSE PAYMENT''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''SETTLED''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''PROCESSED''''
                THEN
                   ''''Open''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''INTIMATED''''
                THEN
                   ''''Open''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''REOPENED''''
                THEN
                   ''''Open''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''DISPUTED''''
                THEN
                   ''''Open''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''PAID AND CLOSED''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''REPUDIATED AND CLOSED''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''CASHLESS DENIED''''
                THEN
                   ''''Closed''''
                WHEN UPPER (C_CLAIM_STATUS) = ''''REGISTERED''''
                THEN
                   ''''Open''''
             END
                C_CLAIM_STATUS_BNC,
             C_POLICY_NUMBER,
             DATE_TRUNC (''''DAY'''',LAST_UPDATE_DATE) LAST_UPDATE_DATE,
             C_CLAIM_MODE,
             CURRENT_DATE ODI_LOAD_DATE,
			 NULL AS INC_JOB_CREATED_AT,
			 NULL AS INC_JOB_CREATED_BY,
			 NULL AS INC_JOB_ID,
			 NULL AS INC_JOB_UPDATED_AT ,
			 NULL AS INC_JOB_UPDATED_BY
        FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_CLAIM_DIM'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_MAXI_ODS_RESERVE_DIM'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.STG_MAXI_ODS_RESERVE_DIM
    SELECT R_RESERVE_TYPE_ID_SK,
	R_RESERVE_TYPE,
	R_RESERVE_DESC,
	R_RESERVE_GROUP_DESC,
	R_ALL_RESERVE_TYPES,
	R_RESERVE_FLAG
	--CREATED_DATE,
	--LAST_UPDATED_DATE
        --FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_RESERVE_DIM a
        FROM TRANSACTIONAL.odi_ods_reserve_dim a
       WHERE NOT EXISTS
                (SELECT 1
                   FROM TRANSACTIONAL.ODS_RESERVE_DIM b
                  WHERE UPPER (b.r_reserve_type) = UPPER (a.r_reserve_type))'';
                  EXECUTE IMMEDIATE v_sqltext;

-- v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_RESERVE_DIM
--       SELECT UTILS.RESERVE_ID_SK_SEQ.NEXTVAL r_reserve_type_id_sk,
--              r_reserve_type,
--              r_reserve_desc,
--              r_reserve_group_desc,
--              r_all_reserve_types,
--              r_reserve_flag
-- FROM INTERMEDIATE.STG_MAXI_ODS_RESERVE_DIM'';
-- EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_RESERVE_DIM
(
r_reserve_type_id_sk,
 r_reserve_type,
             r_reserve_desc,
             r_reserve_group_desc,
             r_all_reserve_types,
             r_reserve_flag)
      SELECT UTILS.RESERVE_ID_SK_SEQ.NEXTVAL r_reserve_type_id_sk,
             r_reserve_type,
             r_reserve_desc,
             r_reserve_group_desc,
             r_all_reserve_types,
             r_reserve_flag
FROM INTERMEDIATE.STG_MAXI_ODS_RESERVE_DIM'';

EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_MAXI_ODS_CLAIM_DIM'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.STG_MAXI_ODS_CLAIM_DIM
      SELECT c_claim_id_sk,
       c_cause_of_loss,
       c_claim_no,
       DECODE (UPPER (C_CLAIM_STATUS_BNC), ''''OPEN'''', ''''OPEN'''', ''''CLOSED'''')
          c_claim_status,
       C_KIND_OF_LOSS,
       c_accident_loc,
       c_loss_date,
       c_loss_time,
       c_inti_date,
       c_regn_date,
       c_app_date,
       c_sur_app_date,
       c_sur_rep_date,
       c_chq_iss_date,
       c_clo_date,
       c_sur_name,
       c_sur_lic_no,
       c_rep_name,
       c_bill_date,
       c_dri_lic_no,
       c_off_loc_id,
       c_parts_claimed,
       c_name_of_in1,
       c_name_of_in2,
       c_name_of_in3,
       c_name_of_in4,
       c_name_of_in5,
       c_adv_name,
       CASE
          WHEN UPPER (C_CLAIM_TYPE) = ''''THIRD PARTY CLAIM'''' THEN ''''TP''''
          WHEN UPPER (C_CLAIM_TYPE) = ''''PERSONAL ACCIDENT'''' THEN ''''PA''''
          WHEN C_CAUSE_OF_LOSS = ''''TP'''' THEN ''''TP''''
          ELSE c_claim_type
       END
          c_claim_type,
       c_comments,
       c_paid_flag,
       c_policy_grain,
       c_claim_regd_by,
       c_last_reopen_date,
       c_reopen_flag,
       c_cons_forum_flag,
       c_ombsman_flag,
       c_ligitation_flag,
       c_recpt_psr_date,
       c_recpt_fsr_date,
       c_all_doc_date,
       NVL (c_court_flag, ''''Normal Claim'''') c_court_flag,
       c_special_comments,
       c_first_reopen_date,
       c_mrn_transporter_name,
       c_invoice_no,
       c_settlemnt_type,
       c_delay_reason,
       c_emeditek_claim_no,
       c_rfa_date,
       c_event_code,
       c_tpa_status,
       c_invoice_date,
       c_fsr_psr_status,
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
       c_next_rvw_date,
       c_last_rvw_remarks,
       c_last_rvw_date,
       c_fplm_flag,
       b.claim_id c_claim_id,
       c_reopen_remark,
       c_reopen_by,
       base_sum_insured,
       addl_excess,
       voluntary_excess,
       compulsory_excess,
       expense_app_date,
       loss_app_date,
       null as net_assessed_amount,
       null as depreciation_amount,
       c_portal_flag
  --FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_CLAIM_DIM a,
  --FROM PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_ODS_CLAIM_DIM_BNC a,
    FROM TRANSACTIONAL.ODI_ODS_CLAIM_DIM_BNC a,
	''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES b
 WHERE  a.c_claim_no = b.clm_ref(+)'';
 EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM ocd
        USING (SELECT c_cause_of_loss,
                      c_claim_no,
                      c_claim_status,
                      c_kind_of_loss,
                      c_accident_loc,
                      DATE_TRUNC(''''DAY'''', c_loss_date) c_loss_date,
                      c_loss_time,
                      DATE_TRUNC(''''DAY'''', c_inti_date) c_inti_date,
                      DATE_TRUNC(''''DAY'''', c_regn_date) c_regn_date,
                      c_app_date,
                      c_sur_app_date,
                      c_sur_rep_date,
                      c_chq_iss_date,
                      c_clo_date,
                      c_sur_name,
                      c_sur_lic_no,
                      c_rep_name,
                      c_bill_date,
                      c_dri_lic_no,
                      c_off_loc_id,
                      c_parts_claimed,
                      c_name_of_in1,
                      c_name_of_in2,
                      c_name_of_in3,
                      c_name_of_in4,
                      c_name_of_in5,
                      c_adv_name,
                      c_claim_type,
                      c_comments,
                      c_paid_flag,
                      c_policy_grain,
                      c_claim_regd_by,
                      c_last_reopen_date,
                      c_reopen_flag,
                      c_cons_forum_flag,
                      c_ombsman_flag,
                      c_ligitation_flag,
                      c_recpt_psr_date,
                      c_recpt_fsr_date,
                      c_all_doc_date,
                      c_court_flag,
                      c_special_comments,
                      c_first_reopen_date,
                      c_mrn_transporter_name,
                      c_invoice_no,
                      c_settlemnt_type,
                      c_delay_reason,
                      c_emeditek_claim_no,
                      c_rfa_date,
                      c_event_code,
                      c_tpa_status,
                      c_invoice_date,
                      c_fsr_psr_status,
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
                      c_next_rvw_date,
                      c_last_rvw_remarks,
                      c_last_rvw_date,
                      c_fplm_flag,
                      c_claim_id,
                      c_reopen_remark,
                      c_reopen_by,
                      base_sum_insured,
                      addl_excess,
                      voluntary_excess,
                      compulsory_excess,
                      expense_app_date,
                      loss_app_date,
                      net_assessed_amount,
                      depreciation_amount,
                      c_portal_flag
                 FROM INTERMEDIATE.STG_MAXI_ODS_CLAIM_DIM
                 -- qualify row_number() over(partition by C_CLAIM_NO order by C_LOSS_DATE desc)=1
                 ) mocd
           ON (ocd.c_claim_no = mocd.c_claim_no)
   WHEN MATCHED
   THEN
      UPDATE SET ocd.c_cause_of_loss = mocd.c_cause_of_loss,
                 ocd.c_claim_status = mocd.c_claim_status,
                 ocd.c_kind_of_loss = mocd.c_kind_of_loss,
                 ocd.c_accident_loc = mocd.c_accident_loc,
                 ocd.c_loss_date = mocd.c_loss_date,
                 ocd.c_loss_time = mocd.c_loss_time,
                 ocd.c_inti_date = mocd.c_inti_date,
                 --ocd.c_regn_date=mocd.c_regn_date,
                 ocd.c_app_date = mocd.c_app_date,
                 ocd.c_sur_app_date = mocd.c_sur_app_date,
                 ocd.c_sur_rep_date = mocd.c_sur_rep_date,
                 ocd.c_chq_iss_date = mocd.c_chq_iss_date,
                 ocd.c_clo_date = mocd.c_clo_date,
                 ocd.c_sur_name = mocd.c_sur_name,
                 ocd.c_sur_lic_no = mocd.c_sur_lic_no,
                 ocd.c_rep_name = mocd.c_rep_name,
                 ocd.c_bill_date = mocd.c_bill_date,
                 ocd.c_dri_lic_no = mocd.c_dri_lic_no,
                 ocd.c_off_loc_id = mocd.c_off_loc_id,
                 ocd.c_parts_claimed = mocd.c_parts_claimed,
                 ocd.c_name_of_in1 = mocd.c_name_of_in1,
                 ocd.c_name_of_in2 = mocd.c_name_of_in2,
                 ocd.c_name_of_in3 = mocd.c_name_of_in3,
                 ocd.c_name_of_in4 = mocd.c_name_of_in4,
                 ocd.c_name_of_in5 = mocd.c_name_of_in5,
                 ocd.c_adv_name = mocd.c_adv_name,
                 ocd.c_claim_type = mocd.c_claim_type,
                 ocd.c_comments = mocd.c_comments,
                 ocd.c_paid_flag = mocd.c_paid_flag,
                 ocd.c_policy_grain = mocd.c_policy_grain,
                 ocd.c_claim_regd_by = mocd.c_claim_regd_by,
                 ocd.c_last_reopen_date = mocd.c_last_reopen_date,
                 ocd.c_reopen_flag = mocd.c_reopen_flag,
                 ocd.c_cons_forum_flag = mocd.c_cons_forum_flag,
                 ocd.c_ombsman_flag = mocd.c_ombsman_flag,
                 ocd.c_ligitation_flag = mocd.c_ligitation_flag,
                 ocd.c_recpt_psr_date = mocd.c_recpt_psr_date,
                 ocd.c_recpt_fsr_date = mocd.c_recpt_fsr_date,
                 ocd.c_all_doc_date = mocd.c_all_doc_date,
                 ocd.c_court_flag = mocd.c_court_flag,
                 ocd.c_special_comments = mocd.c_special_comments,
                 ocd.c_first_reopen_date = mocd.c_first_reopen_date,
                 ocd.c_mrn_transporter_name = mocd.c_mrn_transporter_name,
                 ocd.c_invoice_no = mocd.c_invoice_no,
                 ocd.c_settlemnt_type = mocd.c_settlemnt_type,
                 ocd.c_delay_reason = mocd.c_delay_reason,
                 ocd.c_emeditek_claim_no = mocd.c_emeditek_claim_no,
                 ocd.c_rfa_date = mocd.c_rfa_date,
                 ocd.c_event_code = mocd.c_event_code,
                 ocd.c_tpa_status = mocd.c_tpa_status,
                 ocd.c_invoice_date = mocd.c_invoice_date,
                 ocd.c_fsr_psr_status = mocd.c_fsr_psr_status,
                 ocd.c_place_of_loss = mocd.c_place_of_loss,
                 ocd.c_landmark = mocd.c_landmark,
                 ocd.c_area = mocd.c_area,
                 ocd.c_state = mocd.c_state,
                 ocd.c_city = mocd.c_city,
                 ocd.c_pincode = mocd.c_pincode,
                 ocd.c_journey_from = mocd.c_journey_from,
                 ocd.c_journey_to = mocd.c_journey_to,
                 ocd.c_consignee_name = mocd.c_consignee_name,
                 ocd.c_consigner_name = mocd.c_consigner_name,
                 ocd.c_survey_location = mocd.c_survey_location,
                 ocd.c_goods_details = mocd.c_goods_details,
                 ocd.c_next_rvw_date = mocd.c_next_rvw_date,
                 ocd.c_last_rvw_remarks = mocd.c_last_rvw_remarks,
                 ocd.c_last_rvw_date = mocd.c_last_rvw_date,
                 ocd.c_fplm_flag = mocd.c_fplm_flag,
                 ocd.c_claim_id = mocd.c_claim_id,
                 ocd.c_reopen_remark = mocd.c_reopen_remark,
                 ocd.c_reopen_by = mocd.c_reopen_by,
                 ocd.base_sum_insured = mocd.base_sum_insured,
                 ocd.addl_excess = mocd.addl_excess,
                 ocd.voluntary_excess = mocd.voluntary_excess,
                 ocd.compulsory_excess = mocd.compulsory_excess,
                 ocd.expense_app_date = mocd.expense_app_date,
                 ocd.loss_app_date = mocd.loss_app_date,
                 ocd.net_assessed_amount = mocd.net_assessed_amount,
                 ocd.depreciation_amount = mocd.depreciation_amount,
                 ocd.c_portal_flag = mocd.c_portal_flag,
                 ETL_REFRESH_AT = CURRENT_TIMESTAMP()
   WHEN NOT MATCHED
   THEN
      INSERT     (c_claim_id_sk,
                  c_cause_of_loss,
                  c_claim_no,
                  c_claim_status,
                  c_kind_of_loss,
                  c_accident_loc,
                  c_loss_date,
                  c_loss_time,
                  c_inti_date,
                  c_regn_date,
                  c_app_date,
                  c_sur_app_date,
                  c_sur_rep_date,
                  c_chq_iss_date,
                  c_clo_date,
                  c_sur_name,
                  c_sur_lic_no,
                  c_rep_name,
                  c_bill_date,
                  c_dri_lic_no,
                  c_off_loc_id,
                  c_parts_claimed,
                  c_name_of_in1,
                  c_name_of_in2,
                  c_name_of_in3,
                  c_name_of_in4,
                  c_name_of_in5,
                  c_adv_name,
                  c_claim_type,
                  c_comments,
                  c_paid_flag,
                  c_policy_grain,
                  c_claim_regd_by,
                  c_last_reopen_date,
                  c_reopen_flag,
                  c_cons_forum_flag,
                  c_ombsman_flag,
                  c_ligitation_flag,
                  c_recpt_psr_date,
                  c_recpt_fsr_date,
                  c_all_doc_date,
                  c_court_flag,
                  c_special_comments,
                  c_first_reopen_date,
                  c_mrn_transporter_name,
                  c_invoice_no,
                  c_settlemnt_type,
                  c_delay_reason,
                  c_emeditek_claim_no,
                  c_rfa_date,
                  c_event_code,
                  c_tpa_status,
                  c_invoice_date,
                  c_fsr_psr_status,
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
                  c_next_rvw_date,
                  c_last_rvw_remarks,
                  c_last_rvw_date,
                  c_fplm_flag,
                  c_claim_id,
                  c_reopen_remark,
                  c_reopen_by,
                  base_sum_insured,
                  addl_excess,
                  voluntary_excess,
                  compulsory_excess,
                  expense_app_date,
                  loss_app_date,
                  net_assessed_amount,
                  depreciation_amount,
                  c_portal_flag,
                  ETL_REFRESH_AT)
          VALUES (UTILS.claim_surrogate_key.NEXTVAL,
                  mocd.c_cause_of_loss,
                  mocd.c_claim_no,
                  mocd.c_claim_status,
                  mocd.c_kind_of_loss,
                  mocd.c_accident_loc,
                  mocd.c_loss_date,
                  mocd.c_loss_time,
                  mocd.c_inti_date,
                  mocd.c_regn_date,
                  mocd.c_app_date,
                  mocd.c_sur_app_date,
                  mocd.c_sur_rep_date,
                  mocd.c_chq_iss_date,
                  mocd.c_clo_date,
                  mocd.c_sur_name,
                  mocd.c_sur_lic_no,
                  mocd.c_rep_name,
                  mocd.c_bill_date,
                  mocd.c_dri_lic_no,
                  mocd.c_off_loc_id,
                  mocd.c_parts_claimed,
                  mocd.c_name_of_in1,
                  mocd.c_name_of_in2,
                  mocd.c_name_of_in3,
                  mocd.c_name_of_in4,
                  mocd.c_name_of_in5,
                  mocd.c_adv_name,
                  mocd.c_claim_type,
                  mocd.c_comments,
                  mocd.c_paid_flag,
                  mocd.c_policy_grain,
                  mocd.c_claim_regd_by,
                  mocd.c_last_reopen_date,
                  mocd.c_reopen_flag,
                  mocd.c_cons_forum_flag,
                  mocd.c_ombsman_flag,
                  mocd.c_ligitation_flag,
                  mocd.c_recpt_psr_date,
                  mocd.c_recpt_fsr_date,
                  mocd.c_all_doc_date,
                  mocd.c_court_flag,
                  mocd.c_special_comments,
                  mocd.c_first_reopen_date,
                  mocd.c_mrn_transporter_name,
                  mocd.c_invoice_no,
                  mocd.c_settlemnt_type,
                  mocd.c_delay_reason,
                  mocd.c_emeditek_claim_no,
                  mocd.c_rfa_date,
                  mocd.c_event_code,
                  mocd.c_tpa_status,
                  mocd.c_invoice_date,
                  mocd.c_fsr_psr_status,
                  mocd.c_place_of_loss,
                  mocd.c_landmark,
                  mocd.c_area,
                  mocd.c_state,
                  mocd.c_city,
                  mocd.c_pincode,
                  mocd.c_journey_from,
                  mocd.c_journey_to,
                  mocd.c_consignee_name,
                  mocd.c_consigner_name,
                  mocd.c_survey_location,
                  mocd.c_goods_details,
                  mocd.c_next_rvw_date,
                  mocd.c_last_rvw_remarks,
                  mocd.c_last_rvw_date,
                  mocd.c_fplm_flag,
                  mocd.c_claim_id,
                  mocd.c_reopen_remark,
                  mocd.c_reopen_by,
                  mocd.base_sum_insured,
                  mocd.addl_excess,
                  mocd.voluntary_excess,
                  mocd.compulsory_excess,
                  mocd.expense_app_date,
                  mocd.loss_app_date,
                  mocd.net_assessed_amount,
                  mocd.depreciation_amount,
                  mocd.c_portal_flag,
                  CURRENT_TIMESTAMP())'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
      SET MAXIMUS_FLAG = ''''Y'''', ETL_REFRESH_AT = CURRENT_TIMESTAMP()
    WHERE c_claIM_NO IN (SELECT C_CLAIM_NO FROM INTERMEDIATE.STG_MAXI_ODS_CLAIM_DIM)'';
EXECUTE IMMEDIATE v_sqltext;

---maximus merge

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODI_ODS_CLAIM_FACT_MV A
        USING (WITH TABLE1
                    AS (SELECT PAID_CLAIM AS PAID_CLAIM,
                               RESERVE_AMOUNT AS RESERVE_AMOUNT,
                               SALVAGE_AMOUNT AS SALVAGE_AMOUNT,
                               RECOVERY_AMOUNT AS RECOVERY_AMOUNT,
                               SERVICE_TAX AS SERVICE_TAX,
                               NET_PAID AS NET_PAID,
                               NET_TAX AS NET_TAX,
                               C_CLAIM_NO AS C_CLAIM_NO,
                               P_POLICY_NUMBER AS P_POLICY_NUMBER,
                               R_RESERVE_TYPE AS R_RESERVE_TYPE,
                               TRANS_DATE AS TRANS_DATE
                          FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_CLAIM_FACT_MV
                         WHERE     DATE_TRUNC (''''DAY'''',LAST_UPDATED_DATE) BETWEEN
																	 --TRUNC(SYSDATE - 1,''''MM'''') AND TRUNC (SYSDATE) - 1
																	 DATE_TRUNC(''''MONTH'''', DATEADD(''''DAY'''', -1, CURRENT_DATE - 1))
																 AND DATE_TRUNC(''''DAY'''',CURRENT_DATE-1)
                               AND NVL (CREATED_BY, ''''X'''') <> ''''MIGRATION'''')
                               -- ,                                                   -- written for duplicate records in ods_Claim_fact_mv
                  -- TABLE2 as (
                  SELECT NVL (C_CLAIM_ID_SK, 9999999999) AS C_CLAIM_ID_SK,
                        NVL (P_POLICY_NO_SK, 1) AS P_POLICY_NO_SK,
                        1 AS COMPANY_CODE,
                        1 AS T_DATE_ID_SK,
                        1 AS CC_CC_CLAIMTYPE_ID_SK,
                        R_RESERVE_TYPE_ID_SK AS R_RESERVE_TYPE_ID,
                        (SUM (NVL (PAID_CLAIM, 0))) AS PAID_CLAIM,
                        (SUM (NVL (RESERVE_AMOUNT, 0))) AS RESERVE_AMOUNT,
                        (SUM (NVL (SALVAGE_AMOUNT, 0))) AS SALVAGE_AMOUNT,
                        (SUM (NVL (RECOVERY_AMOUNT, 0))) AS RECOVERY_AMOUNT,
                        (SUM (NVL (SERVICE_TAX, 0))) AS SERVICE_TAX,
                        (SUM (NVL (NET_PAID, 0))) AS NET_PAID,
                        (SUM (NVL (NET_TAX, 0))) AS NET_TAX,
                        DATE_TRUNC (''''DAY'''',TRANS_DATE) AS TRANS_DATE,
                        A.C_CLAIM_NO AS C_CLAIM_NO,
                        A.P_POLICY_NUMBER AS P_POLICY_NUMBER,
                        A.R_RESERVE_TYPE AS R_RESERVE_TYPE
                   FROM TABLE1 A,
                        TRANSACTIONAL.ODI_ODS_CLAIM_DIM_BNC B,
                        -- ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_POLICY_DIM C,   -- SOURCE WAS CHANGED AS PER DWH ON 19TH Sept, 2025 confirmed by Ramesh.
                        PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM C,
                        TRANSACTIONAL.odi_ods_reserve_dim D
                  WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
                        AND A.P_POLICY_NUMBER = C.P_POLICY_NUMBER(+)
                        AND UPPER (TRIM (A.R_RESERVE_TYPE)) =
                               UPPER (TRIM (D.R_RESERVE_TYPE(+)))
                        AND P_CURRENT_INDICATOR(+) = 1
               GROUP BY NVL (C_CLAIM_ID_SK, 9999999999),
                        NVL (P_POLICY_NO_SK, 1),
                        R_RESERVE_TYPE_ID_SK,
                        DATE_TRUNC (''''DAY'''',TRANS_DATE),
                        A.C_CLAIM_NO,
                        A.P_POLICY_NUMBER,
                        A.R_RESERVE_TYPE
                        -- )
          -- Select * from TABLE2
          -- QUALIFY ROW_NUMBER() OVER(PARTITION BY P_POLICY_NO_SK ORDER BY TRANS_DATE desc) = 1
           ) B
           ON (    A.TRANS_DATE = B.TRANS_DATE
               AND A.C_CLAIM_NO = B.C_CLAIM_NO
               AND A.R_RESERVE_TYPE = B.R_RESERVE_TYPE)
   WHEN NOT MATCHED
   THEN
      INSERT     (C_CLAIM_ID_SK,
                  P_POLICY_NO_SK,
                  COMPANY_CODE,
                  T_DATE_ID_SK,
                  CC_CC_CLAIMTYPE_ID_SK,
                  R_RESERVE_TYPE_ID,
                  PAID_CLAIM,
                  RESERVE_AMOUNT,
                  SALVAGE_AMOUNT,
                  RECOVERY_AMOUNT,
                  SERVICE_TAX,
                  NET_PAID,
                  NET_TAX,
                  TRANS_DATE,
                  C_CLAIM_NO,
                  P_POLICY_NUMBER,
                  R_RESERVE_TYPE)
          VALUES (B.C_CLAIM_ID_SK,
                  B.P_POLICY_NO_SK,
                  B.COMPANY_CODE,
                  B.T_DATE_ID_SK,
                  B.CC_CC_CLAIMTYPE_ID_SK,
                  B.R_RESERVE_TYPE_ID,
                  B.PAID_CLAIM,
                  B.RESERVE_AMOUNT,
                  B.SALVAGE_AMOUNT,
                  B.RECOVERY_AMOUNT,
                  B.SERVICE_TAX,
                  B.NET_PAID,
                  B.NET_TAX,
                  B.TRANS_DATE,
                  B.C_CLAIM_NO,
                  B.P_POLICY_NUMBER,
                  B.R_RESERVE_TYPE)
   WHEN MATCHED
   THEN
      UPDATE SET C_CLAIM_ID_SK = B.C_CLAIM_ID_SK,
                 P_POLICY_NO_SK = B.P_POLICY_NO_SK,
                 COMPANY_CODE = B.COMPANY_CODE,
                 T_DATE_ID_SK = B.T_DATE_ID_SK,
                 CC_CC_CLAIMTYPE_ID_SK = B.CC_CC_CLAIMTYPE_ID_SK,
                 R_RESERVE_TYPE_ID = B.R_RESERVE_TYPE_ID,
                 PAID_CLAIM = B.PAID_CLAIM,
                 RESERVE_AMOUNT = B.RESERVE_AMOUNT,
                 SALVAGE_AMOUNT = B.SALVAGE_AMOUNT,
                 RECOVERY_AMOUNT = B.RECOVERY_AMOUNT,
                 SERVICE_TAX = B.SERVICE_TAX,
                 NET_PAID = B.NET_PAID,
                 NET_TAX = B.NET_TAX,
                 P_POLICY_NUMBER = B.P_POLICY_NUMBER'';
EXECUTE IMMEDIATE v_sqltext;





v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_MAXI_ODS_CLAIM_FACT_MV'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.STG_MAXI_ODS_CLAIM_FACT_MV
      SELECT c.c_claim_id_sk,
             d.p_policy_no_sk,
             company_code,
             b.t_date_id_sk,
             cc_cc_claimtype_id_sk,
             r_reserve_type_id_sk r_reserve_type_id,
             paid_claim,
             reserve_amount,
             salvage_amount,
             recovery_amount,
             service_tax,
             net_paid,
             net_tax
        --FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_CLAIM_FACT_MV a,
            --FROM PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_ODS_CLAIM_FACT_MV a,
			FROM TRANSACTIONAL.ODI_ODS_CLAIM_FACT_MV a,
             PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b,
             TRANSACTIONAL.ODS_CLAIM_DIM c,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM d,
             TRANSACTIONAL.ODS_RESERVE_DIM e
       WHERE     b.t_date_desc = DATE_TRUNC(''''DAY'''', a.trans_date)
             AND c.c_claim_no = a.c_claim_no
             AND a.p_policy_number = d.p_policy_number
             AND UPPER (NVL (a.r_reserve_type, ''''X'''')) =
                    UPPER (NVL (e.r_reserve_type, ''''Y''''))
             AND P_CURRENT_INDICATOR = 1
             AND DATE_TRUNC(''''DAY'''', trans_date) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO TRANSACTIONAL.ODS_CLAIM_FACT_MV
            (
            c_claim_id_sk,
               p_policy_no_sk,
               company_code,
               t_date_id_sk,
               cc_cc_claimtype_id_sk,
               r_reserve_type_id,
               paid_claim,
               reserve_amount,
                salvage_amount,
                recovery_amount,
                 service_tax,
                 net_paid,
                net_tax,
                MAXIMUS_FLAG
            )
        SELECT c_claim_id_sk,
               p_policy_no_sk,
               company_code,
               t_date_id_sk,
               cc_cc_claimtype_id_sk,
               r_reserve_type_id,
               SUM (paid_claim) paid_claim,
               SUM (reserve_amount) reserve_amount,
               SUM (salvage_amount) salvage_amount,
               SUM (recovery_amount) recovery_amount,
               SUM (service_tax) service_tax,
               SUM (net_paid) net_paid,
               SUM (net_tax) net_tax,
               ''''Y''''
          FROM INTERMEDIATE.STG_MAXI_ODS_CLAIM_FACT_MV
      GROUP BY c_claim_id_sk,
               p_policy_no_sk,
               company_code,
               t_date_id_sk,
               cc_cc_claimtype_id_sk,
               r_reserve_type_id'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.RPT_MAXIMUS_CR_BKP
      SELECT c_claim_id_sk,
             p_policy_no_sk,
             company_code,
             t_date_id_sk,
             cc_cc_claimtype_id_sk,
             r_reserve_type_id,
             paid_claim,
             reserve_amount,
             salvage_amount,
             recovery_amount,
             service_tax,
             net_paid,
             net_tax,
             CURRENT_DATE load_date
        FROM INTERMEDIATE.STG_MAXI_ODS_CLAIM_FACT_MV'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''INSERT INTO INTERMEDIATE.MAXIMUS_DWH_CLM_RECO
      SELECT COUNT (DISTINCT c_Claim_no) total_cnt,
             SUM (reserve_amount) res_amt,
             SUM (paid_claim) paid_amt,
             CURRENT_DATE load_date
        --FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_CLAIM_FACT_MV
        FROM TRANSACTIONAL.ODI_ODS_CLAIM_FACT_MV'';
EXECUTE IMMEDIATE v_sqltext;


-- v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MAXIMUS_DAILY_RECO
--          SELECT a.*, DATE_TRUNC(''''DAY'''', CURRENT_DATE) load_date
--            FROM PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_DAILY_CLM_RECON_DATA a'';
-- EXECUTE IMMEDIATE v_sqltext;
-- mentioned ODI_DAILY_CLM_RECON_DATA not in use


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MAXIMUS_CLOSER_DATA'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MAXIMUS_CLOSER_DATA
           SELECT BAGIC_PRODUCT_CODE,
                  DATE_TRUNC(''''DAY'''', C_CLO_DATE) CLOSE_DATE,
                  C_CLAIM_STATUS,
                  COUNT (C_CLAIM_NO) NO_OF_CLM
               FROM ''|| MIRROR_DB ||''.MAXI_IIMS_REP.ODS_CLAIM_DIM
             --FROM PROD_DWH_MIGRATED_DB.STAGEBNC.ODI_ODS_CLAIM_DIM_BNC_NEW
			 --FROM TRANSACTIONAL.ODI_ODS_CLAIM_DIM_BNC
            WHERE     C_CLO_DATE IS NOT NULL
                  AND C_CLAIM_STATUS IN (''''Rejected'''', ''''Closed Without Payment'''')
         GROUP BY DATE_TRUNC(''''DAY'''', C_CLO_DATE), C_CLAIM_STATUS, BAGIC_PRODUCT_CODE
         ORDER BY DATE_TRUNC(''''DAY'''', C_CLO_DATE)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_TP_CLP_CLAIMS'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_TP_CLP_CLAIMS
SELECT ID,
ALL_VALIDATION_BY_PASS,
BRANCH_ID,
CASE_DECISION,
CASE_FILLING_DATE,
CASE_NO_UNDER_140,
CASE_PREFIX_UNDER_140,
CASE_YEAR_UNDER_140,
CAUSE_OF_LOSS,
CLAIM_NUMBER,
CLAIM_REF_NO,
CLAIM_RESPONSIBLE,
CLAIMED_AMOUNT,
CNR_NUMBER,
COURT_CONTACT_NUMBER,
COURT_EMAIL_ID,
CREATED_BY,
CREATED_DATE,
DATE_APP_FILED_UNDER_140,
DWH_CREATED_DATE,
DWH_LAST_UPDATED,
HO_ID,
INTIMATION_ID,
IS_ACTIVE,
IS_ADVOCATE_APPOINTED,
IS_CLOSE_PROXIMITY,
IS_CRITCAL_CLAIM,
IS_MANUVAL_CLOSURE,
MODIFIED_BY,
MODIFIED_DATE,
NO_OF_CLAIMANT,
PAGE_CODE,
POLICY_NUMBER,
REGISTER_DELAYED_REASON,
REGISTER_DELAYED_REASON_OTHERS,
RESERVE_AMOUNT,
RESPONSIBLE_LEGAL_OFFICER,
SECTION_CODE,
SEPARATE_APP_FILED_UNDER_140,
STATUS_CODE, STATUS_ID,
SUB_STATUS,
TEMP_CAUSE_OF_LOSS,
CASE_ID,
POLICY_ID,
CRITICAL_CLAIM_REASON
FROM ''|| MIRROR_DB ||''.CLP.CLAIM_DETAILS
WHERE NOT CLAIM_NUMBER IS NULL'';
EXECUTE IMMEDIATE v_sqltext;


BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
    SET C_CLAIM_TYPE = src.C_CLAIM_TYPE,
    C_CAUSE_OF_LOSS = src.CAUSE_OF_LOSS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()


FROM
(
  SELECT TO_CHAR (CLAIM_NUMBER) CLAIM_NUMBER,
                    CAUSE_OF_LOSS,
                    HO_ID,
                    ''''TP'''' C_CLAIM_TYPE
               FROM INTERMEDIATE.WRK_TP_CLP_CLAIMS
)as src
WHERE     C_CLAIM_NO = src.CLAIM_NUMBER
             AND MAXIMUS_FLAG IS NOT NULL
             AND EXISTS
                    (SELECT 1
                       FROM INTERMEDIATE.WRK_TP_CLP_CLAIMS
                      WHERE C_CLAIM_NO = TO_CHAR (CLAIM_NUMBER))'';
EXECUTE IMMEDIATE v_sqltext;


END;


EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;

end;
';