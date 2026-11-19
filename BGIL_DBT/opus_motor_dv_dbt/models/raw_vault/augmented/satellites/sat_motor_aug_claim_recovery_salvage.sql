-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_RECOVERY_SALVAGE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_recovery_salvage'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'BENCHMARK_AVERAGE_SOLD_AMOUNT'
  - 'BENCHMARK_HIGHEST_SOLD_AMOUNT'
  - 'BEST_SALVAGE_QUOTATION_AMOUNT'
  - 'INDEMNITY_BOND_INDICATOR'
  - 'OTHER_DEDUCTION_AMOUNT'
  - 'RECOVERED_VEHICLE_CONDITION'
  - 'RECOVERY_POLICE_STATION_NAME'
  - 'RECOVERY_TYPE'
  - 'SALVAGE_AUCTION_REFERENCE'
  - 'SALVAGE_BIDDING_END_DATE'
  - 'SALVAGE_BIDDING_START_DATE'
  - 'SALVAGE_PROCEEDS_INSTRUMENT_DATE'
  - 'SALVAGE_PROCEEDS_INSTRUMENT_DETAILS'
  - 'SALVAGE_PROCEEDS_PAYMENT_MODE'
  - 'SALVAGE_PROCEEDS_RECEIPT_DATE'
  - 'SALVAGE_PROCEEDS_RECEIPT_DETAILS'
  - 'SALVAGE_REALISATION_PERCENTAGE'
  - 'SALVAGE_RETAINED_BY_INSURED_INDICATOR'
  - 'SALVAGE_TRANSACTION_YEAR'
  - 'SALVAGE_TYPE'
  - 'SCRAP_DISPOSAL_INDICATOR'
  - 'VEHICLE_RECOVERY_DATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
