-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_CERTIFICATE (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v09_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_certificate'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ANNUAL_EMPLOYER_CONTRIBUTION_AMOUNT'
  - 'ELIGIBLE_COVERAGE_DAYS'
  - 'FINAL_PAYABLE_AMOUNT'
  - 'PRO_RATA_EMPLOYER_CONTRIBUTION_AMOUNT'
  - 'PRO_RATA_MEMBER_PREMIUM'
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
