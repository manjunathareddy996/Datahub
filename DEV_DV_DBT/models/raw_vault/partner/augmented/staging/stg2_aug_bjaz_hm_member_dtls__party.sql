{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_HM_MEMBER_DTLS'.
-- 1 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_HM_MEMBER_DTLS carries a
-- verified HUB_PARTY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hm_member_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MONTHLY_SALARY'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  MONTHLY_SALARY: 'monthly_salary'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
