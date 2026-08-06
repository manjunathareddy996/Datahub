{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_HEALTH_PROFILE (HUB_PARTY grain) -- stitch-backed, 4 table(s).
-- Source: stg2_party_health_profile.

{%- set yaml_metadata -%}
source_model: 'stg2_party_health_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BODYMASSINDEX'
  - 'HEIGHT'
  - 'MATERNITYSTATUS'
  - 'SMOKERINDICATOR'
  - 'WEIGHT'
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
