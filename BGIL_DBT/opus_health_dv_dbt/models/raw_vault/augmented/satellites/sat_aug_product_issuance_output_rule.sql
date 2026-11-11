-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PRODUCT_ISSUANCE_OUTPUT_RULE (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_v31_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_product_issuance_output_rule'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'AUTOMATIC_ISSUANCE_EMAIL_INDICATOR'
  - 'AUTOMATIC_ISSUANCE_SMS_INDICATOR'
  - 'INTERMEDIARY_EMAIL_SUPPRESSED_INDICATOR'
  - 'INTERMEDIARY_SMS_SUPPRESSED_INDICATOR'
  - 'POLICY_SCHEDULE_PRODUCED_INDICATOR'
  - 'POLICY_SCHEDULE_WORDING_NAME'
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
