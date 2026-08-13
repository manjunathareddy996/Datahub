-- Staging model for source table BJAZ_STARPKG_FF_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("CI_YN"::varchar), '') as ci_yn,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PRE_EXIST_DISEASE"::varchar), '') as pre_exist_disease,
    nullif(trim("RELATION"::varchar), '') as relation
    from {{ source('health_raw', 'BJAZ_STARPKG_FF_DTLS') }}

)

select * from source
