{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS
--
-- Carries 1 walk column(s) onto each row of stg_mtv2__uwr_pol_ins_mbr_pa.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_party_code            climb hop, 1 real level(s): uwr_pol_ins_mbr . PARTY_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_party_code_p0.party_code as w0_party_code
from {{ ref('stg_mtv2__uwr_pol_ins_mbr_pa') }} b
left join {{ ref('stg_mtv2__uwr_pol_ins_mbr') }} w0_party_code_p0
    on w0_party_code_p0.key_hash = b.parent_key_hash
