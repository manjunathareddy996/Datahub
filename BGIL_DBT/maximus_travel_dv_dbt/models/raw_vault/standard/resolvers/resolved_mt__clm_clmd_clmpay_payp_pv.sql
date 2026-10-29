{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--
-- Carries 3 walk column(s) onto each row of stg_mt__clm_clmd_clmpay_payp_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_claimno               fk_join (document handle) => clm_clmd.CLAIMNO
--   w1_claimpaymentid        climb hop, 2 real level(s): clm_clmd_clmpay_payp -> clm_clmd_clmpay . CLAIMPAYMENTID
--   w2_payreservetypre       climb hop, 2 real level(s): clm_clmd_clmpay_payp -> clm_clmd_clmpay . PAYRESERVETYPRE
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
    w0_claimno_d.claimno as w0_claimno,
    w1_claimpaymentid_p1.claimpaymentid as w1_claimpaymentid,
    w2_payreservetypre_p1.payreservetypre as w2_payreservetypre
from {{ ref('stg_mt__clm_clmd_clmpay_payp_pv') }} b
left join {{ ref('stg_mt__clm_clmd') }} w0_claimno_d
    on w0_claimno_d.foreign_key = b.foreign_key
left join {{ ref('stg_mt__clm_clmd_clmpay_payp') }} w1_claimpaymentid_p0
    on w1_claimpaymentid_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__clm_clmd_clmpay') }} w1_claimpaymentid_p1
    on w1_claimpaymentid_p1.key_hash = w1_claimpaymentid_p0.parent_key_hash
left join {{ ref('stg_mt__clm_clmd_clmpay_payp') }} w2_payreservetypre_p0
    on w2_payreservetypre_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__clm_clmd_clmpay') }} w2_payreservetypre_p1
    on w2_payreservetypre_p1.key_hash = w2_payreservetypre_p0.parent_key_hash
