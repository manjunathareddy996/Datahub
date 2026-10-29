{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
-- Covers this view's 2 key slot(s) and its 4 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   FINANCIAL_TRANSACTION_HKEY         HUB_FINANCIAL_TRANSACTION  (11 row(s) in the map)
--   PAYMENT_INSTRUMENT_HKEY            HUB_PAYMENT_INSTRUMENT  (2 row(s) in the map)
--   HASHDIFF_FINTXN_HEADER             SAT_FINTXN_HEADER payload 3 of 7 live here
--   HASHDIFF_FINTXN_PREMIUM            SAT_FINTXN_PREMIUM payload 1 of 1 live here
--   HASHDIFF_FIN_RECEIPT               SAT_FIN_RECEIPT payload 5 of 6 live here
--   HASHDIFF_INSTRUMENT_DEFINITION     SAT_INSTRUMENT_DEFINITION payload 1 of 5 live here

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__uwr_pol_policy_payment_information'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  HASHDIFF_FINTXN_HEADER:
    is_hashdiff: true
    columns:
      - 'ORG_UNIT_CODE'
      - 'SOURCE_REFERENCE_NUMBER'
      - 'SOURCE_REFERENCE_TYPE'
      - 'TRANSACTION_CHANNEL'
      - 'TRANSACTION_DATE'
      - 'TRANSACTION_NUMBER'
      - 'TRANSACTION_TYPE'
  HASHDIFF_FINTXN_PREMIUM:
    is_hashdiff: true
    columns:
      - 'COLLECTION_MODE'
  HASHDIFF_FIN_RECEIPT:
    is_hashdiff: true
    columns:
      - 'AMOUNT_RECEIVED'
      - 'PAYMENT_GATEWAY_REFERENCE'
      - 'REALISATION_DATE'
      - 'RECEIPT_DATE'
      - 'RECEIPT_NUMBER'
      - 'RECEIPT_TYPE'
  HASHDIFF_INSTRUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_CATEGORY_CODE'
      - 'ACCOUNT_TYPE'
      - 'BANK_BRANCH_CODE'
      - 'BANK_NAME'
      - 'INSTRUMENT_STATUS'
derived_columns:
  FINANCIAL_TRANSACTION_BK: "nullif(trim(case when coalesce(nullif(trim(transaction_id),'')) is not null then nullif(trim(transaction_id), '') end),'')"
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(transaction_id),'')) is not null then nullif(trim(transaction_id), '') end),''))"
  PAYMENT_INSTRUMENT_BK: "nullif(trim(case when coalesce(nullif(trim(cheque_number),'')) is not null then 'CHEQUE:' || nullif(trim(cheque_number), '') end),'')"
  PAYMENT_INSTRUMENT_NK: "'HUB_PAYMENT_INSTRUMENT|' || (nullif(trim(case when coalesce(nullif(trim(cheque_number),'')) is not null then 'CHEQUE:' || nullif(trim(cheque_number), '') end),''))"
  ACCOUNT_TYPE: 'cast(null as varchar)'
  AMOUNT_RECEIVED: 'collection_amount'
  BANK_NAME: 'cast(null as varchar)'
  COLLECTION_MODE: 'collection_mode'
  INSTRUMENT_STATUS: 'cheque_status'
  ORG_UNIT_CODE: 'sub_code'
  PAYMENT_GATEWAY_REFERENCE: 'cast(null as varchar)'
  REALISATION_DATE: 'cheque_realisation_date'
  RECEIPT_DATE: 'receipt_generation_date'
  RECEIPT_NUMBER: 'receipt_number'
  RECEIPT_TYPE: 'collection_type'
  SOURCE_REFERENCE_NUMBER: 'cast(null as varchar)'
  SOURCE_REFERENCE_TYPE: 'cast(null as varchar)'
  TRANSACTION_CHANNEL: 'collection_source'
  TRANSACTION_DATE: 'transaction_date'
  TRANSACTION_NUMBER: 'cast(null as varchar)'
  TRANSACTION_TYPE: 'cast(null as varchar)'
  ACCOUNT_CATEGORY_CODE: 'cast(null as varchar)'
  BANK_BRANCH_CODE: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
