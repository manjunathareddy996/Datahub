-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_DIGITAL_JOURNEY_STAGE, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STAGE_REACHED_INDICATOR'
      - 'JOURNEY_STAGE_CODE_CK'
      - 'JOURNEY_STAGE_CK'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR is not null then 'HUB_PARTY|' || PARTY_BK end"
  JOURNEY_STAGE_CODE_CK: 'AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CODE_CK'
  JOURNEY_STAGE_CK: 'AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK'
  STAGE_REACHED_INDICATOR: 'AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
