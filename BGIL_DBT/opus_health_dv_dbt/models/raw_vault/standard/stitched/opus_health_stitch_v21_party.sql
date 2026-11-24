-- CENTRAL VIEW v21_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_POLICY_HISTORY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_RISK_OBJECT_DOCUMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_HCP_PROD_8428_GPG_LOADER
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as DOCUMENT_BK,
        pd_premium_payer_id as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        md_gross_monthly_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1000 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 1: BA_HCP_PROD_8432_ECP_LOADER
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as DOCUMENT_BK,
        pd_premium_payer_id as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        md_gross_monthly_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 2: BA_HCP_PROD_8433_FHC_LOADER
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as DOCUMENT_BK,
        pd_premium_payer_id as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        md_gross_monthly_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 3: BA_HCP_PROD_8439_CLH_LOADER
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as DOCUMENT_BK,
        pd_premium_payer_id as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        md_gross_monthly_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 4: BJAZ_EC_MEM_DTLS_EXTN
    select
        partner_id as DISTRIBUTION_CHANNEL_BK,
        medical_report as DOCUMENT_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        member_no as RISK_OBJECT_BK,
        1 as __LNK_PARTY_CHANNEL,
        1 as __LNK_PARTY_DOCUMENT,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_DOCUMENT,
        1 as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_DOCUMENT,
        1 as __LNK_RISK_OBJECT_PARTY,
        gross_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        hlth_ins_pol_yrs as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where (coalesce(contract_id, medical_report, member_no, member_no, partner_id)) is not null

    union all

    -- branch 5: BJAZ_HCF_MEMBER_DTLS
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as DOCUMENT_BK,
        member_no as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        monthly_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (member_no) is not null

    union all

    -- branch 6: BJAZ_HM_MEMBER_DTLS
    select
        partner_id as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as DOCUMENT_BK,
        member_id as PARTY_BK,
        contract_id as POLICY_BK,
        product_code as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        1 as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        1 as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        1 as __LNK_POLICY_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        gross_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where (coalesce(contract_id, member_id, partner_id, product_code)) is not null

    union all

    -- branch 7: BJAZ_IHG_MEM_DTLS_EXTN
    select
        partner_id as DISTRIBUTION_CHANNEL_BK,
        medical_report as DOCUMENT_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        1 as __LNK_PARTY_CHANNEL,
        1 as __LNK_PARTY_DOCUMENT,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_DOCUMENT,
        1 as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        gross_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where (coalesce(contract_id, medical_report, member_no, partner_id)) is not null

    union all

    -- branch 8: BJAZ_SH_MEM_DTLS_EXTN
    select
        partner_id as DISTRIBUTION_CHANNEL_BK,
        medical_report as DOCUMENT_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        1 as __LNK_PARTY_CHANNEL,
        1 as __LNK_PARTY_DOCUMENT,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_DOCUMENT,
        1 as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        gross_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (coalesce(contract_id, medical_report, member_no, partner_id)) is not null

)

select
    DISTRIBUTION_CHANNEL_BK,
    DOCUMENT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    RISK_OBJECT_BK,
    __LNK_PARTY_CHANNEL,
    __LNK_PARTY_DOCUMENT,
    __LNK_POLICY_CHANNEL,
    __LNK_POLICY_DOCUMENT,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_RISK_OBJECT_DOCUMENT,
    __LNK_RISK_OBJECT_PARTY,
    first_value(PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    first_value(PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from merged
