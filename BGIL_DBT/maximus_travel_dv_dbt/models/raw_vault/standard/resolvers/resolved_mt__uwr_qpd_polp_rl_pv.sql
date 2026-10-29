{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--
-- Carries 3 walk column(s) onto each row of stg_mt__uwr_qpd_polp_rl_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_quote_number   climb hop, 3 real level(s): uwr_qpd_polp_rl -> uwr_qpd_polp -> uwr_qpd . POLICY_QUOTE_NUMBER
--   w1_product_code          climb hop, 3 real level(s): uwr_qpd_polp_rl -> uwr_qpd_polp -> uwr_qpd . PRODUCT_CODE
--   w2_policy_holder_code    climb hop, 3 real level(s): uwr_qpd_polp_rl -> uwr_qpd_polp -> uwr_qpd . POLICY_HOLDER_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_policy_quote_number_p2.policy_quote_number as w0_policy_quote_number,
    w1_product_code_p2.product_code as w1_product_code,
    w2_policy_holder_code_p2.policy_holder_code as w2_policy_holder_code
from {{ ref('stg_mt__uwr_qpd_polp_rl_pv') }} b
left join {{ ref('stg_mt__uwr_qpd_polp_rl') }} w0_policy_quote_number_p0
    on w0_policy_quote_number_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_polp') }} w0_policy_quote_number_p1
    on w0_policy_quote_number_p1.key_hash = w0_policy_quote_number_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd') }} w0_policy_quote_number_p2
    on w0_policy_quote_number_p2.key_hash = w0_policy_quote_number_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_polp_rl') }} w1_product_code_p0
    on w1_product_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_polp') }} w1_product_code_p1
    on w1_product_code_p1.key_hash = w1_product_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd') }} w1_product_code_p2
    on w1_product_code_p2.key_hash = w1_product_code_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_polp_rl') }} w2_policy_holder_code_p0
    on w2_policy_holder_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd_polp') }} w2_policy_holder_code_p1
    on w2_policy_holder_code_p1.key_hash = w2_policy_holder_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_qpd') }} w2_policy_holder_code_p2
    on w2_policy_holder_code_p2.key_hash = w2_policy_holder_code_p1.parent_key_hash
