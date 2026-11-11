-- automate_dv.stage() for SAT_PARTY_CLAIM_HISTORY, read off central view stitch_v20_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v20_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TOTAL_CLAIM_AMOUNT'
      - 'TOTAL_CLAIM_COUNT'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT, PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  TOTAL_CLAIM_AMOUNT: 'PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT'
  TOTAL_CLAIM_COUNT: 'PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v20_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
