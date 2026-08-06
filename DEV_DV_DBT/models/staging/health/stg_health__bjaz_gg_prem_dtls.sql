-- Staging model for source table BJAZ_GG_PREM_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("BA_LEAD_NO")), '') as ba_lead_no,
    nullif(trim(to_varchar("BDR_CODE")), '') as bdr_code,
    nullif(trim(to_varchar("CLIENT_ID")), '') as client_id,
    nullif(trim(to_varchar("CUSTOMER_ID")), '') as customer_id,
    nullif(trim("HEIGHT"::varchar), '') as height,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim(to_varchar("KGC_PROPOSAL_NUMBER")), '') as kgc_proposal_number,
    nullif(trim(to_varchar("MASTER_POLICY_NO")), '') as master_policy_no,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PREEXISTING_DISEASE"::varchar), '') as preexisting_disease,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim(to_varchar("SM_CODE")), '') as sm_code,
    nullif(trim(to_varchar("SUBIMD_ID")), '') as subimd_id,
    nullif(trim(to_varchar("S_ACCOUNT_NUMBER")), '') as s_account_number,
    nullif(trim(to_varchar("USER_ID")), '') as user_id,
    nullif(trim("WEIGHT"::varchar), '') as weight
    from {{ source('health_raw', 'BJAZ_GG_PREM_DTLS') }}

)

select * from source
