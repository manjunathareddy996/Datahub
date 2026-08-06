-- Intermediate harmonisation view for LNK_FINTXN_CLAIM (Financial Txn Claim).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        clid as claim_bk,
        claim_no || '|' || utr_no as financial_transaction_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null and claim_no is not null and utr_no is not null

    union all

    select distinct
        bjaz_claim_id as claim_bk,
        tpa_trans_key as financial_transaction_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where bjaz_claim_id is not null and tpa_trans_key is not null

)

select distinct claim_bk, financial_transaction_bk, record_source
from unioned
