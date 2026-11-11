-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_ENDORSEMENT (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v23_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_endorsement'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BROKERAGE_ON_ENDORSEMENT'
  - 'ENDORSEMENT_RAISED_DUE_TO_CODE'
  - 'ENDORSEMENT_WORDING_TEXT'
  - 'MAIN_AGENT_COMMISSION_ON_ENDORSEMENT'
  - 'MAIN_AGENT_SERVICE_CHARGE_ON_ENDORSEMENT'
  - 'SERVICE_TAX_ON_ENDORSEMENT'
  - 'SPECIAL_DISCOUNT_ON_ENDORSEMENT'
  - 'SUB_AGENT_SERVICE_CHARGE_ON_ENDORSEMENT'
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
