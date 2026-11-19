-- Staging for source table BA_QUOTE_MOT_COVERS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("COVER_NO")), '') as cover_no,
        nullif(trim(to_varchar("COVER_RATE")), '') as cover_rate,
        nullif(trim(to_varchar("VOLUNTARY_EXCESS")), '') as voluntary_excess,
        nullif(trim(to_varchar("PA_NO_OF_PERSONS")), '') as pa_no_of_persons,
        nullif(trim(to_varchar("PA_NO_DRV_CL")), '') as pa_no_drv_cl,
        nullif(trim(to_varchar("COVER_DISC")), '') as cover_disc,
        nullif(trim(to_varchar("COVER_LOAD")), '') as cover_load,
        nullif(trim(to_varchar("ENABLE_DISC")), '') as enable_disc,
        nullif(trim(to_varchar("TYRE1")), '') as tyre1,
        nullif(trim(to_varchar("TYRE2")), '') as tyre2,
        nullif(trim(to_varchar("TYRE3")), '') as tyre3,
        nullif(trim(to_varchar("TYRE4")), '') as tyre4,
        nullif(trim(to_varchar("TYRE5")), '') as tyre5,
        nullif(trim(to_varchar("COVER_PREM")), '') as cover_prem,
        nullif(trim(to_varchar("SGST_AMT")), '') as sgst_amt,
        nullif(trim(to_varchar("CGST_AMT")), '') as cgst_amt,
        nullif(trim(to_varchar("IGST_AMT")), '') as igst_amt,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BA_QUOTE_MOT_COVERS') }}

)

select * from source
