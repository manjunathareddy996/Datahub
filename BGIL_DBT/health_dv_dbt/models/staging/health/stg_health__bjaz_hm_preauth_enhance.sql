-- Staging model for source table BJAZ_HM_PREAUTH_ENHANCE (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLID")), '') as clid,
    nullif(trim(to_varchar("ENHANCE_REF_ID")), '') as enhance_ref_id,
    nullif(trim("ENHANCE_REQUEST"::varchar), '') as enhance_request,
    "EXPECTED_DOD"::timestamp_ntz as expected_dod,
    nullif(trim(to_varchar("HOSP_ID")), '') as hosp_id,
    nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
    nullif(trim(to_varchar("PATIENT_ID_CARD")), '') as patient_id_card,
    "TRANS_AMOUNT"::number as trans_amount
    from {{ source('health_raw', 'BJAZ_HM_PREAUTH_ENHANCE') }}

)

select * from source
