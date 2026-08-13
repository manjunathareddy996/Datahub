-- Intermediate harmonisation view for LNK_PROPOSAL_POLICY (Proposal to Policy).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        contract_id as policy_bk,
        hi_control_number as proposal_bk,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where contract_id is not null and hi_control_number is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        kgc_proposal_number as proposal_bk,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where master_policy_no is not null and kgc_proposal_number is not null

    union all

    select distinct
        reg_no as policy_bk,
        quote_ref_no as proposal_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null and quote_ref_no is not null

    union all

    select distinct
        reference_id as policy_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where reference_id is not null and ba_lead_no is not null

    union all

    select distinct
        contract_id as policy_bk,
        quote_ref_no as proposal_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where contract_id is not null and quote_ref_no is not null

    union all

    select distinct
        policy_ref as policy_bk,
        ba_lead_no as proposal_bk,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where policy_ref is not null and ba_lead_no is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where master_policy_no is not null and ba_lead_no is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where master_policy_no is not null and ba_lead_no is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where master_policy_no is not null and ba_lead_no is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where master_policy_no is not null and ba_lead_no is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        ba_lead_no as proposal_bk,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where master_policy_no is not null and ba_lead_no is not null

)

select distinct policy_bk, proposal_bk, record_source
from unioned
