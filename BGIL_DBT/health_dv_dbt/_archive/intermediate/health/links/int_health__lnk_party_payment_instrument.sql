-- Intermediate harmonisation view for LNK_PARTY_PAYMENT_INSTRUMENT (Party Payment Instrument).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        hospital_id as party_bk,
        cheque_no as payment_instrument_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where hospital_id is not null and cheque_no is not null

    union all

    select distinct
        part_id as party_bk,
        cheque_no as payment_instrument_bk,
        'BJAZ_HM_INVESTI_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_investi_payment') }}
    where part_id is not null and cheque_no is not null

    union all

    select distinct
        customer_id as party_bk,
        cheque_no as payment_instrument_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where customer_id is not null and cheque_no is not null

)

select distinct party_bk, payment_instrument_bk, record_source
from unioned
