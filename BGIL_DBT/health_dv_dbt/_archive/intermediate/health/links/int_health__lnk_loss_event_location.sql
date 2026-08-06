-- Intermediate harmonisation view for LNK_LOSS_EVENT_LOCATION (Loss Event Location).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        policy_location as location_bk,
        claim_no as loss_event_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy_location is not null and claim_no is not null

    union all

    select distinct
        location_code as location_bk,
        claim_id as loss_event_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where location_code is not null and claim_id is not null

)

select distinct location_bk, loss_event_bk, record_source
from unioned
