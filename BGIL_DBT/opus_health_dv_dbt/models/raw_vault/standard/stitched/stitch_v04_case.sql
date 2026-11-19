-- CENTRAL VIEW v04_case -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_INWARD_OMNI_MAPPING (opus_health_v2)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_EXTERNAL_REF
--   SAT_CASE_EXTERNAL_REF
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_HM_INWARD_OMNI_MAPPING
    select
        nullif(trim(cashless_in_id),'') as CASE_BK,
        redirect_flag as AUG_CASE_EXTERNAL_REF__REDIRECT_INDICATOR,
        cast(null as varchar) as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
        cast(null as varchar) as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_inward_omni_mapping') }}
    where (nullif(trim(cashless_in_id),'')) is not null

    union all

    -- branch 1: BJAZ_HM_INWARD_OMNI_MAPPING | child-key literal(s): CASE_EXTERNAL_REF.Reference Type=OMNI_INWARD
    select
        nullif(trim(cashless_in_id),'') as CASE_BK,
        cast(null as varchar) as AUG_CASE_EXTERNAL_REF__REDIRECT_INDICATOR,
        'OMNI_INWARD' as CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
        omni_inward_no as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_inward_omni_mapping') }}
    where (nullif(trim(cashless_in_id),'')) is not null

)

select
    CASE_BK,
    first_value(AUG_CASE_EXTERNAL_REF__REDIRECT_INDICATOR) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_EXTERNAL_REF__REDIRECT_INDICATOR,
    CASE_EXTERNAL_REF__REFERENCE_TYPE_CK,
    first_value(CASE_EXTERNAL_REF__EXTERNAL_REFERENCE) ignore nulls over (partition by CASE_BK, CASE_EXTERNAL_REF__REFERENCE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_EXTERNAL_REF__EXTERNAL_REFERENCE
from merged
