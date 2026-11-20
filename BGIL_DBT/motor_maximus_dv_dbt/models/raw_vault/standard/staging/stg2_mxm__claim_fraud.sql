-- automate_dv.stage() for SAT_CLAIM_FRAUD, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANOMALY_SCORE'
      - 'FRAUD_SCORE'
      - 'FRAUD_TRIGGER_REASON'
      - 'FRAUD_TYPE'
      - 'INVESTIGATION_REFERENCE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_FRAUD__ANOMALY_SCORE, CLAIM_FRAUD__FRAUD_SCORE, CLAIM_FRAUD__FRAUD_TRIGGER_REASON, CLAIM_FRAUD__FRAUD_TYPE, CLAIM_FRAUD__INVESTIGATION_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ANOMALY_SCORE: 'CLAIM_FRAUD__ANOMALY_SCORE'
  FRAUD_SCORE: 'CLAIM_FRAUD__FRAUD_SCORE'
  FRAUD_TRIGGER_REASON: 'CLAIM_FRAUD__FRAUD_TRIGGER_REASON'
  FRAUD_TYPE: 'CLAIM_FRAUD__FRAUD_TYPE'
  INVESTIGATION_REFERENCE: 'CLAIM_FRAUD__INVESTIGATION_REFERENCE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
