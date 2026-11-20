-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_PAYMENT_TRANCHE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAYMENT_CONFIRMED_INDICATOR'
      - 'TRANCHE_NUMBER_CK'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  TRANCHE_NUMBER_CK: 'AUG_CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK'
  PAYMENT_CONFIRMED_INDICATOR: 'AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
