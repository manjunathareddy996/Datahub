{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_DOCUMENT_REMINDER from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__clm_clmd_clmcov_msd_prop_pv__aug_sat_aug_claim_document_reminder: 3 instance(s) on this view.
--
-- 1 payload column(s); the child key is REMINDER_SEQUENCE, REQUIREMENT_TYPE_NAME.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__clm_clmd_clmcov_msd_prop_pv__aug_sat_aug_claim_document_reminder'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_DOCUMENT_REMINDER:
    is_hashdiff: true
    columns:
      - 'REMINDER_DATE'
      - 'REMINDER_SEQUENCE'
      - 'REQUIREMENT_TYPE_NAME'
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || (CLAIM_BK)"
  CLAIM_BK: 'CLAIM_BK'
  REMINDER_SEQUENCE: 'REMINDER_SEQUENCE'
  REQUIREMENT_TYPE_NAME: 'REQUIREMENT_TYPE_NAME'
  REMINDER_DATE: 'REMINDER_DATE'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
