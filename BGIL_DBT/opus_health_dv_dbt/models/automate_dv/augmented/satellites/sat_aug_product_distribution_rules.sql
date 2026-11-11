-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PRODUCT_DISTRIBUTION_RULES (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_v31_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_product_distribution_rules'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'AUTHORISED_SUB_INTERMEDIARY_CODE_SET'
  - 'BACKDATING_AUTHORISED_INTERMEDIARY_CODE_SET'
  - 'GENERIC_SMS_INTERMEDIARY_CODE_SET'
  - 'INTERMEDIARY_BACKDATING_VALIDATION_REQUIRED_INDICATOR'
  - 'INTERMEDIARY_CODE_VALIDATION_REQUIRED_INDICATOR'
  - 'NEW_BUSINESS_BLOCKED_INDICATOR'
  - 'PLAN_SPECIFIC_SMS_INTERMEDIARY_CODE_SET'
  - 'SUB_INTERMEDIARY_CODE_VALIDATION_REQUIRED_INDICATOR'
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
