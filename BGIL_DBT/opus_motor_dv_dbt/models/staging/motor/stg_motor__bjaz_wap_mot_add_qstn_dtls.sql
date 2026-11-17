-- Staging for source table BJAZ_WAP_MOT_ADD_QSTN_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TRANS_ID")), '') as trans_id,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("USER_ID")), '') as user_id,
        nullif(trim(to_varchar("CLAIM_YN")), '') as claim_yn,
        nullif(trim(to_varchar("OD_CLAIM")), '') as od_claim,
        nullif(trim(to_varchar("OD_CLAIM_AMT")), '') as od_claim_amt,
        nullif(trim(to_varchar("TP_CLAIM")), '') as tp_claim,
        nullif(trim(to_varchar("TP_CLAIM_AMT")), '') as tp_claim_amt,
        nullif(trim(to_varchar("THEFT_INDICATOR")), '') as theft_indicator,
        nullif(trim(to_varchar("TOTAL_CLAIM_INDICATOR")), '') as total_claim_indicator,
        nullif(trim(to_varchar("PARTIAL_LOSS_SCORE")), '') as partial_loss_score,
        nullif(trim(to_varchar("KM_READING")), '') as km_reading,
        nullif(trim(to_varchar("VEH_AGE")), '') as veh_age,
        nullif(trim(to_varchar("DRIVING_OFFENCE_SCORE")), '') as driving_offence_score,
        nullif(trim(to_varchar("VEH_DRIVER")), '') as veh_driver,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("MARITAL_STATUS")), '') as marital_status,
        nullif(trim(to_varchar("PROFESSION")), '') as profession,
        nullif(trim(to_varchar("BAGIC_MOT_POL_YN")), '') as bagic_mot_pol_yn,
        nullif(trim(to_varchar("BAGIC_MOT_POL")), '') as bagic_mot_pol,
        nullif(trim(to_varchar("BAGIC_NONMOT_POL_YN")), '') as bagic_nonmot_pol_yn,
        nullif(trim(to_varchar("BAGIC_NONMOT_POL")), '') as bagic_nonmot_pol,
        nullif(trim(to_varchar("IMD_CHANNEL")), '') as imd_channel,
        nullif(trim(to_varchar("ODMETER")), '') as odmeter,
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("MOTOR_WS_TRANS_ID")), '') as motor_ws_trans_id,
        nullif(trim(to_varchar("PACKAGE_DESC")), '') as package_desc,
        nullif(trim(to_varchar("REG_NO_PART1")), '') as reg_no_part1,
        nullif(trim(to_varchar("REG_NO_PART2")), '') as reg_no_part2,
        nullif(trim(to_varchar("REG_NO_PART3")), '') as reg_no_part3,
        nullif(trim(to_varchar("REG_NO_PART4")), '') as reg_no_part4,
        nullif(trim(to_varchar("PIN_CONDITION")), '') as pin_condition,
        nullif(trim(to_varchar("VEHICLE_TYPE")), '') as vehicle_type,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_WAP_MOT_ADD_QSTN_DTLS') }}

)

select * from source
