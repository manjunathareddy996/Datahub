-- automate_dv.stage() for SAT_CLAIM_TPA_INTERACTION, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AUTHORISATION_MESSAGE'
      - 'DENIAL_INDICATOR'
      - 'DENIAL_REASON'
      - 'TPA_REFERENCE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_TPA_INTERACTION__AUTHORISATION_MESSAGE, CLAIM_TPA_INTERACTION__DENIAL_INDICATOR, CLAIM_TPA_INTERACTION__DENIAL_REASON, CLAIM_TPA_INTERACTION__TPA_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AUTHORISATION_MESSAGE: 'CLAIM_TPA_INTERACTION__AUTHORISATION_MESSAGE'
  DENIAL_INDICATOR: 'CLAIM_TPA_INTERACTION__DENIAL_INDICATOR'
  DENIAL_REASON: 'CLAIM_TPA_INTERACTION__DENIAL_REASON'
  TPA_REFERENCE: 'CLAIM_TPA_INTERACTION__TPA_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
