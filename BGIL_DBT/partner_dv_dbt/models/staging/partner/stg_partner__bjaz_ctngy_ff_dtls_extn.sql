-- Staging model for source table BJAZ_CTNGY_FF_DTLS_EXTN (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("PASSPORTNO"::varchar), '') as passportno,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    "PREMIUM"::number as premium,
    nullif(trim("YESNO"::varchar), '') as yesno,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PRE_EXIST_DISEASE"::varchar), '') as pre_exist_disease,
    "TRACKED_DATE"::timestamp_ntz as tracked_date,
    nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
    "SCHEME_VERSION"::number as scheme_version,
    "SECTION_CODE"::number as section_code,
    "SR_NO"::number as sr_no,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("NOMINEE_RELATION"::varchar), '') as nominee_relation,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    "VERSION_NO"::number as version_no,
    "OBJECT_ID"::number as object_id,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "RATE"::number as rate,
    "RATE_FACTOR"::number as rate_factor,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    "DOB"::timestamp_ntz as dob
    from {{ source('partner_raw', 'BJAZ_CTNGY_FF_DTLS_EXTN') }}

)

select * from source
