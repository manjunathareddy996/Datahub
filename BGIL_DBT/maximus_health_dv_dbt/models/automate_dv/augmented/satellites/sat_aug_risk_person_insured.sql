-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_PERSON_INSURED (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_v17_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_risk_person_insured'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'CONSENT_LETTER_REQUIRED_INDICATOR'
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
