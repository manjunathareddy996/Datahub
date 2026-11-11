-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PRODUCT_CAPTURE_PARAMETER (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_v31_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_product_capture_parameter'
src_pk: 'PRODUCT_HKEY'
src_cdk:
  - 'SCHEME_VERSION_CK'
  - 'PARAMETER_REFERENCE_CK'
src_payload:
  - 'ALPHABETIC_ONLY_INDICATOR'
  - 'APPLICABLE_COVER_CODE'
  - 'APPLICABLE_PLAN_IDENTIFIER_LIST'
  - 'APPLICABLE_SECTION_IDENTIFIER'
  - 'DISPLAY_AND_VALIDATE_COVER_SCOPE'
  - 'MAXIMUM_VALUE_LENGTH'
  - 'MEMBER_LEVEL_PARAMETER_REFERENCE'
  - 'MINIMUM_VALUE_LENGTH'
  - 'NIL_ENDORSEMENT_ALLOWED_INDICATOR'
  - 'NIL_ENDORSEMENT_PARAMETER_REFERENCE'
  - 'NR_SEARCH_FIELD_INDICATOR'
  - 'PARAMETER_DATA_TYPE'
  - 'PARAMETER_DISPLAY_LABEL'
  - 'PARAMETER_IDENTIFIER'
  - 'PARAMETER_PERMITTED_VALUES_LIST'
  - 'PARAMETER_TERM_NAME'
  - 'POST_ISSUANCE_UPDATE_ALLOWED_INDICATOR'
  - 'POST_ISSUANCE_UPDATE_RULE'
  - 'PRINT_ONCE_PER_MEMBER_INDICATOR'
  - 'PRINT_ON_DOCUMENT_INDICATOR'
  - 'TRANSCRIPT_PARAMETER_REFERENCE'
  - 'VALIDATION_HARD_STOP_INDICATOR'
  - 'VALIDATION_STOP_TRIGGER_VALUE'
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
