-- automate_dv.stage() for SAT_CLAIM_RECOVERY_SALVAGE, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RECOVERY_EXPENSE'
      - 'SALVAGE_DISPOSAL_METHOD'
      - 'SALVAGE_REALISED_AMOUNT'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_RECOVERY_SALVAGE__RECOVERY_EXPENSE, CLAIM_RECOVERY_SALVAGE__SALVAGE_DISPOSAL_METHOD, CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  RECOVERY_EXPENSE: 'CLAIM_RECOVERY_SALVAGE__RECOVERY_EXPENSE'
  SALVAGE_DISPOSAL_METHOD: 'CLAIM_RECOVERY_SALVAGE__SALVAGE_DISPOSAL_METHOD'
  SALVAGE_REALISED_AMOUNT: 'CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISED_AMOUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
