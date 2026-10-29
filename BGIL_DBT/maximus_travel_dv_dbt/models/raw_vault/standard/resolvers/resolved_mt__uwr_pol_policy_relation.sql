{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_RELATION
--
-- Carries 1 walk column(s) onto each row of stg_mt__uwr_pol_policy_relation.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_number         fk_join (document handle) => uwr_pol.POLICY_NUMBER
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
    w0_policy_number_d.policy_number as w0_policy_number
from {{ ref('stg_mt__uwr_pol_policy_relation') }} b
left join {{ ref('stg_mt__uwr_pol') }} w0_policy_number_d
    on w0_policy_number_d.foreign_key = b.foreign_key
