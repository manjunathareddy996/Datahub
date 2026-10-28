{{ config(materialized='view') }}

-- FOREIGN_KEY ROUND-TRIP DIAGNOSTIC (open item P6-FK-ROUNDTRIP, decision BD1).
--
-- 863 spine occurrences in this map join on FOREIGN_KEY as a DOCUMENT HANDLE. Whether
-- that handle round-trips 1:1 to the root business number is UNPROVEN:
-- 00_tables_index.json carries sample_data_available=false and an empty
-- sample_data_files map, so no probe could be run at build time.
--
-- max_business_numbers_per_handle > 1 FALSIFIES the assumption. Those keys would be
-- WRONG rather than empty, which nothing downstream can see.

    select 'clm_clmd' as destination_view, 'CLAIMNO' as business_column,
           count(distinct foreign_key) as distinct_handles,
           count(distinct claimno) as distinct_business_numbers,
           max(per_handle) as max_business_numbers_per_handle
    from (select foreign_key, claimno,
                 count(distinct claimno) over (partition by foreign_key) as per_handle
          from {{ ref('stg_mtv2__clm_clmd') }})
union all
    select 'clm_clmd' as destination_view, 'POLICYNO' as business_column,
           count(distinct foreign_key) as distinct_handles,
           count(distinct policyno) as distinct_business_numbers,
           max(per_handle) as max_business_numbers_per_handle
    from (select foreign_key, policyno,
                 count(distinct policyno) over (partition by foreign_key) as per_handle
          from {{ ref('stg_mtv2__clm_clmd') }})
union all
    select 'uwr_pol' as destination_view, 'POLICY_NUMBER' as business_column,
           count(distinct foreign_key) as distinct_handles,
           count(distinct policy_number) as distinct_business_numbers,
           max(per_handle) as max_business_numbers_per_handle
    from (select foreign_key, policy_number,
                 count(distinct policy_number) over (partition by foreign_key) as per_handle
          from {{ ref('stg_mtv2__uwr_pol') }})
