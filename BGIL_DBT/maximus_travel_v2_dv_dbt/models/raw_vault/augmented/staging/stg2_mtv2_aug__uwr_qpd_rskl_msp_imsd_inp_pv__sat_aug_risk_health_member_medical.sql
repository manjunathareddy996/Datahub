{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 4 payload column(s); the child key is CONDITION_CODE, MEMBER_REFERENCE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL:
    is_hashdiff: true
    columns:
      - 'CONDITION_CODE'
      - 'CONDITION_DESCRIPTION'
      - 'CURRENT_MEDICATION_DETAIL'
      - 'MEMBER_REFERENCE'
      - 'PRE_EXISTING_DISEASE_ONSET_MONTH'
      - 'PRE_EXISTING_DISEASE_ONSET_YEAR'
derived_columns:
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  CONDITION_CODE: "coalesce(nullif(trim(disease), ''),'')"
  MEMBER_REFERENCE: "coalesce(nullif(trim(w1_pol_risk_id), ''),'')"
  CONDITION_DESCRIPTION: 'disease_description'
  CURRENT_MEDICATION_DETAIL: 'current_medication'
  PRE_EXISTING_DISEASE_ONSET_MONTH: 'ped_month'
  PRE_EXISTING_DISEASE_ONSET_YEAR: 'ped_year'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
