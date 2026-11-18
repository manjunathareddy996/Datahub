-- Standard sat() for SAT_RISK_EXTENDED_WARRANTY (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v10_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_extended_warranty'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'EXTENDED_WARRANTY_END_DATE'
  - 'EXTENDED_WARRANTY_START_DATE'
  - 'OEM_MAKE_REFERENCE'
  - 'OEM_MODEL_REFERENCE'
  - 'WARRANTY_INVOICE_NUMBER'
  - 'WARRANTY_PLAN_CODE'
  - 'WARRANTY_PLAN_NAME'
  - 'WARRANTY_SUM_INSURED'
  - 'WARRANTY_TERM_MONTHS'
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
