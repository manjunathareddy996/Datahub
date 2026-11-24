-- CENTRAL VIEW v17_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_PORTABILITY_MIGRATION
--   SAT_LNK_ROLE_EMPLOYEE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_CESSION
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_TREATY_PARTY
--   LNK_TREATY_PRODUCT
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_HM_MEMBER_HLTH_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        first_policy_ref as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        prev_policy_dtls as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 1: BA_HCP_PORT_WORDINGS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        partner_id as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        1 as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        port_reason as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        prev_policy_exp_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_port_wordings') }}
    where (coalesce(contract_id, partner_id)) is not null

    union all

    -- branch 2: BA_HCP_PROD_8439_CLH_LOADER
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        md_first_policy_inception_date as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        md_prev_expiry_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 3: BJAZ_EC_MEM_DTLS_EXTN
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        first_policy_ref as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        con_deductable as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        coalesce(con_exp_date, perv_pol_exp_date) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 4: BJAZ_GPG_POL_DTLS
    select
        scrutiny_no as ASSESSMENT_BK,
        imd_code as DISTRIBUTION_CHANNEL_BK,
        company_org_unit as ORG_UNIT_BK,
        bagic_e_code as PARTY_BK,
        reference_id as POLICY_BK,
        product_code as PRODUCT_BK,
        re_insu as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        1 as __LNK_ASSESSMENT_PARTY,
        1 as __LNK_CHANNEL_ORG_UNIT,
        1 as __LNK_PARTY_CHANNEL,
        1 as __LNK_PARTY_ORG_UNIT,
        1 as __LNK_POLICY_CESSION,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_TREATY_PARTY,
        1 as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        prev_policy_branch_address as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        prev_policy_expiry as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where (coalesce(bagic_e_code, company_org_unit, imd_code, product_code, re_insu, reference_id, scrutiny_no)) is not null

    union all

    -- branch 5: BJAZ_GPG_POL_DTLS | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        bagic_e_code as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        coalesce(bagic_e_code, bagic_rm_e_code) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where (bagic_e_code) is not null

    union all

    -- branch 6: BJAZ_HCF_MEMBER_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        prev_policy_since as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 7: BJAZ_HG_POL_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        perv_pol_exp_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 8: BJAZ_HLT_ENSURE_MEM_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        partner_id as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        1 as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        1 as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        first_pol_inception_date as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        first_policy_number as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        previous_cum_amount as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        previous_to_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        previous_from_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where (coalesce(contract_id, member_no, partner_id)) is not null

    union all

    -- branch 9: BJAZ_SH_MEM_DTLS_EXTN
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        first_policy_ref as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 10: BJAZ_GMC_BASES_EXTN
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        first_policy_ref as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        2009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gmc_bases_extn') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 11: BJAZ_POLICY_BASES_EXTN
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as REINSURANCE_TREATY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CESSION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_TREATY_PARTY,
        cast(null as number) as __LNK_TREATY_PRODUCT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
        prev_policy_expiry_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        2010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_policy_bases_extn') }}
    where (nullif(trim(contract_id),'')) is not null

)

select
    ASSESSMENT_BK,
    DISTRIBUTION_CHANNEL_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    REINSURANCE_TREATY_BK,
    ROLE_TYPE_CODE,
    __LNK_ASSESSMENT_PARTY,
    __LNK_CHANNEL_ORG_UNIT,
    __LNK_PARTY_CHANNEL,
    __LNK_PARTY_ORG_UNIT,
    __LNK_POLICY_CESSION,
    __LNK_POLICY_CHANNEL,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_TREATY_PARTY,
    __LNK_TREATY_PRODUCT,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_ORIGINAL_POLICY_REFERENCE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_INCEPTION_DATE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_NUMBER,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__FIRST_POLICY_REFERENCE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__ORIGINATING_POLICY_NUMBER,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PORTABILITY_REASON,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PORTED_CUMULATIVE_BONUS_AMOUNT,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_BRANCH_ADDRESS,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DEDUCTIBLE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_DETAIL,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_INCEPTION_DATE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
    LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
    first_value(LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE
from merged
