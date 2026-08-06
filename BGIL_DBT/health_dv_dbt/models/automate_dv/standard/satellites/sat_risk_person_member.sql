{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_RISK_PERSON_MEMBER (HUB_RISK_OBJECT grain) -- union of 2 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_prod_8428_gpg_loader__risk_person_member'
  - 'stg2_sat_ba_hcp_prod_8433_fhc_loader__risk_person_member'
src_pk: 'RISK_OBJECT_HK'
src_cdk:
  - 'MEMBER_SEQUENCE_CK'
src_payload:
  - 'RELATIONSHIP_TO_PROPOSER'
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
