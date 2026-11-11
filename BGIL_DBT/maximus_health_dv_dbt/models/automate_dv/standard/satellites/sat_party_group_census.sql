-- Standard ma_sat() for SAT_PARTY_GROUP_CENSUS (parent HUB_PARTY, history Multi-Active SCD2), fed whole from central view stitch_v12_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_party_group_census'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'MEMBER_REFERENCE_CK'
src_payload:
  - 'DESIGNATION_BAND'
  - 'EMPLOYEE_ID'
  - 'EXIT_DATE'
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
