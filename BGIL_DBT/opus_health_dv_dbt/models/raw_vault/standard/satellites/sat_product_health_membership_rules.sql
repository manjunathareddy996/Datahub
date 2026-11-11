-- Standard sat() for SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_v31_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_product_health_membership_rules'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'DOB_VALIDATION_RULE'
  - 'MEMBER_BACKDATING_LIMIT_DAYS'
  - 'MEMBER_BULK_UPLOAD_ALLOWED_INDICATOR'
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
