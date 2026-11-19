-- automate_dv.stage() over central view stitch_mxm__v10_party: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v10_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
derived_columns:
  DISTRIBUTION_CHANNEL_BK: 'DISTRIBUTION_CHANNEL_BK'
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
