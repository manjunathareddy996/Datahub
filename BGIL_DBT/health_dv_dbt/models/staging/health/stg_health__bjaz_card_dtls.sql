-- Staging model for source table BJAZ_CARD_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    "CARD_EXPIRY"::timestamp_ntz as card_expiry,
    nullif(trim(to_varchar("CARD_NO")), '') as card_no,
    nullif(trim("CARD_STATUS"::varchar), '') as card_status,
    nullif(trim("CARD_TYPE"::varchar), '') as card_type,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "DATE_OF_JOINING"::timestamp_ntz as date_of_joining,
    "DOB"::timestamp_ntz as dob,
    "EFF_DATE"::timestamp_ntz as eff_date,
    nullif(trim("EMP_NO"::varchar), '') as emp_no,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    nullif(trim("FLOATER_OR_NOT"::varchar), '') as floater_or_not,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("MEMBER_TYPE"::varchar), '') as member_type,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("POLICY_TYPE"::varchar), '') as policy_type,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("RELATION_DESC"::varchar), '') as relation_desc,
    nullif(trim("STATUS"::varchar), '') as status,
    "SUM_INSURED"::number as sum_insured
    from {{ source('health_raw', 'BJAZ_CARD_DTLS') }}

)

select * from source
