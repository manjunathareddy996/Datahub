-- Standard sat() for SAT_COVERAGE_DEFINITION (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_mxm__v07_financial_transaction.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_COVERAGE_DEFINITION | Coverage Name | None: emits COVER_NAME; withheld COVERAGE_NAME
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | SAT_COVERAGE_DEFINITION | Coverage Name | None: emits COVER_NAME; withheld COVERAGE_NAME
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__coverage_definition'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'COVERAGE_DISPLAY_NAME'
  - 'COVERAGE_NAME'
  - 'PERIL_COVERED'
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
