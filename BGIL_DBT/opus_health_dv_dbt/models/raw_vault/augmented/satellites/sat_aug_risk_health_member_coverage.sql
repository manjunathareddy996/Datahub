-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_risk_health_member_coverage'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'BENEFIT_OPTION_CODE'
  - 'ENROLMENT_REMARKS'
  - 'HEALTH_COVER_BENEFIT_WAITING_PERIOD'
  - 'INDIVIDUAL_HEALTH_PRODUCT_WAITING_PERIOD'
  - 'MEDICAL_REPORT_RECEIVED_INDICATOR'
  - 'MEMBER_COVER_INCEPTION_DATE'
  - 'MEMBER_RATING_STATUS'
  - 'METRO_CLASSIFICATION'
  - 'NETWORK_HOSPITAL_REFERENCE'
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
