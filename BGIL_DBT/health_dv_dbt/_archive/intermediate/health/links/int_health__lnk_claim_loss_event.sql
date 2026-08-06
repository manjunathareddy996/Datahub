-- Intermediate harmonisation view for LNK_CLAIM_LOSS_EVENT (Claim Loss Event).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        clid as claim_bk,
        claim_no as loss_event_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null and claim_no is not null

    union all

    select distinct
        claim_id as claim_bk,
        claim_id as loss_event_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null and claim_id is not null

    union all

    select distinct
        bjaz_claim_id as claim_bk,
        tpa_claim_no as loss_event_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where bjaz_claim_id is not null and tpa_claim_no is not null

)

select distinct claim_bk, loss_event_bk, record_source
from unioned
