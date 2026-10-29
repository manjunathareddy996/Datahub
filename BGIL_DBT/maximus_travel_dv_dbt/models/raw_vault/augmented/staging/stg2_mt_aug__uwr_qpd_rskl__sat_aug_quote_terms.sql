{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_QUOTE_TERMS from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 11 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_qpd_rskl'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_TERMS:
    is_hashdiff: true
    columns:
      - 'CANCELLATION_PREMIUM_BASIS'
      - 'CHILD_POLICY_PLAN_CODE'
      - 'CO_INSURANCE_INDICATOR'
      - 'CUSTOMISED_PRODUCT_INDICATOR'
      - 'EXCLUDED_COUNTRIES_DESCRIPTION'
      - 'EXCLUDED_COUNTRIES_REMARKS'
      - 'EXCLUDED_EVENTS_DESCRIPTION'
      - 'EXCLUDED_EVENTS_REMARKS'
      - 'JURISDICTION_COUNTRY_CODE'
      - 'MANDATORY_QUESTIONNAIRE_INDICATOR'
      - 'UNDERWRITING_RULES_BYPASSED_INDICATOR'
derived_columns:
  QUOTE_BK: "nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  CANCELLATION_PREMIUM_BASIS: 'cast(null as varchar)'
  CHILD_POLICY_PLAN_CODE: 'cast(null as varchar)'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CUSTOMISED_PRODUCT_INDICATOR: 'cast(null as varchar)'
  EXCLUDED_COUNTRIES_DESCRIPTION: 'cast(null as varchar)'
  EXCLUDED_COUNTRIES_REMARKS: 'cast(null as varchar)'
  EXCLUDED_EVENTS_DESCRIPTION: 'cast(null as varchar)'
  EXCLUDED_EVENTS_REMARKS: 'cast(null as varchar)'
  JURISDICTION_COUNTRY_CODE: 'policy_country'
  MANDATORY_QUESTIONNAIRE_INDICATOR: 'cast(null as varchar)'
  UNDERWRITING_RULES_BYPASSED_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
