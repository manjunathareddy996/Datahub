-- Intermediate harmonisation view for HUB_PAYMENT_INSTRUMENT.
-- Unions the HUB_PAYMENT_INSTRUMENT business key from every Health source table/column carrying it. (2 of 4 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_payment_instrument.sql.

with unioned as (

    select distinct
        cheque_no as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where cheque_no is not null

    union all

    -- CONFIRMED
    select distinct
        utr_no as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where utr_no is not null

    union all

    -- DISCOVERED
    select distinct
        cheque_no as business_key,
        'BJAZ_HM_INVESTI_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_investi_payment') }}
    where cheque_no is not null

    union all

    select distinct
        cheque_no as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where cheque_no is not null

)

select distinct business_key, record_source
from unioned
