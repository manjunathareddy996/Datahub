-- automate_dv.stage() for SAT_CLAIM_RECOVERY_SALVAGE, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SALVAGE_INDICATOR'
derived_columns:
  CLAIM_NK: "case when CLAIM_RECOVERY_SALVAGE__SALVAGE_INDICATOR is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  SALVAGE_INDICATOR: 'CLAIM_RECOVERY_SALVAGE__SALVAGE_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
