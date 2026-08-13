{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_CLM_SUPP_EXTN'.
-- 6 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_CLM_SUPP_EXTN carries a
-- verified HUB_PARTY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MARRIAGE_ANNIVERSARY_DATE'
      - 'PAN_STATUS'
      - 'PAN_ACK_DT'
      - 'PAN_APP_NO'
      - 'TWO_YR_ITR_FLAG'
      - 'ADHAAR_PAN_LINK_FLAG'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  MARRIAGE_ANNIVERSARY_DATE: 'mrg_anniversiry'
  PAN_STATUS: 'pan_status'
  PAN_ACK_DT: 'pan_ack_dt'
  PAN_APP_NO: 'pan_app_no'
  TWO_YR_ITR_FLAG: 'two_yr_itr_flag'
  ADHAAR_PAN_LINK_FLAG: 'adhaar_pan_link_flag'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
