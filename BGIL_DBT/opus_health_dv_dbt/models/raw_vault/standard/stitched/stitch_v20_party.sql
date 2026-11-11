{{ config(materialized='view') }}
-- CENTRAL VIEW v20_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BA_HCP_DT_MEM_COV (opus_health_legacy_v4)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_CARD_DTLS (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_ILLNESS_BASES_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_CLAIM_HISTORY
--   SAT_POLICY_CERTIFICATE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_ROLE
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_party_claim_history, stitch_policy_certificate, stitch_lk_party_role__v20, stitch_lk_policy_coverage__v20, stitch_lk_policy_party__v20

select
    cast(null as varchar) as COVERAGE_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as int) as __LNK_PARTY_ROLE,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    party_claim_history__total_claim_amount as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    party_claim_history__total_claim_count as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED
from {{ ref('stitch_party_claim_history') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as int) as __LNK_PARTY_ROLE,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    policy_certificate__certificate_number_ck as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    policy_certificate__certificate_number as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    policy_certificate__coverage_end_date as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    policy_certificate__coverage_start_date as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    policy_certificate__enrolment_date as POLICY_CERTIFICATE__ENROLMENT_DATE,
    policy_certificate__joining_type as POLICY_CERTIFICATE__JOINING_TYPE,
    policy_certificate__member_premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    policy_certificate__member_status as POLICY_CERTIFICATE__MEMBER_STATUS,
    policy_certificate__member_sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED
from {{ ref('stitch_policy_certificate') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    1 as __LNK_PARTY_ROLE,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED
from {{ ref('stitch_lk_party_role__v20') }}

union all

select
    coverage_bk as COVERAGE_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as int) as __LNK_PARTY_ROLE,
    1 as __LNK_POLICY_COVERAGE,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED
from {{ ref('stitch_lk_policy_coverage__v20') }}

union all

select
    cast(null as varchar) as COVERAGE_BK,
    party_bk as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as int) as __LNK_PARTY_ROLE,
    cast(null as int) as __LNK_POLICY_COVERAGE,
    1 as __LNK_POLICY_PARTY,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
    cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
    cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED
from {{ ref('stitch_lk_policy_party__v20') }}
