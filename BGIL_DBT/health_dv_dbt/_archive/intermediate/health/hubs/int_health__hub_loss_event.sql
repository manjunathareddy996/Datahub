-- Intermediate harmonisation view for HUB_LOSS_EVENT.
-- Unions the HUB_LOSS_EVENT business key from every Health source table/column carrying it. (3 of 3 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_loss_event.sql.

with unioned as (

    -- CONFIRMED
    select distinct
        claim_no as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where claim_no is not null

    union all

    -- CONFIRMED
    select distinct
        claim_id as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null

    union all

    -- CONFIRMED
    select distinct
        tpa_claim_no as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where tpa_claim_no is not null

)

select distinct business_key, record_source
from unioned
