-- automate_dv.stage() for SAT_PARTY_CONSENT_MANDATE, read off central view stitch_v16_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MANDATE_STATUS'
derived_columns:
  PARTY_NK: "case when PARTY_CONSENT_MANDATE__MANDATE_STATUS is not null then 'HUB_PARTY|' || PARTY_BK end"
  MANDATE_STATUS: 'PARTY_CONSENT_MANDATE__MANDATE_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
