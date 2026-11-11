-- Staging for source table BJAZ_GRP_TPA_EXTN (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("SERVICE_A")), '') as service_a,
        nullif(trim(to_varchar("SERVICE_B")), '') as service_b,
        nullif(trim(to_varchar("SERVICE_C")), '') as service_c,
        nullif(trim(to_varchar("SERVICE_CHARGE_AMT")), '') as service_charge_amt,
        nullif(trim(to_varchar("SERVICE_CHARGE_RATE")), '') as service_charge_rate,
        nullif(trim(to_varchar("SERVICE_D")), '') as service_d,
        nullif(trim(to_varchar("SERVICE_E")), '') as service_e,
        nullif(trim(to_varchar("SERVICE_F")), '') as service_f,
        nullif(trim(to_varchar("TPA_CODE")), '') as tpa_code
    from {{ source('health_raw', 'BJAZ_GRP_TPA_EXTN') }}

)

select * from source
