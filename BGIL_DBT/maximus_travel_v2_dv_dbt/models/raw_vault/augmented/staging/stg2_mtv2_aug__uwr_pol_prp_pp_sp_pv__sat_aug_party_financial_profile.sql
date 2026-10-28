{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_FINANCIAL_PROFILE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 10 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
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
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  BANKING_DETAILS_NARRATIVE: 'banking_details'
  CHEQUE_RECEIPTING_BLOCKED_INDICATOR: 'cheque_receipting_blocked'
  CHEQUE_RECEIPTING_BLOCK_REASON: 'remarks_for_cheque_receipting_blocked'
  CREDIT_CARD_DETAILS_NARRATIVE: 'credit_card_details'
  CREDIT_LIMIT_REFERENCE: 'credit_limit_cin_no'
  HIGH_NET_WORTH_INDIVIDUAL_INDICATOR: 'hni_flag'
  INCOME_SEGMENT: 'cast(null as varchar)'
  INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR: 'filed_it_last_2_years'
  LOWER_TDS_CERTIFICATE_REFERENCE: 'cast(null as varchar)'
  MONTHLY_INCOME_DECLARED: 'monthly_income'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
