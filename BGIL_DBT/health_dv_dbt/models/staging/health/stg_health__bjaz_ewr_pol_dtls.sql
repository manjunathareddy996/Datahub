-- Staging model for source table BJAZ_EWR_POL_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim(to_varchar("BUSINESS_SOURCE")), '') as business_source,
    nullif(trim(to_varchar("COMPANY_ORG_UNIT")), '') as company_org_unit,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("DEPARTMENT_CODE")), '') as department_code,
    nullif(trim(to_varchar("DEPT_CODE")), '') as dept_code,
    nullif(trim(to_varchar("EMP_CODE")), '') as emp_code,
    nullif(trim(to_varchar("MAIN_AGENT_CODE")), '') as main_agent_code,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim(to_varchar("PRODUCT_4DIGIT_CODE")), '') as product_4digit_code,
    nullif(trim(to_varchar("PROSPECT_ID")), '') as prospect_id,
    nullif(trim(to_varchar("QUOTE_REF_NO")), '') as quote_ref_no,
    nullif(trim(to_varchar("RM_CODE")), '') as rm_code
    from {{ source('health_raw', 'BJAZ_EWR_POL_DTLS') }}

)

select * from source
