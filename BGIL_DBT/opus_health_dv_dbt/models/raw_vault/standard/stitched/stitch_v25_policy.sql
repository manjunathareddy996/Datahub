{{ config(materialized='view') }}
-- CENTRAL VIEW v25_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_COVER_DTLS (opus_health_delta3)
--   OCP_POLICY_COVERS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_COVERAGE_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_aug_policy_coverage_schedule, stitch_policy_coverage_schedule, stitch_lk_policy_coverage__v25, stitch_lk_policy_party__v25

select
    cast(null as varchar) as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    aug_policy_coverage_schedule__coverage_reference_ck as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    aug_policy_coverage_schedule__coverage_sequence_ck as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    aug_policy_coverage_schedule__agent_commission_company_share_amount as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_AMOUNT,
    aug_policy_coverage_schedule__agent_commission_company_share_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_CURRENCY_CODE,
    aug_policy_coverage_schedule__agent_commission_whole_cover_amount as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_AMOUNT,
    aug_policy_coverage_schedule__agent_commission_whole_cover_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_CURRENCY_CODE,
    aug_policy_coverage_schedule__cover_variant_classification_code as AUG_POLICY_COVERAGE_SCHEDULE__COVER_VARIANT_CLASSIFICATION_CODE,
    aug_policy_coverage_schedule__co_insurance_share_portion as AUG_POLICY_COVERAGE_SCHEDULE__CO_INSURANCE_SHARE_PORTION,
    aug_policy_coverage_schedule__full_term_premium_original_company_share as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE,
    aug_policy_coverage_schedule__full_term_premium_original_company_share_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE_CURRENCY_CODE,
    aug_policy_coverage_schedule__full_term_premium_original_whole_cover as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER,
    aug_policy_coverage_schedule__full_term_premium_original_whole_cover_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER_CURRENCY_CODE,
    aug_policy_coverage_schedule__full_term_premium_system_company_share as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE,
    aug_policy_coverage_schedule__full_term_premium_system_company_share_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE_CURRENCY_CODE,
    aug_policy_coverage_schedule__full_term_premium_system_whole_cover_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_WHOLE_COVER_CURRENCY_CODE,
    aug_policy_coverage_schedule__parent_coverage_contract_reference as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_CONTRACT_REFERENCE,
    aug_policy_coverage_schedule__parent_coverage_partition_number as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_PARTITION_NUMBER,
    aug_policy_coverage_schedule__parent_coverage_reference as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_REFERENCE,
    aug_policy_coverage_schedule__parent_coverage_sequence as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_SEQUENCE,
    aug_policy_coverage_schedule__plan_reference as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
    aug_policy_coverage_schedule__reinsurable_risk_amount as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT,
    aug_policy_coverage_schedule__reinsurable_risk_amount_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT_CURRENCY_CODE,
    aug_policy_coverage_schedule__section_reference as AUG_POLICY_COVERAGE_SCHEDULE__SECTION_REFERENCE,
    aug_policy_coverage_schedule__source_row_version_number as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_ROW_VERSION_NUMBER,
    aug_policy_coverage_schedule__sum_insured_company_share as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE,
    aug_policy_coverage_schedule__sum_insured_company_share_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE_CURRENCY_CODE,
    aug_policy_coverage_schedule__sum_insured_whole_cover_currency_code as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_WHOLE_COVER_CURRENCY_CODE,
    aug_policy_coverage_schedule__surcharge_or_discount_amount as AUG_POLICY_COVERAGE_SCHEDULE__SURCHARGE_OR_DISCOUNT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_PERCENTAGE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__DEDUCTIBLE_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__WAITING_PERIOD
from {{ ref('stitch_aug_policy_coverage_schedule') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVER_VARIANT_CLASSIFICATION_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__CO_INSURANCE_SHARE_PORTION,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_CONTRACT_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_PARTITION_NUMBER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_SEQUENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SECTION_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_ROW_VERSION_NUMBER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SURCHARGE_OR_DISCOUNT_AMOUNT,
    policy_coverage_schedule__coverage_reference_ck as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    policy_coverage_schedule__coverage_sequence_ck as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    policy_coverage_schedule__coverage_opted_indicator as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
    policy_coverage_schedule__coverage_reference as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
    policy_coverage_schedule__coverage_sequence as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
    policy_coverage_schedule__co_payment_amount as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_AMOUNT,
    policy_coverage_schedule__co_payment_percentage as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_PERCENTAGE,
    policy_coverage_schedule__deductible_amount as POLICY_COVERAGE_SCHEDULE__DEDUCTIBLE_AMOUNT,
    policy_coverage_schedule__premium_for_coverage as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    policy_coverage_schedule__sub_limit_amount as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
    policy_coverage_schedule__sum_insured as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
    policy_coverage_schedule__waiting_period as POLICY_COVERAGE_SCHEDULE__WAITING_PERIOD
from {{ ref('stitch_policy_coverage_schedule') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    1 as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVER_VARIANT_CLASSIFICATION_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__CO_INSURANCE_SHARE_PORTION,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_CONTRACT_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_PARTITION_NUMBER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_SEQUENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SECTION_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_ROW_VERSION_NUMBER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SURCHARGE_OR_DISCOUNT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_PERCENTAGE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__DEDUCTIBLE_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__WAITING_PERIOD
from {{ ref('stitch_lk_policy_coverage__v25') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    party_bk as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    1 as __LNK_POLICY_PARTY,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__AGENT_COMMISSION_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVER_VARIANT_CLASSIFICATION_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__CO_INSURANCE_SHARE_PORTION,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__FULL_TERM_PREMIUM_SYSTEM_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_CONTRACT_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_PARTITION_NUMBER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PARENT_COVERAGE_SEQUENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__REINSURABLE_RISK_AMOUNT_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SECTION_REFERENCE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_ROW_VERSION_NUMBER,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_COMPANY_SHARE_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_WHOLE_COVER_CURRENCY_CODE,
    cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SURCHARGE_OR_DISCOUNT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__CO_PAYMENT_PERCENTAGE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__DEDUCTIBLE_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
    cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__WAITING_PERIOD
from {{ ref('stitch_lk_policy_party__v25') }}
