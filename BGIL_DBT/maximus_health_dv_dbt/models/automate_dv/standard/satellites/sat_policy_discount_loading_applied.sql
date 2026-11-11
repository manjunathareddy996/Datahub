-- Standard ma_sat() for SAT_POLICY_DISCOUNT_LOADING_APPLIED (parent HUB_POLICY, history Multi-Active SCD2), fed whole from central view stitch_v17_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_discount_loading_applied'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'ITEM_CODE_CK'
src_payload:
  - 'AMOUNT_APPLIED'
  - 'BASIS'
  - 'EXTRA_DISCOUNT_OPTED_INDICATOR'
  - 'ITEM_CODE'
  - 'ITEM_TYPE'
  - 'JUSTIFICATION'
  - 'PERCENTAGE_APPLIED'
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
