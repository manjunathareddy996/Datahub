-- Staging model for source table BJAZ_STARPKG_FF_DTLS (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "VERSION_NO"::number as version_no,
    "OBJECT_ID"::number as object_id,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    "SECTION_CODE"::number as section_code,
    "SR_NO"::number as sr_no,
    nullif(trim("RELATION"::varchar), '') as relation,
    "RATE"::number as rate,
    "RATE_FACTOR"::number as rate_factor,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("PRE_EXIST_DISEASE"::varchar), '') as pre_exist_disease,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("PASSPORTNO"::varchar), '') as passportno,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    "FULL_PREMIUM"::number as full_premium,
    nullif(trim("YESNO"::varchar), '') as yesno,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    "DOB"::timestamp_ntz as dob,
    nullif(trim("SP_CONDITIONS"::varchar), '') as sp_conditions,
    nullif(trim("CI_YN"::varchar), '') as ci_yn,
    "CI_LOADING_PER"::number as ci_loading_per,
    "FF_PREMIUM"::number as ff_premium,
    nullif(trim("HC_YN"::varchar), '') as hc_yn,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    "AGE"::number as age,
    nullif(trim("DEL_FLAG"::varchar), '') as del_flag,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date
    from {{ source('partner_raw', 'BJAZ_STARPKG_FF_DTLS') }}

)

select * from source
