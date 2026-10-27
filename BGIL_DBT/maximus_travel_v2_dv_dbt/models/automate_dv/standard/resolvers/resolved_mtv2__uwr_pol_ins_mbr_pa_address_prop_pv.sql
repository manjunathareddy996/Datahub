{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--
-- Carries 1 walk column(s) onto each row of stg_mtv2__uwr_pol_ins_mbr_pa_address_prop_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_party_code            climb hop, 3 real level(s): uwr_pol_ins_mbr_pa_address_prop -> uwr_pol_ins_mbr_pa -> uwr_pol_ins_mbr . PARTY_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_party_code_p2.party_code as w0_party_code
from {{ ref('stg_mtv2__uwr_pol_ins_mbr_pa_address_prop_pv') }} b
left join {{ ref('stg_mtv2__uwr_pol_ins_mbr_pa_address_prop') }} w0_party_code_p0
    on w0_party_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_ins_mbr_pa') }} w0_party_code_p1
    on w0_party_code_p1.key_hash = w0_party_code_p0.parent_key_hash
left join {{ ref('stg_mtv2__uwr_pol_ins_mbr') }} w0_party_code_p2
    on w0_party_code_p2.key_hash = w0_party_code_p1.parent_key_hash
