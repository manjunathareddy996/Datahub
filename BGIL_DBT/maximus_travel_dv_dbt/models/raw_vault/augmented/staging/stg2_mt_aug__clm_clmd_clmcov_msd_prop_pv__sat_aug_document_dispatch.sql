{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_DOCUMENT_DISPATCH from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 6 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmcov_msd_prop_pv'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF_DOCUMENT_DISPATCH:
    is_hashdiff: true
    columns:
      - 'COURIER_NAME'
      - 'INWARD_DATE'
      - 'PROOF_OF_DELIVERY_NUMBER'
      - 'SENDER_NAME'
      - 'SPECIAL_ENCLOSURES_DESCRIPTION'
      - 'SPECIAL_ENCLOSURES_INDICATOR'
derived_columns:
  DOCUMENT_BK: "nullif(trim(case when nullif(trim(inward_number),'') is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when nullif(trim(inward_number),'') is not null then 'INWARD:' || nullif(trim(inward_number), '') end),''))"
  COURIER_NAME: 'courier_name'
  INWARD_DATE: 'inward_date'
  PROOF_OF_DELIVERY_NUMBER: 'pod_number'
  SENDER_NAME: 'sender_name'
  SPECIAL_ENCLOSURES_DESCRIPTION: 'special_enclosures_details'
  SPECIAL_ENCLOSURES_INDICATOR: 'special_enclosures_flag'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
