-- Staging model for source table BJAZ_CTNGY_GC_MEM_DATA (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("MASTER_POLICY_REF"::varchar), '') as master_policy_ref,
    nullif(trim("PLAN_NAME"::varchar), '') as plan_name,
    nullif(trim("POLICY_REF"::varchar), '') as policy_ref,
    "POLICY_ISSUE_DATE"::timestamp_ntz as policy_issue_date,
    "RISK_INCEPTION_DATE"::timestamp_ntz as risk_inception_date,
    "RISK_EXPIRY_DATE"::timestamp_ntz as risk_expiry_date,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("GENDER"::varchar), '') as gender,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "AGE"::number as age,
    nullif(trim("RELATION"::varchar), '') as relation,
    "SUM_INSURED"::number as sum_insured,
    nullif(trim("EXTRA_COL1"::varchar), '') as extra_col1,
    nullif(trim("EXTRA_COL2"::varchar), '') as extra_col2,
    nullif(trim("INSURED_ADDRESS"::varchar), '') as insured_address,
    nullif(trim("TELEPHONE"::varchar), '') as telephone,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("INFOVIEW_FLAG"::varchar), '') as infoview_flag,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date
    from {{ source('partner_raw', 'BJAZ_CTNGY_GC_MEM_DATA') }}

)

select * from source
