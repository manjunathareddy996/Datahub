-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_LNK_POLICY_PARTY_ROLE (parent LNK_POLICY_PARTY, history SCD2), fed whole from central view stitch_v23_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_lnk_policy_party_role'
src_pk: 'POLICY_PARTY_HKEY'
src_payload:
  - 'DISCLAIMER_ACCEPTED_INDICATOR'
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
