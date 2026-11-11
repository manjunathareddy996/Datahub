-- CENTRAL VIEW v06_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_BFHL_DTLS (opus_health_v2)
--   BJAZ_HM_CLAIM_CONVERSION (opus_health_v2)
--   BJAZ_HM_ORPHAN_FOLLOW_DTLS (opus_health_v2)
--   BJAZ_HAT_OCR_BILL_DETAILS (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_QUERY_REMARK (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_ANOMALY_DETECTION
--   SAT_AUG_CLAIM_BILL_DIGITISATION
--   SAT_AUG_CLAIM_CONVERSION_EVENT
--   SAT_AUG_CLAIM_FOLLOW_UP_CHASE
--   SAT_CLAIM_BILL_DIGITISATION
--   SAT_CLAIM_NOTE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_POLICY
--   LNK_POLICY_LOCATION
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_BFHL_DTLS
    select
        nullif(trim(claim_no),'') as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        anomaly_description as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        anomaly_timestamp as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        is_anomaly_found as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        anomaly_sub_type as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        anomaly_supporting_doc as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        anomaly_type as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        by_pass_remarks_by as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        by_pass_remarks_updated_on as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        by_pass_remarks as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        doc_class as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_bfhl_dtls') }}
    where (nullif(trim(claim_no),'')) is not null

    union all

    -- branch 1: BJAZ_HM_CLAIM_CONVERSION
    select
        nullif(trim(claim_id),'') as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        conv_id as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        coalesce(convert_date, updated_on) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        conv_id as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        conv_type as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        updated_by as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        prev_claim_id as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_claim_conversion') }}
    where (nullif(trim(claim_id),'')) is not null

    union all

    -- branch 2: BJAZ_HM_ORPHAN_FOLLOW_DTLS
    select
        nullif(trim(claim_id),'') as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        document_from as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        fir_rem_date as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        coalesce(intimation_date, updated_on) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        followup_reason as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        followup_id as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        updated_by as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        orphan_id as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        reply_date as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        sec_rem_date as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        2 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_orphan_follow_dtls') }}
    where (nullif(trim(claim_id),'')) is not null

    union all

    -- branch 3: BJAZ_HAT_OCR_BILL_DETAILS
    select
        case_id as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        inward_no as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_ocr_bill_details') }}
    where (case_id) is not null

    union all

    -- branch 4: BJAZ_HM_BILL_DETAIL
    select
        claim_id as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        bill_status as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        genral_remarks as CLAIM_NOTE__NOTE_TEXT,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_bill_detail') }}
    where (claim_id) is not null

    union all

    -- branch 5: BJAZ_HM_BILL_DETAIL_OCR
    select
        claim_id as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        add_status as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        ref_bill_id as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        bill_status as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
    where (claim_id) is not null

    union all

    -- branch 6: BJAZ_HM_ORPHAN_REG
    select
        claim_id as CLAIM_BK,
        orphan_loc as LOCATION_BK,
        policy_number as POLICY_BK,
        1 as __LNK_CLAIM_LOCATION,
        1 as __LNK_CLAIM_POLICY,
        1 as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        orphan_follow_flag as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        orphan_close_remark as CLAIM_NOTE__NOTE_TEXT,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where (coalesce(claim_id, orphan_loc, policy_number)) is not null

    union all

    -- branch 7: BJAZ_HM_QUERY_REMARK
    select
        claim_id as CLAIM_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_LOCATION,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
        cast(null as varchar) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
        cast(null as varchar) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
        cast(null as varchar) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
        query_remark as CLAIM_NOTE__NOTE_TEXT,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_query_remark') }}
    where (claim_id) is not null

)

select
    CLAIM_BK,
    LOCATION_BK,
    POLICY_BK,
    __LNK_CLAIM_LOCATION,
    __LNK_CLAIM_POLICY,
    __LNK_POLICY_LOCATION,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DESCRIPTION,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_DETECTED_TIMESTAMP,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_FOUND_INDICATOR,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUB_TYPE_CODE,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_SUPPORTING_DOCUMENT_URI,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__ANOMALY_TYPE_CODE,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_AUTHORISED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_DECISION_TIMESTAMP,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__BYPASS_REMARKS,
    first_value(AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ANOMALY_DETECTION__DOCUMENT_CLASS_EXAMINED,
    first_value(AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS,
    first_value(AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE,
    AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK,
    first_value(AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE,
    first_value(AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE,
    first_value(AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE,
    first_value(AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER,
    first_value(AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__DOCUMENT_SOURCE_STAGE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_INTIMATION_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REASON,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__ORPHAN_RECORD_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__REPLY_RECEIVED_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
    CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(CLAIM_BILL_DIGITISATION__BILL_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BILL_DIGITISATION__BILL_REFERENCE,
    first_value(CLAIM_BILL_DIGITISATION__INVOICE_STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BILL_DIGITISATION__INVOICE_STATUS,
    CLAIM_NOTE__NOTE_SEQUENCE_CK,
    first_value(CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR,
    first_value(CLAIM_NOTE__NOTE_TEXT) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_TEXT
from merged
