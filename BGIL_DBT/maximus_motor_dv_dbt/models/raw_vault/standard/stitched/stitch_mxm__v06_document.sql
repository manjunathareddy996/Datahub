-- CENTRAL VIEW v06_document -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_DOCUMENT_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_DOCUMENT_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_DOCUMENT_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_DOCUMENT_DETAIL
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_DOCUMENT_CHECKLIST
--   SAT_MOTOR_AUG_DOCUMENT_DEFINITION
--   SAT_DOCUMENT_CHECKLIST
--   SAT_DOCUMENT_DEFINITION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.claimno),''), '') as CLAIM_BK,
        nullif(coalesce(nullif(trim(t0.inward_number),''), nullif(trim(t0.outward_number),''), nullif(trim(t0.pod_number),'')), '') as DOCUMENT_BK,
        1 as __LNK_CLAIM_DOCUMENT,
        nullif(trim(t0.requirement_type_name),'') as AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        t0.acknowledgment_received as AUG_DOCUMENT_CHECKLIST__ACKNOWLEDGEMENT_RECEIVED_INDICATOR,
        t0.is_this_final_document as AUG_DOCUMENT_CHECKLIST__FINAL_DOCUMENT_INDICATOR,
        t0.c_1st_reminder_date as AUG_DOCUMENT_CHECKLIST__FIRST_REMINDER_DATE,
        t0.last_updated_by as AUG_DOCUMENT_CHECKLIST__LAST_UPDATED_BY_USER_REFERENCE,
        t0.remarks as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
        t0.response as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RESPONSE_TEXT,
        t0.required_from as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_SOURCE_NAME,
        t0.requirement_status as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_STATUS,
        t0.c_2nd_reminder_date as AUG_DOCUMENT_CHECKLIST__SECOND_REMINDER_DATE,
        t0.c_3rd_reminder_date as AUG_DOCUMENT_CHECKLIST__THIRD_REMINDER_DATE,
        t0.courier_name as AUG_DOCUMENT_DEFINITION__COURIER_VENDOR_NAME,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__DISPATCH_DATE,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__DISPATCH_DESTINATION,
        t0.mode_of_dispatch as AUG_DOCUMENT_DEFINITION__DISPATCH_MODE,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__DISPATCH_PRIORITY,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__DISPATCH_REMARKS,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__DISPATCH_SERIAL_NUMBER,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__DISPATCH_STATUS,
        t0.document_details as AUG_DOCUMENT_DEFINITION__DOCUMENT_DETAIL_TEXT,
        t0.mode_of_inward as AUG_DOCUMENT_DEFINITION__INWARD_MODE,
        t0.inward_date as AUG_DOCUMENT_DEFINITION__INWARD_REGISTRATION_DATE,
        t0.outward_date as AUG_DOCUMENT_DEFINITION__OUTWARD_DISPATCH_DATE,
        t0.document_type_outward as AUG_DOCUMENT_DEFINITION__OUTWARD_DOCUMENT_TYPE,
        t0.outward_number as AUG_DOCUMENT_DEFINITION__OUTWARD_REGISTRATION_NUMBER,
        t0.pod_number as AUG_DOCUMENT_DEFINITION__PROOF_OF_DELIVERY_NUMBER,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__RECIPIENT_NAME,
        t0.sender_name as AUG_DOCUMENT_DEFINITION__SENDER_NAME,
        t0.sent_to as AUG_DOCUMENT_DEFINITION__SENT_TO_NAME,
        t0.special_enclosures_details as AUG_DOCUMENT_DEFINITION__SPECIAL_ENCLOSURE_DETAILS,
        t0.special_enclosures_flag as AUG_DOCUMENT_DEFINITION__SPECIAL_ENCLOSURE_INDICATOR,
        nullif(trim(t0.requirement_type_name),'') as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        t0.requirement_type_name as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
        cast(null as varchar) as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.document_type_inward as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        cast(null as varchar) as DOCUMENT_DEFINITION__ISSUE_DATE,
        t0.document_received_date as DOCUMENT_DEFINITION__RECEIVED_DATE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_cover_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_cover_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_cover_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.inward_number),''), nullif(trim(t0.outward_number),''), nullif(trim(t0.pod_number),'')), ''), nullif(nullif(trim(j4.claimno),''), ''))) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_DOCUMENT_DETAILS
    select
        null,
        nullif(nullif(trim(t0.document_id),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        t0.document_generation_date as DOCUMENT_DEFINITION__ISSUE_DATE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_document_dtls') }} t0
    where (nullif(nullif(trim(t0.document_id),''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS
    select
        null,
        nullif(nullif(trim(t0.pod_number),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.courier_name as AUG_DOCUMENT_DEFINITION__COURIER_VENDOR_NAME,
        t0.dispatch_date as AUG_DOCUMENT_DEFINITION__DISPATCH_DATE,
        t0.dispatch_destination as AUG_DOCUMENT_DEFINITION__DISPATCH_DESTINATION,
        t0.dispatch_mode as AUG_DOCUMENT_DEFINITION__DISPATCH_MODE,
        t0.priority as AUG_DOCUMENT_DEFINITION__DISPATCH_PRIORITY,
        t0.remarks as AUG_DOCUMENT_DEFINITION__DISPATCH_REMARKS,
        t0.serial_no as AUG_DOCUMENT_DEFINITION__DISPATCH_SERIAL_NUMBER,
        t0.dispatch_status as AUG_DOCUMENT_DEFINITION__DISPATCH_STATUS,
        null, null, null, null, null, null, null,
        t0.recipient_name as AUG_DOCUMENT_DEFINITION__RECIPIENT_NAME,
        null, null, null, null, null, null, null,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_dispatch_dtls') }} t0
    where (nullif(nullif(trim(t0.pod_number),''), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_DOCUMENT_DETAILS
    select
        null,
        nullif(nullif(trim(t0.document_id),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        t0.document_generation_date as DOCUMENT_DEFINITION__ISSUE_DATE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_document_dtls') }} t0
    where (nullif(nullif(trim(t0.document_id),''), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_DOCUMENT_DETAILS
    select
        null,
        nullif(nullif(trim(t0.document_id),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        t0.document_generation_date as DOCUMENT_DEFINITION__ISSUE_DATE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_document_dtls') }} t0
    where (nullif(nullif(trim(t0.document_id),''), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_DOCUMENT_DETAIL
    select
        null,
        nullif(nullif(trim(t0.document_id),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        t0.document_generation_date as DOCUMENT_DEFINITION__ISSUE_DATE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_document_detail') }} t0
    where (nullif(nullif(trim(t0.document_id),''), '')) is not null

)

select
    CLAIM_BK,
    DOCUMENT_BK,
    __LNK_CLAIM_DOCUMENT,
    AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
    first_value(AUG_DOCUMENT_CHECKLIST__ACKNOWLEDGEMENT_RECEIVED_INDICATOR) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__ACKNOWLEDGEMENT_RECEIVED_INDICATOR,
    first_value(AUG_DOCUMENT_CHECKLIST__FINAL_DOCUMENT_INDICATOR) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__FINAL_DOCUMENT_INDICATOR,
    first_value(AUG_DOCUMENT_CHECKLIST__FIRST_REMINDER_DATE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__FIRST_REMINDER_DATE,
    first_value(AUG_DOCUMENT_CHECKLIST__LAST_UPDATED_BY_USER_REFERENCE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__LAST_UPDATED_BY_USER_REFERENCE,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RESPONSE_TEXT) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RESPONSE_TEXT,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIREMENT_SOURCE_NAME) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_SOURCE_NAME,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIREMENT_STATUS) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_STATUS,
    first_value(AUG_DOCUMENT_CHECKLIST__SECOND_REMINDER_DATE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__SECOND_REMINDER_DATE,
    first_value(AUG_DOCUMENT_CHECKLIST__THIRD_REMINDER_DATE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__THIRD_REMINDER_DATE,
    first_value(AUG_DOCUMENT_DEFINITION__COURIER_VENDOR_NAME) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__COURIER_VENDOR_NAME,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_DATE,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_DESTINATION) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_DESTINATION,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_MODE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_MODE,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_PRIORITY) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_PRIORITY,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_REMARKS) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_REMARKS,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_SERIAL_NUMBER) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_SERIAL_NUMBER,
    first_value(AUG_DOCUMENT_DEFINITION__DISPATCH_STATUS) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DISPATCH_STATUS,
    first_value(AUG_DOCUMENT_DEFINITION__DOCUMENT_DETAIL_TEXT) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__DOCUMENT_DETAIL_TEXT,
    first_value(AUG_DOCUMENT_DEFINITION__INWARD_MODE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__INWARD_MODE,
    first_value(AUG_DOCUMENT_DEFINITION__INWARD_REGISTRATION_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__INWARD_REGISTRATION_DATE,
    first_value(AUG_DOCUMENT_DEFINITION__OUTWARD_DISPATCH_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OUTWARD_DISPATCH_DATE,
    first_value(AUG_DOCUMENT_DEFINITION__OUTWARD_DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OUTWARD_DOCUMENT_TYPE,
    first_value(AUG_DOCUMENT_DEFINITION__OUTWARD_REGISTRATION_NUMBER) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__OUTWARD_REGISTRATION_NUMBER,
    first_value(AUG_DOCUMENT_DEFINITION__PROOF_OF_DELIVERY_NUMBER) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__PROOF_OF_DELIVERY_NUMBER,
    first_value(AUG_DOCUMENT_DEFINITION__RECIPIENT_NAME) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__RECIPIENT_NAME,
    first_value(AUG_DOCUMENT_DEFINITION__SENDER_NAME) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__SENDER_NAME,
    first_value(AUG_DOCUMENT_DEFINITION__SENT_TO_NAME) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__SENT_TO_NAME,
    first_value(AUG_DOCUMENT_DEFINITION__SPECIAL_ENCLOSURE_DETAILS) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__SPECIAL_ENCLOSURE_DETAILS,
    first_value(AUG_DOCUMENT_DEFINITION__SPECIAL_ENCLOSURE_INDICATOR) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__SPECIAL_ENCLOSURE_INDICATOR,
    DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
    first_value(DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK, DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_NAME) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_NAME,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
    first_value(DOCUMENT_DEFINITION__ISSUE_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__ISSUE_DATE,
    first_value(DOCUMENT_DEFINITION__RECEIVED_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__RECEIVED_DATE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on DOCUMENT_BK (SAT_MOTOR_AUG_DOCUMENT_CHECKLIST, SAT_DOCUMENT_CHECKLIST):
    -- one load time per DOCUMENT_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_DOCUMENT_CHECKLIST__ACKNOWLEDGEMENT_RECEIVED_INDICATOR, m.AUG_DOCUMENT_CHECKLIST__FINAL_DOCUMENT_INDICATOR, m.AUG_DOCUMENT_CHECKLIST__FIRST_REMINDER_DATE, m.AUG_DOCUMENT_CHECKLIST__LAST_UPDATED_BY_USER_REFERENCE, m.AUG_DOCUMENT_CHECKLIST__REQUIREMENT_REMARKS, m.AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RESPONSE_TEXT, m.AUG_DOCUMENT_CHECKLIST__REQUIREMENT_SOURCE_NAME, m.AUG_DOCUMENT_CHECKLIST__REQUIREMENT_STATUS, m.AUG_DOCUMENT_CHECKLIST__SECOND_REMINDER_DATE, m.AUG_DOCUMENT_CHECKLIST__THIRD_REMINDER_DATE, m.DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.DOCUMENT_BK) as DOCUMENT_BK__MA_LOAD_DATETIME
from merged m
