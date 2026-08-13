-- Intermediate harmonisation view for LNK_PROPOSAL_PRODUCT (Proposal Product).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        product_code as product_bk,
        kgc_proposal_number as proposal_bk,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where product_code is not null and kgc_proposal_number is not null

    union all

    select distinct
        product as product_bk,
        quote_ref_no as proposal_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where product is not null and quote_ref_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where product_code is not null and ba_lead_no is not null

    union all

    select distinct
        product_4digit_code as product_bk,
        quote_ref_no as proposal_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where product_4digit_code is not null and quote_ref_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where product_code is not null and ba_lead_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where product_code is not null and ba_lead_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where product_code is not null and ba_lead_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where product_code is not null and ba_lead_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where product_code is not null and ba_lead_no is not null

    union all

    select distinct
        product_code as product_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where product_code is not null and ba_lead_no is not null

)

select distinct product_bk, proposal_bk, record_source
from unioned
