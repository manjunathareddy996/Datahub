-- Staging for source table BA_HCP_POL_MST (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CHILD_LOC_CODE")), '') as child_loc_code,
        nullif(trim(to_varchar("CLAIM_DISCOUNT")), '') as claim_discount,
        nullif(trim(to_varchar("CLAIM_LOADING")), '') as claim_loading,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("CTO_CEO_DISCOUNT")), '') as cto_ceo_discount,
        nullif(trim(to_varchar("CTO_CEO_LOADING")), '') as cto_ceo_loading,
        nullif(trim(to_varchar("GROUP_DISCOUNT")), '') as group_discount,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("IMD_NAME")), '') as imd_name,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("POLICY_END_DATE")), '') as policy_end_date,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("POLICY_START_DATE")), '') as policy_start_date,
        nullif(trim(to_varchar("POLICY_STATUS")), '') as policy_status,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("USER_ID")), '') as user_id
    from {{ source('health_raw', 'BA_HCP_POL_MST') }}

)

select * from source
