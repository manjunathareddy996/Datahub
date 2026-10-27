{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_FIN_RECEIPT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_sp_pv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM: 'FINANCIAL_TRANSACTION_NK__POLICY_PREMIUM'
  HASHDIFF_FIN_RECEIPT:
    is_hashdiff: true
    columns:
      - 'COLLECTION_DATE'
      - 'PORTAL_PAYMENT_MODE_CODE'
derived_columns:
  FINANCIAL_TRANSACTION_BK__POLICY_PREMIUM: "nullif(trim(case when coalesce(nullif(trim(w1_policy_number),''), nullif(trim(foreign_key),'')) is not null then 'POLPREM:' || coalesce(nullif(trim(w1_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  FINANCIAL_TRANSACTION_NK__POLICY_PREMIUM: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(w1_policy_number),''), nullif(trim(foreign_key),'')) is not null then 'POLPREM:' || coalesce(nullif(trim(w1_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  COLLECTION_DATE: 'cast(null as varchar)'
  PORTAL_PAYMENT_MODE_CODE: 'portal_payment_mode'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
