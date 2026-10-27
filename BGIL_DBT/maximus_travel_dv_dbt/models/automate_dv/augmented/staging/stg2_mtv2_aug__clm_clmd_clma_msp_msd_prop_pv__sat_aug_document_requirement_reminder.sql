{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_DOCUMENT_REQUIREMENT_REMINDER from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__clm_clmd_clma_msp_msd_prop_pv__aug_sat_aug_document_requirement_reminder: 3 instance(s) on this view.
--
-- 1 payload column(s); the child key is REMINDER_SEQUENCE.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__clm_clmd_clma_msp_msd_prop_pv__aug_sat_aug_document_requirement_reminder'
hashed_columns:
  DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET: 'DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET'
  HASHDIFF_DOCUMENT_REQUIREMENT_REMINDER:
    is_hashdiff: true
    columns:
      - 'REMINDER_DATE'
      - 'REMINDER_SEQUENCE'
derived_columns:
  DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET: "'HUB_DOCUMENT|' || (DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET)"
  DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET: 'DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET'
  REMINDER_SEQUENCE: 'REMINDER_SEQUENCE'
  REMINDER_DATE: 'REMINDER_DATE'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
