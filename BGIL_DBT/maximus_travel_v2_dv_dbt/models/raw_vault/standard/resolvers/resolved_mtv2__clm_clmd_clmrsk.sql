{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK
--
-- Carries 1 walk column(s) onto each row of stg_mtv2__clm_clmd_clmrsk.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policyno              climb hop, 1 real level(s): clm_clmd . POLICYNO
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_policyno_p0.policyno as w0_policyno
from {{ ref('stg_mtv2__clm_clmd_clmrsk') }} b
left join {{ ref('stg_mtv2__clm_clmd') }} w0_policyno_p0
    on w0_policyno_p0.key_hash = b.parent_key_hash
