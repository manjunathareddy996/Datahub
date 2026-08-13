-- Intermediate harmonisation view for HUB_FINANCIAL_TRANSACTION.
-- Unions the HUB_FINANCIAL_TRANSACTION business key from every Health source table/column carrying it. (2 of 3 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_financial_transaction.sql.

with unioned as (

    select distinct
        ptransaction_id as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where ptransaction_id is not null

    union all

    -- CONFIRMED
    select distinct
        claim_no || '|' || utr_no as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where claim_no is not null and utr_no is not null

    union all

    -- CONFIRMED
    select distinct
        tpa_trans_key as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where tpa_trans_key is not null

)

select distinct business_key, record_source
from unioned
