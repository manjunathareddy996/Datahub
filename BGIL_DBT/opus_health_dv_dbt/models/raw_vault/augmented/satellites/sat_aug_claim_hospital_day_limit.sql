-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_HOSPITAL_DAY_LIMIT (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v05_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_hospital_day_limit'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'COVER_SECTION_CODE_CK'
  - 'WARD_CLASS_CODE_CK'
src_payload:
  - 'ASSESSED_COMPONENT_VALUE'
  - 'BALANCE_DAYS'
  - 'ELIGIBLE_AMOUNT_PER_DAY'
  - 'TOTAL_DAYS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
