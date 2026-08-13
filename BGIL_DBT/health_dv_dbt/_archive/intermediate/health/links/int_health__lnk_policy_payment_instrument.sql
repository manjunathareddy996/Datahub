-- Intermediate harmonisation view for LNK_POLICY_PAYMENT_INSTRUMENT (Policy Payment Instrument).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        cheque_no as payment_instrument_bk,
        policy as policy_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where cheque_no is not null and policy is not null

    union all

    select distinct
        cheque_no as payment_instrument_bk,
        policy_no as policy_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where cheque_no is not null and policy_no is not null

)

select distinct payment_instrument_bk, policy_bk, record_source
from unioned
