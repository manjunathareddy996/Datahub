{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_LNK_ROLE_AGENT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 3 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_ROLE_HKEY__PROPOSER: 'PARTY_ROLE_NK__PROPOSER'
  HASHDIFF_LNK_ROLE_AGENT:
    is_hashdiff: true
    columns:
      - 'IRDA_LISTED_PRIMARY_PROFESSION'
      - 'LICENCE_DETAILS_DESCRIPTION'
      - 'SPECIAL_TDS_RATE_APPLICABLE_INDICATOR'
derived_columns:
  PARTY_ROLE_BK__PROPOSER: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),'')"
  PARTY_ROLE_NK__PROPOSER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),''))"
  IRDA_LISTED_PRIMARY_PROFESSION: 'irda_list_primary_profession'
  LICENCE_DETAILS_DESCRIPTION: 'license_details'
  SPECIAL_TDS_RATE_APPLICABLE_INDICATOR: 'special_rate_applicable'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
