{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_FIN_RECEIPT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__uwr_pol_policy_payment_information'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF_FIN_RECEIPT:
    is_hashdiff: true
    columns:
      - 'COLLECTION_DATE'
      - 'PORTAL_PAYMENT_MODE_CODE'
derived_columns:
  FINANCIAL_TRANSACTION_BK: "nullif(trim(case when coalesce(nullif(trim(transaction_id),'')) is not null then nullif(trim(transaction_id), '') end),'')"
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(transaction_id),'')) is not null then nullif(trim(transaction_id), '') end),''))"
  COLLECTION_DATE: 'collection_date'
  PORTAL_PAYMENT_MODE_CODE: 'cast(null as varchar)'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
