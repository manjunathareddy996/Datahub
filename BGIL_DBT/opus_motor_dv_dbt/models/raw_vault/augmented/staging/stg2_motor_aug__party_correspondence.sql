-- automate_dv.stage() for SAT_AUG_PARTY_CORRESPONDENCE, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMUNICATION_REQUEST_TIMESTAMP'
      - 'COMMUNICATION_SCHEDULED_INDICATOR'
      - 'DISPATCH_REFERENCE_CK'
      - 'DISPATCH_CHANNEL_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP, AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  DISPATCH_REFERENCE_CK: 'AUG_PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK'
  DISPATCH_CHANNEL_CK: 'AUG_PARTY_CORRESPONDENCE__DISPATCH_CHANNEL_CK'
  COMMUNICATION_REQUEST_TIMESTAMP: 'AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP'
  COMMUNICATION_SCHEDULED_INDICATOR: 'AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR'
  LOAD_DATETIME: 'AUG_PARTY_CORRESPONDENCE__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
