-- Staging for source table BA_HCP_PORT_WORDINGS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CB_APPLICABLE")), '') as cb_applicable,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DOB")), '') as dob,
        nullif(trim(to_varchar("EMAIL")), '') as email,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("INCEPTION_DATE")), '') as inception_date,
        nullif(trim(to_varchar("MEM_NAME")), '') as mem_name,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("POL_VERSION_NO")), '') as pol_version_no,
        nullif(trim(to_varchar("PORT_REASON")), '') as port_reason,
        nullif(trim(to_varchar("PREV_INSURER")), '') as prev_insurer,
        nullif(trim(to_varchar("PREV_POLICY_EXP_DATE")), '') as prev_policy_exp_date,
        nullif(trim(to_varchar("PREV_POLICY_NO")), '') as prev_policy_no,
        nullif(trim(to_varchar("PREV_SI")), '') as prev_si,
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator
    from {{ source('health_raw', 'BA_HCP_PORT_WORDINGS') }}

)

select * from source
