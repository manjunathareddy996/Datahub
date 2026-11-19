-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_RECOVERY_AMOUNT'
      - 'REINSURANCE_ENDORSEMENT_NUMBER'
      - 'REINSURANCE_EXPIRY_DATE'
      - 'REINSURANCE_PREMIUM_AMOUNT'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_RECOVERY_AMOUNT, AUG_CLAIM_CO_RI_SHARE__REINSURANCE_ENDORSEMENT_NUMBER, AUG_CLAIM_CO_RI_SHARE__REINSURANCE_EXPIRY_DATE, AUG_CLAIM_CO_RI_SHARE__REINSURANCE_PREMIUM_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CO_INSURANCE_RECOVERY_AMOUNT: 'AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_RECOVERY_AMOUNT'
  REINSURANCE_ENDORSEMENT_NUMBER: 'AUG_CLAIM_CO_RI_SHARE__REINSURANCE_ENDORSEMENT_NUMBER'
  REINSURANCE_EXPIRY_DATE: 'AUG_CLAIM_CO_RI_SHARE__REINSURANCE_EXPIRY_DATE'
  REINSURANCE_PREMIUM_AMOUNT: 'AUG_CLAIM_CO_RI_SHARE__REINSURANCE_PREMIUM_AMOUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
