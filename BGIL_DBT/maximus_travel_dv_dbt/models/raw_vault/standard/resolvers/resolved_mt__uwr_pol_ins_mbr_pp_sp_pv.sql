{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- Carries 2 walk column(s) onto each row of stg_mt__uwr_pol_ins_mbr_pp_sp_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_party_code            climb hop, 3 real level(s): uwr_pol_ins_mbr_pp_sp -> uwr_pol_ins_mbr_pp -> uwr_pol_ins_mbr . PARTY_CODE
--   w1_quotation_number      climb hop, 5 real level(s): uwr_pol_ins_mbr_pp_sp -> uwr_pol_ins_mbr_pp -> uwr_pol_ins_mbr -> uwr_pol_ins -> uwr_pol . QUOTATION_NUMBER
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_party_code_p2.party_code as w0_party_code,
    w1_quotation_number_p4.quotation_number as w1_quotation_number
from {{ ref('stg_mt__uwr_pol_ins_mbr_pp_sp_pv') }} b
left join {{ ref('stg_mt__uwr_pol_ins_mbr_pp_sp') }} w0_party_code_p0
    on w0_party_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_mbr_pp') }} w0_party_code_p1
    on w0_party_code_p1.key_hash = w0_party_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_mbr') }} w0_party_code_p2
    on w0_party_code_p2.key_hash = w0_party_code_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_mbr_pp_sp') }} w1_quotation_number_p0
    on w1_quotation_number_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_mbr_pp') }} w1_quotation_number_p1
    on w1_quotation_number_p1.key_hash = w1_quotation_number_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins_mbr') }} w1_quotation_number_p2
    on w1_quotation_number_p2.key_hash = w1_quotation_number_p1.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_ins') }} w1_quotation_number_p3
    on w1_quotation_number_p3.key_hash = w1_quotation_number_p2.parent_key_hash
left join {{ ref('stg_mt__uwr_pol') }} w1_quotation_number_p4
    on w1_quotation_number_p4.key_hash = w1_quotation_number_p3.parent_key_hash
