{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_RISK_PERSON_INSURED from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- ALIGNED to the OPUS sibling (BUILD_RULES 7.7). travel_dv_dbt already builds
-- SAT_AUG_RISK_PERSON_INSURED with src_pk RISK_OBJECT_HKEY, single-active, no child key and a bare
-- HASHDIFF. This EXTENDS that satellite's payload; a second Maximus-side satellite
-- for the same concept would be model invention wearing an AUG_ prefix.
--
-- 10 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_qpd_rskl_rskp_rl_pv'
hashed_columns:
  RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK: 'RISK_OBJECT_NK__QUOTED_TRAVELLER_RISK'
  HASHDIFF_RISK_PERSON_INSURED:
    is_hashdiff: true
    columns:
      - 'ALCOHOL_USE_INDICATOR'
      - 'EMPLOYEE_NUMBER'
      - 'GOOD_HEALTH_DECLARATION_INDICATOR'
      - 'INSURED_SAME_AS_POLICYHOLDER_INDICATOR'
      - 'MEDICAL_CHECK_REQUIRED_INDICATOR'
      - 'NOMINEE_DETAILS'
      - 'OTHER_INSURANCE_HELD_DETAIL'
      - 'PREVIOUS_CLAIM_DECLARATION_DETAIL'
      - 'RECREATIONAL_DRUG_USE_INDICATOR'
      - 'RELATIONSHIP_TO_PRIMARY_INSURED'
derived_columns:
  RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK__QUOTED_TRAVELLER_RISK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  ALCOHOL_USE_INDICATOR: 'drink_alcohol'
  EMPLOYEE_NUMBER: 'employee_number'
  GOOD_HEALTH_DECLARATION_INDICATOR: 'good_health_declaration_flag'
  INSURED_SAME_AS_POLICYHOLDER_INDICATOR: 'is_the_insured_same_as_policy_holder'
  MEDICAL_CHECK_REQUIRED_INDICATOR: 'medical_check'
  NOMINEE_DETAILS: 'nominee_details'
  OTHER_INSURANCE_HELD_DETAIL: 'insurance_details_if_any_healthpa_etc'
  PREVIOUS_CLAIM_DECLARATION_DETAIL: 'claim_details'
  RECREATIONAL_DRUG_USE_INDICATOR: 'do_you_do_recreational_drug_use'
  RELATIONSHIP_TO_PRIMARY_INSURED: 'relationship_to_insured'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
