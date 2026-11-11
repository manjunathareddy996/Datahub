-- Standard ma_sat() for SAT_POLICY_TENURE_SCHEDULE (parent HUB_POLICY, history Multi-Active SCD2), fed whole from central view stitch_v16_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_tenure_schedule'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'TENURE_SEQUENCE_CK'
src_payload:
  - 'TENURE_END_DATE'
  - 'TENURE_START_DATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
