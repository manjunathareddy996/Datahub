{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
--
-- Carries 3 walk column(s) onto each row of stg_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_quote_number   climb hop, 5 real level(s): uwr_qpd_rskl_rskc_rskc_prop_rl -> uwr_qpd_rskl_rskc_rskc_prop -> uwr_qpd_rskl_rskc -> uwr_qpd_rskl -> uwr_qpd . POLICY_QUOTE_NUMBER
--   w1_pol_risk_id           climb hop, 4 real level(s): uwr_qpd_rskl_rskc_rskc_prop_rl -> uwr_qpd_rskl_rskc_rskc_prop -> uwr_qpd_rskl_rskc -> uwr_qpd_rskl . POL_RISK_ID
--   w2_cover_code            climb hop, 3 real level(s): uwr_qpd_rskl_rskc_rskc_prop_rl -> uwr_qpd_rskl_rskc_rskc_prop -> uwr_qpd_rskl_rskc . COVER_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_policy_quote_number_p4.policy_quote_number as w0_policy_quote_number,
    w1_pol_risk_id_p3.pol_risk_id as w1_pol_risk_id,
    w2_cover_code_p2.cover_code as w2_cover_code
from {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }} b
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop_rl') }} w0_policy_quote_number_p0
    on w0_policy_quote_number_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop') }} w0_policy_quote_number_p1
    on w0_policy_quote_number_p1.key_hash = w0_policy_quote_number_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc') }} w0_policy_quote_number_p2
    on w0_policy_quote_number_p2.key_hash = w0_policy_quote_number_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl') }} w0_policy_quote_number_p3
    on w0_policy_quote_number_p3.key_hash = w0_policy_quote_number_p2.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd') }} w0_policy_quote_number_p4
    on w0_policy_quote_number_p4.key_hash = w0_policy_quote_number_p3.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop_rl') }} w1_pol_risk_id_p0
    on w1_pol_risk_id_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop') }} w1_pol_risk_id_p1
    on w1_pol_risk_id_p1.key_hash = w1_pol_risk_id_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc') }} w1_pol_risk_id_p2
    on w1_pol_risk_id_p2.key_hash = w1_pol_risk_id_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl') }} w1_pol_risk_id_p3
    on w1_pol_risk_id_p3.key_hash = w1_pol_risk_id_p2.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop_rl') }} w2_cover_code_p0
    on w2_cover_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc_rskc_prop') }} w2_cover_code_p1
    on w2_cover_code_p1.key_hash = w2_cover_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_rskl_rskc') }} w2_cover_code_p2
    on w2_cover_code_p2.key_hash = w2_cover_code_p1.parent_key_hash
