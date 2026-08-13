-- Staging model for source table BJAZ_HDFC_SEC_FHPP (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("AGE"::varchar), '') as age,
    nullif(trim(to_varchar("BA_LEAD_NO")), '') as ba_lead_no,
    nullif(trim(to_varchar("CLIENT_ID")), '') as client_id,
    nullif(trim(to_varchar("CUSTOMER_ID")), '') as customer_id,
    nullif(trim("CUSTOMER_NAME"::varchar), '') as customer_name,
    nullif(trim("CUSTOMER_TYPE"::varchar), '') as customer_type,
    "DOB"::timestamp_ntz as dob,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("GROSS_PREMIUM"::varchar), '') as gross_premium,
    nullif(trim("HEIGHT"::varchar), '') as height,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim(to_varchar("KGC_PROPOSAL_NUMBER")), '') as kgc_proposal_number,
    nullif(trim(to_varchar("MASTER_POLICY_NO")), '') as master_policy_no,
    nullif(trim("NOMINEE_RELATION"::varchar), '') as nominee_relation,
    nullif(trim("NO_OF_DAYS"::varchar), '') as no_of_days,
    nullif(trim("NO_OF_YEARS"::varchar), '') as no_of_years,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PREEXISTING_DISEASE"::varchar), '') as preexisting_disease,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("REFERENCE_ID")), '') as reference_id,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim(to_varchar("SM_CODE")), '') as sm_code,
    nullif(trim("SOURCE_NAME"::varchar), '') as source_name,
    nullif(trim(to_varchar("SUBIMD_ID")), '') as subimd_id,
    nullif(trim("SUM_INSURED"::varchar), '') as sum_insured,
    nullif(trim(to_varchar("S_ACCOUNT_NUMBER")), '') as s_account_number,
    "TERM_END_DATE"::timestamp_ntz as term_end_date,
    "TERM_START_DATE"::timestamp_ntz as term_start_date,
    nullif(trim("WEIGHT"::varchar), '') as weight
    from {{ source('health_raw', 'BJAZ_HDFC_SEC_FHPP') }}

)

select * from source
