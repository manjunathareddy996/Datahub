{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL hub() for HUB_LOCATION, 2 contributing table(s), 4 branches --
-- trip-transit points (TRANSITFROM/TRANSITTO) plus address points (content-hash of the full
-- normalized address, added in round 2 -- see the two __location_addr.sql stage files).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__location_transitfrom'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__location_transitto'
  - 'stg2_hub_bjaz_trv_loader_data_mv__location_addr'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__location_addr'
src_pk: 'LOCATION_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
