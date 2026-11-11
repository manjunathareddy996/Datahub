-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_ANOMALY_DETECTION (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v06_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_anomaly_detection'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ANOMALY_DESCRIPTION'
  - 'ANOMALY_DETECTED_TIMESTAMP'
  - 'ANOMALY_FOUND_INDICATOR'
  - 'ANOMALY_SUB_TYPE_CODE'
  - 'ANOMALY_SUPPORTING_DOCUMENT_URI'
  - 'ANOMALY_TYPE_CODE'
  - 'BYPASS_AUTHORISED_BY_USER_REFERENCE'
  - 'BYPASS_DECISION_TIMESTAMP'
  - 'BYPASS_REMARKS'
  - 'DOCUMENT_CLASS_EXAMINED'
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
