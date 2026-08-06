-- Staging model for source table BA_HCP_PORT_WORDINGS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "CB_APPLICABLE"::number as cb_applicable,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "DOB"::timestamp_ntz as dob,
    nullif(trim("EMAIL"::varchar), '') as email,
    nullif(trim("GENDER"::varchar), '') as gender,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    nullif(trim("MEM_NAME"::varchar), '') as mem_name,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PREV_INSURER"::varchar), '') as prev_insurer,
    nullif(trim("PREV_POLICY_NO"::varchar), '') as prev_policy_no,
    "PREV_SI"::number as prev_si,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator
    from {{ source('health_raw', 'BA_HCP_PORT_WORDINGS') }}

)

select * from source
