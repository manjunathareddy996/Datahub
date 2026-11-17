-- Staging for source table BJAZ_MOT_TAC_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("ROAD_TYPE")), '') as road_type,
        nullif(trim(to_varchar("VEH_DRIVEN_BY")), '') as veh_driven_by,
        nullif(trim(to_varchar("DRIVER_EXPERIENCE")), '') as driver_experience,
        nullif(trim(to_varchar("CLM_HIST_CODE")), '') as clm_hist_code,
        nullif(trim(to_varchar("INCURRED_CLM_EXP_CODE")), '') as incurred_clm_exp_code,
        nullif(trim(to_varchar("DRIVER_QUALIFICATION_CODE")), '') as driver_qualification_code,
        nullif(trim(to_varchar("TAC_MAKE_CODE")), '') as tac_make_code,
        nullif(trim(to_varchar("EXT_COL1")), '') as ext_col1,
        nullif(trim(to_varchar("EXT_COL2")), '') as ext_col2,
        nullif(trim(to_varchar("EXT_COL3")), '') as ext_col3,
        nullif(trim(to_varchar("EXT_COL4")), '') as ext_col4,
        nullif(trim(to_varchar("EXT_COL5")), '') as ext_col5,
        nullif(trim(to_varchar("EXT_COL6")), '') as ext_col6,
        nullif(trim(to_varchar("EXT_COL7")), '') as ext_col7,
        nullif(trim(to_varchar("EXT_COL8")), '') as ext_col8,
        nullif(trim(to_varchar("EXT_COL9")), '') as ext_col9,
        nullif(trim(to_varchar("EXT_COL10")), '') as ext_col10,
        nullif(trim(to_varchar("EXT_COL11")), '') as ext_col11,
        nullif(trim(to_varchar("EXT_COL12")), '') as ext_col12,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_TAC_DTLS') }}

)

select * from source
