-- automate_dv.stage() for SAT_LNK_ROLE_CUSTOMER, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BLACKLIST_INDICATOR'
      - 'BLACKLIST_REASON'
      - 'CONSENT_FOR_DATA_SHARING_INDICATOR'
      - 'VIP_INDICATOR'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR, LNK_ROLE_CUSTOMER__BLACKLIST_REASON, LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR, LNK_ROLE_CUSTOMER__VIP_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_CUSTOMER__ROLE_TYPE_CK'
  BLACKLIST_INDICATOR: 'LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR'
  BLACKLIST_REASON: 'LNK_ROLE_CUSTOMER__BLACKLIST_REASON'
  CONSENT_FOR_DATA_SHARING_INDICATOR: 'LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR'
  VIP_INDICATOR: 'LNK_ROLE_CUSTOMER__VIP_INDICATOR'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
