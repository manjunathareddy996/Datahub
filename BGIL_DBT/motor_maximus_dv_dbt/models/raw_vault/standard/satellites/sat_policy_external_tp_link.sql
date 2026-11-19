-- Standard sat() for SAT_POLICY_EXTERNAL_TP_LINK (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_external_tp_link'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'EXTERNAL_TP_POLICY_INDICATOR'
  - 'TP_INSURER_NAME'
  - 'TP_POLICY_END_DATE'
  - 'TP_POLICY_NUMBER'
  - 'TP_POLICY_START_DATE'
  - 'TP_TENURE_YEARS'
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
