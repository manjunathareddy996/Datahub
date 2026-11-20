-- Standard sat() for SAT_COVERAGE_MOTOR_PA_OCCUPANT (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_COVERAGE_MOTOR_PA_OCCUPANT | Number Of Persons Covered | None: emits NO_OF_PERSONS; withheld NOP, NUMBER_OF_PERSONS
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | SAT_COVERAGE_MOTOR_PA_OCCUPANT | Number Of Persons Covered | None: emits NO_OF_PERSONS; withheld NOP, NUMBER_OF_PERSONS
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__coverage_motor_pa_occupant'
src_pk:
  - 'COVERAGE_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'NUMBER_OF_PERSONS_COVERED'
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
