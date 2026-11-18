-- automate_dv.stage() for SAT_PARTY_BANKING, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BANK_NAME'
      - 'ACCOUNT_NUMBER_MASKED_CK'
derived_columns:
  PARTY_NK: "case when PARTY_BANKING__BANK_NAME is not null then 'HUB_PARTY|' || PARTY_BK end"
  ACCOUNT_NUMBER_MASKED_CK: 'PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK'
  BANK_NAME: 'PARTY_BANKING__BANK_NAME'
  LOAD_DATETIME: 'PARTY_BANKING__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
