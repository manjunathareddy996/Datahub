-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_HEALTH_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_health_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ADMISSION_TYPE'
  - 'ASSISTED_REPRODUCTIVE_TECHNOLOGY_INDICATOR'
  - 'BODY_MASS_INDEX'
  - 'CRITICAL_ILLNESS_CATEGORY'
  - 'CRITICAL_ILLNESS_DESCRIPTION'
  - 'EXPECTED_ADMISSION_DATE'
  - 'FITNESS_CERTIFICATION_DATE'
  - 'GRAVIDA_COUNT'
  - 'HOSPITALISATION_TYPE'
  - 'LIVING_CHILDREN_COUNT'
  - 'PREGNANCY_TERMINATION_COUNT'
  - 'PRETERM_BIRTH_COUNT'
  - 'PROVIDER_ADDRESS'
  - 'RADIOLOGIST_DETAIL'
  - 'SECOND_OPINION_COUNT'
  - 'SERVICE_RENDERED_DATE'
  - 'SEVERE_COMORBIDITY_DESCRIPTION'
  - 'SYSTEM_OF_MEDICINE'
  - 'TEST_PACKAGE_DETAIL'
  - 'TOTAL_CO_PAY_AND_DEDUCTIBLE_AMOUNT'
  - 'TRANSPORTATION_MODE'
  - 'TREATMENT_SUB_TYPE'
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
