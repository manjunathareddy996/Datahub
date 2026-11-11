-- automate_dv.stage() for SAT_LNK_ROLE_PROVIDER, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BED_COUNT'
      - 'EMPANELMENT_STATUS'
      - 'MOU_STATUS'
      - 'PROVIDER_TYPE'
      - 'SERVICE_REGION'
      - 'SUSPENSION_INDICATOR'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_ROLE_PROVIDER__BED_COUNT, LNK_ROLE_PROVIDER__EMPANELMENT_STATUS, LNK_ROLE_PROVIDER__MOU_STATUS, LNK_ROLE_PROVIDER__PROVIDER_TYPE, LNK_ROLE_PROVIDER__SERVICE_REGION, LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_PROVIDER__ROLE_TYPE_CK'
  BED_COUNT: 'LNK_ROLE_PROVIDER__BED_COUNT'
  EMPANELMENT_STATUS: 'LNK_ROLE_PROVIDER__EMPANELMENT_STATUS'
  MOU_STATUS: 'LNK_ROLE_PROVIDER__MOU_STATUS'
  PROVIDER_TYPE: 'LNK_ROLE_PROVIDER__PROVIDER_TYPE'
  SERVICE_REGION: 'LNK_ROLE_PROVIDER__SERVICE_REGION'
  SUSPENSION_INDICATOR: 'LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
