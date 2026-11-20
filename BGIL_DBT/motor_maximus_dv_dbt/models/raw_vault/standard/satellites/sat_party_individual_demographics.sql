-- Standard sat() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v10_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS | Educational Qualification | None: emits EDUCATIONAL_QUALIFICATION; withheld EDUCATION
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__party_individual_demographics'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'EDUCATIONAL_QUALIFICATION'
  - 'FATHER_NAME'
  - 'HIGHEST_DEGREE'
  - 'INCOME_BAND'
  - 'MARITAL_STATUS'
  - 'OCCUPATION_CODE'
  - 'OCCUPATION_DESCRIPTION'
  - 'SPOUSE_NAME'
  - 'VEHICLE_OWNED_INDICATOR'
  - 'YEARS_IN_CITY'
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
