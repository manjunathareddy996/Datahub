{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES (HUB_POLICY grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_ecard_pol_dtls_config__product_health_membership_rules'
src_pk: 'POLICY_HK'
src_payload:
  - 'NATURAL_ADDITION_NEWBORN_DAYS'
  - 'NATURAL_ADDITION_RULE_INDICATOR'
  - 'NATURAL_ADDITION_SPOUSE_DAYS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
