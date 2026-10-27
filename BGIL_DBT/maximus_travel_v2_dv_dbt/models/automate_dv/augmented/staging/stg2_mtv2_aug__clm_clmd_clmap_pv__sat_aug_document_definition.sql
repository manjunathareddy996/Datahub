{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_DOCUMENT_DEFINITION from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 7 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET: 'DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET'
  HASHDIFF_DOCUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COURIER_NAME'
      - 'DOCUMENT_DETAILS_TEXT'
      - 'PROOF_OF_DELIVERY_NUMBER'
      - 'RECORD_VALID_INDICATOR'
      - 'SENDER_NAME'
      - 'SPECIAL_ENCLOSURES_DETAILS'
      - 'SPECIAL_ENCLOSURES_INDICATOR'
derived_columns:
  DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET: "nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'')"
  DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),''))"
  COURIER_NAME: 'courier_name'
  DOCUMENT_DETAILS_TEXT: 'document_details'
  PROOF_OF_DELIVERY_NUMBER: 'cast(null as varchar)'
  RECORD_VALID_INDICATOR: 'isvalid'
  SENDER_NAME: 'cast(null as varchar)'
  SPECIAL_ENCLOSURES_DETAILS: 'cast(null as varchar)'
  SPECIAL_ENCLOSURES_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
