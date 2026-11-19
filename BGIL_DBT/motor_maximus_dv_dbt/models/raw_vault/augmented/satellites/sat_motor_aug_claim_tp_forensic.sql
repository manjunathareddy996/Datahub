-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_TP_FORENSIC (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_tp_forensic'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'DATE_OF_DEATH'
  - 'FIR_REMARKS'
  - 'FIR_TIME'
  - 'POLICE_REPORT_NUMBER'
  - 'POLICE_REPORT_OWN_DAMAGE_INDICATOR'
  - 'POLICE_REPORT_REFERENCE'
  - 'POLICE_REPORT_TIME'
  - 'POLICE_STATION_NAME'
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
