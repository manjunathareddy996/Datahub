-- Staging model for source table BJAZ_HM_GMC_AHC (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("BEN_NAME"::varchar), '') as ben_name,
    nullif(trim("CONTACT_NO"::varchar), '') as contact_no,
    "DOA"::timestamp_ntz as doa,
    nullif(trim("EMAIL_ID"::varchar), '') as email_id,
    nullif(trim("EMP_ID"::varchar), '') as emp_id,
    nullif(trim("ID_CARD_NO"::varchar), '') as id_card_no,
    nullif(trim("PACKAGE_NAME"::varchar), '') as package_name,
    nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
    nullif(trim("TOTAL_AMT"::varchar), '') as total_amt
    from {{ source('health_raw', 'BJAZ_HM_GMC_AHC') }}

)

select * from source
