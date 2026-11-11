-- Staging for source table BJAZ_HCS_PLANSI_MAPP (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AIR_AMBULANCE_SI")), '') as air_ambulance_si,
        nullif(trim(to_varchar("DONOR_SI")), '') as donor_si,
        nullif(trim(to_varchar("EFFECTIVE_DT")), '') as effective_dt,
        nullif(trim(to_varchar("HOSP_SI")), '') as hosp_si,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("IS_APPLICABLE")), '') as is_applicable,
        nullif(trim(to_varchar("MATERNITY_SI")), '') as maternity_si,
        nullif(trim(to_varchar("OPD_SI")), '') as opd_si,
        nullif(trim(to_varchar("PARAM_GROUP")), '') as param_group,
        nullif(trim(to_varchar("PARAM_ID")), '') as param_id,
        nullif(trim(to_varchar("PHY_SI")), '') as phy_si,
        nullif(trim(to_varchar("PLAN_NAME")), '') as plan_name,
        nullif(trim(to_varchar("PLAN_SI")), '') as plan_si,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("RECOVERY_THEFT_SI")), '') as recovery_theft_si
    from {{ source('health_raw', 'BJAZ_HCS_PLANSI_MAPP') }}

)

select * from source
