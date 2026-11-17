-- automate_dv.stage() for SAT_AUG_CLAIM_RECOVERY_EXPENSE_LINE, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXPENSE_AMOUNT'
      - 'EXPENSE_HEAD_CODE_CK'
      - 'EXPENSE_HEAD_CK'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  EXPENSE_HEAD_CODE_CK: 'AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK'
  EXPENSE_HEAD_CK: 'AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CK'
  EXPENSE_AMOUNT: 'AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
