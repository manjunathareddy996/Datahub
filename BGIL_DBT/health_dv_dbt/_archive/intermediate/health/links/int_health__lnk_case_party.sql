-- Intermediate harmonisation view for LNK_CASE_PARTY (Case Party).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        enhance_ref_id as case_bk,
        hosp_id as party_bk,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where enhance_ref_id is not null and hosp_id is not null

    union all

    select distinct
        query_ref_id as case_bk,
        hosp_id as party_bk,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where query_ref_id is not null and hosp_id is not null

    union all

    select distinct
        request_no as case_bk,
        member_identifier as party_bk,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where request_no is not null and member_identifier is not null

)

select distinct case_bk, party_bk, record_source
from unioned
