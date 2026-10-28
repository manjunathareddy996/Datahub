{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_RISK_LINE from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 5 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_RISK_LINE:
    is_hashdiff: true
    columns:
      - 'BILLING_STAKE_CODE'
      - 'DISCOUNT_AMOUNT'
      - 'LOADING_AMOUNT'
      - 'RISK_EXPIRY_DATE'
      - 'RISK_INCEPTION_DATE'
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  BILLING_STAKE_CODE: 'billing_stake'
  DISCOUNT_AMOUNT: 'discount'
  LOADING_AMOUNT: 'loading'
  RISK_EXPIRY_DATE: 'risk_expiry_date'
  RISK_INCEPTION_DATE: 'risk_inception_date'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
