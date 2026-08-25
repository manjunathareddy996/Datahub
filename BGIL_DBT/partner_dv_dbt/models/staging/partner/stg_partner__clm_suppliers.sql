-- Staging model for source table CLM_SUPPLIERS (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("SUPP_ID"::varchar), '') as supp_id,
    nullif(trim("SUPP_TYPE"::varchar), '') as supp_type,
    nullif(trim("PART_ID"::varchar), '') as part_id,
    "EFF_DATE"::timestamp_ntz as eff_date,
    "EXP_DATE"::timestamp_ntz as exp_date,
    nullif(trim("SUPP_STATUS"::varchar), '') as supp_status,
    nullif(trim("CONTACT"::varchar), '') as contact,
    nullif(trim("COMMENTS"::varchar), '') as comments,
    nullif(trim("LOC_CODE"::varchar), '') as loc_code,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'CLM_SUPPLIERS') }}

)

select * from source
