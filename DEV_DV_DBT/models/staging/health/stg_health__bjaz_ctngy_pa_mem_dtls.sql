-- Staging model for source table BJAZ_CTNGY_PA_MEM_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDITONAL_COVERAGES"::varchar), '') as additonal_coverages,
    "AGE"::number as age,
    nullif(trim("ASSIGNEE_RELATION"::varchar), '') as assignee_relation,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("EXLCUSIONS"::varchar), '') as exlcusions,
    nullif(trim("FAMILY_FLAGGING"::varchar), '') as family_flagging,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim(to_varchar("MEMBER_REF_NUMBER")), '') as member_ref_number,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    "PM_POL_ENROLMENT_DATE"::timestamp_ntz as pm_pol_enrolment_date,
    nullif(trim("PRE_EXIST_DISEASE"::varchar), '') as pre_exist_disease,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code
    from {{ source('health_raw', 'BJAZ_CTNGY_PA_MEM_DTLS') }}

)

select * from source
