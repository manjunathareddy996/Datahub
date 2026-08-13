-- Staging model for source table BA_HCP_PRIME_RIDER_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("BASE_CONTRACT_ID")), '') as base_contract_id,
    nullif(trim(to_varchar("BASE_POLICY_REF")), '') as base_policy_ref,
    "CGST_AMT"::number as cgst_amt,
    "FINAL_PREMIUM"::number as final_premium,
    nullif(trim(to_varchar("HAN_NUMBER")), '') as han_number,
    "IGST_AMT"::number as igst_amt,
    nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
    "PLAN_PREMIUM"::number as plan_premium,
    "POLICY_PERIOD"::number as policy_period,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    "SGST_AMT"::number as sgst_amt,
    "TOTAL_FINAL_PREMIUM"::number as total_final_premium,
    "TOTAL_NET_PREMIUM"::number as total_net_premium
    from {{ source('health_raw', 'BA_HCP_PRIME_RIDER_DTLS') }}

)

select * from source
