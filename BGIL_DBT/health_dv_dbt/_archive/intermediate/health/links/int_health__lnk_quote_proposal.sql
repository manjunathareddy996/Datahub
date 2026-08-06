-- Intermediate harmonisation view for LNK_QUOTE_PROPOSAL (Quote to Proposal).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        quote_ref_no as proposal_bk,
        quote_sub_no as quote_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where quote_ref_no is not null and quote_sub_no is not null

    union all

    select distinct
        quote_ref_no as proposal_bk,
        quote_ref_no as quote_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where quote_ref_no is not null and quote_ref_no is not null

)

select distinct proposal_bk, quote_bk, record_source
from unioned
