{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_HEALTH_DETAIL from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 7 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clma_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_HEALTH_DETAIL:
    is_hashdiff: true
    columns:
      - 'ADVERSE_MEDICAL_HISTORY_DESCRIPTION'
      - 'DISEASE_CATEGORY'
      - 'ICD_DESCRIPTION'
      - 'MEDICALLY_ADMISSIBLE_INDICATOR'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'PRE_EXISTING_ILLNESS_DESCRIPTION'
      - 'SYSTEM_OF_MEDICINE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ADVERSE_MEDICAL_HISTORY_DESCRIPTION: 'cast(null as varchar)'
  DISEASE_CATEGORY: 'disease_category'
  ICD_DESCRIPTION: 'cast(null as varchar)'
  MEDICALLY_ADMISSIBLE_INDICATOR: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'cast(null as varchar)'
  PRE_EXISTING_ILLNESS_DESCRIPTION: 'cast(null as varchar)'
  SYSTEM_OF_MEDICINE: 'cast(null as varchar)'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
