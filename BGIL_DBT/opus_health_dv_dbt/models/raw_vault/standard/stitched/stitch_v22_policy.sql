{{ config(materialized='view') }}
-- CENTRAL VIEW v22_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_NR_BASES_EXTN (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_UNDERWRITING
--   SAT_AUG_POLICY_CLASSIFICATION
--   SAT_AUG_POLICY_CONTINGENCY_SCHEME
--   SAT_POLICY_CLASSIFICATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_assessment_underwriting, stitch_aug_policy_classification, stitch_aug_policy_contingency_scheme, stitch_policy_classification

select
    assessment_bk as ASSESSMENT_BK,
    cast(null as varchar) as POLICY_BK,
    assessment_underwriting__risk_acceptance_authority as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
    assessment_underwriting__special_conditions_recommended as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
    assessment_underwriting__underwriting_remarks as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
    cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
    cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
    cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE
from {{ ref('stitch_assessment_underwriting') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
    aug_policy_classification__classification_type_code as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
    cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
    cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE
from {{ ref('stitch_aug_policy_classification') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
    cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
    aug_policy_contingency_scheme__scheme_code as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
    aug_policy_contingency_scheme__scheme_version as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
    cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE
from {{ ref('stitch_aug_policy_contingency_scheme') }}

union all

select
    cast(null as varchar) as ASSESSMENT_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
    cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
    cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
    cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
    cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
    policy_classification__classification_type_ck as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    policy_classification__classification_type as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
    policy_classification__classification_value as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE
from {{ ref('stitch_policy_classification') }}
