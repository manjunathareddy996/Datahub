{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_FINTXN_PREMIUM.
-- data_7 sync (MAPPER_NOTE_TRAVEL_DATA7_SYNC.md): DISCOUNT_PERCENTAGE (from DISCOUNT_PER)
-- folded out of here into canonical SAT_FINTXN_PREMIUM -- data_7 canonicalised standard
-- discount, not special discount, so SPECIAL_DISCOUNT_AMOUNT/PERCENTAGE stay here.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_fintxn_premium_ba_trv_data_policy_dtls_mv_sp_discount_per'
  - 'stg2_aug_fintxn_premium_ba_trv_data_policy_dtls_mv_sp_discount_amt'
  - 'stg2_aug_fintxn_premium_bjaz_trv_loader_data_mv_spdiscount'
  - 'stg2_aug_fintxn_premium_bjaz_trv_loader_log_table_mv_spdiscount'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'SPECIAL_DISCOUNT_AMOUNT'
  - 'SPECIAL_DISCOUNT_PERCENTAGE'
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
