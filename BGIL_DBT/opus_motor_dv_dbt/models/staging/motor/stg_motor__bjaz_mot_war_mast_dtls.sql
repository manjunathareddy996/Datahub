-- Staging for source table BJAZ_MOT_WAR_MAST_DTLS. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("TRANSACTION_ID")), '') as transaction_id,
        nullif(trim(to_varchar("POLICY_START_DATE")), '') as policy_start_date,
        nullif(trim(to_varchar("POLICY_END_DATE")), '') as policy_end_date,
        nullif(trim(to_varchar("POLICY_STATUS")), '') as policy_status,
        nullif(trim(to_varchar("INSERTED_BY")), '') as inserted_by,
        nullif(trim(to_varchar("INSERT_DATE")), '') as insert_date,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATE_DATE")), '') as update_date,
        nullif(trim(to_varchar("TYPE_OF_WARRANTY")), '') as type_of_warranty,
        nullif(trim(to_varchar("SUBTYPE_OF_WARRANTY")), '') as subtype_of_warranty,
        nullif(trim(to_varchar("CHILD_PRODUCT_CODE")), '') as child_product_code,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_WAR_MAST_DTLS') }}

)

select * from source
