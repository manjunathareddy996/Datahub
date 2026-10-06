{{ config(materialized='view') }}

-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_T_KYC_INCOMING'.
-- 1 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_POLICY_HEADER.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_incoming'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SALES_ORDER_NUMBER'
derived_columns:
  PARENT_BK: "case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end"
  PARENT_NK: "'HUB_POLICY|' || (case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end)"
  SALES_ORDER_NUMBER: 'order_number'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_INCOMING'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
