-- automate_dv.stage() for SAT_AUG_PARTY_BENEFICIARY_LINE, read off central view stitch_v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BENEFICIARY_NAME'
      - 'BENEFICIARY_PARTY_CODE'
      - 'BENEFICIARY_SEQUENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_NAME, AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_PARTY_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  BENEFICIARY_SEQUENCE_CK: 'AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_SEQUENCE_CK'
  BENEFICIARY_NAME: 'AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_NAME'
  BENEFICIARY_PARTY_CODE: 'AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_PARTY_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
