-- Staging model for source table BJAZ_GRP_TPA_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "SERVICE_CHARGE_AMT"::number as service_charge_amt,
    "SERVICE_CHARGE_RATE"::number as service_charge_rate,
    nullif(trim(to_varchar("TPA_CODE")), '') as tpa_code
    from {{ source('health_raw', 'BJAZ_GRP_TPA_EXTN') }}

)

select * from source
