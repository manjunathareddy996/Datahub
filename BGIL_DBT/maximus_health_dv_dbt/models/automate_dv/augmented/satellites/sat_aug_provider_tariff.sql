-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PROVIDER_TARIFF (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_provider_tariff'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'SERVICE_CODE_CK'
src_payload:
  - 'I3_TARIFF_PRICE'
  - 'I3_TARIFF_REMARKS'
  - 'SERVICE_TYPE_CODE'
  - 'SERVICE_TYPE_DESCRIPTION'
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
