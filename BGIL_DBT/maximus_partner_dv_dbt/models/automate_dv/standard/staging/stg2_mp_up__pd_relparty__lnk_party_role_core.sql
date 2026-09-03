{{ config(materialized='view') }}

-- stage() over the SAT_LNK_PARTY_ROLE_CORE unpivot for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY: one hashing pass over all 1 rows.

{%- set yaml_metadata -%}
source_model: 'unpivot_mp__pd_relparty__lnk_party_role_core'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_LNK_PARTY_ROLE_CORE:
    is_hashdiff: true
    columns:
      - 'ROLECODE'
      - 'ROLEENDDATE'
      - 'ROLESTARTDATE'
      - 'ROLETYPE'
derived_columns:
  PARTY_BK: "parent_bk"
  PARTY_NK: "'HUB_PARTY|' || (parent_bk)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
