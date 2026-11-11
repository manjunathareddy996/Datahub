-- Standard sat() for SAT_RISK_PERSON_INSURED (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_v34_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_risk_person_insured'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'BODY_MASS_INDEX'
  - 'HEALTH_CARD_NUMBER'
  - 'HEIGHT'
  - 'MEMBER_RISK_LOADING_PERCENTAGE'
  - 'PRE_EXISTING_DISEASE_DESCRIPTION'
  - 'RELATIONSHIP_TO_PROPOSER'
  - 'SMOKER_INDICATOR'
  - 'WEIGHT'
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
