-- Staging model for source table OCP_INTERESTED_PARTIES (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    "OBJECT_ID"::number as object_id,
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("CUSTOMER_NAME_TEXT"::varchar), '') as customer_name_text,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    nullif(trim(to_varchar("MAILING_ADDRESS_ID")), '') as mailing_address_id,
    "IP_NO"::number as ip_no,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "VERSION_NO"::number as version_no,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'OCP_INTERESTED_PARTIES') }}

)

select * from source
