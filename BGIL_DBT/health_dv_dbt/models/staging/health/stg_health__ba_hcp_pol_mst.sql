-- Staging model for source table BA_HCP_POL_MST (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CHILD_LOC_CODE")), '') as child_loc_code,
    "CLAIM_DISCOUNT"::number as claim_discount,
    "CLAIM_LOADING"::number as claim_loading,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "CTO_CEO_DISCOUNT"::number as cto_ceo_discount,
    "CTO_CEO_LOADING"::number as cto_ceo_loading,
    "GROUP_DISCOUNT"::number as group_discount,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim("IMD_NAME"::varchar), '') as imd_name,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    "POLICY_END_DATE"::timestamp_ntz as policy_end_date,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    "POLICY_START_DATE"::timestamp_ntz as policy_start_date,
    nullif(trim("POLICY_STATUS"::varchar), '') as policy_status,
    nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
    nullif(trim(to_varchar("USER_ID")), '') as user_id
    from {{ source('health_raw', 'BA_HCP_POL_MST') }}

)

select * from source
