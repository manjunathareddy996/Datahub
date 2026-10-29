{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_COMMON_COMMUNICATION_PREFERENCE, at HUB_PARTY grain.
-- partner_dv_dbt does not build sat_aug_common_communication_preference; Maximus-only augmented table.
-- Payload columns are the mapper's PROPOSED ATTRIBUTE names in partner_dv_dbt's own rendering
-- (squashed), not raw Maximus column names -- a shared table must not gain a second column for a
-- fact that already has one. NOT part of the canonical model.
--
-- Writes the SAME physical table as the sibling travel LOB (maximus_travel / opus_travel). The
-- sibling created it with the bare HASHDIFF column, so src_hashdiff_alias='HASHDIFF' renames
-- this project's suffixed source hashdiff into that shared column. Uses sat_multi_source (list
-- path) because the alias is only supported there -- the single-string delegation drops to
-- automate_dv.sat() which has no alias parameter.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_mp__pd_prop_sp_pv__party'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'PREFERREDALERTMODE'
src_hashdiff: 'HASHDIFF_AUG_COMMON_COMMUNICATION_PREFERENCE'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_mp__pd_prop_sp_pv__party: 'MAXIMUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_hashdiff_alias='HASHDIFF',
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_aug_mp__pd_prop_sp_pv__party': ['PREFERREDALERTMODE']
                    }) }}
