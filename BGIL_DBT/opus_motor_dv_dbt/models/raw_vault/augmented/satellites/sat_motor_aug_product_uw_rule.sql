-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_PRODUCT_UW_RULE (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_motor__v21_product.
-- GRAIN_UNRATIFIED (P-2): emitted as the map states. Self-named child-key blocks here write several
-- attributes of ONE entity, shredding it into child rows. Not ratified as a grain change; routed to the modeller.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__product_uw_rule'
src_pk:
  - 'PRODUCT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER_CK'
  - 'RULE_CODE_CK'
src_payload:
  - 'APPLICABILITY_BUSINESS_TYPE'
  - 'APPLICABILITY_DUMPER_OR_TIPPER_INDICATOR'
  - 'APPLICABILITY_ENGINE_CAPACITY_FROM'
  - 'APPLICABILITY_ENGINE_CAPACITY_TO'
  - 'APPLICABILITY_ENGINE_CAPACITY_TYPE'
  - 'APPLICABILITY_FUEL_TYPE'
  - 'APPLICABILITY_ISSUANCE_SOURCE'
  - 'APPLICABILITY_POLICY_PLAN'
  - 'APPLICABILITY_POLICY_TERM'
  - 'APPLICABILITY_RTA_CLUSTER'
  - 'APPLICABILITY_VEHICLE_AGE_FROM'
  - 'APPLICABILITY_VEHICLE_AGE_TO'
  - 'APPLICABILITY_VEHICLE_MAKE'
  - 'APPLICABILITY_VEHICLE_MODEL'
  - 'APPLICABILITY_VEHICLE_TYPE'
  - 'APPLICABLE_BUSINESS_TYPE'
  - 'APPLICABLE_POLICY_PLAN_CODE'
  - 'APPLICABLE_VEHICLE_CODE'
  - 'APPLICABLE_VEHICLE_TYPE_CODE'
  - 'CONFIGURATION_ROW_REFERENCE'
  - 'EXPIRY_DATE'
  - 'MINIMUM_RID_VALUE'
  - 'RULE_ACTIVE_INDICATOR'
  - 'RULE_STATUS'
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
