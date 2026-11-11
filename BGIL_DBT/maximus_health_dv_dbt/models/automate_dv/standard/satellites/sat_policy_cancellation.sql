-- Standard sat() for SAT_POLICY_CANCELLATION (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v16_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_cancellation'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CANCELLATION_DATE'
  - 'CANCELLATION_EFFECTIVE_DATE'
  - 'CANCELLATION_REASON'
  - 'CANCELLATION_TYPE'
  - 'REFUND_AMOUNT'
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
