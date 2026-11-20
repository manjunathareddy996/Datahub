-- Standard sat() for SAT_POLICY_TAX_BREAKUP (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v12_policy.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_POLICY_TAX_BREAKUP | CGST Amount | None: emits CGST_AMOUNT; withheld CGST
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_tax_breakup'
src_pk:
  - 'POLICY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CGST_AMOUNT'
  - 'CGST_RATE'
  - 'GST_RATE'
  - 'IGST_AMOUNT'
  - 'PLACE_OF_SUPPLY'
  - 'SGST_AMOUNT'
  - 'SUPPLIER_STATE_CODE'
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
