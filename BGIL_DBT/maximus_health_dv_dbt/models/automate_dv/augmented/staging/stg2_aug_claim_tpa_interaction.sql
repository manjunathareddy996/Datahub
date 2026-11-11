-- automate_dv.stage() for SAT_AUG_CLAIM_TPA_INTERACTION, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TPA_BILLING_DETAIL'
      - 'TPA_NAME'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_TPA_INTERACTION__TPA_BILLING_DETAIL, AUG_CLAIM_TPA_INTERACTION__TPA_NAME) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  TPA_BILLING_DETAIL: 'AUG_CLAIM_TPA_INTERACTION__TPA_BILLING_DETAIL'
  TPA_NAME: 'AUG_CLAIM_TPA_INTERACTION__TPA_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
