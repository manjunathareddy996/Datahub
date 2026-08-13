-- Intermediate harmonisation view for HUB_FINANCIAL_ACCOUNT.
-- Unions the HUB_FINANCIAL_ACCOUNT business key from every Health source table/column carrying it. (6 of 18 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_financial_account.sql.

with unioned as (

    select distinct
        mlac_emi_pc_loan_account_no as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where mlac_emi_pc_loan_account_no is not null

    union all

    select distinct
        pd_bank_ref_no1_lac_sac as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_bank_ref_no1_lac_sac is not null

    union all

    select distinct
        pd_bank_ref_no1_lac_sac as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_bank_ref_no1_lac_sac is not null

    union all

    select distinct
        pd_bank_ref_no1_lac_sac as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_bank_ref_no1_lac_sac is not null

    union all

    select distinct
        plc_loan_acc_no as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where plc_loan_acc_no is not null

    union all

    select distinct
        pd_bank_ref_no1_lac_sac as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_bank_ref_no1_lac_sac is not null

    union all

    select distinct
        lms_no as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where lms_no is not null

    union all

    select distinct
        s_account_number as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where s_account_number is not null

    union all

    select distinct
        s_account_number as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where s_account_number is not null

    union all

    select distinct
        loan_accno as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where loan_accno is not null

    union all

    select distinct
        bank_ac_no as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where bank_ac_no is not null

    union all

    select distinct
        bank_ac_no as business_key,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where bank_ac_no is not null

    union all

    -- DISCOVERED
    select distinct
        s_account_number as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where s_account_number is not null

    union all

    -- DISCOVERED
    select distinct
        s_account_number as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where s_account_number is not null

    union all

    -- DISCOVERED
    select distinct
        s_account_number as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where s_account_number is not null

    union all

    -- DISCOVERED
    select distinct
        s_account_number as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where s_account_number is not null

    union all

    -- DISCOVERED
    select distinct
        s_account_number as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where s_account_number is not null

    union all

    -- DISCOVERED
    select distinct
        s_account_number as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where s_account_number is not null

)

select distinct business_key, record_source
from unioned
