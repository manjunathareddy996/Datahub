-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_SALVAGE_BIDDER (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_salvage_bidder'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BIDDER_SEQUENCE_CK'
  - 'BIDDER_NAME_CK'
src_payload:
  - 'BIDDER_DETAILS_TEXT'
  - 'BID_INVITATION_SENT_DATE'
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
