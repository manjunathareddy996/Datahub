{{ config(materialized='view') }}

-- RESOLVER for NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--
-- Carries 7 walk column(s) onto each row of stg_mt__uwr_pol_off_oa_address_prop_pv.
-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the
-- destination's name: a named destination skips levels.
--
--   w0_address1              climb hop, 2 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa . ADDRESS1
--   w1_address2              climb hop, 2 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa . ADDRESS2
--   w2_address3              climb hop, 2 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa . ADDRESS3
--   w3_city                  climb hop, 2 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa . CITY
--   w4_state                 climb hop, 2 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa . STATE
--   w5_pincode               climb hop, 2 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa . PINCODE
--   w6_office_code           climb hop, 3 real level(s): uwr_pol_off_oa_address_prop -> uwr_pol_off_oa -> uwr_pol_off . OFFICE_CODE
--
-- Left joins throughout. A row whose ancestor is missing keeps its own columns and
-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and
-- audit_mt_key_rejections counts the drop. A WRONG hop would also produce all-NULL,
-- which is why the drop is counted per hub per feeder rather than assumed to be zero.

select
    b.*,
    w0_address1_p1.address1 as w0_address1,
    w1_address2_p1.address2 as w1_address2,
    w2_address3_p1.address3 as w2_address3,
    w3_city_p1.city as w3_city,
    w4_state_p1.state as w4_state,
    w5_pincode_p1.pincode as w5_pincode,
    w6_office_code_p2.office_code as w6_office_code
from {{ ref('stg_mt__uwr_pol_off_oa_address_prop_pv') }} b
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w0_address1_p0
    on w0_address1_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w0_address1_p1
    on w0_address1_p1.key_hash = w0_address1_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w1_address2_p0
    on w1_address2_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w1_address2_p1
    on w1_address2_p1.key_hash = w1_address2_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w2_address3_p0
    on w2_address3_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w2_address3_p1
    on w2_address3_p1.key_hash = w2_address3_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w3_city_p0
    on w3_city_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w3_city_p1
    on w3_city_p1.key_hash = w3_city_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w4_state_p0
    on w4_state_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w4_state_p1
    on w4_state_p1.key_hash = w4_state_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w5_pincode_p0
    on w5_pincode_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w5_pincode_p1
    on w5_pincode_p1.key_hash = w5_pincode_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa_address_prop') }} w6_office_code_p0
    on w6_office_code_p0.key_hash = b.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off_oa') }} w6_office_code_p1
    on w6_office_code_p1.key_hash = w6_office_code_p0.parent_key_hash
left join {{ ref('stg_mt__uwr_pol_off') }} w6_office_code_p2
    on w6_office_code_p2.key_hash = w6_office_code_p1.parent_key_hash
