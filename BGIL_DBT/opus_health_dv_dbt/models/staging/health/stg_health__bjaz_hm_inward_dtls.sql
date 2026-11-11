-- Staging for source table BJAZ_HM_INWARD_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CALLER_CONTACT_NO")), '') as caller_contact_no,
        nullif(trim(to_varchar("CALLER_EMAIL_ID")), '') as caller_email_id,
        nullif(trim(to_varchar("CERTIFICATE_NO")), '') as certificate_no,
        nullif(trim(to_varchar("CITY_NAME")), '') as city_name,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("COURIER_ID")), '') as courier_id,
        nullif(trim(to_varchar("DELAY_REASON")), '') as delay_reason,
        nullif(trim(to_varchar("DOCUMENT_FLAG")), '') as document_flag,
        nullif(trim(to_varchar("DOC_INW_REMARK")), '') as doc_inw_remark,
        nullif(trim(to_varchar("DOC_REC_DATE")), '') as doc_rec_date,
        nullif(trim(to_varchar("DOC_REC_TIME")), '') as doc_rec_time,
        nullif(trim(to_varchar("DOC_REMARK")), '') as doc_remark,
        nullif(trim(to_varchar("DOC_WT_INWARD")), '') as doc_wt_inward,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("GEO_AREA")), '') as geo_area,
        nullif(trim(to_varchar("HOSP_PORTAL_FLAG")), '') as hosp_portal_flag,
        nullif(trim(to_varchar("HOSP_PRIORITY_FLAG")), '') as hosp_priority_flag,
        nullif(trim(to_varchar("ID_CARD_NO")), '') as id_card_no,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("INSURED_CONTACT_NO")), '') as insured_contact_no,
        nullif(trim(to_varchar("INSURED_EMAIL_ID")), '') as insured_email_id,
        nullif(trim(to_varchar("INWARD_DATE")), '') as inward_date,
        nullif(trim(to_varchar("INWARD_ID")), '') as inward_id,
        nullif(trim(to_varchar("INWARD_NO")), '') as inward_no,
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("OUTWARD_ID")), '') as outward_id,
        nullif(trim(to_varchar("PASSPORT_NO")), '') as passport_no,
        nullif(trim(to_varchar("PERTAIN_TO")), '') as pertain_to,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("PLAN_NAME")), '') as plan_name,
        nullif(trim(to_varchar("POD_NO")), '') as pod_no,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("PRIORITY_FLAG")), '') as priority_flag,
        nullif(trim(to_varchar("PROPOSER_NAME")), '') as proposer_name,
        nullif(trim(to_varchar("SENDER_NAME")), '') as sender_name,
        nullif(trim(to_varchar("STATE_NAME")), '') as state_name,
        nullif(trim(to_varchar("TYPE_OF_LOSS")), '') as type_of_loss,
        nullif(trim(to_varchar("VIP_FLAG")), '') as vip_flag
    from {{ source('health_raw', 'BJAZ_HM_INWARD_DTLS') }}

)

select * from source
