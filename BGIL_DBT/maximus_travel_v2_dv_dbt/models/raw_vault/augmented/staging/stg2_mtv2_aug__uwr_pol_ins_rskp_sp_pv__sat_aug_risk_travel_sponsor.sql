{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_RISK_TRAVEL_SPONSOR from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_rskp_sp_pv'
hashed_columns:
  RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK: 'RISK_OBJECT_NK__INSURED_TRAVELLER_RISK'
  HASHDIFF_RISK_TRAVEL_SPONSOR:
    is_hashdiff: true
    columns:
      - 'SPONSOR_CONTACT_NUMBER'
      - 'SPONSOR_NAME'
derived_columns:
  RISK_OBJECT_BK__INSURED_TRAVELLER_RISK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK__INSURED_TRAVELLER_RISK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  SPONSOR_CONTACT_NUMBER: 'sponser_contact_number'
  SPONSOR_NAME: 'sponser_name'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
