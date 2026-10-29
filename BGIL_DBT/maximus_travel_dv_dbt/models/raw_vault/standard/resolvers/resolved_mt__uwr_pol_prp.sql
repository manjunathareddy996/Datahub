{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--
-- Carries 1 walk column(s) onto each row of stg_mt__uwr_pol_prp.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_number         climb hop, 1 real level(s): uwr_pol . POLICY_NUMBER
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_policy_number_p0.policy_number as w0_policy_number
from {{ ref('stg_mt__uwr_pol_prp') }} b
left join {{ ref('stg_mt__uwr_pol') }} w0_policy_number_p0
    on w0_policy_number_p0.key_hash = b.parent_key_hash
