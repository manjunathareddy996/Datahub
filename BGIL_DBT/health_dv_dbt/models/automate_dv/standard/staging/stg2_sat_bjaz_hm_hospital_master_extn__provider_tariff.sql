{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PROVIDER_TARIFF, table 'BJAZ_HM_HOSPITAL_MASTER_EXTN' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master_extn'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_PERCENTAGE'
      - 'EFFECTIVE_DATE'
      - 'EXPIRY_DATE'
      - 'PACKAGE_RATE'
      - 'SERVICE_DESCRIPTION'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  SERVICE_CODE_CK: '!'
  DISCOUNT_PERCENTAGE: 'pp_discount1'
  EFFECTIVE_DATE: 'tariff_from_date'
  EXPIRY_DATE: 'tariff_to_date'
  PACKAGE_RATE: 'package_rates'
  SERVICE_DESCRIPTION: 'pp_disc_services1'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
