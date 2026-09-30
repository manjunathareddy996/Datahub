{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_PARTY.
-- CP_PARTNERS holds every partner_id, so a single cp_partners branch is the
-- authoritative source for the full HUB_PARTY key set. The previous per-table
-- hub stages were redundant against this and have been removed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_cp_partners__party'
src_pk: 'PARTY_HKEY'
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
