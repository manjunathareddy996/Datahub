{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_PREFERENCE_PROFILE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_mbr_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  HASHDIFF_PARTY_PREFERENCE_PROFILE:
    is_hashdiff: true
    columns:
      - 'ELECTRONIC_POLICY_REQUIRED_INDICATOR'
      - 'PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR'
derived_columns:
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  ELECTRONIC_POLICY_REQUIRED_INDICATOR: 'epolicy_required'
  PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR: 'update_contact_details_in_all_policies'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
