{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_party_identity -- serves SAT_PARTY_IDENTITY.
-- The ONE place PARTY_HK gets hashed for this cluster (namespaced: 'HUB_PARTY|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_party_identity'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'DATE_OF_BIRTH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'PARTY_DISPLAY_NAME'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_STATUS'
      - 'PARTY_STATUS_REASON'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
