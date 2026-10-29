{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- Carries 3 walk column(s) onto each row of stg_mt__uwr_pol_ins_cov_covp_sp_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_number         fk_join (document handle) => uwr_pol.POLICY_NUMBER
--   w1_pol_risk_id           climb hop, 4 real level(s): uwr_pol_ins_cov_covp_sp -> uwr_pol_ins_cov_covp -> uwr_pol_ins_cov -> uwr_pol_ins . POL_RISK_ID
--   w2_cover_code            climb hop, 3 real level(s): uwr_pol_ins_cov_covp_sp -> uwr_pol_ins_cov_covp -> uwr_pol_ins_cov . COVER_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.
--
-- 1 hop(s) here join on FOREIGN_KEY, the document handle (BD1). The round-trip to
-- the root business number is UNPROVEN -- 00_tables_index.json carries
-- sample_data_available=false -- so audit_mt_fk_roundtrip counts distinct root
-- business numbers per FOREIGN_KEY value; any count above 1 falsifies it before any
-- load (open item P6-FK-ROUNDTRIP).

select
    b.*,
    w0_policy_number_d.policy_number as w0_policy_number,
    w1_pol_risk_id_p3.pol_risk_id as w1_pol_risk_id,
    w2_cover_code_p2.cover_code as w2_cover_code
from {{ ref('stg_mt__uwr_pol_ins_cov_covp_sp_pv') }} b
left join {{ ref('stg_mt__uwr_pol') }} w0_policy_number_d
    on w0_policy_number_d.foreign_key = b.foreign_key
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp_sp') }} w1_pol_risk_id_p0
    on w1_pol_risk_id_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp') }} w1_pol_risk_id_p1
    on w1_pol_risk_id_p1.key_hash = w1_pol_risk_id_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov') }} w1_pol_risk_id_p2
    on w1_pol_risk_id_p2.key_hash = w1_pol_risk_id_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins') }} w1_pol_risk_id_p3
    on w1_pol_risk_id_p3.key_hash = w1_pol_risk_id_p2.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp_sp') }} w2_cover_code_p0
    on w2_cover_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp') }} w2_cover_code_p1
    on w2_cover_code_p1.key_hash = w2_cover_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov') }} w2_cover_code_p2
    on w2_cover_code_p2.key_hash = w2_cover_code_p1.parent_key_hash
