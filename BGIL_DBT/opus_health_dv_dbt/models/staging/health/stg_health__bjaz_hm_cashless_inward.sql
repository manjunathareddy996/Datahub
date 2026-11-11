-- Staging for source table BJAZ_HM_CASHLESS_INWARD (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CARD_NUMBER")), '') as card_number,
        nullif(trim(to_varchar("CASHLESS_IN_DATE")), '') as cashless_in_date,
        nullif(trim(to_varchar("CASHLESS_IN_NO")), '') as cashless_in_no,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("HOSPITAL_ID")), '') as hospital_id,
        nullif(trim(to_varchar("INWARD_REMARK")), '') as inward_remark,
        nullif(trim(to_varchar("INWARD_STATUS")), '') as inward_status,
        nullif(trim(to_varchar("PATIENT_NAME")), '') as patient_name,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("VIP_FLAG_INWARD")), '') as vip_flag_inward
    from {{ source('health_raw', 'BJAZ_HM_CASHLESS_INWARD') }}

)

select * from source
