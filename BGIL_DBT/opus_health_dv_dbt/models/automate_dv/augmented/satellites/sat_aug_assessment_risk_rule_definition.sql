-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_ASSESSMENT_RISK_RULE_DEFINITION (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_v03_assessment.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_assessment_risk_rule_definition'
src_pk: 'ASSESSMENT_HKEY'
src_payload:
  - 'RISK_CATEGORY_CODE'
  - 'RISK_RULE_NAME'
  - 'RISK_SUB_CATEGORY_CODE'
  - 'RULE_CONTRIBUTION_SCORE'
  - 'RULE_DEVELOPED_BY_USER_REFERENCE'
  - 'RULE_EFFECTIVE_FROM_DATE'
  - 'RULE_EFFECTIVE_TO_DATE'
  - 'RULE_LAST_MAINTAINED_BY_USER_REFERENCE'
  - 'RULE_LAST_MAINTAINED_TIMESTAMP'
  - 'RULE_MODULE_IDENTIFIER'
  - 'RULE_TRIGGER_EXPRESSION'
  - 'RULE_TRIGGER_TYPE'
  - 'RULE_VERSION_NUMBER'
  - 'SUSPECTED_FRAUD_SCENARIO_DESCRIPTION'
  - 'SUSPECTED_FRAUD_SCENARIO_REFERENCE'
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
