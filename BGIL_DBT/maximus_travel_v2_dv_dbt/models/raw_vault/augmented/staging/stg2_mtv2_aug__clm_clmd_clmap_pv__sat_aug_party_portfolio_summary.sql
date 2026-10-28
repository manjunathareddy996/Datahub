{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_PORTFOLIO_SUMMARY from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 7 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  PARTY_HKEY__CLAIMANT_CUSTOMER: 'PARTY_NK__CLAIMANT_CUSTOMER'
  HASHDIFF_PARTY_PORTFOLIO_SUMMARY:
    is_hashdiff: true
    columns:
      - 'CROSS_SELL_POLICIES_PURCHASED'
      - 'CUSTOMER_ACTIVE_YEARS'
      - 'LATEST_POLICY_ISSUANCE_LOCATION_NAME'
      - 'LATEST_POLICY_LINE_OF_BUSINESS'
      - 'LATEST_POLICY_PRODUCT_NAME'
      - 'LATEST_POLICY_SUB_CHANNEL'
      - 'MULTI_CHANNEL_PURCHASE_INDICATOR'
derived_columns:
  PARTY_BK__CLAIMANT_CUSTOMER: "nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'')"
  PARTY_NK__CLAIMANT_CUSTOMER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''))"
  CROSS_SELL_POLICIES_PURCHASED: 'cross_sell_policies_purchased'
  CUSTOMER_ACTIVE_YEARS: 'customer_active_period_with_bagic_in_year'
  LATEST_POLICY_ISSUANCE_LOCATION_NAME: 'latest_policy_location_name_of_policy_issuance'
  LATEST_POLICY_LINE_OF_BUSINESS: 'latest_policy_line_of_business'
  LATEST_POLICY_PRODUCT_NAME: 'latest_policy_product_name'
  LATEST_POLICY_SUB_CHANNEL: 'latest_policy_sub_channnel'
  MULTI_CHANNEL_PURCHASE_INDICATOR: 'customer_taking_policies_from_multiple_channels'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
