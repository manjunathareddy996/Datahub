{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_BENEFIT_HEAD from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 16 payload column(s); the child key is BENEFIT_HEAD_CODE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_properties_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_BENEFIT_HEAD:
    is_hashdiff: true
    columns:
      - 'AMOUNT_IN_EXCESS_OF_SUM_INSURED'
      - 'BENEFIT_HEAD_CODE'
      - 'BENEFIT_LIMIT_AMOUNT_USD'
      - 'CLAIMED_AMOUNT_BREAKUP'
      - 'COVER_SUM_INSURED_AMOUNT'
      - 'COVER_SUM_INSURED_CURRENCY'
      - 'COVER_TAKEN_INDICATOR'
      - 'DEDUCTIBLE_AMOUNT'
      - 'DEDUCTIBLE_COMMENT'
      - 'DEDUCTIBLE_WAIVED_INDICATOR'
      - 'DEDUCTION_AMOUNT_BREAKUP'
      - 'EXTENSION_OR_CLAUSE_APPLICABLE_INDICATOR'
      - 'HEAD_LINE_PARTICULARS'
      - 'HEAD_SUM_INSURED_AMOUNT'
      - 'PANDEMIC_COVER_APPLICABLE_INDICATOR'
      - 'SUM_INSURED_VALIDATION_OVERRIDE_INDICATOR'
      - 'SUM_INSURED_VALIDATION_OVERRIDE_REMARKS'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  BENEFIT_HEAD_CODE: "nullif(trim(cover_code), '') || '#' || nullif(trim(subcover_code), '')"
  AMOUNT_IN_EXCESS_OF_SUM_INSURED: 'additional_amount_over_si'
  BENEFIT_LIMIT_AMOUNT_USD: 'benefit_limit_usd'
  CLAIMED_AMOUNT_BREAKUP: 'cast(null as varchar)'
  COVER_SUM_INSURED_AMOUNT: 'cover_sum_insured'
  COVER_SUM_INSURED_CURRENCY: 'cover_sum_insured_currency'
  COVER_TAKEN_INDICATOR: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT: 'deductible'
  DEDUCTIBLE_COMMENT: 'deductible_comment'
  DEDUCTIBLE_WAIVED_INDICATOR: 'deductible_waived'
  DEDUCTION_AMOUNT_BREAKUP: 'cast(null as varchar)'
  EXTENSION_OR_CLAUSE_APPLICABLE_INDICATOR: 'is_extensions_clauses_conditions_and_warranties_applicable'
  HEAD_LINE_PARTICULARS: 'cast(null as varchar)'
  HEAD_SUM_INSURED_AMOUNT: 'subcover_si_amount'
  PANDEMIC_COVER_APPLICABLE_INDICATOR: 'pandemic_cover_flag'
  SUM_INSURED_VALIDATION_OVERRIDE_INDICATOR: 'si_validation_override'
  SUM_INSURED_VALIDATION_OVERRIDE_REMARKS: 'si_validation_override_remarks'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
