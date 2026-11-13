{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER sat_multi_source() for SAT_LNK_ROLE_CUSTOMER.
-- Writes the SAME physical table as the other projects' models of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.
-- Change detection and watermark are per (PARTY_HKEY, RECORD_SOURCE), so other projects' rows
-- are never touched. Payload column names are the shared underscore form; the renames happen in
-- satfeed_mp_sat__lnk_role_customer.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mp_sat__lnk_role_customer'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CONSENT_FOR_DATA_SHARING_INDICATOR'
  - 'PREFERRED_CUSTOMER_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mp_sat__lnk_role_customer: 'MAXIMUS_PARTNER'
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
                        'satfeed_mp_sat__lnk_role_customer': ['CONSENT_FOR_DATA_SHARING_INDICATOR', 'PREFERRED_CUSTOMER_INDICATOR']
                    }) }}
