-- Standard sat() for SAT_ASSESSMENT_RISK_SCORING (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_v16_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_assessment_risk_scoring'
src_pk: 'ASSESSMENT_HKEY'
src_payload:
  - 'SCORE_BAND'
  - 'SCORE_VALUE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
