-- Staging for source table BJAZ_MOT_TRADE_DTLS_EXTN. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("OBJECT_ID")), '') as object_id,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("VEH_DESC")), '') as veh_desc,
        nullif(trim(to_varchar("INSURED_OCCUP")), '') as insured_occup,
        nullif(trim(to_varchar("TWOWHEELER_YN")), '') as twowheeler_yn,
        nullif(trim(to_varchar("SEATING_CAPACITY")), '') as seating_capacity,
        nullif(trim(to_varchar("TRADECERTI_IDV")), '') as tradecerti_idv,
        nullif(trim(to_varchar("NAMEDRIVER_COUNT")), '') as namedriver_count,
        nullif(trim(to_varchar("BASIC_ADD_ACT_PREMIUM")), '') as basic_add_act_premium,
        nullif(trim(to_varchar("TRADECERTI_FLAG")), '') as tradecerti_flag,
        nullif(trim(to_varchar("TRADECERTI_COUNT")), '') as tradecerti_count,
        nullif(trim(to_varchar("NAMEDRIVER_FLAG")), '') as namedriver_flag,
        nullif(trim(to_varchar("BASIC_FIRST_OD_PREM")), '') as basic_first_od_prem,
        nullif(trim(to_varchar("BASIC_ADD_OD_PREM")), '') as basic_add_od_prem,
        nullif(trim(to_varchar("BASIC_FIRST_ACT_PREM")), '') as basic_first_act_prem,
        nullif(trim(to_varchar("NAMEDRIVER_IDV")), '') as namedriver_idv,
        nullif(trim(to_varchar("LIABILITY")), '') as liability,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_TRADE_DTLS_EXTN') }}

)

select * from source
