{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PROVIDER_TARIFF, table 'BJAZ_HM_HOSPITAL_MASTER'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hm_hospital_master'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNTPERCENTAGE'
      - 'EFFECTIVEDATE'
      - 'EXPIRYDATE'
      - 'TARIFFRATE'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  DISCOUNTPERCENTAGE: 'imps_discnt_on'
  EFFECTIVEDATE: 'imps_tarif_frm'
  EXPIRYDATE: 'imps_tarif_to'
  TARIFFRATE: 'imps_payment_lmt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
