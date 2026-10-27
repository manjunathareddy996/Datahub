{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_ORG_UNIT_CONTACT: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        ORG_UNIT_HKEY as ORG_UNIT_HKEY,
        CONTACT_POINT_TYPE,
        ALTERNATE_MOBILE_NUMBER,
        MOBILE_NUMBER,
        SOCIAL_MEDIA_HANDLE,
        HASHDIFF_ORG_UNIT_CONTACT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_off_oa_address_prop_pv__sat_aug_org_unit_contact') }}
    where ORG_UNIT_HKEY is not null
