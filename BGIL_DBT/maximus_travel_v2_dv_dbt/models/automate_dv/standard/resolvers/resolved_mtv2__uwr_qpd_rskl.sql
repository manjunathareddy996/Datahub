{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--
-- Carries 1 walk column(s) onto each row of stg_mtv2__uwr_qpd_rskl.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_quote_number   climb hop, 1 real level(s): uwr_qpd . POLICY_QUOTE_NUMBER
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_policy_quote_number_p0.policy_quote_number as w0_policy_quote_number
from {{ ref('stg_mtv2__uwr_qpd_rskl') }} b
left join {{ ref('stg_mtv2__uwr_qpd') }} w0_policy_quote_number_p0
    on w0_policy_quote_number_p0.key_hash = b.parent_key_hash
