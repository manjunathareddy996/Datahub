{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_LNK_ROLE_PROVIDER from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_ROLE_HKEY__PROPOSER: 'PARTY_ROLE_NK__PROPOSER'
  HASHDIFF_LNK_ROLE_PROVIDER:
    is_hashdiff: true
    columns:
      - 'NATIONAL_TIE_UP_INFORMATION'
      - 'TASK_ALLOCATION_THRESHOLD'
derived_columns:
  PARTY_ROLE_BK__PROPOSER: "coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'')"
  PARTY_ROLE_NK__PROPOSER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),''))"
  NATIONAL_TIE_UP_INFORMATION: 'national_tieup_information'
  TASK_ALLOCATION_THRESHOLD: 'task_threshold'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
