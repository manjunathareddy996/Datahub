-- automate_dv.stage() for SAT_LEAD_ATTRIBUTION, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LEAD_REFERENCE'
      - 'PARAMETER_VALUE'
      - 'ATTRIBUTION_PARAMETER_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LEAD_ATTRIBUTION__LEAD_REFERENCE, LEAD_ATTRIBUTION__PARAMETER_VALUE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ATTRIBUTION_PARAMETER_CK: 'LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK'
  LEAD_REFERENCE: 'LEAD_ATTRIBUTION__LEAD_REFERENCE'
  PARAMETER_VALUE: 'LEAD_ATTRIBUTION__PARAMETER_VALUE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
