{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_TREATY_PRODUCT member-end 'bjaz_gpg_pol_dtls'.
-- PRODUCT_HKEY is hashed with the EXACT SAME formula ('HUB_PRODUCT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for REINSURANCE_TREATY_HKEY.
-- TREATY_PRODUCT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gpg_pol_dtls'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_HKEY_NK'
  REINSURANCE_TREATY_HKEY: 'REINSURANCE_TREATY_HKEY_NK'
  TREATY_PRODUCT_HKEY: 'TREATY_PRODUCT_HKEY_NK'
derived_columns:
  PRODUCT_HKEY_NK: "'HUB_PRODUCT|' || product_code"
  REINSURANCE_TREATY_HKEY_NK: "'HUB_REINSURANCE_TREATY|' || re_insu"
  TREATY_PRODUCT_HKEY_NK: "'LNK_TREATY_PRODUCT|' || product_code || '|' || re_insu"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GPG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
