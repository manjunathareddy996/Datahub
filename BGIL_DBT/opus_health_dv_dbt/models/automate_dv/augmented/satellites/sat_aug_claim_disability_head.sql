-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_DISABILITY_HEAD (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v05_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_disability_head'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'COVER_SECTION_CODE_CK'
  - 'DISABILITY_TYPE_CODE_CK'
src_payload:
  - 'APPROVED_DAYS_COUNT'
  - 'DISABILITY_DESCRIPTION'
  - 'DISABILITY_DURATION'
  - 'DISABILITY_PERCENTAGE'
  - 'FITNESS_CERTIFIED_DATE'
  - 'FUNCTIONAL_LOSS_DESCRIPTION'
  - 'INJURY_DATE'
  - 'LEAVE_DURATION'
  - 'LEAVE_FROM_DATE'
  - 'LEAVE_TO_DATE'
  - 'WEEKLY_BENEFIT_AMOUNT'
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
