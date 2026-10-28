{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_PAYOUT_PROFILE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 6 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_PARTY_PAYOUT_PROFILE:
    is_hashdiff: true
    columns:
      - 'FLOAT_ACCOUNT_ACCESS_INDICATOR'
      - 'LOWER_TDS_CERTIFICATE_REFERENCE'
      - 'REWARD_ELIGIBLE_INDICATOR'
      - 'TDS_CODE'
      - 'TDS_CODE_DESCRIPTION'
      - 'TDS_DETAILS_DESCRIPTION'
derived_columns:
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  FLOAT_ACCOUNT_ACCESS_INDICATOR: 'agent_float_access'
  LOWER_TDS_CERTIFICATE_REFERENCE: 'lower_tds_certificate'
  REWARD_ELIGIBLE_INDICATOR: 'applicable_for_reward'
  TDS_CODE: 'tds_code'
  TDS_CODE_DESCRIPTION: 'tds_code_desc'
  TDS_DETAILS_DESCRIPTION: 'tds_details'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
