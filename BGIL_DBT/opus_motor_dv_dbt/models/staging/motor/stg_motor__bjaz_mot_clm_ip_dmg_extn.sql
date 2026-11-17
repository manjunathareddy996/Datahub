-- Staging for source table BJAZ_MOT_CLM_IP_DMG_EXTN. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("IP_NO")), '') as ip_no,
        nullif(trim(to_varchar("DAMAGED_OBJECT")), '') as damaged_object,
        nullif(trim(to_varchar("SF_NO")), '') as sf_no,
        nullif(trim(to_varchar("VEHICLE_ID")), '') as vehicle_id,
        nullif(trim(to_varchar("VEHICLE_VERSION")), '') as vehicle_version,
        nullif(trim(to_varchar("KIND_OF_DAMAGE")), '') as kind_of_damage,
        nullif(trim(to_varchar("DAMAGE_DESC")), '') as damage_desc,
        nullif(trim(to_varchar("OBJECT_DESC")), '') as object_desc,
        nullif(trim(to_varchar("INJURED_NAME")), '') as injured_name,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("SEX")), '') as sex,
        nullif(trim(to_varchar("ADDRESS")), '') as address,
        nullif(trim(to_varchar("OCCUPATION")), '') as occupation,
        nullif(trim(to_varchar("INCOME")), '') as income,
        nullif(trim(to_varchar("TYPE_OF_INJURY")), '') as type_of_injury,
        nullif(trim(to_varchar("INJURY_DETAILS")), '') as injury_details,
        nullif(trim(to_varchar("PHYSICAL_INFIRMITY")), '') as physical_infirmity,
        nullif(trim(to_varchar("CEASED_DATE")), '') as ceased_date,
        nullif(trim(to_varchar("RESUMED_DATE")), '') as resumed_date,
        nullif(trim(to_varchar("PERIOD_OF_DISABLEMENT")), '') as period_of_disablement,
        nullif(trim(to_varchar("NEGLIGENCE_DETAILS")), '') as negligence_details,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_CLM_IP_DMG_EXTN') }}

)

select * from source
