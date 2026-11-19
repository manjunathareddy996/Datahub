-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_CONTACT_ADDRESS_LINK, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SAME_AS_PRIMARY_ADDRESS_INDICATOR'
      - 'ADDRESS_USAGE_TYPE_CK'
derived_columns:
  PARTY_LOCATION_NK: "case when AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR is not null then 'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK end"
  ADDRESS_USAGE_TYPE_CK: 'AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK'
  SAME_AS_PRIMARY_ADDRESS_INDICATOR: 'AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR'
  LOAD_DATETIME: 'LOCATION_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
