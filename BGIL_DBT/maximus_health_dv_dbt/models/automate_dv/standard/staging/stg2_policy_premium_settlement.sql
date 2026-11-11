-- automate_dv.stage() for SAT_POLICY_PREMIUM_SETTLEMENT, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SECTION_64VB_STATUS'
      - 'SETTLEMENT_LINE_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when POLICY_PREMIUM_SETTLEMENT__SECTION_64VB_STATUS is not null then 'HUB_POLICY|' || POLICY_BK end"
  SETTLEMENT_LINE_SEQUENCE_CK: 'POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK'
  SECTION_64VB_STATUS: 'POLICY_PREMIUM_SETTLEMENT__SECTION_64VB_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
