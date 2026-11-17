-- automate_dv.stage() for SAT_AUG_RISK_OBJECT_INSURABLE_INTEREST, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINANCIER_BRANCH_NAME'
      - 'INTEREST_TYPE_CK'
      - 'INTEREST_HOLDER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_BRANCH_NAME is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  INTEREST_TYPE_CK: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK'
  INTEREST_HOLDER_REFERENCE_CK: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK'
  FINANCIER_BRANCH_NAME: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_BRANCH_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
