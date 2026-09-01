{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_RISK_PERSON_INSURED (parent HUB_RISK_OBJECT).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_risk_person_insured_bjaz_trv_loader_data_mv_member1'
  - 'stg2_risk_person_insured_bjaz_trv_loader_data_mv_member2'
  - 'stg2_risk_person_insured_bjaz_trv_loader_data_mv_member3'
  - 'stg2_risk_person_insured_bjaz_trv_loader_data_mv_member4'
  - 'stg2_risk_person_insured_bjaz_trv_loader_data_mv_member5'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'GENDER'
  - 'INSURED_MEMBER_NAME'
  - 'PRE_EXISTING_DISEASE_DESCRIPTION'
  - 'RELATIONSHIP_TO_PROPOSER'
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
