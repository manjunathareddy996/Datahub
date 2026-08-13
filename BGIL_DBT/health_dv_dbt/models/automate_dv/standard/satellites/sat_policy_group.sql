{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_POLICY_GROUP (HUB_POLICY grain) -- stitch-backed, 4 table(s) joined.
-- Source: stg2_policy_group.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_group'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CONTRIBUTORY_INDICATOR'
  - 'EMPLOYER_CONTRIBUTION_PERCENTAGE'
  - 'FLOATER_INDICATOR'
  - 'GROUP_SIZE'
  - 'GROUP_TYPE'
  - 'MASTER_POLICY_NUMBER'
  - 'MEMBER_COUNT'
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
