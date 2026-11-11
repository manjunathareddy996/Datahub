-- automate_dv.stage() for SAT_AUG_CLAIM_SETTLEMENT, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAYOUT_REASON'
      - 'PENAL_INTEREST_APPLICABLE_INDICATOR'
      - 'PENAL_INTEREST_PAYABLE_INDICATOR'
      - 'SETTLEMENT_DELAY_DAYS'
      - 'SETTLEMENT_DELAY_REASON'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SETTLEMENT__PAYOUT_REASON, AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_APPLICABLE_INDICATOR, AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_PAYABLE_INDICATOR, AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_DAYS, AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_REASON) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  PAYOUT_REASON: 'AUG_CLAIM_SETTLEMENT__PAYOUT_REASON'
  PENAL_INTEREST_APPLICABLE_INDICATOR: 'AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_APPLICABLE_INDICATOR'
  PENAL_INTEREST_PAYABLE_INDICATOR: 'AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_PAYABLE_INDICATOR'
  SETTLEMENT_DELAY_DAYS: 'AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_DAYS'
  SETTLEMENT_DELAY_REASON: 'AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
