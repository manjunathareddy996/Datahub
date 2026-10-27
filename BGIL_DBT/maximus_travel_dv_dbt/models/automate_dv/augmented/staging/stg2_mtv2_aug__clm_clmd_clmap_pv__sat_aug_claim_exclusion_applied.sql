{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_EXCLUSION_APPLIED from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__clm_clmd_clmap_pv__aug_sat_aug_claim_exclusion_applied: 6 instance(s) on this view.
--
-- 1 payload column(s); the child key is EXCLUSION_SET_CODE.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__clm_clmd_clmap_pv__aug_sat_aug_claim_exclusion_applied'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_EXCLUSION_APPLIED:
    is_hashdiff: true
    columns:
      - 'EXCLUSION_DETAIL_TEXT'
      - 'EXCLUSION_SET_CODE'
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || (CLAIM_BK)"
  CLAIM_BK: 'CLAIM_BK'
  EXCLUSION_SET_CODE: 'EXCLUSION_SET_CODE'
  EXCLUSION_DETAIL_TEXT: 'EXCLUSION_DETAIL_TEXT'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
