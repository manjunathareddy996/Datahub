-- automate_dv.stage() for SAT_PROPOSAL_UNDERWRITING, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MEDICAL_REQUIRED_INDICATOR'
derived_columns:
  PROPOSAL_NK: "case when PROPOSAL_UNDERWRITING__MEDICAL_REQUIRED_INDICATOR is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  MEDICAL_REQUIRED_INDICATOR: 'PROPOSAL_UNDERWRITING__MEDICAL_REQUIRED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
