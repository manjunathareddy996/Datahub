{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS
-- Covers this view's 7 key slot(s) and its 4 1:1 satellite target(s) in one pass,
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
--   DISTRIBUTION_CHANNEL_HKEY          HUB_DISTRIBUTION_CHANNEL  (1 row(s) in the map)
--   DOCUMENT_HKEY                      HUB_DOCUMENT  (1 row(s) in the map)
--   FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM HUB_FINANCIAL_TRANSACTION / quote-premium  (4 row(s) in the map)
--   ORG_UNIT_HKEY__POLICY_ISSUING_BRANCH HUB_ORG_UNIT / policy-issuing-branch  (1 row(s) in the map)
--   PARTY_HKEY__POLICYHOLDER           HUB_PARTY / policyholder  (1 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (1 row(s) in the map)
--   QUOTE_HKEY                         HUB_QUOTE  (17 row(s) in the map)
--   HASHDIFF_COMMON_MONETARY_CONTEXT   SAT_COMMON_MONETARY_CONTEXT payload 3 of 3 live here
--   HASHDIFF_ORG_UNIT_DEFINITION       SAT_ORG_UNIT_DEFINITION payload 1 of 2 live here
--   HASHDIFF_QUOTE_HEADER              SAT_QUOTE_HEADER payload 4 of 8 live here
--   HASHDIFF_QUOTE_RATING              SAT_QUOTE_RATING payload 3 of 6 live here

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__uwr_qpd'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM: 'FINANCIAL_TRANSACTION_NK__QUOTE_PREMIUM'
  ORG_UNIT_HKEY__POLICY_ISSUING_BRANCH: 'ORG_UNIT_NK__POLICY_ISSUING_BRANCH'
  PARTY_HKEY__POLICYHOLDER: 'PARTY_NK__POLICYHOLDER'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_COMMON_MONETARY_CONTEXT:
    is_hashdiff: true
    columns:
      - 'BASE_CURRENCY_CODE'
      - 'CURRENCY_CODE'
      - 'EXCHANGE_RATE'
  HASHDIFF_ORG_UNIT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COST_CENTRE_CODE'
      - 'ORG_UNIT_NAME'
  HASHDIFF_QUOTE_HEADER:
    is_hashdiff: true
    columns:
      - 'LEAD_REFERENCE'
      - 'PROSPECT_REFERENCE'
      - 'QUOTE_REMARKS'
      - 'QUOTE_SOURCE'
      - 'QUOTE_STATUS'
      - 'REQUESTED_COVER_START_DATE'
      - 'REQUESTED_POLICY_TERM'
      - 'REQUESTED_SUM_INSURED'
  HASHDIFF_QUOTE_RATING:
    is_hashdiff: true
    columns:
      - 'BASE_PREMIUM'
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'PREMIUM_FREQUENCY'
derived_columns:
  DISTRIBUTION_CHANNEL_BK: "nullif(trim(case when coalesce(nullif(trim(agent_code),'')) is not null then nullif(trim(agent_code), '') end),'')"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (nullif(trim(case when coalesce(nullif(trim(agent_code),'')) is not null then nullif(trim(agent_code), '') end),''))"
  DOCUMENT_BK: "nullif(trim(case when coalesce(nullif(trim(document_id),'')) is not null then 'DOC:' || nullif(trim(document_id), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(document_id),'')) is not null then 'DOC:' || nullif(trim(document_id), '') end),''))"
  FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM: "nullif(trim(case when coalesce(nullif(trim(policy_quote_number),'')) is not null then 'QUOTEPREM:' || nullif(trim(policy_quote_number), '') end),'')"
  FINANCIAL_TRANSACTION_NK__QUOTE_PREMIUM: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(policy_quote_number),'')) is not null then 'QUOTEPREM:' || nullif(trim(policy_quote_number), '') end),''))"
  ORG_UNIT_BK__POLICY_ISSUING_BRANCH: "nullif(trim(case when coalesce(nullif(trim(policy_branch_name),'')) is not null then 'ORGUNIT:' || md5(upper(trim(nullif(trim(policy_branch_name), '')))) end),'')"
  ORG_UNIT_NK__POLICY_ISSUING_BRANCH: "'HUB_ORG_UNIT|' || (nullif(trim(case when coalesce(nullif(trim(policy_branch_name),'')) is not null then 'ORGUNIT:' || md5(upper(trim(nullif(trim(policy_branch_name), '')))) end),''))"
  PARTY_BK__POLICYHOLDER: "nullif(trim(case when coalesce(nullif(trim(policy_holder_code),'')) is not null then nullif(trim(policy_holder_code), '') end),'')"
  PARTY_NK__POLICYHOLDER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(policy_holder_code),'')) is not null then nullif(trim(policy_holder_code), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when coalesce(nullif(trim(product_code),'')) is not null then 'PROD:' || nullif(trim(product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when coalesce(nullif(trim(product_code),'')) is not null then 'PROD:' || nullif(trim(product_code), '') end),''))"
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(policy_quote_number),'')) is not null then nullif(trim(policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(policy_quote_number),'')) is not null then nullif(trim(policy_quote_number), '') end),''))"
  BASE_CURRENCY_CODE: 'base_currency'
  BASE_PREMIUM: 'cast(null as varchar)'
  COST_CENTRE_CODE: 'cast(null as varchar)'
  CURRENCY_CODE: 'premium_currency'
  DISCOUNT_AMOUNT: 'total_discount_amount'
  EXCHANGE_RATE: 'premium_currency_rate'
  GROSS_PREMIUM: 'cast(null as varchar)'
  LEAD_REFERENCE: 'cast(null as varchar)'
  LOADING_AMOUNT: 'total_loading_amount'
  NET_PREMIUM: 'cast(null as varchar)'
  ORG_UNIT_NAME: 'policy_branch_name'
  PREMIUM_FREQUENCY: 'premium_frequency'
  PROSPECT_REFERENCE: 'cast(null as varchar)'
  QUOTE_REMARKS: 'cast(null as varchar)'
  QUOTE_SOURCE: 'application_code'
  QUOTE_STATUS: 'policy_status_code'
  REQUESTED_COVER_START_DATE: 'policy_inception_date'
  REQUESTED_POLICY_TERM: 'policy_term'
  REQUESTED_SUM_INSURED: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
