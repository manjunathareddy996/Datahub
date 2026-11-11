-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_PORTABILITY_MIGRATION (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v17_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_portability_migration'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'FIRST_ORIGINAL_POLICY_REFERENCE'
  - 'FIRST_POLICY_INCEPTION_DATE'
  - 'FIRST_POLICY_NUMBER'
  - 'FIRST_POLICY_REFERENCE'
  - 'ORIGINATING_POLICY_NUMBER'
  - 'PORTABILITY_REASON'
  - 'PORTED_CUMULATIVE_BONUS_AMOUNT'
  - 'PREVIOUS_INSURER_BRANCH_ADDRESS'
  - 'PREVIOUS_POLICY_DEDUCTIBLE'
  - 'PREVIOUS_POLICY_DETAIL'
  - 'PREVIOUS_POLICY_EXPIRY_DATE'
  - 'PREVIOUS_POLICY_INCEPTION_DATE'
  - 'PREVIOUS_POLICY_START_DATE'
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
