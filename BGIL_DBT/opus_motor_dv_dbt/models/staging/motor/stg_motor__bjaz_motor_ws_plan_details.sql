-- Staging for source table BJAZ_MOTOR_WS_PLAN_DETAILS. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("POL_TYPE")), '') as pol_type,
        nullif(trim(to_varchar("PRODUCT_4DIGIT_CODE")), '') as product_4digit_code,
        nullif(trim(to_varchar("DEPT_CODE")), '') as dept_code,
        nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
        nullif(trim(to_varchar("TERM_START_DATE")), '') as term_start_date,
        nullif(trim(to_varchar("TERM_END_DATE")), '') as term_end_date,
        nullif(trim(to_varchar("TP_FIN_TYPE")), '') as tp_fin_type,
        nullif(trim(to_varchar("HYPO")), '') as hypo,
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("VEHICLE_TYPE")), '') as vehicle_type,
        nullif(trim(to_varchar("MISC_VEH_TYPE")), '') as misc_veh_type,
        nullif(trim(to_varchar("VEHICLE_MAKE_CODE")), '') as vehicle_make_code,
        nullif(trim(to_varchar("VEHICLE_MAKE")), '') as vehicle_make,
        nullif(trim(to_varchar("VEHICLE_MODEL_CODE")), '') as vehicle_model_code,
        nullif(trim(to_varchar("VEHICLE_MODEL")), '') as vehicle_model,
        nullif(trim(to_varchar("VEHICLE_SUBTYPE_CODE")), '') as vehicle_subtype_code,
        nullif(trim(to_varchar("VEHICLE_SUBTYPE")), '') as vehicle_subtype,
        nullif(trim(to_varchar("FUEL")), '') as fuel,
        nullif(trim(to_varchar("ZONE")), '') as zone,
        nullif(trim(to_varchar("ENGINE_NO")), '') as engine_no,
        nullif(trim(to_varchar("CHASSIS_NO")), '') as chassis_no,
        nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
        nullif(trim(to_varchar("REGISTRATION_DATE")), '') as registration_date,
        nullif(trim(to_varchar("REGISTRATION_LOCATION")), '') as registration_location,
        nullif(trim(to_varchar("REGI_LOC_OTHER")), '') as regi_loc_other,
        nullif(trim(to_varchar("CARRYING_CAPACITY")), '') as carrying_capacity,
        nullif(trim(to_varchar("CUBIC_CAPACITY")), '') as cubic_capacity,
        nullif(trim(to_varchar("YEAR_MANF")), '') as year_manf,
        nullif(trim(to_varchar("COLOR")), '') as color,
        nullif(trim(to_varchar("VEHICLE_IDV")), '') as vehicle_idv,
        nullif(trim(to_varchar("NCB")), '') as ncb,
        nullif(trim(to_varchar("ADD_LOADING")), '') as add_loading,
        nullif(trim(to_varchar("ADD_LOADING_ON")), '') as add_loading_on,
        nullif(trim(to_varchar("SP_DISC_RATE")), '') as sp_disc_rate,
        nullif(trim(to_varchar("ELEC_ACC_TOTAL")), '') as elec_acc_total,
        nullif(trim(to_varchar("NON_ELEC_ACC_TOTAL")), '') as non_elec_acc_total,
        nullif(trim(to_varchar("PRV_POLICY_REF")), '') as prv_policy_ref,
        nullif(trim(to_varchar("PRV_EXPIRY_DATE")), '') as prv_expiry_date,
        nullif(trim(to_varchar("PRV_INS_COMPANY")), '') as prv_ins_company,
        nullif(trim(to_varchar("PRV_NCB")), '') as prv_ncb,
        nullif(trim(to_varchar("PRV_CLAIM_STATUS")), '') as prv_claim_status,
        nullif(trim(to_varchar("AUTO_MEMBERSHIP")), '') as auto_membership,
        nullif(trim(to_varchar("PARTNER_TYPE")), '') as partner_type,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOTOR_WS_PLAN_DETAILS') }}

)

select * from source
