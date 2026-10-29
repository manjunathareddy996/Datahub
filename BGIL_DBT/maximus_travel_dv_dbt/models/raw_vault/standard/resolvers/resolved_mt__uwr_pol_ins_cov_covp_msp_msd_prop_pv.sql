{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- Carries 1 walk column(s) onto each row of stg_mt__uwr_pol_ins_cov_covp_msp_msd_prop_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_cover_code            climb hop, 5 real level(s): uwr_pol_ins_cov_covp_msp_msd_prop -> uwr_pol_ins_cov_covp_msp_msd -> uwr_pol_ins_cov_covp_msp -> uwr_pol_ins_cov_covp -> uwr_pol_ins_cov . COVER_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_cover_code_p4.cover_code as w0_cover_code
from {{ ref('stg_mt__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }} b
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp_msp_msd_prop') }} w0_cover_code_p0
    on w0_cover_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp_msp_msd') }} w0_cover_code_p1
    on w0_cover_code_p1.key_hash = w0_cover_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp_msp') }} w0_cover_code_p2
    on w0_cover_code_p2.key_hash = w0_cover_code_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov_covp') }} w0_cover_code_p3
    on w0_cover_code_p3.key_hash = w0_cover_code_p2.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_cov') }} w0_cover_code_p4
    on w0_cover_code_p4.key_hash = w0_cover_code_p3.parent_key_hash
