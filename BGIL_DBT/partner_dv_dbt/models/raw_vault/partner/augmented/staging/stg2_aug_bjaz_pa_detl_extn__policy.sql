{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_PA_DETL_EXTN'.
-- 5 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_PA_DETL_EXTN carries a
-- verified HUB_POLICY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.
-- MULTI-ACTIVE FIX (mapper feedback round 2): SAT_AUG_POLICY is now ma_sat()-keyed by
-- MEMBER_SEQUENCE. This table has no member column (mapper-confirmed) -- literal placeholder
-- so it still unions cleanly with the tables that do carry a real member sequence.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_pa_detl_extn'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUMMULATIVE_AMT'
      - 'CUMM_BONUS_COMP'
      - 'CUMM_BONUS_WIDER'
      - 'CUMM_BONUS_AMT_WIDER'
      - 'CUMM_BONUS_AMT_COMP'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  MEMBER_SEQUENCE: '!0'
  CUMMULATIVE_AMT: 'cummulative_amt'
  CUMM_BONUS_COMP: 'cumm_bonus_comp'
  CUMM_BONUS_WIDER: 'cumm_bonus_wider'
  CUMM_BONUS_AMT_WIDER: 'cumm_bonus_amt_wider'
  CUMM_BONUS_AMT_COMP: 'cumm_bonus_amt_comp'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PA_DETL_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
