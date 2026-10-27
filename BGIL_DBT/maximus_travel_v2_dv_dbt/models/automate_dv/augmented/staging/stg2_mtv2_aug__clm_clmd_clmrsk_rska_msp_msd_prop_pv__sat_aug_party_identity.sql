{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_IDENTITY from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 5 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
hashed_columns:
  PARTY_HKEY__CLAIMANT: 'PARTY_NK__CLAIMANT'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'CREATED_BY_USER_REFERENCE'
      - 'GUARDIAN_NAME'
      - 'PARTY_COUNTRY'
      - 'RECORD_LAST_MODIFIED_DATE'
      - 'SOURCE_REFERENCE_CODE'
derived_columns:
  PARTY_BK__CLAIMANT: "nullif(trim(case when coalesce(nullif(trim(claimant_party_code),'')) is not null then nullif(trim(claimant_party_code), '') end),'')"
  PARTY_NK__CLAIMANT: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(claimant_party_code),'')) is not null then nullif(trim(claimant_party_code), '') end),''))"
  CREATED_BY_USER_REFERENCE: 'cast(null as varchar)'
  GUARDIAN_NAME: 'guardian_name'
  PARTY_COUNTRY: 'cast(null as varchar)'
  RECORD_LAST_MODIFIED_DATE: 'cast(null as varchar)'
  SOURCE_REFERENCE_CODE: 'cast(null as varchar)'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
