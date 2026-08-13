-- Staging model for source table BJAZ_HM_PREAUTH_QUERY (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLID")), '') as clid,
    nullif(trim(to_varchar("HOSP_ID")), '') as hosp_id,
    nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
    nullif(trim(to_varchar("PATIENT_ID_CARD")), '') as patient_id_card,
    nullif(trim(to_varchar("QUERY_REF_ID")), '') as query_ref_id
    from {{ source('health_raw', 'BJAZ_HM_PREAUTH_QUERY') }}

)

select * from source
