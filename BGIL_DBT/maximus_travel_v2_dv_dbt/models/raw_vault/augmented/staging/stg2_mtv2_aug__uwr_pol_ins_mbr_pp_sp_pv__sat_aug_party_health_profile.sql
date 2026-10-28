{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_HEALTH_PROFILE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 3 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_mbr_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  HASHDIFF_PARTY_HEALTH_PROFILE:
    is_hashdiff: true
    columns:
      - 'DISABILITY_BODY_LOCATION'
      - 'ICD_DIAGNOSIS_CODE'
      - 'SURGERY_HISTORY_DESCRIPTION'
derived_columns:
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  DISABILITY_BODY_LOCATION: 'location_of_disability'
  ICD_DIAGNOSIS_CODE: 'icd'
  SURGERY_HISTORY_DESCRIPTION: 'surgery_details'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
