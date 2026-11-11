-- automate_dv.stage() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MARITAL_STATUS'
derived_columns:
  PARTY_NK: "case when PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS is not null then 'HUB_PARTY|' || PARTY_BK end"
  MARITAL_STATUS: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
