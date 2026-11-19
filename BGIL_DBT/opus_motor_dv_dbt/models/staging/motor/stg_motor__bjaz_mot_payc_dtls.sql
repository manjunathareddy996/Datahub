-- Staging for source table BJAZ_MOT_PAYC_DTLS. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("VEHICLE_ID")), '') as vehicle_id,
        nullif(trim(to_varchar("PAYC_PLAN_A")), '') as payc_plan_a,
        nullif(trim(to_varchar("PAYG_PLAN_B")), '') as payg_plan_b,
        nullif(trim(to_varchar("PAYG_PLAN_C")), '') as payg_plan_c,
        nullif(trim(to_varchar("TRIP_FROM")), '') as trip_from,
        nullif(trim(to_varchar("TRIP_TO")), '') as trip_to,
        nullif(trim(to_varchar("TRIP_FROM_DATE")), '') as trip_from_date,
        nullif(trim(to_varchar("TRIP_TO_DATE")), '') as trip_to_date,
        nullif(trim(to_varchar("PAY_C_KM_TYPE")), '') as pay_c_km_type,
        nullif(trim(to_varchar("DECL_KM_AS_ON_DATE")), '') as decl_km_as_on_date,
        nullif(trim(to_varchar("CURRENT_KM")), '') as current_km,
        nullif(trim(to_varchar("APPLICABLE_RANGE_FROM")), '') as applicable_range_from,
        nullif(trim(to_varchar("APPLICABLE_RANGE_TO")), '') as applicable_range_to,
        nullif(trim(to_varchar("TOTAL_KM_BENEFIT")), '') as total_km_benefit,
        nullif(trim(to_varchar("PAYG_RID")), '') as payg_rid,
        nullif(trim(to_varchar("PAYG_RED")), '') as payg_red,
        nullif(trim(to_varchar("PAYG_RID_TIME")), '') as payg_rid_time,
        nullif(trim(to_varchar("KM_TOP_UP")), '') as km_top_up,
        nullif(trim(to_varchar("BONUS_KM")), '') as bonus_km,
        nullif(trim(to_varchar("REST_PROD_POL_REQYN")), '') as rest_prod_pol_reqyn,
        nullif(trim(to_varchar("WAITING_PERIOD")), '') as waiting_period,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_PAYC_DTLS') }}

)

select * from source
