-- Staging for source table BJAZ_MOT_ADD_QSTN_DTLS. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("PARTITION_NO")), '') as partition_no,
        nullif(trim(to_varchar("KM_READING")), '') as km_reading,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("CLAIM_YN")), '') as claim_yn,
        nullif(trim(to_varchar("OD_CLAIM")), '') as od_claim,
        nullif(trim(to_varchar("OD_CLAIM_AMT")), '') as od_claim_amt,
        nullif(trim(to_varchar("TP_CLAIM")), '') as tp_claim,
        nullif(trim(to_varchar("TP_CLAIM_AMT")), '') as tp_claim_amt,
        nullif(trim(to_varchar("THEFT_INDICATOR")), '') as theft_indicator,
        nullif(trim(to_varchar("TOTAL_CLAIM_INDICATOR")), '') as total_claim_indicator,
        nullif(trim(to_varchar("PARTIAL_LOSS_SCORE")), '') as partial_loss_score,
        nullif(trim(to_varchar("VEH_AGE")), '') as veh_age,
        nullif(trim(to_varchar("DRIVING_OFFENCE_SCORE")), '') as driving_offence_score,
        nullif(trim(to_varchar("VEH_DRIVER")), '') as veh_driver,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("MARITAL_STATUS")), '') as marital_status,
        nullif(trim(to_varchar("PROFESSION")), '') as profession,
        nullif(trim(to_varchar("PAN_NO")), '') as pan_no,
        nullif(trim(to_varchar("BAGIC_MOT_POL_YN")), '') as bagic_mot_pol_yn,
        nullif(trim(to_varchar("BAGIC_MOT_POL")), '') as bagic_mot_pol,
        nullif(trim(to_varchar("BAGIC_NONMOT_POL_YN")), '') as bagic_nonmot_pol_yn,
        nullif(trim(to_varchar("BAGIC_NONMOT_POL")), '') as bagic_nonmot_pol,
        nullif(trim(to_varchar("IMD_CHANNEL")), '') as imd_channel,
        nullif(trim(to_varchar("ODMETER")), '') as odmeter,
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("CHALLAN")), '') as challan,
        nullif(trim(to_varchar("STPVEHSUBTYPE")), '') as stpvehsubtype,
        nullif(trim(to_varchar("STP_PIN")), '') as stp_pin,
        nullif(trim(to_varchar("DRV_OFFENCE_YN")), '') as drv_offence_yn,
        nullif(trim(to_varchar("DRV_OFFENCE_CNT")), '') as drv_offence_cnt,
        nullif(trim(to_varchar("CLAIM_OFFENCE_CNT")), '') as claim_offence_cnt,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_ADD_QSTN_DTLS') }}

)

select * from source
