{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_DOCUMENT_REQUIREMENT from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 6 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmcov_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_DOCUMENT_REQUIREMENT:
    is_hashdiff: true
    columns:
      - 'REQUIRED_FROM_ROLE'
      - 'REQUIREMENT_CLOSURE_DATE'
      - 'REQUIREMENT_REMARKS'
      - 'REQUIREMENT_RESPONSE'
      - 'REQUIREMENT_STATUS'
      - 'REQUIREMENT_TYPE_NAME'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  REQUIRED_FROM_ROLE: 'required_from'
  REQUIREMENT_CLOSURE_DATE: 'closure_date'
  REQUIREMENT_REMARKS: 'remarks'
  REQUIREMENT_RESPONSE: 'response'
  REQUIREMENT_STATUS: 'requirement_status'
  REQUIREMENT_TYPE_NAME: 'requirement_type_name'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
