-- Staging model for source table BJAZ_TRV_RIDER_RATE_MAST_MV (Travel LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health/Partner LOB builds.
-- Types read from OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv (real Snowflake DESCRIBE-style
-- metadata, supplied by the mapper) -- not inferred.

with source as (

    select
    "EXTN_PRM_EXCLUDING_ST"::number as extn_prm_excluding_st,
    "MIN_EXTN_PRM"::number as min_extn_prm,
    "MIN_NB_PRM"::number as min_nb_prm,
    "NB_PRM_EXCLUDING_ST"::number as nb_prm_excluding_st,
    nullif(trim(to_varchar("RIDER_SEQ_NO")), '') as rider_seq_no,
    "RIDER_SI"::number as rider_si,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('travel_raw', 'BJAZ_TRV_RIDER_RATE_MAST_MV') }}

)

select * from source
