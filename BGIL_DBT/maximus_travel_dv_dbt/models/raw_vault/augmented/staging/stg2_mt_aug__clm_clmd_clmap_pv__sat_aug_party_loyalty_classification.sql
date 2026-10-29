{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_PARTY_LOYALTY_CLASSIFICATION from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mt__clm_clmd_clmap_pv__aug_sat_aug_party_loyalty_classification: 3 instance(s) on this view.
--
-- 1 payload column(s); the child key is LOYALTY_CLASSIFICATION_TYPE.

{%- set yaml_metadata -%}
source_model: 'up_mt__clm_clmd_clmap_pv__aug_sat_aug_party_loyalty_classification'
hashed_columns:
  PARTY_HKEY__INSURED_CUSTOMER: 'PARTY_NK__INSURED_CUSTOMER'
  HASHDIFF_PARTY_LOYALTY_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'LOYALTY_BUCKET'
      - 'LOYALTY_CLASSIFICATION_TYPE'
derived_columns:
  PARTY_NK__INSURED_CUSTOMER: "'HUB_PARTY|' || (PARTY_BK__INSURED_CUSTOMER)"
  PARTY_BK__INSURED_CUSTOMER: 'PARTY_BK__INSURED_CUSTOMER'
  LOYALTY_CLASSIFICATION_TYPE: 'LOYALTY_CLASSIFICATION_TYPE'
  LOYALTY_BUCKET: 'LOYALTY_BUCKET'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
