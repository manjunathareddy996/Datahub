{{ config(materialized='incremental') }}
-- TRAVEL STANDARD-MODEL link() for LNK_RISK_OBJECT_LOCATION (Risk Object Location). Writes the shared LNK_RISK_OBJECT_LOCATION table.
{%- set yaml_metadata -%}
source_model: 'stg2_lnk_risk_object_location'
src_pk: 'RISK_OBJECT_LOCATION_HKEY'
src_fk:
  - 'LOCATION_HKEY'
  - 'RISK_OBJECT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
