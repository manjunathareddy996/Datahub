{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_AGREEMENT_CHANNEL: hub keys and the link key, hashed off stitch_travel__lnk_agreement_channel.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_agreement_channel'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  AGREEMENT_CHANNEL_HKEY: 'AGREEMENT_CHANNEL_NK'
derived_columns:
  AGREEMENT_NK: "'HUB_AGREEMENT|' || AGREEMENT_BK"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK"
  AGREEMENT_CHANNEL_NK: "'LNK_AGREEMENT_CHANNEL|' || AGREEMENT_BK || '|' || DISTRIBUTION_CHANNEL_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
