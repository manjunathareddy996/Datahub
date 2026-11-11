-- Standard ma_sat() for SAT_PROPOSAL_MEDICAL_SCHEDULING (parent HUB_PROPOSAL, history Multi-Active SCD2), fed whole from central view stitch_v18_proposal.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_proposal_medical_scheduling'
src_pk: 'PROPOSAL_HKEY'
src_cdk:
  - 'MEMBER_REFERENCE_CK'
  - 'TEST_TYPE_CK'
src_payload:
  - 'REPORT_STATUS'
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
