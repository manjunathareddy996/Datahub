{{ config(materialized='view') }}
-- CENTRAL VIEW v12_coverage -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BJAZ_GRP_TPA_EXTN (opus_health_legacy_v4)
--   BJAZ_STARPKG_COVER_MST (opus_health_delta3)
--   BJAZ_STARPKG_COV_PREM_MST (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COVERAGE_DEFINITION
--   SAT_AUG_COVERAGE_PARAMETER
--   SAT_AUG_COVERAGE_PREMIUM_RATE_SLAB
--   SAT_COVERAGE_DEFINITION
--   SAT_POLICY_INSTALMENT_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_aug_coverage_definition, stitch_aug_coverage_parameter, stitch_aug_coverage_premium_rate_slab, stitch_coverage_definition, stitch_policy_instalment_schedule, stitch_lk_policy_coverage__v12, stitch_lk_policy_party__v12, stitch_lk_policy_product__v12, stitch_lk_product_coverage__v12

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    aug_coverage_definition__catalogue_display_order as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    aug_coverage_definition__independently_selectable_indicator as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    aug_coverage_definition__rating_participation_indicator as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    aug_coverage_definition__section_reference as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    aug_coverage_definition__self_covered_indicator as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_aug_coverage_definition') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    aug_coverage_parameter__parameter_reference as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    aug_coverage_parameter__parameter_value as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_aug_coverage_parameter') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    aug_coverage_premium_rate_slab__age_limit_band as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    aug_coverage_premium_rate_slab__line_sequence_number as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    aug_coverage_premium_rate_slab__plan_reference as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    aug_coverage_premium_rate_slab__premium_applicability_basis as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    aug_coverage_premium_rate_slab__rate_effective_date as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    aug_coverage_premium_rate_slab__section_reference as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    aug_coverage_premium_rate_slab__slab_premium_rate as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    aug_coverage_premium_rate_slab__sum_insured_slab_amount as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_aug_coverage_premium_rate_slab') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    coverage_definition__coverage_description as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_coverage_definition') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    policy_instalment_schedule__instalment_number_ck as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    policy_instalment_schedule__due_date as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    policy_instalment_schedule__instalment_amount as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    policy_instalment_schedule__instalment_number as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    policy_instalment_schedule__outstanding_after_instalment as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    policy_instalment_schedule__paid_amount as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_policy_instalment_schedule') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    1 as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_lk_policy_coverage__v12') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    party_bk as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    1 as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_lk_policy_party__v12') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    product_bk as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    1 as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_lk_policy_product__v12') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    product_bk as PRODUCT_BK,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    1 as __LNK_PRODUCT_COVERAGE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from {{ ref('stitch_lk_product_coverage__v12') }}
