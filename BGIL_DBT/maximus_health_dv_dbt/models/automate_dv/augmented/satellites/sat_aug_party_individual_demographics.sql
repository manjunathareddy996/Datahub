-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_individual_demographics'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BASIC_QUALIFICATION_DESCRIPTION'
  - 'BASIC_QUALIFICATION_ROLL_NUMBER'
  - 'MARRIAGE_ANNIVERSARY_DATE'
  - 'MATRICULATION_QUALIFICATION_INDICATOR'
  - 'MOTHER_MAIDEN_NAME'
  - 'NUMBER_OF_DAUGHTERS'
  - 'NUMBER_OF_SONS'
  - 'OTHER_RELATIONSHIP_DESCRIPTION'
  - 'PERSONAL_DETAILS_DESCRIPTION'
  - 'POSTGRADUATE_QUALIFICATION'
  - 'PROFESSIONAL_QUALIFICATION'
  - 'QUALIFICATION_BOARD_NAME'
  - 'QUALIFICATION_DETAILS'
  - 'RELATIONSHIP_TO_PRIMARY_INSURED'
  - 'UNDERGRADUATE_QUALIFICATION'
  - 'YEAR_OF_PASSING_QUALIFICATION'
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
