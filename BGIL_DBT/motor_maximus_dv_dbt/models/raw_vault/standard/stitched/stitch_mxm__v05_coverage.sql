-- CENTRAL VIEW v05_coverage -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COVERAGE_PARAMETER
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY
    select
        nullif(nullif(trim('COV:' || coalesce(nullif(trim(j3.policy_quote_number), ''), '') || '|' || coalesce(nullif(trim(j2.pol_risk_id), ''), '') || '|' || coalesce(nullif(trim(j1.cover_code), ''), '')), 'COV:||'), '') as COVERAGE_BK,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE_CK,
        t0.event_code as AUG_COVERAGE_PARAMETER__BUSINESS_EVENT_CODE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim('COV:' || coalesce(nullif(trim(j3.policy_quote_number), ''), '') || '|' || coalesce(nullif(trim(j2.pol_risk_id), ''), '') || '|' || coalesce(nullif(trim(j1.cover_code), ''), '')), 'COV:||'), '')) is not null

)

select
    COVERAGE_BK,
    AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE_CK,
    first_value(AUG_COVERAGE_PARAMETER__BUSINESS_EVENT_CODE) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PARAMETER__BUSINESS_EVENT_CODE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on COVERAGE_BK (SAT_MOTOR_AUG_COVERAGE_PARAMETER):
    -- one load time per COVERAGE_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.AUG_COVERAGE_PARAMETER__BUSINESS_EVENT_CODE is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.COVERAGE_BK) as COVERAGE_BK__MA_LOAD_DATETIME
from merged m
