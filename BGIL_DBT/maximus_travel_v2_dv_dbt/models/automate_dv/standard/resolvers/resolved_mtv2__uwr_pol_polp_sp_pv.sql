{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- Carries 4 walk column(s) onto each row of stg_mtv2__uwr_pol_polp_sp_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_policy_number         fk_join (document handle) => uwr_pol.POLICY_NUMBER
--   w1_policy_number         climb hop, 3 real level(s): uwr_pol_polp_sp -> uwr_pol_polp -> uwr_pol . POLICY_NUMBER
--   w2_product_code          climb hop, 3 real level(s): uwr_pol_polp_sp -> uwr_pol_polp -> uwr_pol . PRODUCT_CODE
--   w3_policy_holder_code    climb hop, 3 real level(s): uwr_pol_polp_sp -> uwr_pol_polp -> uwr_pol . POLICY_HOLDER_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.
--
-- 1 hop(s) here join on FOREIGN_KEY, the document handle (BD1). The round-trip to
-- the root business number is UNPROVEN -- 00_tables_index.json carries
-- sample_data_available=false -- so audit_mtv2_fk_roundtrip counts distinct root
-- business numbers per FOREIGN_KEY value; any count above 1 falsifies it before any
-- load (open item P6-FK-ROUNDTRIP).

select
    b.*,
    w0_policy_number_d.policy_number as w0_policy_number,
    w1_policy_number_p2.policy_number as w1_policy_number,
    w2_product_code_p2.product_code as w2_product_code,
    w3_policy_holder_code_p2.policy_holder_code as w3_policy_holder_code
from {{ ref('stg_mtv2__uwr_pol_polp_sp_pv') }} b
left join {{ ref('stg_mtv2__uwr_pol') }} w0_policy_number_d
    on w0_policy_number_d.foreign_key = b.foreign_key
left join {{ ref('stg_mtv2__uwr_pol_polp_sp') }} w1_policy_number_p0
    on w1_policy_number_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_polp') }} w1_policy_number_p1
    on w1_policy_number_p1.key_hash = w1_policy_number_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol') }} w1_policy_number_p2
    on w1_policy_number_p2.key_hash = w1_policy_number_p1.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_polp_sp') }} w2_product_code_p0
    on w2_product_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_polp') }} w2_product_code_p1
    on w2_product_code_p1.key_hash = w2_product_code_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol') }} w2_product_code_p2
    on w2_product_code_p2.key_hash = w2_product_code_p1.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_polp_sp') }} w3_policy_holder_code_p0
    on w3_policy_holder_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_polp') }} w3_policy_holder_code_p1
    on w3_policy_holder_code_p1.key_hash = w3_policy_holder_code_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol') }} w3_policy_holder_code_p2
    on w3_policy_holder_code_p2.key_hash = w3_policy_holder_code_p1.parent_key_hash
