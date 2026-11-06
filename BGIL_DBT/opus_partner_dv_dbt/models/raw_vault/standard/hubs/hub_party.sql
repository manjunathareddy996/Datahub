{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_PARTY.
-- CP_PARTNERS is the primary partner_id branch, but it is NOT the complete key
-- set: AZBJ_PARTNER_EXTN carries ~45.6k part_ids not in CP_PARTNERS, and
-- BJAZ_INTERMEDIARY contributes intermediary parties on PARTNER_ID. Both are
-- added below (DM-R1 item 6 fix) so party-grain satellites keyed from those
-- tables have a parent hub row.
-- KYC: HUB_PARTY is keyed on part_id only, per mapping/business. KYC tables carry
-- no part_id and are NOT hub sources; KYC satellites resolve part_id through
-- BJAZ_T_KYC_DETAILS.PARTNER_ID and hash onto the same 'HUB_PARTY|' || part_id key.

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
