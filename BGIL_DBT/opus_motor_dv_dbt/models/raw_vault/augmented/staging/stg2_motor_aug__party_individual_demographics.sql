-- automate_dv.stage() for SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FOUR_WHEELER_OWNED_COUNT'
      - 'TWO_WHEELER_OWNED_COUNT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FOUR_WHEELER_OWNED_COUNT, AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__TWO_WHEELER_OWNED_COUNT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  FOUR_WHEELER_OWNED_COUNT: 'AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FOUR_WHEELER_OWNED_COUNT'
  TWO_WHEELER_OWNED_COUNT: 'AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__TWO_WHEELER_OWNED_COUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
