{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
-- Covers this view's 7 key slot(s) and its 4 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   DOCUMENT_HKEY                      HUB_DOCUMENT  (1 row(s) in the map)
--   FINANCIAL_TRANSACTION_HKEY__QUOTE_RISK_PREMIUM HUB_FINANCIAL_TRANSACTION / quote-risk-premium  (2 row(s) in the map)
--   LOCATION_HKEY                      HUB_LOCATION  (7 row(s) in the map)
--   PARTY_HKEY                         HUB_PARTY  (1 row(s) in the map)
--   PARTY_HKEY__ADDITIONAL_PARTY       HUB_PARTY / additional-party  (1 row(s) in the map)
--   QUOTE_HKEY                         HUB_QUOTE  (7 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (5 row(s) in the map)
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 7 of 16 live here
--   HASHDIFF_COMMON_MONETARY_CONTEXT   SAT_COMMON_MONETARY_CONTEXT payload 2 of 4 live here
--   HASHDIFF_RISK_OBJECT_CORE          SAT_RISK_OBJECT_CORE payload 3 of 6 live here
--   HASHDIFF_RISK_OBJECT_VALUATION     SAT_RISK_OBJECT_VALUATION payload 1 of 3 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_qpd_rskl'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  FINANCIAL_TRANSACTION_HKEY__QUOTE_RISK_PREMIUM: 'FINANCIAL_TRANSACTION_NK__QUOTE_RISK_PREMIUM'
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  PARTY_HKEY__ADDITIONAL_PARTY: 'PARTY_NK__ADDITIONAL_PARTY'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'ADDRESS_TYPE_CODE'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
  HASHDIFF_COMMON_MONETARY_CONTEXT:
    is_hashdiff: true
    columns:
      - 'BASE_CURRENCY_CODE'
      - 'BASE_CURRENCY_EXCHANGE_RATE'
      - 'CURRENCY_CODE'
      - 'EXCHANGE_RATE'
  HASHDIFF_RISK_OBJECT_CORE:
    is_hashdiff: true
    columns:
      - 'EXPOSURE_QUANTITY'
      - 'EXPOSURE_UNIT'
      - 'RISK_CLASS_CODE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
      - 'RISK_OBJECT_TYPE'
  HASHDIFF_RISK_OBJECT_VALUATION:
    is_hashdiff: true
    columns:
      - 'INSURED_VALUE'
      - 'INSURED_VALUE_IN_SUM_INSURED_CURRENCY'
      - 'INSURED_VALUE_IN_TRANSACTION_CURRENCY'
derived_columns:
  DOCUMENT_BK: "nullif(trim(case when nullif(trim(document_id),'') is not null then 'DOC:' || nullif(trim(document_id), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when nullif(trim(document_id),'') is not null then 'DOC:' || nullif(trim(document_id), '') end),''))"
  FINANCIAL_TRANSACTION_BK__QUOTE_RISK_PREMIUM: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(pol_risk_id),'')) is not null then 'QUOTEPREM:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(pol_risk_id), '') end),'')"
  FINANCIAL_TRANSACTION_NK__QUOTE_RISK_PREMIUM: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(pol_risk_id),'')) is not null then 'QUOTEPREM:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(pol_risk_id), '') end),''))"
  LOCATION_BK: "nullif(trim(case when coalesce(nullif(trim(addr1),''), nullif(trim(addr2),''), nullif(trim(addr3),''), nullif(trim(city_code),''), nullif(trim(state_code),''), nullif(trim(postal_code),''), nullif(trim(country_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(addr1), ''), '') || '#' || coalesce(nullif(trim(addr2), ''), '') || '#' || coalesce(nullif(trim(addr3), ''), '') || '#' || coalesce(nullif(trim(city_code), ''), '') || '#' || coalesce(nullif(trim(state_code), ''), '') || '#' || coalesce(nullif(trim(postal_code), ''), '') || '#' || coalesce(nullif(trim(country_code), ''), '')), '######')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(addr1),''), nullif(trim(addr2),''), nullif(trim(addr3),''), nullif(trim(city_code),''), nullif(trim(state_code),''), nullif(trim(postal_code),''), nullif(trim(country_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(addr1), ''), '') || '#' || coalesce(nullif(trim(addr2), ''), '') || '#' || coalesce(nullif(trim(addr3), ''), '') || '#' || coalesce(nullif(trim(city_code), ''), '') || '#' || coalesce(nullif(trim(state_code), ''), '') || '#' || coalesce(nullif(trim(postal_code), ''), '') || '#' || coalesce(nullif(trim(country_code), ''), '')), '######')), '[[:space:]]+', ' '))) end),''))"
  PARTY_BK: "nullif(trim(case when nullif(trim(party_code),'') is not null then nullif(trim(party_code), '') end),'')"
  PARTY_NK: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(party_code),'') is not null then nullif(trim(party_code), '') end),''))"
  PARTY_BK__ADDITIONAL_PARTY: "nullif(trim(case when nullif(trim(additional_party_code),'') is not null then nullif(trim(additional_party_code), '') end),'')"
  PARTY_NK__ADDITIONAL_PARTY: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(additional_party_code),'') is not null then nullif(trim(additional_party_code), '') end),''))"
  QUOTE_BK: "nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(pol_risk_id), '') end),''))"
  ADDRESS_LINE_1: 'addr1'
  ADDRESS_LINE_2: 'addr2'
  ADDRESS_LINE_3: 'addr3'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  BASE_CURRENCY_CODE: 'base_currency'
  CARE_OF_NAME: 'cast(null as varchar)'
  CITY: 'city_code'
  COUNTRY_CODE: 'country_code'
  COUNTRY_NAME: 'cast(null as varchar)'
  CURRENCY_CODE: 'prem_currency'
  DISTRICT: 'cast(null as varchar)'
  EXCHANGE_RATE: 'cast(null as varchar)'
  EXPOSURE_QUANTITY: 'cast(null as varchar)'
  EXPOSURE_UNIT: 'cast(null as varchar)'
  INSURED_VALUE: 'risk_sum_insured'
  LANDMARK: 'cast(null as varchar)'
  LOCALITY: 'cast(null as varchar)'
  POSTAL_CODE: 'postal_code'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  RISK_CLASS_CODE: 'cast(null as varchar)'
  RISK_OBJECT_DESCRIPTION: 'risk_desc'
  RISK_OBJECT_REFERENCE_NUMBER: 'risk_serial_number'
  RISK_OBJECT_TYPE: 'risk_code'
  STATE_CODE: 'state_code'
  STATE_NAME: 'cast(null as varchar)'
  STREET_NAME: 'cast(null as varchar)'
  BASE_CURRENCY_EXCHANGE_RATE: 'cast(null as varchar)'
  INSURED_VALUE_IN_SUM_INSURED_CURRENCY: 'cast(null as varchar)'
  INSURED_VALUE_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
