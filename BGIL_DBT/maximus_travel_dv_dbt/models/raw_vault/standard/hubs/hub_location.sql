{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL hub() for HUB_LOCATION.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The key is a business code, never a hash, with ONE ratified exception: HUB_LOCATION's
-- address content hash. Where the code needed a spine join it was recovered upstream in
-- resolved_mt__*, so by here it is just a column.

{%- set yaml_metadata -%}
source_model: 'hubfeed_mt_location'
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
