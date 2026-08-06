-- Intermediate harmonisation view for HUB_PROPOSAL.
-- Unions the HUB_PROPOSAL business key from every Health source table/column carrying it. (14 of 19 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_proposal.sql.

with unioned as (

    select distinct
        hi_control_number as business_key,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where hi_control_number is not null

    union all

    select distinct
        reference_id as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where reference_id is not null

    union all

    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where kgc_proposal_number is not null

    union all

    -- CONFIRMED
    select distinct
        quote_ref_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where quote_ref_no is not null

    union all

    select distinct
        ba_lead_no as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where ba_lead_no is not null

    union all

    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where kgc_proposal_number is not null

    union all

    -- CONFIRMED
    select distinct
        quote_ref_no as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where quote_ref_no is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where kgc_proposal_number is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where kgc_proposal_number is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where kgc_proposal_number is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where kgc_proposal_number is not null

    union all

    -- DISCOVERED
    select distinct
        ba_lead_no as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where ba_lead_no is not null

    union all

    -- DISCOVERED
    select distinct
        kgc_proposal_number as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where kgc_proposal_number is not null

)

select distinct business_key, record_source
from unioned
