-- Standard sat() for SAT_POLICY_BONUS_TRACKING (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v14_org_unit.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_bonus_tracking'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BONUS_AMOUNT'
  - 'CUMULATIVE_BONUS_PERCENTAGE'
  - 'NCB_PERCENTAGE'
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
