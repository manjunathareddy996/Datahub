{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- Carries 4 walk column(s) onto each row of stg_mt__clm_clmd_clmap_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_claimno               fk_join (document handle) => clm_clmd.CLAIMNO
--   w1_policyno              fk_join (document handle) => clm_clmd.POLICYNO
--   w2_claimno               climb hop, 3 real level(s): clm_clmd_clmap -> clm_clmd_clma -> clm_clmd . CLAIMNO
--   w3_policyno              climb hop, 3 real level(s): clm_clmd_clmap -> clm_clmd_clma -> clm_clmd . POLICYNO
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.
--
-- 2 hop(s) here join on FOREIGN_KEY, the document handle (BD1). The round-trip to
-- the root business number is UNPROVEN -- 00_tables_index.json carries
-- sample_data_available=false -- so audit_mt_fk_roundtrip counts distinct root
-- business numbers per FOREIGN_KEY value; any count above 1 falsifies it before any
-- load (open item P6-FK-ROUNDTRIP).

select
    b.*,
    w0_claimno_d.claimno as w0_claimno,
    w1_policyno_d.policyno as w1_policyno,
    w2_claimno_p2.claimno as w2_claimno,
    w3_policyno_p2.policyno as w3_policyno
from {{ ref('stg_mt__clm_clmd_clmap_pv') }} b
left join {{ ref('stg_mt__clm_clmd') }} w0_claimno_d
    on w0_claimno_d.foreign_key = b.foreign_key
left join {{ ref('stg_mt__clm_clmd') }} w1_policyno_d
    on w1_policyno_d.foreign_key = b.foreign_key
left join {{ ref('stg_mt__clm_clmd_clmap') }} w2_claimno_p0
    on w2_claimno_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__clm_clmd_clma') }} w2_claimno_p1
    on w2_claimno_p1.key_hash = w2_claimno_p0.parent_key_hash
left join {{ ref('stg_mt__clm_clmd') }} w2_claimno_p2
    on w2_claimno_p2.key_hash = w2_claimno_p1.parent_key_hash
left join {{ ref('stg_mt__clm_clmd_clmap') }} w3_policyno_p0
    on w3_policyno_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__clm_clmd_clma') }} w3_policyno_p1
    on w3_policyno_p1.key_hash = w3_policyno_p0.parent_key_hash
left join {{ ref('stg_mt__clm_clmd') }} w3_policyno_p2
    on w3_policyno_p2.key_hash = w3_policyno_p1.parent_key_hash
