{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['LOCATION_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_LOCATION (HUB_LOCATION grain).
-- 2 contributing table(s). NOT part of the canonical
-- data_5a.js model -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_cp_addresses__location'
  - 'stg2_aug_cp_partners__location'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ADDRESS_LINE4'
  - 'ADDRESS_LINE5'
  - 'CARE_OF_NAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_cp_addresses__location: 'OPUS'
  stg2_aug_cp_partners__location: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_aug_cp_addresses__location': ['ADDRESS_LINE4', 'ADDRESS_LINE5'],
                        'stg2_aug_cp_partners__location': ['CARE_OF_NAME']
                    }) }}
