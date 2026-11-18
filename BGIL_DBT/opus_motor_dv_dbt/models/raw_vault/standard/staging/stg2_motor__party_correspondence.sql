-- automate_dv.stage() for SAT_PARTY_CORRESPONDENCE, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TEMPLATE_REFERENCE'
      - 'DISPATCH_REFERENCE_CK'
derived_columns:
  PARTY_NK: "case when PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE is not null then 'HUB_PARTY|' || PARTY_BK end"
  DISPATCH_REFERENCE_CK: 'PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK'
  TEMPLATE_REFERENCE: 'PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE'
  LOAD_DATETIME: 'PARTY_CORRESPONDENCE__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
