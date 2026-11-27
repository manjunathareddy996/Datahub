-- Staging model for source table CLM_BASES (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.
-- CLAIM_ID is cast to VARCHAR to match claim_id in stg_partner__clm_interested_parties.
-- DMS CDC metadata (DMS_*, OP) and INC_JOB_* audit columns are not carried, except INC_JOB_UPDATED_AT.
with source as (
    select
    nullif(trim("CLAIM_ID"::varchar), '') as claim_id,
    nullif(trim("CLM_REF"::varchar), '') as clm_ref,
    nullif(trim("EXT_CLM_REF"::varchar), '') as ext_clm_ref,
    "CLM_LINE_ID"::number as clm_line_id,
    "INC_ID"::number as inc_id,
    "CAT_ID"::number as cat_id,
    "OCCURENCE_SEQ"::number as occurence_seq,
    "ACCT_YEAR"::number as acct_year,
    nullif(trim("LOC_CODE"::varchar), '') as loc_code,
    nullif(trim("COL_CODE"::varchar), '') as col_code,
    nullif(trim("CHARGEABLE_CODE"::varchar), '') as chargeable_code,
    nullif(trim("SWIFT_CODE"::varchar), '') as swift_code,
    nullif(trim("CLM_STATUS"::varchar), '') as clm_status,
    nullif(trim("MANUAL_CLAIM"::varchar), '') as manual_claim,
    nullif(trim("LUA_VALUE_1"::varchar), '') as lua_value_1,
    nullif(trim("LUA_VALUE_2"::varchar), '') as lua_value_2,
    nullif(trim("LUA_VALUE_3"::varchar), '') as lua_value_3,
    "DATE_OF_LOSS"::timestamp_ntz as date_of_loss,
    "DATE_REPORTED"::timestamp_ntz as date_reported,
    "LAST_UPDATED_DATE"::timestamp_ntz as last_updated_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'CLM_BASES') }}
)
select * from source
