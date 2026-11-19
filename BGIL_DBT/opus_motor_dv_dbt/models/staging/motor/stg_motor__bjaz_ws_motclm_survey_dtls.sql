-- Staging for source table BJAZ_WS_MOTCLM_SURVEY_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLM_REF")), '') as clm_ref,
        nullif(trim(to_varchar("TOTAL_ASD_AMT")), '') as total_asd_amt,
        nullif(trim(to_varchar("PLASTIC_PARTS_ASD_AMT")), '') as plastic_parts_asd_amt,
        nullif(trim(to_varchar("METAL_PARTS_ASD_AMT")), '') as metal_parts_asd_amt,
        nullif(trim(to_varchar("GLASD_PARTS_ASD_AMT")), '') as glasd_parts_asd_amt,
        nullif(trim(to_varchar("LABOUR_ASD_AMT")), '') as labour_asd_amt,
        nullif(trim(to_varchar("PAINTING_ASD_AMT")), '') as painting_asd_amt,
        nullif(trim(to_varchar("MISCELLANEOUS_ASD_AMT")), '') as miscellaneous_asd_amt,
        nullif(trim(to_varchar("COMPULSRY_EXCESS_AMT")), '') as compulsry_excess_amt,
        nullif(trim(to_varchar("SALVAGE_AMT")), '') as salvage_amt,
        nullif(trim(to_varchar("VOLUNTARY_EXCESS_AMT")), '') as voluntary_excess_amt,
        nullif(trim(to_varchar("INSURED_LIABLITY_AMT")), '') as insured_liablity_amt,
        nullif(trim(to_varchar("VERSION")), '') as version,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("LAST_MODIFIED_ON")), '') as last_modified_on,
        nullif(trim(to_varchar("INSTRING")), '') as instring,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_WS_MOTCLM_SURVEY_DTLS') }}

)

select * from source
