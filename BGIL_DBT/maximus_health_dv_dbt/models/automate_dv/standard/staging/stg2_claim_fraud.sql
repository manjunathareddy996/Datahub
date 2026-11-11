-- automate_dv.stage() for SAT_CLAIM_FRAUD, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FRAUD_SCORE'
      - 'FRAUD_SUSPICION_INDICATOR'
      - 'FRAUD_TRIGGER_REASON'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_FRAUD__FRAUD_SCORE, CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR, CLAIM_FRAUD__FRAUD_TRIGGER_REASON) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  FRAUD_SCORE: 'CLAIM_FRAUD__FRAUD_SCORE'
  FRAUD_SUSPICION_INDICATOR: 'CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR'
  FRAUD_TRIGGER_REASON: 'CLAIM_FRAUD__FRAUD_TRIGGER_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
