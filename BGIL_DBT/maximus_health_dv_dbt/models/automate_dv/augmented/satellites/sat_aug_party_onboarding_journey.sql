-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PARTY_ONBOARDING_JOURNEY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_onboarding_journey'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'APPLICATION_REJECTION_REASON'
  - 'CANDIDATE_BACKGROUND_DESCRIPTION'
  - 'EXISTING_PARTY_SEARCH_INDICATOR'
  - 'PREVIOUS_EMPLOYER_LOCATION'
  - 'PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE'
  - 'PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE'
  - 'PREVIOUS_NON_GENERAL_INSURER_NAME'
  - 'REASON_FOR_LEAVING_PREVIOUS_EMPLOYER'
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
