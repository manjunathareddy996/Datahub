{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_FINANCIAL_PROFILE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 10 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  PARTY_HKEY__CLAIMANT_CUSTOMER: 'PARTY_NK__CLAIMANT_CUSTOMER'
  HASHDIFF_PARTY_FINANCIAL_PROFILE:
    is_hashdiff: true
    columns:
      - 'BANKING_DETAILS_NARRATIVE'
      - 'CHEQUE_RECEIPTING_BLOCKED_INDICATOR'
      - 'CHEQUE_RECEIPTING_BLOCK_REASON'
      - 'CREDIT_CARD_DETAILS_NARRATIVE'
      - 'CREDIT_LIMIT_REFERENCE'
      - 'HIGH_NET_WORTH_INDIVIDUAL_INDICATOR'
      - 'INCOME_SEGMENT'
      - 'INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR'
      - 'LOWER_TDS_CERTIFICATE_REFERENCE'
      - 'MONTHLY_INCOME_DECLARED'
derived_columns:
  PARTY_BK__CLAIMANT_CUSTOMER: "nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'')"
  PARTY_NK__CLAIMANT_CUSTOMER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''))"
  BANKING_DETAILS_NARRATIVE: 'cast(null as varchar)'
  CHEQUE_RECEIPTING_BLOCKED_INDICATOR: 'cast(null as varchar)'
  CHEQUE_RECEIPTING_BLOCK_REASON: 'cast(null as varchar)'
  CREDIT_CARD_DETAILS_NARRATIVE: 'cast(null as varchar)'
  CREDIT_LIMIT_REFERENCE: 'cast(null as varchar)'
  HIGH_NET_WORTH_INDIVIDUAL_INDICATOR: 'cast(null as varchar)'
  INCOME_SEGMENT: 'customer_income_segment'
  INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR: 'cast(null as varchar)'
  LOWER_TDS_CERTIFICATE_REFERENCE: 'cast(null as varchar)'
  MONTHLY_INCOME_DECLARED: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
