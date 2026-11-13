{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat_multi_source() for SAT_LNK_ROLE_AGENT.
-- Writes the SAME physical table as the partner projects: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- Keyed on PARTY_HKEY (same as maximus_partner / opus_partner). The role is carried by the
-- satellite name, so PARTY_HKEY gives the same grain as PARTY_ROLE_HKEY. sat_multi_source keeps
-- change detection and the watermark per (PARTY_HKEY, RECORD_SOURCE), so MAXIMUS_TRAVEL_* rows
-- never interact with the partners' rows.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_lnk_role_agent'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGENT_CODE'
  - 'IRDAI_AGENT_LICENCE_NUMBER'
  - 'IRDA_LISTED_PRIMARY_PROFESSION'
  - 'LICENCE_CATEGORY'
  - 'LICENCE_DETAILS_DESCRIPTION'
  - 'LICENCE_EXPIRY_DATE'
  - 'LICENCE_ISSUE_DATE'
  - 'SPECIAL_TDS_RATE'
  - 'SPECIAL_TDS_RATE_APPLICABLE_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_lnk_role_agent: 'MAXIMUS_TRAVEL'
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
                        'satfeed_mt_sat_lnk_role_agent': ['AGENT_CODE', 'IRDAI_AGENT_LICENCE_NUMBER', 'IRDA_LISTED_PRIMARY_PROFESSION', 'LICENCE_CATEGORY', 'LICENCE_DETAILS_DESCRIPTION', 'LICENCE_EXPIRY_DATE', 'LICENCE_ISSUE_DATE', 'SPECIAL_TDS_RATE', 'SPECIAL_TDS_RATE_APPLICABLE_INDICATOR']
                    }) }}
