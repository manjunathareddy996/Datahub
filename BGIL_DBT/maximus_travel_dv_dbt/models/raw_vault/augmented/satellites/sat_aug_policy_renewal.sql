{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_POLICY_RENEWAL.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, POLICY_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_policy_renewal'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'EXPIRING_POLICY_INSURER_NAME'
  - 'RENEWAL_APPLICABLE_INDICATOR'
  - 'RENEWAL_INDICATOR'
  - 'RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME'
  - 'RENEWAL_QUOTE_GENERATED_INDICATOR'
  - 'REPLACED_POLICY_EXPIRY_DATE'
  - 'REPLACED_POLICY_INCEPTION_DATE'
  - 'REPLACED_POLICY_PRODUCT_CODE'
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
