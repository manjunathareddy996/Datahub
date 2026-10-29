{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_ORG_UNIT_CONTACT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mt__uwr_pol_off_oa_address_prop_pv__aug_sat_aug_org_unit_contact: 6 instance(s) on this view.
--
-- 3 payload column(s); the child key is CONTACT_POINT_TYPE.

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_pol_off_oa_address_prop_pv__aug_sat_aug_org_unit_contact'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  HASHDIFF_ORG_UNIT_CONTACT:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'CONTACT_POINT_TYPE'
      - 'MOBILE_NUMBER'
      - 'SOCIAL_MEDIA_HANDLE'
derived_columns:
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (ORG_UNIT_BK)"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  CONTACT_POINT_TYPE: 'CONTACT_POINT_TYPE'
  ALTERNATE_MOBILE_NUMBER: 'ALTERNATE_MOBILE_NUMBER'
  MOBILE_NUMBER: 'MOBILE_NUMBER'
  SOCIAL_MEDIA_HANDLE: 'SOCIAL_MEDIA_HANDLE'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
