-- CENTRAL VIEW v02_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_CLM_BASE_MOT_EXT
--   BJAZ_CLM_MOTOR_INTIM_DETAILS
--   BJAZ_CLM_SUBFILE_MOT_EXT
--   BJAZ_MOTORTHEFT_CASE_DTLS
--   BJAZ_MOTOR_INVOICE_OCR_DTLS
--   BJAZ_MOT_CLM_CDC_REVIEWER_DTLS
--   BJAZ_PAYMOTORTHEFT_DTLS
--   BJAZ_WB_CLM_BASE_MOT_EXT
--   BJAZ_WB_CLM_IP_MOT_EXT
--   BJAZ_WS_MOTCLM_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_DOCUMENT_CHECKLIST
--   SAT_AUG_CASE_LITIGATION
--   SAT_AUG_CASE_WORKFLOW_TASK
--   SAT_AUG_CLAIM_FRAUD
--   SAT_AUG_CLAIM_LITIGATION
--   SAT_AUG_CLAIM_PA_DETAIL
--   SAT_AUG_CLAIM_RECOVERY_EXPENSE_LINE
--   SAT_AUG_CLAIM_SALVAGE_BIDDER
--   SAT_AUG_CLAIM_SUB_FILE
--   SAT_AUG_CLAIM_SURVEY_APPOINTMENT
--   SAT_AUG_CLAIM_TP_FORENSIC
--   SAT_AUG_DOCUMENT_DEFINITION
--   SAT_AUG_LOSS_EVENT_DETAIL
--   SAT_AUG_LOSS_LOCATION_ADDRESS
--   SAT_CASE_EXTERNAL_REF
--   SAT_CASE_HEADER
--   SAT_CASE_INVESTIGATION
--   SAT_CASE_LITIGATION
--   SAT_CASE_WORKFLOW_TASK
--   SAT_CLAIM_EVIDENCE
--   SAT_CLAIM_FRAUD
--   SAT_CLAIM_HEADER
--   SAT_CLAIM_LITIGATION
--   SAT_CLAIM_NOTE
--   SAT_CLAIM_QUALITY_AUDIT
--   SAT_CLAIM_RECOVERY_SALVAGE
--   SAT_CLAIM_TP_FORENSIC
--   SAT_DOCUMENT_DEFINITION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CLM_BASE_MOT_EXT
    select
        cast(null as varchar) as CASE_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        cast(null as varchar) as DOCUMENT_BK,
        cast(null as varchar) as LOSS_EVENT_BK,
        cast(null as number) as __LNK_CLAIM_DOCUMENT,
        cast(null as varchar) as AUG_CASE_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        cast(null as varchar) as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        cast(null as varchar) as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        cast(null as varchar) as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        cast(null as varchar) as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        cast(null as varchar) as AUG_CASE_LITIGATION__COURT_CASE_NUMBER,
        cast(null as varchar) as AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_OBTAINED_INDICATOR,
        cast(null as varchar) as AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_RECEIVED_DATE,
        cast(null as varchar) as AUG_CASE_LITIGATION__COURT_SALE_ORDER_OBTAINED_INDICATOR,
        cast(null as varchar) as AUG_CASE_LITIGATION__COURT_SALE_ORDER_RECEIVED_DATE,
        cast(null as varchar) as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        cast(null as varchar) as AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS,
        cast(null as varchar) as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
        t0.aml_waiver as AUG_CLAIM_FRAUD__AML_WAIVER_INDICATOR,
        t0.aml_waiver_reason as AUG_CLAIM_FRAUD__AML_WAIVER_REASON,
        t0.bypass_taken_by as AUG_CLAIM_FRAUD__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_LITIGATION__ADVISORY_COMMITTEE_REMARKS,
        cast(null as varchar) as AUG_CLAIM_LITIGATION__LITIGATION_CASE_NARRATIVE,
        t0.long_tail_disputed as AUG_CLAIM_LITIGATION__LONG_TAIL_DISPUTED_INDICATOR,
        t0.obm_complain as AUG_CLAIM_LITIGATION__OMBUDSMAN_COMPLAINT_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_INDICATOR,
        t0.suit_marine_rec as AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_RECORD_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_CONTACT_NUMBER,
        cast(null as varchar) as AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_NAME,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK,
        cast(null as varchar) as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK,
        cast(null as varchar) as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT,
        cast(null as varchar) as AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE,
        cast(null as varchar) as AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER_CK,
        cast(null as varchar) as AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER,
        cast(null as varchar) as AUG_CLAIM_SUB_FILE__SUB_FILE_REMARKS,
        cast(null as varchar) as AUG_CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK,
        cast(null as varchar) as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_STAGE,
        cast(null as varchar) as AUG_CLAIM_TP_FORENSIC__PANCHANAMA_DETAIL,
        cast(null as varchar) as AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__INVOICE_PRESENT_INDICATOR,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__OCR_ACCEPTED_DATE,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__OCR_APPROVED_DATE,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__OCR_PROCESSING_FLAG,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__OCR_REQUEST_REFERENCE,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__OCR_SENT_DATE,
        cast(null as varchar) as AUG_LOSS_EVENT_DETAIL__CAUSE_TYPE_CODE,
        cast(null as varchar) as AUG_LOSS_LOCATION_ADDRESS__LOCALITY,
        cast(null as varchar) as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
        cast(null as varchar) as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE,
        cast(null as varchar) as CASE_HEADER__ASSIGNED_TO_REFERENCE,
        cast(null as varchar) as CASE_HEADER__CASE_STATUS,
        cast(null as varchar) as CASE_HEADER__CASE_SUB_STATUS,
        cast(null as varchar) as CASE_HEADER__RAISED_DATE,
        cast(null as varchar) as CASE_HEADER__RESOLUTION_DATE,
        cast(null as varchar) as CASE_INVESTIGATION__FINDINGS_SUMMARY,
        cast(null as varchar) as CASE_LITIGATION__CASE_FILING_DATE,
        cast(null as varchar) as CASE_LITIGATION__CASE_STAGE,
        cast(null as varchar) as CASE_LITIGATION__COURT_NAME,
        cast(null as varchar) as CASE_LITIGATION__NEXT_HEARING_DATE,
        cast(null as varchar) as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        cast(null as varchar) as CASE_WORKFLOW_TASK__ASSIGNED_DATE,
        cast(null as varchar) as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        cast(null as varchar) as CASE_WORKFLOW_TASK__TASK_STATUS,
        cast(null as varchar) as CASE_WORKFLOW_TASK__TASK_TYPE,
        cast(null as varchar) as CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
        cast(null as varchar) as CLAIM_EVIDENCE__MEDIA_REFERENCE_CK,
        cast(null as varchar) as CLAIM_EVIDENCE__EVIDENCE_TYPE,
        cast(null as varchar) as CLAIM_EVIDENCE__MEDIA_REFERENCE,
        t0.double_claim_bypass as CLAIM_FRAUD__DOUBLE_CLAIM_OVERRIDE_INDICATOR,
        t0.fraud_flag as CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR,
        t0.fraud_details as CLAIM_FRAUD__FRAUD_TRIGGER_REASON,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_EXAMINER_REFERENCE,
        t0.assignee as CLAIM_HEADER__CLAIM_HANDLER_REFERENCE,
        t0.unique_refno as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_REMARKS,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_SUB_STATUS,
        t0.clm_type as CLAIM_HEADER__CLAIM_TYPE,
        cast(null as varchar) as CLAIM_HEADER__CLOSED_DATE,
        cast(null as varchar) as CLAIM_HEADER__FAST_TRACK_INDICATOR,
        t0.claim_department as CLAIM_HEADER__HANDLING_ORG_UNIT_CODE,
        cast(null as varchar) as CLAIM_HEADER__INTIMATED_BY_ROLE,
        t0.mode_claim_intimation as CLAIM_HEADER__INTIMATION_CHANNEL,
        cast(null as varchar) as CLAIM_HEADER__LOSS_DATE,
        t0.notification_date as CLAIM_HEADER__NOTIFICATION_DATE,
        cast(null as varchar) as CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        t0.is_forum_case as CLAIM_LITIGATION__CONSUMER_FORUM_CASE_INDICATOR,
        cast(null as varchar) as CLAIM_LITIGATION__LITIGATION_INDICATOR,
        t0.other_ligitation as CLAIM_LITIGATION__OTHER_LITIGATION_INDICATOR,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        cast(null as varchar) as CLAIM_QUALITY_AUDIT__AUDITOR_REFERENCE,
        cast(null as varchar) as CLAIM_QUALITY_AUDIT__AUDIT_DATE,
        cast(null as varchar) as CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME,
        cast(null as varchar) as CLAIM_RECOVERY_SALVAGE__RECOVERY_EXPENSE,
        cast(null as varchar) as CLAIM_RECOVERY_SALVAGE__SALVAGE_DISPOSAL_METHOD,
        cast(null as varchar) as CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT,
        cast(null as varchar) as CLAIM_TP_FORENSIC__FIR_NUMBER,
        cast(null as varchar) as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        cast(null as varchar) as DOCUMENT_DEFINITION__RECEIVED_DATE,
        cast(null as varchar) as DOCUMENT_DEFINITION__SOURCE_CHANNEL,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 1: BJAZ_CLM_BASE_MOT_EXT | child-key literal(s): CLAIM_EVIDENCE.Evidence Type=IDENTITY_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IDENTITY_PROOF' as CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
        null,
        t0.doc_identy_proof as CLAIM_EVIDENCE__EVIDENCE_TYPE,
        t0.doc_no_identy_proof as CLAIM_EVIDENCE__MEDIA_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_CLM_BASE_MOT_EXT | child-key literal(s): CLAIM_EVIDENCE.Evidence Type=ADDRESS_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDRESS_PROOF' as CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
        null,
        t0.doc_address_proof as CLAIM_EVIDENCE__EVIDENCE_TYPE,
        t0.doc_no_address_proof as CLAIM_EVIDENCE__MEDIA_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_CLM_BASE_MOT_EXT | child-key literal(s): CLAIM_EVIDENCE.Evidence Type=INCOME_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INCOME_PROOF' as CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
        null,
        t0.doc_income_proof as CLAIM_EVIDENCE__EVIDENCE_TYPE,
        t0.doc_no_income_proof as CLAIM_EVIDENCE__MEDIA_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 4: BJAZ_CLM_MOTOR_INTIM_DETAILS
    select
        null,
        nullif(nullif('INTIMATION:' || nullif(trim(t0.intimation_id), ''), 'INTIMATION:'), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.claim_type as CLAIM_HEADER__CLAIM_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(nullif('INTIMATION:' || nullif(trim(t0.intimation_id), ''), 'INTIMATION:'), '')) is not null

    union all

    -- branch 5: BJAZ_CLM_SUBFILE_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.case_details as AUG_CLAIM_LITIGATION__LITIGATION_CASE_NARRATIVE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sf_no as AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER_CK,
        t0.sf_no as AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER,
        t0.sf_comments as AUG_CLAIM_SUB_FILE__SUB_FILE_REMARKS,
        null, null, null,
        t0.panchanama_details as AUG_CLAIM_TP_FORENSIC__PANCHANAMA_DETAIL,
        t0.police_station_name as AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.case_filed as CLAIM_LITIGATION__LITIGATION_INDICATOR,
        null, null, null, null, null, null, null, null, null,
        t0.fir_no as CLAIM_TP_FORENSIC__FIR_NUMBER,
        null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_subfile_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=NONOBJ_CERTIFICATE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'NONOBJ_CERTIFICATE' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.nonobj_certificate as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=BUYER_ID_PROOF
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'BUYER_ID_PROOF' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.buyer_id_proof as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=SALE_LETTER
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'SALE_LETTER' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.sale_letter as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=RELEASE_ORDER
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'RELEASE_ORDER' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.release_order as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=PURCHASE_INVOICE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'PURCHASE_INVOICE' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.purchase_invoice as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=ADDRESS_ID_PROOF
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'ADDRESS_ID_PROOF' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.address_id_proof as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=TRANSFER_FORM
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'TRANSFER_FORM' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.transfer_form as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=INDEMNITY_BOUND
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'INDEMNITY_BOUND' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.indemnity_bound as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=SALE_ORD_COPY
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'SALE_ORD_COPY' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.sale_ord_copy as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=ORIGINAL_RC_AVAILABLE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'ORIGINAL_RC_AVAILABLE' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.original_rc_available as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=RTO_FORMS_AVAILABLE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'RTO_FORMS_AVAILABLE' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.rto_forms_available as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 17: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=HYPO_NOC_AVAILABLE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'HYPO_NOC_AVAILABLE' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.hypo_noc_available as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 18: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=KEY
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'KEY' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.insured_key as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 19: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_ORGNL_RC_AVAIL
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_ORGNL_RC_AVAIL' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_orgnl_rc_avail as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 20: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_VEHICLE_KEY
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_VEHICLE_KEY' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_vehicle_key as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 21: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_HYPOTHECATED
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_HYPOTHECATED' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_hypothecated as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 22: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_FINANCER_NOC
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_FINANCER_NOC' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_financer_noc as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 23: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_FORM_35
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_FORM_35' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_form_35 as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 24: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RC_INSURED_NAME
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RC_INSURED_NAME' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_rc_insured_name as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 25: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_CONFIRM_NAME_OWNER
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_CONFIRM_NAME_OWNER' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_confirm_name_owner as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 26: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_INSURED_KYC
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_INSURED_KYC' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_insured_kyc as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 27: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RTO_FORM
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RTO_FORM' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.chk_rto_form as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 28: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RMRKS_ORGNL_RC_AVAIL
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RMRKS_ORGNL_RC_AVAIL' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.chk_rmrks_orgnl_rc_avail as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 29: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RMRKS_VEHICLE_KEY
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RMRKS_VEHICLE_KEY' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.chk_rmrks_vehicle_key as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 30: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RMRKS_HYPOTHECATED
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RMRKS_HYPOTHECATED' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.chk_rmrks_hypothecated as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 31: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RMRKS_RC_INSURED_NAME
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RMRKS_RC_INSURED_NAME' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.chk_rmrks_rc_insured_name as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 32: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RMRKS_INSURED_KYC
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RMRKS_INSURED_KYC' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.chk_rmrks_insured_kyc as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 33: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_DOCUMENT_CHECKLIST.Document Type=CHK_RMRKS_RTO_FORM
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null,
        'CHK_RMRKS_RTO_FORM' as AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.chk_rmrks_rto_form as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 34: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null,
        t0.court_case_no as AUG_CASE_LITIGATION__COURT_CASE_NUMBER,
        t0.release_ord_flag as AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_OBTAINED_INDICATOR,
        t0.release_ord_rec_date as AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_RECEIVED_DATE,
        t0.sale_ord_flag as AUG_CASE_LITIGATION__COURT_SALE_ORDER_OBTAINED_INDICATOR,
        t0.sale_ord_rec_date as AUG_CASE_LITIGATION__COURT_SALE_ORDER_RECEIVED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.external_bidder1 as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK,
        t0.external_bidder1_dtls as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT,
        t0.external_snt_date1 as AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.status as CASE_HEADER__CASE_STATUS,
        null, null, null,
        t0.investigator_remarks as CASE_INVESTIGATION__FINDINGS_SUMMARY,
        t0.court_assign_date as CASE_LITIGATION__CASE_FILING_DATE,
        t0.stage as CASE_LITIGATION__CASE_STAGE,
        t0.court_name as CASE_LITIGATION__COURT_NAME,
        t0.court_hearing_date as CASE_LITIGATION__NEXT_HEARING_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.clm_ref as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.cc_qc2_remarks, t0.court_fill_remarks, t0.court_rmrks, t0.remaks_by_hod, t0.remark_confirmation, t0.remarks, t0.remarks_by_cen_cordi, t0.remarks_by_padmasir, t0.remarks_by_stateowner, t0.remarks_by_vh, t0.so_qc1_remarks) as CLAIM_NOTE__NOTE_TEXT,
        null, null, null,
        t0.total_expenses as CLAIM_RECOVERY_SALVAGE__RECOVERY_EXPENSE,
        t0.scrap_detail as CLAIM_RECOVERY_SALVAGE__SALVAGE_DISPOSAL_METHOD,
        t0.bid_amount as CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT,
        null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.case_id), ''), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 35: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_WORKFLOW_TASK.Task Code=LOA_EMAIL
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOA_EMAIL' as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.loa_email as AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 36: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_WORKFLOW_TASK.Task Code=I_TRACK_EMAIL
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'I_TRACK_EMAIL' as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.i_track_email as AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 37: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_WORKFLOW_TASK.Task Code=APP_REMARKS1
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_REMARKS1' as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.app_remarks1 as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 38: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_WORKFLOW_TASK.Task Code=APP_REMARKS2
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_REMARKS2' as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.app_remarks2 as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 39: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CASE_WORKFLOW_TASK.Task Code=APP_REMARKS3
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_REMARKS3' as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.app_remarks3 as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 40: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head=ADVOCTE_LEGAL
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'ADVOCTE_LEGAL' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK,
        t0.advocte_legal_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 41: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head=POLICE
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'POLICE' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK,
        t0.police_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 42: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head=YARD_RENTAL
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'YARD_RENTAL' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK,
        t0.yard_rental_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 43: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head=OTHER_MISC
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'OTHER_MISC' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK,
        t0.other_misc_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 44: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.external_bidder2 as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK,
        t0.external_bidder2_dtls as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT,
        t0.external_snt_date2 as AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 45: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.external_bidder3 as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK,
        t0.external_bidder3_dtls as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT,
        t0.external_snt_date3 as AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 46: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_EXTERNAL_REF.Reference Type=I_TRACK_NUMBER
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'I_TRACK_NUMBER' as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
        t0.i_track_number as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 47: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_EXTERNAL_REF.Reference Type=LOA_REQUEST
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'LOA_REQUEST' as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
        t0.loa_request as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 48: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=LOA_EMAIL_DATE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOA_EMAIL_DATE' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.loa_email_date as CASE_WORKFLOW_TASK__ASSIGNED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 49: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=LOA_RECEIVE_DATE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOA_RECEIVE_DATE' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.loa_receive_date as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 50: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=I_TRACK_RAISE_DATE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'I_TRACK_RAISE_DATE' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.i_track_raise_date as CASE_WORKFLOW_TASK__ASSIGNED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 51: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=I_TRACK_RECEIVE_DATE
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'I_TRACK_RECEIVE_DATE' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.i_track_receive_date as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 52: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APP_CATEGORY1
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_CATEGORY1' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null, null, null,
        t0.app_category1 as CASE_WORKFLOW_TASK__TASK_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 53: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APP_CATEGORY2
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_CATEGORY2' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null, null, null,
        t0.app_category2 as CASE_WORKFLOW_TASK__TASK_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 54: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APP_CATEGORY3
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_CATEGORY3' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null, null, null,
        t0.app_category3 as CASE_WORKFLOW_TASK__TASK_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 55: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APPROVE_STATUS1
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APPROVE_STATUS1' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null, null,
        t0.approve_status1 as CASE_WORKFLOW_TASK__TASK_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 56: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APPROVE_STATUS2
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APPROVE_STATUS2' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null, null,
        t0.approve_status2 as CASE_WORKFLOW_TASK__TASK_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 57: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APPROVE_STATUS3
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APPROVE_STATUS3' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null, null,
        t0.approve_status3 as CASE_WORKFLOW_TASK__TASK_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 58: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APP_STATUS_DATE1
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_STATUS_DATE1' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.app_status_date1 as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 59: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APP_STATUS_DATE2
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_STATUS_DATE2' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.app_status_date2 as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 60: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): CASE_WORKFLOW_TASK.Task Code=APP_STATUS_DATE3
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APP_STATUS_DATE3' as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        null,
        t0.app_status_date3 as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.case_id), ''), '')) is not null

    union all

    -- branch 61: BJAZ_MOTOR_INVOICE_OCR_DTLS
    select
        null,
        nullif(nullif(trim(t0.claim_id), ''), '') as CLAIM_BK,
        nullif(nullif(trim(to_char(t0.index_id)), ''), '') as DOCUMENT_BK,
        null,
        1 as __LNK_CLAIM_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.invoice_yn as AUG_DOCUMENT_DEFINITION__INVOICE_PRESENT_INDICATOR,
        t0.accept_ocr_date as AUG_DOCUMENT_DEFINITION__OCR_ACCEPTED_DATE,
        t0.approved_ocr_date as AUG_DOCUMENT_DEFINITION__OCR_APPROVED_DATE,
        t0.flag as AUG_DOCUMENT_DEFINITION__OCR_PROCESSING_FLAG,
        t0.request_id as AUG_DOCUMENT_DEFINITION__OCR_REQUEST_REFERENCE,
        t0.send_ocr_date as AUG_DOCUMENT_DEFINITION__OCR_SENT_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.claim_stage as CLAIM_HEADER__CLAIM_SUB_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        t0.received_doc_date as DOCUMENT_DEFINITION__RECEIVED_DATE,
        t0.source_flag as DOCUMENT_DEFINITION__SOURCE_CHANNEL,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_invoice_ocr_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.claim_id), ''), ''), nullif(nullif(trim(to_char(t0.index_id)), ''), ''))) is not null

    union all

    -- branch 62: BJAZ_MOT_CLM_CDC_REVIEWER_DTLS
    select
        null,
        nullif(nullif(trim(t0.claim_ref), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.updated_by as CLAIM_QUALITY_AUDIT__AUDITOR_REFERENCE,
        t0.updated_on as CLAIM_QUALITY_AUDIT__AUDIT_DATE,
        t0.review_status as CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME,
        null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_cdc_reviewer_dtls') }} t0
    where (nullif(nullif(trim(t0.claim_ref), ''), '')) is not null

    union all

    -- branch 63: BJAZ_PAYMOTORTHEFT_DTLS
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.responsible as CASE_HEADER__ASSIGNED_TO_REFERENCE,
        t0.status as CASE_HEADER__CASE_STATUS,
        t0.sub_status as CASE_HEADER__CASE_SUB_STATUS,
        t0.case_report_date as CASE_HEADER__RAISED_DATE,
        t0.case_closure_date as CASE_HEADER__RESOLUTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.clm_ref as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        null, null, null,
        t0.closure_date as CLAIM_HEADER__CLOSED_DATE,
        null, null, null, null,
        t0.date_of_loss as CLAIM_HEADER__LOSS_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_paymotortheft_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.case_id), ''), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 64: BJAZ_WB_CLM_BASE_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null,
        nullif(nullif('LOSS:' || nullif(trim(to_char(t0.claim_id)), ''), 'LOSS:'), '') as LOSS_EVENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.advisory_cell_remarks as AUG_CLAIM_LITIGATION__ADVISORY_COMMITTEE_REMARKS,
        null, null,
        t0.obm_complain as AUG_CLAIM_LITIGATION__OMBUDSMAN_COMPLAINT_INDICATOR,
        t0.suit_marine_rec as AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_INDICATOR,
        null, null, null,
        t0.pa_flag as AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.area as AUG_LOSS_LOCATION_ADDRESS__LOCALITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.processed_by as CLAIM_HEADER__CLAIM_EXAMINER_REFERENCE,
        t0.assignee as CLAIM_HEADER__CLAIM_HANDLER_REFERENCE,
        null,
        t0.clm_status_rem as CLAIM_HEADER__CLAIM_REMARKS,
        null,
        t0.clm_type as CLAIM_HEADER__CLAIM_TYPE,
        null,
        t0.fast_track as CLAIM_HEADER__FAST_TRACK_INDICATOR,
        null,
        t0.notified_by as CLAIM_HEADER__INTIMATED_BY_ROLE,
        null, null,
        t0.notification_date as CLAIM_HEADER__NOTIFICATION_DATE,
        t0.route_to_adv_committee as CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        t0.is_forum_case as CLAIM_LITIGATION__CONSUMER_FORUM_CASE_INDICATOR,
        null,
        t0.other_ligitation as CLAIM_LITIGATION__OTHER_LITIGATION_INDICATOR,
        null, null, null, null, null, null, null,
        t0.amt_paid_by_salvge_buyer as CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT,
        null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (coalesce(nullif(nullif('LOSS:' || nullif(trim(to_char(t0.claim_id)), ''), 'LOSS:'), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 65: BJAZ_WB_CLM_IP_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.tp_lawyers_ph as AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_CONTACT_NUMBER,
        t0.tp_lawyers_name as AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.surveyor_stage as AUG_CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK,
        null,
        t0.surveyor_stage as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_STAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.comments as CLAIM_HEADER__CLAIM_REMARKS,
        null,
        t0.clm_type as CLAIM_HEADER__CLAIM_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_ip_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 66: BJAZ_WS_MOTCLM_DETAILS
    select
        null,
        nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), '') as CLAIM_BK,
        null,
        nullif(md5(normalise(upper(nullif('LOSSEVENT:' || coalesce(to_char(t0.clm_ref_id), ''), 'LOSSEVENT:')))), '') as LOSS_EVENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cause_type as AUG_LOSS_EVENT_DETAIL__CAUSE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.clm_ref as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        t0.remarks as CLAIM_HEADER__CLAIM_REMARKS,
        null,
        t0.claim_type as CLAIM_HEADER__CLAIM_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif('LOSSEVENT:' || coalesce(to_char(t0.clm_ref_id), ''), 'LOSSEVENT:')))), ''), nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), ''))) is not null

)

