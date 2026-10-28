{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_HEADER from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 16 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_HEADER:
    is_hashdiff: true
    columns:
      - 'ADD_ON_COVERS_CLAIMED'
      - 'CERTIFICATE_OF_INSURANCE_STATUS'
      - 'CLAIM_CLOSE_REASON'
      - 'CLAIM_LOCATION_CODE'
      - 'CLAIM_STATE'
      - 'CLONE_TYPE'
      - 'HEAD_OFFICE_ORG_UNIT_CODE'
      - 'LOSS_CAUSE_DESCRIPTION'
      - 'PRIMARY_CAUSE_OF_LOSS_CODE'
      - 'PRIMARY_CAUSE_OF_LOSS_DESCRIPTION'
      - 'REGISTRATION_ORG_UNIT_CODE'
      - 'REGISTRATION_TIME'
      - 'REOPENING_TYPE'
      - 'ROADSIDE_ASSISTANCE_REQUIRED_INDICATOR'
      - 'SECONDARY_CAUSE_OF_LOSS_CODE'
      - 'SECONDARY_CAUSE_OF_LOSS_DESCRIPTION'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ADD_ON_COVERS_CLAIMED: 'cast(null as varchar)'
  CERTIFICATE_OF_INSURANCE_STATUS: 'cast(null as varchar)'
  CLAIM_CLOSE_REASON: 'cast(null as varchar)'
  CLAIM_LOCATION_CODE: 'cast(null as varchar)'
  CLAIM_STATE: 'cast(null as varchar)'
  CLONE_TYPE: 'cast(null as varchar)'
  HEAD_OFFICE_ORG_UNIT_CODE: 'cast(null as varchar)'
  LOSS_CAUSE_DESCRIPTION: 'loss_reason'
  PRIMARY_CAUSE_OF_LOSS_CODE: 'cast(null as varchar)'
  PRIMARY_CAUSE_OF_LOSS_DESCRIPTION: 'cast(null as varchar)'
  REGISTRATION_ORG_UNIT_CODE: 'cast(null as varchar)'
  REGISTRATION_TIME: 'cast(null as varchar)'
  REOPENING_TYPE: 'cast(null as varchar)'
  ROADSIDE_ASSISTANCE_REQUIRED_INDICATOR: 'cast(null as varchar)'
  SECONDARY_CAUSE_OF_LOSS_CODE: 'cast(null as varchar)'
  SECONDARY_CAUSE_OF_LOSS_DESCRIPTION: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
