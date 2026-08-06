{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_risk_person_insured -- serves SAT_RISK_PERSON_INSURED.
-- The ONE place RISK_OBJECT_HK gets hashed for this cluster (namespaced: 'HUB_RISK_OBJECT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_risk_person_insured'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE_AT_ENTRY'
      - 'BODY_MASS_INDEX'
      - 'CRITICAL_ILLNESS_COVER_INDICATOR'
      - 'CUMULATIVE_BONUS_APPLICABLE_INDICATOR'
      - 'FLOATER_INDICATOR'
      - 'HEALTH_CARD_NUMBER'
      - 'HEIGHT'
      - 'INSURED_MEMBER_NAME'
      - 'INSURED_MEMBER_REFERENCE'
      - 'MEMBER_RISK_LOADING_PERCENTAGE'
      - 'MEMBER_TYPE'
      - 'OCCUPATION_RISK_CLASS'
      - 'POLICY_HOLDER_RELATIONSHIP'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'RELATIONSHIP_TO_PROPOSER'
      - 'SMOKER_INDICATOR'
      - 'WEIGHT'
derived_columns:
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
