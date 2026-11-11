-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PRODUCT_TERMS (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_v32_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_product_terms'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'AT_LEAST_ONE_COVERAGE_MANDATORY_INDICATOR'
  - 'AUTO_DEBIT_ALLOWED_INDICATOR'
  - 'AUTO_RENEWAL_INDICATOR'
  - 'CONFIGURED_MEMBER_COUNT'
  - 'FAMILY_FLOATER_INDICATOR'
  - 'MULTIPLE_MANDATORY_COVERAGE_SELECTION_BLOCKED_INDICATOR'
  - 'NEW_BUSINESS_ADVANCE_ISSUANCE_DAYS'
  - 'PORT_IN_BLOCKED_INDICATOR'
  - 'RENEWAL_ADVANCE_ISSUANCE_DAYS'
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
