{{ config(materialized='view') }}
-- CENTRAL VIEW v04_case -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_INWARD_OMNI_MAPPING (opus_health_v2)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_EXTERNAL_REF
--   SAT_CASE_EXTERNAL_REF
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_aug_case_external_ref, stitch_case_external_ref__omni_inward

select
    case_bk as CASE_BK,
    aug_case_external_ref__redirect_indicator as AUG_CASE_EXTERNAL_REF__REDIRECT_INDICATOR,
    cast(null as varchar) as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
    cast(null as varchar) as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE
from {{ ref('stitch_aug_case_external_ref') }}

union all

select
    case_bk as CASE_BK,
    cast(null as varchar) as AUG_CASE_EXTERNAL_REF__REDIRECT_INDICATOR,
    case_external_ref__reference_type_ck as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
    case_external_ref__external_reference as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE
from {{ ref('stitch_case_external_ref__omni_inward') }}
