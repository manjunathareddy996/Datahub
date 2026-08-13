-- Intermediate harmonisation view for LNK_FINTXN_POLICY (Financial Txn Policy).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        ptransaction_id as financial_transaction_bk,
        policy_ref as policy_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where ptransaction_id is not null and policy_ref is not null

    union all

    select distinct
        claim_no || '|' || utr_no as financial_transaction_bk,
        policy as policy_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where claim_no is not null and utr_no is not null and policy is not null

    union all

    select distinct
        tpa_trans_key as financial_transaction_bk,
        policy_no as policy_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where tpa_trans_key is not null and policy_no is not null

)

select distinct financial_transaction_bk, policy_bk, record_source
from unioned
