-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_TP_FORENSIC, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DATE_OF_DEATH'
      - 'FIR_REMARKS'
      - 'FIR_TIME'
      - 'POLICE_REPORT_NUMBER'
      - 'POLICE_REPORT_OWN_DAMAGE_INDICATOR'
      - 'POLICE_REPORT_REFERENCE'
      - 'POLICE_REPORT_TIME'
      - 'POLICE_STATION_NAME'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_TP_FORENSIC__DATE_OF_DEATH, AUG_CLAIM_TP_FORENSIC__FIR_REMARKS, AUG_CLAIM_TP_FORENSIC__FIR_TIME, AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_NUMBER, AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_OWN_DAMAGE_INDICATOR, AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_REFERENCE, AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_TIME, AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  DATE_OF_DEATH: 'AUG_CLAIM_TP_FORENSIC__DATE_OF_DEATH'
  FIR_REMARKS: 'AUG_CLAIM_TP_FORENSIC__FIR_REMARKS'
  FIR_TIME: 'AUG_CLAIM_TP_FORENSIC__FIR_TIME'
  POLICE_REPORT_NUMBER: 'AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_NUMBER'
  POLICE_REPORT_OWN_DAMAGE_INDICATOR: 'AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_OWN_DAMAGE_INDICATOR'
  POLICE_REPORT_REFERENCE: 'AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_REFERENCE'
  POLICE_REPORT_TIME: 'AUG_CLAIM_TP_FORENSIC__POLICE_REPORT_TIME'
  POLICE_STATION_NAME: 'AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
