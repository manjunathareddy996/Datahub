-- Staging for source table BA_HCP_PRIME_RIDER_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("BASE_CONTRACT_ID")), '') as base_contract_id,
        nullif(trim(to_varchar("BASE_POLICY_REF")), '') as base_policy_ref,
        nullif(trim(to_varchar("CGST_AMT")), '') as cgst_amt,
        nullif(trim(to_varchar("FINAL_PREMIUM")), '') as final_premium,
        nullif(trim(to_varchar("HAN_NUMBER")), '') as han_number,
        nullif(trim(to_varchar("IGST_AMT")), '') as igst_amt,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
        nullif(trim(to_varchar("PLAN_PREMIUM")), '') as plan_premium,
        nullif(trim(to_varchar("POLICY_PERIOD")), '') as policy_period,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("SGST_AMT")), '') as sgst_amt,
        nullif(trim(to_varchar("TOTAL_FINAL_PREMIUM")), '') as total_final_premium,
        nullif(trim(to_varchar("TOTAL_NET_PREMIUM")), '') as total_net_premium,
        nullif(trim(to_varchar("UTGST_AMT")), '') as utgst_amt
    from {{ source('health_raw', 'BA_HCP_PRIME_RIDER_DTLS') }}

)

select * from source
