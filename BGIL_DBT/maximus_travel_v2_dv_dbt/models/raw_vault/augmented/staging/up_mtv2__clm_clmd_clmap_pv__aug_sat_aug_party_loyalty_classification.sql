{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_PARTY_LOYALTY_CLASSIFICATION from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- 3 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'NOMENCLATURE' as LOYALTY_CLASSIFICATION_TYPE,
        loyality_bucket_by_nomenclature as LOYALTY_BUCKET,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where loyality_bucket_by_nomenclature is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'SEVERITY' as LOYALTY_CLASSIFICATION_TYPE,
        loyality_bucket_by_severity as LOYALTY_BUCKET,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where loyality_bucket_by_severity is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'SEVERITY_FINAL' as LOYALTY_CLASSIFICATION_TYPE,
        loyaltyseverityfinal as LOYALTY_BUCKET,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where loyaltyseverityfinal is not null
