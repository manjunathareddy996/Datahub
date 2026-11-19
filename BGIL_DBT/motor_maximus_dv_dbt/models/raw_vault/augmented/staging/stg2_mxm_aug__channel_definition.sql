-- automate_dv.stage() for SAT_MOTOR_AUG_CHANNEL_DEFINITION, read off central view stitch_mxm__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v10_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NATIONAL_TIE_UP_DETAIL_TEXT'
      - 'SOLICITATION_TYPE'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when coalesce(AUG_CHANNEL_DEFINITION__NATIONAL_TIE_UP_DETAIL_TEXT, AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE) is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  NATIONAL_TIE_UP_DETAIL_TEXT: 'AUG_CHANNEL_DEFINITION__NATIONAL_TIE_UP_DETAIL_TEXT'
  SOLICITATION_TYPE: 'AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
