-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_LNK_PARTY_ROLE_CORE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__lnk_party_role_core'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ROLE_CODE_CK'
  - 'ROLE_SEQUENCE_CK'
src_payload:
  - 'OTHER_RELATIONSHIP_DESCRIPTION'
  - 'RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER'
  - 'RELATIONSHIP_TO_INSURED'
  - 'RELATIONSHIP_TO_INSURER_EMPLOYEE'
  - 'RELATIONSHIP_TO_PRIVE_CUSTOMER'
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
