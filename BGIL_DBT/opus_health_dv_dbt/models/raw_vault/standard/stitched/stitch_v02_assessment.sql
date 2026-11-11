{{ config(materialized='view') }}
-- CENTRAL VIEW v02_assessment -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_SCR_HLTH_PORTABLE_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_GRP_HLT_MEM_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_HEADER
--   SAT_QUOTE_HEADER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CASE_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_QUOTE_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_assessment_header, stitch_quote_header, stitch_lk_assessment_party__v02, stitch_lk_case_party__v02, stitch_lk_policy_product__v02, stitch_lk_quote_product__v02

select
    assessment_bk as ASSESSMENT_BK,
    cast(null as varchar) as CASE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as QUOTE_BK,
    cast(null as int) as __LNK_ASSESSMENT_PARTY,
    cast(null as int) as __LNK_CASE_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_QUOTE_PRODUCT,
    assessment_header__assessment_reference_number as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    assessment_header__assessment_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    assessment_header__assessment_type as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    assessment_header__assessor_reference as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    assessment_header__completed_date as ASSESSMENT_HEADER__COMPLETED_DATE,
    assessment_header__conducted_date as ASSESSMENT_HEADER__CONDUCTED_DATE,
    assessment_header__cost_of_assessment as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    assessment_header__outcome_summary as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    assessment_header__priority as ASSESSMENT_HEADER__PRIORITY,
    assessment_header__scheduled_date as ASSESSMENT_HEADER__SCHEDULED_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
    cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from {{ ref('stitch_assessment_header') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    cast(null as varchar) as CASE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    quote_bk as QUOTE_BK,
    cast(null as int) as __LNK_ASSESSMENT_PARTY,
    cast(null as int) as __LNK_CASE_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_QUOTE_PRODUCT,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
    cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
    quote_header__quote_date as QUOTE_HEADER__QUOTE_DATE,
    quote_header__quote_remarks as QUOTE_HEADER__QUOTE_REMARKS,
    quote_header__quote_status as QUOTE_HEADER__QUOTE_STATUS,
    quote_header__quote_version as QUOTE_HEADER__QUOTE_VERSION,
    quote_header__requested_cover_start_date as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from {{ ref('stitch_quote_header') }}

union all

select
    assessment_bk as ASSESSMENT_BK,
    cast(null as varchar) as CASE_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as QUOTE_BK,
    1 as __LNK_ASSESSMENT_PARTY,
    cast(null as int) as __LNK_CASE_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_QUOTE_PRODUCT,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
    cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
    cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from {{ ref('stitch_lk_assessment_party__v02') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    case_bk as CASE_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as QUOTE_BK,
    cast(null as int) as __LNK_ASSESSMENT_PARTY,
    1 as __LNK_CASE_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_QUOTE_PRODUCT,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
    cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
    cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from {{ ref('stitch_lk_case_party__v02') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    cast(null as varchar) as CASE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    product_bk as PRODUCT_BK,
    cast(null as varchar) as QUOTE_BK,
    cast(null as int) as __LNK_ASSESSMENT_PARTY,
    cast(null as int) as __LNK_CASE_PARTY,
    1 as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_QUOTE_PRODUCT,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
    cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
    cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from {{ ref('stitch_lk_policy_product__v02') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    cast(null as varchar) as CASE_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    product_bk as PRODUCT_BK,
    quote_bk as QUOTE_BK,
    cast(null as int) as __LNK_ASSESSMENT_PARTY,
    cast(null as int) as __LNK_CASE_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    1 as __LNK_QUOTE_PRODUCT,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
    cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
    cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
    cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from {{ ref('stitch_lk_quote_product__v02') }}
