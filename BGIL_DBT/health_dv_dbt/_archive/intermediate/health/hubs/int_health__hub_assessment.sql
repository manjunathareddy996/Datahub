-- Intermediate harmonisation view for HUB_ASSESSMENT.
-- Unions the HUB_ASSESSMENT business key from every Health source table/column carrying it. (5 of 25 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_assessment.sql.

with unioned as (

    select distinct
        scrutiny_no as business_key,
        'BA_HCP_PORT_WORDINGS' as record_source
    from {{ ref('stg_health__ba_hcp_port_wordings') }}
    where scrutiny_no is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where scrutiny_no is not null

    union all

    select distinct
        pd_scrutiny_number as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_scrutiny_number is not null

    union all

    select distinct
        pd_scrutiny_number as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_scrutiny_number is not null

    union all

    select distinct
        pd_scrutiny_number as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_scrutiny_number is not null

    union all

    select distinct
        pd_scrutiny_number as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_scrutiny_number is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where scrutiny_no is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where scrutiny_no is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where scrutiny_no is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where scrutiny_no is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_HCP_TRANSCRIPT_URL' as record_source
    from {{ ref('stg_health__bjaz_hcp_transcript_url') }}
    where scrutiny_no is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where scrutiny_no is not null

    union all

    select distinct
        docasess_id as business_key,
        'BJAZ_HM_DOCTOR_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_assess') }}
    where docasess_id is not null

    union all

    select distinct
        docasess_id as business_key,
        'BJAZ_HM_DOCTOR_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
    where docasess_id is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_HM_HAT_ITRACK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_hat_itrack_dtls') }}
    where scrutiny_no is not null

    union all

    select distinct
        docasess_id as business_key,
        'BJAZ_HM_PCS_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
    where docasess_id is not null

    union all

    select distinct
        pcs_id as business_key,
        'BJAZ_HM_PCS_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
    where pcs_id is not null

    union all

    select distinct
        pcs_sno as business_key,
        'BJAZ_HM_PCS_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
    where pcs_sno is not null

    union all

    select distinct
        assess_id as business_key,
        'BJAZ_HM_PRO_ASSESSMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where assess_id is not null

    union all

    select distinct
        scrutiny_no as business_key,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where scrutiny_no is not null

    union all

    -- DISCOVERED
    select distinct
        scrutiny_no as business_key,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where scrutiny_no is not null

    union all

    -- DISCOVERED
    select distinct
        pcs_id as business_key,
        'BJAZ_HM_PCS_DES_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_des_master') }}
    where pcs_id is not null

    union all

    -- DISCOVERED
    select distinct
        pcs_id as business_key,
        'BJAZ_HM_PCS_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_master') }}
    where pcs_id is not null

    union all

    -- DISCOVERED
    select distinct
        scrutiny_no as business_key,
        'BJAZ_SCRUTINY_IP_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scrutiny_ip_dtls') }}
    where scrutiny_no is not null

    union all

    -- DISCOVERED
    select distinct
        scrutiny_no as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where scrutiny_no is not null

)

select distinct business_key, record_source
from unioned
