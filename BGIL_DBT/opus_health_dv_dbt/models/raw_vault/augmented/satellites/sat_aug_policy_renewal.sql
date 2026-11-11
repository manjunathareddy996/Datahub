-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_RENEWAL (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v26_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_renewal'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'FIRST_POLICY_REFERENCE'
  - 'FIRST_POLICY_REFERENCE_IN_CONTINUITY_CHAIN'
  - 'PRECEDING_POLICY_EXPIRY_DATE'
  - 'PREVIOUS_YEAR_SUM_INSURED_AMOUNT'
  - 'RENEWAL_BUSINESS_INDICATOR'
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
