-- Intermediate harmonisation view for LNK_FINTXN_INSTRUMENT (Financial Txn Instrument).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        claim_no || '|' || utr_no as financial_transaction_bk,
        cheque_no as payment_instrument_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where claim_no is not null and utr_no is not null and cheque_no is not null

    union all

    select distinct
        tpa_trans_key as financial_transaction_bk,
        cheque_no as payment_instrument_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where tpa_trans_key is not null and cheque_no is not null

)

select distinct financial_transaction_bk, payment_instrument_bk, record_source
from unioned
