-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_MARKETING, read off central view stitch_mxm__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AA_MEMBERSHIP_NUMBER'
      - 'BANCASSURANCE_CUSTOMER_TYPE'
      - 'CROSS_SELL_REFERENCE_NUMBER'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_MARKETING__AA_MEMBERSHIP_NUMBER, AUG_PARTY_MARKETING__BANCASSURANCE_CUSTOMER_TYPE, AUG_PARTY_MARKETING__CROSS_SELL_REFERENCE_NUMBER) is not null then 'HUB_PARTY|' || PARTY_BK end"
  AA_MEMBERSHIP_NUMBER: 'AUG_PARTY_MARKETING__AA_MEMBERSHIP_NUMBER'
  BANCASSURANCE_CUSTOMER_TYPE: 'AUG_PARTY_MARKETING__BANCASSURANCE_CUSTOMER_TYPE'
  CROSS_SELL_REFERENCE_NUMBER: 'AUG_PARTY_MARKETING__CROSS_SELL_REFERENCE_NUMBER'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
