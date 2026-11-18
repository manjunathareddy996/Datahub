-- automate_dv.stage() for SAT_LNK_ROLE_NOMINEE_BENEFICIARY, read off central view stitch_motor__v07_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v07_location'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPOINTEE_NAME'
      - 'RELATIONSHIP_TO_INSURED'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME, LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK'
  APPOINTEE_NAME: 'LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME'
  RELATIONSHIP_TO_INSURED: 'LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED'
  LOAD_DATETIME: 'LNK_ROLE_NOMINEE_BENEFICIARY__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v07_location'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
