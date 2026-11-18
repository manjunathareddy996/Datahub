-- Standard sat() for SAT_POLICY_EXTERNAL_TP_LINK (parent HUB_POLICY, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__policy_external_tp_link'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'STANDALONE_TP_INDICATOR'
  - 'TP_FINANCE_TYPE'
  - 'TP_POLICY_END_DATE'
  - 'TP_POLICY_START_DATE'
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
