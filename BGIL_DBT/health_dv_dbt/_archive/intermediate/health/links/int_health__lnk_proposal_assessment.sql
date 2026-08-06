-- Intermediate harmonisation view for LNK_PROPOSAL_ASSESSMENT (Proposal Assessment).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        scrutiny_no as assessment_bk,
        hi_control_number as proposal_bk,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where scrutiny_no is not null and hi_control_number is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        quote_ref_no as proposal_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where scrutiny_no is not null and quote_ref_no is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        ba_lead_no as proposal_bk,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where scrutiny_no is not null and ba_lead_no is not null

)

select distinct assessment_bk, proposal_bk, record_source
from unioned
