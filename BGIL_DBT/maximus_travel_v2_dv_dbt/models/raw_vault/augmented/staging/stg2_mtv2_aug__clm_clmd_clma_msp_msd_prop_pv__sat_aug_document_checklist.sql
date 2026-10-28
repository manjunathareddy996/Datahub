{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_DOCUMENT_CHECKLIST from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 3 payload column(s); the child key is REQUIRED_DOCUMENT_TYPE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clma_msp_msd_prop_pv'
hashed_columns:
  DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET: 'DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET'
  HASHDIFF_DOCUMENT_CHECKLIST:
    is_hashdiff: true
    columns:
      - 'REQUIRED_DOCUMENT_TYPE'
      - 'REQUIREMENT_RESPONSE_TEXT'
      - 'REQUIREMENT_SOUGHT_FROM'
      - 'REQUIREMENT_STATUS'
derived_columns:
  DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET: "nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'')"
  DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),''))"
  REQUIRED_DOCUMENT_TYPE: "coalesce(nullif(trim(requirement_type_name), ''),'')"
  REQUIREMENT_RESPONSE_TEXT: 'response'
  REQUIREMENT_SOUGHT_FROM: 'required_from'
  REQUIREMENT_STATUS: 'requirement_status'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
