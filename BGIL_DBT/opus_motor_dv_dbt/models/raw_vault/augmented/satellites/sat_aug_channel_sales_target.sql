-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CHANNEL_SALES_TARGET (parent HUB_DISTRIBUTION_CHANNEL, history SCD2), fed whole from central view stitch_motor__v09_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__channel_sales_target'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
src_cdk:
  - 'TARGET_PERIOD_CK'
  - 'TARGET_TYPE_CK'
src_payload:
  - 'BORROWED_AMOUNT_BRANCH_OFFICE'
  - 'BORROWED_AMOUNT_ZONAL_HEAD'
  - 'BUDGETED_OWN_DAMAGE_PREMIUM'
  - 'BUDGET_AMOUNT_BRANCH_OFFICE'
  - 'BUDGET_AMOUNT_ZONAL_HEAD'
  - 'BUDGET_REFERENCE'
  - 'CARRIED_FORWARD_AMOUNT_BRANCH_OFFICE'
  - 'CARRIED_FORWARD_AMOUNT_ZONAL_HEAD'
  - 'PORTFOLIO_GROUP_CODE'
  - 'RENEWAL_TYPE'
  - 'TARGET_YEAR'
  - 'UTILISED_AMOUNT_BRANCH_OFFICE'
  - 'UTILISED_AMOUNT_ZONAL_HEAD'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
