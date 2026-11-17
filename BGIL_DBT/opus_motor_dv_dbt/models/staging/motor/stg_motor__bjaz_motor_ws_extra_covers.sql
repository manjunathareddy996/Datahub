-- Staging for source table BJAZ_MOTOR_WS_EXTRA_COVERS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TRANSACTIONID")), '') as transactionid,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("MODULE_FROM")), '') as module_from,
        nullif(trim(to_varchar("GEOG_EXTN")), '') as geog_extn,
        nullif(trim(to_varchar("NO_OF_PERSONS_PA")), '') as no_of_persons_pa,
        nullif(trim(to_varchar("SUM_INSURED_PA")), '') as sum_insured_pa,
        nullif(trim(to_varchar("SUM_INSURED_TOTAL_NAMED_PA")), '') as sum_insured_total_named_pa,
        nullif(trim(to_varchar("CNG_VALUE")), '') as cng_value,
        nullif(trim(to_varchar("NO_OF_EMPLOYEES_LLE")), '') as no_of_employees_lle,
        nullif(trim(to_varchar("NO_OF_PERSONS_LLO")), '') as no_of_persons_llo,
        nullif(trim(to_varchar("FIBRE_GLASS_VALUE")), '') as fibre_glass_value,
        nullif(trim(to_varchar("SIDE_CAR_VALUE")), '') as side_car_value,
        nullif(trim(to_varchar("NO_OF_TRAILERS")), '') as no_of_trailers,
        nullif(trim(to_varchar("TOTAL_TRAILER_VALUE")), '') as total_trailer_value,
        nullif(trim(to_varchar("VOLUNTARY_EXCESS")), '') as voluntary_excess,
        nullif(trim(to_varchar("COVERNOTE_NO")), '') as covernote_no,
        nullif(trim(to_varchar("COVERNOTE_DATE")), '') as covernote_date,
        nullif(trim(to_varchar("SUB_IMDCODE")), '') as sub_imdcode,
        nullif(trim(to_varchar("EXTRA_FIELD1")), '') as extra_field1,
        nullif(trim(to_varchar("EXTRA_FIELD2")), '') as extra_field2,
        nullif(trim(to_varchar("EXTRA_FIELD3")), '') as extra_field3,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOTOR_WS_EXTRA_COVERS') }}

)

select * from source
