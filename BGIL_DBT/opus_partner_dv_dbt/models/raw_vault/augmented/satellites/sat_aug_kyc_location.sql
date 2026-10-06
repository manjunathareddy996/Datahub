{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_KYC_LOCATION (HUB_LOCATION grain).
-- 2 contributing table(s). LOB-local satellite for mapper-proposed attributes that are
-- NOT in data_7 -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.
-- Each source supplies one payload column; the macro pads the other with NULL.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_m_kyc_voter__location'
  - 'stg2_aug_bjaz_t_ekyc__location'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ELECTORAL_ROLL_PART_NAME'
  - 'FULL_ADDRESS_TEXT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_bjaz_m_kyc_voter__location: 'OPUS'
  stg2_aug_bjaz_t_ekyc__location: 'OPUS'
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
                        'stg2_aug_bjaz_m_kyc_voter__location': ['ELECTORAL_ROLL_PART_NAME'],
                        'stg2_aug_bjaz_t_ekyc__location': ['FULL_ADDRESS_TEXT']
                    }) }}
