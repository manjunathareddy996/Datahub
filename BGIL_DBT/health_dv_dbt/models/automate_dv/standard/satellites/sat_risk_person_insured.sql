{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_RISK_PERSON_INSURED (HUB_RISK_OBJECT grain) -- stitch-backed, 5 table(s) joined.
-- Source: stg2_risk_person_insured.

{%- set yaml_metadata -%}
source_model: 'stg2_risk_person_insured'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
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
