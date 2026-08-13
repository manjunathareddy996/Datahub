-- Staging model for source table BJAZ_HM_CLM_ENHANCE (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    "ENHANCE_AUTH_AMT"::number as enhance_auth_amt,
    "ENHANCE_DATE"::timestamp_ntz as enhance_date,
    "ENHANCE_PREAUTH_AMT"::number as enhance_preauth_amt
    from {{ source('health_raw', 'BJAZ_HM_CLM_ENHANCE') }}

)

select * from source
