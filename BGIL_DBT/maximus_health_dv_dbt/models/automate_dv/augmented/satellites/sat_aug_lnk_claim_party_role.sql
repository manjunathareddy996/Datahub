-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_LNK_CLAIM_PARTY_ROLE (parent LNK_CLAIM_PARTY, history SCD2), fed whole from central view stitch_v04_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_lnk_claim_party_role'
src_pk: 'CLAIM_PARTY_HKEY'
src_cdk:
  - 'PARTY_ROLE_TYPE_CK'
  - 'ROLE_SEQUENCE_CK'
src_payload:
  - 'FIXED_PAYMENT_AMOUNT'
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
