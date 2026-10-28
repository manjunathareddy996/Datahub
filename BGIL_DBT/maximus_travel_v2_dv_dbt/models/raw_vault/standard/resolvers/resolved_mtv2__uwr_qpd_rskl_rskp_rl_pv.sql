{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
--
-- Carries 4 walk column(s) onto each row of stg_mtv2__uwr_qpd_rskl_rskp_rl_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_quote_number   climb hop, 4 real level(s): uwr_qpd_rskl_rskp_rl -> uwr_qpd_rskl_rskp -> uwr_qpd_rskl -> uwr_qpd . POLICY_QUOTE_NUMBER
--   w1_pol_risk_id           climb hop, 3 real level(s): uwr_qpd_rskl_rskp_rl -> uwr_qpd_rskl_rskp -> uwr_qpd_rskl . POL_RISK_ID
--   w2_policy_holder_code    climb hop, 4 real level(s): uwr_qpd_rskl_rskp_rl -> uwr_qpd_rskl_rskp -> uwr_qpd_rskl -> uwr_qpd . POLICY_HOLDER_CODE
--   w3_product_code          climb hop, 4 real level(s): uwr_qpd_rskl_rskp_rl -> uwr_qpd_rskl_rskp -> uwr_qpd_rskl -> uwr_qpd . PRODUCT_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_policy_quote_number_p3.policy_quote_number as w0_policy_quote_number,
    w1_pol_risk_id_p2.pol_risk_id as w1_pol_risk_id,
    w2_policy_holder_code_p3.policy_holder_code as w2_policy_holder_code,
    w3_product_code_p3.product_code as w3_product_code
from {{ ref('stg_mtv2__uwr_qpd_rskl_rskp_rl_pv') }} b
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp_rl') }} w0_policy_quote_number_p0
    on w0_policy_quote_number_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp') }} w0_policy_quote_number_p1
    on w0_policy_quote_number_p1.key_hash = w0_policy_quote_number_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl') }} w0_policy_quote_number_p2
    on w0_policy_quote_number_p2.key_hash = w0_policy_quote_number_p1.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd') }} w0_policy_quote_number_p3
    on w0_policy_quote_number_p3.key_hash = w0_policy_quote_number_p2.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp_rl') }} w1_pol_risk_id_p0
    on w1_pol_risk_id_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp') }} w1_pol_risk_id_p1
    on w1_pol_risk_id_p1.key_hash = w1_pol_risk_id_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl') }} w1_pol_risk_id_p2
    on w1_pol_risk_id_p2.key_hash = w1_pol_risk_id_p1.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp_rl') }} w2_policy_holder_code_p0
    on w2_policy_holder_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp') }} w2_policy_holder_code_p1
    on w2_policy_holder_code_p1.key_hash = w2_policy_holder_code_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl') }} w2_policy_holder_code_p2
    on w2_policy_holder_code_p2.key_hash = w2_policy_holder_code_p1.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd') }} w2_policy_holder_code_p3
    on w2_policy_holder_code_p3.key_hash = w2_policy_holder_code_p2.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp_rl') }} w3_product_code_p0
    on w3_product_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl_rskp') }} w3_product_code_p1
    on w3_product_code_p1.key_hash = w3_product_code_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd_rskl') }} w3_product_code_p2
    on w3_product_code_p2.key_hash = w3_product_code_p1.parent_key_hash
left join {{ ref('stg_mtv2__uwr_qpd') }} w3_product_code_p3
    on w3_product_code_p3.key_hash = w3_product_code_p2.parent_key_hash
