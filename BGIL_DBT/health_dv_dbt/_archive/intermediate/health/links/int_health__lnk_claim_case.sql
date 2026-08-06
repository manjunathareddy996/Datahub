-- Intermediate harmonisation view for LNK_CLAIM_CASE (Claim Case).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        allocate_id as case_bk,
        claim_id as claim_bk,
        'BJAZ_HM_INWARD_AUTOALLOCATION' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
    where allocate_id is not null and claim_id is not null

    union all

    select distinct
        enhance_ref_id as case_bk,
        clid as claim_bk,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where enhance_ref_id is not null and clid is not null

    union all

    select distinct
        query_ref_id as case_bk,
        clid as claim_bk,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where query_ref_id is not null and clid is not null

)

select distinct case_bk, claim_bk, record_source
from unioned
