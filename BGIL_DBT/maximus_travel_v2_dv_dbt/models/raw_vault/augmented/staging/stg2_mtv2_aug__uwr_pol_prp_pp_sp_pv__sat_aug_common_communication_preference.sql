{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_COMMON_COMMUNICATION_PREFERENCE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- ALIGNED to the OPUS sibling (BUILD_RULES 7.7). travel_dv_dbt already builds
-- SAT_AUG_COMMON_COMMUNICATION_PREFERENCE with src_pk PARTY_HKEY, single-active, no child key and a bare
-- HASHDIFF. This EXTENDS that satellite's payload; a second Maximus-side satellite
-- for the same concept would be model invention wearing an AUG_ prefix.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'PREFERRED_ALERT_CHANNEL'
derived_columns:
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  PREFERRED_ALERT_CHANNEL: 'preferred_mode_of_alert'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