select
    CASE_BK,
    CLAIM_BK,
    DOCUMENT_BK,
    LOSS_EVENT_BK,
    __LNK_CLAIM_DOCUMENT,
    AUG_CASE_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
    AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK,
    first_value(AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR) ignore nulls over (partition by CASE_BK, AUG_CASE_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK, AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
    first_value(AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS) ignore nulls over (partition by CASE_BK, AUG_CASE_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK, AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
    first_value(AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS) ignore nulls over (partition by CASE_BK, AUG_CASE_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK, AUG_CASE_DOCUMENT_CHECKLIST__DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
    first_value(AUG_CASE_LITIGATION__COURT_CASE_NUMBER) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_LITIGATION__COURT_CASE_NUMBER,
    first_value(AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_OBTAINED_INDICATOR) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_OBTAINED_INDICATOR,
    first_value(AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_RECEIVED_DATE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_RECEIVED_DATE,
    first_value(AUG_CASE_LITIGATION__COURT_SALE_ORDER_OBTAINED_INDICATOR) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_LITIGATION__COURT_SALE_ORDER_OBTAINED_INDICATOR,
    first_value(AUG_CASE_LITIGATION__COURT_SALE_ORDER_RECEIVED_DATE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_LITIGATION__COURT_SALE_ORDER_RECEIVED_DATE,
    AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
    first_value(AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS) ignore nulls over (partition by CASE_BK, AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS,
    first_value(AUG_CASE_WORKFLOW_TASK__TASK_REMARKS) ignore nulls over (partition by CASE_BK, AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
    first_value(AUG_CLAIM_FRAUD__AML_WAIVER_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FRAUD__AML_WAIVER_INDICATOR,
    first_value(AUG_CLAIM_FRAUD__AML_WAIVER_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FRAUD__AML_WAIVER_REASON,
    first_value(AUG_CLAIM_FRAUD__BYPASS_AUTHORISED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FRAUD__BYPASS_AUTHORISED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_LITIGATION__ADVISORY_COMMITTEE_REMARKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__ADVISORY_COMMITTEE_REMARKS,
    first_value(AUG_CLAIM_LITIGATION__LITIGATION_CASE_NARRATIVE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__LITIGATION_CASE_NARRATIVE,
    first_value(AUG_CLAIM_LITIGATION__LONG_TAIL_DISPUTED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__LONG_TAIL_DISPUTED_INDICATOR,
    first_value(AUG_CLAIM_LITIGATION__OMBUDSMAN_COMPLAINT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__OMBUDSMAN_COMPLAINT_INDICATOR,
    first_value(AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_INDICATOR,
    first_value(AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_RECORD_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__SUIT_OR_RECOVERY_RECORD_INDICATOR,
    first_value(AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_CONTACT_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_CONTACT_NUMBER,
    first_value(AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_LITIGATION__THIRD_PARTY_ADVOCATE_NAME,
    first_value(AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR,
    AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
    AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
    AUG_CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK,
    AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK,
    first_value(AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK, AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT,
    first_value(AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK, AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE,
    AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER_CK,
    first_value(AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER,
    first_value(AUG_CLAIM_SUB_FILE__SUB_FILE_REMARKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SUB_FILE__SUB_FILE_REMARKS,
    AUG_CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK,
    AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK,
    first_value(AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_STAGE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK, AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_STAGE,
    first_value(AUG_CLAIM_TP_FORENSIC__PANCHANAMA_DETAIL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_TP_FORENSIC__PANCHANAMA_DETAIL,
    first_value(AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME,
    first_value(AUG_DOCUMENT_DEFINITION__INVOICE_PRESENT_INDICATOR) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__INVOICE_PRESENT_INDICATOR,
    first_value(AUG_DOCUMENT_DEFINITION__OCR_ACCEPTED_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OCR_ACCEPTED_DATE,
    first_value(AUG_DOCUMENT_DEFINITION__OCR_APPROVED_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OCR_APPROVED_DATE,
    first_value(AUG_DOCUMENT_DEFINITION__OCR_PROCESSING_FLAG) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OCR_PROCESSING_FLAG,
    first_value(AUG_DOCUMENT_DEFINITION__OCR_REQUEST_REFERENCE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OCR_REQUEST_REFERENCE,
    first_value(AUG_DOCUMENT_DEFINITION__OCR_SENT_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OCR_SENT_DATE,
    first_value(AUG_LOSS_EVENT_DETAIL__CAUSE_TYPE_CODE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LOSS_EVENT_DETAIL__CAUSE_TYPE_CODE,
    first_value(AUG_LOSS_LOCATION_ADDRESS__LOCALITY) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LOSS_LOCATION_ADDRESS__LOCALITY,
    CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
    first_value(CASE_EXTERNAL_REF__EXTERNAL_REFERENCE) ignore nulls over (partition by CASE_BK, CASE_EXTERNAL_REF__REFERENCE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE,
    first_value(CASE_HEADER__ASSIGNED_TO_REFERENCE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_HEADER__ASSIGNED_TO_REFERENCE,
    first_value(CASE_HEADER__CASE_STATUS) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_HEADER__CASE_STATUS,
    first_value(CASE_HEADER__CASE_SUB_STATUS) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_HEADER__CASE_SUB_STATUS,
    first_value(CASE_HEADER__RAISED_DATE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_HEADER__RAISED_DATE,
    first_value(CASE_HEADER__RESOLUTION_DATE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_HEADER__RESOLUTION_DATE,
    first_value(CASE_INVESTIGATION__FINDINGS_SUMMARY) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_INVESTIGATION__FINDINGS_SUMMARY,
    first_value(CASE_LITIGATION__CASE_FILING_DATE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_LITIGATION__CASE_FILING_DATE,
    first_value(CASE_LITIGATION__CASE_STAGE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_LITIGATION__CASE_STAGE,
    first_value(CASE_LITIGATION__COURT_NAME) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_LITIGATION__COURT_NAME,
    first_value(CASE_LITIGATION__NEXT_HEARING_DATE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_LITIGATION__NEXT_HEARING_DATE,
    CASE_WORKFLOW_TASK__TASK_CODE_CK,
    first_value(CASE_WORKFLOW_TASK__ASSIGNED_DATE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__ASSIGNED_DATE,
    first_value(CASE_WORKFLOW_TASK__COMPLETED_DATE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__COMPLETED_DATE,
    first_value(CASE_WORKFLOW_TASK__TASK_STATUS) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_STATUS,
    first_value(CASE_WORKFLOW_TASK__TASK_TYPE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_TYPE,
    CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
    CLAIM_EVIDENCE__MEDIA_REFERENCE_CK,
    first_value(CLAIM_EVIDENCE__EVIDENCE_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_EVIDENCE__EVIDENCE_TYPE_CK, CLAIM_EVIDENCE__MEDIA_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_EVIDENCE__EVIDENCE_TYPE,
    first_value(CLAIM_EVIDENCE__MEDIA_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_EVIDENCE__EVIDENCE_TYPE_CK, CLAIM_EVIDENCE__MEDIA_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_EVIDENCE__MEDIA_REFERENCE,
    first_value(CLAIM_FRAUD__DOUBLE_CLAIM_OVERRIDE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FRAUD__DOUBLE_CLAIM_OVERRIDE_INDICATOR,
    first_value(CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR,
    first_value(CLAIM_FRAUD__FRAUD_TRIGGER_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FRAUD__FRAUD_TRIGGER_REASON,
    first_value(CLAIM_HEADER__CLAIM_EXAMINER_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_EXAMINER_REFERENCE,
    first_value(CLAIM_HEADER__CLAIM_HANDLER_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_HANDLER_REFERENCE,
    first_value(CLAIM_HEADER__CLAIM_REFERENCE_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
    first_value(CLAIM_HEADER__CLAIM_REMARKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_REMARKS,
    first_value(CLAIM_HEADER__CLAIM_SUB_STATUS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_SUB_STATUS,
    first_value(CLAIM_HEADER__CLAIM_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_TYPE,
    first_value(CLAIM_HEADER__CLOSED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLOSED_DATE,
    first_value(CLAIM_HEADER__FAST_TRACK_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__FAST_TRACK_INDICATOR,
    first_value(CLAIM_HEADER__HANDLING_ORG_UNIT_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__HANDLING_ORG_UNIT_CODE,
    first_value(CLAIM_HEADER__INTIMATED_BY_ROLE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__INTIMATED_BY_ROLE,
    first_value(CLAIM_HEADER__INTIMATION_CHANNEL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__INTIMATION_CHANNEL,
    first_value(CLAIM_HEADER__LOSS_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__LOSS_DATE,
    first_value(CLAIM_HEADER__NOTIFICATION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__NOTIFICATION_DATE,
    first_value(CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
    first_value(CLAIM_LITIGATION__CONSUMER_FORUM_CASE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__CONSUMER_FORUM_CASE_INDICATOR,
    first_value(CLAIM_LITIGATION__LITIGATION_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__LITIGATION_INDICATOR,
    first_value(CLAIM_LITIGATION__OTHER_LITIGATION_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__OTHER_LITIGATION_INDICATOR,
    CLAIM_NOTE__NOTE_SEQUENCE_CK,
    first_value(CLAIM_NOTE__NOTE_TEXT) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_TEXT,
    first_value(CLAIM_QUALITY_AUDIT__AUDITOR_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_QUALITY_AUDIT__AUDITOR_REFERENCE,
    first_value(CLAIM_QUALITY_AUDIT__AUDIT_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_QUALITY_AUDIT__AUDIT_DATE,
    first_value(CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME,
    first_value(CLAIM_RECOVERY_SALVAGE__RECOVERY_EXPENSE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RECOVERY_SALVAGE__RECOVERY_EXPENSE,
    first_value(CLAIM_RECOVERY_SALVAGE__SALVAGE_DISPOSAL_METHOD) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RECOVERY_SALVAGE__SALVAGE_DISPOSAL_METHOD,
    first_value(CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT,
    first_value(CLAIM_TP_FORENSIC__FIR_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_TP_FORENSIC__FIR_NUMBER,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
    first_value(DOCUMENT_DEFINITION__RECEIVED_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__RECEIVED_DATE,
    first_value(DOCUMENT_DEFINITION__SOURCE_CHANNEL) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__SOURCE_CHANNEL
from merged
