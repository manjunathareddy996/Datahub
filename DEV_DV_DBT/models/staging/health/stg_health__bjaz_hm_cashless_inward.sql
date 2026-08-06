-- Staging model for source table BJAZ_HM_CASHLESS_INWARD (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("CARD_NUMBER"::varchar), '') as card_number,
    "CASHLESS_IN_DATE"::timestamp_ntz as cashless_in_date,
    nullif(trim("CASHLESS_IN_NO"::varchar), '') as cashless_in_no,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("HOSPITAL_ID")), '') as hospital_id,
    nullif(trim("INWARD_REMARK"::varchar), '') as inward_remark,
    nullif(trim("PATIENT_NAME"::varchar), '') as patient_name,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("VIP_FLAG_INWARD"::varchar), '') as vip_flag_inward
    from {{ source('health_raw', 'BJAZ_HM_CASHLESS_INWARD') }}

)

select * from source
