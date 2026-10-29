{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_PARTY_RELATIONSHIP_PROFILE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 5 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_prp'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_PARTY_RELATIONSHIP_PROFILE:
    is_hashdiff: true
    columns:
      - 'EXISTING_CUSTOMER_DECLARED_INDICATOR'
      - 'RELATED_PARTY_REFERENCE'
      - 'RELATIONSHIP_WITH_EMPLOYEE'
      - 'RELATIONSHIP_WITH_HNI_CUSTOMER'
      - 'RELATIONSHIP_WITH_PRIVE_CUSTOMER'
derived_columns:
  PARTY_BK__PROPOSER: "nullif(trim(case when nullif(trim(party_code),'') is not null then nullif(trim(party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(party_code),'') is not null then nullif(trim(party_code), '') end),''))"
  EXISTING_CUSTOMER_DECLARED_INDICATOR: 'cast(null as varchar)'
  RELATED_PARTY_REFERENCE: 'related_party'
  RELATIONSHIP_WITH_EMPLOYEE: 'cast(null as varchar)'
  RELATIONSHIP_WITH_HNI_CUSTOMER: 'cast(null as varchar)'
  RELATIONSHIP_WITH_PRIVE_CUSTOMER: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
