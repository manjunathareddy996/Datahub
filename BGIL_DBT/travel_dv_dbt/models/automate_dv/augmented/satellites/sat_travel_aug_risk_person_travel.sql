{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_RISK_PERSON_TRAVEL.


{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_risk_person_travel_bjaz_trv_loader_data_mv_member1'
  - 'stg2_aug_risk_person_travel_bjaz_trv_loader_data_mv_member2'
  - 'stg2_aug_risk_person_travel_bjaz_trv_loader_data_mv_member3'
  - 'stg2_aug_risk_person_travel_bjaz_trv_loader_data_mv_member4'
  - 'stg2_aug_risk_person_travel_bjaz_trv_loader_data_mv_member5'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'ALTITUDE_LIMIT'
  - 'MODE_OF_TRANSPORT'
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
