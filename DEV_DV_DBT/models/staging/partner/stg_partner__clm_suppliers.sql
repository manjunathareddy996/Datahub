-- Staging model for source table CLM_SUPPLIERS (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim(to_varchar("SUPP_ID")), '') as supp_id,
    nullif(trim("SUPP_TYPE"::varchar), '') as supp_type,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    "EFF_DATE"::timestamp_ntz as eff_date,
    "EXP_DATE"::timestamp_ntz as exp_date,
    nullif(trim("SUPP_STATUS"::varchar), '') as supp_status,
    nullif(trim("CONTACT"::varchar), '') as contact,
    nullif(trim("COMMENTS"::varchar), '') as comments,
    nullif(trim(to_varchar("LOC_CODE")), '') as loc_code,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date
    from {{ source('partner_raw', 'CLM_SUPPLIERS') }}

)

select * from source
