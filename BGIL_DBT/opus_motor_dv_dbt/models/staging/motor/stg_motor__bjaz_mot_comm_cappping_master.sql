-- Staging for source table BJAZ_MOT_COMM_CAPPPING_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("VEHICLE_MAKE_CODE")), '') as vehicle_make_code,
        nullif(trim(to_varchar("BUSINESS_TYPE")), '') as business_type,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUBIMD_CODE")), '') as subimd_code,
        nullif(trim(to_varchar("RELAXATION_CAP")), '') as relaxation_cap,
        nullif(trim(to_varchar("MAXIMUM_CAP")), '') as maximum_cap,
        nullif(trim(to_varchar("BENEFIT_PO_CAP")), '') as benefit_po_cap,
        nullif(trim(to_varchar("VALUE_FROM")), '') as value_from,
        nullif(trim(to_varchar("VALUE_TO")), '') as value_to,
        nullif(trim(to_varchar("APPROVER_LEVEL")), '') as approver_level,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("STATUS")), '') as status,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_COMM_CAPPPING_MASTER') }}

)

select * from source
