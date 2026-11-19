-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_RISK_MOTOR_CPA (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v15_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_RISK_MOTOR_CPA | PA Nominee Detail Text | None: emits NOMINEE_DETAIL, SCPA_NOMINEE_DETAILS (merged in column-name order, no redundant_of invented); withheld -
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | SAT_MOTOR_AUG_RISK_MOTOR_CPA | PA Nominee Detail Text | None: emits NOMINEE_DETAIL, SCPA_NOMINEE_DETAILS (merged in column-name order, no redundant_of invented); withheld -
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__risk_motor_cpa'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'COMPULSORY_PA_DURATION'
  - 'COMPULSORY_PA_DURATION_UNIT'
  - 'COMPULSORY_PA_EXPIRY_NOTICE'
  - 'COMPULSORY_PA_NOMINATION_PERCENTAGE'
  - 'COMPULSORY_PA_NOMINEE_NAME'
  - 'COMPULSORY_PA_NOMINEE_RELATIONSHIP'
  - 'COMPULSORY_PA_POLICY_EXPIRY_DATE'
  - 'COMPULSORY_PA_POLICY_INCEPTION_DATE'
  - 'COMPULSORY_PA_POLICY_NUMBER'
  - 'PA_NOMINEE_DETAIL_TEXT'
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
