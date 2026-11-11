-- automate_dv.stage() for SAT_AUG_AGREEMENT_DEFINITION, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COST_NEGOTIATED_INDICATOR'
      - 'EMPANELMENT_SUPPORT_DATE'
derived_columns:
  AGREEMENT_NK: "case when coalesce(AUG_AGREEMENT_DEFINITION__COST_NEGOTIATED_INDICATOR, AUG_AGREEMENT_DEFINITION__EMPANELMENT_SUPPORT_DATE) is not null then 'HUB_AGREEMENT|' || AGREEMENT_BK end"
  COST_NEGOTIATED_INDICATOR: 'AUG_AGREEMENT_DEFINITION__COST_NEGOTIATED_INDICATOR'
  EMPANELMENT_SUPPORT_DATE: 'AUG_AGREEMENT_DEFINITION__EMPANELMENT_SUPPORT_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
