{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_SPP_MEMBER_DTLS'.
-- 4 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_SPP_MEMBER_DTLS carries a
-- verified HUB_PARTY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_spp_member_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'HEIGHT_FEET'
      - 'HEIGHT_INCHES'
      - 'BMI'
      - 'OTHER_OCC'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  HEIGHT_FEET: 'height_feet'
  HEIGHT_INCHES: 'height_inches'
  BMI: 'bmi'
  OTHER_OCC: 'other_occ'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_SPP_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
