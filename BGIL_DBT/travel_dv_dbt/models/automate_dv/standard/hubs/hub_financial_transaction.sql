{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL hub() for HUB_FINANCIAL_TRANSACTION, 3 contributing table(s) --
-- 2 real transaction IDs plus a degenerate branch (round 2, see the _degenerate.sql stage
-- file header) for the one table with no dedicated transaction ID.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_trv_data_policy_dtls_mv__financial_transaction'
  - 'stg2_hub_bjaz_trv_loader_data_mv__financial_transaction'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__financial_transaction_degenerate'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
