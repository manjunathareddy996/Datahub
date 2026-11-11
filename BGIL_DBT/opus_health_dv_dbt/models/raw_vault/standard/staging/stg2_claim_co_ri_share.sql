-- automate_dv.stage() for SAT_CLAIM_CO_RI_SHARE, read off central view stitch_v09_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_OUR_SHARE_AMOUNT'
derived_columns:
  CLAIM_NK: "case when CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_AMOUNT is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CO_INSURANCE_OUR_SHARE_AMOUNT: 'CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
