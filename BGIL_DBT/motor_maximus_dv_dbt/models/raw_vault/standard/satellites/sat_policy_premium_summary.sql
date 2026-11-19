-- Standard sat() for SAT_POLICY_PREMIUM_SUMMARY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v12_policy.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BASE_PREMIUM'
  - 'GROSS_PREMIUM'
  - 'GST_AMOUNT'
  - 'LOADING_AMOUNT'
  - 'MINIMUM_PREMIUM_APPLIED_INDICATOR'
  - 'NET_PREMIUM'
  - 'PREMIUM_OUTSTANDING'
  - 'REFUND_AMOUNT'
  - 'STAMP_DUTY_AMOUNT'
  - 'TOTAL_PREMIUM_COLLECTED'
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
